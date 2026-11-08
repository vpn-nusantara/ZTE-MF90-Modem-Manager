# ZTE MF90 Beeline B10 — Termux SAFE Manager

Profil SAFE berfokus pada pembacaan status dan backup lokal. Target firmware: `BD_RUS_BEELINE_MF90V1.0.0B10`. Bukan aplikasi resmi ZTE/Beeline.

## Instalasi
```bash
pkg update -y
pkg install -y git curl jq openssl coreutils libiconv python
git clone https://github.com/vpn-nusantara/ZTE-MF90-Modem-Manager.git
cd ZTE-MF90-Modem-Manager
chmod +x mf90-termux-manager.sh
./mf90-termux-manager.sh
```

Jika IP modem bukan `192.168.0.1`:
```bash
MF90_HOST=192.168.0.1 ./mf90-termux-manager.sh
```

## Menu SAFE
| Menu | Fitur |
|---|---|
| 01 | Dashboard modem, firmware, jaringan, sinyal |
| 03 | Lihat profil APN (read-only) |
| 05 | Inbox SMS (read-only) |
| 07–08 | Wi-Fi dan USSD melalui Web Admin |
| 09 | Informasi band/sinyal (read-only) |
| 10 | Backup lokal tersamarkan |
| 11 | Lihat panduan pemulihan manual |
| 12–13 | Info firmware dan buka Web Admin |
| 15 | Diagnostik modem dan HTTPS |
| 16 | Sinkronisasi GitHub fast-forward only |

## Dinonaktifkan
Perubahan mode jaringan, tambah/ubah/hapus APN, pengiriman SMS, kontrol WAN, dan perubahan mode dial tidak tersedia pada SAFE. Tidak ada pemanggilan endpoint GoForm untuk perubahan konfigurasi. Login hanya membuat sesi baca; endpoint pembacaan GoForm menggunakan HTTP POST sesuai implementasi API komunitas.

## Keamanan
- Backup di `~/MF90_Manager/backups`, permission dibatasi.
- Backup menyamarkan `m_profile_name`, `wan_apn`, `ppp_username`, `ppp_passwd`, dan semua blob `APN_config*`.
- Jangan unggah backup, cookie, log, IMEI, IMSI, nomor SIM, SMS, atau kredensial ke GitHub.
- Cookie sesi dihapus saat manager keluar; password tidak dicatat ke log.
- HTTP lokal tidak terenkripsi. Gunakan Wi-Fi modem sendiri dan jaringan tepercaya.
- Web Admin adalah pintasan; tindakan manual di dalamnya tetap dapat mengubah modem.
- Tidak ada flashing firmware, NV/partisi, reboot paksa, LTE band lock, atau restore otomatis.

## Kompatibilitas
Endpoint GoForm dan field API dapat berbeda menurut revisi hardware dan firmware. Referensi teknis: [Beeline MF90 API](https://wijayamin.github.io/zte-modem-api-docs/). SAFE belum diuji langsung pada perangkat fisik pengguna. Jika login atau pembacaan gagal, verifikasi Web Admin, IP, dan firmware; jangan mencoba endpoint tulis yang tidak dikenal.
