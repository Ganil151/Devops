"""
XML Parser and Extractor
Description: Parses XML files and searches for specific elements.
Author: Senior DevOps Engineer
Version: 1.0 (Golden Standard)
"""

import xml.etree.ElementTree as ET
import argparse

def parse_xml(file_path, tag=None):
    try:
        tree = ET.parse(file_path)
        root = tree.getroot()
        
        print(f"Root Element: {root.tag}")
        
        if tag:
            print(f"\nSearching for tag: {tag}")
            found = False
            for elem in root.iter(tag):
                print(f"Found: {elem.tag} = {elem.text}")
                found = True
            if not found:
                print("No matching tags found.")
        else:
            print("\nStructure:")
            for child in root:
                print(f"- {child.tag}: {child.attrib}")
                
    except ET.ParseError as e:
        print(f"[ERROR] Malformed XML: {e}")
    except FileNotFoundError:
        print(f"[ERROR] File not found.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='XML Parser')
    parser.add_argument('file', help='Path to XML file')
    parser.add_argument('--tag', '-t', help='Tag to search for')
    args = parser.parse_args()
    
    parse_xml(args.file, args.tag)
