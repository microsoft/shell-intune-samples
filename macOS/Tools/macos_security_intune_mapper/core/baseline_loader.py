"""Baseline loader for macOS security baselines."""

import logging
import yaml
from pathlib import Path
from typing import List, Optional, Dict, Any

from ..models.baseline import Baseline, BaselineSection

logger = logging.getLogger(__name__)


class BaselineLoader:
    """Loads macOS security baselines from YAML files."""
    
    def __init__(self, macos_security_path: Optional[str] = None):
        """Initialize the baseline loader.
        
        Args:
            macos_security_path: Path to macos_security folder. If None, uses default.
        """
        if macos_security_path:
            self.baselines_path = Path(macos_security_path) / "baselines"
        else:
            # Try to find macos_security folder
            current = Path(__file__).parent
            while current.parent != current:
                macos_security = current / "macos_security"
                if macos_security.exists() and (macos_security / "baselines").exists():
                    self.baselines_path = macos_security / "baselines"
                    break
                current = current.parent
            else:
                # Default to relative path
                self.baselines_path = Path("macos_security/baselines")
        
        self._baselines_cache: Dict[str, Baseline] = {}
        logger.info(f"Baseline loader initialized with path: {self.baselines_path}")
    
    def list_baselines(self) -> List[str]:
        """List all available baselines.
        
        Returns:
            List of baseline names (without .yaml extension)
        """
        if not self.baselines_path.exists():
            logger.warning(f"Baselines path does not exist: {self.baselines_path}")
            return []
        
        baselines = []
        for baseline_file in self.baselines_path.glob("*.yaml"):
            if baseline_file.name != "all_rules.yaml":  # Skip the all_rules baseline
                baselines.append(baseline_file.stem)
        
        return sorted(baselines)
    
    def load_baseline(self, baseline_name: str) -> Baseline:
        """Load a baseline from YAML file.
        
        Args:
            baseline_name: Name of the baseline (without .yaml extension)
            
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
        
        baseline_file = self.baselines_path / f"{baseline_name}.yaml"
        
        if not baseline_file.exists():
            raise FileNotFoundError(f"Baseline file not found: {baseline_file}")
        
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
