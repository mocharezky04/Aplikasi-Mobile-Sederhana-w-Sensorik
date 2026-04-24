![Banner](https://capsule-render.vercel.app/api?type=waving&height=220&color=0:0f172a,100:0d9488&text=Tugas%201%20Sensor%20Flutter&fontColor=ffffff&fontSize=42&fontAlignY=38&desc=Accelerometer%20%C2%B7%20Compass%2BGyroscope%20%C2%B7%20Light%20Sensor&descAlignY=60)

# Tugas 1 Sensor Flutter

[![Flutter](https://img.shields.io/badge/Flutter-3.38+-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.10+-0175C2?logo=dart&logoColor=white)](https://dart.dev/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://opensource.org/licenses/MIT)

Project ini adalah aplikasi Flutter sederhana untuk tugas PAB yang memanfaatkan minimal 3 sensor perangkat:
`Accelerometer`, `Compass + Gyroscope`, dan `Light Sensor`.

## 📑 Daftar Isi

- [🎯 Ringkasan Proyek](#-ringkasan-proyek)
- [✨ Fitur Utama](#-fitur-utama)
- [🛠️ Stack Teknologi](#️-stack-teknologi)
- [🗂️ Struktur Folder](#️-struktur-folder)
- [🚀 Quick Start](#-quick-start)
- [🧭 Halaman Sensor](#-halaman-sensor)
- [🧪 Testing](#-testing)
- [📝 Catatan Pengembangan](#-catatan-pengembangan)

## 🎯 Ringkasan Proyek

Aplikasi ini menampilkan pembacaan data sensor secara realtime dengan antarmuka sederhana dan mudah dipahami.
Fokus proyek adalah implementasi sensor, tanpa fitur tambahan seperti CRUD, login, atau backend.

## ✨ Fitur Utama

- Menu utama untuk memilih sensor.
- Halaman `Accelerometer`:
  - Estimasi kecepatan (`m/s`) dan jarak (`meter`) berbasis data percepatan.
  - Visualisasi ikon pelari yang bergerak.
- Halaman `Compass + Gyroscope`:
  - Heading derajat + arah mata angin (`N/NE/E/...`).
  - Efek tilt 3D realtime dari gyroscope.
- Halaman `Light Sensor`:
  - Pembacaan intensitas cahaya (`lux`) realtime.
  - Tampilan otomatis menyesuaikan kondisi gelap/terang.

## 🛠️ Stack Teknologi

- Framework: Flutter
- Language: Dart
- Sensor packages:
  - `sensors_plus`
  - `flutter_compass`
  - `ambient_light`
- UI: Material 3

## 🗂️ Struktur Folder

<details>
  <summary><strong>Click here to expand</strong></summary>

```text
tugas_1_sensor/
|- android/
|- ios/
|- lib/
|  `- main.dart
|- web/
|- windows/
|- linux/
|- macos/
|- pubspec.yaml
`- README.md
```

</details>

Folder yang bisa diklik:

- [`lib/main.dart`](lib/main.dart)
- [`pubspec.yaml`](pubspec.yaml)
- [`android/`](android)
- [`ios/`](ios)

## 🚀 Quick Start

<details>
  <summary><strong>Click here to expand</strong></summary>

1. Clone repository

```bash
git clone https://github.com/mocharezky04/Aplikasi-Mobile-Sederhana-w-Sensorik.git
cd Aplikasi-Mobile-Sederhana-w-Sensorik
```

2. Install dependency

```bash
flutter pub get
```

3. Jalankan aplikasi (debug)

```bash
flutter run
```

4. Build APK release

```bash
flutter build apk --release
```

</details>

## 🧭 Halaman Sensor

| Halaman               | Data Utama                                 | Visualisasi                        |
| --------------------- | ------------------------------------------ | ---------------------------------- |
| `Accelerometer`       | Kecepatan estimasi, jarak estimasi         | Ikon pelari bergerak               |
| `Compass + Gyroscope` | Heading derajat, arah mata angin, tilt X/Y | Dial compass dengan efek 3D        |
| `Light Sensor`        | Intensitas cahaya (lux), rentang kalibrasi | Tema gelap/terang menyesuaikan lux |

## 🧪 Testing

```bash
flutter analyze
```

Opsional:

```bash
flutter test
```

## 📝 Catatan Pengembangan

- Arah compass sudah disinkronkan dengan heading realtime.
- Efek 3D pada compass menggunakan kombinasi data compass + gyroscope.
- Light sensor menggunakan kalibrasi adaptif min/max lux agar perubahan tema lebih natural.
