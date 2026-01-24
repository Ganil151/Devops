import shutil
import os

def backup_folder(source_folder, backup_folder):
    try:
        # Check if source folder exists
        if not os.path.exists(source_folder):
            print(f"Source folder '{source_folder}' does not exist.")
            return
          
        # Create backup folder if it doesn't exist
        if not os.path.exists(backup_folder):
            os.makedirs(backup_folder)
            print(f"Created backup folder: {backup_folder}")

        # Copy contents from source to backup folder
        shutil.copytree(source_folder, os.path.join(backup_folder, os.path.basename(source_folder)), dirs_exist_ok=True)
        print(f"Backup of '{source_folder}' completed successfully to '{backup_folder}'.")

    except Exception as e:
        print(f"An error occurred: {e}")    

# Example usage
source = 'path/to/source/folder'
backup = 'path/to/backup/folder'
backup_folder(source, backup)