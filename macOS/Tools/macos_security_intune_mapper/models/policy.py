"""Policy data model for Intune Settings Catalog."""

from dataclasses import dataclass, field
from typing import Dict, Any, List, Optional
from enum import Enum
import json


class PolicyType(Enum):
    """Type of policy implementation."""
    DDM = "ddm"  # Declarative Device Management
    MOBILECONFIG = "mobileconfig"  # Configuration Profile
    CUSTOM = "custom"  # Custom mobileconfig


@dataclass
class PolicySetting:
    """Individual setting within a policy."""
    
    setting_definition_id: str
    setting_instance: Dict[str, Any]
    
    # Metadata
    name: Optional[str] = None
    description: Optional[str] = None


@dataclass
class Policy:
    """Represents an Intune policy or setting."""
    
    name: str
    description: str = ""
    
    # Settings
    settings: List[PolicySetting] = field(default_factory=list)
    
    # Type and source tracking
    policy_type: PolicyType = PolicyType.DDM
    source_rule_id: Optional[str] = None
    section: Optional[str] = None
    
    # Intune-specific fields
    platforms: str = "macOS"
    technologies: str = "mdm"
    template_reference: Optional[Dict[str, str]] = None
    
    # Inclusion tracking (for GUI)
    included: bool = True
    modified: bool = False
    
    def to_intune_json(self) -> str:
        """Convert policy to Intune JSON format.
        
        Returns:
            JSON string representation
        """
        policy_dict = {
            "name": self.name,
            "description": self.description,
            "platforms": self.platforms,
            "technologies": self.technologies,
            "settings": []
        }
        
        # Add each setting
        for setting in self.settings:
            setting_dict = {
                "@odata.type": "#microsoft.graph.deviceManagementConfigurationSetting",
                "settingInstance": setting.setting_instance
            }
            policy_dict["settings"].append(setting_dict)
        
        if self.template_reference:
            policy_dict["templateReference"] = self.template_reference
        
        return json.dumps(policy_dict, indent=2)


@dataclass
class MobileConfigPolicy:
    """Represents a mobileconfig-based policy."""
    
    name: str
    description: str
    payload_content: Dict[str, Any]
    source_rule_id: Optional[str] = None
    
    def to_mobileconfig_xml(self) -> str:
        """Convert to mobileconfig XML format.
        
        Returns:
            XML plist string
        """
        import plistlib
        
        # Create top-level mobileconfig structure
        mobileconfig = {
            "PayloadContent": [self.payload_content],
            "PayloadDescription": self.description,
            "PayloadDisplayName": self.name,
            "PayloadIdentifier": f"com.apple.security.{self.source_rule_id or 'custom'}",
            "PayloadType": "Configuration",
            "PayloadUUID": self._generate_uuid(),
            "PayloadVersion": 1
        }
        
        return plistlib.dumps(mobileconfig, fmt=plistlib.FMT_XML).decode('utf-8')
    
    def _generate_uuid(self) -> str:
        """Generate a UUID for the payload."""
        import uuid
        return str(uuid.uuid4()).upper()
