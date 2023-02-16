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

### netconfig

The netconfig should be done under a dict named `netconfig`, preferably in host vars

The `mac` field is required for udev rules, this will ensure the device is properly named
- During the setup process, the device will be renamed to the desired name, which could cause network instability

Each item under the `netconfig` dict should be interface names, such as `br0` or `ethernet1`
- Names such as `eth1` and `wlp1` should be avoided as they are kernel device names

| Parameter name        | Description                                                               |
| --------------------- | ------------------------------------------------------------------------- |
| `mac`                 | The mac address of the interface, used to set udev rules                  |
| `config`              | The openrc `config_` parameter, such as `dhcp`, `null`, or `1.2.3.4/32`   |
| `modules`             | A list of modules to be passed to `modules_{{interface_name}}`            |
| `bridge`              | A list of interfaces to be bridged under the current interface            |

#### VLANs

VLAN entries can be added by creating a dict with the key name `vlan[n]` ex. `vlan1`

The dict can contain the following key/value pairs

| Key           | Description                                       |
| ------------- | ------------------------------------------------- |
| `name`        | The vlan name, ex `lan` `ethernet1.lan`           |
| `config`      | The config parameter, like on a normal interface  |


Example network config:

      netconfig:
        wan:
        mac: "aa:bb:cc:dd:ee:01"
          config: "null"
        ax1800:
          mac: "aa:bb:cc:dd:ee:02"
          config: "null"
          modules:
            - "!wpa_supplicant"
            - "!iw"
            - "!iwconfig"
        lan:
          mac: "aa:bb:cc:dd:ee:03"
          config: "null"
        fib1:
        mac: "aa:bb:cc:dd:ee:04"
          mtu: "9000"
          config: "null"
          vlan1:
            name: "fib.def"
            config: "192.168.0.10/24"
          vlan500:
            name: "fib.wan"
            config: dhcp
          vlan100:
            name: "fib.lan"
            config: "null"
        fib2:
        mac: "aa:bb:cc:dd:ee:04"
          mtu: "9000"
          config: "null"
        br0:
          autostart: true
          config: "192.168.1.1/24"
          bridge:
            - lan
            - fib.lan
            - ax1800
          need:
            - net.lan
            - net.fib1
            - net.ax1800


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
| `autorun`                 | `false`                       | If true, the entire install is played on import               |

#### SELinux

| Name                  | Default       | Description                                       |
| --------------------- | ------------- | ------------------------------------------------- |
| `selinux_relabel`     | `true`        | Relabels the system when enables                  |
| `selinux_status`      | `permissive`  | Sets the SELinux enforcing status                 |
| `selinux_type`        | `strict`      | Sets the SELinux policy type                      |

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


