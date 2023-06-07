#!/bin/bash -eux

# Add vagrant user to sudoers.
echo "vagrant        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

# Disable daily apt unattended updates.
echo 'APT::Periodic::Enable "0";' >> /etc/apt/apt.conf.d/10periodic

# Install XenTools
echo 'Installing XenTools'
mkdir /mnt/cdrom
sudo mount /dev/sr1 /mnt/cdrom
sudo /bin/bash /mnt/cdrom/Linux/install.sh -n
sudo umount /dev/sr1

echo 'Setting up Ansible user and key'
useradd -d /home/ansible -s /bin/bash -m ansible
mkdir -pm 700 /home/ansible/.ssh
cat /tmp/ansible.pub >> /home/ansible/.ssh/authorized_keys
chown -R ansible:ansible /home/ansible/.ssh
echo "ansible        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers