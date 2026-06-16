"""Baseline data model."""

from dataclasses import dataclass, field
from typing import List, Dict, Any, Optional


@dataclass
class BaselineSection:
    """Represents a section within a baseline."""
    section: str
    rules: List[str] = field(default_factory=list)


@dataclass
class Baseline:
    """Represents a macOS security baseline."""
    
    name: str
    title: str
    description: str
    authors: str
    parent_values: Optional[str] = None
    profile: List[BaselineSection] = field(default_factory=list)
    odv: Dict[str, Any] = field(default_factory=dict)  # Organization-Defined Values
    
    @classmethod
    def from_dict(cls, name: str, data: Dict[str, Any]) -> "Baseline":
        """Create Baseline from dictionary loaded from YAML.
        
        Args:
            name: Baseline identifier (filename without extension)
            data: Dictionary from YAML file
            
        Returns:
            Baseline instance
        """
        sections = []
        for section_data in data.get("profile", []):
            sections.append(
                BaselineSection(
                    section=section_data.get("section", ""),
                    rules=section_data.get("rules", [])
                )
            )
        
        return cls(
            name=name,
            title=data.get("title", ""),
            description=data.get("description", ""),
            authors=data.get("authors", ""),
            parent_values=data.get("parent_values"),
            profile=sections,
            odv=data.get("odv", {})
        )
    
    def get_all_rules(self) -> List[str]:
        """Get all rule IDs from all sections.
        
        Returns:
            List of rule IDs
        """
        rules = []
        for section in self.profile:
            rules.extend(section.rules)
        return rules
