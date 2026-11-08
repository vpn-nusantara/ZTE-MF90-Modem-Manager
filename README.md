# ZTE MF90 Modem Manager — SAFE

Manager berbasis Termux untuk ZTE MF90 / MF90 Bolt dengan target firmware `BD_RUS_BEELINE_MF90V1.0.0B10`. SAFE adalah profil **read-only** untuk pemantauan dan pencadangan lokal. Proyek komunitas independen, bukan aplikasi resmi ZTE.

## Fitur SAFE
- Dashboard status modem, jaringan, operator, dan sinyal.
- Baca profil APN tanpa mengubahnya.
- Baca inbox SMS tanpa mengirim atau menghapus pesan.
- Informasi band LTE (baca saja); tidak ada band lock.
- Backup lokal dengan penyamaran data APN dan profil.
- Panduan pemulihan manual; tidak ada restore otomatis.
- Diagnostik koneksi modem dan akses HTTPS.
- Membuka Web Admin untuk pengaturan manual.
- Pembaruan GitHub melalui `git pull --ff-only`.

## Dinonaktifkan pada SAFE
Pemilihan mode jaringan, tambah/ubah/hapus APN, pengiriman SMS, kontrol WAN, dan perubahan mode dial. SAFE tidak mengirim perintah perubahan konfigurasi ke endpoint GoForm. Login hanya dipakai untuk membuat sesi baca. Perubahan yang dilakukan manual melalui Web Admin tetap dapat mengubah modem.

## Instalasi
```bash
pkg update -y
pkg install -y git curl jq openssl coreutils libiconv python
git clone https://github.com/vpn-nusantara/ZTE-MF90-Modem-Manager.git
cd ZTE-MF90-Modem-Manager
chmod +x mf90-termux-manager.sh
./mf90-termux-manager.sh
```

Default IP modem: `192.168.0.1`. Jika berbeda:
```bash
MF90_HOST=192.168.0.1 ./mf90-termux-manager.sh
```

Data lokal berada di `~/MF90_Manager`; cookie sesi dihapus saat program keluar. Permission folder, cookie, log, dan backup dibatasi oleh `umask 077`. Backup menyamarkan nama profil, APN, username, password, dan blob profil APN. Jangan unggah backup atau log ke repository publik.

## Batas keselamatan
- Tidak ada flashing firmware, NV/partisi write, reboot paksa, band lock, atau restore otomatis.
- Tidak ada endpoint Wi-Fi/USSD tebakan. Fitur tersebut hanya membuka Web Admin.
- API komunitas bukan dokumentasi resmi; respons dan field dapat berbeda antar revisi MF90.
- Gunakan hanya melalui Wi-Fi modem sendiri yang tepercaya. Login melalui HTTP lokal tidak terenkripsi; hindari jaringan publik.
- SAFE belum diuji langsung pada perangkat fisik pengguna.

## Referensi
- [Dokumentasi komunitas Beeline MF90 API](https://wijayamin.github.io/zte-modem-api-docs/)
- [Panduan Termux](README-TERMUX.md)

## Disclaimer
Gunakan dengan risiko sendiri. Proyek ini tidak berafiliasi dengan ZTE atau Beeline.
