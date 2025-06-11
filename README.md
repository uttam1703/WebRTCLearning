# WebRTCLearning

A **video calling app demo** built in **Swift** and **UIKit** using **WebRTC** and a local **WebSocket** signaling client over Wi-Fi, following the **MVVM** architecture.

---

## 🚀 Features

* 🔗 **Peer-to-Peer Video Call**: Establishes a direct video call between two iOS devices on the same Wi-Fi network.
* 🛰️ **WebSocket Signaling**: Uses a lightweight WebSocket client for signaling and session negotiation.
* 🏗️ **MVVM Architecture**: Clean separation of Model, View, and ViewModel for maintainable code.
* 🎨 **UIKit Interface**: Customizable UI built with UIKit components.
* 🔄 **Async/Await**: Modern Swift concurrency patterns for network and WebRTC callbacks.

---

## 🛠️ Tech Stack

* **Language:** Swift 5+
* **UI Framework:** UIKit
* **Architecture:** MVVM
* **Signaling:** WebSocket (URLSessionWebSocketTask)
* **Media:** WebRTC (Google’s WebRTC SDK)

---

## 📦 Requirements

* Xcode 14 or later
* iOS 14+ target
* Local Wi-Fi network
* Two iOS devices on the same network

---

## 🎬 Usage

1. **Launch the app** on both devices.
2. **Enter the peer ID** of the other device (displayed upon launch).
3. **Tap “Connect”** to initiate WebSocket signaling.
4. Once signaling completes, **video streams** will appear on both screens.
5. **End call** by tapping the disconnect button.

---


