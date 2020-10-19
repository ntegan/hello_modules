#!/bin/bash
KERNEL=linux/arch/$(uname -m)/boot/bzImage
KERNEL=/boot/vmlinuz-linux
INITRAMFS=mkroot/root.cpio.gz

[ ! -f $KERNEL ] && echo "Uh oh, no kernel found at $KERNEL" && exit 1
[ ! -f $INITRAMFS ] && echo "Uh oh, no rootfs found at $INITRAMFS" && exit 2

# Special thanks to Landley for his mkroot project

qemu-system-x86_64 \
    -no-reboot \
    -nographic \
    -enable-kvm \
    -kernel $KERNEL \
    -initrd $INITRAMFS \
    -hda "a.qcow2" \
    -append "panic=1 console=ttyS0 root=/dev/hda"
    #-append "panic=1 console=ttyS0 init=/bin/sh "



