SHELL:=/bin/bash

LOG:=debug.log
OVMFBASE:=edk2/Build/OvmfX64/DEBUG_GCC5/
OVMFCODE:=$(OVMFBASE)/FV/OVMF_CODE.fd
OVMFVARS:=$(OVMFBASE)/FV/OVMF_VARS.fd
QEMU:=qemu-system-x86_64

QEMUFLAGS:=-drive if=pflash,format=raw,read-only=on,file=$(OVMFCODE) \
          -drive if=pflash,format=raw,file=$(OVMFVARS) \
          -debugcon file:$(LOG) -global isa-debugcon.iobase=0x402 \
          -serial stdio \
          -nographic \
          -nodefaults
run:
	$(QEMU) $(QEMUFLAGS)

debug:
	$(QEMU) $(QEMUFLAGS) -s -S

# TDOD
# build-edk: edk2/

peinfo:
	$(shell git update --init --recursive)

peinfo/peinfo: peinfo
	$(shell make -C peinfo)

.PHONY: run debug

