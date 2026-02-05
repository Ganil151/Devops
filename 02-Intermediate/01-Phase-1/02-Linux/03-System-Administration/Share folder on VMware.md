- Edit  `/etc/fstab`
```sh
sudo vi /etc/fstab
```
(You can use `nano` or your preferred text editor instead of `vi`).
- **Add the Entry:** Add one of the following lines to the end of the file, depending on your mounting preference:    
   - **For mounting _all_ shared folders:**
```sh
 .host:/  /mnt/hgfs  fuse.vmhgfs-fuse  defaults,allow_other  0  0
```
  - **For mounting a _specific_ shared folder:** Replace `YourShareName` and `/mnt/hgfs/YourShareName` with your actual share name and desired mount point.
```sh
.host:/YourShareName  /mnt/hgfs/YourShareName  fuse.vmhgfs-fuse  defaults,allow_other  0  0
```  
- **Save and Exit:** If using `vi`, press `Esc`, then `:wq`, then `Enter`.
- **Test the fstab Entry (Optional but Recommended):** You can test if the `fstab` entry is correct by attempting to mount all entries specified in `fstab` (without rebooting):
```sh
sudo mount -a
```
 