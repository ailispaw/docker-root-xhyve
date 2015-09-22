# DockerRoot running on xhyve hypervisor

This is a toolbox to run [DockerRoot](https://github.com/ailispaw/docker-root) on xhyve hypervisor easily.

For VirtualBox or QEMU, see https://github.com/ailispaw/docker-root-packer.

## Features

- [DockerRoot](https://github.com/ailispaw/docker-root)
- Disable TLS
- Expose the official IANA registered Docker port 2375
- Support NFS synced folder at /Users

## Requirements

- [xhyve](https://github.com/mist64/xhyve)
  - Mac OS X Yosemite 10.10.3 or later
  - A 2010 or later Mac (i.e. a CPU that supports EPT)

## Caution

- **Kernel Panic** will occur on booting, once VirtualBox (< v5.0) has run before.
- Pay attention to **exposing the port 2375 without TLS**, as you see the features.

## Installing xhyve

```
$ git clone https://github.com/mist64/xhyve
$ cd xhyve
$ make
$ cp build/xhyve /usr/local/bin/ # You may need sudo.
```

or

```
$ brew install xhyve
```

## Setting up DockerRoot images and tools

```
$ git clone https://github.com/ailispaw/docker-root-xhyve
$ cd docker-root-xhyve
$ make init
```

## Booting Up

```
$ sudo ./xhyverun.sh

Welcome to DockerRoot docker-root /dev/ttyS0
docker-root login: 
```

or

```
$ make up
Booting up...
```

- On Termial.app: This will open a new window, then you will see in the window as below.
- On iTerm.app: This will split the current window, then you will see in the bottom pane as below.

```
Welcome to DockerRoot docker-root /dev/ttyS0
docker-root login: 
```

## Logging In

- ID: docker
- Password: docker

```
$ make ssh
docker-root-xhyve: running on 192.168.64.2
docker@192.168.64.2's password: 
Welcome to DockerRoot version 1.0.4, Docker version 1.8.2, build 0a8c2e3
[docker@docker-root ~]$ 
```

## Shutting Down

Use `halt` command to shut down in the VM.

```
[docker@docker-root ~]$ sudo halt
halt[247]: Executing shutdown scripts in /etc/init.d
Saving random seed... done.
halt[247]: halt
[docker@docker-root ~]$ reboot: System halted
$ 
```

or

```
$ make halt
docker-root-xhyve: running on 192.168.64.2
docker@192.168.64.2's password: 
halt[247]: Executing shutdown scripts in /etc/init.d
Saving random seed... done.
halt[247]: halt
Connection to 192.168.64.2 closed by remote host.
Shutting down...
```

## Using Docker

```
$ make env
docker-root-xhyve: running on 192.168.64.2
export DOCKER_HOST=tcp://192.168.64.2:2375;
unset DOCKER_CERT_PATH;
unset DOCKER_TLS_VERIFY;
$ eval $(make env)
docker-root-xhyve: running on 192.168.64.2
$ docker info
Containers: 0
Images: 0
Storage Driver: overlay
 Backing Filesystem: extfs
Execution Driver: native-0.2
Logging Driver: json-file
Kernel Version: 4.1.8-docker-root
Operating System: DockerRoot v1.0.4
CPUs: 1
Total Memory: 1000 MiB
Name: docker-root
ID: UYTD:YGFH:3LRG:ETDP:NBHC:PMSO:F24F:RJ2Z:XRSX:YFRZ:KUGC:MTF5
Debug mode (server): true
File Descriptors: 14
Goroutines: 16
System Time: 2015-09-22T00:38:50.626602126Z
EventsListeners: 0
Init SHA1:
Init Path: /bin/docker
Docker Root Dir: /mnt/vda1/var/lib/docker
```

## Resources

- /var/db/dhcpd_leases
- /Library/Preferences/SystemConfiguration/com.apple.vmnet.plist
  - Shared_Net_Address
  - Shared_Net_Mask
