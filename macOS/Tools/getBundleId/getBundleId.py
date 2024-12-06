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

def setup_logging(verbose=False):
    """
    Configures the logging settings based on the verbosity flag.
    """
    log_level = logging.DEBUG if verbose else logging.ERROR
    logging.basicConfig(
        level=log_level,
        format='%(levelname)s: %(message)s'
    )

def expand_pkg(pkg_path, dest_dir):
    """
    Expands a .pkg file into the specified destination directory.
    On macOS, uses pkgutil. On Windows, requires another method (not implemented here).
    """
    if platform.system() == "Darwin":
        # macOS
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
    else:
        # NOT IMPLEMENTED...
        # On Windows, you need a tool like 7z or xar to extract the pkg.
        # Example (if you have `xar` and `7z` available):
        # subprocess.run(['xar', '-xf', pkg_path, '-C', dest_dir], check=True)
        # Then manually handle conversion of binary plists if needed.
        raise NotImplementedError("Package expansion on non-macOS platforms is not implemented.")

def extract_pkgids(expanded_dir):
    """
    Extracts pkgids (receipts) from PackageInfo and Distribution XML files.
    """
    receipts = []
    packageinfos = []
    distributions = []

    # Find all PackageInfo and Distribution files
    for root, dirs, files in os.walk(expanded_dir):
        for file in files:
            if file == 'PackageInfo':
                packageinfos.append(os.path.join(root, file))
            elif file == 'Distribution':
                distributions.append(os.path.join(root, file))

    # Parse PackageInfo files for pkgids
    for pkginfo_path in packageinfos:
        try:
            logging.debug(f"Parsing PackageInfo: {pkginfo_path}")
            tree = ET.parse(pkginfo_path)
            root = tree.getroot()
            pkgid = root.attrib.get('identifier')
            if pkgid and pkgid not in receipts:
                receipts.append(pkgid)
                logging.debug(f"Found pkgid from PackageInfo: {pkgid}")
        except ET.ParseError as e:
            logging.error(f"Error parsing PackageInfo {pkginfo_path}: {e}")

    # Parse Distribution files for pkgids
    for dist_path in distributions:
        try:
            logging.debug(f"Parsing Distribution: {dist_path}")
            tree = ET.parse(dist_path)
            root = tree.getroot()
            for pkg_ref in root.findall(".//pkg-ref"):
                pkgid = pkg_ref.attrib.get("id")
                if pkgid and pkgid not in receipts:
                    receipts.append(pkgid)
                    logging.debug(f"Found pkgid from Distribution: {pkgid}")
        except ET.ParseError as e:
            logging.error(f"Error parsing Distribution {dist_path}: {e}")

    return receipts

def extract_bundleids(expanded_dir):
    """
    Extracts bundle identifiers (BundleIDs) from PackageInfo files.
    """
    bundleids = []
    packageinfos = []

    # Find all PackageInfo files
    for root, dirs, files in os.walk(expanded_dir):
        for file in files:
            if file == 'PackageInfo':
                packageinfos.append(os.path.join(root, file))

    # Parse PackageInfo files for bundle IDs
    for pkginfo_path in packageinfos:
        try:
            logging.debug(f"Parsing PackageInfo for BundleIDs: {pkginfo_path}")
            tree = ET.parse(pkginfo_path)
            root = tree.getroot()

            # Extract from bundle-version
            bundle_version = root.find('bundle-version')
            if bundle_version is not None:
                for bundle in bundle_version.findall('bundle'):
                    bundle_id = bundle.attrib.get('id')
                    if bundle_id and bundle_id not in bundleids:
                        bundleids.append(bundle_id)
                        logging.debug(f"Found BundleID from bundle-version: {bundle_id}")

            # Extract from strict-identifier
            strict_identifier = root.find('strict-identifier')
            if strict_identifier is not None:
                for bundle in strict_identifier.findall('bundle'):
                    bundle_id = bundle.attrib.get('id')
                    if bundle_id and bundle_id not in bundleids:
                        bundleids.append(bundle_id)
                        logging.debug(f"Found BundleID from strict-identifier: {bundle_id}")

            # Additionally, extract CFBundleIdentifier from Info.plist if present
            info_plist_path = os.path.join(os.path.dirname(pkginfo_path), 'Info.plist')
            if os.path.exists(info_plist_path):
                logging.debug(f"Found Info.plist: {info_plist_path}")
                try:
                    # plistlib.load can handle both XML and binary plists
                    with open(info_plist_path, 'rb') as plist_file:
                        plist_data = plistlib.load(plist_file)
                        bundleid = plist_data.get("CFBundleIdentifier")
                        if bundleid and bundleid not in bundleids:
                            bundleids.append(bundleid)
                            logging.debug(f"Found BundleID from Info.plist: {bundleid}")

                except plistlib.InvalidFileException as e:
                    logging.error(f"Invalid plist file {info_plist_path}: {e}")
                except Exception as e:
                    logging.error(f"Error reading Info.plist {info_plist_path}: {e}")

        except ET.ParseError as e:
            logging.error(f"Error parsing PackageInfo {pkginfo_path}: {e}")
        except Exception as e:
            logging.error(f"Unexpected error while parsing {pkginfo_path}: {e}")

    return bundleids

def compare_ids(pkgids, bundleids, exact_match=False):
    """
    Compares pkgids and bundleids, returning matching pairs.
    If exact_match is True, only exact matches are considered.
    Otherwise, a match is defined as one ID being a substring of the other.
    """
    matching_ids = {}
    for pkgid in pkgids:
        if exact_match:
            if pkgid in bundleids:
                matching_ids[pkgid] = [pkgid]
        else:
            matching_bundles = [bundleid for bundleid in bundleids if pkgid in bundleid or bundleid in pkgid]
            if matching_bundles:
                matching_ids[pkgid] = matching_bundles
    return matching_ids

def main():
    parser = argparse.ArgumentParser(
        description="Extract package receipts and bundle identifiers from a .pkg file and display only matching bundle IDs."
    )
    parser.add_argument(
        "--pkg_path",
        required=True,
        help="Path to the .pkg file"
    )
    parser.add_argument(
        "--exact",
        action="store_true",
        help="Enable exact matching between PkgIDs and BundleIDs."
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Enable verbose output for detailed logging."
    )
    args = parser.parse_args()
    pkg_path = args.pkg_path

    # Setup logging
    setup_logging(args.verbose)

    # Check if the file exists
    if not os.path.exists(pkg_path):
        logging.error(f"File {pkg_path} does not exist.")
        sys.exit(1)

    # Create a temporary directory for expansion
    with tempfile.TemporaryDirectory() as temp_dir:
        # Create a unique subdirectory within temp_dir for expansion
        expand_dest = os.path.join(temp_dir, "expanded_pkg")
        success = expand_pkg(pkg_path, expand_dest)
        if not success:
            logging.error("Failed to expand the package. Exiting.")
            sys.exit(1)

        # Extract pkgids
        pkgids = extract_pkgids(expand_dest)

        # Extract bundleids
        bundleids = extract_bundleids(expand_dest)

        # Compare and find matches
        matching_ids = compare_ids(pkgids, bundleids, exact_match=args.exact)

        # Print only matching bundle IDs
        matched_bundleids = set()
        for bundles in matching_ids.values():
            for bundleid in bundles:
                matched_bundleids.add(bundleid)

        # Print matched bundleids, one per line
        for b in matched_bundleids:
            print(b)

if __name__ == "__main__":
    main()