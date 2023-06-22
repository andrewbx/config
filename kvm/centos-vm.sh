#!/usr/bin/env bash

# Variables

MEM_SIZE=2048
VCPUS=2
OS_VARIANT="rhl8.0"
OS_TYPE="linux"
ISO_FILE="CentOS-Stream-8-x86_64-latest-dvd1.iso"
VM_NAME=${1:?}
DISK_SIZE=10

# Build VM

sudo virt-install \
     --name ${VM_NAME} \
     --memory=${MEM_SIZE} \
     --vcpus=${VCPUS} \
     --os-type ${OS_TYPE} \
     --location ${ISO_FILE} \
     --disk size=${DISK_SIZE}  \
     --network bridge=virbr0 \
     --graphics=none \
     --os-variant=${OS_VARIANT} \
     --console pty,target_type=serial \
     --initrd-inject ks.cfg --extra-args "inst.ks=file:/centos-ks.cfg console=tty0 console=ttyS0,115200n8"
     #--extra-args="ks=http://172.16.254.1/centos-ks.cfg console=tty0 console=ttyS0,115200n8"
