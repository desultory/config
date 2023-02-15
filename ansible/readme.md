# Ansible

## Setup process

### Gentoo

Install ansible

`# emerge ansible`

Get community.general for portage, SELinux, and make

Get ansible.posix for mounts

`$ ansible-galaxy collection install community.general ansible.posix`

## Usage

Get host information

`$ ansible -i inventory {host} -m gather_facts`

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

These may not have defaults, in which case, values must be defined in the host/playbook configuiration, and may be required for some functions

|  Variable name            | Default   | Required by           |  Description                                                                      |
| ------------------------- | --------- | --------------------- | --------------------------------------------------------------------------------- |
| `boot_device`             |           | bootloader, kernel    | The name of the item under /dev/disk/by-id/ that corresponds with the boot device |
| `reformat_boot`           |           |                       | When true, the script will allow reformatting of the boot device (DANGEROUS)      |
| `efi_device`              |           |                       | The device containing the EFI partition, useful if not using `reformat_boot`      |
| `efi_removable`           | `false`   |                       | Specifies whether or not GRUB should do a removable install                       |
| `boot_partition_size`     | `512`     |                       | Size of the boot partition (in MB)                                                |
| `system_root`             | `/`       |                       | The location of the system root                                                   | 
| `encrypted_root`          | `false`   |                       | When true, enables the dmcrypt and ramdisk                                        |
| `serial_port`             | `S1`      | serial                | The port identifier for the serial port (S0,S1, etc)                              |
| `grub_custom_cmdline`     |           |                       | Additional parameters to be added to `GRUB_CMDLINE_LINUX`                         |

### Gentoo Variables

|  Variable name            |  Defaults                     |  Description                                                  |
| ------------------------- | ----------------------------- | ------------------------------------------------------------- |
| `services`                | `['ssh']`                     | List of services to install/configure                         |
| `features`                | `[]`                          | List of features to use                                       |
| `gentoo_hardened`         | `true`                        | Define whether or not to use the hardened profile             | 
| `emerge_profile`          | `default/linux/amd64/17.1`    | The default profile to select                                 |
| `emerge_kernel`           | `gentoo-sources`              | Short atom of the gentoo kernel source package                |
| `emerge_kernel_unstable`  | `false`                       | Tells emerge to use the unstable kernel                       |
| `use_initramfs`           | `false`                       | True if an initramfs is being used, may be set automatically  |
| `autorun`                 | `true`                        | If true, the entire install is played on import               |

#### Services

| Name          | Description                                       |
| ------------- | ------------------------------------------------- |
| `ssh`         | OpenSSH server                                    |
| `docker`      | dockerd                                           |
| `dmcrypt`     | Disk encryption, inherited by encrypted_root      |

#### Features

| Name          | Description                                       |
| ------------- | ------------------------------------------------- |
| `selinux`     | Enables selinux support                           |
| `ipv6`        | Enables ipv6 support                              |
| `virt`        | Enables virtualization support                    |
| `serial`      | Enables serial output                             |

### Kernel configurator parameters

When using this module, kernel features are loaded in the following order:

  - kernel_features
  - values detected from lspci/lsusb
  - late_kernel_features
  - cust_kernel_features

It is unlikely the kernel_features variable should need modification, most system values should be detected from lspci/lsusb (templates are added to roles/kernel_configurator/templates

Templates can be added under the playbook dir under a templates folder and can be added to cust_kernel_features, just ensure the file ends in .config but the list item does not contain that suffix

late_kernel_features is used to ensure certain .configs are added after autodetected features

|  Variable name            |  Defaults                                                 |  Description                                                                  |
| ------------------------- | --------------------------------------------------------- | ----------------------------------------------------------------------------- |
| `kernel_features`         | `['strip', 'base', 'fs-basic' 'net-netfilter']`           | Define a list of kernel features, will attempt to load these templates/files  |
| `late_kernel_features`    | `['kspp']`                                                | Define a list of kernel features, loaded after autogenerated rules            |
| `cust_kernel_features`    | `[]`                                                      | Features used in addition to the base ones                                    |
| `build_clean`             | `false`                                                   | Defines whether or not make clean is ran before running make                  |
| `kconfig_allnoconfig`     | `false`                                                   | Runs make allnoconfig instead of make alldefconfig when merging kernel.configs|
| `wireless_enabled`        | `false`                                                   | When true, tells the kernel to load regdb blobs                               |

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


