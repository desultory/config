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

### Host Variables

These have no defaults and may be required for some functions

|  Variable name            |  Required by          |  Description                                                                      |
| ------------------------- | --------------------- | --------------------------------------------------------------------------------- |
| `boot_device`             | bootloader, kernel    | The name of the item under /dev/disk/by-id/ that corresponds with the boot device |
| `boot_partition`          | bootloader, kernel    | The UUID of the boot partition, should be associated with the boot device         |
| `reformat_boot`           |                       | When true, the script will allow reformatting of the boot device (DANGEROUS)      |

### Gentoo Variables

|  Variable name            |  Defaults                     |  Description                                                  |
| ------------------------- | ----------------------------- | ------------------------------------------------------------- |
| `services`                | `['ssh']`                     | List of services to install/configure                         |
| `gentoo_hardened`         | `true`                        | Define whether or not to use the hardened profile             | 
| `docker_configure`        | `false`                       | Define whether or not to configure for Docker                 |
| `selinux_configure`       | `false`                       | Define whether or not to configure for SELinux                | 
| `emerge_profile`          | `default/linux/amd64/17.1`    | The default profile to select                                 |
| `emerge_kernel`           | `gentoo-sources`              | Short atom of the gentoo kernel source package                |
| `emerge_kernel_unstable`  | `false`                       | Tells emerge to use the unstable kernel                       |
| `boot_partition_size`     | `512`                         | Size of the boot partition (in MB)                            |
| `use_initramfs`           | `false`                       | True if an initramfs is being used, may be set automatically  |

### Kernel configurator parameters

|  Variable name            |  Defaults                                                                     |  Description                                                                  |
| ------------------------- | ----------------------------------------------------------------------------- | ----------------------------------------------------------------------------- |
| `kernel_features`         | `['base', 'strip', 'network', 'kspp', 'fs-linux', 'fs-msdos', 'net-basic']`   | Define a list of kernel features, will attempt to load these templates/files  |
| `cust_kernel_features`    |                                                                               | Features used in addition to the base ones                                    |

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


