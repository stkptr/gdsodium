#!/bin/sh

# Allows for forcing the C compiler and flags to something in a file
# put in /usr/local/bin and link your compiler's name to it:
# ln -s /usr/local/bin/cc.sh /usr/local/bin/cc

flagsf=/tmp/CCFLAGS
ccf=/tmp/CC

CC=/usr/bin/$(basename "$0")
if [ -f "$ccf" ]; then
    CC=$(cat "$ccf")
fi

CCFLAGS=""
if [ -f "$flagsf" ]; then
    CCFLAGS=$(cat "$flagsf")
fi

$CC $@ $CCFLAGS
