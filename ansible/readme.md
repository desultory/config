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

`$ ansible-playbook -i inventory -l nas install_kernel.yaml -K`

Install kernels on all hosts

`$ ansible-playbook -i inventory install_kernel.yaml -K`

Configure the base system for all servers

`$ ansible-playbook -i inventory configure_base.yaml -K`

## Configuration

Overrides to role variables should be made in the inventory file

### Gentoo Variables

|  Variable name            |  Defaults             |  Description                                      |
| ------------------------- | --------------------- | ------------------------------------------------- |
| `services`                | `['ssh']`             | List of serviecs to install/configure             |
| `selinux_configure`       | `false`               | Define whether or not to configuure for SELinux   | 
| `emerge_arch`             | `amd64`               | The arch for emerge packages                      |
| `emerge_ssh_full`         | `net-misc/openssh`    | Full package atom for ssh                         |
| `emerge_sudo_full`        | `app-admin/sudo`      | Full package atom for sudo                        |


### Kernel parameters

|  Variable name            |  Defaults                                                             |  Description                                              |
| ------------------------- | --------------------------------------------------------------------- | --------------------------------------------------------- |
| `dst_grub_cfg_path`       | `/boot/grub/grub.cfg`                                                 | Grub .cfg path                                            |
| `dst_kernel_src_path`     | `/usr/src/linux/`                                                     | Base dir for the live kernel sources                      |
| `dst_kernel_config_path`  | `{{dst_kernel_src_path}}.config`                                      | the .config for the build process                         |
| `src_dir_path`            | `{{playbook_dir}}/../hosts/{{inventory_hostname}}`                    | The directory the host config should be sourced from      |
| `src_kernel_path`         | `/usr/src/linux`                                                      | The subdir the kernel configs are in                      |
| `src_kernel_config`       | `default`                                                             | The name of the kernel configuration file                 |
| `src_kernel_config_path`  | `{{src_dir_path}}{{src_kernel_path}}/{{src_kernel_config}}.config`    | The path of the kernel configuration file                 |
| `emerge_kernel_full`      | `sys-kernel/gentoo-sources`                                           | The full atom of the gentoo kernel source package         |
| `emerge_kernel_use`       | `symlink`                                                             | The use flags for kernel sources                          |
| `initramfs_enable`        | `false`                                                               | Bool determining whether or not an initramfs is used      |
| `initramfs_bin`           | `dracut`                                                              | The binary for the initramfs                              |
| `emerge_initramfs_full`   | `sys-kernel/dracut`                                                   | The full atom for the initramfs package                   |
| `kernel_module_dir_path`  | `/lib/modules`                                                        | The path used for determining the latest kernel version   |


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


