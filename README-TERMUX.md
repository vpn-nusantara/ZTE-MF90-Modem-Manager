# ZTE MF90 Modem Manager — Termux

Tool shell untuk membantu pemeriksaan modem **ZTE MF90 / MF90 Bolt**, dengan target firmware **Beeline B10**. Repository ini juga memuat proyek aplikasi Android.

## Instalasi di Termux

```bash
pkg update -y
pkg install -y git curl jq
git clone https://github.com/vpn-nusantara/ZTE-MF90-Modem-Manager.git
cd ZTE-MF90-Modem-Manager
chmod +x mf90-termux-manager.sh
./mf90-termux-manager.sh
```

Jika repo sudah pernah di-clone:
```bash
cd ZTE-MF90-Modem-Manager && git pull
```

## Fitur yang tersedia

- Pemeriksaan koneksi ke modem (default `192.168.0.1`).
- Pembacaan sejumlah field status melalui endpoint GoForm ZTE.
- Uji permintaan login GoForm; dukungan login dapat berbeda menurut build firmware.
- Membuka halaman admin modem.
- Backup profil APN ke JSON lokal di `~/MF90_Manager/backups`.
- Menampilkan nilai profil APN untuk diterapkan manual dari UI modem.

Ganti alamat modem saat menjalankan:
```bash
MF90_HOST=192.168.0.1 ./mf90-termux-manager.sh
```

## Batasan penting / Beeline B10

API GoForm, nama field, autentikasi, SMS, USSD, Wi-Fi, dan pengaturan band dapat berbeda antar-revisi MF90 dan build Beeline B10. Karena itu tool ini **tidak mengirim perintah tulis yang belum terverifikasi**. Pengaturan SSID/password, SMS/USSD, dan penerapan APN dilakukan melalui halaman admin modem sampai endpoint pada unit fisik telah diuji.

LTE band hanya ditampilkan bila field tersedia; script tidak mengunci band. Wi-Fi 5 GHz tidak dapat ditambahkan lewat software jika radio perangkat keras MF90 hanya mendukung 2.4 GHz.

## Firmware

Script ini **bukan firmware** dan bukan flasher. Tidak ada image firmware Beeline B10 yang disertakan. Gunakan hanya image resmi/terverifikasi yang cocok persis dengan model dan revisi hardware. Salah image dapat membuat modem tidak bisa boot. Jangan flash melalui script generik.

## Keamanan

- Password admin tidak disimpan oleh script.
- File backup APN berisi kredensial bila diisi; disimpan dengan permission `600`. Jangan commit folder backup ke GitHub.
- Jangan bagikan cookie sesi, konfigurasi, IMEI, serial number, atau data SIM.

## Pengembangan berikutnya

Endpoint tulis Wi-Fi/APN/SMS/USSD dan dukungan pemilihan band baru boleh diaktifkan setelah request/response diuji pada unit MF90 Bolt Beeline B10 dan dicatat tanpa data pribadi.

## Disclaimer

Proyek komunitas independen, bukan produk resmi ZTE atau Beeline. Gunakan dengan risiko sendiri.
