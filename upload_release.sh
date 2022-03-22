#!/bin/bash

set -e

BUILD_PATH=$(find /build/android/out/target/product/davinci/ -name "PixelExperience_davinci-*.zip" | head -n1)
BUILD_CHECKSUM_PATH=$(find /build/android/out/target/product/davinci/ -name "PixelExperience_davinci-*.zip.sha256sum" | head -n1)

if [ ! -f "$BUILD_PATH" ] || [ ! -f "$BUILD_CHECKSUM_PATH" ]; then
    echo "[e] Build wasn't successful. Discarding upload..."
    exit 1
fi

echo "[i] Uploading build checksum..."

scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i /build/keys/sourceforge_id_ed25519 $BUILD_CHECKSUM_PATH davincicodeos@frs.sourceforge.net:/home/frs/project/davincicodeos/testing
echo "[i] Uploading built rom... This might take a while."
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i /build/keys/sourceforge_id_ed25519 $BUILD_PATH davincicodeos@frs.sourceforge.net:/home/frs/project/davincicodeos/testing

echo "[i] Uploading done..."
