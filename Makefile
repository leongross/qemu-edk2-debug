SHELL:=/bin/bash

LOG:=debug.log
OVMFBASE:=edk2/Build/OvmfX64/DEBUG_GCC5/
OVMFCODE:=$(OVMFBASE)/FV/OVMF_CODE.fd
OVMFVARS:=$(OVMFBASE)/FV/OVMF_VARS.fd
OVMFBIOS:=$(OVMFBASE)/FV/OVMF.fd  # edk2/Build/OvmfX64/DEBUG_GCC5/FV/OVMF.fd


QEMU:=qemu-system-x86_64
PEINFO:=peinfo/peinfo
LOG_COLLECTION_TIMEOUT_SEC=10
GDBINIT_LOCAL=$(shell realpath .gdbinit)

QEMUFLAGS:=-drive if=pflash,format=raw,read-only=on,file=$(OVMFCODE) \
          -drive if=pflash,format=raw,file=$(OVMFVARS) \
          -debugcon file:$(LOG) -global isa-debugcon.iobase=0x402 \
          -serial stdio \
          -nographic \
          -nodefaults

# qemu-system-x86_64 --bios ~/lib/edk2/Build/OvmfX64/DEBUG_GCC5/FV/OVMF.fd --enable-kvm --net none -serial mon:stdio -s
QEMUFLAGS_RUN=--bios $(OVMFBIOS) \
			  --enable-kvm \
			  --net none \
			  -serial mon:stdio \
			  -s 
run:
	$(QEMU) $(QEMUFLAGS_RUN)

$(LOG):
	@echo "Starting log generation ($LOG_COLLECTION_TIMEOUT_SEC sec)"
	-timeout $(LOG_COLLECTION_TIMEOUT_SEC) $(QEMU) $(QEMUFLAGS)
	@echo "Stopped log generation"

debug: $(GDBINIT_LOCAL)
	@echo "[*] Attach to the ruinning gdb session with 'target'"
	$(QEMU) $(QEMUFLAGS) -s -S

peinfo:
	$(shell git update --init --recursive)

$(PEINFO): peinfo
	$(shell make -C peinfo)


$(GDBINIT_LOCAL): $(LOG) $(PEINFO)
	./gen_symbol_offsets.sh
	./setup_gdbinit.sh

# TDOD
# build-edk: edk2/

.PHONY: run debug clean

clean:
	-rm $(GDBINIT_LOCAL) $(LOG)
	-make -C edk2/ clean
