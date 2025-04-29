# vps-setup
A script to execute common setup tasks on newly created VPS (Virtual Private Servers).

## Description

This script is based on Hetzner Community guides on [How to Keep a VPS Server Safe](https://community.hetzner.com/tutorials/security-ubuntu-settings-firewall-tools)

This script is develop for Debian 12.

## sysadmin user

In addition to installing and configuring some tools, this script will create a `sysadmin` user for subsequent logins and automated tasks.
Therefore, in order to execute you will need to copy an `id_ed25519.pub` public key file in the same directory where this script will be run. The execution
will then take care to append that public key to the `/home/sysadmin/.ssh/authorized_keys` file so you can login using ssh with the newly
created sysadmin user (assuming you have the private key in your machine).

## ssh port

This script will change the default ssh port from 22 to 1222 so in order to log in again you will need to either parametrize the `ssh` command or add a
custom configuration to your `~/.ssh/config` file.
```bash
ssh -p 1222 sysadmin@1.2.3.4
```

```
# ~/.ssh/config
Host 1.2.3.4
  User sysadmin
  IdentityFile ~/.ssh/id_ed25519 # Or whatever your ssh key is.
  Port 1222
```

## How to execute
Copy to the host both the script and the public key for the sysadmin account that will be created then execute the script.

```bash
scp vps-setup.sh root@1.2.3.4:/root/
# If you want a different public key for the sysadmin user replace it
scp ~/.ssh/id_ed25519.pub root@1.2.3.4:/root/

# SSH into the VPS
ssh root@1.2.3.4

# Run the script (from the VPS)
./vps-setup.sh
```

Before closing the root session, check that you are able to login with the new sysadmin account:

```bash
ssh -p 1222 sysadmin@1.2.3.4
```

If you are able to login with the sysadmin account, close the root session. You can validate that root login is disabled by executing:

```bash
ssh root@1.2.3.4
root@1.2.3.4: Permission denied (publickey).
```
