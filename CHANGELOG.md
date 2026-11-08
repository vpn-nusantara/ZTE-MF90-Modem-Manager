# Changelog

## 2026-11-08 — ADVANCED Termux update

- Added confirmed WAN connect/disconnect actions with explicit typed confirmation.
- Added network diagnostics for modem reachability, local route, HTTPS connectivity, and a compact modem status query.
- Added an in-menu GitHub updater using `git pull --ff-only` so local changes are not force-overwritten.
- Split dashboard reads into smaller API groups to reduce the risk of overloading the modem API.
- Redacted APN password in newly created local backup exports.
- Updated installation, menu, compatibility, and security documentation.
- Kept Wi-Fi SSID/password changes in Web Admin because the available Beeline B10 API documentation does not verify WLAN write endpoints.
- Added APN profile deletion with slot-specific typed confirmation and a guard that blocks deleting the active profile.
- Added WAN auto/manual dial mode selection, keeping automatic roaming disabled.
- Rebranded the interactive CLI from ULTIMATE to ADVANCED.
- No firmware flashing, NV/partition writes, or LTE band-lock writes are included.
