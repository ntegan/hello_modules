#!/bin/bash











mkdir output 1>/dev/null 2>/dev/null
# For each directory here, make
for i in *
do
    [ ! -d "$i" ] && continue
    [ "$i" == "output" ] && continue
    A=output/$i.out
    B=output/$i.err
    rm -f $A $B
    make -C $i 1>$A 2>$B &&
        cp $i/*.ko . &&
        make -C $i clean 1>/dev/null 2>/dev/null
done
