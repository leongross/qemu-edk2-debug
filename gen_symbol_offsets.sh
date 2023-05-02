#!/bin/bash

LOG="debug.log"
BUILD="edk2/Build/OvmfX64/DEBUG_GCC5/X64"
PEINFO="peinfo/peinfo"

cat ${LOG} | grep Loading | grep -i efi | while read LINE; do
  BASE="`echo ${LINE} | cut -d " " -f4`"
  NAME="`echo ${LINE} | cut -d " " -f6 | tr -d "[:cntrl:]"`"
  ADDR="`${PEINFO} ${BUILD}/${NAME} \
        | grep -A 5 text | grep VirtualAddress | cut -d " " -f2`"
  TEXT="`python -c "print(hex(${BASE} + ${ADDR}))"`"
  SYMS="`echo ${NAME} | sed -e "s/\.efi/\.debug/g"`"
  echo "add-symbol-file ${BUILD}/${SYMS} ${TEXT}" >> .gdbinit
done

