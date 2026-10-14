#!/system/bin/sh
# ==============================================================================
# YouTube Music RVX — POSIX Boot Service
# 100% Compatible with Magisk / KernelSU / APatch
# ==============================================================================

MODPATH=${0%/*}
[ -d "$MODPATH/app" ] || MODPATH="/data/adb/modules/YouTube-Music-RVX"

# Execute Native Rust Core if compiled binary is present
if [ -f "$MODPATH/bin/rvx-daemon" ]; then
	chmod 755 "$MODPATH/bin/rvx-daemon" 2>/dev/null
	exec "$MODPATH/bin/rvx-daemon" service --modpath "$MODPATH" "$@"
fi

# Fallback POSIX Routine
while [ "$(getprop sys.boot_completed)" != "1" ]; do sleep 1; done
[ -e /data/local/tmp/magisk ] && sleep 60 || sleep 3

PKGNAME="com.google.android.apps.youtube.music"
STOCKAPPVER=$(dumpsys package "$PKGNAME" 2>/dev/null | grep versionName | cut -d "=" -f 2 | sed -n '1p' | tr -d ' ')
RVAPK=$(ls "$MODPATH/app"/YouTubeMusicRevanced-*.apk 2>/dev/null | head -n 1)
RVAPPVER=$(basename "$RVAPK" .apk 2>/dev/null | cut -d "-" -f 2)

if [ -f "$RVAPK" ]; then
	if [ -n "$STOCKAPPVER" ] && [ -n "$RVAPPVER" ] && [ "$STOCKAPPVER" != "$RVAPPVER" ] && [ -d "$MODPATH/ori" ]; then
		for BASE_APK in "$MODPATH/ori"/*.apk; do
			if [ -f "$BASE_APK" ]; then
				TMP_RESTORE="/data/local/tmp/ytmusic_restore.apk"
				rm -f "$TMP_RESTORE" 2>/dev/null
				cp -f "$BASE_APK" "$TMP_RESTORE"
				chmod 644 "$TMP_RESTORE"
				chown system:system "$TMP_RESTORE" 2>/dev/null
				chcon u:object_r:apk_data_file:s0 "$TMP_RESTORE" 2>/dev/null
				pm install -r -d -g "$TMP_RESTORE" >/dev/null 2>&1 || \
				pm install -r -d -g --user 0 "$TMP_RESTORE" >/dev/null 2>&1
				rm -f "$TMP_RESTORE" 2>/dev/null
			fi
		done
	fi
	STOCKAPK=$(pm path "$PKGNAME" 2>/dev/null | grep -E 'base|split' | head -n 1 | sed 's/package://g')
	[ -z "$STOCKAPK" ] && STOCKAPK=$(pm path "$PKGNAME" 2>/dev/null | head -n 1 | sed 's/package://g')
	if [ -n "$STOCKAPK" ] && [ -f "$STOCKAPK" ]; then
		chmod 644 "$RVAPK"
		chown system:system "$RVAPK" 2>/dev/null
		chcon u:object_r:apk_data_file:s0 "$RVAPK" 2>/dev/null
		mount -o bind "$RVAPK" "$STOCKAPK"
		am force-stop "$PKGNAME" 2>/dev/null
	fi
fi

su -lp 2000 -c "cmd notification post -S bigtext -t 'YouTube Music RVX' tag '✅ YouTube Music RVX is ready to use...'" >/dev/null 2>&1
