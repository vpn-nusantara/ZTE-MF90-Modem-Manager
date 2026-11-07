#!/data/data/com.termux/files/usr/bin/bash
# ZTE MF90 / Beeline B10 Termux Manager
# Conservative edition: status probing + safe local APN profile backup.
set -Eeuo pipefail
APP="MF90 Termux Manager"
HOST="${MF90_HOST:-192.168.0.1}"
BASE="http://${HOST}"
WORK="$HOME/MF90_Manager"
BACKUPS="$WORK/backups"
COOKIE="$WORK/session.cookie"
mkdir -p "$BACKUPS"
trap 'rm -f "$COOKIE"' EXIT

need() { command -v "$1" >/dev/null 2>&1 || { echo "Perintah '$1' belum ada. Jalankan: pkg install $1"; exit 1; }; }
need curl
need jq

line(){ printf '%s\n' '------------------------------------------------------------'; }
pause(){ read -r -p "Tekan Enter untuk kembali..."; }
url(){ termux-open-url "$1" 2>/dev/null || printf 'Buka URL ini di browser: %s\n' "$1"; }

probe() {
  curl -fsS --connect-timeout 4 --max-time 10 "$BASE/" >/dev/null
}
get_api() {
  local cmd="$1"
  curl -fsS --connect-timeout 5 --max-time 15 \
    -b "$COOKIE" -c "$COOKIE" \
    "$BASE/goform/goform_get_cmd_process?multi_data=1&isTest=false&cmd=$cmd"
}
show_json() {
  local raw="$1"
  if jq -e . >/dev/null 2>&1 <<<"$raw"; then
    jq -r 'to_entries[] | "\(.key): \(.value // "-")"' <<<"$raw"
  else
    echo "Respons modem bukan JSON yang dikenali:"
    printf '%s\n' "$raw" | head -c 1200; echo
  fi
}
status() {
  line; echo "MEMERIKSA MODEM $HOST"
  if ! probe; then
    echo "Modem tidak merespons. Pastikan HP tersambung ke WiFi MF90."
    return
  fi
  echo "Koneksi HTTP: OK"
  local data
  data="$(get_api 'wa_inner_version,cr_version,hardware_version,web_version,network_type,network_provider,signalbar,wan_ipaddr,ppp_status,battery_percent')"
  show_json "$data"
  echo
  echo "Catatan: beberapa field dapat kosong jika tidak diekspos firmware Beeline B10."
}
login() {
  local pass encoded response
  read -r -s -p "Password admin modem: " pass; echo
  encoded="$(printf '%s' "$pass" | base64 | tr -d '\n')"
  # Login ZTE GoForm bervariasi antar-build. Tidak menyimpan password.
  response="$(curl -sS --connect-timeout 5 --max-time 15 -c "$COOKIE" -b "$COOKIE" \
    -X POST "$BASE/goform/goform_set_cmd_process" \
    --data-urlencode 'isTest=false' \
    --data-urlencode 'goformId=LOGIN' \
    --data-urlencode "password=$encoded" || true)"
  unset pass encoded
  if grep -Eqi 'success|ok|result' <<<"$response"; then
    echo "Permintaan login dikirim. Respons: $(head -c 300 <<<"$response")"
  else
    echo "Respons login tidak dapat dipastikan: $(head -c 300 <<<"$response")"
    echo "Jika gagal, gunakan login dari halaman admin modem."
  fi
}
open_admin(){ url "$BASE"; }
apn_backup() {
  local apn user pass file
  read -r -p "Nama profil APN (mis. Internet): " apn
  read -r -p "Username (kosongkan jika tidak ada): " user
  read -r -s -p "Password APN (kosongkan jika tidak ada): " pass; echo
  file="$BACKUPS/apn-$(date +%Y%m%d-%H%M%S).json"
  jq -n --arg apn "$apn" --arg username "$user" --arg password "$pass" \
    --arg host "$HOST" --arg firmware "Beeline B10 (target; verifikasi pada modem)" \
    '{device:"ZTE MF90",host:$host,firmware:$firmware,apn:$apn,username:$username,password:$password,created_at:(now|todate)}' > "$file"
  chmod 600 "$file"; unset pass
  echo "Profil APN tersimpan lokal: $file"
}
apn_restore() {
  local files=() choice file apn user pass
  shopt -s nullglob; files=("$BACKUPS"/apn-*.json); shopt -u nullglob
  if (("${#files[@]}"==0)); then echo "Belum ada backup APN."; return; fi
  echo "Pilih profil:"
  select file in "${files[@]}" "Batal"; do
    [[ "$file" == "Batal" || -z "${file:-}" ]] && return
    break
  done
  jq -e '.device=="ZTE MF90" and (.apn|type=="string")' "$file" >/dev/null || { echo "File backup tidak valid."; return; }
  apn="$(jq -r .apn "$file")"; user="$(jq -r '.username // ""' "$file")"; pass="$(jq -r '.password // ""' "$file")"
  line; echo "APN: $apn"; echo "Username: ${user:- (kosong)}"
  echo "Restore otomatis tidak dilakukan karena nama field API APN berbeda antar firmware."
  echo "Buka halaman modem, lalu masukkan nilai di atas:"
  echo "APN=$apn | Username=$user | Password tersimpan dalam file lokal (mode 600)."
  echo "File: $file"
  unset pass
  open_admin
}
device_notes() {
  line
  echo "FITUR & KOMPATIBILITAS"
  echo "- Dashboard/status: baca API GoForm jika field didukung firmware."
  echo "- APN: backup/restore profil lokal; penerapan dilakukan lewat UI modem."
  echo "- WiFi/SSID/password, SMS, USSD: buka UI modem; endpoint tulis belum diverifikasi."
  echo "- LTE band: hanya tampil jika firmware mengekspos field; tidak memaksa band."
  echo "- WiFi 5 GHz: MF90 umumnya perangkat 2.4 GHz; firmware tidak dapat menambah radio 5 GHz."
  echo "- Firmware Beeline B10: tool ini bukan flasher dan tidak mengubah firmware/NV."
  echo
  echo "Jangan kirim firmware lintas revisi hardware. Simpan backup konfigurasi sebelum perubahan."
}
menu() {
  clear 2>/dev/null || true
  line; echo "$APP"; echo "Target: ZTE MF90 | Firmware target: Beeline B10"; echo "Modem: $BASE"; line
  echo "1) Cek koneksi & informasi modem"
  echo "2) Login admin (uji GoForm)"
  echo "3) Buka halaman admin modem"
  echo "4) Backup profil APN ke JSON"
  echo "5) Pulihkan/tampilkan profil APN"
  echo "6) Catatan fitur & kompatibilitas"
  echo "0) Keluar"
  read -r -p "Pilih: " choice
  case "$choice" in
    1) status; pause ;;
    2) login; pause ;;
    3) open_admin; pause ;;
    4) apn_backup; pause ;;
    5) apn_restore; pause ;;
    6) device_notes; pause ;;
    0) exit 0 ;;
    *) echo "Pilihan tidak valid."; pause ;;
  esac
}
while true; do menu; done
