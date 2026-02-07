#!/usr/bin/env python3
import os
import shutil
import argparse
import re
from pathlib import Path
from datetime import datetime

# ==============================================================================
# Script Name: centralize_cheatsheets.py
# Description: Audits the DevOps directory, centralizes cheatsheet.md files,
#              handles conflicts, and generates a master catalog.
# Author:      Gemini Code Assist
# ==============================================================================

# --- Configuration ---
SOURCE_ROOT = Path("/home/gsmash/Documents/Devops/")
DEST_ROOT = SOURCE_ROOT / "09-resources/00-cheatsheets"
CATALOG_FILE = DEST_ROOT / "00-CATALOG.md"


def slugify(value):
    """
    Converts a string to a URL-friendly slug.
    Example: "Docker CLI Cheat Sheet" -> "docker-cli-cheat-sheet"
    """
    value = str(value)
    # Remove non-alphanumeric chars (except spaces and hyphens)
    value = re.sub(r"[^\w\s-]", "", value).strip().lower()
    # Replace spaces/underscores with hyphens
    value = re.sub(r"[-\s]+", "-", value)
    return value


def extract_title(file_path):
    """
    Reads the first H1 header (line starting with '# ') from the file.
    Returns the title string or None if not found.
    """
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            for line in f:
                if line.strip().startswith("# "):
                    return line.strip()[2:].strip()
    except Exception as e:
        print(f"Warning: Could not read {file_path}: {e}")
    return None


def main():
    # --- Argument Parsing ---
    parser = argparse.ArgumentParser(
        description="Centralize and organize cheatsheet.md files."
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Simulate the move operations without making changes.",
    )
    args = parser.parse_args()

    # --- Initialization ---
    print(f"--- Starting Cheatsheet Centralization ---")
    print(f"Source Root: {SOURCE_ROOT}")
    print(f"Destination: {DEST_ROOT}")

    if args.dry_run:
        print(
            f"\n{os.environ.get('YELLOW', '')}*** DRY RUN MODE ENABLED ***{os.environ.get('NC', '')}"
        )
    else:
        print(f"\n*** LIVE EXECUTION MODE ***")

    # --- Safety Check: Permissions ---
    if not os.access(SOURCE_ROOT, os.W_OK):
        print(f"Error: No write permission for {SOURCE_ROOT}. Aborting.")
        return

    # Create destination directory if it doesn't exist
    if not args.dry_run:
        try:
            DEST_ROOT.mkdir(parents=True, exist_ok=True)
        except OSError as e:
            print(f"Error creating destination directory: {e}")
            return

    catalog_entries = []

    # --- Discovery Loop ---
    # rglob recursively finds all files matching the pattern
    files_found = list(SOURCE_ROOT.rglob("cheatsheet.md"))

    for file_path in files_found:
        # 1. Ignore files already in the destination folder to prevent infinite loops
        if DEST_ROOT in file_path.parents:
            continue

        print(f"\nProcessing: {file_path}")

        # 2. Metadata Extraction
        title = extract_title(file_path)
        if not title:
            print("  - No H1 header found. Using parent folder name as title.")
            title = file_path.parent.name

        # 3. Dynamic Naming (Slugify)
        slug = slugify(title)
        if not slug:  # Fallback if slugify results in empty string
            slug = slugify(file_path.parent.name)

        target_folder = DEST_ROOT / slug

        # 4. Conflict Handling
        if target_folder.exists():
            print(f"  - Conflict: Destination '{slug}' already exists.")

            # Strategy 1: Append parent folder name for context
            new_slug = slugify(f"{title} {file_path.parent.name}")
            target_folder = DEST_ROOT / new_slug

            if target_folder.exists():
                # Strategy 2: Append numeric suffix if context still conflicts
                counter = 2
                base_slug = new_slug
                while target_folder.exists():
                    new_slug = f"{base_slug}-{counter}"
                    target_folder = DEST_ROOT / new_slug
                    counter += 1

            print(f"  - Resolved to: {target_folder.name}")

        target_file = target_folder / "cheatsheet.md"

        # 5. Execution (Move & Cleanup)
        if args.dry_run:
            print(f"  [DRY RUN] Would create folder: {target_folder}")
            print(f"  [DRY RUN] Would move file to: {target_file}")
            print(
                f"  [DRY RUN] Would create DEPRECATED.md at: {file_path.parent / 'DEPRECATED.md'}"
            )
        else:
            try:
                target_folder.mkdir(parents=True, exist_ok=True)
                shutil.move(str(file_path), str(target_file))

                # Create DEPRECATED.md in the old location
                deprecated_path = file_path.parent / "DEPRECATED.md"
                with open(deprecated_path, "w") as f:
                    f.write(f"# Resource Moved\n\n")
                    f.write(
                        f"The cheatsheet previously located here has been moved to the central library.\n\n"
                    )
                    f.write(
                        f"**New Location:** [{target_folder.name}]({target_file})\n"
                    )

                print(f"  [SUCCESS] Moved to {target_folder.name}")
            except Exception as e:
                print(f"  [ERROR] Failed to move file: {e}")
                continue

        # Add to catalog list
        # Relative path for the link in catalog
        rel_path = f"./{target_folder.name}/cheatsheet.md"
        catalog_entries.append(
            f"- **{title}** - [Open]({rel_path}) (Original Context: `{file_path.parent.name}`)"
        )

    # 6. Generate Catalog
    if catalog_entries:
        if args.dry_run:
            print(
                f"\n[DRY RUN] Would generate {CATALOG_FILE} with {len(catalog_entries)} entries."
            )
        else:
            try:
                with open(CATALOG_FILE, "w") as f:
                    f.write("# Centralized Cheatsheet Catalog\n\n")
                    f.write(
                        f"> Last Updated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n"
                    )
                    f.write(
                        "Below is the index of all centralized DevOps cheatsheets.\n\n"
                    )
                    for entry in sorted(catalog_entries):
                        f.write(f"{entry}\n")
                print(f"\n[SUCCESS] Catalog generated at: {CATALOG_FILE}")
            except Exception as e:
                print(f"\n[ERROR] Failed to write catalog: {e}")
    else:
        print("\nNo cheatsheets found to process.")


if __name__ == "__main__":
    main()
