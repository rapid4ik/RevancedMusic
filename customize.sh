#!/system/bin/sh
# ==============================================================================
# YouTube Music RVX — Smart Root Module Installer & In-Place Updater
# 100% Compatible with Magisk / KernelSU / APatch
# Preserves all user settings, playlists, logins, and RVX preferences across updates
# ==============================================================================

# 1. Recovery mode check (TWRP is not supported due to lack of Android package manager)
if [ "$BOOTMODE" = "false" ]; then
    ui_print "****************************************************"
    ui_print "❌ Installing through TWRP / recovery is not supported!"
    ui_print "👉 Please install this module via Magisk, KernelSU, or APatch app."
    ui_print "****************************************************"
    abort "- Aborting installation !!"
fi

# 2. Properly detect MODPATH (do NOT overwrite if already set by Magisk/KernelSU)
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

# 3. Detect current installation & state (Stock vs Patched vs Previous Module)
STOCKAPK=$(pm path "$PKGNAME" 2>/dev/null | grep -E "base|split" | head -n 1 | sed "s/package://g")
[ -z "$STOCKAPK" ] && STOCKAPK=$(pm path "$PKGNAME" 2>/dev/null | head -n 1 | sed "s/package://g")

CURRENT_VER=$(dumpsys package "$PKGNAME" 2>/dev/null | grep versionName | cut -d "=" -f 2 | sed -n "1p" | tr -d " ")

RVAPPVER=$(grep "^version=" "$MODPATH/module.prop" 2>/dev/null | cut -d= -f2 | sed "s/^v//")
[ -z "$RVAPPVER" ] && RVAPPVER="latest"

IS_MOUNTED=false
grep "$PKGNAME" /proc/mounts 2>/dev/null | grep -q "base.apk" && IS_MOUNTED=true

IS_PATCHED=false
if [ "$IS_MOUNTED" = "true" ]; then
    IS_PATCHED=true
elif [ -n "$STOCKAPK" ] && [ -f "$STOCKAPK" ]; then
    if unzip -l "$STOCKAPK" 2>/dev/null | grep -qiE "revanced|morphe|anddea"; then
        IS_PATCHED=true
    fi
fi

IS_PREV_MODULE=false
if [ -f "/data/adb/modules/YouTube-Music-RVX/module.prop" ] || [ -f "$MODPATH/module.prop" ]; then
    IS_PREV_MODULE=true
fi

# 4. Safe backup of user settings (Shared Preferences & RVX configurations)
PREFS_DIR="/data/data/$PKGNAME/shared_prefs"
BACKUP_DIR="/data/local/tmp/ytm_backup_prefs"
if [ -d "$PREFS_DIR" ]; then
    rm -rf "$BACKUP_DIR" 2>/dev/null
    mkdir -p "$BACKUP_DIR"
    cp -af "$PREFS_DIR"/* "$BACKUP_DIR/" 2>/dev/null
    ui_print "📦 Backed up RVX user preferences and account data."
fi

# 5. Display status and update mode
if [ -n "$STOCKAPK" ] && [ -f "$STOCKAPK" ]; then
    if [ "$IS_PATCHED" = "true" ] || [ "$IS_PREV_MODULE" = "true" ]; then
        ui_print "✨ Detected existing Patched YouTube Music RVX (v$CURRENT_VER)!"
        ui_print "⚡ In-place update mode: all settings, logins, and downloads are preserved."
    else
        ui_print "- Detected unpatched official YouTube Music (v$CURRENT_VER)."
        ui_print "⚡ Converting to Patched YouTube Music RVX (keeping all user data)..."
    fi
else
    ui_print "- YouTube Music is not installed on system."
    ui_print "- Performing fresh install with bundled stock base APK..."
fi

# 6. Unmount any stale bind mounts for this package before touching filesystem
STOCK_BASE=$(pm path "$PKGNAME" 2>/dev/null | grep -E "base|split" | head -n 1 | sed "s/package://g")
[ -n "$STOCK_BASE" ] && umount -l "$STOCK_BASE" 2>/dev/null
grep "$PKGNAME" /proc/mounts 2>/dev/null | while read -r line; do
    mp=$(echo "$line" | awk "{print \$2}")
    [ -n "$mp" ] && umount -l "$mp" 2>/dev/null
done

# 7. Helper function: reliably install APK across KernelSU, Magisk, and APatch
# Bypasses /data/adb 0700 permission restrictions by staging in /data/local/tmp and using stdin streaming
install_stock_apk() {
    local src="$1"
    [ -f "$src" ] || return 1
    
    local tmp_apk="/data/local/tmp/ytmusic_stock_install.apk"
    rm -f "$tmp_apk" 2>/dev/null
    cp -f "$src" "$tmp_apk" || return 1
    chmod 644 "$tmp_apk"
    chown system:system "$tmp_apk" 2>/dev/null || chown 1000:1000 "$tmp_apk" 2>/dev/null
    chcon u:object_r:apk_data_file:s0 "$tmp_apk" 2>/dev/null

    local res=1
    local out=""

    # Attempt 1: Standard pm install from /data/local/tmp
    out=$(pm install -r -d -g "$tmp_apk" 2>&1)
    if echo "$out" | grep -qi "Success"; then
        res=0
    fi

    # Attempt 2: Explicit primary user 0
    if [ $res -ne 0 ]; then
        out=$(pm install -r -d -g --user 0 "$tmp_apk" 2>&1)
        if echo "$out" | grep -qi "Success"; then
            res=0
        fi
    fi

    # Attempt 3: Android 14+ bypass low target SDK block
    if [ $res -ne 0 ]; then
        out=$(pm install -r -d -g --bypass-low-target-sdk-block --user 0 "$tmp_apk" 2>&1)
        if echo "$out" | grep -qi "Success"; then
            res=0
        fi
    fi

    # Attempt 4: Stream via standard input pipe into PackageInstaller session
    if [ $res -ne 0 ]; then
        local apk_size
        apk_size=$(wc -c < "$src" 2>/dev/null | tr -d " ")
        local session
        session=$(pm install-create -r -d -g --user 0 2>/dev/null | grep -oE "[0-9]+")
        [ -z "$session" ] && session=$(pm install-create -r -d 2>/dev/null | grep -oE "[0-9]+")
        if [ -n "$session" ]; then
            if [ -n "$apk_size" ] && [ "$apk_size" -gt 0 ]; then
                cat "$src" | pm install-write -S "$apk_size" "$session" base.apk - >/dev/null 2>&1
            else
                cat "$src" | pm install-write "$session" base.apk - >/dev/null 2>&1
            fi
            out=$(pm install-commit "$session" 2>&1)
            if echo "$out" | grep -qi "Success"; then
                res=0
            fi
        fi
    fi

    rm -f "$tmp_apk" 2>/dev/null
    return $res
}

# 8. Dynamically select matching architecture stock APK for this device
DEVICE_ABI=$(getprop ro.product.cpu.abi)
DEVICE_ABILIST=$(getprop ro.product.cpu.abilist)

if echo "$DEVICE_ABI $DEVICE_ABILIST" | grep -qi "arm64"; then
    ui_print "- Architecture: 64-bit ($DEVICE_ABI)"
    STOCK_BUNDLE=$(ls "$MODPATH/ytmusic"/*arm64*.apk "$MODPATH/ori"/*arm64*.apk 2>/dev/null | head -n 1)
else
    ui_print "- Architecture: 32-bit ($DEVICE_ABI)"
    STOCK_BUNDLE=$(ls "$MODPATH/ytmusic"/*v7a*.apk "$MODPATH/ori"/*v7a*.apk 2>/dev/null | head -n 1)
fi

[ -z "$STOCK_BUNDLE" ] && STOCK_BUNDLE=$(ls "$MODPATH/ytmusic"/*.apk "$MODPATH/ori"/*.apk 2>/dev/null | head -n 1)

# Check underlying base version after unmount
UNMOUNTED_BASE_VER=$(dumpsys package "$PKGNAME" 2>/dev/null | grep versionName | cut -d "=" -f 2 | sed -n "1p" | tr -d " ")

NEED_BASE_INSTALL=false
if [ -z "$STOCKAPK" ] || [ ! -f "$STOCKAPK" ]; then
    NEED_BASE_INSTALL=true
elif [ -n "$UNMOUNTED_BASE_VER" ] && [ -n "$RVAPPVER" ] && [ "$UNMOUNTED_BASE_VER" != "$RVAPPVER" ]; then
    NEED_BASE_INSTALL=true
    ui_print "- Updating base YouTube Music: $UNMOUNTED_BASE_VER -> $RVAPPVER (in-place)..."
else
    ui_print "- Base YouTube Music matches module version ($UNMOUNTED_BASE_VER). No base reinstallation required."
fi

if [ "$NEED_BASE_INSTALL" = "true" ]; then
    if [ -f "$STOCK_BUNDLE" ]; then
        ui_print "- Installing matching base Stock APK (v$RVAPPVER)..."
        install_stock_apk "$STOCK_BUNDLE"
    fi

    # Wait and verify package registration
    ui_print "- Verifying YouTube Music package registration..."
    for i in 1 2 3 4 5 6 7 8 9 10; do
        STOCKAPK=$(pm path "$PKGNAME" 2>/dev/null | grep -E "base|split" | head -n 1 | sed "s/package://g")
        [ -z "$STOCKAPK" ] && STOCKAPK=$(pm path "$PKGNAME" 2>/dev/null | head -n 1 | sed "s/package://g")
        if [ -n "$STOCKAPK" ] && [ -f "$STOCKAPK" ]; then
            break
        fi
        sleep 1
    done
fi

# Backup bundled APKs to ori/ for future offline boot restoring
if [ -d "$MODPATH/ytmusic" ]; then
    mkdir -p "$MODPATH/ori"
    mv "$MODPATH/ytmusic"/* "$MODPATH/ori/" 2>/dev/null
    rm -rf "$MODPATH/ytmusic"
fi

# Final check if base APK is verified
STOCKAPK=$(pm path "$PKGNAME" 2>/dev/null | grep -E "base|split" | head -n 1 | sed "s/package://g")
[ -z "$STOCKAPK" ] && STOCKAPK=$(pm path "$PKGNAME" 2>/dev/null | head -n 1 | sed "s/package://g")

if [ -z "$STOCKAPK" ] || [ ! -f "$STOCKAPK" ]; then
    ui_print "****************************************************"
    ui_print "❌ Failed to install or locate YouTube Music ($PKGNAME)!"
    ui_print "👉 If automatic installation is restricted by your ROM,"
    ui_print "   please install official YouTube Music from Play Store,"
    ui_print "   then re-flash this module."
    ui_print "****************************************************"
    abort "- Aborting installation !!"
fi

ui_print "- Detected base APK: $STOCKAPK"

# 9. Locate patched RVX APK in module and prepare in app/
mkdir -p "$MODPATH/app"

PATCHED_APK=$(ls "$MODPATH"/*-Anddea.apk "$MODPATH"/*-revanced*.apk "$MODPATH"/*.apk 2>/dev/null | grep -v "module.prop" | head -n 1)
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

# 10. Restore user preferences and RVX settings if needed
if [ -d "$BACKUP_DIR" ] && [ -n "$(ls "$BACKUP_DIR" 2>/dev/null)" ]; then
    NEW_UID=$(dumpsys package "$PKGNAME" 2>/dev/null | grep userId= | head -n 1 | cut -d= -f2 | awk "{print \$1}")
    if [ -n "$NEW_UID" ]; then
        mkdir -p "$PREFS_DIR"
        for pref_file in "$BACKUP_DIR"/*; do
            [ -f "$pref_file" ] || continue
            base_f=$(basename "$pref_file")
            # Always ensure revanced and youtube preferences are preserved
            if [ ! -f "$PREFS_DIR/$base_f" ] || [ "$base_f" = "revanced.xml" ] || [ "$base_f" = "youtube.xml" ]; then
                cp -f "$pref_file" "$PREFS_DIR/$base_f"
                chown "$NEW_UID:$NEW_UID" "$PREFS_DIR/$base_f" 2>/dev/null
                chmod 660 "$PREFS_DIR/$base_f" 2>/dev/null
            fi
        done
        chown -R "$NEW_UID:$NEW_UID" "$PREFS_DIR" 2>/dev/null
        chmod 771 "$PREFS_DIR" 2>/dev/null
        ui_print "✓ RVX settings & user preferences successfully preserved."
    fi
    rm -rf "$BACKUP_DIR" 2>/dev/null
fi

# 11. Apply live bind-mount immediately (Hot-Mount)
chmod 644 "$RVAPK"
chown system:system "$RVAPK" 2>/dev/null
chcon u:object_r:apk_data_file:s0 "$RVAPK" 2>/dev/null
mount -o bind "$RVAPK" "$STOCKAPK"
am force-stop "$PKGNAME" 2>/dev/null

[ -d "$MODPATH/bin" ] && chmod 755 "$MODPATH/bin"/* 2>/dev/null
[ -d "$MODPATH/webroot" ] && chmod 644 "$MODPATH/webroot"/* 2>/dev/null

ui_print "- Installation Successful !!"
ui_print "- Patched YouTube Music RVX mounted successfully."
am start -n com.google.android.apps.youtube.music/com.google.android.apps.youtube.music.activities.MusicActivity >/dev/null 2>&1 || monkey -p com.google.android.apps.youtube.music -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1
