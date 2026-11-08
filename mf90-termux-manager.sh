#!/data/data/com.termux/files/usr/bin/bash
# ZTE MF90 / MF90 Bolt - Beeline B10 Termux Manager
# Community utility. API availability differs by hardware revision and firmware build.
set -Eeuo pipefail
umask 077

APP="MF90 BEELINE B10 MANAGER"
HOST_RAW="${MF90_HOST:-http://192.168.0.1}"
HOST="${HOST_RAW%/}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
[[ "$HOST" == http://* || "$HOST" == https://* ]] || HOST="http://$HOST"
COOKIE="$HOME/.mf90-manager-cookie"
DATA_DIR="$HOME/MF90_Manager"
BACKUP_DIR="$DATA_DIR/backups"
LOG_FILE="$DATA_DIR/activity.log"
mkdir -p "$BACKUP_DIR"
chmod 700 "$DATA_DIR" "$BACKUP_DIR"
touch "$LOG_FILE"; chmod 600 "$LOG_FILE"

if [[ -t 1 ]]; then
  R=$'\033[31m'; G=$'\033[32m'; Y=$'\033[33m'
  B=$'\033[34m'; C=$'\033[36m'; M=$'\033[35m'; W=$'\033[1;37m'; N=$'\033[0m'
else R=''; G=''; Y=''; B=''; C=''; M=''; W=''; N=''; fi

say(){ printf '%b\n' "$*"; }
line(){ say "${C}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"; }
ok(){ say "${G}✔${N} $*"; }
warn(){ say "${Y}⚠${N} $*"; }
err(){ say "${R}✖${N} $*"; }
pause(){ read -r -p "Tekan Enter untuk kembali..." _ || true; }
log(){ printf '[%s] %s\n' "$(date '+%F %T')" "$*" >> "$LOG_FILE"; }
need(){ command -v "$1" >/dev/null 2>&1 || { err "Paket $1 belum terpasang."; return 1; }; }

install_deps(){
  local miss=()
  for x in curl jq openssl iconv python3 od git; do command -v "$x" >/dev/null 2>&1 || miss+=("$x"); done
  if (("${#miss[@]}")); then
    warn "Dependensi belum lengkap: ${miss[*]}"
    say "Pasang dengan: pkg update && pkg install git curl jq openssl coreutils libiconv python"
    return 1
  fi
}
cleanup(){ rm -f "$COOKIE"; }
trap cleanup EXIT

probe(){
  curl -fsS --connect-timeout 3 --max-time 7 "$HOST/" >/dev/null 2>&1
}
open_admin(){
  if command -v termux-open-url >/dev/null 2>&1; then termux-open-url "$HOST" >/dev/null 2>&1 || true
  elif command -v am >/dev/null 2>&1; then am start -a android.intent.action.VIEW -d "$HOST" >/dev/null 2>&1 || true
  else say "Buka browser: $HOST"; fi
}
login(){
  local pass enc res
  if [[ -s "$COOKIE" ]]; then
    # Existing session may still be valid; caller can re-login if API rejects it.
    return 0
  fi
  read -r -s -p "Password admin modem: " pass; printf '\n'
  enc="$(printf '%s' "$pass" | openssl base64 -A)"
  res="$(curl -sS --connect-timeout 4 --max-time 12 -c "$COOKIE" -b "$COOKIE" \
    -e "$HOST/index.html" --data-urlencode 'isTest=false' \
    --data-urlencode 'goformId=LOGIN' --data-urlencode "password=$enc" \
    "$HOST/goform/goform_set_cmd_process" 2>/dev/null || true)"
  unset pass enc
  chmod 600 "$COOKIE" 2>/dev/null || true
  if printf '%s' "$res" | jq -e '(.result=="0") or (.result==0) or (.result=="success")' >/dev/null 2>&1; then
    ok "Login diterima modem."; log "Login diterima"; return 0
  fi
  err "Login tidak terkonfirmasi oleh modem."
  say "Coba login lewat Web Admin, lalu jalankan ulang manager. Build B10 tertentu memakai metode autentikasi berbeda."
  rm -f "$COOKIE"; log "Login tidak terkonfirmasi"; return 1
}
api_get(){
  local cmd="$1"
  curl -fsS --connect-timeout 4 --max-time 18 -b "$COOKIE" -c "$COOKIE" \
    -H 'Accept: application/json, text/javascript, */*; q=0.01' \
    -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' -e "$HOST/index.html" \
    --data-urlencode 'isTest=false' --data-urlencode 'multi_data=1' \
    --data-urlencode "cmd=$cmd" "$HOST/goform/goform_get_cmd_process"
}
api_set(){
  local form="$1"; shift
  local args=(--data-urlencode "isTest=false" --data-urlencode "goformId=$form") p
  for p in "$@"; do args+=(--data-urlencode "$p"); done
  curl -sS --connect-timeout 4 --max-time 20 -b "$COOKIE" -c "$COOKIE" \
    -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' \
    -e "$HOST/index.html" "${args[@]}" "$HOST/goform/goform_set_cmd_process"
}
show_json(){
  local raw="$1"
  if printf '%s' "$raw" | jq . 2>/dev/null; then return 0; fi
  warn "Respons bukan JSON yang dikenali:"
  printf '%s\n' "$raw" | head -c 1200; printf '\n'
}
accepted(){
  printf '%s' "$1" | jq -e '(.result=="success") or (.result=="0") or (.result==0)' >/dev/null 2>&1
}
require_modem(){
  if ! probe; then
    err "Modem tidak terjangkau di $HOST."
    say "Sambungkan HP ke Wi-Fi modem. Jika IP berbeda: MF90_HOST=192.168.0.1 ./mf90-termux-manager.sh"
    return 1
  fi
  login
}

status_menu(){
  line; say "${W}DASHBOARD MODEM${N}"; line
  local d n w q
  say "${C}Firmware & perangkat${N}"
  d="$(api_get 'wa_inner_version,cr_version,hardware_version,web_version,modem_main_state,pin_status,battery_percent')"
  show_json "$d"
  say "${C}Jaringan seluler${N}"
  n="$(api_get 'network_type,network_provider,signalbar,rssi,rscp,lte_rsrp,lte_rsrq,lte_sinr')"
  show_json "$n"
  say "${C}Koneksi data${N}"
  w="$(api_get 'wan_ipaddr,ppp_status,simcard_roam')"
  show_json "$w"
  log "Membaca dashboard status"; pause
}
network_menu(){
  line; say "${W}MODE JARINGAN${N}"; line
  say "1) Otomatis 2G/3G/4G"; say "2) LTE saja"; say "3) 3G saja"; say "4) 2G saja"; say "0) Batal"
  read -r -p "Pilih: " n
  local val=''
  case "$n" in 1) val='NETWORK_auto';; 2) val='Only_LTE';; 3) val='Only_WCDMA';; 4) val='Only_GSM';; 0) return;; *) err "Pilihan tidak valid"; pause; return;; esac
  warn "Koneksi internet mungkin terputus saat modem mengganti mode."
  read -r -p "Ketik UBAH untuk melanjutkan: " conf
  [[ "$conf" == UBAH ]] || { warn "Dibatalkan."; pause; return; }
  api_set 'DISCONNECT_NETWORK' >/dev/null 2>&1 || true
  sleep 2
  local r; r="$(api_set 'SET_BEARER_PREFERENCE' "BearerPreference=$val")"
  show_json "$r"
  accepted "$r" && ok "Permintaan mode jaringan diterima." || warn "Belum ada konfirmasi sukses."
  log "Permintaan mode jaringan $val"; pause
}
apn_view(){
  local r; r="$(api_get 'm_profile_name,Current_index,wan_apn,pdp_type,ppp_auth_mode,wan_dial,dns_mode,APN_config0,APN_config1,APN_config2,APN_config3,APN_config4')"
  show_json "$r"; log "Melihat APN"; pause
}
apn_write(){
  line; say "${W}BUAT / UBAH PROFIL APN${N}"; line
  local idx name apn user pass pdpchoice pdp conf r
  read -r -p "Slot profil (0-19): " idx
  [[ "$idx" =~ ^([0-9]|1[0-9])$ ]] || { err "Slot harus 0-19"; pause; return; }
  read -r -p "Nama profil: " name
  read -r -p "APN operator: " apn
  [[ -n "$apn" ]] || { err "APN tidak boleh kosong"; pause; return; }
  read -r -p "Username (kosong jika tidak ada): " user
  read -r -s -p "Password APN (kosong jika tidak ada): " pass; printf '\n'
  say "PDP: 1 IPv4 | 2 IPv6 | 3 IPv4/IPv6"
  read -r -p "Pilih PDP [1]: " pdpchoice
  case "$pdpchoice" in 2) pdp='IPv6';; 3) pdp='IPv4v6';; *) pdp='IP';; esac
  [[ -n "$name" ]] || name='Internet'
  warn "Slot $idx mungkin menimpa profil yang sudah ada."
  read -r -p "Ketik SIMPAN untuk mengirim perubahan: " conf
  if [[ "$conf" != SIMPAN ]]; then unset pass; warn "Dibatalkan."; pause; return; fi
  r="$(api_set 'APN_PROC_EX' 'apn_action=save' 'apn_mode=manual' 'pdp_select=auto' \
    "profile_name=$name" 'wan_dial=*99#' "pdp_type=$pdp" "index=$idx" \
    "wan_apn=$apn" 'ppp_auth_mode=auto' "ppp_username=$user" "ppp_passwd=$pass" 'dns_mode=auto')"
  unset pass; show_json "$r"
  if accepted "$r"; then
    ok "Modem menerima permintaan simpan APN."
    read -r -p "Jadikan profil default? (y/N): " def
    if [[ "$def" =~ ^[Yy]$ ]]; then
      r="$(api_set 'APN_PROC_EX' 'apn_mode=manual' 'apn_action=set_default' 'set_default_flag=1' "pdp_type=$pdp" "index=$idx")"
      show_json "$r"; accepted "$r" && ok "Permintaan set default diterima." || warn "Set default belum terkonfirmasi."
    fi
  else warn "Penyimpanan APN belum terkonfirmasi."; fi
  log "Mengirim perubahan APN slot $idx"; pause
}
apn_delete(){
  line; say "HAPUS PROFIL APN"; line
  local idx conf r current_raw current
  warn "Profil APN yang dihapus tidak dapat dipulihkan kecuali Anda memiliki catatan/backup."
  read -r -p "Nomor slot APN yang akan dihapus (0-19): " idx
  [[ "$idx" =~ ^([0-9]|1[0-9])$ ]] || { err "Slot harus 0-19."; pause; return; }
  current_raw="$(api_get 'Current_index')" || { err "Tidak dapat membaca profil APN aktif; penghapusan dibatalkan."; pause; return; }
  current="$(printf '%s' "$current_raw" | jq -r '.Current_index // empty' 2>/dev/null)"
  [[ -n "$current" ]] || { err "Indeks APN aktif tidak diketahui; penghapusan dibatalkan demi keamanan."; pause; return; }
  if [[ "$current" == "$idx" ]]; then
    err "Slot $idx adalah profil APN aktif. Pilih profil lain atau ubah profil default terlebih dahulu."
    pause; return
  fi
  say "Profil aktif berada pada slot $current; slot $idx bukan profil aktif."
  read -r -p "Ketik HAPUS-$idx untuk mengonfirmasi: " conf
  [[ "$conf" == "HAPUS-$idx" ]] || { warn "Dibatalkan."; pause; return; }
  r="$(api_set 'APN_PROC_EX' 'apn_action=delete' "index=$idx")"
  show_json "$r"
  accepted "$r" && ok "Modem menerima permintaan hapus slot $idx." || warn "Penghapusan belum terkonfirmasi."
  log "Permintaan hapus profil APN slot $idx"
  pause
}
wan_mode(){
  line; say "MODE DIAL WAN"; line
  say "1) Otomatis (auto_dial)"
  say "2) Manual (manual_dial)"
  say "0) Batal"
  local n mode conf r
  read -r -p "Pilih mode: " n
  case "$n" in
    1) mode="auto_dial";;
    2) mode="manual_dial";;
    0) return;;
    *) err "Pilihan tidak valid."; pause; return;;
  esac
  warn "Mode otomatis dapat memulai koneksi data sesuai profil APN aktif."
  warn "Opsi roaming otomatis tetap OFF untuk menghindari koneksi data roaming."
  read -r -p "Ketik TERAPKAN untuk mengubah mode WAN: " conf
  [[ "$conf" == TERAPKAN ]] || { warn "Dibatalkan."; pause; return; }
  r="$(api_set 'SET_CONNECTION_MODE' "ConnectionMode=$mode" 'roam_setting_option=off')"
  show_json "$r"
  accepted "$r" && ok "Modem menerima mode $mode." || warn "Mode WAN belum terkonfirmasi."
  log "Permintaan mode WAN $mode (roaming off)"
  pause
}

sms_inbox(){
  local raw count i id num body tag dt decoded
  raw="$(curl -fsS --connect-timeout 4 --max-time 20 -b "$COOKIE" -c "$COOKIE" -e "$HOST/index.html" \
    --data-urlencode 'cmd=sms_data_total' --data-urlencode 'page=0' --data-urlencode 'data_per_page=30' \
    --data-urlencode 'mem_store=1' --data-urlencode 'tags=10' --data-urlencode 'order_by=order by id desc' \
    "$HOST/goform/goform_get_cmd_process")" || { err "Gagal membaca SMS."; pause; return; }
  if ! printf '%s' "$raw" | jq -e '.messages|type=="array"' >/dev/null 2>&1; then show_json "$raw"; pause; return; fi
  count="$(printf '%s' "$raw" | jq '.messages|length')"
  (( count > 0 )) || { say "Inbox kosong."; pause; return; }
  for ((i=0;i<count;i++)); do
    id="$(jq -r ".messages[$i].id // \"?\"" <<<"$raw")"
    num="$(jq -r ".messages[$i].number // \"?\"" <<<"$raw")"
    body="$(jq -r ".messages[$i].content // \"\"" <<<"$raw")"
    tag="$(jq -r ".messages[$i].tag // \"?\"" <<<"$raw")"
    dt="$(jq -r ".messages[$i].date // \"?\"" <<<"$raw")"
    decoded="$(python3 -c 'import sys; s=sys.stdin.read().strip(); print(bytes.fromhex(s).decode("utf-16-be",errors="replace") if s else "")' <<<"$body" 2>/dev/null || true)"
    line; say "ID: $id | Nomor: $num | Status: $tag | $dt"; say "$decoded"
  done
  log "Membaca inbox SMS"; pause
}
sms_send(){
  local num msg hex tm conf r
  line; say "${W}KIRIM SMS${N}"; line
  read -r -p "Nomor tujuan (+628xxxxxxxx): " num
  [[ "$num" =~ ^\+[0-9]{8,15}$ ]] || { err "Format nomor tidak valid."; pause; return; }
  read -r -p "Pesan: " msg
  [[ -n "$msg" ]] || { err "Pesan kosong."; pause; return; }
  hex="$(printf '%s' "$msg" | iconv -f UTF-8 -t UTF-16BE | od -An -v -tx1 | tr -d ' \n')"
  tm="$(TZ=Asia/Jakarta date '+%y;%m;%d;%H;%M;%S;+7')"
  warn "SMS mungkin dikenakan biaya operator."
  read -r -p "Ketik KIRIM untuk mengirim: " conf
  [[ "$conf" == KIRIM ]] || { warn "Dibatalkan."; pause; return; }
  r="$(api_set 'SEND_SMS' 'notCallback=true' "Number=$num" "sms_time=$tm" "MessageBody=$hex" 'ID=-1' 'encode_type=UNICODE')"
  show_json "$r"; accepted "$r" && ok "Permintaan SMS diterima modem." || warn "Status pengiriman belum terkonfirmasi."
  log "Permintaan SMS dikirim ke $num"; pause
}
wifi_menu(){
  line; say "${W}PENGATURAN WI-FI${N}"; line
  warn "API tulis SSID/password belum diverifikasi pada setiap build Beeline B10."
  say "Web Admin akan dibuka. Cari menu Wi-Fi / WLAN / SSID / Security."
  say "Gunakan WPA2-AES dan password unik; jangan bagikan password admin."
  open_admin; log "Membuka halaman Wi-Fi Web Admin"; pause
}
ussd_menu(){
  line; say "${W}USSD${N}"; line
  warn "Endpoint USSD belum dipastikan untuk semua build B10."
  say "Gunakan menu USSD di Web Admin bila tersedia."
  open_admin; log "Membuka halaman USSD Web Admin"; pause
}
band_menu(){
  line; say "${W}INFO SINYAL & BAND${N}"; line
  local r; r="$(api_get 'network_type,network_provider,signalbar,rssi,rscp,lte_rsrp,lte_rsrq,lte_sinr,bandinfo,earfcn')"
  show_json "$r"
  warn "Penguncian LTE band sengaja tidak diaktifkan: endpoint dan nilai band harus diverifikasi pada unit ini."
  log "Pemeriksaan band tanpa mengubah konfigurasi"; pause
}
backup_menu(){
  local stamp f d a b
  stamp="$(date '+%Y%m%d_%H%M%S')"; f="$BACKUP_DIR/MF90_B10_$stamp.json"
  d="$(api_get 'wa_inner_version,cr_version,hardware_version,web_version,modem_main_state,network_type,network_provider,signalbar,rssi,lte_rsrp,ppp_status')"
  a="$(api_get 'm_profile_name,Current_index,wan_apn,pdp_type,ppp_auth_mode,wan_dial,ppp_username,ppp_passwd,dns_mode,APN_config0,APN_config1,APN_config2,APN_config3,APN_config4')"
  b="$(api_get 'APN_config5,APN_config6,APN_config7,APN_config8,APN_config9,APN_config10,APN_config11,APN_config12,APN_config13,APN_config14,APN_config15,APN_config16,APN_config17,APN_config18,APN_config19')"
  if jq -n --argjson device "$d" --argjson apn "$a" --argjson more "$b" \
    '{created_at:(now|todate),device:"ZTE MF90",firmware_target:"Beeline B10",status:$device,apn:($apn | .ppp_passwd="[REDACTED]" | with_entries(if (.key|startswith("APN_config")) then .value="[REDACTED: profile may contain credentials]" else . end)),apn_extra:($more | with_entries(if (.key|startswith("APN_config")) then .value="[REDACTED: profile may contain credentials]" else . end))}' >"$f" 2>/dev/null; then
    chmod 600 "$f"; ok "Backup lokal: $f"
    warn "Backup dapat memuat kredensial APN. Jangan unggah ke GitHub atau kirim ke orang lain."
    log "Backup konfigurasi dibuat: $(basename "$f")"
  else err "Backup gagal: respons API tidak valid."; rm -f "$f"; fi
  pause
}
restore_info(){
  local files=( "$BACKUP_DIR"/*.json ) f n=0
  [[ -e "${files[0]}" ]] || { warn "Belum ada backup."; pause; return; }
  for f in "${files[@]}"; do ((n+=1)); printf '%d) %s\n' "$n" "$(basename "$f")"; done
  read -r -p "Nomor file (0 batal): " n
  [[ "$n" =~ ^[0-9]+$ ]] && ((n>0 && n<=${#files[@]})) || { warn "Dibatalkan."; pause; return; }
  f="${files[$((n-1))]}"
  jq -e '.device=="ZTE MF90" and (.apn|type=="object")' "$f" >/dev/null || { err "Backup tidak valid."; pause; return; }
  say "Ringkasan profil APN dari backup:"
  jq -r '.apn | to_entries[] | select(.key|startswith("APN_config")|not) | "\(.key): \(.value)"' "$f" 2>/dev/null || true
  say "Data profil mentah juga tersimpan pada bagian APN_config0..19."
  warn "Restore otomatis tidak dijalankan karena format serialisasi APN berbeda antar firmware."
  say "Gunakan menu APN modem untuk memasukkan kembali nilai yang diperlukan."
  open_admin; pause
}

wan_action(){
  line; say "${W}KONTROL KONEKSI WAN${N}"; line
  say "1) Hubungkan internet seluler"
  say "2) Putuskan koneksi internet seluler"
  say "0) Batal"
  local n form confirm r
  read -r -p "Pilih: " n
  case "$n" in
    1) form='CONNECT_NETWORK';;
    2) form='DISCONNECT_NETWORK';;
    0) return;;
    *) err "Pilihan tidak valid."; pause; return;;
  esac
  if [[ "$form" == CONNECT_NETWORK ]]; then
    warn "Modem akan mencoba membuat koneksi data seluler menggunakan profil APN aktif."
    read -r -p "Ketik HUBUNGKAN untuk melanjutkan: " confirm
    [[ "$confirm" == HUBUNGKAN ]] || { warn "Dibatalkan."; pause; return; }
  else
    warn "Perangkat yang memakai internet modem akan kehilangan koneksi."
    read -r -p "Ketik PUTUSKAN untuk melanjutkan: " confirm
    [[ "$confirm" == PUTUSKAN ]] || { warn "Dibatalkan."; pause; return; }
  fi
  r="$(api_set "$form")"
  show_json "$r"
  accepted "$r" && ok "Modem menerima perintah $form." || warn "Respons belum mengonfirmasi keberhasilan."
  log "Permintaan WAN: $form"
  pause
}
health_check(){
  line; say "${W}DIAGNOSTIK JARINGAN${N}"; line
  say "Host modem : $HOST"
  if probe; then ok "Web Admin modem dapat dijangkau."
  else err "Web Admin modem tidak merespons."; fi
  if command -v ip >/dev/null 2>&1; then
    say "\nRute jaringan lokal:"
    ip route 2>/dev/null | head -n 8 || true
  fi
  say "\nUji DNS/Internet (maks. 8 detik):"
  if curl -fsSI --connect-timeout 3 --max-time 8 https://www.cloudflare.com/ >/dev/null 2>&1; then
    ok "Akses HTTPS internet berhasil."
  else
    warn "HTTPS internet gagal/tidak terjangkau. Periksa APN, sinyal, dan paket data."
  fi
  say "\nStatus modem (kelompok kecil):"
  local r
  r="$(api_get 'modem_main_state,network_type,network_provider,signalbar,wan_ipaddr,ppp_status')"
  show_json "$r"
  log "Diagnostik jaringan dijalankan"
  pause
}

update_manager(){
  line; say "${W}SINKRONISASI GITHUB${N}"; line
  if ! command -v git >/dev/null 2>&1; then err "Git belum terpasang."; pause; return; fi
  if [[ ! -d "$SCRIPT_DIR/.git" ]]; then
    warn "Folder manager bukan clone Git; pembaruan otomatis dilewati."
    say "Gunakan git clone dari repository resmi."
    pause; return
  fi
  warn "Pembaruan hanya fast-forward; perubahan lokal tidak akan ditimpa paksa."
  read -r -p "Ketik UPDATE untuk menjalankan git pull --ff-only: " confirm
  [[ "$confirm" == UPDATE ]] || { warn "Dibatalkan."; pause; return; }
  local rc=0
  if git -C "$SCRIPT_DIR" pull --ff-only; then
    ok "Sinkronisasi selesai. Jalankan ulang manager agar versi baru aktif."
  else
    rc=$?
    warn "Git pull gagal atau ada perubahan lokal. Periksa status repository secara manual."
  fi
  log "GitHub sync selesai dengan kode $rc"
  pause
}

firmware_info(){
  line; say "${W}FIRMWARE BEELINE B10${N}"; line
  say "Manager ini bukan firmware dan bukan flasher."
  say "Tidak menyertakan image Beeline B10 karena image harus cocok dengan revisi hardware MF90."
  say "Jangan flash image dari model/revisi lain. Risiko: modem brick / gagal boot."
  say "Versi firmware aktual dapat dilihat dari Dashboard atau Web Admin."
  open_admin; pause
}
menu(){
  clear 2>/dev/null || true
  line
  say "${C}   ███████╗████████╗███████╗   MF90${N}"
  say "${C}   ╚══███╔╝╚══███╔╝██╔════╝   BEELINE B10${N}"
  say "${C}     ███╔╝   ███╔╝ █████╗     TERMUX MANAGER${N}"
  say "${C}    ███╔╝   ███╔╝  ██╔══╝${N}"
  say "${C}   ███████╗███████╗███████╗   ${W}ADVANCED${N}"
  line
  say " Modem : ${W}$HOST${N}"; say " Data  : $DATA_DIR"
  say ""
  say " ${G}01${N}  Dashboard modem & sinyal"
  say " ${G}02${N}  Pilih jaringan 2G / 3G / 4G"
  say " ${G}03${N}  Lihat profil APN"
  say " ${G}04${N}  Tambah / ubah APN"
  say " ${G}05${N}  Inbox SMS"
  say " ${G}06${N}  Kirim SMS"
  say " ${G}07${N}  Wi-Fi / SSID / password (Web Admin)"
  say " ${G}08${N}  USSD (Web Admin)"
  say " ${G}09${N}  Pemeriksaan band LTE"
  say " ${G}10${N}  Backup konfigurasi lokal"
  say " ${G}11${N}  Restore / lihat backup APN"
  say " ${G}12${N}  Informasi firmware Beeline B10"
  say " ${G}13${N}  Buka Web Admin"
  say " ${G}14${N}  Hubungkan / putuskan WAN"
  say " ${G}15${N}  Diagnostik koneksi & internet"
  say " ${G}16${N}  Sinkronisasi update dari GitHub"
  say " ${G}17${N}  Hapus profil APN"
  say " ${G}18${N}  Mode dial WAN otomatis / manual"
  say " ${R}00${N}  Keluar"
  line
  read -r -p " Pilih menu: " choice
  case "$choice" in
    0|00) exit 0;;
    13) open_admin; pause; return;;
    14) require_modem || { pause; return; }; wan_action; return;;
    15) require_modem || { pause; return; }; health_check; return;;
    16) update_manager; return;;
    17) require_modem || { pause; return; }; apn_delete; return;;
    18) require_modem || { pause; return; }; wan_mode; return;;
    12) firmware_info; return;;
    *) require_modem || { pause; return; };;
  esac
  case "$choice" in
    1|01) status_menu;; 2|02) network_menu;; 3|03) apn_view;; 4|04) apn_write;;
    5|05) sms_inbox;; 6|06) sms_send;; 7|07) wifi_menu;; 8|08) ussd_menu;;
    9|09) band_menu;; 10) backup_menu;; 11) restore_info;;
    *) warn "Menu tidak tersedia."; pause;;
  esac
}
main(){
  install_deps || exit 1
  while true; do menu; done
}
main "$@"
