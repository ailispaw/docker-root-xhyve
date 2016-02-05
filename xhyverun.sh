#!/bin/sh

VBOX_VERSION=$(VBoxManage --version 2> /dev/null)
if [ -n "${VBOX_VERSION}" ]; then
  VBOX_VERSION=($(echo ${VBOX_VERSION} | tr -s '.' ' '))
  if [[ ${VBOX_VERSION[0]} -lt 5 ]]; then
    echo "Abort: KERNEL PANIC would occur with VirtualBox (< v5.0)." >&2
    exit 1
  fi
fi

: ${SHARED_FOLDER:="${1:-$HOME}"}

UNAME=${SUDO_USER:-$(id -un)}

KERNEL=$(make -C vm xhyve_kernel)
INITRD=$(make -C vm xhyve_initrd)
CMDLINE="$(make -C vm xhyve_cmdline) docker-root.shared_folder=\"${SHARED_FOLDER}\" docker-root.virtfs_uname=${UNAME}"
HDD=$(make -C vm xhyve_hdd)
UUID=$(make -C vm xhyve_uuid)

ACPI="-A"
MEM="-m 1G"
#SMP="-c 2"
NET="-s 2:0,virtio-net -s 3,virtio-9p,host=${SHARED_FOLDER}"
if [ -n "${HDD}" ]; then
  IMG_HDD="-s 4,virtio-blk,${HDD}"
fi
PCI_DEV="-s 0:0,hostbridge -s 31,lpc"
LPC_DEV="-l com1,stdio"

if [ -n "${UUID}" ]; then
  if [ -x "bin/uuid2mac" ]; then
    MAC_ADDRESS=$(bin/uuid2mac ${UUID})
    if [ -n "${MAC_ADDRESS}" ]; then
      echo "${MAC_ADDRESS}" > vm/.mac_address
    else
      exit 1
    fi
  fi
  UUID="-U ${UUID}"
fi

echo "Starting DockerRoot VM"
while [ 1 ]; do
  xhyve $ACPI $MEM $SMP $PCI_DEV $LPC_DEV $NET $IMG_CD $IMG_HDD $UUID -f kexec,$KERNEL,$INITRD,"$CMDLINE"
  if [ $? -ne 0 ]; then
    break
  fi
done

rm -f vm/.mac_address

exit 0
