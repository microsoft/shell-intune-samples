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
        
        return cls(
            id=data.get("id", ""),
            title=data.get("title", ""),
            discussion=data.get("discussion", ""),
            check=data.get("check", ""),
            result=data.get("result", {}),
            fix=data.get("fix", ""),
            references=data.get("references", {}),
            macos_versions=data.get("macOS", []),
            tags=data.get("tags", []),
            severity=severity,
            mobileconfig=data.get("mobileconfig", False),
            mobileconfig_info=data.get("mobileconfig_info", {}),
            ddm_info=data.get("ddm_info", {}),
            odv=data.get("odv")
        )
    
    @property
    def has_mobileconfig(self) -> bool:
        """Check if rule has mobileconfig information."""
        return self.mobileconfig and bool(self.mobileconfig_info)
    
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
