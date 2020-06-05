## Kernel Module Testing
This project includes a submodule for `linux` and `mkroot`.  
Scripts will be provided for automatically compiling linux,  
making a basic initramfs via `mkroot`,  
compiling basic kernel modules,  
and running them in an emulated system via QEMU.

## Clone me
```
# NOTE: this will clone linux which takes forever
git clone --recursive https://github.com/ntegan/hello_modules
```

## Usage
```
bash make.sh
```

#### Kernel
This will first build the linux kernel,  
should see output similar to this when done
```
Don't see a kernel, attempting to make it
linux makedefconfig with PID: 59685
Elapsed Time: 0 min 3 secs
*** Default configuration is based on 'x86_64_defconfig'
building linux kernel with PID: 60010
Elapsed Time: 19 min 7 secss
  GZIP    arch/x86/boot/compressed/vmlinux.bin.gz
```

#### Kernel Modules
This is where kernel modules will be built.  
They will then be placed inside of the initramfs  
for access in the minimal system.  
TODO:


#### Initramfs
This will then build a minimal rootfs/initramfs,  
should see output similar to this when done
```
Don't see a root/initramfs, making
making initramfs/rootfs PID: 127189
Elapsed Time: 0 min 49 secs
Trying libraries: crypt m
making the root archive
6152 blocks
```

### Booting
There is now a bootable linux system with  
kernel: `linux/arch/$(uname -m)/boot/bzImage`  
initramfs: `mkroot/output/host/root.cpio.gz`  

Run with  
```
bash runqemu.sh
```

#### Running modules
Modules should be in the `home` directory of the rootfs,  
```
Type exit when done.
/ # cd
/home # ls
hello.ko
/home # insmod hello.ko 
[   13.296718] hello, world
/home # 
```




