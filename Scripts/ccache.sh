#!/bin/sh

source $(dirname $0)/ccache-config.sh

if [ -z "$DEVELOPER_DIR" ]; then
    
    CLANG=/usr/bin/clang
    
else
    
    CLANG=$DEVELOPER_DIR/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang
    
fi

if type -p ccache > /dev/null 2>&1; then
        
    exec ccache $CLANG "$@"
    
else
    
    exec $CLANG "$@"
    
fi
