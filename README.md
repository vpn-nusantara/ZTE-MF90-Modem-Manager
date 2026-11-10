# 🚀 ZTE MF90 Modem Manager

**Android-based tools for managing and inspecting the ZTE MF90 LTE modem.**

ZTE MF90 Modem Manager is a community project by **VPN-NUSANTARA**. It is intended to make selected modem-management tasks easier from an Android device using Termux.

## ✨ Project features

Depending on modem firmware and available interfaces, the project may provide tools for:

- 📡 Inspecting LTE network and modem status
- 📶 Exploring LTE band information and band-lock capabilities
- 🔧 Sending supported AT commands
- 🌐 Inspecting modem configuration and API endpoints
- 📱 Running supported utilities from Android with Termux

> Feature availability depends on the modem, firmware, connection method, and the scripts included in this repository. Check each script's instructions before running it.

## 📱 Target device

| Item | Details |
|---|---|
| Modem | ZTE MF90 |
| Hardware revision | xq5B (tested target) |
| Firmware | BD_RUS_BEELINE_MF90V1.0.0B10 (tested target) |
| Operating environment | Android + Termux |

Other hardware revisions or firmware versions may behave differently and are not guaranteed to be compatible.

## ⚠️ Wi-Fi 5 GHz support

**5 GHz Wi-Fi is currently NOT supported by this project.**

This project currently focuses on the modem's 4G LTE management capabilities. Wi-Fi band support depends on the physical hardware and firmware; a software update alone cannot add 5 GHz capability if the device hardware does not support it.

## 🚧 Important notes

- Back up your modem configuration before making changes.
- Incorrect AT commands or configuration changes may interrupt connectivity or require a reset.
- Use only commands you understand and verify that they apply to your exact firmware.
- This project is provided as-is, without a guarantee that every feature will work on every device.
- You are responsible for any changes made to your modem.

## 💖 Support development — Donate via QRIS

If this project helps you, you can support continued development through **QRIS**.

Your contribution helps with testing, bug fixes, documentation, and development of new features.

**Thank you for supporting this project! ❤️**

> The QRIS image has not been added to this repository yet. The developer can add it as `assets/qris.png` and update this section to display it.

## 👨‍💻 Developer

**VPN-NUSANTARA**

If you find this project useful, please ⭐ star the repository and share feedback or bug reports through GitHub Issues.

---

*ZTE MF90 Modem Manager — Manage your modem, your way.*
