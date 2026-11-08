# ZTE MF90 Modem Manager

Manager ADVANCED berbasis Termux untuk ZTE MF90 / MF90 Bolt dengan target firmware `BD_RUS_BEELINE_MF90V1.0.0B10`. Proyek komunitas independen, bukan aplikasi resmi ZTE.

## Fitur

- Dashboard informasi modem, operator, jaringan, dan sinyal.
- Pemilihan mode jaringan otomatis, LTE, 3G, atau 2G.
- Lihat, buat, ubah, dan hapus profil APN dengan konfirmasi.
- Baca inbox dan kirim SMS.
- Buka pengaturan Wi-Fi/SSID/password melalui Web Admin.
- USSD melalui Web Admin.
- Pemeriksaan informasi band LTE (baca saja).
- Backup konfigurasi lokal dan panduan pemulihan manual.
- Kontrol koneksi WAN dan mode dial otomatis/manual.
- Diagnostik koneksi modem dan akses HTTPS internet.
- Sinkronisasi pembaruan repository melalui GitHub (fast-forward only).

## Instalasi Termux

```bash
pkg update -y
pkg install -y git curl jq openssl coreutils libiconv python
git clone https://github.com/vpn-nusantara/ZTE-MF90-Modem-Manager.git
cd ZTE-MF90-Modem-Manager
chmod +x mf90-termux-manager.sh
./mf90-termux-manager.sh
```

Untuk panduan lengkap, kompatibilitas, dan batas keamanan lihat [README-TERMUX.md](README-TERMUX.md).

## Kompatibilitas dan batasan penting

Target penggunaan adalah ZTE MF90 / MF90 Bolt dengan firmware Beeline B10. API GoForm dapat berbeda antar-revisi perangkat dan firmware. Fitur yang menulis konfigurasi perlu diverifikasi pada modem nyata.

Wi-Fi SSID/password tetap menggunakan Web Admin karena dokumentasi API yang tersedia belum memverifikasi endpoint Wireless-LAN. Tidak ada penguncian LTE band, modifikasi NV/partisi, atau flashing firmware. Tool ini bukan flasher dan tidak menyertakan image firmware.

Backup dibuat lokal dan tidak boleh diunggah ke repository publik karena dapat memuat identitas perangkat atau data jaringan. Password APN dan blob profil APN pada backup baru disamarkan.

## Kontribusi

Saran, laporan bug, dan dokumentasi hasil pengujian pada revisi MF90 yang berbeda sangat diterima. Jangan kirim password, IMEI, IMSI, nomor telepon, atau kredensial jaringan saat membuat laporan.

## Disclaimer

Gunakan dengan risiko sendiri. Pastikan setiap perubahan konfigurasi dipahami dan selalu periksa hasilnya melalui Web Admin modem.
