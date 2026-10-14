<h1 align="center">🎵 YouTube Music ReVanced (RVX) Builder</h1>

<p align="center">
  <b>Модифицированная версия YouTube Music с фоновым воспроизведением, вырезанной рекламой, AMOLED темой, максимальным битрейтом и премиум-возможностями на базе Morphe CLI & Anddea Patches</b>  
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Android-green?style=flat-square" alt="Android" />
  <img src="https://img.shields.io/badge/Root-Magisk%20%7C%20KernelSU%20%7C%20APatch-orange?style=flat-square" alt="Root" />
  <img src="https://img.shields.io/badge/Non--Root-GmsCore%20Supported-blue?style=flat-square" alt="Non-Root" />
</p>

---

## 📌 О проекте (About)

Этот проект предоставляет автоматизированный сборочный конвейер и модуль **YouTube Music ReVanced (RVX)**.
Поддерживаются обе версии:
- 🌈 **Non-Root (обычный APK)**: работает на любых устройствах без рута в связке с MicroG / GmsCore.
- 🎭 **Root (модуль Magisk / KernelSU / APatch)**: монтируется напрямую поверх системного YouTube Music без изменения `/system` и без необходимости перезагрузки (Hot-Mount).

---

## ✨ Основные возможности (Features)

- 🎧 **Фоновое воспроизведение**: музыка продолжает играть при заблокированном экране или сворачивании приложения.
- 🚫 **Без рекламы**: блокировка всех аудио- и видео-вставок, а также баннеров в приложении.
- ⚡ **Always High Bitrate**: принудительное включение наивысшего качества звука по умолчанию.
- 🎤 **Синхронизированные тексты песен (Third-Party Lyrics)**: караоке-тайминги и слова песен из 15+ онлайн-источников в панели трека.
- 🔀 **Кроссфейд треков (Track Crossfade)**: плавное бесшовное микширование перехода между треками.
- 🚗 **Android Auto**: встроенная подмена сертификата (`Certificate spoof`) для работы на головном устройстве автомобиля.
- 🛡️ **SponsorBlock**: автоматический пропуск спонсорских сегментов, интро и аутро в клипах.
- 👎 **Return YouTube Dislike**: отображение счетчика дизлайков.
- 🖤 **AMOLED Pure Black Theme**: идеально черный фон (`#000000`) для экономии батареи на OLED/AMOLED экранах.
- 📥 **Встроенная кнопка загрузки**: возможность интеграции стороннего загрузчика (NewPipe, Seal, YTDL).

---

## 📥 Загрузка GmsCore (для Non-Root)

Для входа в аккаунт Google в **Non-Root** версии необходим **GmsCore (MicroG)**:

| Источник | Ссылка на загрузку |
|---|---|
| **MicroG-RE (Morphe)** (Рекомендуется) | 🔗 [Скачать](https://github.com/MorpheApp/MicroG-RE/releases/latest) |
| **MicroG-RE (wstxda)** | 🔗 [Скачать](https://github.com/wstxda/microg-re/releases/latest) |
| **ReVanced GmsCore** | 🔗 [Скачать](https://github.com/revanced/gmscore/releases/latest) |

---

## 🚀 Установка (Installation Guide)

### 🌈 Вариант 1: Non-Root (Без Root-прав)

1. Установите **GmsCore (MicroG)** по ссылке выше.
2. Скачайте файл **`YouTubeMusic.RVX.v<version>-NonRoot.apk`** из раздела [Releases](../../releases).
3. Установите и запустите приложение.
4. Войдите в свой Google-аккаунт.

---

### 🎭 Вариант 2: Root (Magisk / KernelSU / APatch)

1. Убедитесь, что оригинальный YouTube Music установлен из Google Play.
2. Скачайте архив модуля **`YouTubeMusic.RVX.v<version>.zip`** из раздела [Releases](../../releases).
3. Прошейте архив через менеджер **Magisk**, **KernelSU** или **APatch**.
4. Модуль применится мгновенно без обязательной перезагрузки устройства!
5. При необходимости нажмите кнопку **Action** в Magisk для повторного монтирования.

---

## ⚙️ Как собрать свой APK / Модуль через GitHub Actions

Вам не нужно устанавливать Java, Android SDK или собирать что-либо на компьютере:

1. Сделайте **Fork** или откройте вкладку **Actions** в этом репозитории.
2. Выберите workflow **`Build & Package YouTube Music RVX`**.
3. Нажмите **`Run workflow`**:
   - `music_version`: оставьте `recommended` (автовыбор стабильной версии, например `8.30.54`) или укажите свою.
   - `patch_source`: выберите `anddea` (рекомендуется) или `morphe`.
   - `patch_tag`: `dev` (последние функции) или `latest`.
   - `build_mode`: `test` (сохранит в артефакты сборки) или `release` (создаст официальный GitHub Release).
4. Нажмите зеленую кнопку **Run workflow**. Через 3–5 минут готовые файлы появятся в артефактах или разделе Releases!

---

## 💻 Локальная сборка на ПК (Linux / macOS)

Если вы хотите собрать файлы локально:

```bash
# Установите зависимости (Ubuntu / Debian)
sudo apt-get install -y jq zip unzip curl openjdk-21-jdk python3 python3-pip
pip install requests beautifulsoup4 packaging

# Запустите сборку
chmod +x tools/*.sh customize.sh service.sh action.sh uninstall.sh
bash tools/build-module.sh recommended anddea dev test config/golden-preset.json
```

Готовые файлы появятся в папке `build_out/`:
- `build_out/YouTubeMusic.RVX.v*-NonRoot.apk`
- `build_out/YouTubeMusic.RVX.v*.zip`

---

## 🛠️ Решение проблем (Troubleshooting)

- **Ошибка "Пакет поврежден / Package incompatible" при установке Non-Root**:
  Удалите старую версию YouTube Music RVX перед установкой новой.
- **Проблемы с буферизацией треков**:
  Перейдите в *Настройки > RVX > Разное > Spoof client / Подмена клиента* и смените клиент воспроизведения.
- **Root-модуль не применился**:
  Убедитесь, что версия установленного из Play Store YouTube Music совпадает с версией модуля, или откройте Magisk и нажмите кнопку **Action** у модуля.

---

## 📜 Благодарности и используемые источники

- 🛠️ [Anddea Patches](https://github.com/anddea/revanced-patches)
- ⚙️ [Morphe CLI](https://github.com/MorpheApp/morphe-cli)
- 📺 [ReVanced Team](https://github.com/revanced)
- 💡 [Zy0x/YouTube-Revanced](https://github.com/Zy0x/YouTube-Revanced) за архитектурное вдохновение
