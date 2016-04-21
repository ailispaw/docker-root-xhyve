#!/bin/sh

DEV=/dev/vda
MNT=/mnt/vda1

(echo n; echo p; echo 2; echo; echo +1000M; echo w) | fdisk ${DEV}
(echo t; echo 82; echo w) | fdisk ${DEV}
until [ -b "${DEV}2" ]; do
  sleep 0.5
done
mkswap -L DOCKERROOT-SWAP ${DEV}2

(echo n; echo p; echo 1; echo; echo; echo w) | fdisk ${DEV}
until [ -b "${DEV}1" ]; do
  sleep 0.5
done
mkfs.ext4 -b 4096 -i 4096 -F -L DOCKERROOT-DATA ${DEV}1

mkdir -p ${MNT}
mount -t ext4 ${DEV}1 ${MNT}
mkdir -p ${MNT}/var/lib/docker-root

wget -qO ${MNT}/var/lib/docker-root/profile https://raw.githubusercontent.com/ailispaw/docker-root-xhyve/master/contrib/configs/profile
wget -qO ${MNT}/var/lib/docker-root/start.sh https://raw.githubusercontent.com/ailispaw/docker-root-xhyve/master/contrib/configs/start.sh
chmod +x ${MNT}/var/lib/docker-root/start.sh

sync; sync; sync
