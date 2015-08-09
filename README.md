# DockerRoot running on xhyve hypervisor

## Features

- DockerRoot
- Disable TLS
- Expose the official IANA registered Docker port 2375
- Support NFS synced folder at /Users

## Requirements

- [xhyve](https://github.com/mist64/xhyve)
  - Mac OS X Yosemite 10.10.3 or later
  - A 2010 or later Mac (i.e. a CPU that supports EPT)

## Caution

- **Kernel Panic** will occur on booting, once VirtualBox (< v5.0) has run before.

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
$ make
```

## Booting Up

```
$ sudo ./xhyverun.sh

DockerRoot: docker-root /dev/ttyS0
docker-root login: 
```

or

```
$ make run
Booting up...
```

- On Termial.app: This will open a new window, then you will see in the window as below.
- On iTerm.app: This will split the current window, then you will see in the bottom pane as below.

```
DockerRoot: docker-root /dev/ttyS0
docker-root login: 
```

## Logging In

- ID: docker
- Password: docker

```
$ make ssh
DockerRoot version 0.9.6, Docker version 1.7.1, build 786b29d
[docker@docker-root ~]$ 
```

## Shutting Down

Use `halt` command to shut down in the VM.

```
[docker@docker-root ~]$ sudo halt
halt[277]: halt
[docker@docker-root ~]$ reboot: System halted
$ 
```

or

```
$ make halt
halt[275]: halt
Connection to 192.168.64.2 closed by remote host.
Shutting down...
```

## Using Docker

```
$ docker -H `make ip`:2375 info
Containers: 0
Images: 0
Storage Driver: overlay
 Backing Filesystem: extfs
Execution Driver: native-0.2
Logging Driver: json-file
Kernel Version: 4.0.9-docker-root
Operating System: DockerRoot v0.9.6
CPUs: 1
Total Memory: 998.8 MiB
Name: docker-root
ID: NNA3:RZXY:L4IS:BUGY:ACR7:A3FG:EECH:QYN5:KI5W:3WVU:EPQM:FPDG
Debug mode (server): true
File Descriptors: 10
Goroutines: 15
System Time: 2015-08-09T21:01:56.505715062Z
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
