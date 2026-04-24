# 🛠️ Ansible Vault Challenges

## Challenge 1: The Secret Keeper
**Objective**: Encrypt and decrypt a variable file.
1.  Create a file `vars.yml` with `api_key: "12345"`.
2.  Encrypt it using `ansible-vault encrypt vars.yml`.
3.  Try to `cat vars.yml`. You should see `$ANSIBLE_VAULT;1.1;AES256`.
4.  Run a playbook that uses this file:
    ```bash
    ansible-playbook site.yml --ask-vault-pass
    ```

## Challenge 2: Single String Encryption
**Objective**: Encrypt just one variable value, not the whole file.
1.  Use `ansible-vault encrypt_string 'my_secret_password' --name 'db_pass'`.
2.  Copy the output into a plain text `group_vars/all.yml`.
3.  This allows you to keep non-sensitive names visible while hiding the values.

## Challenge 3: Password Files
**Objective**: Run automation without manual password entry.
1.  Create a file `.vault_pass` containing your vault password.
2.  Run your playbook using:
    ```bash
    ansible-playbook site.yml --vault-password-file .vault_pass
    ```
3.  **Security Check**: Add `.vault_pass` to your `.gitignore` immediately!
