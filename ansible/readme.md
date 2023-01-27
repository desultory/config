# Ansible

## Setup process

### Gentoo

Install ansible

`# emerge ansible`

Get community packages for SELinux

`$ ansible-galaxy collection install community.general`

## Usage

Ping hosts

`$ ansible-playbook -i inventory all`



