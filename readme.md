# Config


## Ansible Setup process

This repo is currently designed to be used with OpenRC based Gentoo systems

### Gentoo

Install ansible

`# emerge ansible`

- Get community.general for portage, SELinux, and make
- nano Get ansible.posix for mounts

`$ ansible-galaxy collection install community.general ansible.posix`

## Usage

Before the playbooks with the `gentoo` role can be used, the following must be configured:
- Your hosts file, can be any yaml file in `inventory/`
  - Carefully read all parameters in the configuration section before runnning the playbook
  - Block devices are specified using their `/dev/disk/by-id` name
    - Be mindful of whether you are selecting partitions or devices, and ensure you read the relevant playbooks before letting this reconfiure your partitions!
    - In most cases, an additional flag must be set which will allow the playbook to actually modify partitions/filesystems
    - The script should only mount/unmount the boot partition for kernel installations unless explicitly specified
- `-K` must be passed to prompt for sudo credentials if the task/action required privileges

Get host information, this is an effective way to obtain drive ids and other host information this script may use

`$ ansible -i inventory {host} -m gather_facts`

Ping hosts, can be used to bootstrap the install process when only single new SSH connections can be initiated at a time, ex. ssh agent forwarding over WSL

`$ ansible -i inventory -m ping all`

Install kernel on host nas

`$ ansible-playbook -i inventory -l nas install_kernel.yaml -K`

Relabel SElinux on the nas host

`$ ansible-playbook -i inventory -l nas selinux_relabel.yaml -K`

Configure all systems

`$ ansible-playbook -i inventory run.yaml -K`

## Configuration

Overrides to role variables should be made in the inventory file

### Host Variables

These may not have defaults, in which case, values must be defined in the host/playbook configuiration, and may be required for some functions

|  Variable name            | Default   | Required by           |  Description                                                                                          |
| ------------------------- | --------- | --------------------- | ----------------------------------------------------------------------------------------------------- |
| `reformat_boot`           | `false`   |                       | When true, the script will allow reformatting of the boot device (DANGEROUS)                          |
| `reformat_root`           | `false`   |                       | When true, the script will allow reformatting of the root device (DANGEROUS)                          |
| `boot_partition_size`     | `512`     |                       | Size of the boot partition (in MB)                                                                    |
| `root_device`             |           |                       | The disk ID of the device to be used as the system root                                               |
| `root_partition`          | `1`       |                       | The partition to be used as the system root                                                           |
| `system_root`             | `/`       |                       | The location of the system root                                                                       |
| `encrypted_root`          | `false`   |                       | When true, enables the dmcrypt and ramdisk                                                            |
| `serial_port`             | `S1`      | serial                | The port identifier for the serial port (S0,S1, etc)                                                  |
| `efi_stub`                | `false`   |                       | When true, configures the kernel/system to boot from an efi stub, requires the `root_device` is set   |

### Users

Users can be configured by adding them to a dict in `vars/users.yaml`

The key names should be the name of the user

Potential values include:

`ssh_keys` : A list containing the full SSH key as it would be listed in `ssh-add -L`

`groups` : A list of groups the user will be added to, if wheel is set, the user will be given selinux staff permissions, and will be allowed to use sudo with their ssh key

`shell` : The default shell for the user, defaults to `/bin/bash`

`se_user` : If selinux is enabled, sets the seuser value for this user and relables their home dir

### GRUB

`feature_grub` role

either `boot_device` or `efi_device` are required, these are host level vars that may be used by other functions

| Parameter name        | Default       | Description                                                                       |
| --------------------- | ------------- | --------------------------------------------------------------------------------- |
| `efi_removable`       | `false`       | Specifies whether or not GRUB should do a removable install                       |
| `grub_custom_cmdline` |               | Additional parameters to be added to `GRUB_CMDLINE_LINUX`                         |
| `boot_device`         |               | The /dev/disk/by-id/ that corresponds to the boot device or partition             |
| `efi_device`          |               | The the EFI partition disk ID, if it differs from the `boot_device`               |

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
| `gateway`             | The addressed  to be passed to `routes_{{interface_name}="defalut via"}`  |
| `modules`             | A list of modules to be passed to `modules_{{interface_name}}`            |
| `bridge`              | A list of interfaces to be bridged under the current interface            |

#### VLANs

VLAN entries can be added by creating a dict with the key name `vlan` then adding keys containing the vlan numbers
- names can be specified using the `name` key under the vlan number
- crated vlans can be configured using the configured `name` (with . replaced with _ )  or `{{vlan_interface}}_{{vlan_number}}`

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
          vlan:
            1:
              name: "fib.def"
            500:
            100:
              name: "fib.lan"
        fib_def:
          config: "192.168.0.2/24"
          gateway: "192.168.0.1"
        fib_lan:
          config: "null"
        fib1_500:
          config: "dhcp"
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

|  Variable name            |  Defaults                     |  Description                                                                                                          |
| ------------------------- | ----------------------------- | --------------------------------------------------------------------------------------------------------------------- |
| `services`                | `['ssh']`                     | List of services to install/configure                                                                                 |
| `features`                | `[]`                          | List of features to use                                                                                               |
| `gentoo_hardened`         | `true`                        | Define whether or not to use the hardened profile, this will also enable KSPP                                         | 
| `emerge_profile`          | `default/linux/amd64/17.1`    | The default profile to select                                                                                         |
| `emerge_kernel`           | `gentoo-sources`              | Short atom of the gentoo kernel source package                                                                        |
| `emerge_kernel_unstable`  | `false`                       | Tells emerge to use the unstable kernel                                                                               |
| `use_initramfs`           | `false`                       | True if an initramfs is being used, may be set automatically                                                          |
| `autorun`                 | `false`                       | If true, the entire install is played on import                                                                       |
| `clean_net`               | `false`                       | If true, network init files which are not in the config will be deleted                                               |
| `use_chroot`              | `false`                       | If true, which is implied if the root device differs from the `/` mount, does a chroot install to the `root_device`   |

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
| `dhcp`        | ISC DHCP Server                                   |

#### Features

| Name          | Description                                       |
| ------------- | ------------------------------------------------- |
| `selinux`     | Enables selinux support                           |
| `ipv6`        | Enables ipv6 support                              |
| `virt`        | Enables virtualization support                    |
| `serial`      | Enables serial output                             |
| `dhcp`        | Enables the DHCP server                           |

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

### DHCP Server variables

| Variable name             | Defaults          | Description                                                                                                       |
| ------------------------- | ----------------- | ----------------------------------------------------------------------------------------------------------------- |
| `dhcp_lease_time`         | `600`             | `default-lease-time`                                                                                              |
| `dhcp_max_lease_time`     | `7200`            | `max-lease-time`                                                                                                  |
| `dhcp_authoritative`      | `false`           | `authoritative`                                                                                                   |
| `dhcp_use_client`         | `false`           | When false, passes `-client` to emerge for the DHCP package                                                       |
| `dhcp_interfaces`         |                   | Set the DHCP interfaces in `etc/conf.d/dhcpd`, should be a list. Specified interfaces should exist in netconfig   |
| `dhcp_chroot`             | `true`            | Enables the chroot  at `/var/lib/dhcp/chroot`                                                                     |

#### Subnets

The key name should be: `dhcp_subnets`

Each key name under it should be the name of subnet

This configuration could be added to groups, hosts or as a standalone file that can be loaded with `vars_files`
- Loading the `service_dhcp` module automatically attempts to load `vars/dhcp.yaml` and will throw an error if that file is not defined and there is no configuration in the host `dhcp_subnets` dict


| Key name      | type                  | Description                                                                   |
| ------------- | --------------------- | ----------------------------------------------------------------------------- |
| `network`     | `string`              | The network of the DHCP range, ex `192.168.0.0`                               |
| `subnet`      | `string`              | The subnet of the DHCP range, ex `255.255.255.0`                              |
| `domain_name` | `string`              | Sets `domain-name`                                                            |
| `dns_servers` | `list` of `string`    | Sets the `domain-name-servers`                                                |
| `gateway`     | `string`              | Sets the `routers` option                                                     |
| `range`       | `list` of `string`    | Sets the `range`, the first parameter is the start, the second is the finish  |


Example:

    dhcp_subnets:
      lan:
        network: "192.168.0.0"
        netmask: "255.255.255.0"
        domain_name: "lan.mylocal"
        dns_servers:
          - "1.1.1.1"
          - "1.0.0.1"
        gateway: "192.168.0.1"
        range:
            - "192.168.0.10"
            - "192.168.0.100"

#### Static leases

The key name should be: `dhcp_hosts`

Each host should have a named key with the following possible keys:

| Key name      | type          | Description                                           |
| ------------- | ------------- | ----------------------------------------------------- |
| `mac`         | `string`      | Sets the `hardware ethernet` option under the host    |
| `ip`          | `string`      | Sets the `fixed-address` option                       |

Example:

    dhcp_hosts:
      computer-1:
        mac: "aa:bb:cc:dd:ee:ff"
        ip: "192.168.0.11"
      phone-a:
        mac: "ff:ee:dd:cc:bb:aa"
        ip: "192.168.100.11"





