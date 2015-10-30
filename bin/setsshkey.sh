#!/bin/sh
set -e

pushd `dirname $0` > /dev/null
HERE=`pwd`
popd > /dev/null

cd "${HERE}/.."

SSH_KEY=.ssh/id_rsa
IP_ADDR=$(make ip)
USERNAME=$(make -sC vm username)
PASSWORD=$(make -sC vm password)
SSH_ARGS=$(make -sC vm ssh_args)

mkdir -p .ssh

if [ ! -f "${SSH_KEY}" ]; then
  ssh-keygen -t rsa -b 2048 -P "" -f "${SSH_KEY}"
fi

make ssh -- mkdir -p .ssh >/dev/null 2>&1
make ssh -- chmod 0700 .ssh >/dev/null 2>&1

expect -c " \
  spawn -noecho scp ${SSH_ARGS} ${SSH_KEY}.pub ${USERNAME}@${IP_ADDR}:.ssh/authorized_keys; \
  expect \"(yes/no)?\" { send \"yes\r\"; exp_continue; } \"password:\" { send \"${PASSWORD}\r\"; }; \
  interact; \
"

make ssh -- chmod 0600 .ssh/authorized_keys >/dev/null 2>&1
