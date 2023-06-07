#!/bin/bash -eux

# Uninstall Ansible and remove PPA.
apt -y remove --purge ansible
apt-add-repository --remove ppa:ansible/ansible

# Apt cleanup.
apt autoremove
apt update

# Delete unneeded files.
rm -f /home/vagrant/*.sh

# Disable password login for Ansible user
passwd vagrant -l

# Disable root login with password
sed -i 's/PermitRootLogin no//g' /etc/ssh/sshd_config
echo  -e 'PermitRootLogin without-password' >> /etc/ssh/sshd_config

echo 'Zeroing free space'
# Zero out the rest of the free space using dd, then delete the written file.
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

# Add `sync` so Packer doesn't quit too early, before the large file is deleted.
sync