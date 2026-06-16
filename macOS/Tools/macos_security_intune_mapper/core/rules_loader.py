"""Rules loader for macOS security rules."""

import logging
import yaml
from pathlib import Path
from typing import Dict, List, Optional

from ..models.rule import Rule

logger = logging.getLogger(__name__)


class RulesLoader:
    """Loads macOS security rules from YAML files."""
    
    def __init__(self, macos_security_path: Optional[str] = None):
        """Initialize the rules loader.
        
        Args:
            macos_security_path: Path to macos_security folder. If None, uses default.
        """
        if macos_security_path:
            self.rules_path = Path(macos_security_path) / "rules"
        else:
            # Try to find macos_security folder
            current = Path(__file__).parent
            while current.parent != current:
                macos_security = current / "macos_security"
                if macos_security.exists() and (macos_security / "rules").exists():
                    self.rules_path = macos_security / "rules"
                    break
                current = current.parent
            else:
                # Default to relative path
                self.rules_path = Path("macos_security/rules")
        
        self._rules_cache: Dict[str, Rule] = {}
        logger.info(f"Rules loader initialized with path: {self.rules_path}")
    
    def load_rule(self, rule_id: str) -> Optional[Rule]:
        """Load a single rule from YAML file.
        
        Args:
            rule_id: Rule identifier (e.g., 'audit_acls_files_configure')
            
        Returns:
            Rule object or None if not found
        """
        # Check cache first
        if rule_id in self._rules_cache:
            return self._rules_cache[rule_id]
        
        # Find the rule file
        rule_file = self._find_rule_file(rule_id)
        if not rule_file:
            logger.warning(f"Rule file not found for: {rule_id}")
            return None
        
        try:
            with open(rule_file, 'r', encoding='utf-8') as f:
                rule_data = yaml.safe_load(f)
            
            # Create Rule object
            rule = Rule.from_dict(rule_data)
            
            # Cache it
            self._rules_cache[rule_id] = rule
            
            return rule
            
        except yaml.YAMLError as e:
            logger.error(f"Invalid YAML in rule file {rule_file}: {e}")
            return None
        except Exception as e:
            logger.error(f"Failed to load rule {rule_id}: {e}")
            return None
    
    def load_rules_bulk(self, rule_ids: List[str]) -> Dict[str, Rule]:
        """Load multiple rules at once.
        
        Args:
            rule_ids: List of rule identifiers
            
        Returns:
            Dictionary mapping rule IDs to Rule objects (excludes not found)
        """
        rules = {}
        
        for rule_id in rule_ids:
            rule = self.load_rule(rule_id)
            if rule:
                rules[rule_id] = rule
        
        logger.info(f"Loaded {len(rules)}/{len(rule_ids)} rules")
        
        return rules
    
    def _find_rule_file(self, rule_id: str) -> Optional[Path]:
        """Find the YAML file for a rule.
        
        Args:
            rule_id: Rule identifier
            
        Returns:
            Path to rule file or None if not found
        """
        # Infer section from rule ID prefix
        section = self._infer_section(rule_id)
        
        if section:
            # Try section-specific path first
            section_path = self.rules_path / section / f"{rule_id}.yaml"
            if section_path.exists():
                return section_path
        
        # Search all subdirectories
        for rule_file in self.rules_path.rglob(f"{rule_id}.yaml"):
            return rule_file
        
        return None
    
    def _infer_section(self, rule_id: str) -> Optional[str]:
        """Infer the section from rule ID prefix.
        
        Args:
            rule_id: Rule identifier
            
        Returns:
            Section name or None
        """
        # Common prefixes
        if rule_id.startswith("audit_"):
            return "audit"
        elif rule_id.startswith("auth_"):
            return "auth"
        elif rule_id.startswith("icloud_"):
            return "icloud"
        elif rule_id.startswith("os_"):
            return "os"
        elif rule_id.startswith("pwpolicy_"):
            return "pwpolicy"
        elif rule_id.startswith("system_settings_"):
            return "system_settings"
        elif rule_id.startswith("supplemental_"):
            return "supplemental"
        
        return None
