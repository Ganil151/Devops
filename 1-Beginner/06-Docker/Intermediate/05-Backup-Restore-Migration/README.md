# Backup, Restore, and Migration

Being able to commit, save, and load Docker images is essential for debugging, backing up specific states, and migrating containers between air-gapped systems (environment without internet).

## 1. Committing a Container

If you have made manual changes inside a running container and want to save its current state as a new image:

```bash
# Syntax
docker commit [OPTIONS] CONTAINER [REPOSITORY[:TAG]]

# Example: Save state of container 'web01' as image 'my-web-snapshot'
docker commit -m "Fixed config bug manually" -a "Admin" web01 my-web-snapshot:v1
```

> [!WARNING]
> While useful for quick fixes, `docker commit` is generally discouraged for production builds. Always prefer updating the `Dockerfile` to ensure reproducibility.

## 2. Exporting Images (Save)

You can save one or more images to a single tar archive. This is useful for moving images to machines that cannot access a registry.

```bash
# Save an image to a tar file
docker save -o my-app-backup.tar my-app:v1

# Save multiple images
docker save -o full-backup.tar frontend:v1 backend:v1 database:v1
```

## 3. Importing Images (Load)

On the target machine, use `docker load` to import the images from the tar archive.

```bash
# Load images from a tar file
docker load -i my-app-backup.tar
```

## 4. Migration Workflow (Air-Gapped)

1.  **Online Machine**: Pull or build the necessary images.
    ```bash
    docker pull specialized-tool:latest
    docker save -o tool.tar specialized-tool:latest
    ```
2.  **Transfer**: Copy `tool.tar` via USB or secure file transfer to the offline machine.
3.  **Offline Machine**: Load the image.
    ```bash
    docker load -i tool.tar
    docker run specialized-tool:latest
    ```

## 5. Exporting Container Filesystems

If you only want the filesystem contents (not the image layers/history), you can use `docker export`.

```bash
# Export container filesystem to tar
docker export container_name > container_fs.tar

# Import as a new "flat" image
cat container_fs.tar | docker import - my-flat-image:latest
```

| Command | Purpose | Preserves History? | Input |
| :--- | :--- | :--- | :--- |
| `docker save` | Backup Image | Yes | Image |
| `docker export` | Backup Container FS | No (Flattened) | Container |

## Resources
- [Docker Save Docs](https://docs.docker.com/engine/reference/commandline/save/)
- [Docker Load Docs](https://docs.docker.com/engine/reference/commandline/load/)
