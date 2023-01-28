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

`$ ansible -i inventory -m ping all`

Install kernel on host nas

`$ ansible -i inventory -t install_kernel nas`



