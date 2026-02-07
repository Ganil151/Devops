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

# Setup Logging
logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")


def slugify(value):
    """Converts a string to a URL-friendly slug."""
    value = str(value)
    value = re.sub(r"[^\w\s-]", "", value).strip().lower()
    value = re.sub(r"[-\s]+", "-", value)
    return value or "unnamed-resource"


def extract_title(file_path):
    """Reads the first H1 header from the file."""
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
        description="Centralize and organize cheatsheet.md files."
    )
    parser.add_argument("--dry-run", action="store_true", help="Simulate operations.")
    parser.add_argument(
        "--cleanup",
        action="store_true",
        help="Remove empty source directories after moving.",
    )
    args = parser.parse_args()

    print(f"🚀 Starting Cheatsheet Centralization")
    print(f"Source: {SOURCE_ROOT}\nDest:   {DEST_ROOT}\n")

    if args.dry_run:
        print("⚠️  DRY RUN MODE ENABLED - No changes will be made.\n")

    if not SOURCE_ROOT.exists():
        logging.error(f"Source root {SOURCE_ROOT} does not exist.")
        return

    if not args.dry_run:
        DEST_ROOT.mkdir(parents=True, exist_ok=True)

    # 1. Discovery
    files_found = [
        f for f in SOURCE_ROOT.rglob("cheatsheet.md") if DEST_ROOT not in f.parents
    ]

    if not files_found:
        print("✅ No new cheatsheets found to process.")
        return

    catalog_entries = []

    # 2. Processing with Progress Bar
    for file_path in tqdm(files_found, desc="Organizing Cheatsheets", unit="file"):
        title = extract_title(file_path) or file_path.parent.name
        slug = slugify(title)

        target_folder = DEST_ROOT / slug

        # Conflict Resolution
        if target_folder.exists():
            slug = slugify(f"{title} {file_path.parent.name}")
            target_folder = DEST_ROOT / slug

            counter = 2
            while target_folder.exists():
                target_folder = DEST_ROOT / f"{slug}-{counter}"
                counter += 1

        target_file = target_folder / "cheatsheet.md"

        if args.dry_run:
            catalog_entries.append(f"- [DRY RUN] {title} -> {target_folder.name}")
            continue

        try:
            target_folder.mkdir(parents=True, exist_ok=True)
            shutil.move(str(file_path), str(target_file))

            # Create DEPRECATED.md redirect
            with open(file_path.parent / "DEPRECATED.md", "w") as f:
                f.write(
                    f"# Resource Moved\n\nMoved to: [{target_folder.name}](../09-resources/00-cheatsheets/{target_folder.name}/cheatsheet.md)"
                )

            catalog_entries.append(
                f"- **{title}** - [Open](./{target_folder.name}/cheatsheet.md) (Context: `{file_path.parent.name}`)"
            )

            # Optional Cleanup: Remove empty parent dir
            if args.cleanup and not any(file_path.parent.iterdir()):
                file_path.parent.rmdir()

        except Exception as e:
            logging.error(f"Failed to process {file_path}: {e}")

    # 3. Catalog Generation
    if catalog_entries and not args.dry_run:
        try:
            with open(CATALOG_FILE, "w") as f:
                f.write("# Centralized Cheatsheet Catalog\n\n")
                f.write(
                    f"> Updated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n"
                )
                for entry in sorted(catalog_entries):
                    f.write(f"{entry}\n")
            print(f"\n✨ Success! Catalog updated at: {CATALOG_FILE}")
        except Exception as e:
            logging.error(f"Catalog error: {e}")
    elif args.dry_run:
        print(f"\n[DRY RUN] Would have processed {len(files_found)} files.")


if __name__ == "__main__":
    main()
