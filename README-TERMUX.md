# ZTE MF90 Beeline B10 — Termux Modem Manager

Manager terminal interaktif untuk **ZTE MF90 / MF90 Bolt** dengan target firmware **Beeline B10**. Proyek komunitas independen; bukan aplikasi resmi ZTE/Beeline.

## Instalasi cepat di Termux

```bash
pkg update -y
pkg install -y git curl jq openssl coreutils libiconv python
git clone https://github.com/vpn-nusantara/ZTE-MF90-Modem-Manager.git
cd ZTE-MF90-Modem-Manager
chmod +x mf90-termux-manager.sh
./mf90-termux-manager.sh
```

Jika repo sudah ada:
```bash
cd ZTE-MF90-Modem-Manager
git pull
./mf90-termux-manager.sh
```

Default alamat modem adalah `http://192.168.0.1`. Jika berbeda:
```bash
MF90_HOST=192.168.0.1 ./mf90-termux-manager.sh
```

## Menu

1. Dashboard dan informasi firmware/jaringan/sinyal.
2. Pemilihan mode jaringan otomatis, LTE, 3G, atau 2G.
3. Membaca profil APN.
4. Menambah atau mengubah profil APN.
5. Membaca inbox SMS.
6. Mengirim SMS (memerlukan konfirmasi; biaya operator mungkin berlaku).
7. Pengaturan Wi-Fi/SSID/password melalui Web Admin.
8. USSD melalui Web Admin.
9. Pemeriksaan informasi LTE band/sinyal.
10. Backup konfigurasi lokal.
11. Membaca backup dan membuka Web Admin untuk pemulihan manual.
12. Informasi firmware Beeline B10.
13. Membuka Web Admin.

## Catatan kompatibilitas dan keamanan

- API GoForm, autentikasi, field status, APN, SMS, dan network mode berbeda antar-revisi MF90 dan build firmware. Keberhasilan respons HTTP belum tentu berarti perubahan diterapkan; periksa kembali dari Web Admin.
- Wi-Fi/SSID/password dan USSD diarahkan ke Web Admin karena endpoint tulis B10 belum diverifikasi pada semua perangkat.
- Penguncian LTE band tidak dijalankan. Manager hanya membaca field sinyal/band jika firmware mengeksposnya.
- Backup disimpan di `~/MF90_Manager/backups` dengan permission terbatas. Backup mungkin berisi username/password APN. Jangan commit backup, cookie, IMEI, nomor SIM, atau konfigurasi pribadi ke GitHub.
- Password admin tidak ditulis ke log dan cookie sesi dihapus saat program keluar.
- Manager ini **bukan flasher**. Firmware Beeline B10 tidak disertakan. Cocokkan model dan revisi hardware secara persis sebelum memakai image firmware apa pun. Salah image dapat membuat modem gagal boot.
- MF90 dengan radio Wi-Fi 2.4 GHz tidak dapat memperoleh radio 5 GHz hanya melalui modifikasi firmware.

## Troubleshooting

- Pastikan HP terhubung ke Wi-Fi modem.
- Buka `http://192.168.0.1` di browser dan pastikan halaman admin dapat diakses.
- Jika IP berbeda, jalankan dengan variabel `MF90_HOST`.
- Bila login/API ditolak, lakukan login di Web Admin dan cek ulang dukungan API pada build firmware.
- Jangan mencoba endpoint tulis yang tidak dikenal.

## Lisensi

Tambahkan lisensi proyek sesuai pilihan pemilik repository. Gunakan dan modifikasi dengan risiko sendiri.
