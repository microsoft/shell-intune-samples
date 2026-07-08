#!/usr/bin/env python3
"""Test script to verify baseline loader works with new structure."""

import sys
from pathlib import Path

# Add parent to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent.parent.parent))

# Import after path is set
from shell_intune_samples.macOS.Tools.macos_security_intune_mapper.core.baseline_loader import BaselineLoader

def test_baseline_detection():
    """Test that baselines can be detected from new structure."""
    print("Testing Baseline Loader with new structure...")
    print("=" * 60)
    
    # Test with new structure
    loader = BaselineLoader(r"c:\CAT\gitrepos\macos_security")
    
    print(f"\nBaseline path: {loader.baselines_path}")
    print(f"Path exists: {loader.baselines_path.exists()}")
    
    # List baselines
    baselines = loader.list_baselines()
    
    print(f"\nFound {len(baselines)} baselines:")
    for baseline in sorted(baselines):
        print(f"  - {baseline}")
    
    # Test loading a specific baseline
    if "cis_lvl1" in baselines:
        print(f"\nTesting load of 'cis_lvl1' baseline...")
        try:
            baseline = loader.load_baseline("cis_lvl1")
            print(f"✓ Successfully loaded: {baseline.name}")
            print(f"  Title: {baseline.title}")
            print(f"  Rules: {len(baseline.get_all_rules())}")
            print(f"  Sections: {len(baseline.profile)}")
            for section in baseline.profile[:3]:
                print(f"    - {section.section}: {len(section.rules)} rules")
        except Exception as e:
            print(f"✗ Failed to load baseline: {e}")
    
    print("\n" + "=" * 60)
    print("Test complete!")

if __name__ == "__main__":
    test_baseline_detection()
