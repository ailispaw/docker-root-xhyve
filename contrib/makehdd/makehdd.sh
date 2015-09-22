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

if cat /proc/cmdline | grep "docker-root.nfsroot=" >/dev/null; then
  NFS_ROOT=\$(cat /proc/cmdline | sed 's/.*docker-root.nfsroot="\(.*\)".*/\1/')
fi
NFS_ROOT=\${NFS_ROOT:-/Users}

MOUNT_POINT=\${NFS_ROOT}

GW_IP=\$(ip route get 8.8.8.8 | awk 'NR==1 {print \$3}')
if [ -n "\${GW_IP}" ]; then
  mkdir -p \${MOUNT_POINT}
  umount \${MOUNT_POINT}
  mount "\${GW_IP}:\${NFS_ROOT}" \${MOUNT_POINT} -o rw,async,noatime,rsize=32768,wsize=32768,nolock,vers=3
fi
EOF
chmod +x ${MNT}/var/lib/docker-root/start.sh

sync; sync; sync
