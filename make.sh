#!/bin/bash
KERNEL=linux/arch/$(uname -m)/boot/bzImage

# _____                 _   _                 
#|  ___|   _ _ __   ___| |_(_) ___  _ __  ___ 
#| |_ | | | | '_ \ / __| __| |/ _ \| '_ \/ __|
#|  _|| |_| | | | | (__| |_| | (_) | | | \__ \
#|_|   \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
have_kernel() {
    MAKE_FILE="linux/Makefile"
    [ ! -f $MAKE_FILE ] && \
        echo "Uh oh, no Makefile '$MAKE_FILE'" &&
        return 1
    [ ! -f $KERNEL ] && return 2
}
have_root() {
    ROOT_DIR="mkroot/root"
    [ ! -d $ROOT_DIR ] && return 2
}
have_root_archive() {
    ROOT_FILE="mkroot/root.cpio.gz"
    [ ! -f $ROOT_FILE ] && return 2
}
make_the_kernel() {
    # Save output in file so don't clog up this terminal
    mkdir output 1>/dev/null 2>/dev/null


    # Make defconfig
    A=output/linux_defconfig.out
    B=output/linux_defconfig.err
    rm -f $A $B
    echo Don\'t see a kernel, attempting to make it
    sleep 1
    SECONDS=0
    make -j $(nproc) -C linux defconfig 1>$A 2>$B &
    PID=$!
    echo linux makedefconfig with PID: $PID
    while true
    do
        echo "Elapsed Time: $((SECONDS / 60)) min $((SECONDS % 60)) secs"
        line=$(tail -n 1 $A 2>/dev/null)
        line=$(crop_to_term_width "$line")
        [ "$line" == "" ] && echo ""
        [ ! "$line" == "" ] && echo -e "\r\e[0K$line"
        sleep 1
        pid_exists $PID || break;
        re_wind 2
    done

    # Make the kernel
    A=output/linux_make_kernel.out
    B=output/linux_make_kernel.err
    rm -f $A $B
    SECONDS=0
    make -j $(nproc) -C linux 1>$A 2>$B &
    PID=$!
    echo building linux kernel with PID: $PID
    while true
    do
        echo "Elapsed Time: $((SECONDS / 60)) min $((SECONDS % 60)) secs"
        line=$(tail -n 1 $A 2>/dev/null)
        line=$(crop_to_term_width "$line")
        [ "$line" == "" ] && echo ""
        [ ! "$line" == "" ] && echo -e "\r\e[0K$line"
        sleep 1
        pid_exists $PID || break;
        re_wind 2
    done
}
make_the_root() {
    (
    cd mkroot
    mkdir root
    cd root
    mkinitcpio -g root.img
    zcat root.img | while cpio -i; do :; done
    rm root.img
)
}
make_the_root_archive() {
    echo making the root archive
    (cd mkroot/root && 
        find . | cpio -o -H newc | gzip > ../root.cpio.gz)
}
pid_exists() {
    # https://stackoverflow.com/questions/5207013/bash-check-if-pid-exists
    [ "$1" == "" ] && return 1
    kill -s 0 $1 1>/dev/null 2>&1 && return 0
    return 2
}
re_wind() {
    # https://stackoverflow.com/questions/11283625/overwrite-last-line-on-terminal
    [ "$1" == "" ] && return
    echo -en "\e[$1A"
}
make_modules() {
    # Make modules in modules folder
    (cd modules && bash make_modules.sh)
    # Copy them to the rootfs
    mkdir -p mkroot/root/modds
    cp modules/*.ko mkroot/root/modds
}
crop_to_term_width() {
    # tput cols and lines
    NUM=$(tput cols)
    [ "$1" == "" ] && return
    echo "$1" | cut -c -$NUM
}






#TODO: trap exit and kill parent and subprocesses of make things
# https://unix.stackexchange.com/questions/124127/kill-all-descendant-processes

# __  __       _       
#|  \/  | __ _(_)_ __  
#| |\/| |/ _` | | '_ \ 
#| |  | | (_| | | | | |
#|_|  |_|\__,_|_|_| |_|

# Check if kernel is compiled, make it otherwise
have_kernel
RET=$?
[ $RET == 2 ] && make_the_kernel

# Check if have a root to build out initramfs with
have_root
RET=$?
[ $RET == 2 ] && make_the_root

# Make the kernel modules and put in rootfs
make_modules

# Make the root cpio.gz archive
#have_root_archive
#RET=$?
#[ $RET == 2 ] && make_the_root_archive
make_the_root_archive



                      
                                             
