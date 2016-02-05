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

cat <<EOF > ${MNT}/var/lib/docker-root/profile
DOCKER_HOST="-H unix:// -H tcp://0.0.0.0:2375"
EOF

cat <<EOF > ${MNT}/var/lib/docker-root/start.sh
#!/bin/sh

SHARED_FOLDER=\$(cat /proc/cmdline | sed -n 's/^.*docker-root.shared_folder="\([^"]\+\)".*\$/\1/p')
: \${SHARED_FOLDER:="/Users"}

MOUNT_POINT=\${SHARED_FOLDER}

VIRTFS_UNAME=\$(cat /proc/cmdline | sed -n 's/^.*docker-root.virtfs_uname=\([^ ]\+\).*\$/\1/p')
if [ -n "\${VIRTFS_UNAME}" ];then
  mkdir -p "\${MOUNT_POINT}"
  umount "\${MOUNT_POINT}"
  mount -t 9p -o version=9p2000,trans=virtio,access=any,uname=\${VIRTFS_UNAME},dfltuid=\$(id -u docker),dfltgid=\$(id -g docker) host "\${MOUNT_POINT}"
fi
EOF
chmod +x ${MNT}/var/lib/docker-root/start.sh

sync; sync; sync
