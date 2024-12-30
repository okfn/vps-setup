#!/bin/bash
# Setup a Debian Virtual Private Server (VPS) hosted in Hetzner
# This script follows the guidelines recommended by Hetzner:
#  - https://community.hetzner.com/tutorials/setup-ubuntu-20-04
#
# Develop and tested in Debian 12 but should work on Ubuntu as well.

update_apt() {
    echo "######## Updating apt-get repository.."
    apt update -q
}

setup_firewall() {
  echo "########## Installing firewall and opening only ports 22, 80 and 443."
  apt install -q ufw
  ufw default deny incoming
  ufw allow 22/tcp
  ufw allow 80/tcp
  ufw allow 443/tcp
  ufw enable
}

disable_password_login() {
  echo "########## Disabbling password authentication from SSH."
  sed -i 's/#   PasswordAuthentication yes/   PasswordAuthentication no/' /etc/ssh/ssh_config
  systemctl restart ssh
}

setup_fail2ban() {
  echo "########## Installing and enabling fail2ban (using default configs)..."
  apt install -q fail2ban
  systemctl enable fail2ban
  systemctl start fail2ban
}

setup_logwatch() {
  echo "########## Installing and enabling logwatch (using default configs)"
  apt install -q logwatch
}

install_utils() {
  echo "########## Installing util tools like htop..."
  apt install -q htop vim
}

main () {
    update_apt
    setup_firewall
    disable_password_login
    setup_fail2ban
    setup_logwatch
    install_utils
}

main
