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

NFS_ROOT=\$(cat /proc/cmdline | sed -n 's/^.*docker-root.nfsroot="\([^"]\+\)".*\$/\1/p')
SHARED_FOLDER=\$(cat /proc/cmdline | sed -n 's/^.*docker-root.shared_folder="\([^"]\+\)".*\$/\1/p')
: \${SHARED_FOLDER:="\${NFS_ROOT}"}

VIRTFS_UNAME=\$(cat /proc/cmdline | sed -n 's/^.*docker-root.virtfs_uname=\([^ ]\+\).*\$/\1/p')

GW_IP=\$(ip route get 8.8.8.8 | awk 'NR==1 {print \$3}')

if [ -n "\${SHARED_FOLDER}" ]; then
  MOUNT_POINT=\${SHARED_FOLDER}
  if mountpoint -q "\${MOUNT_POINT}"; then
    umount "\${MOUNT_POINT}"
  fi
  mkdir -p "\${MOUNT_POINT}"

  if [ -n "\${VIRTFS_UNAME}" ]; then
    mount -t 9p -o version=9p2000,trans=virtio,access=any,uname=\${VIRTFS_UNAME},dfltuid=\$(id -u docker),dfltgid=\$(id -g docker) host "\${MOUNT_POINT}"
  fi
  if ! mountpoint -q "\${MOUNT_POINT}"; then
    if [ -n "\${GW_IP}" ]; then
      mount "\${GW_IP}:\${MOUNT_POINT}" "\${MOUNT_POINT}" -o rw,async,noatime,rsize=32768,wsize=32768,nolock,vers=3,udp,actimeo=1
    fi
  fi
fi

if ! grep -q sntp /etc/cron/crontabs/root; then
  if [ -n "\${GW_IP}" ]; then
    echo '*/5 * * * * /usr/bin/sntp -4sSc' "\${GW_IP}" >> /etc/cron/crontabs/root
  fi
fi
EOF
chmod +x ${MNT}/var/lib/docker-root/start.sh

sync; sync; sync
