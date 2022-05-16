#!/bin/bash

#######################################
# Extremely simple build script to
#       build DavinciCodeOS
# error handling is not yet done,
#    manual review is required
#######################################

set -e

BUILDER_USER="leonardo"
BUILDER_EMAIL="not@existing.org"
CACHE_SIZE="100GB"
BUILD_TYPE="user"
THREAD_COUNT=$(nproc --all)
UPLOAD_TO_SF=true

mkdir -p android
cd android

echo "[i] Setting up git credentials and properties..."

git config --global user.name $BUILDER_USER
git config --global user.email $BUILDER_EMAIL

git config --global color.ui true # see https://groups.google.com/g/repo-discuss/c/T_JouBm-vBU

echo "[i] Setting up ccache..."

export USE_CCACHE=1
export CCACHE_EXEC=$(which ccache)
mkdir -p /build/ccache
export CCACHE_DIR="/build/ccache"
ccache -M $CACHE_SIZE

echo "[i] Initializing PE repository..."

repo init -u https://github.com/PixelExperience/manifest -b twelve-plus

echo "[i] Creating device specific manifests"

mkdir -p .repo/local_manifests
cp /build/local_manifest.xml .repo/local_manifests/

echo "[i] Fetching sources, hang tight... This might take a while."
# when pulling sources with more than 16 threads, 429 errors occur often, 16 seems to be fine
repo sync -c --jobs-network=$(( $THREAD_COUNT < 16 ? $THREAD_COUNT : 16 )) -j$THREAD_COUNT --jobs-checkout=$THREAD_COUNT --force-sync --no-clone-bundle --no-tags

/build/apply.sh dcos

echo "[i] Setting build environment..."

source build/envsetup.sh

lunch aosp_davinci-$BUILD_TYPE

echo "[i] Regenerating ABI reference dumps for O3 build..."
development/vndk/tools/header-checker/utils/create_reference_dumps.py -products aosp_davinci --build-variant $BUILD_TYPE

echo "[i] Starting build process for DavinciCodeOS..."

make -j$THREAD_COUNT bacon

echo "[i] Done building DavinciCodeOS!"

/build/apply.sh dcosx

echo "[i] Starting build process for DavinciCodeOSX..."

lunch aosp_davinci-$BUILD_TYPE

make -j$THREAD_COUNT bacon

if [ "$UPLOAD_TO_SF" = true ]; then
    bash /build/upload_release.sh
fi
