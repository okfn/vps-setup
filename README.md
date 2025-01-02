# vps-setup
A script to execute common setup tasks on newly created VPS (Virtual Private Servers).

## Description

This script is based on Hetzner Community guides on [How to Keep a VPS Server Safe](https://community.hetzner.com/tutorials/security-ubuntu-settings-firewall-tools)

This script is develop and tested in Debian 12, but probably will work on any Ubuntu as well.

## sysadmin user

In addition to installing and configuring some tools, this script will create a `sysadmin` user for subsequent logins and automated tasks.
Therefore, in order to execute you will need to copy an `id_rsa.pub` public key file in the same directory where this script will be run. The execution
will then take care to append that public key to the `/home/sysadmin/.ssh/authorized_keys` file so you can login using ssh with the newly
created sysadmin user (assuming you have the private key in your machine).

## How to execute

```bash
./vps-setup.sh
```
