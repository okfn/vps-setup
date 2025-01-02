#!/bin/bash
# Setup a Debian Virtual Private Server (VPS) hosted in Hetzner
# This script follows the guidelines recommended by Hetzner:
#  - https://community.hetzner.com/tutorials/setup-ubuntu-20-04
#
# Develop and tested in Debian 12 but should work on Ubuntu as well.
GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

if [ $1 != "--confirm" ]; then
    echo "ATTENTION!!"
    echo "This command will disable password authentication and root login."
    echo "This means that once you logout from the current session you will no longer be able to login again as root."
    echo "After running make sure you can login with the newly created sysadmin user BEFORE closing this session."
    echo ""
    echo "If you understand this, execute the command with --confirm argument."
    exit 1
fi

if [ ! -f id_rsa ]; then
    echo -e "${RED}This script will create a sysadmin account. A file named id_rsa with the public key for this user needs to exist in this directory.${RESET}"
    echo -e "${RED}Exiting...${RESET}"
    exit 1
fi

update_apt() {
    echo -e "${GREEN} Updating apt-get repository...${RESET}"
    apt update -q
}

setup_firewall() {
  echo -e "${GREEN}Installing firewall and opening only ports 22, 80 and 443... ${RESET}"
  apt install -q ufw
  ufw default deny incoming
  ufw allow 22/tcp
  ufw allow 80/tcp
  ufw allow 443/tcp
  ufw enable
}

disable_password_and_root_login() {
  echo -e "${GREEN}Disabbling password authentication and root login from SSH...${RESET}"
  sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
  sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
  systemctl restart ssh
}

disable_root_login() {
  echo -e "${GREEN}Disabbling root login...${RESET}"
}

setup_fail2ban() {
  echo -e "${GREEN}Installing and enabling fail2ban (using default configs)...${RESET}"
  apt install -q fail2ban
  systemctl enable fail2ban
  systemctl start fail2ban
}

setup_logwatch() {
  echo -e "${GREEN}Installing and enabling logwatch (using default configs)...${RESET}"
  apt install -q logwatch
}

install_utils() {
  echo -e "${GREEN}Installing util tools like htop and vim...${RESET}"
  apt install -q htop vim
}

add_sysadmin_user() {
  echo -e "${GREEN}Adding a sysadmin user with sudo permission...${RESET}"
  adduser sysadmin
  usermod -aG sudo sysadmin
  mkdir /home/sysadmin/.ssh
  echo -e "${GREEN}Adding the id_rsa key to authorized_keys file of sysadmin user...${RESET}"
  cat id_rsa >> /home/sysadmin/.ssh/authorized_keys
}

main () {
    update_apt
    setup_firewall
    disable_password_and_root_login
    setup_fail2ban
    setup_logwatch
    install_utils
    add_sysadmin_user
}

main
