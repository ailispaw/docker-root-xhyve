#!/bin/sh

NFS_ROOT=$(cat /proc/cmdline | sed -n 's/^.*docker-root.nfsroot="\([^"]\+\)".*$/\1/p')
SHARED_FOLDER=$(cat /proc/cmdline | sed -n 's/^.*docker-root.shared_folder="\([^"]\+\)".*$/\1/p')
: ${SHARED_FOLDER:="${NFS_ROOT}"}

VIRTFS_UNAME=$(cat /proc/cmdline | sed -n 's/^.*docker-root.virtfs_uname=\([^ ]\+\).*$/\1/p')

GW_IP=$(ip route get 8.8.8.8 | awk 'NR==1 {print $3}')

if [ -n "${SHARED_FOLDER}" ]; then
  MOUNT_POINT=${SHARED_FOLDER}
  if mountpoint -q "${MOUNT_POINT}"; then
    umount "${MOUNT_POINT}"
  fi
  mkdir -p "${MOUNT_POINT}"

  if [ -n "${VIRTFS_UNAME}" ]; then
    mount -t 9p -o version=9p2000,trans=virtio,access=any,uname=${VIRTFS_UNAME},dfltuid=$(id -u docker),dfltgid=$(id -g docker) host "${MOUNT_POINT}"
  fi
  if ! mountpoint -q "${MOUNT_POINT}"; then
    if [ -n "${GW_IP}" ]; then
      mount "${GW_IP}:${MOUNT_POINT}" "${MOUNT_POINT}" -o rw,async,noatime,rsize=32768,wsize=32768,nolock,vers=3,actimeo=1
    fi
  fi
fi

if ! grep -q sntp /etc/cron/crontabs/root; then
  if [ -n "${GW_IP}" ]; then
    echo '*/5 * * * * /usr/bin/sntp -4sSc' "${GW_IP}" >> /etc/cron/crontabs/root
  fi
fi
