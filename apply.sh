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
	# fresh kernel building clang toolchain by Adrian
	rm -rf prebuilts/clang/host/linux-x86/adrian-clang
	mkdir -p prebuilts/clang/host/linux-x86/adrian-clang
	cd prebuilts/clang/host/linux-x86/adrian-clang
	# in case of automated builds, please host a mirror
	curl https://ftp.travitia.xyz/clang/clang-latest.tar.xz | tar -xJ
	cd $BASE_BUILD_DIR
	# Used to build the ROM
	rm -rf prebuilts/clang/host/linux-x86/adrian-clang-2
	mkdir -p prebuilts/clang/host/linux-x86/adrian-clang-2
	cd prebuilts/clang/host/linux-x86/adrian-clang-2
	curl https://ftp.travitia.xyz/clang/clang-r459371.tar.xz | tar -xJ
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
	echo "[i] Applying 0013-build-Flatten-APEXs-for-performance.patch"
	git am -3 $CATHEDRA_PATH/dcos/patches/0013-build-Flatten-APEXs-for-performance.patch
	echo "[i] Applying 0014-build-Set-ro.apex.updatable-false-in-product-propert.patch"
	git am -3 $CATHEDRA_PATH/dcos/patches/0014-build-Set-ro.apex.updatable-false-in-product-propert.patch
	cd $BASE_BUILD_DIR

	cd build/tools
	echo "[i] Applying 0003-releasetools-rebrand-to-davincicodeos.patch"
	git am -3 $CATHEDRA_PATH/dcos/patches/0003-releasetools-rebrand-to-davincicodeos.patch
	echo "[i] Applying 0011-build-add-erofs-support.patch"
	git am -3 $CATHEDRA_PATH/dcos/patches/0011-build-add-erofs-support.patch
	cd $BASE_BUILD_DIR

	cd frameworks/base
	echo "[i] Applying 0004-PixelPropsUtils-Spoof-Pixel-XL-for-Snapchat.patch"
	git am -3 $CATHEDRA_PATH/dcos/patches/0004-PixelPropsUtils-Spoof-Pixel-XL-for-Snapchat.patch
	echo "[i] Applying 0007-core-jni-Switch-to-O3.patch"
	git am -3 $CATHEDRA_PATH/dcos/patches/0007-core-jni-Switch-to-O3.patch
	echo "[i] Applying 0001-base-Clang-15-backports.patch"
	git am -3 $CATHEDRA_PATH/dcos/patches/clang-15/0001-base-Clang-15-backports.patch
	cd $BASE_BUILD_DIR

	cd build/soong
	echo "[i] Applying 0006-soong-clang-builds-with-O3.patch"
	git am -3 $CATHEDRA_PATH/dcos/patches/0006-soong-clang-builds-with-O3.patch
	echo "[i] Applying 0001-soong-Clang-14-15-Rust-1.62-backports.patch"
	git am -3 $CATHEDRA_PATH/dcos/patches/clang-15/0001-soong-Clang-14-15-Rust-1.62-backports.patch
	cd $BASE_BUILD_DIR

	cd bionic
	echo "[i] Applying 0008-libc-switch-to-jemalloc-from-scudo.patch"
	git am -3 $CATHEDRA_PATH/dcos/patches/0008-libc-switch-to-jemalloc-from-scudo.patch
	echo "[i] Applying 0001-Reland-Use-the-dynamic-table-instead-of-__rela-_iplt.patch"
	git am -3 $CATHEDRA_PATH/dcos/patches/clang-15/0001-Reland-Use-the-dynamic-table-instead-of-__rela-_iplt.patch
	cd $BASE_BUILD_DIR

	cd system/extras
	echo "[i] Applying 0012-add-fstab-entry-for-erofs-postinstall.patch"
	git am -3 $CATHEDRA_PATH/dcos/patches/0012-add-fstab-entry-for-erofs-postinstall.patch
	cd $BASE_BUILD_DIR

	cd prebuilts/clang/host/linux-x86
	echo "[i] Applying 0001-No-scudo-prebuilts-since-clang-r437112.patch"
	git am -3 $CATHEDRA_PATH/dcos/patches/clang-15/0001-No-scudo-prebuilts-since-clang-r437112.patch
	cd $BASE_BUILD_DIR

	cd build/make
	echo "[i] Applying 0001-make-Change-llvm-ar-format-to-be-format.patch"
	git am -3 $CATHEDRA_PATH/dcos/patches/clang-15/0001-make-Change-llvm-ar-format-to-be-format.patch
	cd $BASE_BUILD_DIR

	cd external/harfbuzz_ng
	echo "[i] Applying 0001-Do-not-use-pragma-diagnostics-as-a-workaround.patch"
	git am -3 $CATHEDRA_PATH/dcos/patches/clang-15/0001-Do-not-use-pragma-diagnostics-as-a-workaround.patch
	cd $BASE_BUILD_DIR

	cd system/netd
	echo "[i] Applying 0001-netd-Clang-15-backports.patch"
	git am -3 $CATHEDRA_PATH/dcos/patches/clang-15/0001-netd-Clang-15-backports.patch
	cd $BASE_BUILD_DIR

	cd external/mdnsresponder
	echo "[i] Applying 0001-Increase-keyword-buffer-size-to-11-since-we-read-up-.patch"
	git am -3 $CATHEDRA_PATH/dcos/patches/clang-15/0001-Increase-keyword-buffer-size-to-11-since-we-read-up-.patch
	cd $BASE_BUILD_DIR

	cd system/apex
	echo "[i] Applying 0001-Remove-redundant-using-statement.patch"
	git am -3 $CATHEDRA_PATH/dcos/patches/clang-15/0001-Remove-redundant-using-statement.patch
	cd $BASE_BUILD_DIR

	cd frameworks/native
	echo "[i] Applying 0001-libbinder-Remove-redundant-using-android.patch"
	git am -3 $CATHEDRA_PATH/dcos/patches/clang-15/0001-libbinder-Remove-redundant-using-android.patch
	echo "[i] Applying 0002-Fix-error-for-compiler-update.patch"
	git am -3 $CATHEDRA_PATH/dcos/patches/clang-15/0002-Fix-error-for-compiler-update.patch
	echo "[i] Applying 0003-binder-Fix-new-Rust-compiler-errors.patch"
	git am -3 $CATHEDRA_PATH/dcos/patches/clang-15/0003-binder-Fix-new-Rust-compiler-errors.patch
	cd $BASE_BUILD_DIR

	cd frameworks/av
	echo "[i] Applying 0001-MediaMetrics-fix-error-for-compiler-update.patch"
	git am -3 $CATHEDRA_PATH/dcos/patches/clang-15/0001-MediaMetrics-fix-error-for-compiler-update.patch
	echo "[i] Applying 0002-Suppress-ordered-compare-function-pointers-warning.patch"
	git am -3 $CATHEDRA_PATH/dcos/patches/clang-15/0002-Suppress-ordered-compare-function-pointers-warning.patch
	cd $BASE_BUILD_DIR

	cd art
	echo "[i] Applying 0001-Switch-to-an-assembler-macro-for-CFI_RESTORE_STATE_A.patch"
	git am -3 $CATHEDRA_PATH/dcos/patches/clang-15/0001-Switch-to-an-assembler-macro-for-CFI_RESTORE_STATE_A.patch
	echo "[i] Applying 0002-Suppress-three-counts-of-compiler-warnings-for-frame.patch"
	git am -3 $CATHEDRA_PATH/dcos/patches/clang-15/0002-Suppress-three-counts-of-compiler-warnings-for-frame.patch
	cd $BASE_BUILD_DIR

	cd packages/modules/DnsResolver
	echo "[i] Applying 0001-Sanitize-buffer-alignment-macros.patch"
	git am -3 $CATHEDRA_PATH/dcos/patches/clang-15/0001-Sanitize-buffer-alignment-macros.patch
	echo "[i] Applying 0002-DnsResolver-Remove-redundant-using-statements.patch"
	git am -3 $CATHEDRA_PATH/dcos/patches/clang-15/0002-DnsResolver-Remove-redundant-using-statements.patch
	cd $BASE_BUILD_DIR

	cd prebuilts/rust
	echo "[i] Applying 0001-rust-Backport-to-old-soong.patch"
	git am -3 $CATHEDRA_PATH/dcos/patches/clang-15/0001-rust-Backport-to-old-soong.patch
	cd $BASE_BUILD_DIR

	cd packages/modules/Connectivity
	echo "[i] Applying 0001-Fix-deprecated-error-limit-linker-flag.patch"
	git am -3 $CATHEDRA_PATH/dcos/patches/clang-15/0001-Fix-deprecated-error-limit-linker-flag.patch
	cd $BASE_BUILD_DIR

	cd system/bt
	echo "[i] Applying 0001-bt-Ignore-unused-value-warnings.patch"
	git am -3 $CATHEDRA_PATH/dcos/patches/clang-15/0001-bt-Ignore-unused-value-warnings.patch
	cd $BASE_BUILD_DIR

	cd system/security
	echo "[i] Applying 0001-Fix-warnings-in-preparation-for-Rust-1.62.0.patch"
	git am -3 $CATHEDRA_PATH/dcos/patches/clang-15/0001-Fix-warnings-in-preparation-for-Rust-1.62.0.patch
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
	echo "[i] Applying 0008-Add-toggle-to-disable-battery-estimates-in-QS-1-2.patch"
	git am -3 $CATHEDRA_PATH/dcosx/patches/0008-Add-toggle-to-disable-battery-estimates-in-QS-1-2.patch
	echo "[i] Applying 0014-SystemUI-Require-unlocking-to-use-sensitive-QS-tiles.patch"
	git am -3 $CATHEDRA_PATH/dcosx/patches/0014-SystemUI-Require-unlocking-to-use-sensitive-QS-tiles.patch
	echo "[i] Applying 0015-base-introduce-app-lock-1-4.patch"
	git am -3 $CATHEDRA_PATH/dcosx/patches/0015-base-introduce-app-lock-1-4.patch
	echo "[i] Applying 0019-pocket-introduce-pocket-judge.patch"
	git am -3 $CATHEDRA_PATH/dcosx/patches/0019-pocket-introduce-pocket-judge.patch
	echo "[i] Applying 0020-policy-introduce-pocket-lock.patch"
	git am -3 $CATHEDRA_PATH/dcosx/patches/0020-policy-introduce-pocket-lock.patch
	echo "[i] Applying 0021-PocketService-Adjust-light-sensor-rate-to-400ms.patch"
	git am -3 $CATHEDRA_PATH/dcosx/patches/0021-PocketService-Adjust-light-sensor-rate-to-400ms.patch
	echo "[i] Applying 0022-pocket-Adjust-sleep-timeout-for-pocket-lock-view-to-.patch"
	git am -3 $CATHEDRA_PATH/dcosx/patches/0022-pocket-Adjust-sleep-timeout-for-pocket-lock-view-to-.patch
	echo "[i] Applying 0023-Pocket-lock-improvements.patch"
	git am -3 $CATHEDRA_PATH/dcosx/patches/0023-Pocket-lock-improvements.patch
	echo "[i] Applying 0024-pocket-introduce-pocket-bridge.patch"
	git am -3 $CATHEDRA_PATH/dcosx/patches/0024-pocket-introduce-pocket-bridge.patch
	echo "[i] Applying 0025-Pocket-lock-Add-config_pocketModeSupported-overlay.patch"
	git am -3 $CATHEDRA_PATH/dcosx/patches/0025-Pocket-lock-Add-config_pocketModeSupported-overlay.patch
	echo "[i] Applying 0026-PocketLock-Make-using-light-sensor-optional.patch"
	git am -3 $CATHEDRA_PATH/dcosx/patches/0026-PocketLock-Make-using-light-sensor-optional.patch
	echo "[i] Applying 0028-SystemUI-Introduce-Data-Switch-QS-Tile.patch"
	git am -3 $CATHEDRA_PATH/dcosx/patches/0028-SystemUI-Introduce-Data-Switch-QS-Tile.patch
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
	echo "[i] Applying 0009-Add-toggle-to-disable-battery-estimates-in-QS-2-2.patch"
	git am -3 $CATHEDRA_PATH/dcosx/patches/0009-Add-toggle-to-disable-battery-estimates-in-QS-2-2.patch
	echo "[i] Applying 0017-Settings-introduce-app-lock-3-4.patch"
	git am -3 $CATHEDRA_PATH/dcosx/patches/0017-Settings-introduce-app-lock-3-4.patch
	echo "[i] Applying 0027-Settings-Add-pocket-lock-toggle.patch"
	git am -3 $CATHEDRA_PATH/dcosx/patches/0027-Settings-Add-pocket-lock-toggle.patch
	cd $BASE_BUILD_DIR

	cd device/custom/sepolicy
	echo "[i] Applying 0016-sepolicy-introduce-app-lock-2-4.patch"
	git am -3 $CATHEDRA_PATH/dcosx/patches/0016-sepolicy-introduce-app-lock-2-4.patch
	cd $BASE_BUILD_DIR
fi
