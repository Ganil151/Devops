import json
import os
import sys
import argparse
from datetime import datetime
import base64
import re
from collections import Counter
from pathlib import Path

try:
    import fitz  # PyMuPDF
except ImportError:
    print("Error: PyMuPDF (fitz) is not installed. Run: pip install pymupdf")
    sys.exit(1)

# --- CONFIGURATION ---
BASE_JSON_DIR = r"C:\Users\Ganil\Documents\Devops\00-Resources\04-Books-Guides\json_scrape"
BASE_CONTENT_DIR = r"C:\Users\Ganil\Documents\Devops\00-Resources\04-Books-Guides\Processed_Content"

class DevOpsPDFArchitect:
    def __init__(self, pdf_path):
        self.pdf_path = Path(pdf_path)
        self.doc = None
        self.subject = "Uncategorized"
        self.topic = "General"
        self.data = {
            "metadata": {},
            "pages": [],
            "extracted_assets": {"images": [], "mermaid": [], "text_blocks": []}
        }

    def _classify_content(self, text_sample):
        """Step 1: Analyze PDF by subject and topic using keyword heuristics."""
        # DevOps Domain Mapping
        categories = {
            "Infrastructure": ["terraform", "ansible", "bash", "cloudformation", "iac", "vagrant"],
            "Containerization": ["docker", "kubernetes", "k8s", "podman", "containerd"],
            "CI-CD": ["jenkins", "github actions", "gitlab", "pipeline", "automation"],
            "Monitoring": ["prometheus", "grafana", "elk", "logging", "observability"],
            "Security": ["devsecops", "vault", "encryption", "iam", "compliance"]
        }
        
        text_lower = text_sample.lower()
        for subject, keywords in categories.items():
            if any(k in text_lower for k in keywords):
                self.subject = subject
                # Extract first matching keyword as topic
                match = next((k.capitalize() for k in keywords if k in text_lower), "General")
                self.topic = match
                break

    def _extract_mermaid(self, text):
        """Step 4: Extract Mermaid diagram syntax."""
        mermaid_pattern = r"graph [A-Z].*?|sequenceDiagram.*?|classDiagram.*?"
        matches = re.findall(mermaid_pattern, text, re.DOTALL)
        return matches

    def process(self):
        if not self.pdf_path.exists():
            return False
        
        self.doc = fitz.open(self.pdf_path)
        full_text = ""
        
        # Metadata Setup
        self.data["metadata"] = {
            "filename": self.pdf_path.name,
            "page_count": len(self.doc),
            "timestamp": datetime.now().isoformat()
        }

        for page_num in range(len(self.doc)):
            page = self.doc.load_page(page_num)
            text = page.get_text("text")
            full_text += text
            
            # Step 4: Extract Information & Mermaid
            page_data = {
                "page": page_num + 1,
                "text": text,
                "mermaid": self._extract_mermaid(text),
                "images": []
            }

            # Step 4: Extract Images/Diagrams
            for img_index, img in enumerate(page.get_images(full=True)):
                xref = img[0]
                pix = fitz.Pixmap(self.doc, xref)
                img_data = base64.b64encode(pix.tobytes("png")).decode()
                page_data["images"].append({
                    "name": f"img_{page_num}_{img_index}.png",
                    "data": img_data
                })

            self.data["pages"].append(page_data)

        # Step 1: Run Classification
        self._classify_content(full_text[:5000]) # Analyze first 5k chars
        self.data["metadata"]["subject"] = self.subject
        self.data["metadata"]["topic"] = self.topic
        
        return True

    def save_and_deploy(self):
        """Step 2, 3, & 5: Save JSON and distribute files."""
        # Ensure directories exist
        json_folder = Path(BASE_JSON_DIR)
        json_folder.mkdir(parents=True, exist_ok=True)
        
        # Step 2 & 3: Save JSON
        json_filename = f"{self.pdf_path.stem}.json"
        json_path = json_folder / json_filename
        with open(json_path, 'w', encoding='utf-8') as f:
            json.dump(self.data, f, indent=4)
        
        # Step 5: Save Assets to Subject/Topic Directories
        target_dir = Path(BASE_CONTENT_DIR) / self.subject / self.topic
        target_dir.mkdir(parents=True, exist_ok=True)
        
        # Write out a summary Markdown for easy reading in the new dir
        with open(target_dir / f"{self.pdf_path.stem}_summary.md", "w", encoding='utf-8') as md:
            md.write(f"# {self.pdf_path.stem}\n\n")
            md.write(f"**Subject:** {self.subject} | **Topic:** {self.topic}\n\n")
            
            for p in self.data["pages"]:
                if p["mermaid"]:
                    md.write(f"## Mermaid Diagrams (Page {p['page']})\n")
                    for m in p["mermaid"]:
                        md.write(f"```mermaid\n{m}\n```\n\n")
                
                if p["images"]:
                    md.write(f"## Images (Page {p['page']})\n")
                    md.write(f"Extract includes {len(p['images'])} visual assets.\n\n")

        print(f"🚀 Deployment Complete:")
        print(f"   - JSON: {json_path}")
        print(f"   - Assets: {target_dir}")

def main():
    parser = argparse.ArgumentParser(description="DevOps PDF-to-JSON Pipeline")
    parser.add_argument("pdf_path", help="Path to source PDF")
    args = parser.parse_args()

    architect = DevOpsPDFArchitect(args.pdf_path)
    if architect.process():
        architect.save_and_deploy()
    else:
        print("Failed to process PDF.")

if __name__ == "__main__":
    main()