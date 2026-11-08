# ZTE MF90 Beeline B10 — Termux ADVANCED Manager

Manager CLI interaktif untuk ZTE MF90 / MF90 Bolt. Target pengujian pengguna: firmware `BD_RUS_BEELINE_MF90V1.0.0B10`. Proyek independen, bukan aplikasi resmi ZTE/Beeline.

## Instalasi

```bash
pkg update -y
pkg install -y git curl jq openssl coreutils libiconv python
git clone https://github.com/vpn-nusantara/ZTE-MF90-Modem-Manager.git
cd ZTE-MF90-Modem-Manager
chmod +x mf90-termux-manager.sh
./mf90-termux-manager.sh
```

Pembaruan:
```bash
cd ZTE-MF90-Modem-Manager
git pull
./mf90-termux-manager.sh
```

Alamat default modem `http://192.168.0.1`. Jika IP berbeda:
```bash
MF90_HOST=192.168.0.1 ./mf90-termux-manager.sh
```

## Menu manager

| Menu | Fitur |
|---|---|
| 01 | Dashboard modem, firmware, jaringan, dan sinyal |
| 02 | Pilih jaringan otomatis / LTE / 3G / 2G |
| 03–04 | Lihat dan simpan profil APN |
| 05–06 | Inbox dan pengiriman SMS |
| 07 | Pengaturan Wi-Fi lewat Web Admin |
| 08 | USSD lewat Web Admin |
| 09 | Informasi band dan sinyal (baca saja) |
| 10–11 | Backup lokal dan panduan restore APN |
| 12–13 | Informasi firmware dan buka Web Admin |
| 14 | Hubungkan / putuskan koneksi WAN (konfirmasi wajib) |
| 15 | Diagnostik akses modem dan HTTPS internet |
| 16 | Sinkronisasi GitHub dengan fast-forward only |
| 17 | Hapus profil APN (konfirmasi slot) |
| 18 | Mode dial WAN otomatis / manual (roaming off) |

## Keamanan dan batas kompatibilitas

- Endpoint GoForm dan field API dapat berbeda menurut revisi hardware dan build firmware. Menu tulis memerlukan konfirmasi dan hasilnya harus diverifikasi lagi dari Web Admin.
- Perintah WAN memakai form ID `CONNECT_NETWORK` dan `DISCONNECT_NETWORK`; mode dial memakai `SET_CONNECTION_MODE`; penghapusan profil memakai `APN_PROC_EX` dengan `apn_action=delete`. Endpoint tersebut didokumentasikan untuk Beeline MF90, tetapi tetap perlu diuji pada unit Anda.
- Pengaturan Wi-Fi SSID/password tetap melalui Web Admin. Dokumentasi reverse-engineering Beeline B10 mencantumkan Wireless-LAN sebagai area yang belum terverifikasi; manager tidak mengirim endpoint Wi-Fi tebakan.
- Penguncian LTE band, perubahan NV/partisi, reboot paksa, dan flashing firmware tidak disediakan.
- Backup lokal berada di `~/MF90_Manager/backups`, permission dibatasi, dan password APN dan blob profil APN disamarkan pada backup baru. Jangan pernah unggah cookie, backup, IMEI, IMSI, nomor SIM, atau data pribadi ke repository publik.
- Password admin tidak dicatat ke log. Cookie sesi dihapus saat manager keluar.
- Manager bukan flasher dan tidak menyertakan firmware. Image yang salah dapat membuat modem gagal boot.
- Modem hanya dapat memakai kemampuan radio yang didukung hardware; software tidak dapat menambahkan Wi-Fi 5 GHz pada perangkat 2.4 GHz.

## Troubleshooting

1. Hubungkan HP ke Wi-Fi modem.
2. Pastikan Web Admin bisa dibuka di browser.
3. Jalankan dengan `MF90_HOST` jika IP bukan `192.168.0.1`.
4. Jika autentikasi/API gagal, login ke Web Admin dan periksa kompatibilitas firmware. Jangan mencoba endpoint tulis yang tidak dikenal.

