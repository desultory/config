# Ansible

## Setup process

### Gentoo

Install ansible

`# emerge ansible`

Get community.general for portage, SELinux, and make

Get ansible.posix for mounts

`$ ansible-galaxy collection install community.general ansible.posix`

## Usage

Ping hosts

`$ ansible -i inventory -m ping all`

Install kernel on host nas

`$ ansible-playbook -i inventory -l nas install_kernel.yaml -K`

Install kernels on all hosts

`$ ansible-playbook -i inventory install_kernel.yaml -K`

Configure the base system for all servers

`$ ansible-playbook -i inventory configure_base.yaml -K`

## Configuration

Overrides to role variables should be made in the inventory file

### Gentoo Variables

|  Variable name            |  Defaults                                     |  Description                                      |
| ------------------------- | --------------------------------------------- | ------------------------------------------------- |
| `services`                | `['ssh']`                                     | List of serviecs to install/configure             |
| `selinux_configure`       | `false`                                       | Define whether or not to configuure for SELinux   | 
| `emerge_arch`             | `amd64`                                       | The arch for emerge packages                      |
| `emerge_profile`          | `default/linux/amd64/17.1/hardened/selinux`   | The default profile to select                     |
| `emerge_bootloader`       | `grub`                                        | Set the USE flag for the bootloade                |
| `emerge_ssh_full`         | `net-misc/openssh`                            | Full package atom for ssh                         |
| `emerge_sudo_full`        | `app-admin/sudo`                              | Full package atom for sudo                        |


### Kernel parameters

|  Variable name            |  Defaults                     |  Description                                              |
| ------------------------- | ----------------------------- | --------------------------------------------------------- |
| `emerge_kernel_full`      | `sys-kernel/gentoo-sources`   | The full atom of the gentoo kernel source package         |
| `emerge_kernel_unstable`  | `false`                       | When true, tells emerge to use the unstable kernel        |
| `initramfs_enable`        | `false`                       | Bool determining whether or not an initramfs is used      |
| `kspp_enable`             | `true`                        | Bool determining whether or not to configure for kspp     |
| `stripped_kernel`         | `true`                        | Boot determining whether or not to strip the kernel       |

### SSH Variables

|  Variable name            |  Defaults         |  Description                                      |
| ------------------------- | ----------------- | ------------------------------------------------- |
| `ssh_auth_methods`        | `publickey`       | `AuthenticationMethods`                           |
| `ssh_port`                | `22`              | `Port`                                            |
| `ssh_root_login`          | `false`           | `PermitRootLogin`                                 |
| `ssh_sftp_server`         | `true`            | `Subsystem sftp /usr/lib64/misc/sftp-server`      |
| `ssh_socket_unlink`       | `false`           | `StreamLocalBindUnlink`                           |
| `ssh_tcp_keepalive`       | `true`            | `TCPKeepAlive`                                    |
| `ssh_x11_forward`         | `false`           | `X11Forwarding`                                   |


