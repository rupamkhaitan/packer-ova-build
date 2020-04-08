#!/bin/bash

EULA=files/eula.txt
COMPRESSION=1 # 1 = least, 9 = most

set -e
if [ ! -z "${DEBUG}" ]; then
  set -x
fi

DEPENDENCIES=("ovftool")
for dep in "${DEPENDENCIES[@]}"
do
  if [ ! $(which ${dep}) ]; then
      echo "${dep} must be available."
      exit 1
  fi
done

print_usage () {
  echo "vmx-to-ova.sh - Converts a VMX to an OVA and deletes the VMX if successful."
  echo "-s=<source_vmx_folder>    The directory that contains the VMX."
}

while getopts "s:" opt; do
  case $opt in
    s) SOURCE_DIR=$OPTARG ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      print_usage
      exit 1
      ;;
  esac
done

if [[ -z "${SOURCE_DIR}" ]]; then
  echo "Source VMX folder must be specified"
  print_usage
  exit 1
fi

# Unfortunately ovftool doesn't work very well. It is not updating the ovf
#  file for the items below, and it doesn't allow us to add product info.
#    --memorySize:vm=2048 \
#    --numberOfCpus:vm=2 \
#    Compression breaks VirtualBox in Windows
#    --compress=${COMPRESSION} \

# --shaAlgorithm Use this option to condense with Secure Hash Algorithm (SHA)
#for manifest validation, digital signing, and OVF package
#creation. Either sha1 (SHA-1), sha256 (SHA-256), or sha512 (SHA-512).
#The default value is sha256

for vmx in "$SOURCE_DIR"/*.vmx; do
  name=$(basename "${vmx}" .vmx)
  ovftool \
    -dm=thin \
    --eula@=${EULA} \
    "${vmx}" "${SOURCE_DIR}/${name}.ova"
done

cd "${SOURCE_DIR}" && rm *.vmdk *.vmx *.vmxf *.vmsd *.nvram
