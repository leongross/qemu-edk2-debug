# qemu-edk2-debug

This repo is a slightly improved version of [this](https://retrage.github.io/2019/12/05/debugging-ovmf-en.html) blog article.
Further, it accumulates most of the necessary tools used for a proper debug setup.


## Generate EFI debug symbols

Run a clean test run of the EFI and dump the debug logs. This will reveal the correct virtual address mappings.
```sh
$ make debug.log
```

After building the log target, terminate it using <Cr-c>.
This will generate the logs and write them into the respective file.

## Debug Build

To launch the debug build, run the `debug` make target:

```sh
$ make debug
```

This will launch qemu whilst waiting for gdb to connect to start the remote debugging session.

## Attach a debugger

When the debug build is running, connect to the remote target from gdb:

```sh
$ gdb
(gdb) target remote :1234
```

If the previous step succeeded, gdb should automatically reload all the debug files.
This should add symbols, functions and even source identifiers.

## TODOs

- [ ] edk2 build using root Makefile
- [ ] Integrate python refactoring into Makefile
- [ ] Automatically launch a gdb session using tmux
