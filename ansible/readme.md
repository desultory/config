# Ansible

## Setup process

### Gentoo

Install ansible

`# emerge ansible`

Get community.general for SELinux and make
Get ansible.posix for mounts

`$ ansible-galaxy collection install community.general ansible.posix`

## Usage

Ping hosts

`$ ansible-playbook -i inventory all`



