#!/usr/bin/env python3
"""
Dynamic Version Fetcher from APKMirror for YouTube Music
"""

import sys
import os
import re
import json
import argparse
import urllib.request

USER_AGENTS = [
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
    'Mozilla/5.0 (Linux; Android 14; Pixel 8 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36'
]

def fetch_apkmirror_versions(app_category="youtube-music", max_pages=5):
    try:
        import requests
        from bs4 import BeautifulSoup
    except ImportError:
        print("[-] 'requests' or 'beautifulsoup4' not installed. Install with: pip install requests beautifulsoup4")
        return []

    headers = {'User-Agent': USER_AGENTS[0]}
    versions = []
    seen = set()

    for p in range(1, max_pages + 1):
        url = f"https://www.apkmirror.com/uploads/page/{p}/?appcategory={app_category}"
        print(f"[*] Fetching page {p}/{max_pages} from APKMirror: {url}")
        try:
            r = requests.get(url, headers=headers, timeout=15)
            if r.status_code != 200:
                print(f"[-] Page {p} returned status {r.status_code}, stopping.")
                break

            soup = BeautifulSoup(r.text, 'html.parser')
            links = soup.find_all('a', class_='fontBlack')
            for a in links:
                text = a.text.strip()
                # Matches versions like "YouTube Music 8.30.54" or "YouTube Music 9.15.51"
                m = re.search(r'([0-9]+\.[0-9]+\.[0-9]+)', text)
                if m:
                    ver = m.group(1)
                    is_beta = 'beta' in text.lower() or 'alpha' in text.lower()
                    if ver not in seen:
                        seen.add(ver)
                        versions.append({
                            'version': ver,
                            'isBeta': is_beta,
                            'title': text
                        })
        except Exception as e:
            print(f"[-] Error on page {p}: {e}")
            break

    print(f"[+] Successfully collected {len(versions)} unique versions for '{app_category}'.")
    return versions

def main():
    parser = argparse.ArgumentParser(description="Fetch YouTube Music versions from APKMirror")
    parser.add_argument("--app", default="youtube-music", help="App category (default: youtube-music)")
    parser.add_argument("--pages", type=int, default=5, help="Pages to scrape (default: 5)")
    parser.add_argument("--output", default="config/ytmusic-versions.json", help="Output JSON path")
    args = parser.parse_args()

    results = fetch_apkmirror_versions(args.app, args.pages)
    if results:
        os.makedirs(os.path.dirname(args.output), exist_ok=True)
        with open(args.output, 'w', encoding='utf-8') as f:
            json.dump(results, f, indent=2)
        print(f"[+] Saved to: {args.output}")

if __name__ == "__main__":
    main()
