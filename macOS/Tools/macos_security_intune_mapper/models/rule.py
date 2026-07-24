# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
"""Rule data model."""

from dataclasses import dataclass, field
from typing import Dict, Any, List, Optional, Union
from enum import Enum


class Severity(Enum):
    """Security severity levels."""
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"


@dataclass
class Rule:
    """Represents a macOS security rule."""
    
    id: str
    title: str
    discussion: str
    check: str
    result: Dict[str, Any]
    fix: str
    references: Dict[str, Any]
    macos_versions: List[str] = field(default_factory=list)
    tags: List[str] = field(default_factory=list)
    severity: Severity = Severity.MEDIUM
    
    # Configuration profile fields
    mobileconfig: bool = False
    mobileconfig_info: Dict[str, Any] = field(default_factory=dict)
    ddm_info: Dict[str, Any] = field(default_factory=dict)  # DDM (Declarative Device Management) info
    
    # Additional fields
    odv: Optional[Union[str, Dict[str, Any]]] = None  # Organization-Defined Value reference or dict
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> "Rule":
        """Create Rule from dictionary loaded from YAML.
        
        Args:
            data: Dictionary from YAML file
            
        Returns:
            Rule instance
        """
        # Parse severity
        severity_str = data.get("severity", "medium").lower()
        try:
            severity = Severity(severity_str)
        except ValueError:
            severity = Severity.MEDIUM
        
        # Normalize mobileconfig_info from new format to old format
        mobileconfig_info = cls._normalize_mobileconfig_info(data.get("mobileconfig_info", {}))
        
        # Extract check, result, fix from new structure if not at top level
        check = data.get("check", "")
        result = data.get("result", {})
        fix = data.get("fix", "")
        
        # If not found at top level, try to extract from platforms section
        if not check and "platforms" in data:
            platforms = data["platforms"]
            if "macOS" in platforms:
                macos_platforms = platforms["macOS"]
                # Get enforcement_info from the first macOS version or from common enforcement_info
                enforcement_info = macos_platforms.get("enforcement_info")
                if not enforcement_info:
                    # Try first version
                    for version_key, version_data in macos_platforms.items():
                        if isinstance(version_data, dict) and "enforcement_info" in version_data:
                            enforcement_info = version_data["enforcement_info"]
                            break
                
                if enforcement_info:
                    check_info = enforcement_info.get("check", {})
                    if isinstance(check_info, dict):
                        check = check_info.get("shell", "")
                        result = check_info.get("result", {})
                    fix = enforcement_info.get("fix", {}).get("shell", "") if isinstance(enforcement_info.get("fix"), dict) else ""
        
        return cls(
            id=data.get("id", ""),
            title=data.get("title", ""),
            discussion=data.get("discussion", ""),
            check=check,
            result=result,
            fix=fix,
            references=data.get("references", {}),
            macos_versions=data.get("macOS", []),
            tags=data.get("tags", []),
            severity=severity,
            mobileconfig=data.get("mobileconfig", False),
            mobileconfig_info=mobileconfig_info,
            ddm_info=data.get("ddm_info", {}),
            odv=data.get("odv")
        )
    
    @staticmethod
    def _normalize_mobileconfig_info(mobileconfig_info: Union[Dict, List]) -> Dict[str, Any]:
        """Normalize mobileconfig_info from new format to old format.
        
        New format (list):
            - PayloadType: com.apple.security.firewall
              PayloadContent:
                - EnableFirewall: true
                - EnableStealthMode: true
        
        Old format (dict):
            com.apple.security.firewall:
                EnableFirewall: true
                EnableStealthMode: true
        
        Args:
            mobileconfig_info: Either list (new format) or dict (old format)
            
        Returns:
            Normalized dict in old format
        """
        if not mobileconfig_info:
            return {}
        
        # If already a dict, return as-is (old format or already normalized)
        if isinstance(mobileconfig_info, dict):
            return mobileconfig_info
        
        # If it's a list, convert from new format to old format
        if isinstance(mobileconfig_info, list):
            normalized = {}
            for payload in mobileconfig_info:
                if not isinstance(payload, dict):
                    continue
                
                payload_type = payload.get('PayloadType')
                payload_content = payload.get('PayloadContent', [])
                
                if not payload_type:
                    continue
                
                # Convert PayloadContent list to dict
                settings = {}
                if isinstance(payload_content, list):
                    for item in payload_content:
                        if isinstance(item, dict):
                            settings.update(item)
                elif isinstance(payload_content, dict):
                    settings = payload_content
                
                if settings:
                    normalized[payload_type] = settings
            
            return normalized
        
        return {}
    
    @property
    def has_mobileconfig(self) -> bool:
        """Check if rule has mobileconfig information."""
        # In new format, mobileconfig flag may not exist, so check mobileconfig_info directly
        return bool(self.mobileconfig_info) or (self.mobileconfig and bool(self.mobileconfig_info))
    
    @property
    def has_ddm(self) -> bool:
        """Check if rule has DDM (Declarative Device Management) information."""
        return bool(self.ddm_info)
    
    def get_section(self) -> str:
        """Get the section this rule belongs to based on ID prefix.
        
        Returns:
            Section name
        """
        if self.id.startswith("audit_"):
            return "auditing"
        elif self.id.startswith("auth_"):
            return "authentication"
        elif self.id.startswith("icloud_"):
            return "icloud"
        elif self.id.startswith("os_"):
            return "macos"
        elif self.id.startswith("pwpolicy_"):
            return "passwordpolicy"
        elif self.id.startswith("system_settings_"):
            return "systemsettings"
        elif self.id.startswith("supplemental_"):
            return "supplemental"
        else:
            return "other"
