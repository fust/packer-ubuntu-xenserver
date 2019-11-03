#!/bin/bash -eux

# Add ansible user to sudoers.
echo "ansible        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

# Disable daily apt unattended updates.
echo 'APT::Periodic::Enable "0";' >> /etc/apt/apt.conf.d/10periodic

# Install XenTools
mkdir /mnt/cdrom
sudo mount /dev/sr1 /mnt/cdrom
sudo /bin/bash /mnt/cdrom/Linux/install.sh -n
sudo umount /dev/sr1