#!/bin/bash
# Setup a Debian Virtual Private Server (VPS) hosted in Hetzner
# This script follows the guidelines recommended by Hetzner:
#  - https://community.hetzner.com/tutorials/setup-ubuntu-20-04
#
# This script is developed for Debian 12.
GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

if [ -z "$1" ] || [ "$1" != "--confirm" ]; then
    echo "ATTENTION!!"
    echo "This command will disable password authentication and root login."
    echo "This means that once you logout from the current session you will no longer be able to login again as root."
    echo "After running make sure you can login with the newly created sysadmin user BEFORE closing this session."
    echo ""
    echo "If you understand this, execute the command with --confirm argument."
    exit 1
fi

if [ ! -f id_ed25519.pub ]; then
    echo -e "${RED}This script will create a sysadmin account. A file named id_ed25519.pub with the public key for this user needs to exist in this directory.${RESET}"
    echo -e "${RED}Exiting...${RESET}"
    exit 1
fi

update_apt() {
    echo -e "${GREEN} Updating apt-get repository and upgrading the system...${RESET}"
    apt-get update -qq
    apt-get upgrade -qq
}

setup_firewall() {
  echo -e "${GREEN}Installing firewall and opening only ports 1222 (ssh), 80 and 443... ${RESET}"
  apt-get install ufw -qq
  ufw default deny incoming
  ufw allow 1222/tcp
  ufw allow 80/tcp
  ufw allow 443/tcp
  ufw enable
}

setup_ssh_daemon() {
  echo -e "${GREEN}Disabbling password authentication, root login and changing SSH port to 1222...${RESET}"
  sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
  # prohibit-password is Debian's default
  sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
  sed -i 's/#Port 22/Port 1222/' /etc/ssh/sshd_config
  systemctl restart ssh
}

setup_fail2ban() {
  echo -e "${GREEN}Installing and enabling fail2ban (using default configs)...${RESET}"
  apt-get install fail2ban -qq
  # For Debian 12 install: https://github.com/fail2ban/fail2ban/issues/3292#issuecomment-1678844644
  apt-get install python3-systemd
  echo -e "[sshd]\nbackend=systemd\nenabled=true" | sudo tee /etc/fail2ban/jail.local
  systemctl enable fail2ban
  systemctl start fail2ban
}

setup_logwatch() {
  echo -e "${GREEN}Installing and enabling logwatch (using default configs)...${RESET}"
  apt-get install logwatch -qq
}

install_utils() {
  echo -e "${GREEN}Installing util tools: htop, vim and git...${RESET}"
  apt-get install htop vim git -qq
}

add_sysadmin_user() {
  echo -e "${GREEN}Adding a sysadmin user with sudo permission...${RESET}"
  adduser sysadmin
  usermod -aG sudo sysadmin
  mkdir /home/sysadmin/.ssh
  echo -e "${GREEN}Adding the id_ed25519.pub key to authorized_keys file of sysadmin user...${RESET}"
  cat id_ed25519.pub >> /home/sysadmin/.ssh/authorized_keys
}

finish_message() {
  echo -e "${GREEN}Configuration Finished!! Before closing this session check that you can ssh in using port 1222 with the newly created sysadmin account.${RESET}"
}

install_docker() {
  echo -e "${GREEN}Installing latest version of docker...${RESET}"
  # Commands extracted from official documentation:
  # https://docs.docker.com/engine/install/debian/#install-using-the-repository
  apt-get update -qq
  apt-get install ca-certificates curl -qq
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null
  apt-get update -qq
  apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -qq

  echo -e "${GREEN}Adding sysadmin user to docker group...${RESET}"
  usermod -aG docker sysadmin
}

main () {
    update_apt
    setup_firewall
    setup_ssh_daemon
    setup_fail2ban
    setup_logwatch
    install_utils
    add_sysadmin_user
    install_docker
    finish_message
}

main
