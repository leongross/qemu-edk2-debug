#!/usr/bin/env python3

import sys
from pathlib import Path
from dataclasses import dataclass
import subprocess

@dataclass
class efi_info:
    def __init__(self, _base:int, _name:str, _addr:int, _syms:str):
        self.base:int = _base
        self.name:str = _name
        self.addr:int = _addr
        self.text:int = _base + _addr
        self.syms:str = _syms

    def __str__(self) -> str:
        return f"base = {hex(self.base)}, name = {self.name}, addr = {hex(self.addr)}, text = {hex(self.text)}, syms = {self.syms}"

def main():
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <build_folder>")
        sys.exit(1)

    path_peinfo = Path('peinfo/peinfo')
    path_build = Path(sys.argv[1])
    path_log = Path("debug.log")
    path_efi_out = Path(".gdbinit")
    
    efi_objects = []


    with open(path_log, "r") as handle_log:
        list_log = handle_log.readlines()
        if (list_log == []):
            print(f"{path_log} may not be empty!")
            sys.exit(1)

        for line in list_log:
            line = line.strip("\n")
            line_split = line.split(" ")

            if line_split[0] == "Loading" and line_split[-1].split(".")[-1] == "efi":
                efi_base = int(line_split[3], base=16)
                efi_name = line_split[5]
                efi_addr = 0x00

                if Path(path_build/efi_name).exists():
                    pei_out = subprocess.getoutput(f"{str(path_peinfo)} {str(path_build/efi_name)}").split("\n")
                    try:
                        efi_addr = int(pei_out[pei_out.index("Name: .text") + 2].split(" ")[-1], 16)

                        efi_objects.append(efi_info(efi_base, efi_name, efi_addr, efi_name.replace(".efi", ".debug")))

                    except ValueError:
                        print(f"File {path_build/efi_name} has no text section?")

    print(f"[*] Parsed {len(efi_objects)} efi files")
    added = efi_to_file(path_efi_out, efi_objects, path_build)
    print(f"[*] Added {added} new config lines")

def efi_to_file(file: Path, efi_infos: list[efi_info], build_dir: Path) -> int:
    current_config = []
    added = 0

    try:
        with open(file, "r") as handle_file_read:
            current_config = handle_file_read.readlines()
    except: FileNotFoundError

    with open(file, "a+") as handle_file_append:
        for efi in efi_infos:
            duplicate = False
            for current_config_line in current_config:
                if efi.syms in current_config_line:
                    duplicate = True
                    break

                if duplicate:
                    break

            if not duplicate:
                handle_file_append.write(f"add-symbol-file {str(build_dir)}/{efi.syms} {hex(efi.text)}\n")
                added += 1

    return added

if __name__ == "__main__":
    main()
