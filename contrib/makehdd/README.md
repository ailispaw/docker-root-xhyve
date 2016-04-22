# Making a fresh persistent disk

## Make a blank disk image on Max OS X

4GB for example

```
$ dd if=/dev/zero of=vm/docker-root-data.img bs=1g count=4
4+0 records in
4+0 records out
4294967296 bytes transferred in 11.520751 secs (372802719 bytes/sec)
```

## Set up a persistent disk

- Boot it on xhyve
- Download and execute [makehdd.sh](https://github.com/ailispaw/docker-root-xhyve/blob/master/contrib/makehdd/makehdd.sh)

```
$ sudo ./xhyverun.sh

Welcome to DockerRoot docker-root /dev/ttyS0
docker-root login: docker
Password: 
Welcome to DockerRoot version 1.3.10, Docker version 1.9.1, build 66c06d0-stripped
[docker@docker-root ~]$ wget https://raw.githubusercontent.com/ailispaw/docker-root-xhyve/master/contrib/makehdd/makehdd.sh
[docker@docker-root ~]$ chmod +x makehdd.sh
[docker@docker-root ~]$ sudo ./makehdd.sh
[docker@docker-root ~]$ sudo fdisk -l

Disk /dev/vda: 4294 MB, 4294967296 bytes
64 heads, 32 sectors/track, 4096 cylinders
Units = cylinders of 2048 * 512 = 1048576 bytes

   Device Boot      Start         End      Blocks  Id System
/dev/vda1             956        4096     3216384  83 Linux
/dev/vda2               1         955      977904  82 Linux swap

Partition table entries are not in disk order
[docker@docker-root ~]$ ls -l /mnt/vda1/var/lib/docker-root/
total 8
-rw-r--r--    1 root     root            47 Apr 22 03:45 profile
-rwxr-xr-x    1 root     root          1123 Apr 22 03:45 start.sh*
[docker@docker-root ~]$ sudo halt
halt[301]: Stopping Docker daemon
docker[305]: Stopping Docker daemon
halt[301]: Executing shutdown scripts in /etc/init.d
Stopping crond... OK
Stopping sshd... OK
Saving random seed... done.
halt[301]: halt
[docker@docker-root ~]$ reboot: System halted
```

Done.
