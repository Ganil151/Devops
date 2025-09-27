sudo ssh-copy-id

The command 

`sudo ssh-copy-id` is used to copy your local SSH public key to a remote server, adding it to that server's `~/.ssh/authorized_keys` file. The `sudo` prefix is sometimes needed if your local SSH key isn't readable by your current user and requires root privileges, but this is an uncommon scenario. 

By adding your key, you can securely log into the remote server without entering a password, making it a more secure and convenient alternative to password-based authentication. 

Prerequisite: Generate an SSH key pair

Before you can use `ssh-copy-id`, you must have an SSH key pair (a public and private key) on your local machine. 

1. **Generate the keys**: Run `ssh-keygen` in your terminal. You can press `Enter` to accept the default file location (`~/.ssh/id_rsa`) and leave the passphrase empty for a passwordless login.
2. **Locate the public key**: The command will create two files in your `~/.ssh/` directory. Your public key will have the `.pub` extension (e.g., `id_rsa.pub`), while your private key will not. 

How to use `ssh-copy-id`

The general syntax for the command is `ssh-copy-id [user@]hostname`. 

Basic usage

To copy your default public key to a remote server, use the following command. The first time you run it, you will be prompted for the remote user's password. 

```sh
ssh-copy-id username@remote_host
```

Use code with caution.

- `username`: The user on the remote server you want to log in as.
- `remote_host`: The remote server's IP address or domain name. 

Specify a different public key

If you have multiple SSH keys, you can specify a non-default public key using the `-i` option. 

```sh
ssh-copy-id -i ~/.ssh/my_key.pub username@remote_host
```

Use code with caution.

Specify a custom port

If the SSH server is not running on the default port (22), you can specify the port using the `-p` option. 
```sh
ssh-copy-id -p 2222 username@remote_host
```

Use code with caution.

After running the command

1. **Test the connection**: After the command successfully copies your key, you can test it by attempting to log in to the server without a password.
 ```sh
ssh username@remote_host
 ```
   
Use code with caution.
1. **Verify the key**: If the connection is successful, you have successfully set up passwordless authentication using your SSH key. 

What `ssh-copy-id` does

The command automates several steps to ensure your key is added correctly and securely: 

- It logs in to the remote server using your password.
- It creates the `~/.ssh` directory and `authorized_keys` file if they do not exist.
- It appends your public key to the `authorized_keys` file.
- It ensures the `~/.ssh` directory and `authorized_keys` file have the correct permissions, which prevents others from modifying them. 


