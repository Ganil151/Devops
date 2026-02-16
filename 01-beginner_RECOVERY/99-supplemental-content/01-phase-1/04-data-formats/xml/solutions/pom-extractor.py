# 🛠️ Python Solution for XML Extraction Challenge
import xml.etree.ElementTree as ET

def extract_pom_info(xml_file):
    try:
        tree = ET.parse(xml_file)
        root = tree.getroot()
        
        # Handle namespaces if present (standard in full POM files)
        # For this simplified snippet, direct access works:
        artifact = root.find('artifactId').text
        version = root.find('version').text
        
        print(f"Artifact: {artifact}, Version: {version}")
        
    except Exception as e:
        print(f"Error parsing XML: {e}")

if __name__ == "__main__":
    # Assuming the snippet is saved as target.xml
    extract_pom_info('target.xml')
