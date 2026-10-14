#!/usr/bin/env python3
"""
Multi-Channel Architecture-Aware Downloader for Stock YouTube Music APK
Supports arm64-v8a, armeabi-v7a, and Universal multi-arch builds.
Channels:
1. GitHub Releases Mirror (j-hc/revanced-magisk-module) - High-speed, direct CDN
2. APKMirror Scraper with ABI row resolution
3. Archive.org & GitHub Releases Fallbacks
"""

import sys
import os
import re
import urllib.request
import json
import zipfile
import shutil

USER_AGENTS = [
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
    'Mozilla/5.0 (Linux; Android 14; Pixel 8 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36'
]

def validate_and_fix_apk(file_path):
    """
    Validates that the downloaded file contains AndroidManifest.xml.
    If the file is an APKM / Split bundle, automatically extracts base.apk.
    """
    if not os.path.exists(file_path) or os.path.getsize(file_path) < 15 * 1024 * 1024:
        return False

    try:
        with zipfile.ZipFile(file_path, 'r') as z:
            namelist = z.namelist()
            # 1. Standalone valid APK
            if 'AndroidManifest.xml' in namelist:
                size_mb = os.path.getsize(file_path) // (1024 * 1024)
                print(f"[+] Verification Successful: Valid Standalone APK detected ({size_mb} MB).")
                return True

            # 2. APKM / Split bundle
            if 'base.apk' in namelist:
                print("[*] Detected APKM bundle. Extracting base.apk...")
                temp_extract = file_path + ".base.apk"
                with z.open('base.apk') as src, open(temp_extract, 'wb') as dst:
                    while chunk := src.read(1024 * 1024):
                        dst.write(chunk)
                os.replace(temp_extract, file_path)
                size_mb = os.path.getsize(file_path) // (1024 * 1024)
                print(f"[+] Successfully extracted base.apk ({size_mb} MB).")
                return True
    except Exception as e:
        print(f"[-] ZIP/APK validation failed: {e}")

    return False

def try_download_raw(url, output_path):
    try:
        req = urllib.request.Request(url, headers={'User-Agent': USER_AGENTS[0]})
        with urllib.request.urlopen(req, timeout=45) as resp:
            if resp.status == 200:
                with open(output_path, 'wb') as f:
                    while chunk := resp.read(1024 * 1024):
                        f.write(chunk)
                return True
    except Exception as e:
        print(f"[-] Raw download error for {url}: {e}")
    return False

def try_download(url, output_path):
    if try_download_raw(url, output_path):
        return validate_and_fix_apk(output_path)
    return False

def fetch_from_github_mirror(version, arch, output_path):
    """
    Fetches official stock YouTube Music APK matching version and arch from
    j-hc/revanced-magisk-module releases.
    """
    try:
        api_url = "https://api.github.com/repos/j-hc/revanced-magisk-module/releases"
        req = urllib.request.Request(api_url, headers={'User-Agent': USER_AGENTS[0]})
        with urllib.request.urlopen(req, timeout=15) as resp:
            releases = json.loads(resp.read().decode())

        norm_arch = "arm64-v8a" if ("64" in arch) else "arm-v7a"
        target_name_part = f"music-morphe-module-v{version}-{norm_arch}"

        for rel in releases:
            for asset in rel.get('assets', []):
                name = asset.get('name', '')
                if target_name_part in name and name.endswith('.zip'):
                    download_url = asset.get('browser_download_url')
                    print(f"[*] Found GitHub release mirror ({norm_arch}): {name}")
                    temp_zip = output_path + f".{norm_arch}.zip"
                    if try_download_raw(download_url, temp_zip):
                        with zipfile.ZipFile(temp_zip, 'r') as z:
                            if 'stock/base.apk' in z.namelist():
                                with z.open('stock/base.apk') as src, open(output_path, 'wb') as dst:
                                    while chunk := src.read(1024 * 1024):
                                        dst.write(chunk)
                                if os.path.exists(temp_zip):
                                    os.remove(temp_zip)
                                if validate_and_fix_apk(output_path):
                                    return True
                        if os.path.exists(temp_zip):
                            os.remove(temp_zip)
    except Exception as e:
        print(f"[-] GitHub mirror lookup failed for {arch}: {e}")
    return False

def scrape_apkmirror(version, output_path, target_arch="arm64-v8a"):
    v_slug = version.replace('.', '-')
    try:
        import requests
        from bs4 import BeautifulSoup
        s = requests.Session()
        s.headers.update({'User-Agent': USER_AGENTS[0]})

        url = f"https://www.apkmirror.com/apk/google-inc/youtube-music/youtube-music-{v_slug}-release/"
        print(f"[*] Checking APKMirror for {target_arch}: {url}")
        res = s.get(url, timeout=20)
        if res.status_code != 200:
            return False

        soup = BeautifulSoup(res.text, 'html.parser')
        rows = soup.find_all('div', class_='table-row')

        arm64_link = None
        arm32_link = None
        universal_link = None
        any_link = None
        bundle_link = None

        for row in rows:
            badge = row.find('span', class_='apkm-badge')
            link = row.find('a', class_='accent_color')
            if badge and link and 'href' in link.attrs:
                badge_text = badge.text.strip().upper()
                full_href = "https://www.apkmirror.com" + link['href']
                row_text = row.get_text().lower()

                if badge_text == 'APK':
                    if 'arm64' in row_text or 'arm64-v8a' in row_text:
                        if not arm64_link:
                            arm64_link = full_href
                    elif 'armeabi' in row_text or 'v7a' in row_text:
                        if not arm32_link:
                            arm32_link = full_href
                    elif 'universal' in row_text:
                        if not universal_link:
                            universal_link = full_href
                    if not any_link:
                        any_link = full_href
                elif badge_text == 'BUNDLE' and not bundle_link:
                    bundle_link = full_href

        if "64" in target_arch:
            chosen_link = arm64_link or universal_link or any_link or bundle_link
        elif "7" in target_arch or "32" in target_arch:
            chosen_link = arm32_link or universal_link or any_link or bundle_link
        else:
            chosen_link = arm64_link or arm32_link or universal_link or any_link or bundle_link

        if not chosen_link:
            return False

        print(f"[*] Fetching download page: {chosen_link}")
        res2 = s.get(chosen_link, timeout=20)
        soup2 = BeautifulSoup(res2.text, 'html.parser')

        dl_btn = soup2.find('a', class_='downloadButton')
        if not dl_btn:
            return False

        final_page = "https://www.apkmirror.com" + dl_btn['href']
        res3 = s.get(final_page, timeout=20)
        soup3 = BeautifulSoup(res3.text, 'html.parser')

        raw_link = soup3.find('a', rel='nofollow')
        if not raw_link or 'href' not in raw_link.attrs:
            return False

        file_url = "https://www.apkmirror.com" + raw_link['href']
        print(f"[*] Downloading file from: {file_url}")
        with s.get(file_url, stream=True, timeout=90) as r:
            r.raise_for_status()
            with open(output_path, 'wb') as f:
                for chunk in r.iter_content(chunk_size=1024*1024):
                    f.write(chunk)

        return validate_and_fix_apk(output_path)
    except Exception as e:
        print(f"[-] Scraper failed: {e}")
        return False

def merge_native_libraries(arm64_apk, arm32_apk, universal_output):
    """
    Creates a Universal multi-arch APK by combining arm64-v8a and armeabi-v7a .so libs.
    """
    print(f"[*] Creating multi-arch Universal Stock APK from {arm64_apk} and {arm32_apk}...")
    shutil.copyfile(arm64_apk, universal_output)
    with zipfile.ZipFile(arm32_apk, 'r') as src, zipfile.ZipFile(universal_output, 'a') as dst:
        existing = set(dst.namelist())
        for item in src.infolist():
            if item.filename.startswith('lib/armeabi-v7a/') and item.filename not in existing:
                dst.writestr(item, src.read(item.filename))
    size_mb = os.path.getsize(universal_output) // (1024 * 1024)
    print(f"[+] Successfully merged Universal APK ({size_mb} MB): {universal_output}")
    return True

def download_single(version, output_path, arch, custom_url=None):
    if custom_url:
        print(f"[*] Downloading from custom URL: {custom_url}")
        if try_download(custom_url, output_path):
            return True

    # 1. Primary: High-speed GitHub releases mirror
    print(f"[*] Searching GitHub mirrors for {arch} v{version}...")
    if fetch_from_github_mirror(version, arch, output_path):
        return True

    # 2. Secondary: Archive.org & GitHub Releases Fallbacks
    arch_tag = "arm64-v8a" if ("64" in arch) else "armeabi-v7a"
    mirrors = [
        f"https://github.com/revanced-apks/builds/releases/download/v{version}/music-{arch_tag}.apk",
        f"https://github.com/revanced-apks/builds/releases/download/ytmusic-v{version}/ytmusic.apk",
        f"https://archive.org/download/youtube-music-apk-{version.replace('.', '-')}/youtube-music-{version}-{arch_tag}.apk",
        f"https://archive.org/download/youtube-music-apk-{version.replace('.', '-')}/youtube-music-{version}.apk"
    ]
    for m in mirrors:
        if try_download(m, output_path):
            return True

    # 3. Tertiary: APKMirror Scraper
    if scrape_apkmirror(version, output_path, arch):
        return True

    return False

def main():
    if len(sys.argv) < 3:
        print("Usage: download-stock.py <version> <output_path> [arch] [custom_url]")
        print("  arch: arm64-v8a (default), armeabi-v7a, both, or universal")
        sys.exit(1)

    version = sys.argv[1].lstrip('v')
    if not re.match(r'^[0-9]+(\.[0-9]+)*(-[a-zA-Z0-9.]+)?$', version):
        print(f"[-] Invalid YouTube Music version format: {version}")
        sys.exit(1)

    output_path = os.path.abspath(sys.argv[2])
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    
    arch = sys.argv[3] if len(sys.argv) > 3 else "arm64-v8a"
    custom_url = sys.argv[4] if len(sys.argv) > 4 else None

    if arch == "both":
        base, ext = os.path.splitext(output_path)
        arm64_out = f"{base}-arm64-v8a{ext}"
        arm32_out = f"{base}-armeabi-v7a{ext}"

        print(f"📥 [1/2] Downloading Stock arm64-v8a APK...")
        s64 = download_single(version, arm64_out, "arm64-v8a", custom_url)
        print(f"📥 [2/2] Downloading Stock armeabi-v7a APK...")
        s32 = download_single(version, arm32_out, "armeabi-v7a", custom_url)

        if s64 and s32:
            merge_native_libraries(arm64_out, arm32_out, output_path)
            sys.exit(0)
        elif s64:
            shutil.copyfile(arm64_out, output_path)
            sys.exit(0)
        elif s32:
            shutil.copyfile(arm32_out, output_path)
            sys.exit(0)
        else:
            print("❌ Failed to download stock APKs.")
            sys.exit(1)
    else:
        if download_single(version, output_path, arch, custom_url):
            sys.exit(0)
        else:
            print(f"❌ Failed to download valid Stock YouTube Music APK for {arch}.")
            sys.exit(1)

if __name__ == '__main__':
    main()
