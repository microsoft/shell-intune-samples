#!/usr/bin/env python3
"""Command-line tool for generating Intune policies from macOS security baselines."""

import argparse
import logging
import sys
from pathlib import Path
from typing import Any

# Add current directory to path for imports
sys.path.insert(0, str(Path(__file__).parent))

from core.baseline_loader import BaselineLoader
from core.settings_catalog import SettingsCatalog
from core.policy_mapper import PolicyMapper
from core.rules_loader import RulesLoader
from core.exporter import IntuneExporter

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout),
        logging.FileHandler('macos_security_intune_mapper.log')
    ]
)

logger = logging.getLogger(__name__)


def resolve_rule_odvs(rule, baseline) -> Any:
    """Resolve $ODV placeholders in rule's mobileconfig_info and ddm_info using baseline values.
    
    Args:
        rule: Original rule
        baseline: Current baseline
        
    Returns:
        New Rule instance with resolved ODV values
    """
    if not rule.odv or not isinstance(rule.odv, dict):
        return rule
    
    # Get the baseline's parent_values (e.g., "cis_lvl2")
    baseline_key = baseline.parent_values if hasattr(baseline, 'parent_values') and baseline.parent_values else baseline.name
    
    # Get the ODV value for this baseline
    odv_value = rule.odv.get(baseline_key) or rule.odv.get('recommended')
    
    if odv_value is None:
        return rule
    
    # Create a copy of mobileconfig_info with resolved ODVs
    resolved_mobileconfig_info = replace_odv_in_dict(rule.mobileconfig_info, odv_value)
    
    # Create a copy of ddm_info with resolved ODVs
    resolved_ddm_info = replace_odv_in_dict(rule.ddm_info, odv_value)
    
    # Create a new rule with resolved values
    from dataclasses import replace
    return replace(rule, mobileconfig_info=resolved_mobileconfig_info, ddm_info=resolved_ddm_info)


def replace_odv_in_dict(data, odv_value):
    """Recursively replace $ODV placeholders in a dictionary or value.
    
    Args:
        data: Data structure (dict, list, str, etc.)
        odv_value: Value to replace $ODV with
        
    Returns:
        Data structure with $ODV replaced
    """
    if isinstance(data, dict):
        return {k: replace_odv_in_dict(v, odv_value) for k, v in data.items()}
    elif isinstance(data, list):
        return [replace_odv_in_dict(item, odv_value) for item in data]
    elif isinstance(data, str) and data == "$ODV":
        return odv_value
    else:
        return data


def prompt_for_path(prompt_message: str, default_path: str = None, must_exist: bool = True) -> Path:
    """Prompt user for a file/directory path.
    
    Args:
        prompt_message: Message to display to user
        default_path: Default path to use if user presses Enter
        must_exist: Whether the path must exist
        
    Returns:
        Path object
    """
    while True:
        if default_path:
            user_input = input(f"{prompt_message} [{default_path}]: ").strip()
            path_str = user_input if user_input else default_path
        else:
            path_str = input(f"{prompt_message}: ").strip()
        
        if not path_str:
            print("Path cannot be empty. Please try again.")
            continue
        
        path = Path(path_str)
        
        if must_exist and not path.exists():
            print(f"Error: Path does not exist: {path}")
            print("Please enter a valid path.")
            continue
        
        return path


def choose_baseline(baselines: list) -> str:
    """Display baselines and let user choose one by number.
    
    Args:
        baselines: List of baseline names
        
    Returns:
        Selected baseline name
    """
    while True:
        print("\n" + "="*60)
        print("Available Baselines:")
        print("="*60)
        
        for idx, baseline in enumerate(baselines, 1):
            print(f"  {idx}. {baseline}")
        
        print("="*60)
        
        choice = input(f"\nEnter baseline number (1-{len(baselines)}) or 'q' to quit: ").strip()
        
        if choice.lower() == 'q':
            print("Exiting...")
            sys.exit(0)
        
        try:
            choice_num = int(choice)
            if 1 <= choice_num <= len(baselines):
                selected = baselines[choice_num - 1]
                print(f"\n✓ Selected: {selected}")
                return selected
            else:
                print(f"Error: Please enter a number between 1 and {len(baselines)}")
        except ValueError:
            print("Error: Please enter a valid number")


def interactive_mode(catalog_path_arg=None, macos_security_path_arg=None, output_path_arg=None):
    """Run the tool in interactive mode with user prompts.
    
    Args:
        catalog_path_arg: Optional pre-provided catalog path from command line
        macos_security_path_arg: Optional pre-provided macos_security path from command line
        output_path_arg: Optional pre-provided output path from command line
    """
    print("\n" + "="*60)
    print("macOS Security Baselines Generator - Interactive Mode")
    print("="*60)
    print()
    
    # Prompt for Settings Catalog path (unless already provided)
    if catalog_path_arg:
        catalog_path = Path(catalog_path_arg)
        print(f"Step 1: Settings Catalog JSON file")
        print(f"Using provided path: {catalog_path}")
        if not catalog_path.exists():
            print(f"Error: Provided catalog path does not exist: {catalog_path}")
            sys.exit(1)
    else:
        default_catalog = str(Path(__file__).parent / "settingsCatalog.json")
        print("Step 1: Settings Catalog JSON file")
        print("This file contains Microsoft Intune Settings Catalog definitions.")
        catalog_path = prompt_for_path(
            "Enter path to settingsCatalog.json",
            default_path=default_catalog,
            must_exist=True
        )
    
    # Prompt for macos_security folder (unless already provided)
    if macos_security_path_arg:
        macos_security_path = Path(macos_security_path_arg)
        print(f"\nStep 2: macOS Security folder")
        print(f"Using provided path: {macos_security_path}")
        if not macos_security_path.exists():
            print(f"Error: Provided macos_security path does not exist: {macos_security_path}")
            sys.exit(1)
    else:
        default_macos_security = str(Path(__file__).parent.parent / "macos_security")
        print("\nStep 2: macOS Security folder")
        print("This folder contains baseline YAML files and rule definitions.")
        macos_security_path = prompt_for_path(
            "Enter path to macos_security folder",
            default_path=default_macos_security,
            must_exist=True
        )
    
    # Load Settings Catalog
    print("\n" + "-"*60)
    logger.info(f"Loading Settings Catalog from {catalog_path}")
    try:
        settings_catalog = SettingsCatalog.from_file(catalog_path)
    except Exception as e:
        print(f"Error loading Settings Catalog: {e}")
        sys.exit(1)
    
    # Initialize baseline loader
    baseline_loader = BaselineLoader(str(macos_security_path))
    baselines = baseline_loader.list_baselines()
    
    if not baselines:
        print(f"\nError: No baselines found in {macos_security_path / 'baselines'}")
        print("Please check the path and try again.")
        sys.exit(1)
    
    print(f"\n✓ Found {len(baselines)} baselines")
    
    # Let user choose baseline
    baseline_name = choose_baseline(baselines)
    
    # Prompt for output directory (unless already provided)
    if output_path_arg:
        output_path = Path(output_path_arg)
        print(f"\nStep 3: Output directory")
        print(f"Using provided path: {output_path}")
    else:
        print("\nStep 3: Output directory")
        default_output = "."
        output_path = prompt_for_path(
            "Enter output directory",
            default_path=default_output,
            must_exist=False
        )
    
    # Create output directory if it doesn't exist
    output_path.mkdir(parents=True, exist_ok=True)
    
    # Generate policies
    print("\n" + "="*60)
    print("Generating Policies")
    print("="*60)
    
    try:
        # Load baseline
        logger.info(f"Loading baseline: {baseline_name}")
        baseline = baseline_loader.load_baseline(baseline_name)
        logger.info(f"Loaded baseline: {baseline.name} ({len(baseline.get_all_rules())} rules)")
        
        # Load rules
        rules_loader = RulesLoader(str(macos_security_path))
        all_rules = baseline.get_all_rules()
        
        logger.info("Loading rule details and resolving ODV (Organizational Default Values)...")
        loaded_rules = []
        for rule_id in all_rules:
            rule = rules_loader.load_rule(rule_id)
            if rule:
                # Resolve ODV values for this rule based on baseline
                resolved_rule = resolve_rule_odvs(rule, baseline)
                loaded_rules.append(resolved_rule)
        
        logger.info(f"Loaded {len(loaded_rules)} rules (with ODV values resolved)")
        
        # Map rules to policies
        logger.info("Mapping rules to Intune policies...")
        policy_mapper = PolicyMapper(settings_catalog, prefer_ddm=True)
        
        mapped_policies = []
        unmapped_rules = []
        
        for rule in loaded_rules:
            policy = policy_mapper.map_rule_to_policy(rule)
            if policy:
                mapped_policies.append(policy)
            else:
                # Check if rule has mobileconfig
                if rule.has_mobileconfig:
                    unmapped_rules.append(rule)
                else:
                    logger.warning(f"Rule {rule.id} has no mobileconfig and cannot be mapped to Settings Catalog")
        
        logger.info(f"Mapped {len(mapped_policies)} policies to Settings Catalog")
        logger.info(f"Found {len(unmapped_rules)} unmapped rules (will generate mobileconfig)")
        
        # Generate output filenames based on baseline name
        baseline_filename = baseline_name.replace('_', '-')
        json_filename = f"{baseline_filename}.json"
        mobileconfig_filename = f"{baseline_filename}.mobileconfig"
        
        # Export to Intune JSON
        if mapped_policies:
            exporter = IntuneExporter(settings_catalog)
            
            # Analyze dependencies
            exporter.analyze_dependencies(loaded_rules)
            
            # Generate policy name
            policy_name = baseline.title if hasattr(baseline, 'title') else baseline.name
            
            json_output = output_path / json_filename
            json_data = exporter.export_to_intune_json(
                mapped_policies, 
                baseline_name=policy_name
            )
            
            json_output.write_text(json_data, encoding='utf-8')
            logger.info(f"✓ Generated Settings Catalog JSON: {json_output}")
            logger.info(f"  - Contains {len(mapped_policies)} mapped settings")
        else:
            logger.warning("No policies mapped to Settings Catalog - no JSON file generated")
        
        # Export to mobileconfig
        if unmapped_rules:
            exporter = IntuneExporter(settings_catalog)
            
            mobileconfig_output = output_path / mobileconfig_filename
            mobileconfig_data = exporter.export_combined_mobileconfig(unmapped_rules)
            
            mobileconfig_output.write_text(mobileconfig_data, encoding='utf-8')
            logger.info(f"✓ Generated mobileconfig: {mobileconfig_output}")
            logger.info(f"  - Contains {len(unmapped_rules)} unmapped rules")
        else:
            logger.info("No unmapped rules - no mobileconfig file generated")
        
        # Print summary
        print("\n" + "="*60)
        print("GENERATION SUMMARY")
        print("="*60)
        print(f"Baseline: {baseline.name}")
        print(f"Total rules: {len(loaded_rules)}")
        print(f"Mapped to Settings Catalog: {len(mapped_policies)}")
        print(f"Exported as mobileconfig: {len(unmapped_rules)}")
        print(f"\nOutput directory: {output_path.absolute()}")
        if mapped_policies:
            print(f"  - {json_filename}")
        if unmapped_rules:
            print(f"  - {mobileconfig_filename}")
        print("="*60)
        
        return 0
        
    except FileNotFoundError as e:
        logger.error(f"File not found: {e}")
        return 1
    except Exception as e:
        logger.error(f"Error: {e}", exc_info=True)
        return 1


def main():
    """Main entry point for CLI tool."""
    parser = argparse.ArgumentParser(
        description='Generate Intune policies from macOS security baselines',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
Interactive Mode:
  python cli_generate.py
    - Prompts for settingsCatalog.json location
    - Prompts for macos_security folder location
    - Shows numbered list of baselines to choose from
    - Prompts for output directory
    
  You can also provide some parameters to skip those prompts:
    python cli_generate.py -c settingsCatalog.json -m ../macos_security
    - Uses provided paths and only prompts for baseline selection
    
Full Command-line Mode (no prompts):
  python cli_generate.py -b cis_lvl2 -c settingsCatalog.json -m ../macos_security
  python cli_generate.py -b 800-53r5_high -c ./settingsCatalog.json -m ../macos_security -o ./output
    - All required parameters provided, runs without any prompts
        '''
    )
    
    parser.add_argument(
        '-b', '--baseline',
        help='Name of the baseline to process (skips interactive mode)'
    )
    
    parser.add_argument(
        '-c', '--catalog',
        help='Path to settingsCatalog.json file'
    )
    
    parser.add_argument(
        '-m', '--macos-security',
        help='Path to macos_security folder'
    )
    
    parser.add_argument(
        '-o', '--output',
        default='.',
        help='Output directory for generated files (default: current directory)'
    )
    
    parser.add_argument(
        '-v', '--verbose',
        action='store_true',
        help='Enable verbose output'
    )
    
    args = parser.parse_args()
    
    # Set logging level
    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)
    
    # If baseline, catalog, and macos-security are all provided, run in command-line mode (fully non-interactive)
    if args.baseline and args.catalog and getattr(args, 'macos_security', None):
        # Command-line mode (non-interactive)
        try:
            catalog_path = Path(args.catalog)
            macos_security_path = Path(getattr(args, 'macos_security'))
            
            if not catalog_path.exists():
                logger.error(f"Settings Catalog file not found: {catalog_path}")
                return 1
            
            if not macos_security_path.exists():
                logger.error(f"macOS Security folder not found: {macos_security_path}")
                return 1
            
            # Load Settings Catalog
            logger.info(f"Loading Settings Catalog from {catalog_path}")
            settings_catalog = SettingsCatalog.from_file(catalog_path)
            
            # Load baseline
            baseline_loader = BaselineLoader(str(macos_security_path))
            logger.info(f"Loading baseline: {args.baseline}")
            baseline = baseline_loader.load_baseline(args.baseline)
            logger.info(f"Loaded baseline: {baseline.name} ({len(baseline.get_all_rules())} rules)")
            
            # Load rules
            rules_loader = RulesLoader(str(macos_security_path))
            all_rules = baseline.get_all_rules()
            
            logger.info("Loading rule details and resolving ODV (Organizational Default Values)...")
            loaded_rules = []
            for rule_id in all_rules:
                rule = rules_loader.load_rule(rule_id)
                if rule:
                    # Resolve ODV values for this rule based on baseline
                    resolved_rule = resolve_rule_odvs(rule, baseline)
                    loaded_rules.append(resolved_rule)
            
            logger.info(f"Loaded {len(loaded_rules)} rules (with ODV values resolved)")
            
            # Map rules to policies
            logger.info("Mapping rules to Intune policies...")
            policy_mapper = PolicyMapper(settings_catalog, prefer_ddm=True)
            
            mapped_policies = []
            unmapped_rules = []
            
            for rule in loaded_rules:
                policy = policy_mapper.map_rule_to_policy(rule)
                if policy:
                    mapped_policies.append(policy)
                else:
                    if rule.has_mobileconfig:
                        unmapped_rules.append(rule)
            
            logger.info(f"Mapped {len(mapped_policies)} policies to Settings Catalog")
            logger.info(f"Found {len(unmapped_rules)} unmapped rules")
            
            # Create output directory
            output_path = Path(args.output)
            output_path.mkdir(parents=True, exist_ok=True)
            
            # Generate output filenames
            baseline_filename = args.baseline.replace('_', '-')
            json_filename = f"{baseline_filename}.json"
            mobileconfig_filename = f"{baseline_filename}.mobileconfig"
            
            # Export to Intune JSON
            if mapped_policies:
                exporter = IntuneExporter(settings_catalog)
                exporter.analyze_dependencies(loaded_rules)
                
                policy_name = baseline.title if hasattr(baseline, 'title') else baseline.name
                
                json_output = output_path / json_filename
                json_data = exporter.export_to_intune_json(mapped_policies, baseline_name=policy_name)
                json_output.write_text(json_data, encoding='utf-8')
                logger.info(f"✓ Generated Settings Catalog JSON: {json_output}")
            
            # Export to mobileconfig
            if unmapped_rules:
                exporter = IntuneExporter(settings_catalog)
                mobileconfig_output = output_path / mobileconfig_filename
                mobileconfig_data = exporter.export_combined_mobileconfig(unmapped_rules)
                mobileconfig_output.write_text(mobileconfig_data, encoding='utf-8')
                logger.info(f"✓ Generated mobileconfig: {mobileconfig_output}")
            
            # Print summary
            print("\n" + "="*60)
            print("GENERATION SUMMARY")
            print("="*60)
            print(f"Baseline: {baseline.name}")
            print(f"Total rules: {len(loaded_rules)}")
            print(f"Mapped to Settings Catalog: {len(mapped_policies)}")
            print(f"Exported as mobileconfig: {len(unmapped_rules)}")
            print(f"\nOutput directory: {output_path.absolute()}")
            if mapped_policies:
                print(f"  - {json_filename}")
            if unmapped_rules:
                print(f"  - {mobileconfig_filename}")
            print("="*60)
            
            return 0
            
        except Exception as e:
            logger.error(f"Error: {e}", exc_info=args.verbose)
            return 1
    else:
        # Interactive mode (default) - pass any provided arguments to skip those prompts
        return interactive_mode(
            catalog_path_arg=args.catalog,
            macos_security_path_arg=getattr(args, 'macos_security', None),
            output_path_arg=args.output if args.output != '.' else None
        )


if __name__ == "__main__":
    sys.exit(main())
