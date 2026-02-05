#!/usr/bin/env python3
"""
🚀 Docx to PDF Converter Utility
================================
A robust, cross-platform utility for converting Word documents (.docx) to PDF.
Designed for automated reporting pipelines and Documentation as Code workflows.

Supports:
- Windows: Uses Microsoft Word via docx2pdf.
- Linux/MacOS: Uses LibreOffice (Headless mode).

Usage:
    python docx_to_pdf.py --input report.docx
    python docx_to_pdf.py --input ./documents/ --output ./pdfs/
"""

import os
import sys
import argparse
import logging
import subprocess
import time
from pathlib import Path
from typing import List, Optional

# Attempt to import tqdm for progress bars
try:
    from tqdm import tqdm
except ImportError:
    tqdm = None

# Attempt to import docx2pdf for Windows
try:
    from docx2pdf import convert as docx2pdf_convert
except ImportError:
    docx2pdf_convert = None

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

class DocxConverter:
    def __init__(self, output_dir: Optional[str] = None):
        self.output_dir = Path(output_dir) if output_dir else None
        self.platform = sys.platform
        self.total_converted = 0
        self.total_failed = 0
        
        if self.output_dir:
            self.output_dir.mkdir(parents=True, exist_ok=True)

    def _convert_linux(self, input_path: Path, output_path: Path) -> bool:
        """Convert using LibreOffice in headless mode."""
        try:
            # LibreOffice output directory is specified via --outdir
            # It handles the filename generation automatically (input.docx -> input.pdf)
            cmd = [
                "libreoffice",
                "--headless",
                "--convert-to", "pdf",
                str(input_path),
                "--outdir", str(output_path.parent)
            ]
            
            result = subprocess.run(cmd, capture_output=True, text=True, check=True, timeout=60)
            return True
        except (subprocess.CalledProcessError, subprocess.TimeoutExpired, FileNotFoundError) as e:
            logger.error(f"LibreOffice conversion failed for {input_path.name}: {e}")
            return False

    def _convert_windows(self, input_path: Path, output_path: Path) -> bool:
        """Convert using docx2pdf (requires MS Word)."""
        if not docx2pdf_convert:
            logger.error("docx2pdf library not installed. Cannot proceed on Windows.")
            return False
            
        try:
            docx2pdf_convert(str(input_path), str(output_path))
            return True
        except Exception as e:
            logger.error(f"Windows Word conversion failed for {input_path.name}: {e}")
            return False

    def convert(self, input_file: Path) -> bool:
        """Orchestrate conversion based on OS."""
        if not input_file.exists() or input_file.suffix.lower() != '.docx':
            logger.warning(f"Skipping invalid file: {input_file}")
            return False

        # Determine output path
        if self.output_dir:
            target_path = self.output_dir / f"{input_file.stem}.pdf"
        else:
            target_path = input_file.with_suffix('.pdf')

        logger.info(f"🔄 Converting: {input_file.name} -> {target_path.name}")
        
        success = False
        if self.platform.startswith('win'):
            success = self._convert_windows(input_file, target_path)
        else:
            success = self._convert_linux(input_file, target_path)

        if success:
            self.total_converted += 1
            logger.info(f"✅ Success: {target_path.name}")
        else:
            self.total_failed += 1
            
        return success

    def process_batch(self, input_path: str):
        """Process a single file or a directory."""
        path = Path(input_path)
        
        if not path.exists():
            logger.error(f"Input path does not exist: {input_path}")
            return

        files_to_convert = []
        if path.is_file():
            files_to_convert.append(path)
        elif path.is_dir():
            files_to_convert = list(path.glob('*.docx'))
            
        if not files_to_convert:
            logger.warning("No .docx files found to convert.")
            return

        logger.info(f"📂 Found {len(files_to_convert)} file(s) for processing.")
        
        start_time = time.time()
        
        # Use tqdm if available
        iterator = tqdm(files_to_convert, desc="Converting Documents") if tqdm else files_to_convert
        
        for doc_file in iterator:
            self.convert(doc_file)
            
        elapsed = time.time() - start_time
        logger.info(f"\n--- Conversion Summary ---")
        logger.info(f"Total converted: {self.total_converted}")
        logger.info(f"Failed: {self.total_failed}")
        logger.info(f"Time elapsed: {elapsed:.2f} seconds")
        print(f"\n🚀 Total converted: {self.total_converted} | Failed: {self.total_failed} | Time elapsed: {elapsed:.2f} seconds.")

def main():
    parser = argparse.ArgumentParser(description="Professional DOCX to PDF Converter")
    parser.add_argument("--input", "-i", required=True, help="Path to a DOCX file or directory containing DOCX files.")
    parser.add_argument("--output", "-o", help="Optional output directory for the PDF files.")
    
    args = parser.parse_args()
    
    converter = DocxConverter(output_dir=args.output)
    converter.process_batch(args.input)

if __name__ == "__main__":
    main()
