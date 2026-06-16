"""Exporter for Intune policies and mobileconfig files."""

import logging
import json
import plistlib
from typing import List, Dict, Any, Set, Tuple
from pathlib import Path

from ..models.policy import Policy, PolicySetting, MobileConfigPolicy
from ..models.rule import Rule

logger = logging.getLogger(__name__)


class IntuneExporter:
    """Exports policies to Intune JSON and mobileconfig formats."""
    
    def __init__(self, settings_catalog=None):
        """Initialize the exporter.
        
        Args:
            settings_catalog: Optional SettingsCatalog instance for validation
        """
        self.dependencies_map: Dict[str, List[str]] = {}  # rule_id -> [dependent_rule_ids]
        self.settings_catalog = settings_catalog
    
    def analyze_dependencies(self, rules: List[Rule]) -> Dict[str, List[str]]:
        """Analyze rules to find dependencies.
        
        A rule depends on another rule if its mobileconfig_info contains
        settings from the other rule's mobileconfig_info.
        
        Args:
            rules: List of all rules to analyze
            
        Returns:
            Dictionary mapping rule_id to list of rule_ids it depends on
        """
        dependencies = {}
        
        # Build index of settings by domain and key
        settings_by_domain_key = {}
        for rule in rules:
            if not rule.has_mobileconfig:
                continue
            
            for domain, settings in rule.mobileconfig_info.items():
                if isinstance(settings, dict):
                    for key, value in settings.items():
                        settings_key = f"{domain}:{key}"
                        if settings_key not in settings_by_domain_key:
                            settings_by_domain_key[settings_key] = []
                        settings_by_domain_key[settings_key].append(rule.id)
        
        # Find dependencies
        for rule in rules:
            if not rule.has_mobileconfig:
                continue
            
            rule_deps = set()
            rule_own_settings = set()
            
            # Get this rule's primary settings
            for domain, settings in rule.mobileconfig_info.items():
                if isinstance(settings, dict):
                    for key, value in settings.items():
                        settings_key = f"{domain}:{key}"
                        rule_own_settings.add(settings_key)
            
            # Check which settings belong to other rules
            for settings_key in rule_own_settings:
                # Find all rules that define this setting
                rules_with_setting = settings_by_domain_key.get(settings_key, [])
                
                # If another rule also has this exact setting, it might be a dependency
                for other_rule_id in rules_with_setting:
                    if other_rule_id != rule.id:
                        # Check if the other rule's settings are a subset of this rule's settings
                        # (meaning this rule depends on the other)
                        other_rule = next((r for r in rules if r.id == other_rule_id), None)
                        if other_rule and self._is_dependency(rule, other_rule):
                            rule_deps.add(other_rule_id)
            
            if rule_deps:
                dependencies[rule.id] = sorted(list(rule_deps))
        
        self.dependencies_map = dependencies
        return dependencies
    
    def _is_dependency(self, rule: Rule, potential_dep: Rule) -> bool:
        """Check if potential_dep is a dependency of rule.
        
        Args:
            rule: The rule that might depend on potential_dep
            potential_dep: The potential dependency rule
            
        Returns:
            True if potential_dep's settings are a subset of rule's settings
        """
        if not potential_dep.has_mobileconfig:
            return False
        
        # Get all settings from potential_dep
        dep_settings = set()
        for domain, settings in potential_dep.mobileconfig_info.items():
            if isinstance(settings, dict):
                for key in settings.keys():
                    dep_settings.add(f"{domain}:{key}")
        
        # Get all settings from rule
        rule_settings = set()
        for domain, settings in rule.mobileconfig_info.items():
            if isinstance(settings, dict):
                for key in settings.keys():
                    rule_settings.add(f"{domain}:{key}")
        
        # Check if dep_settings is a proper subset of rule_settings
        # (proper = not equal, all dep settings are in rule)
        return dep_settings < rule_settings  # Proper subset
    
    def export_to_intune_json(self, policies: List[Policy], baseline_name: str = "Generated Policy", include_dependencies: bool = True) -> str:
        """Export policies to Intune JSON format as a single combined policy.
        
        Args:
            policies: List of Policy objects to export
            baseline_name: Name for the combined policy
            include_dependencies: Whether to include dependency information
            
        Returns:
            JSON string containing a single Intune policy with all settings
        """
        # Collect all settings from all policies
        all_policy_settings = []
        
        for policy in policies:
            all_policy_settings.extend(policy.settings)
        
        # Merge settings with the same root settingDefinitionId
        merged_settings = self._merge_duplicate_settings(all_policy_settings)
        
        # Convert to Intune format with template references
        intune_settings = []
        for setting in merged_settings:
            # Add settingInstanceTemplateReference to all instances
            setting_with_template = {
                "@odata.type": "#microsoft.graph.deviceManagementConfigurationSetting",
                "settingInstance": self._add_template_references(setting.setting_instance)
            }
            intune_settings.append(setting_with_template)
        
        # Create single Intune policy structure
        intune_policy = {
            "@odata.type": "#microsoft.graph.deviceManagementConfigurationPolicy",
            "name": baseline_name,
            "description": f"macOS security baseline configuration with {len(intune_settings)} settings",
            "platforms": "macOS",
            "technologies": "mdm,appleRemoteManagement",
            "settings": intune_settings,
            "templateReference": {
                "templateId": "",
                "templateFamily": "none",
                "templateDisplayName": None,
                "templateDisplayVersion": None
            },
            "roleScopeTagIds": ["0"]
        }
        
        return json.dumps(intune_policy, indent=2)
    
    def _merge_duplicate_settings(self, policy_settings: List[PolicySetting]) -> List[PolicySetting]:
        """Merge PolicySettings that have the same settingDefinitionId.
        
        Intune requires that all children for a group be combined into a single instance.
        This method groups settings by settingDefinitionId and merges their children.
        
        Args:
            policy_settings: List of PolicySettings to merge
            
        Returns:
            List of merged PolicySettings (no duplicates)
        """
        from collections import defaultdict
        
        logger.info(f"Merging {len(policy_settings)} policy settings...")
        
        # Group settings by their settingDefinitionId
        settings_by_id = defaultdict(list)
        for setting in policy_settings:
            settings_by_id[setting.setting_definition_id].append(setting)
        
        logger.info(f"Found {len(settings_by_id)} unique setting IDs")
        for setting_id, settings_list in settings_by_id.items():
            if len(settings_list) > 1:
                logger.info(f"  {setting_id}: {len(settings_list)} instances - MERGING")
        
        # Merge settings with the same ID
        merged = []
        for setting_id, settings_list in settings_by_id.items():
            if len(settings_list) == 1:
                # No duplicates - use as-is
                merged.append(settings_list[0])
            else:
                # Multiple settings with same ID - merge their children
                merged_setting = self._merge_group_settings(settings_list)
                merged.append(merged_setting)
        
        logger.info(f"Merged result: {len(merged)} settings")
        return merged
    
    def _merge_group_settings(self, settings: List[PolicySetting]) -> PolicySetting:
        """Merge multiple PolicySettings with the same ID into one.
        
        Args:
            settings: List of PolicySettings with the same settingDefinitionId
            
        Returns:
            Single merged PolicySetting
        """
        from copy import deepcopy
        
        # Use the first setting as base
        base_setting = settings[0]
        merged_instance = deepcopy(base_setting.setting_instance)
        
        # Get the base children list
        odata_type = merged_instance.get('@odata.type', '')
        if 'GroupSettingCollection' not in odata_type:
            # Not a group - can't merge (shouldn't happen, but handle gracefully)
            return base_setting
        
        group_values = merged_instance.get('groupSettingCollectionValue', [])
        if not group_values:
            return base_setting
        
        base_children = group_values[0].get('children', [])
        
        # Get parent group's valid child IDs from Settings Catalog
        parent_id = base_setting.setting_definition_id
        parent_def = self.settings_catalog._settings_index.get(parent_id) if hasattr(self, 'settings_catalog') else None
        valid_child_ids = set(parent_def.get('childIds', [])) if parent_def else None
        
        # Collect all unique children from all settings
        # Track by settingDefinitionId to avoid true duplicates
        # ONLY include children that belong to this parent group
        children_by_id = {}
        for child in base_children:
            child_id = child.get('settingDefinitionId')
            if child_id:
                # Validate child belongs to this parent
                if valid_child_ids is None or child_id in valid_child_ids:
                    children_by_id[child_id] = child
                else:
                    logger.warning(f"Skipping child {child_id} - does not belong to parent {parent_id}")
        
        # Add children from other settings
        for setting in settings[1:]:
            setting_instance = setting.setting_instance
            group_vals = setting_instance.get('groupSettingCollectionValue', [])
            if group_vals:
                children = group_vals[0].get('children', [])
                for child in children:
                    child_id = child.get('settingDefinitionId')
                    if child_id:
                        # Only add if not duplicate AND belongs to this parent
                        if child_id not in children_by_id:
                            if valid_child_ids is None or child_id in valid_child_ids:
                                children_by_id[child_id] = child
                            else:
                                logger.warning(f"Skipping child {child_id} - does not belong to parent {parent_id}")
        
        # Update merged instance with all valid unique children
        group_values[0]['children'] = list(children_by_id.values())
        
        logger.info(f"Merged {len(settings)} instances of {parent_id} into 1 with {len(children_by_id)} children")
        
        return PolicySetting(
            setting_definition_id=base_setting.setting_definition_id,
            setting_instance=merged_instance,
            name=base_setting.name,
            description=base_setting.description
        )
    
    def _add_template_references(self, setting_instance: Dict[str, Any]) -> Dict[str, Any]:
        """Recursively add settingInstanceTemplateReference fields to setting instances.
        
        Args:
            setting_instance: Setting instance dict
            
        Returns:
            Setting instance with templateReference fields added
        """
        from copy import deepcopy
        instance = deepcopy(setting_instance)
        
        # Add settingInstanceTemplateReference at current level
        if "settingInstanceTemplateReference" not in instance:
            instance["settingInstanceTemplateReference"] = None
        
        odata_type = instance.get('@odata.type', '')
        
        # Handle group settings with children
        if 'GroupSettingCollection' in odata_type:
            group_values = instance.get('groupSettingCollectionValue', [])
            for group_value in group_values:
                # Add settingValueTemplateReference to group value
                if "settingValueTemplateReference" not in group_value:
                    group_value["settingValueTemplateReference"] = None
                
                # Recursively process children
                children = group_value.get('children', [])
                for i, child in enumerate(children):
                    children[i] = self._add_template_references(child)
        
        # Handle choice settings
        elif 'ChoiceSetting' in odata_type:
            choice_value = instance.get('choiceSettingValue', {})
            if "settingValueTemplateReference" not in choice_value:
                choice_value["settingValueTemplateReference"] = None
        
        # Handle simple settings
        elif 'SimpleSetting' in odata_type:
            simple_value = instance.get('simpleSettingValue', {})
            if "settingValueTemplateReference" not in simple_value:
                simple_value["settingValueTemplateReference"] = None
        
        return instance
    
    def export_to_mobileconfig(self, rule: Rule) -> str:
        """Export a rule's mobileconfig to XML plist format.
        
        Args:
            rule: Rule object with mobileconfig_info
            
        Returns:
            XML plist string
        """
        if not rule.has_mobileconfig:
            raise ValueError(f"Rule {rule.id} has no mobileconfig information")
        
        # Create payload content from mobileconfig_info
        payload_content = {
            "PayloadType": "com.apple.ManagedClient.preferences",
            "PayloadVersion": 1,
            "PayloadIdentifier": f"com.apple.security.{rule.id}",
            "PayloadUUID": self._generate_uuid(),
            "PayloadEnabled": True,
            "PayloadDisplayName": rule.title,
            "PayloadContent": []
        }
        
        # Process mobileconfig_info
        for domain, settings in rule.mobileconfig_info.items():
            if isinstance(settings, dict):
                # Nested structure (e.g., com.apple.ManagedClient.preferences -> domain -> settings)
                for sub_domain, sub_settings in settings.items():
                    if isinstance(sub_settings, dict):
                        domain_payload = {
                            domain: {
                                "Forced": [
                                    {
                                        "mcx_preference_settings": sub_settings
                                    }
                                ]
                            }
                        }
                        payload_content["PayloadContent"].append(domain_payload)
                    else:
                        # Simple setting
                        payload_content["PayloadContent"].append({domain: {sub_domain: sub_settings}})
            else:
                # Direct setting
                payload_content["PayloadContent"].append({domain: settings})
        
        # Create top-level mobileconfig
        mobileconfig = {
            "PayloadContent": [payload_content],
            "PayloadDescription": rule.discussion[:100] if rule.discussion else rule.title,
            "PayloadDisplayName": rule.title,
            "PayloadIdentifier": f"com.apple.security.{rule.id}",
            "PayloadType": "Configuration",
            "PayloadUUID": self._generate_uuid(),
            "PayloadVersion": 1
        }
        
        return plistlib.dumps(mobileconfig, fmt=plistlib.FMT_XML).decode('utf-8')
    
    def export_combined_mobileconfig(self, rules: List[Rule]) -> str:
        """Export multiple rules to a single combined mobileconfig file.
        
        Args:
            rules: List of Rule objects to combine
            
        Returns:
            XML plist string containing all rules
        """
        # Collect all payload content from all rules
        all_payload_content = []
        
        for rule in rules:
            if not rule.has_mobileconfig:
                continue
            
            # Create payload content for this rule
            payload_content = {
                "PayloadType": "com.apple.ManagedClient.preferences",
                "PayloadVersion": 1,
                "PayloadIdentifier": f"com.apple.security.{rule.id}",
                "PayloadUUID": self._generate_uuid(),
                "PayloadEnabled": True,
                "PayloadDisplayName": rule.title,
                "PayloadContent": []
            }
            
            # Process mobileconfig_info for this rule
            for domain, settings in rule.mobileconfig_info.items():
                if isinstance(settings, dict):
                    # Check if this is a nested structure
                    has_nested = any(isinstance(v, dict) for v in settings.values())
                    
                    if has_nested:
                        # Nested structure (e.g., com.apple.ManagedClient.preferences -> domain -> settings)
                        for sub_domain, sub_settings in settings.items():
                            if isinstance(sub_settings, dict):
                                domain_payload = {
                                    domain: {
                                        "Forced": [
                                            {
                                                "mcx_preference_settings": sub_settings
                                            }
                                        ]
                                    }
                                }
                                payload_content["PayloadContent"].append(domain_payload)
                            else:
                                # Simple setting
                                payload_content["PayloadContent"].append({domain: {sub_domain: sub_settings}})
                    else:
                        # Direct setting
                        payload_content["PayloadContent"].append({domain: settings})
                else:
                    # Direct setting
                    payload_content["PayloadContent"].append({domain: settings})
            
            all_payload_content.append(payload_content)
        
        # Create top-level mobileconfig with all payloads
        mobileconfig = {
            "PayloadContent": all_payload_content,
            "PayloadDescription": f"Combined security settings from {len(rules)} rules",
            "PayloadDisplayName": "macOS Security Baseline - Combined",
            "PayloadIdentifier": "com.apple.security.baseline.combined",
            "PayloadType": "Configuration",
            "PayloadUUID": self._generate_uuid(),
            "PayloadVersion": 1
        }
        
        return plistlib.dumps(mobileconfig, fmt=plistlib.FMT_XML).decode('utf-8')
    
    def _generate_uuid(self) -> str:
        """Generate a UUID."""
        import uuid
        return str(uuid.uuid4()).upper()
