#!/bin/sh
set -e

pushd `dirname $0` > /dev/null
HERE=`pwd`
popd > /dev/null

cd "${HERE}/.."

SSH_KEY=.ssh/id_rsa
IP_ADDR=$(make ip)
USERNAME=$(make -sC vm username)
SSH_ARGS=$(make -sC vm ssh_args)

ssh ${USERNAME}@${IP_ADDR} -i "${SSH_KEY}" ${SSH_ARGS} "$@"
