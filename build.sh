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
mkdir -p /build/ccache
export CCACHE_DIR="/build/ccache"
ccache -M $CACHE_SIZE

echo "[i] Initializing PE repository..."

repo init -u https://github.com/PixelExperience/manifest -b twelve

echo "[i] Creating device specific manifests"

mkdir -p .repo/local_manifests
cp /build/local_manifest.xml .repo/local_manifests/

echo "[i] Fetching sources, hang tight... This might take a while."
# when pulling sources with more than 16 threads, 429 errors occur often, 16 seems to be fine
repo sync -c --jobs-network=$(( $THREAD_COUNT < 16 ? $THREAD_COUNT : 16 )) -j$THREAD_COUNT --jobs-checkout=$THREAD_COUNT --force-sync --no-clone-bundle --no-tags

echo "[i] Cloning is done. Patching sources..."

cd system/core
echo "[i] Applying 0001-Revert-libfs_avb-verifying-vbmeta-digest-early.patch"
# the change would otherwise break vbmeta loading and result in no wlan, ril etc
git am -3 /build/patches/0001-Revert-libfs_avb-verifying-vbmeta-digest-early.patch
cd /build/android

cd vendor/aosp
echo "[i] Applying 0002-vendor-davincicodeos-rebrand.patch"
git am -3 /build/patches/0002-vendor-davincicodeos-rebrand.patch
cd /build/android

cd frameworks/base
echo "[i] Applying 0003-base-Add-three-fingers-swipe-to-screenshot-1-2.patch"
git am -3 /build/patches/0003-base-Add-three-fingers-swipe-to-screenshot-1-2.patch
echo "[i] Applying 0004-Allow-doubletap-longpress-power-to-toggle-torch-1-2.patch"
git am -3 /build/patches/0004-Allow-doubletap-longpress-power-to-toggle-torch-1-2.patch
echo "[i] Applying 0005-base-volume-key-music-control-1-2.patch"
git am -3 /build/patches/0005-base-volume-key-music-control-1-2.patch
echo "[i] Applying 0006-base-Add-api-to-take-screenshots.patch"
git am -3 /build/patches/0006-base-Add-api-to-take-screenshots.patch
echo "[i] Applying 0007-base-Add-custom-camera-utilities.patch"
git am -3 /build/patches/0007-base-Add-custom-camera-utilities.patch
cd /build/android

cd packages/apps/Settings
echo "[i] Applying 0008-Settings-Add-three-fingers-swipe-to-screenshot-2-2.patch"
git am -3 /build/patches/0008-Settings-Add-three-fingers-swipe-to-screenshot-2-2.patch
echo "[i] Applying 0009-Settings-Volume-key-music-control-2-2.patch"
git am -3 /build/patches/0009-Settings-Volume-key-music-control-2-2.patch
echo "[i] Applying 0010-Settings-Allow-doubletap-longpress-power-to-toggle-t.patch"
git am -3 /build/patches/0010-Settings-Allow-doubletap-longpress-power-to-toggle-t.patch
cd /build/android

cd external/faceunlock
echo "[i] Applying 0011-faceunlock-remove-conflicting-broken-dependencies.patch"
git am -3 /build/patches/0011-faceunlock-remove-conflicting-broken-dependencies.patch
cd /build/android

echo "[i] Setting build environment..."

source build/envsetup.sh

lunch aosp_davinci-$BUILD_TYPE

echo "[i] Starting build process..."

make -j$THREAD_COUNT bacon

echo "[i] Done"

if [ "$UPLOAD_TO_SF" = true ]; then
    bash /build/upload_release.sh
fi
