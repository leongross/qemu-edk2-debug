#!/usr/bin/env bash

gdbinit=$(realpath ~/.gdbinit)
gdbinit_local=$(realpath .gdbinit)

if ! $(grep -q "set auto-load safe-path $(pwd)" "$gdbinit");then
    echo "[*] Could not find '$(pwd)' as 'auto-load safe-path' in '"$gdbinit"'. Adding it"
    echo "set auto-load safe-path $(pwd)" >> "$gdbinit"
fi

# if [ -f "$gdbinit_local" ]; then
#     echo "b *_ModuleEntryPoint" >> "$gdbinit_local"
#     echo "target remote :1234" >> "$gdbinit_local"
# fi

