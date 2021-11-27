#!/bin/bash
if [ ! -f "bc" ]; then
	wget "https://github.com/static-linux/static-binaries-i386/raw/master/bc-1.06.95.tar.gz" -O bc.tar.gz
	tar zxf bc.tar.gz --wildcards --no-anchored --strip-components 1 bc
fi

if [ ! -f "bash" ]; then
	wget "https://github.com/static-linux/static-binaries-i386/raw/master/bash-4.3.30.tar.gz" -O bash.tar.gz
	tar zxf bash.tar.gz --wildcards --no-anchored --strip-components 1 bash
fi

if [ ! -d "data" ]; then
    mkdir data
fi
