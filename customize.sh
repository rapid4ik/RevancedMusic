#!/system/bin/sh
# ==============================================================================
# YouTube Music RVX — Root Module Installer
# 100% Compatible with Magisk / KernelSU / APatch
# ==============================================================================

# 1. Properly detect MODPATH (do NOT overwrite if already set by Magisk/KernelSU)
if [ -z "$MODPATH" ] || [ ! -f "$MODPATH/module.prop" ]; then
    if [ -f "${0%/*}/module.prop" ]; then
        MODPATH="${0%/*}"
    elif [ -f "./module.prop" ]; then
        MODPATH="."
    fi
fi

PKGNAME="com.google.android.apps.youtube.music"
APPNAME="YouTube Music"

ui_print "- Installing YouTube Music RVX..."

# 2. Unmount any stale bind mounts for this package
STOCK_BASE=$(pm path "$PKGNAME" 2>/dev/null | grep -E 'base|split' | head -n 1 | sed 's/package://g')
[ -n "$STOCK_BASE" ] && umount -l "$STOCK_BASE" 2>/dev/null
grep "$PKGNAME" /proc/mounts 2>/dev/null | while read -r line; do
    mp=$(echo "$line" | awk '{print $2}')
    [ -n "$mp" ] && umount -l "$mp" 2>/dev/null
done

# 3. If Stock APK is bundled in the module, install/update it to ensure clean match
STOCK_BUNDLE=$(ls "$MODPATH/ytmusic"/*.apk 2>/dev/null | head -n 1)
if [ -f "$STOCK_BUNDLE" ]; then
    ui_print "- Found bundled Stock YouTube Music APK"
    ui_print "- Installing Stock APK to ensure version compatibility..."
    
    pm install -r -d "$STOCK_BUNDLE" >/dev/null 2>&1 || \
    pm install -r -d --user 0 "$STOCK_BUNDLE" >/dev/null 2>&1 || \
    (
        SESSION=$(pm install-create -r -d 2>/dev/null | grep -oE '[0-9]+')
        if [ -n "$SESSION" ]; then
            pm install-write "$SESSION" base.apk "$STOCK_BUNDLE" >/dev/null 2>&1
            pm install-commit "$SESSION" >/dev/null 2>&1
        fi
    )

    mkdir -p "$MODPATH/ori"
    mv "$MODPATH/ytmusic"/* "$MODPATH/ori/" 2>/dev/null
    rm -rf "$MODPATH/ytmusic"
fi

# 4. Verify that YouTube Music is installed on the device
STOCKAPK=$(pm path "$PKGNAME" 2>/dev/null | grep -E 'base|split' | head -n 1 | sed 's/package://g')
if [ -z "$STOCKAPK" ]; then
    STOCKAPK=$(pm path "$PKGNAME" 2>/dev/null | head -n 1 | sed 's/package://g')
fi

if [ -z "$STOCKAPK" ] || [ ! -f "$STOCKAPK" ]; then
    ui_print "****************************************************"
    ui_print "❌ YouTube Music ($PKGNAME) is not installed!"
    ui_print "👉 Please install official YouTube Music from Google Play Store,"
    ui_print "   then flash this module again."
    ui_print "****************************************************"
    abort "- Aborting installation !!"
fi

ui_print "- Detected base APK: $STOCKAPK"

# 5. Locate patched RVX APK in module and prepare in app/
mkdir -p "$MODPATH/app"

RVAPPVER=$(grep '^version=' "$MODPATH/module.prop" 2>/dev/null | cut -d= -f2 | sed 's/^v//')
[ -z "$RVAPPVER" ] && RVAPPVER="latest"

PATCHED_APK=$(ls "$MODPATH"/*-Anddea.apk "$MODPATH"/*.apk 2>/dev/null | grep -v "module.prop" | head -n 1)
RVAPK="$MODPATH/app/YouTubeMusicRevanced-${RVAPPVER}.apk"

if [ -n "$PATCHED_APK" ] && [ -f "$PATCHED_APK" ]; then
    mv "$PATCHED_APK" "$RVAPK"
fi

if [ ! -f "$RVAPK" ]; then
    RVAPK=$(ls "$MODPATH/app"/YouTubeMusicRevanced-*.apk 2>/dev/null | head -n 1)
fi

if [ ! -f "$RVAPK" ]; then
    ui_print "❌ Patched RVX APK not found in module!"
    abort "- Aborting installation !!"
fi

# 6. Apply live bind-mount immediately (Hot-Mount)
chmod 644 "$RVAPK"
chown system:system "$RVAPK" 2>/dev/null
chcon u:object_r:apk_data_file:s0 "$RVAPK" 2>/dev/null
mount -o bind "$RVAPK" "$STOCKAPK"
am force-stop "$PKGNAME" 2>/dev/null

[ -d "$MODPATH/bin" ] && chmod 755 "$MODPATH/bin"/* 2>/dev/null
[ -d "$MODPATH/webroot" ] && chmod 644 "$MODPATH/webroot"/* 2>/dev/null

ui_print "- Installation Successful !!"
ui_print "- Patched YouTube Music RVX mounted successfully."
am start -n com.google.android.apps.youtube.music/com.google.android.apps.youtube.music.activities.MusicActivity >/dev/null 2>&1
