# Resizing the Persistent Disk on the fly

## Add more space to the disk

4GB more for example

```
$ dd if=/dev/zero bs=1g count=4 >> vm/docker-root-data.img
4+0 records in
4+0 records out
4294967296 bytes transferred in 11.438091 secs (375496862 bytes/sec)
```

## Re-partition the disk

```
$ make run
Booting up...
$ make ssh
docker-root-xhyve: running on 192.168.64.2
docker@192.168.64.2's password: 
Welcome to DockerRoot version 1.0.2, Docker version 1.8.2, build 0a8c2e3
[docker@docker-root ~]$ (echo d; echo 1; echo n; echo p; echo 1; echo; echo; echo w) | sudo fdisk /dev/vda
[docker@docker-root ~]$ sudo reboot
reboot[264]: Executing shutdown scripts in /etc/init.d
Saving random seed... done.
reboot[264]: reboot
Connection to 192.168.64.2 closed by remote host.
```

## Resize the disk after reboot

```
$ make ssh
docker-root-xhyve: running on 192.168.64.2
docker@192.168.64.2's password: 
Welcome to DockerRoot version 1.0.2, Docker version 1.8.2, build 0a8c2e3
[docker@docker-root ~]$ sudo resize2fs /dev/vda1
resize2fs 1.42.13 (17-May-2015)
Filesystem at /dev/vda1 is mounted on /mnt/vda1; on-line resizing required
old_desc_blocks = 1, new_desc_blocks = 1
The filesystem on /dev/vda1 is now 1852672 (4k) blocks long.

```

Done.
