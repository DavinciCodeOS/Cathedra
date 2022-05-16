#!/bin/bash

SCRIPT_PATH=$(realpath $0)
CATHEDRA_PATH=$(dirname $SCRIPT_PATH)
PATCH_TYPE=$1
BASE_BUILD_DIR=$(pwd)

case "$PATCH_TYPE" in
	dcos | dcosx) echo "[i] Applying patches for $PATCH_TYPE" ;;
	*) echo "[e] $PATCH_TYPE is not a valid patch type, use dcos or dcosx" ;;
esac

if [ "$PATCH_TYPE" = "dcos" ] ; then
	echo "[i] Fetching latest Adrian Clang build for the kernel build..."
	# fresh clang toolchain by Adrian
	rm -rf prebuilts/clang/host/linux-x86/adrian-clang
	mkdir -p prebuilts/clang/host/linux-x86/adrian-clang
	cd prebuilts/clang/host/linux-x86/adrian-clang
	# in case of automated builds, please host a mirror
	curl https://ftp.travitia.xyz/clang/clang-latest.tar.xz | tar -xJ
	cd $BASE_BUILD_DIR

	echo "[i] Fetching is done. Patching sources..."

	cd system/core
	echo "[i] Applying 0001-Revert-libfs_avb-verifying-vbmeta-digest-early.patch"
	# the change would otherwise break vbmeta loading and result in no wlan, ril etc
	git am -3 $CATHEDRA_PATH/dcos/patches/0001-Revert-libfs_avb-verifying-vbmeta-digest-early.patch
	cd $BASE_BUILD_DIR

	cd vendor/aosp
	echo "[i] Applying 0002-vendor-davincicodeos-rebrand.patch"
	git am -3 $CATHEDRA_PATH/dcos/patches/0002-vendor-davincicodeos-rebrand.patch
	echo "[i] Applying 0005-vendor-fix-themedicons-path.patch"
	git am -3 $CATHEDRA_PATH/dcos/patches/0005-vendor-fix-themedicons-path.patch
	cd $BASE_BUILD_DIR

	cd build/tools
	echo "[i] Applying 0003-releasetools-rebrand-to-davincicodeos.patch"
	git am -3 $CATHEDRA_PATH/dcos/patches/0003-releasetools-rebrand-to-davincicodeos.patch
	cd $BASE_BUILD_DIR

	cd frameworks/base
	echo "[i] Applying 0004-PixelPropsUtils-Spoof-Pixel-XL-for-Snapchat.patch"
	git am -3 $CATHEDRA_PATH/dcos/patches/0004-PixelPropsUtils-Spoof-Pixel-XL-for-Snapchat.patch
	echo "[i] Applying 0007-core-jni-Switch-to-O3.patch"
	git am -3 $CATHEDRA_PATH/dcos/patches/0007-core-jni-Switch-to-O3.patch
	echo "[i] Applying 0009-base-whitelist-a-few-services-to-location-indicator.patch"
	git am -3 $CATHEDRA_PATH/dcos/patches/0009-base-whitelist-a-few-services-to-location-indicator.patch
	echo "[i] Applying 0010-add-google-search-and-google-location-history-to-location.patch"
	git am -3 $CATHEDRA_PATH/dcos/patches/0010-add-google-search-and-google-location-history-to-location.patch
	cd $BASE_BUILD_DIR

	cd build/soong
	echo "[i] Applying 0006-soong-clang-builds-with-O3.patch"
	git am -3 $CATHEDRA_PATH/dcos/patches/0006-soong-clang-builds-with-O3.patch
	cd $BASE_BUILD_DIR

	cd bionic
	echo "[i] Applying 0008-libc-switch-to-jemalloc-from-scudo.patch"
	git am -3 $CATHEDRA_PATH/dcos/patches/0008-libc-switch-to-jemalloc-from-scudo.patch
	cd $BASE_BUILD_DIR

	echo "[i] Installing boot animation..."
	cp -f $CATHEDRA_PATH/dcos/assets/bootanimation.zip vendor/aosp/bootanimation/bootanimation_1080.zip
fi

if [ "$PATCH_TYPE" = "dcosx" ] ; then
	echo "[i] Preparing DavinciCodeOSX branding..."
	sed -i "s|DavinciCodeOS_|DavinciCodeOSX_|" vendor/aosp/config/branding.mk
	sed -i "s|DavinciCodeOS|DavinciCodeOSX|" build/tools/releasetools/edify_generator.py

	cd frameworks/base
	echo "[i] Applying 0001-LockscreenCharging-squashed-1-3.patch"
	git am -3 $CATHEDRA_PATH/dcosx/patches/0001-LockscreenCharging-squashed-1-3.patch
	echo "[i] Applying 0004-KeyguardIndication-Fix-glitchy-charging-info-on-lock.patch"
	git am -3 $CATHEDRA_PATH/dcosx/patches/0004-KeyguardIndication-Fix-glitchy-charging-info-on-lock.patch
	echo "[i] Applying 0006-allow-toggling-screen-off-fod-1-2.patch"
	git am -3 $CATHEDRA_PATH/dcosx/patches/0006-allow-toggling-screen-off-fod-1-2.patch
	echo "[i] Applying 0008-Add-toggle-to-disable-battery-estimates-in-QS-1-2.patch"
	git am -3 $CATHEDRA_PATH/dcosx/patches/0008-Add-toggle-to-disable-battery-estimates-in-QS-1-2.patch
	echo "[i] Applying 0014-SystemUI-Require-unlocking-to-use-sensitive-QS-tiles.patch"
	git am -3 $CATHEDRA_PATH/dcosx/patches/0014-SystemUI-Require-unlocking-to-use-sensitive-QS-tiles.patch
	echo "[i] Applying 0015-base-introduce-app-lock-1-4.patch"
	git am -3 $CATHEDRA_PATH/dcosx/patches/0015-base-introduce-app-lock-1-4.patch
	cd $BASE_BUILD_DIR

	cd system/core
	echo "[i] Applying 0002-LockscreenCharging-squashed-2-3.patch"
	git am -3 $CATHEDRA_PATH/dcosx/patches/0002-LockscreenCharging-squashed-2-3.patch
	cd $BASE_BUILD_DIR

	cd vendor/aosp
	echo "[i] Applying 0018-vendor-introduce-app-lock-4-4.patch"
	git am -3 $CATHEDRA_PATH/dcosx/patches/0018-vendor-introduce-app-lock-4-4.patch
	cd $BASE_BUILD_DIR

	cd packages/apps/Settings
	echo "[i] Applying 0003-LockscreenCharging-squashed-3-3.patch"
	git am -3 $CATHEDRA_PATH/dcosx/patches/0003-LockscreenCharging-squashed-3-3.patch
	echo "[i] Applying 0007-allow-toggling-screen-off-fod-2-2.patch"
	git am -3 $CATHEDRA_PATH/dcosx/patches/0007-allow-toggling-screen-off-fod-2-2.patch
	echo "[i] Applying 0009-Add-toggle-to-disable-battery-estimates-in-QS-2-2.patch"
	git am -3 $CATHEDRA_PATH/dcosx/patches/0009-Add-toggle-to-disable-battery-estimates-in-QS-2-2.patch
	echo "[i] Applying 0017-Settings-introduce-app-lock-3-4.patch"
	git am -3 $CATHEDRA_PATH/dcosx/patches/0017-Settings-introduce-app-lock-3-4.patch
	cd $BASE_BUILD_DIR

	cd device/custom/sepolicy
	echo "[i] Applying 0016-sepolicy-introduce-app-lock-2-4.patch"
	git am -3 $CATHEDRA_PATH/dcosx/patches/0016-sepolicy-introduce-app-lock-2-4.patch
	cd $BASE_BUILD_DIR
fi
