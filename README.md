<p align="center">
  <b>🇬🇧 English</b> | <a href="README_RU.md">🇷🇺 Русский</a>
</p>

<h1 align="center">🎵 YouTube Music ReVanced (RVX) Builder</h1>

<p align="center">
  <b>Patched version of YouTube Music with background playback, ad-free experience, AMOLED dark theme, maximum audio bitrate, and premium features powered by Morphe CLI & Anddea Patches.</b>  
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Android-green?style=flat-square" alt="Android" />
  <img src="https://img.shields.io/badge/Root-Magisk%20%7C%20KernelSU%20%7C%20APatch-orange?style=flat-square" alt="Root" />
  <img src="https://img.shields.io/badge/Non--Root-GmsCore%20Supported-blue?style=flat-square" alt="Non-Root" />
  <img src="https://img.shields.io/badge/Auto--Update-Daily%20Cron-brightgreen?style=flat-square" alt="Auto-Update" />
</p>

---

## 📌 About

This repository provides an automated CI/CD cloud build pipeline and system module for **YouTube Music ReVanced (RVX)**.

Supports both usage variants:
- 🌈 **Non-Root (Standalone APK)**: Works on any Android device without root privileges via MicroG / GmsCore.
- 🎭 **Root (Magisk / KernelSU / APatch Module)**: Directly bind-mounts over the official YouTube Music installation without modifying system partitions and without requiring a reboot (Instant Hot-Mount).

---

## ✨ Features

- 🎧 **Background Playback**: Keep listening with the screen turned off or while using other apps without a YouTube Premium subscription.
- 🚫 **Ad-Free**: Audio ads, video ads, and in-app banner promotions are completely removed.
- ⚡ **Always High Bitrate**: Forces the highest audio stream quality by default.
- 🎤 **Synchronized Lyrics (Third-Party Lyrics)**: Karaoke-style synced lyrics in the player panel powered by 15+ external lyric providers.
- 🔀 **Track Crossfade**: True dual-player seamless audio crossfade between consecutive tracks.
- 🚗 **Android Auto Support**: Certificate spoofing enabled to ensure playback works on car dashboards.
- 🛡️ **SponsorBlock**: Automatically skip non-music segments, intros, and outros in music videos.
- 👎 **Return YouTube Dislike**: Displays dislike counts on tracks and music videos.
- 🖤 **AMOLED Pure Black Theme**: Deep `#000000` pitch black theme for battery savings on OLED/AMOLED displays.
- 🔄 **Daily Automated Updates**: Automatically checks for new YouTube Music versions and patches every day, building and publishing fresh releases when available.

---

## 📥 GmsCore / MicroG Downloads (For Non-Root Users)

To log into your Google Account in the **Non-Root** version, install **GmsCore (MicroG)**:

| Source | Download Link |
|---|---|
| **MicroG-RE (Morphe)** (Recommended) | 🔗 [Download](https://github.com/MorpheApp/MicroG-RE/releases/latest) |
| **MicroG-RE (wstxda)** | 🔗 [Download](https://github.com/wstxda/microg-re/releases/latest) |
| **ReVanced GmsCore** | 🔗 [Download](https://github.com/revanced/gmscore/releases/latest) |

---

## 🚀 Installation Guide

### 🌈 Method 1: Non-Root (No Root Required)

1. Install **GmsCore (MicroG)** from the links above.
2. Go to the [Releases](../../releases) section of this repository.
3. Download **`YouTubeMusic.RVX.v<version>-NonRoot.apk`**.
4. Install the APK and launch it.
5. Log into your Google Account and enjoy!

---

### 🎭 Method 2: Root (Magisk / KernelSU / APatch)

1. Ensure the official YouTube Music app is installed from the **Google Play Store**.
2. Go to the [Releases](../../releases) section and download **`YouTubeMusic.RVX.v<version>.zip`**.
3. Open your root manager app (**Magisk**, **KernelSU**, or **APatch**).
4. Navigate to the **Modules** tab ➔ tap **Install from storage** ➔ select the downloaded `.zip` file.
5. The module mounts immediately without requiring a reboot!

---

## ⚙️ Triggering a Manual Build

1. Open the [Actions](../../actions) tab in this repository.
2. Select **`Build & Package YouTube Music RVX`** from the left sidebar.
3. Click **`Run workflow ▾`** ➔ Click the green **`Run workflow`** button.
4. In 3–4 minutes, new builds will be published directly to [Releases](../../releases).

---

## 🛠️ Troubleshooting

- **"App not installed / Package incompatible" error during Non-Root install**:
  Uninstall your previous YouTube Music RVX version first before installing the new build.
- **Playback buffering or song loading issues**:
  Go to *Settings > RVX > Misc > Spoof client* and switch to a different streaming client.
- **Root module not taking effect**:
  Make sure the installed Play Store version matches the module version, or tap the **Action** button on the module card in Magisk.

---

## 📜 Credits & Acknowledgments

- 🛠️ [Anddea Patches](https://github.com/anddea/revanced-patches)
- ⚙️ [Morphe CLI](https://github.com/MorpheApp/morphe-cli)
- 📺 [ReVanced Team](https://github.com/revanced)
- 💡 [Zy0x/YouTube-Revanced](https://github.com/Zy0x/YouTube-Revanced) for architectural inspiration
