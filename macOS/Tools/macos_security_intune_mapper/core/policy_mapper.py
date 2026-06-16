"""Policy mapper for mapping rules to Intune policies."""

import logging
from typing import Optional, Dict, Any

from .settings_catalog import SettingsCatalog
from ..models.rule import Rule
from ..models.policy import Policy, PolicySetting, PolicyType

logger = logging.getLogger(__name__)


class PolicyMapper:
    """Maps macOS security rules to Intune policies."""
    
    def __init__(self, settings_catalog: SettingsCatalog, prefer_ddm: bool = True):
        """Initialize the policy mapper.
        
        Args:
            settings_catalog: Settings Catalog instance
            prefer_ddm: Prefer DDM over mobileconfig when both available
        """
        self.settings_catalog = settings_catalog
        self.prefer_ddm = prefer_ddm
        self._mapping_cache: Dict[str, Optional[Policy]] = {}
    
    def map_rule_to_policy(self, rule: Rule) -> Optional[Policy]:
        """Map a rule to an Intune policy.
        
        Args:
            rule: Rule to map
            
        Returns:
            Policy object or None if cannot be mapped
        """
        # Check cache
        if rule.id in self._mapping_cache:
            return self._mapping_cache[rule.id]
        
        policy = None
        
        # Prefer DDM over mobileconfig if available
        if self.prefer_ddm and rule.has_ddm:
            policy = self._map_ddm_to_settings_catalog(rule)
        
        # Fall back to mobileconfig if DDM not available or didn't work
        if not policy and rule.has_mobileconfig:
            policy = self._map_to_settings_catalog(rule)
        
        # Cache the result
        self._mapping_cache[rule.id] = policy
        
        if policy:
            logger.info(f"Mapped rule {rule.id} to {policy.policy_type.value} policy with {len(policy.settings)} settings")
        
        return policy
    
    def _ensure_required_children(self, parent_id: str, children: list) -> list:
        """Ensure all required children are present in the children list.
        
        Some Settings Catalog groups have required children that must be present
        even if not explicitly configured. This method adds missing required
        children with their default values.
        
        Args:
            parent_id: The parent group's settingDefinitionId
            children: List of existing child setting instances
            
        Returns:
            Updated children list with required children added
        """
        parent_def = self.settings_catalog._settings_index.get(parent_id)
        if not parent_def:
            return children
        
        # Get list of required children from parent's dependedOnBy array
        depended_on_by = parent_def.get('dependedOnBy', [])
        required_child_ids = [
            dep['dependedOnBy'] for dep in depended_on_by 
            if isinstance(dep, dict) and dep.get('required') == True
        ]
        
        if not required_child_ids:
            return children
        
        # Get IDs of existing children
        existing_child_ids = {
            child.get('settingDefinitionId') for child in children 
            if isinstance(child, dict) and 'settingDefinitionId' in child
        }
        
        # Add missing required children with default values
        for required_id in required_child_ids:
            if required_id not in existing_child_ids:
                child_def = self.settings_catalog._settings_index.get(required_id)
                if child_def:
                    # Create instance with default value
                    default_instance = self._create_child_with_default(child_def)
                    if default_instance:
                        logger.info(f"Adding required child {required_id} with default value to {parent_id}")
                        children.append(default_instance)
        
        return children
    
    def _create_child_with_default(self, child_def: dict) -> Optional[dict]:
        """Create a child setting instance with its default value.
        
        Args:
            child_def: Child setting definition from Settings Catalog
            
        Returns:
            Child setting instance or None
        """
        child_id = child_def.get('id')
        odata_type = child_def.get('@odata.type', '')
        
        if not child_id:
            return None
        
        if 'ChoiceSettingDefinition' in odata_type:
            # Choice setting - use defaultOptionId
            default_option_id = child_def.get('defaultOptionId')
            if not default_option_id:
                return None
            
            return {
                '@odata.type': '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance',
                'settingDefinitionId': child_id,
                'choiceSettingValue': {
                    '@odata.type': '#microsoft.graph.deviceManagementConfigurationChoiceSettingValue',
                    'value': default_option_id,
                    'children': [],
                    'settingValueTemplateReference': None
                },
                'settingInstanceTemplateReference': None
            }
        elif 'SimpleSettingDefinition' in odata_type:
            # Simple setting (string, int, etc.) - use defaultValue
            default_value = child_def.get('defaultValue')
            if not default_value:
                return None
            
            value_def = child_def.get('valueDefinition', {})
            value_type = value_def.get('@odata.type', '')
            
            if 'String' in value_type:
                return {
                    '@odata.type': '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance',
                    'settingDefinitionId': child_id,
                    'simpleSettingValue': {
                        '@odata.type': '#microsoft.graph.deviceManagementConfigurationStringSettingValue',
                        'value': default_value.get('value', ''),
                        'settingValueTemplateReference': None
                    },
                    'settingInstanceTemplateReference': None
                }
            elif 'Integer' in value_type:
                return {
                    '@odata.type': '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance',
                    'settingDefinitionId': child_id,
                    'simpleSettingValue': {
                        '@odata.type': '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue',
                        'value': default_value.get('value', 0),
                        'settingValueTemplateReference': None
                    },
                    'settingInstanceTemplateReference': None
                }
        
        return None
    
    def _map_ddm_to_settings_catalog(self, rule: Rule) -> Optional[Policy]:
        """Map a rule's DDM info to Settings Catalog.
        
        DDM structure example:
            declarationtype: com.apple.configuration.passcode.settings
            ddm_key: CustomRegex
            ddm_value:
                Regex: <value>
                Description: <value>
        
        This maps to Settings Catalog as:
            Root: passcode_passcode (derived from declaration type)
            Child: passcode_customregex (ddm_key converted to lowercase with underscore prefix)
            Grandchildren: passcode_customregex_regex, passcode_customregex_description
        
        Args:
            rule: Rule with ddm_info
            
        Returns:
            Policy object or None
        """
        settings = []
        
        declaration_type = rule.ddm_info.get('declarationtype', '')
        ddm_key = rule.ddm_info.get('ddm_key', '')
        ddm_value = rule.ddm_info.get('ddm_value', {})
        
        if not declaration_type or not ddm_key:
            logger.warning(f"Invalid DDM info for rule {rule.id}")
            return None
        
        # Convert declaration type to root setting ID
        # e.g., com.apple.configuration.passcode.settings -> passcode_passcode
        type_parts = declaration_type.split('.')
        if len(type_parts) >= 4 and type_parts[0] == 'com' and type_parts[1] == 'apple' and type_parts[2] == 'configuration':
            root_key = type_parts[3]  # e.g., "passcode"
            root_id = f"{root_key}_{root_key}"
        else:
            logger.warning(f"Unrecognized DDM declaration type: {declaration_type}")
            return None
        
        # Find the root group definition
        root_def = self.settings_catalog._settings_index.get(root_id)
        if not root_def:
            logger.warning(f"Could not find root DDM setting: {root_id}")
            return None
        
        # Convert ddm_key to setting ID (e.g., CustomRegex -> customregex)
        child_key = ddm_key.lower()
        child_id = f"{root_key}_{child_key}"
        
        # Find the child group definition
        child_def = self.settings_catalog._settings_index.get(child_id)
        if not child_def:
            logger.warning(f"Could not find DDM child setting: {child_id}")
            return None
        
        # Normalize ddm_value for processing
        if isinstance(ddm_value, dict):
            # Convert Description string to dict format if needed
            normalized_value = {}
            for k, v in ddm_value.items():
                if k.lower() == 'description' and isinstance(v, str):
                    # Convert string description to dict format: {"default": "description"}
                    normalized_value[k] = {"default": v}
                else:
                    normalized_value[k] = v
            
            child_instance = self._create_child_setting_instance(child_def, normalized_value)
            if not child_instance:
                logger.warning(f"Could not create child instance for {child_id}")
                return None
            
            # Ensure all required children are present
            children = self._ensure_required_children(root_id, [child_instance])
            
            # Wrap in root group
            root_instance = {
                '@odata.type': '#microsoft.graph.deviceManagementConfigurationGroupSettingCollectionInstance',
                'settingDefinitionId': root_id,
                'groupSettingCollectionValue': [{
                    '@odata.type': '#microsoft.graph.deviceManagementConfigurationGroupSettingValue',
                    'children': children
                }]
            }
            
            policy_setting = PolicySetting(
                setting_definition_id=root_id,
                setting_instance=root_instance,
                name=root_def.get('name'),
                description=root_def.get('description')
            )
            settings.append(policy_setting)
        else:
            # Simple value (not a dict) - create as a direct child of root
            child_instance = self._create_simple_ddm_instance(child_def, ddm_value)
            if child_instance:
                # Ensure all required children are present
                children = self._ensure_required_children(root_id, [child_instance])
                
                root_instance = {
                    '@odata.type': '#microsoft.graph.deviceManagementConfigurationGroupSettingCollectionInstance',
                    'settingDefinitionId': root_id,
                    'groupSettingCollectionValue': [{
                        '@odata.type': '#microsoft.graph.deviceManagementConfigurationGroupSettingValue',
                        'children': children
                    }]
                }
                
                policy_setting = PolicySetting(
                    setting_definition_id=root_id,
                    setting_instance=root_instance,
                    name=root_def.get('name'),
                    description=root_def.get('description')
                )
                settings.append(policy_setting)
            else:
                logger.warning(f"Could not create simple DDM instance for {child_id}")
                return None
        
        if not settings:
            return None
        
        policy = Policy(
            name=rule.title,
            description=rule.discussion[:100] if rule.discussion else rule.title,
            settings=settings,
            policy_type=PolicyType.DDM,
            source_rule_id=rule.id,
            section=rule.get_section()
        )
        
        return policy
    
    def _map_to_settings_catalog(self, rule: Rule) -> Optional[Policy]:
        """Map a rule's mobileconfig to Settings Catalog.
        
        Args:
            rule: Rule with mobileconfig_info
            
        Returns:
            Policy object or None
        """
        settings = []
        
        # Process mobileconfig_info
        # Structure: domain -> settings dict
        # Example: com.apple.security.firewall: {EnableFirewall: true, EnableStealthMode: true}
        
        for domain, domain_settings in rule.mobileconfig_info.items():
            if isinstance(domain_settings, dict) and domain_settings:
                # Check if we need to handle this as a nested wrapper structure
                # (e.g., com.apple.ManagedClient.preferences -> actual domain -> settings)
                first_value = next(iter(domain_settings.values()))
                
                if isinstance(first_value, dict):
                    # This is a wrapper structure: wrapper -> domain -> settings
                    for sub_domain, sub_settings in domain_settings.items():
                        if isinstance(sub_settings, dict):
                            # Process the actual domain settings
                            group_setting = self._create_group_setting(sub_domain, sub_settings)
                            if group_setting:
                                settings.append(group_setting)
                        else:
                            # Single setting under wrapper
                            setting_def = self.settings_catalog.find_setting_by_payload(
                                domain, sub_domain, self.prefer_ddm
                            )
                            if setting_def:
                                policy_setting = self._create_setting_instance(
                                    setting_def, sub_domain, sub_settings
                                )
                                if policy_setting:
                                    settings.append(policy_setting)
                else:
                    # Direct domain -> settings structure
                    group_setting = self._create_group_setting(domain, domain_settings)
                    if group_setting:
                        settings.append(group_setting)
            else:
                # Single value at top level
                setting_def = self.settings_catalog.find_setting_by_payload("", domain, self.prefer_ddm)
                if setting_def:
                    policy_setting = self._create_setting_instance(setting_def, domain, domain_settings)
                    if policy_setting:
                        settings.append(policy_setting)
        
        if not settings:
            return None
        
        # Create Policy object
        policy = Policy(
            name=rule.title,
            description=rule.discussion[:100] if rule.discussion else rule.title,
            settings=settings,
            policy_type=PolicyType.MOBILECONFIG,
            source_rule_id=rule.id,
            section=rule.get_section()
        )
        
        return policy
    
    def _create_group_setting(
        self,
        domain: str,
        settings_dict: Dict[str, Any]
    ) -> Optional[PolicySetting]:
        """Create a group setting with multiple child settings.
        
        Args:
            domain: The domain/payload type (e.g., com.apple.security.firewall)
            settings_dict: Dictionary of setting key-value pairs
            
        Returns:
            PolicySetting for the group or None
        """
        # Find the parent group setting definition
        # The group ID is typically: domain + "_" + domain (e.g., com.apple.security.firewall_com.apple.security.firewall)
        group_id = f"{domain}_{domain}".lower().replace(".", "")
        
        # Try to find the group definition in the catalog
        group_def = None
        for setting in self.settings_catalog._settings_index.values():
            if (setting.get('id', '').lower() == group_id or
                setting.get('offsetUri') == domain and 
                'SettingGroupCollection' in setting.get('@odata.type', '')):
                group_def = setting
                break
        
        if not group_def:
            # No group found - try to create individual settings
            logger.debug(f"No group definition found for {domain}, creating individual settings")
            return None
        
        # Create child setting instances
        children = []
        for setting_key, setting_value in settings_dict.items():
            setting_def = self.settings_catalog.find_setting_by_payload(domain, setting_key, self.prefer_ddm)
            
            if setting_def:
                child_instance = self._create_child_setting_instance(setting_def, setting_value)
                if child_instance:
                    children.append(child_instance)
        
        if not children:
            logger.warning(f"No children could be created for group {domain}")
            return None
        
        # Ensure all required children are present
        group_id = group_def.get('id')
        children = self._ensure_required_children(group_id, children)
        
        # Create the group setting instance
        group_instance = {
            '@odata.type': '#microsoft.graph.deviceManagementConfigurationGroupSettingCollectionInstance',
            'settingDefinitionId': group_id,
            'groupSettingCollectionValue': [
                {
                    '@odata.type': '#microsoft.graph.deviceManagementConfigurationGroupSettingValue',
                    'children': children
                }
            ]
        }
        
        return PolicySetting(
            setting_definition_id=group_id,
            setting_instance=group_instance,
            name=group_def.get('name'),
            description=group_def.get('description')
        )
    
    def _create_child_setting_instance(
        self,
        setting_def: Dict[str, Any],
        setting_value: Any
    ) -> Optional[Dict[str, Any]]:
        """Create a child setting instance (for use within a group).
        
        Args:
            setting_def: Setting definition from catalog
            setting_value: Desired value
            
        Returns:
            Setting instance dictionary or None
        """
        setting_id = setting_def.get('id')
        if not setting_id:
            return None
        
        odata_type = setting_def.get('@odata.type', '')
        
        # Check if this is a GROUP collection
        if 'SettingGroupCollection' in odata_type:
            # Check if this is a dictionary-style group (has generickey children)
            child_ids = setting_def.get('childIds', [])
            is_dictionary_style = any('_generickey' in cid for cid in child_ids)
            
            if isinstance(setting_value, dict):
                if is_dictionary_style:
                    # Dictionary-style: {"default": "value"} -> creates key-value pair children
                    return self._create_dictionary_group_instance(setting_def, setting_value)
                else:
                    # Regular group: {"Regex": "value", "Description": {...}} -> creates child for each key
                    return self._create_regular_group_instance(setting_def, setting_value)
            else:
                logger.warning(f"Group collection {setting_id} requires dict value, got {type(setting_value)}")
                return None
        
        # Extract primitive value if nested in dict
        actual_value = self._extract_primitive_value(setting_value)
        
        if 'Choice' in odata_type:
            # Choice setting
            options = setting_def.get('options', [])
            selected_option = None
            
            for option in options:
                option_value = option.get('optionValue', {}).get('value')
                if str(option_value).lower() == str(actual_value).lower():
                    selected_option = option
                    break
            
            if not selected_option:
                logger.warning(f"Value {actual_value} doesn't match any option for {setting_id}")
                return None
            
            return {
                '@odata.type': '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance',
                'settingDefinitionId': setting_id,
                'choiceSettingValue': {
                    '@odata.type': '#microsoft.graph.deviceManagementConfigurationChoiceSettingValue',
                    'value': selected_option.get('itemId'),
                    'children': []
                }
            }
        else:
            # Simple setting - use Settings Catalog definition to determine type
            value_def = setting_def.get('valueDefinition', {})
            value_type = value_def.get('@odata.type', '')
            
            # Convert value to correct type based on Settings Catalog definition
            if 'String' in value_type:
                # Settings Catalog expects string - convert value to string
                converted_value = str(actual_value)
                odata_type = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
            elif 'Integer' in value_type:
                # Settings Catalog expects integer
                converted_value = int(actual_value) if not isinstance(actual_value, bool) else (1 if actual_value else 0)
                odata_type = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
            elif 'Boolean' in value_type:
                # Settings Catalog expects boolean
                converted_value = bool(actual_value)
                odata_type = '#microsoft.graph.deviceManagementConfigurationBooleanSettingValue'
            else:
                # Fallback to string
                converted_value = str(actual_value)
                odata_type = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
            
            return {
                '@odata.type': '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance',
                'settingDefinitionId': setting_id,
                'simpleSettingValue': {
                    '@odata.type': odata_type,
                    'value': converted_value
                }
            }
    
    def _create_regular_group_instance(
        self,
        group_def: Dict[str, Any],
        settings_dict: Dict[str, Any]
    ) -> Optional[Dict[str, Any]]:
        """Create a regular group instance where dict keys correspond to child settings.
        
        Example: CustomRegex group with {"Regex": "...", "Description": {...}}
        
        Args:
            group_def: Group setting definition
            settings_dict: Dictionary with settings (key = child name, value = child value)
            
        Returns:
            Group setting instance or None
        """
        group_id = group_def.get('id')
        child_ids = group_def.get('childIds', [])
        
        if not child_ids:
            logger.warning(f"Group {group_id} has no children defined")
            return None
        
        # Create child instances
        children = []
        for setting_key, setting_value in settings_dict.items():
            # Find matching child definition
            # Convert setting_key (e.g., "Regex") to lowercase for matching
            key_lower = setting_key.lower()
            
            # Find child ID that matches this key
            child_id = None
            for cid in child_ids:
                # Check if child ID ends with the key (e.g., passcode_customregex_regex)
                if cid.lower().endswith('_' + key_lower):
                    child_id = cid
                    break
            
            if not child_id:
                logger.warning(f"Could not find child definition for key '{setting_key}' in group {group_id}")
                continue
            
            # Get child definition
            child_def = self.settings_catalog._settings_index.get(child_id)
            if not child_def:
                logger.warning(f"Could not load child definition: {child_id}")
                continue
            
            # Create child instance recursively
            child_instance = self._create_child_setting_instance(child_def, setting_value)
            if child_instance:
                children.append(child_instance)
        
        if not children:
            logger.warning(f"No children could be created for group {group_id}")
            return None
        
        # Ensure all required children are present
        children = self._ensure_required_children(group_id, children)
        
        return {
            '@odata.type': '#microsoft.graph.deviceManagementConfigurationGroupSettingCollectionInstance',
            'settingDefinitionId': group_id,
            'groupSettingCollectionValue': [{
                '@odata.type': '#microsoft.graph.deviceManagementConfigurationGroupSettingValue',
                'children': children
            }]
        }
    
    
    def _create_dictionary_group_instance(
        self,
        group_def: Dict[str, Any],
        dict_value: Dict[str, str]
    ) -> Optional[Dict[str, Any]]:
        """Create a group instance for dictionary-style settings (e.g., passwordContentDescription).
        
        These settings represent key-value dictionaries where each entry needs TWO child settings:
        - One for the key (e.g., "default", "en-US")
        - One for the value (the actual description/content)
        
        Args:
            group_def: Group setting definition
            dict_value: Dictionary with key-value pairs (e.g., {"default": "Password must..."})
            
        Returns:
            Group setting instance or None
        """
        group_id = group_def.get('id')
        child_ids = group_def.get('childIds', [])
        
        if len(child_ids) < 2:
            logger.warning(f"Dictionary group {group_id} should have at least 2 children for key-value pairs")
            return None
        
        # Find the child definitions for the key and value
        # Typically: <parent>_generickey and <parent>_generickey_keytobereplaced
        key_def_id = None
        value_def_id = None
        
        for child_id in child_ids:
            if child_id.endswith('_generickey') and not child_id.endswith('_keytobereplaced'):
                key_def_id = child_id
            elif child_id.endswith('_keytobereplaced'):
                value_def_id = child_id
        
        if not key_def_id or not value_def_id:
            logger.warning(f"Could not find key/value child definitions for {group_id}")
            return None
        
        # Get the actual setting definitions
        key_def = self.settings_catalog._settings_index.get(key_def_id)
        value_def = self.settings_catalog._settings_index.get(value_def_id)
        
        if not key_def or not value_def:
            logger.warning(f"Could not load child definitions for {group_id}")
            return None
        
        # Create instances for each key-value pair in the dictionary
        # For now, we'll create just the first entry
        dict_entries = []
        for key, value in dict_value.items():
            children = [
                {
                    '@odata.type': '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance',
                    'settingDefinitionId': key_def_id,
                    'simpleSettingValue': {
                        '@odata.type': '#microsoft.graph.deviceManagementConfigurationStringSettingValue',
                        'value': key
                    }
                },
                {
                    '@odata.type': '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance',
                    'settingDefinitionId': value_def_id,
                    'simpleSettingValue': {
                        '@odata.type': '#microsoft.graph.deviceManagementConfigurationStringSettingValue',
                        'value': value
                    }
                }
            ]
            dict_entries.append({
                '@odata.type': '#microsoft.graph.deviceManagementConfigurationGroupSettingValue',
                'children': children
            })
        
        return {
            '@odata.type': '#microsoft.graph.deviceManagementConfigurationGroupSettingCollectionInstance',
            'settingDefinitionId': group_id,
            'groupSettingCollectionValue': dict_entries
        }
    
    def _create_simple_ddm_instance(
        self,
        setting_def: Dict[str, Any],
        setting_value: Any
    ) -> Optional[Dict[str, Any]]:
        """Create a simple setting instance for DDM values that are not dicts.
        
        Args:
            setting_def: Setting definition
            setting_value: Simple value (string, int, bool)
            
        Returns:
            Setting instance or None
        """
        setting_id = setting_def.get('id')
        if not setting_id:
            return None
        
        odata_type = setting_def.get('@odata.type', '')
        
        # Extract primitive value if nested
        actual_value = self._extract_primitive_value(setting_value)
        
        if 'Choice' in odata_type:
            # Choice setting
            options = setting_def.get('options', [])
            selected_option = None
            
            for option in options:
                option_value = option.get('optionValue', {}).get('value')
                if str(option_value).lower() == str(actual_value).lower():
                    selected_option = option
                    break
            
            if not selected_option:
                logger.warning(f"Value {actual_value} doesn't match any option for {setting_id}")
                return None
            
            return {
                '@odata.type': '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance',
                'settingDefinitionId': setting_id,
                'choiceSettingValue': {
                    '@odata.type': '#microsoft.graph.deviceManagementConfigurationChoiceSettingValue',
                    'value': selected_option.get('itemId'),
                    'children': []
                }
            }
        else:
            # Simple setting - use Settings Catalog definition to determine type
            value_def = setting_def.get('valueDefinition', {})
            value_type = value_def.get('@odata.type', '')
            
            # Convert value to correct type based on Settings Catalog definition
            if 'String' in value_type:
                converted_value = str(actual_value)
                odata_type = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
            elif 'Integer' in value_type:
                converted_value = int(actual_value) if not isinstance(actual_value, bool) else (1 if actual_value else 0)
                odata_type = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
            elif 'Boolean' in value_type:
                converted_value = bool(actual_value)
                odata_type = '#microsoft.graph.deviceManagementConfigurationBooleanSettingValue'
            else:
                # Fallback to string
                converted_value = str(actual_value)
                odata_type = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
            
            return {
                '@odata.type': '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance',
                'settingDefinitionId': setting_id,
                'simpleSettingValue': {
                    '@odata.type': odata_type,
                    'value': converted_value
                }
            }
    
    
    def _create_setting_instance(
        self,
        setting_def: Dict[str, Any],
        setting_key: str,
        setting_value: Any
    ) -> Optional[PolicySetting]:
        """Create a PolicySetting from a setting definition.
        
        Args:
            setting_def: Setting definition from catalog
            setting_key: Setting key
            setting_value: Desired value
            
        Returns:
            PolicySetting or None
        """
        setting_id = setting_def.get('id')
        if not setting_id:
            return None
        
        # Extract primitive value if setting_value is a dict/object
        # (e.g., {"default": "value"} -> "value")
        actual_value = self._extract_primitive_value(setting_value)
        
        # Determine the setting instance structure based on type
        odata_type = setting_def.get('@odata.type', '')
        
        if 'Choice' in odata_type:
            # Choice setting - need to find matching option
            options = setting_def.get('options', [])
            
            # Find option that matches the value
            selected_option = None
            for option in options:
                option_value = option.get('optionValue', {}).get('value')
                if str(option_value).lower() == str(actual_value).lower():
                    selected_option = option
                    break
            
            if selected_option:
                setting_instance = {
                    '@odata.type': '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance',
                    'settingDefinitionId': setting_id,
                    'choiceSettingValue': {
                        '@odata.type': '#microsoft.graph.deviceManagementConfigurationChoiceSettingValue',
                        'value': selected_option.get('itemId'),
                        'children': []
                    }
                }
            else:
                # Value doesn't match any option
                logger.warning(f"Value {actual_value} doesn't match any option for {setting_id}")
                return None
        else:
            # Simple setting - use Settings Catalog definition to determine type
            value_def = setting_def.get('valueDefinition', {})
            value_type = value_def.get('@odata.type', '')
            
            # Convert value to correct type based on Settings Catalog definition
            if 'String' in value_type:
                converted_value = str(actual_value)
                odata_type = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
            elif 'Integer' in value_type:
                converted_value = int(actual_value) if not isinstance(actual_value, bool) else (1 if actual_value else 0)
                odata_type = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
            elif 'Boolean' in value_type:
                converted_value = bool(actual_value)
                odata_type = '#microsoft.graph.deviceManagementConfigurationBooleanSettingValue'
            else:
                # Fallback to string
                converted_value = str(actual_value)
                odata_type = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
            
            setting_instance = {
                '@odata.type': '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance',
                'settingDefinitionId': setting_id,
                'simpleSettingValue': {
                    '@odata.type': odata_type,
                    'value': converted_value
                }
            }
        
        return PolicySetting(
            setting_definition_id=setting_id,
            setting_instance=setting_instance,
            name=setting_def.get('name'),
            description=setting_def.get('description')
        )
    
    def _extract_primitive_value(self, value: Any) -> Any:
        """Extract primitive value from potentially nested dict/object.
        
        Args:
            value: The value (may be primitive or dict)
            
        Returns:
            Primitive value (string, int, bool, etc.)
        """
        # If it's a dict, try to extract the actual value
        if isinstance(value, dict):
            # Common patterns: {"default": "value"}, {"value": "..."}, etc.
            if 'default' in value:
                return value['default']
            elif 'value' in value:
                return value['value']
            elif len(value) == 1:
                # Single key dict, return the value
                return list(value.values())[0]
            else:
                # Return the dict as-is (will likely fail, but that's the best we can do)
                logger.warning(f"Could not extract primitive value from dict: {value}")
                return value
        
        # Already a primitive value
        return value
    
    def _get_value_odata_type(self, value: Any) -> str:
        """Get the @odata.type for a value.
        
        Args:
            value: The value
            
        Returns:
            OData type string
        """
        if isinstance(value, bool):
            return '#microsoft.graph.deviceManagementConfigurationBooleanSettingValue'
        elif isinstance(value, int):
            return '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
        elif isinstance(value, str):
            return '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
        else:
            # Default to string
            return '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
