#!/system/bin/sh
# ==============================================================================
# YouTube Music RVX — Manager Action
# 100% Compatible with Magisk / KernelSU / APatch
# ==============================================================================

MODPATH=${0%/*}
[ -d "$MODPATH/app" ] || MODPATH="/data/adb/modules/YouTube-Music-RVX"

# Execute Native Rust Core if compiled binary is present
if [ -f "$MODPATH/bin/rvx-daemon" ]; then
	chmod 755 "$MODPATH/bin/rvx-daemon" 2>/dev/null
	exec "$MODPATH/bin/rvx-daemon" action --modpath "$MODPATH" "$@"
fi

# Fallback POSIX Routine
PKGNAME="com.google.android.apps.youtube.music"
RV_APK=$(ls "$MODPATH/app"/YouTubeMusicRevanced-*.apk 2>/dev/null | head -n 1)
STOCKAPK=$(pm path "$PKGNAME" 2>/dev/null | grep -E 'base|split' | head -n 1 | sed 's/package://g')
[ -z "$STOCKAPK" ] && STOCKAPK=$(pm path "$PKGNAME" 2>/dev/null | head -n 1 | sed 's/package://g')

if [ -f "$RV_APK" ] && [ -n "$STOCKAPK" ]; then
	chmod 644 "$RV_APK"
	chown system:system "$RV_APK" 2>/dev/null
	chcon u:object_r:apk_data_file:s0 "$RV_APK" 2>/dev/null
	mount -o bind "$RV_APK" "$STOCKAPK"
	am force-stop "$PKGNAME" 2>/dev/null
fi

am start -n com.google.android.apps.youtube.music/com.google.android.apps.youtube.music.activities.MusicActivity >/dev/null 2>&1
