<p align="center">
  <a href="README.md">🇬🇧 English</a> | <b>🇷🇺 Русский</b>
</p>

<h1 align="center">🎵 YouTube Music ReVanced (RVX) Builder</h1>

<p align="center">
  <b>Модифицированная версия YouTube Music с фоновым воспроизведением, вырезанной рекламой, AMOLED темой, максимальным битрейтом и премиум-возможностями на базе Morphe CLI & Anddea Patches</b>  
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Платформа-Android-green?style=flat-square" alt="Android" />
  <img src="https://img.shields.io/badge/Root-Magisk%20%7C%20KernelSU%20%7C%20APatch-orange?style=flat-square" alt="Root" />
  <img src="https://img.shields.io/badge/Non--Root-Поддержка%20GmsCore-blue?style=flat-square" alt="Non-Root" />
  <img src="https://img.shields.io/badge/Авто--обновление-Каждый%20день-brightgreen?style=flat-square" alt="Auto-Update" />
</p>

---

## 📌 О проекте

Этот проект предоставляет полностью автоматизированный сборочный конвейер и модуль **YouTube Music ReVanced (RVX)**.

Поддерживаются оба варианта использования:
- 🌈 **Non-Root (обычный APK)**: работает на любых смартфонах и планшетах без рут-прав в связке с MicroG / GmsCore.
- 🎭 **Root (модуль Magisk / KernelSU / APatch)**: монтируется напрямую поверх системного YouTube Music без изменения системного раздела и без обязательной перезагрузки устройства (Hot-Mount).

---

## ✨ Основные возможности

- 🎧 **Фоновое воспроизведение**: музыка продолжает играть при заблокированном экране или сворачивании приложения.
- 🚫 **Без рекламы**: блокировка всех рекламных вставок (аудио, видео и баннеры).
- ⚡ **Always High Bitrate**: принудительное включение наивысшего качества звука по умолчанию.
- 🎤 **Синхронизированные тексты песен (Third-Party Lyrics)**: караоке-тайминги и тексты песен из 15+ онлайн-источников в панели плеера.
- 🔀 **Кроссфейд треков (Track Crossfade)**: плавное бесшовное микширование перехода между треками.
- 🚗 **Android Auto**: встроенная подмена сертификата (`Certificate spoof`) для работы на экране автомобиля.
- 🛡️ **SponsorBlock**: автоматический пропуск спонсорских сегментов, интро и аутро в клипах.
- 👎 **Return YouTube Dislike**: отображение счетчика дизлайков на треках и видео.
- 🖤 **AMOLED Pure Black Theme**: идеально черный фон (`#000000`) для экономии батареи на OLED/AMOLED экранах.
- 🔄 **Автоматическое обновление каждый день**: если Google или Anddea выпустили новую версию, GitHub Actions автоматически собирает свежий релиз.

---

## 📥 Загрузка GmsCore (для Non-Root пользователей)

Для входа в аккаунт Google в **Non-Root** версии необходим **GmsCore (MicroG)**:

| Источник | Ссылка на загрузку |
|---|---|
| **MicroG-RE (Morphe)** (Рекомендуется) | 🔗 [Скачать](https://github.com/MorpheApp/MicroG-RE/releases/latest) |
| **MicroG-RE (wstxda)** | 🔗 [Скачать](https://github.com/wstxda/microg-re/releases/latest) |
| **ReVanced GmsCore** | 🔗 [Скачать](https://github.com/revanced/gmscore/releases/latest) |

---

## 🚀 Инструкция по установке

### 🌈 Вариант 1: Non-Root (Без Root-прав)

1. Установите **GmsCore (MicroG)** по одной из ссылок выше.
2. Перейдите в раздел [Releases](../../releases) этого репозитория.
3. Скачайте файл **`YouTubeMusic.RVX.v<версия>-NonRoot.apk`**.
4. Установите APK и откройте его.
5. Войдите в свой Google-аккаунт.

---

### 🎭 Вариант 2: Root (Magisk / KernelSU / APatch)

1. Убедитесь, что оригинальный YouTube Music установлен из **Google Play Store**.
2. В разделе [Releases](../../releases) скачайте архив модуля **`YouTubeMusic.RVX.v<версия>.zip`**.
3. Откройте ваш менеджер рута (**Magisk**, **KernelSU** или **APatch**).
4. Перейдите во вкладку **«Модули»** ➔ нажмите **«Установить из хранилища»** ➔ выберите скачанный `.zip`.
5. Модуль применится мгновенно без обязательной перезагрузки!

---

## ⚙️ Как запустить сборку вручную

1. Перейдите во вкладку [Actions](../../actions).
2. Слева выберите workflow **`Build & Package YouTube Music RVX`**.
3. Нажмите кнопку **`Run workflow ▾`** ➔ нажмите зеленую кнопку **`Run workflow`**.
4. Через 3–4 минуты свежие файлы появятся во вкладке [Releases](../../releases).

---

## 🛠️ Решение проблем (Troubleshooting)

- **Ошибка "Пакет поврежден / Package incompatible" при установке Non-Root**:
  Удалите предыдущую версию YouTube Music RVX перед установкой новой.
- **Проблемы с буферизацией треков**:
  Перейдите в *Настройки > RVX > Разное > Spoof client / Подмена клиента* и переключите клиент воспроизведения.
- **Root-модуль не применился**:
  Убедитесь, что версия установленного из Play Store YouTube Music совпадает с версией модуля, или откройте Magisk и нажмите кнопку **Action** у карточки модуля.
