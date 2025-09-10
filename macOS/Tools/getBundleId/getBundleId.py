#!/usr/bin/env python3

import os
import subprocess
import tempfile
import xml.etree.ElementTree as ET
import plistlib
import argparse
import sys
import logging
import platform
import shutil

def setup_logging(verbose=False):
    """Configure logging settings based on verbosity flag."""
    log_level = logging.DEBUG if verbose else logging.ERROR
    logging.basicConfig(
        level=log_level,
        format='%(levelname)s: %(message)s'
    )

def expand_pkg(pkg_path, dest_dir):
    """
    Expand a .pkg file into the specified destination directory.
    Only supports macOS using pkgutil.
    """
    if platform.system() != "Darwin":
        raise NotImplementedError("Package expansion on non-macOS platforms is not implemented.")
    
    try:
        logging.debug(f"Expanding {pkg_path} into {dest_dir} using pkgutil...")
        subprocess.run(
            ['pkgutil', '--expand', pkg_path, dest_dir],
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        logging.debug(f"Successfully expanded {pkg_path}.")
        return True
    except subprocess.CalledProcessError as e:
        logging.error(f"Error expanding {pkg_path}: {e.stderr.decode().strip()}")
        return False

def parse_xml_for_pkgid(xml_path, tag_name, attr_name):
    """Parse XML file and extract package IDs from specified tags and attributes."""
    pkgids = []
    try:
        logging.debug(f"Parsing {tag_name}: {xml_path}")
        tree = ET.parse(xml_path)
        root = tree.getroot()
        
        if tag_name == "PackageInfo":
            pkgid = root.attrib.get(attr_name)
            if pkgid:
                pkgids.append(pkgid)
                logging.debug(f"Found pkgid from {tag_name}: {pkgid}")
        else:  # Distribution
            for pkg_ref in root.findall(".//pkg-ref"):
                pkgid = pkg_ref.attrib.get(attr_name)
                if pkgid:
                    pkgids.append(pkgid)
                    logging.debug(f"Found pkgid from {tag_name}: {pkgid}")
    except ET.ParseError as e:
        logging.error(f"Error parsing {tag_name} {xml_path}: {e}")
    
    return pkgids

def extract_pkgids(expanded_dir):
    """Extract pkgids (receipts) from PackageInfo and Distribution XML files."""
    receipts = []
    
    for root, dirs, files in os.walk(expanded_dir):
        for file in files:
            if file == 'PackageInfo':
                pkgids = parse_xml_for_pkgid(
                    os.path.join(root, file), 
                    "PackageInfo", 
                    "identifier"
                )
                receipts.extend(pkgid for pkgid in pkgids if pkgid not in receipts)
            elif file == 'Distribution':
                pkgids = parse_xml_for_pkgid(
                    os.path.join(root, file), 
                    "Distribution", 
                    "id"
                )
                receipts.extend(pkgid for pkgid in pkgids if pkgid not in receipts)
    
    return receipts

def read_app_info_plist(info_plist_path):
    """Read app bundle information from Info.plist."""
    try:
        with open(info_plist_path, 'rb') as plist_file:
            plist_data = plistlib.load(plist_file)
            bundle_id = plist_data.get("CFBundleIdentifier")
            app_name = (plist_data.get("CFBundleName") or 
                       plist_data.get("CFBundleDisplayName") or 
                       os.path.basename(os.path.dirname(os.path.dirname(info_plist_path))).replace('.app', ''))
            return bundle_id, app_name
    except Exception as e:
        logging.error(f"Error reading Info.plist {info_plist_path}: {e}")
        return None, None

def is_applications_install(path):
    """Check if the app path indicates installation to /Applications."""
    path_lower = path.lower()
    return any(pattern in path_lower for pattern in ['/applications', 'applications', 'payload'])

def extract_apps_from_payload(payload_path, temp_dir):
    """Extract and search compressed payload for app bundles."""
    app_bundles = []
    temp_extract_dir = os.path.join(temp_dir, 'temp_payload_extract')
    
    try:
        os.makedirs(temp_extract_dir, exist_ok=True)
        
        # Try to decompress if needed
        extracted_file = payload_path
        if payload_path.endswith('.gz') or os.path.basename(payload_path) == 'Payload':
            try:
                output_file = os.path.join(temp_extract_dir, 'payload_extracted')
                subprocess.run(['gunzip', '-c', payload_path], 
                             stdout=open(output_file, 'wb'),
                             check=True, stderr=subprocess.PIPE)
                extracted_file = output_file
            except subprocess.CalledProcessError:
                pass  # Use original file
        
        # Try to extract with cpio
        try:
            with open(extracted_file, 'rb') as f:
                subprocess.run(['cpio', '-i', '--make-directories'], 
                             stdin=f, cwd=temp_extract_dir, 
                             check=True, stderr=subprocess.PIPE, stdout=subprocess.PIPE)
            
            # Search for app bundles in extracted content
            app_bundles = search_for_app_bundles(temp_extract_dir)
            
        except subprocess.CalledProcessError as e:
            logging.debug(f"Could not extract payload with cpio: {e}")
    
    except Exception as e:
        logging.debug(f"Error processing payload {payload_path}: {e}")
    
    finally:
        if os.path.exists(temp_extract_dir):
            shutil.rmtree(temp_extract_dir)
    
    return app_bundles

def search_for_app_bundles(directory):
    """Search directory for .app bundles and extract their information."""
    app_bundles = []
    
    for root, dirs, files in os.walk(directory):
        for dir_name in dirs:
            if dir_name.endswith('.app'):
                app_path = os.path.join(root, dir_name)
                info_plist_path = os.path.join(app_path, 'Contents', 'Info.plist')
                
                if os.path.exists(info_plist_path):
                    bundle_id, app_name = read_app_info_plist(info_plist_path)
                    if bundle_id:
                        is_applications = is_applications_install(root)
                        app_bundles.append((bundle_id, app_name, app_path, is_applications))
                        logging.debug(f"Found app bundle ID: {bundle_id} for {app_name} (Applications: {is_applications})")
    
    return app_bundles

def find_app_bundles_in_payload(expanded_dir):
    """Search for .app bundles in the package payload and extract their bundle IDs."""
    app_bundles = []
    
    # First, search for direct .app bundles
    app_bundles.extend(search_for_app_bundles(expanded_dir))
    
    # Then, look for compressed payloads
    for root, dirs, files in os.walk(expanded_dir):
        for file_name in files:
            if file_name.lower() in ['payload', 'payload.gz', 'payload.bz2', 'payload.xz']:
                payload_apps = extract_apps_from_payload(
                    os.path.join(root, file_name), 
                    os.path.dirname(root)
                )
                # Mark payload apps as going to /Applications
                for bundle_id, app_name, app_path, _ in payload_apps:
                    app_bundles.append((bundle_id, app_name, app_path, True))
    
    # Check install scripts for additional clues
    update_apps_from_scripts(expanded_dir, app_bundles)
    
    return app_bundles

def update_apps_from_scripts(expanded_dir, app_bundles):
    """Update app installation locations based on install script analysis."""
    scripts_dir = os.path.join(expanded_dir, "Scripts")
    if not os.path.exists(scripts_dir):
        return
    
    for script_file in ['postinstall', 'postflight']:
        script_path = os.path.join(scripts_dir, script_file)
        if not os.path.exists(script_path):
            continue
            
        try:
            with open(script_path, 'r', encoding='utf-8', errors='ignore') as f:
                script_content = f.read()
                if '/Applications' in script_content:
                    logging.debug(f"Found /Applications reference in {script_file}")
                    # Update apps that are mentioned in the script
                    for i, (bundle_id, app_name, app_path, is_applications) in enumerate(app_bundles):
                        if app_name.lower() in script_content.lower():
                            app_bundles[i] = (bundle_id, app_name, app_path, True)
                            logging.debug(f"Updated {app_name} to Applications folder based on script")
        except Exception as e:
            logging.debug(f"Could not read script {script_path}: {e}")

def guess_bundle_id_from_package_info(pkgids, pkg_path):
    """Make educated guesses about bundle IDs based on package information."""
    guesses = []
    pkg_filename = os.path.basename(pkg_path).lower()
    
    for pkgid in pkgids:
        # Apply common transformations
        bundle_id_guess = pkgid.replace('.pkg.', '.').replace('.pkg', '').replace('pkg.', '')
        
        # Zoom-specific handling
        if 'zoom' in bundle_id_guess.lower():
            if 'videomeeting' in bundle_id_guess:
                guesses.append(('us.zoom.ZoomMeetings', 'zoom.us', 'Known Zoom bundle ID pattern'))
            guesses.append((bundle_id_guess, 'Zoom (transformed)', 'Package ID transformation'))
        elif bundle_id_guess != pkgid:
            guesses.append((bundle_id_guess, 'Unknown app', 'Package ID transformation'))
    
    # Filename-based guesses
    if 'zoom' in pkg_filename and not any('zoom' in g[0].lower() for g in guesses):
        guesses.extend([
            ('us.zoom.ZoomMeetings', 'Zoom', 'Filename-based guess'),
            ('us.zoom.videomeeting', 'Zoom', 'Alternative Zoom bundle ID')
        ])
    
    return guesses

def score_bundle_id(bundle_id, app_name, is_applications, pkgids):
    """Score a bundle ID based on various criteria. Higher score = more likely to be main app."""
    score = 0
    bundle_id_lower = bundle_id.lower()
    
    # Priority 1: Apps in /Applications
    if is_applications:
        score += 1000
    
    # Priority 2: Bundle ID matches package ID
    for pkgid in pkgids:
        if pkgid in bundle_id or bundle_id in pkgid:
            score += 500
            break
    
    # Priority 3: Not a helper/service app
    helper_patterns = ['helper', 'agent', 'service', 'daemon', 'updater', 'installer', 'uninstaller', 'launcher']
    if not any(pattern in bundle_id_lower for pattern in helper_patterns):
        score += 100
    
    # Priority 4: Shorter bundle IDs (typically main apps)
    score -= len(bundle_id)
    
    return score

def find_most_likely_bundle_id(app_bundles, pkgids, bundleids, pkg_path=None):
    """Determine the most likely main application bundle ID based on various heuristics."""
    if not app_bundles:
        # No app bundles found, try to guess
        if pkg_path and pkgids:
            guesses = guess_bundle_id_from_package_info(pkgids, pkg_path)
            if guesses:
                bundle_id, app_name, reason = guesses[0]
                return bundle_id, app_name, f"Educated guess: {reason}"
        return None
    
    # Score and sort all apps
    scored_apps = []
    for bundle_id, app_name, app_path, is_applications in app_bundles:
        score = score_bundle_id(bundle_id, app_name, is_applications, pkgids)
        scored_apps.append((score, bundle_id, app_name, is_applications))
    
    # Sort by score (descending)
    scored_apps.sort(key=lambda x: x[0], reverse=True)
    
    # Return the highest scoring app
    _, bundle_id, app_name, is_applications = scored_apps[0]
    
    # Determine reason
    if is_applications:
        reason = "Primary app in /Applications"
    elif any(pkgid in bundle_id or bundle_id in pkgid for pkgid in pkgids):
        reason = "Bundle ID matches package ID"
    else:
        reason = "Best match based on heuristics"
    
    return bundle_id, app_name, reason

def main():
    parser = argparse.ArgumentParser(
        description="Extract bundle identifiers from a .pkg file for applications that install to /Applications (suitable for Intune)."
    )
    parser.add_argument("--pkg", required=True, help="Path to the .pkg file")
    parser.add_argument("--verbose", action="store_true", help="Enable verbose output for detailed logging.")
    parser.add_argument("--all", action="store_true", help="Show all application bundle IDs found that install to /Applications with their app names.")
    
    args = parser.parse_args()
    setup_logging(args.verbose)
    
    # Validate input
    if not os.path.exists(args.pkg):
        logging.error(f"File {args.pkg} does not exist.")
        sys.exit(1)
    
    # Process package
    with tempfile.TemporaryDirectory() as temp_dir:
        expand_dest = os.path.join(temp_dir, "expanded_pkg")
        
        if not expand_pkg(args.pkg, expand_dest):
            logging.error("Failed to expand the package. Exiting.")
            sys.exit(1)
        
        # Extract package IDs and find app bundles
        pkgids = extract_pkgids(expand_dest)
        app_bundles = find_app_bundles_in_payload(expand_dest)
        
        # Filter to only /Applications apps
        applications_bundles = [app for app in app_bundles if app[3]]
        
        if not applications_bundles:
            logging.error("No applications found that install to /Applications")
            sys.exit(1)
        
        if args.all:
            # Show all application bundle IDs
            print("# All application bundle IDs found in /Applications:")
            for bundle_id, app_name, _, _ in applications_bundles:
                print(f"{bundle_id}  # {app_name}")
        else:
            # Return the most likely primary application bundle ID
            result = find_most_likely_bundle_id(applications_bundles, pkgids, [], args.pkg)
            if result:
                bundle_id, app_name, reason = result
                if args.verbose:
                    print(f"# Primary bundle ID: {bundle_id} ({app_name}) - {reason}")
                print(bundle_id)
            else:
                logging.error("Could not determine the most likely bundle ID.")
                sys.exit(1)

if __name__ == "__main__":
    main()