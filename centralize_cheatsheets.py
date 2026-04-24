#!/usr/bin/env python3
import os
import shutil
import argparse
import re
import logging
from pathlib import Path
from datetime import datetime
from tqdm import tqdm

# --- Configuration ---
SOURCE_ROOT = Path("/home/gsmash/Documents/Devops/").expanduser()
DEST_ROOT = SOURCE_ROOT / "09-resources/00-cheatsheets"
CATALOG_FILE = DEST_ROOT / "00-CATALOG.md"
# Define the file patterns we care about
TARGET_EXTENSIONS = {".md", ".pdf", ".docx"}

# Setup Logging
logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")


def slugify(value):
    """Converts a string to a URL-friendly slug."""
    value = str(value)
    value = re.sub(r"[^\w\s-]", "", value).strip().lower()
    value = re.sub(r"[-\s]+", "-", value)
    return value or "unnamed-resource"


def extract_title(file_path):
    """Reads the first H1 header from .md files. Returns None for binaries."""
    if file_path.suffix.lower() != ".md":
        return None
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            for line in f:
                if line.strip().startswith("# "):
                    return line.strip()[2:].strip()
    except Exception as e:
        logging.warning(f"Could not read {file_path}: {e}")
    return None


def main():
    parser = argparse.ArgumentParser(
        description="Centralize and organize cheatsheet files (.md, .pdf, .docx)."
    )
    parser.add_argument("--dry-run", action="store_true", help="Simulate operations.")
    parser.add_argument(
        "--cleanup", action="store_true", help="Remove empty source directories."
    )
    args = parser.parse_args()

    print(f"🚀 Starting Cheatsheet Centralization")
    print(f"Source: {SOURCE_ROOT}\nDest:   {DEST_ROOT}\n")

    if not SOURCE_ROOT.exists():
        logging.error(f"Source root {SOURCE_ROOT} does not exist.")
        return

    if not args.dry_run:
        DEST_ROOT.mkdir(parents=True, exist_ok=True)

    # 1. Discovery: Find any file starting with 'cheatsheet' with target extensions
    all_files = list(SOURCE_ROOT.rglob("*"))
    files_found = [
        f
        for f in all_files
        if f.stem.lower().startswith("cheatsheet")
        and f.suffix.lower() in TARGET_EXTENSIONS
        and DEST_ROOT not in f.parents
    ]

    if not files_found:
        print("✅ No new cheatsheets found to process.")
        return

    # Dictionary to group files by their source directory to keep related files together
    # e.g., { Path('source/k8s'): [k8s.md, k8s.pdf] }
    catalog_data = {}

    # 2. Processing with Progress Bar
    for file_path in tqdm(files_found, desc="Organizing Files", unit="file"):
        # Try to get a title from an MD file in the same folder, otherwise use folder name
        title = extract_title(file_path) or file_path.parent.name
        slug = slugify(title)

        target_folder = DEST_ROOT / slug

        # Conflict Resolution (only if the folder doesn't already belong to this move)
        if target_folder.exists() and not any(
            f.parent == file_path.parent
            for f in files_found
            if slugify(extract_title(f) or f.parent.name) == slug
        ):
            slug = slugify(f"{title} {file_path.parent.name}")
            target_folder = DEST_ROOT / slug

        target_file = target_folder / file_path.name

        if args.dry_run:
            logging.info(
                f"[DRY RUN] Would move {file_path.name} to {target_folder.name}/"
            )
            continue

        try:
            target_folder.mkdir(parents=True, exist_ok=True)
            shutil.move(str(file_path), str(target_file))

            # Create DEPRECATED.md redirect in source
            dep_path = file_path.parent / "DEPRECATED.md"
            if not dep_path.exists():
                with open(dep_path, "w") as f:
                    f.write(
                        f"# Resources Moved\n\nFiles moved to: [{target_folder.name}](../09-resources/00-cheatsheets/{target_folder.name}/)"
                    )

            # Store info for catalog
            if target_folder.name not in catalog_data:
                catalog_data[target_folder.name] = {"title": title, "files": []}
            catalog_data[target_folder.name]["files"].append(file_path.name)

            # Optional Cleanup
            if args.cleanup and not any(file_path.parent.iterdir()):
                file_path.parent.rmdir()

        except Exception as e:
            logging.error(f"Failed to process {file_path.name}: {e}")

    # 3. Catalog Generation
    if catalog_data and not args.dry_run:
        try:
            with open(CATALOG_FILE, "w") as f:
                f.write("# Centralized Cheatsheet Catalog\n\n")
                f.write(
                    f"> Updated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n"
                )
                f.write("| Topic | Available Formats |\n| :--- | :--- |\n")

                for folder_name in sorted(catalog_data.keys()):
                    data = catalog_data[folder_name]
                    links = [
                        f"[{Path(fn).suffix.upper()}](./{folder_name}/{fn})"
                        for fn in sorted(data["files"])
                    ]
                    f.write(f"| **{data['title']}** | {' / '.join(links)} |\n")

            print(
                f"\n✨ Success! Catalog updated with {len(catalog_data)} topics at: {CATALOG_FILE}"
            )
        except Exception as e:
            logging.error(f"Catalog error: {e}")


if __name__ == "__main__":
    main()
