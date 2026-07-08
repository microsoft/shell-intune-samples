# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
"""Baseline loader for macOS security baselines."""

import logging
import yaml
from pathlib import Path
from typing import List, Optional, Dict, Any

from models.baseline import Baseline, BaselineSection

logger = logging.getLogger(__name__)


# Section name mapping: old format -> new format
# The new baseline structure (macos_security 2.0+) uses different section names
SECTION_NAME_MAPPING = {
    "auditing": "Auditing",
    "macos": "Operating System",
    "passwordpolicy": "Password Policy",
    "systemsettings": "System Settings",
    "Supplemental": "Supplemental",  # Unchanged
    # Add reverse mappings for normalization
    "Auditing": "Auditing",
    "Operating System": "Operating System",
    "Password Policy": "Password Policy",
    "System Settings": "System Settings",
}


class BaselineLoader:
    """Loads macOS security baselines from YAML files."""
    
    def __init__(self, macos_security_path: Optional[str] = None):
        """Initialize the baseline loader.
        
        Args:
            macos_security_path: Path to macos_security folder. If None, uses default.
        """
        if macos_security_path:
            baselines_root = Path(macos_security_path) / "baselines"
            # Check for new structure with macos/ subdirectory
            macos_baselines = baselines_root / "macos"
            if macos_baselines.exists():
                self.baselines_path = macos_baselines
            else:
                # Fall back to old structure (baselines/ directly)
                self.baselines_path = baselines_root
        else:
            # Try to find macos_security folder
            current = Path(__file__).parent
            while current.parent != current:
                macos_security = current / "macos_security"
                if macos_security.exists() and (macos_security / "baselines").exists():
                    baselines_root = macos_security / "baselines"
                    # Check for new structure
                    macos_baselines = baselines_root / "macos"
                    if macos_baselines.exists():
                        self.baselines_path = macos_baselines
                    else:
                        self.baselines_path = baselines_root
                    break
                current = current.parent
            else:
                # Default to relative path (try new structure first)
                self.baselines_path = Path("macos_security/baselines/macos")
        
        self._baselines_cache: Dict[str, Baseline] = {}
        logger.info(f"Baseline loader initialized with path: {self.baselines_path}")
    
    def list_baselines(self) -> List[str]:
        """List all available baselines.
        
        Returns:
            List of baseline names (without .yaml extension and version suffix)
        """
        if not self.baselines_path.exists():
            logger.warning(f"Baselines path does not exist: {self.baselines_path}")
            return []
        
        baselines = []
        for baseline_file in self.baselines_path.glob("*.yaml"):
            if baseline_file.name != "all_rules.yaml" and not baseline_file.name.startswith("all_rules_"):
                # Strip .yaml extension
                basename = baseline_file.stem
                
                # For new structure, strip version suffix (e.g., _macos_26.0)
                # Pattern: basename_platform_version (e.g., cis_lvl1_macos_26.0)
                if "_macos_" in basename or "_ios_" in basename or "_visionos_" in basename:
                    # Find the last occurrence of platform suffix and remove it
                    parts = basename.rsplit("_", 2)  # Split from right: ['cis_lvl1', 'macos', '26.0']
                    if len(parts) == 3 and parts[1] in ["macos", "ios", "visionos"]:
                        basename = parts[0]  # Use the baseline name without platform/version
                
                if basename not in baselines:
                    baselines.append(basename)
        
        return sorted(baselines)
    
    def load_baseline(self, baseline_name: str) -> Baseline:
        """Load a baseline from YAML file.
        
        Args:
            baseline_name: Name of the baseline (without .yaml extension and version suffix)
            
        Returns:
            Baseline object
            
        Raises:
            FileNotFoundError: If baseline file doesn't exist
            ValueError: If baseline file is invalid
        """
        # Check cache first
        if baseline_name in self._baselines_cache:
            logger.debug(f"Returning cached baseline: {baseline_name}")
            return self._baselines_cache[baseline_name]
        
        # Try to find the baseline file with different naming patterns
        baseline_file = None
        
        # Pattern 1: New structure with platform/version (e.g., cis_lvl1_macos_26.0.yaml)
        for pattern in [f"{baseline_name}_macos_*.yaml", f"{baseline_name}_ios_*.yaml", f"{baseline_name}_visionos_*.yaml"]:
            matching_files = list(self.baselines_path.glob(pattern))
            if matching_files:
                # If multiple matches, use the first one (typically latest version)
                baseline_file = matching_files[0]
                logger.debug(f"Found baseline using pattern {pattern}: {baseline_file.name}")
                break
        
        # Pattern 2: Old structure (e.g., cis_lvl1.yaml)
        if not baseline_file:
            old_pattern = self.baselines_path / f"{baseline_name}.yaml"
            if old_pattern.exists():
                baseline_file = old_pattern
                logger.debug(f"Found baseline using old naming: {baseline_file.name}")
        
        if not baseline_file or not baseline_file.exists():
            raise FileNotFoundError(f"Baseline file not found: {baseline_name} in {self.baselines_path}")
        
        logger.info(f"Loading baseline from: {baseline_file}")
        
        try:
            with open(baseline_file, 'r', encoding='utf-8') as f:
                baseline_data = yaml.safe_load(f)
            
            # Create Baseline object
            baseline = Baseline.from_dict(baseline_name, baseline_data)
            
            # Cache it
            self._baselines_cache[baseline_name] = baseline
            
            logger.info(f"Loaded baseline '{baseline_name}': {len(baseline.get_all_rules())} rules")
            
            return baseline
            
        except yaml.YAMLError as e:
            raise ValueError(f"Invalid YAML in baseline file: {e}")
        except Exception as e:
            raise ValueError(f"Failed to load baseline: {e}")
    
    @staticmethod
    def normalize_section_name(section_name: str) -> str:
        """Normalize section names from old to new format.
        
        Args:
            section_name: Original section name (old or new format)
            
        Returns:
            Normalized section name in new format
        """
        return SECTION_NAME_MAPPING.get(section_name, section_name)
