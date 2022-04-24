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

repo init -u https://github.com/PixelExperience/manifest -b twelve-plus

echo "[i] Creating device specific manifests"

mkdir -p .repo/local_manifests
cp /build/local_manifest.xml .repo/local_manifests/

echo "[i] Fetching sources, hang tight... This might take a while."
# when pulling sources with more than 16 threads, 429 errors occur often, 16 seems to be fine
repo sync -c --jobs-network=$(( $THREAD_COUNT < 16 ? $THREAD_COUNT : 16 )) -j$THREAD_COUNT --jobs-checkout=$THREAD_COUNT --force-sync --no-clone-bundle --no-tags

echo "[i] Fetching latest Adrian Clang build for the kernel build..."
# fresh clang toolchain by Adrian
mkdir -p prebuilts/clang/host/linux-x86/adrian-clang
cd prebuilts/clang/host/linux-x86/adrian-clang
# in case of automated builds, please host a mirror
curl https://ftp.travitia.xyz/clang/clang-latest.tar.xz | tar -xJ
cd /build/android

echo "[i] Cloning is done. Patching sources..."

cd system/core
echo "[i] Applying 0001-Revert-libfs_avb-verifying-vbmeta-digest-early.patch"
# the change would otherwise break vbmeta loading and result in no wlan, ril etc
git am -3 /build/dcos/patches/0001-Revert-libfs_avb-verifying-vbmeta-digest-early.patch
cd /build/android

cd vendor/aosp
echo "[i] Applying 0002-vendor-davincicodeos-rebrand.patch"
git am -3 /build/dcos/patches/0002-vendor-davincicodeos-rebrand.patch
echo "[i] Applying 0005-vendor-fix-themedicons-path.patch"
git am -3 /build/dcos/patches/0005-vendor-fix-themedicons-path.patch
cd /build/android

cd build/tools
echo "[i] Applying 0003-releasetools-rebrand-to-davincicodeos.patch"
git am -3 /build/dcos/patches/0003-releasetools-rebrand-to-davincicodeos.patch
cd /build/android

cd frameworks/base
echo "[i] Applying 0004-PixelPropsUtils-Spoof-Pixel-XL-for-Snapchat.patch"
git am -3 /build/dcos/patches/0004-PixelPropsUtils-Spoof-Pixel-XL-for-Snapchat.patch
echo "[i] Applying 0007-fix-mediaprojection-crashes.patch"
git am -3 /build/dcos/patches/0007-fix-mediaprojection-crashes.patch
cd /build/android

cd build/soong
echo "[i] Applying 0006-soong-clang-builds-with-O3.patch"
git am -3 /build/dcos/patches/0006-soong-clang-builds-with-O3.patch
cd /build/android

echo "[i] Setting build environment..."

source build/envsetup.sh

lunch aosp_davinci-$BUILD_TYPE

echo "[i] Regenerating ABI reference dumps for O3 build..."
development/vndk/tools/header-checker/utils/create_reference_dumps.py -products aosp_davinci --build-variant $BUILD_TYPE

echo "[i] Starting build process for DavinciCodeOS..."

make -j$THREAD_COUNT bacon

echo "[i] Done building DavinciCodeOS!"

echo "[i] Preparing DavinciCodeOSX branding..."
sed -i "s|DavinciCodeOS_|DavinciCodeOSX_|" vendor/aosp/config/branding.mk
sed -i "s|DavinciCodeOS|DavinciCodeOSX|" build/tools/releasetools/edify_generator.py

cd frameworks/base
echo "[i] Applying 0001-LockscreenCharging-squashed-1-3.patch"
git am -3 /build/dcosx/patches/0001-LockscreenCharging-squashed-1-3.patch
echo "[i] Applying 0004-KeyguardIndication-Fix-glitchy-charging-info-on-lock.patch"
git am -3 /build/dcosx/patches/0004-KeyguardIndication-Fix-glitchy-charging-info-on-lock.patch
echo "[i] Applying 0005-add-auto-brightness-button.patch"
git am -3 /build/dcosx/patches/0005-add-auto-brightness-button.patch
cd /build/android

cd system/core
echo "[i] Applying 0002-LockscreenCharging-squashed-2-3.patch"
git am -3 /build/dcosx/patches/0002-LockscreenCharging-squashed-2-3.patch
cd /build/android

cd packages/apps/Settings
echo "[i] Applying 0003-LockscreenCharging-squashed-3-3.patch"
git am -3 /build/dcosx/patches/0003-LockscreenCharging-squashed-3-3.patch
cd /build/android

echo "[i] Starting build process for DavinciCodeOSX..."

lunch aosp_davinci-$BUILD_TYPE

make -j$THREAD_COUNT bacon

if [ "$UPLOAD_TO_SF" = true ]; then
    bash /build/upload_release.sh
fi
