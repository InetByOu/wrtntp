# 🕒 wrtntp - OpenWRT NTP Time Synchronization

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![OpenWRT](https://img.shields.io/badge/OpenWRT-Compatible-green)
![Architecture](https://img.shields.io/badge/architecture-Hexagonal-orange)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

**wrtntp** adalah solusi sinkronisasi waktu yang powerful dan fleksibel untuk **OpenWRT**, dibangun dengan **arsitektur hexagonal** yang memungkinkan penggunaan *multiple synchronization adapters* dengan *automatic fallback*.

---

## 🚀 Fitur Utama

### 🔧 **Multiple Sync Adapters**
- 🌐 **NTP** — Sinkronisasi dengan server NTP standar  
- ☁️ **HTTP** — Sinkronisasi melalui web API  
- 📱 **Android (ADB)** — Sinkronisasi dari perangkat Android terhubung  
- ⏰ **RTC** — Sinkronisasi dari hardware clock  
- 🔁 **Fallback** — Estimasi waktu berdasarkan uptime  

### ⚡ **Advanced Features**
- ✅ Arsitektur **Hexagonal** untuk maintainability  
- ✅ **Automatic adapter detection**  
- ✅ **Boot-time synchronization**  
- ✅ **Scheduled sync** dengan cron  
- ✅ **Self-update capability**  
- ✅ **Interactive menu interface**  
- ✅ **Service management**  
- ✅ **Comprehensive logging**

---

## 🧩 Kompatibilitas

- ✅ Semua versi **OpenWRT**
- ✅ Arsitektur **ARM, MIPS, x86**
- ✅ Kompatibel dengan **BusyBox**
- ✅ Mendukung **ProCD service**

---

## 📦 Instalasi

### 🧠 Metode 1: Auto Installer

```bash
# Download setup script
wget -O setup.sh https://github.com/InetByOu/wrtntp/raw/main/setup.sh

# Berikan permission executable
chmod +x setup.sh

# Jalankan installer
./setup.sh
```

### 🧰 Metode 2: Manual Install

```bash
# Download langsung
wget -O /usr/bin/wrtntp https://github.com/InetByOu/wrtntp/raw/main/wrtntp
chmod +x /usr/bin/wrtntp

# Buat config directory
mkdir -p /etc/wrtntp
```

---

## 🎯 Penggunaan

### 🖥️ Mode Interaktif

```bash
wrtntp
```

Mode ini menampilkan menu interaktif dengan seluruh fitur (sync, update, service, log, dll).

### ⚙️ Command Line Options

```bash
wrtntp --sync       # Sinkronisasi waktu sekarang
wrtntp --service    # Jalankan sebagai service
wrtntp --boot       # Sinkronisasi saat boot
wrtntp --cron       # Jalankan sync terjadwal
wrtntp --update     # Update aplikasi
wrtntp --status     # Cek status sistem
wrtntp --help       # Bantuan
```

---

## 🏗️ Arsitektur Hexagonal

wrtntp mengimplementasikan **Hexagonal Architecture** untuk memisahkan core logic dan external adapters.

### Core Domain
- `use_case_synchronize_time()` — Business logic utama  
- `use_case_install_dependencies()` — Dependency management  
- `use_case_update_self()` — Self-update mechanism  

### Ports (Interfaces)
```bash
NTP_PORTS="pool.ntp.org time.google.com ntp.ubuntu.com"
HTTP_PORTS="https://worldtimeapi.org/api/ip https://timeapi.io/api/Time/current/zone?timeZone=UTC"
```

### Adapters (Implementations)
- `adapter_ntp()` — NTP client implementation  
- `adapter_http()` — HTTP API implementation  
- `adapter_android()` — Android device implementation  
- `adapter_rtc()` — Hardware clock implementation  
- `adapter_fallback()` — Fallback strategy  

---

## ⚙️ Konfigurasi

**File:** `/etc/wrtntp/wrtntp.conf`

### Default Configuration
```ini
# wrtntp Configuration
SYNC_ON_BOOT=true
BOOT_DELAY=30
SYNC_INTERVAL=3600
MAX_RETRIES=3
NTP_SERVERS="pool.ntp.org time.google.com ntp.ubuntu.com"
```

---

## 🧠 Service Management

```bash
/etc/init.d/wrtntp start      # Start service
/etc/init.d/wrtntp stop       # Stop service
/etc/init.d/wrtntp enable     # Enable boot startup
/etc/init.d/wrtntp disable    # Disable boot startup
```

---

## 🔄 Scheduled Sync

**Interval yang tersedia:**
- 15 menit  
- 30 menit  
- 1 jam *(default)*  
- 2 jam  
- 6 jam  
- 12 jam  
- 24 jam  

### Cron Configuration
```bash
crontab -e
# Tambahkan baris berikut:
0 * * * * /usr/bin/wrtntp --cron >> /var/log/wrtntp.log 2>&1
```

---

## 📊 Status & Monitoring

### System Status
```bash
wrtntp --status
```
Output:
```
Current time: 2024-01-15 14:30:25
System uptime: 2 days, 3 hours, 15 minutes
Available adapters: ntp http fallback
```

### Log File
```bash
tail -f /var/log/wrtntp.log
```

---

## 🧩 Troubleshooting

### 1️⃣ Network Connectivity
```bash
ping -c 3 8.8.8.8
wget --spider https://google.com
```

### 2️⃣ NTP Client Missing
```bash
opkg update
opkg install ntpclient
```

### 3️⃣ Service Not Starting
```bash
/etc/init.d/wrtntp status
logread | grep wrtntp
```

### 4️⃣ Permission Issues
```bash
chmod +x /usr/bin/wrtntp
chmod +x /etc/init.d/wrtntp
```

### 🔍 Debug Mode
```bash
wrtntp --sync 2>&1 | tee /tmp/wrtntp-debug.log
```

---

## 🧠 Advanced Usage

### Custom NTP Servers
```ini
NTP_SERVERS="ntp.local.company.com time.example.com pool.ntp.org"
```

### Boot Delay Adjustment
```ini
BOOT_DELAY=60
```

### Fallback Strategy Order
1. NTP Servers  
2. HTTP Time APIs  
3. Android Devices  
4. Hardware RTC  
5. Fallback (Uptime Estimation)

---

## 📈 Performance

| Resource | Usage |
|-----------|--------|
| Memory | < 2MB RAM |
| Storage | ~50KB |
| CPU | Minimal saat sync |

✅ **Automatic retries**  
✅ **Fallback mechanism**  
✅ **Network connectivity checks**  
✅ **Graceful error handling**

---

## 🤝 Contributing

1. Fork repository  
2. Buat branch baru  
3. Commit perubahan  
4. Push dan buat Pull Request  

### Development Setup
```bash
git clone https://github.com/InetByOu/wrtntp.git
cd wrtntp
chmod +x setup.sh
./setup.sh --no-service --no-deps
```

---

## 📝 Changelog

**v1.0.0**
- ✅ Initial release with hexagonal architecture  
- ✅ Multiple adapters (NTP, HTTP, Android, RTC)  
- ✅ Service management  
- ✅ Self-update  
- ✅ Interactive menu  

---

## 🐛 Bug Reports

Jika menemukan bug, buat issue di GitHub disertai:
- OpenWRT version  
- Device architecture  
- Error log / output  
- Langkah reproduksi  

---

## 📄 License

Distributed under the **MIT License**.  
Lihat file [LICENSE](LICENSE) untuk detail.

---

## 🙏 Acknowledgments

- 💡 OpenWRT community  
- ⏱ NTP Pool Project  
- 🌍 WorldTimeAPI  
- 👨‍💻 Contributors  

---

> **wrtntp** — Keeping your OpenWRT devices in perfect time sync ⏰

---

## 📁 Struktur Repository

```
wrtntp/
├── README.md           # Dokumentasi utama
├── setup.sh            # Script instalasi otomatis
├── wrtntp              # Aplikasi utama
├── LICENSE             # MIT License
└── examples/
    ├── custom-ntp.conf
    └── manual-install.md
```

---

## ⚡ Quick Start

```bash
# 1. Install
wget -O setup.sh https://github.com/InetByOu/wrtntp/raw/main/setup.sh
chmod +x setup.sh && ./setup.sh

# 2. Sync time immediately
wrtntp --sync

# 3. Enable automatic sync
wrtntp  # -> Pilih "Service Management" → "Enable Boot Sync"
```

✨ Hanya 3 langkah untuk menjaga waktu perangkat OpenWRT Anda tetap akurat!
