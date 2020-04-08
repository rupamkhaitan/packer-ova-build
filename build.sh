#/bin/sh

#export PACKER_LOG=1

VERSION=1.0.0
HEADLESS=true
OUTPUT_DIR=/tmp/ova_${VERSION}
VMX_FILE=${OUTPUT_DIR}/ova_${VERSION}_amd64.vmx

BUILD_MEMORY=1024
DEPLOY_MEMORY=4096
CPU_COUNT=2

packer build \
  -var "build_memory=${BUILD_MEMORY}" \
  -var "headless=${HEADLESS}" \
  -var "iso_url=http://releases.ubuntu.com/16.04/ubuntu-16.04.6-server-amd64.iso" \
  -var "iso_checksum=ac8a79a86a905ebdc3ef3f5dd16b7360" \
  -var "type=ova" \
  -var "version=${VERSION}" \
  -var "output_dir=${OUTPUT_DIR}" \
$* ./create_vmx.json

# Convert the VMX to OVA format
echo "Converting VMX in ${OUTPUT_DIR} to OVA"

# Replace virtual machine parameters. We do this here instead of in Packer,
#  because otherwise the build requirements are too high.
sed -i "s/memsize = \"${BUILD_MEMORY}\"/memsize = \"${DEPLOY_MEMORY}\"/" ${VMX_FILE}
echo "numvcpus = \"${CPU_COUNT}\"" >> ${VMX_FILE}

scripts/vmx-to-ova.sh -s ${OUTPUT_DIR}

exit $?
