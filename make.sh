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
make_the_kernel() {
    # Save output in file so don't clog up this terminal
    mkdir output 1>/dev/null 2>/dev/null

    clear

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
        [ "$line" == "" ] && echo ""
        [ ! "$line" == "" ] && echo -e "\r\e[0K$line"
        sleep 1
        pid_exists $PID || break;
        re_wind 2
    done
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






#TODO: trap exit and kill parent and subprocesses of make things
# https://unix.stackexchange.com/questions/124127/kill-all-descendant-processes

# __  __       _       
#|  \/  | __ _(_)_ __  
#| |\/| |/ _` | | '_ \ 
#| |  | | (_| | | | | |
#|_|  |_|\__,_|_|_| |_|

have_kernel
RET=$?

[ $RET == 2 ] && make_the_kernel

                      
                                             
