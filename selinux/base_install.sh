#!/bin/bash

ADMIN_USER="desu"

# https://wiki.gentoo.org/wiki/SELinux/Installation

FEATURES="-selinux" emerge -1 selinux-base
FEATURES="-selinux -sesandbox" emerge -1 selinux-base
FEATURES="-selinux -sesandbox" emerge -1 selinux-base-policy
emerge -uDN @world

mkdir /mnt/gentoo
mount -o bind / /mnt/gentoo
# removed proc
setfiles -r /mnt/gentoo /etc/selinux/strict/contexts/files/file_contexts /mnt/gentoo/{dev,home,run,sys,tmp}
umount /mnt/gentoo

rlpkg -a -r
semanage login -a -s staff_u $ADMIN_USER
restorecon -R -F /home/$ADMIN_USER
semanage user -m -R "staff_r sysadm_r system_r" root
semanage user -m -R "staff_r sysadm_r system_r" staff_u
