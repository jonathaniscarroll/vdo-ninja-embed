# vdo-ninja-embed

A self-hosted [VDO.Ninja](https://vdo.ninja) setup that runs the full web app **and** signaling server locally over HTTPS/WSS — so it works on your machine and on other devices on the same LAN without any external service.

Originally built for an installation where an Arduino bridges a physical model train with a Unity simulation, with video streamed between devices over a local network.

---

## Overview

| Component | What it does |
|---|---|
| `lan-run.js` | Single entry point — starts the web server and signaling server together, auto-detects your LAN IP |
| `serve.js` | Hosts the VDO.Ninja web files over HTTPS using local SSL certs |
| `ssl/` | Self-signed certificates for localhost and your LAN IP |
| `vdoninja/` | Vendored copy of the VDO.Ninja web app (patched for local certs + port) |
| `websocket_server/` | Vendored copy of VDO.Ninja's signaling server (patched for local port) |

---

## Prerequisites

- **Node.js** v18 or later — [nodejs.org](https://nodejs.org)
- **OpenSSL** (comes with macOS; on Windows use Git Bash or WSL)
- A local network (Wi-Fi or Ethernet) shared between your devices

---

## First-Time Setup

### 1. Clone the repo

```bash
git clone https://github.com/jonathaniscarroll/vdo-ninja-embed.git
cd vdo-ninja-embed
```

### 2. Install dependencies

```bash
npm install
cd websocket_server && npm install && cd ..
```

### 3. Generate SSL certificates

The SSL certs must be tied to your current LAN IP. Run the setup script:

```bash
bash setup-certs.sh
```

This creates `ssl/cert.pem` and `ssl/key.pem` signed for both `localhost` and your current LAN IP (e.g. `192.168.10.102`).

> **Note:** If your IP changes (different Wi-Fi, DHCP renewal), repeat this step and restart the server.

### 4. Start the server

```bash
node lan-run.js
```

You should see output like:

```
✅  VDO.Ninja HTTPS server running
  Serving from: /path/to/vdo-ninja-embed/vdoninja

  This machine:   https://localhost:8443
  This machine:   https://localhost:8443/iframe.html

  LAN devices:    https://192.168.10.102:8443
  LAN devices:    https://192.168.10.102:8443/iframe.html

  ⚠️   LAN devices will see a cert warning — click Advanced → Proceed
  Signaling:      wss://192.168.10.102:8444

  Press Ctrl+C to stop.

Server started on port 8444
```

---

## Accessing the App

### On this Mac (host machine)

```
https://localhost:8443/?wss=wss://localhost:8444
```

### On other LAN devices (phones, tablets, other computers)

**Step 1 — Accept the signaling server cert first:**

Open this URL in the browser and click through the security warning (Advanced → Proceed):

```
https://192.168.10.102:8444
```

The page may appear blank — that's fine. You just need the browser to trust the cert.

**Step 2 — Open the app:**

```
https://192.168.10.102:8443/?wss=wss://192.168.10.102:8444
```

Click through the cert warning again if prompted (this is a separate cert for the web server).

**Step 3 — Optional: iframe API tester:**

```
https://192.168.10.102:8443/iframe.html?wss=wss://192.168.10.102:8444
```

> Replace `192.168.10.102` with the IP shown in your `lan-run.js` output.

---

## Testing the Connection

Open the app on two devices (or two browser tabs):

- **Sender:** `https://192.168.10.102:8443/?push=test1&wss=wss://192.168.10.102:8444`
- **Viewer:** `https://192.168.10.102:8443/?view=test1&wss=wss://192.168.10.102:8444`

If the viewer shows the sender's camera feed, the full local setup is working.

---

## When Your IP Changes

Every time your Mac's LAN IP changes (different Wi-Fi, different network, DHCP lease renewal):

```bash
bash setup-certs.sh    # regenerate cert for the new IP
node lan-run.js         # restart with the new IP
```

Re-share the new IP-based URLs with any LAN devices.

---

## IFRAME API

Send commands to the embedded VDO.Ninja instance via `postMessage`:

```js
const iframe = document.querySelector('iframe');

// Mute / unmute
iframe.contentWindow.postMessage({ mute: true }, '*');
iframe.contentWindow.postMessage({ mute: false }, '*');
iframe.contentWindow.postMessage({ mute: 'toggle' }, '*');

// Volume (0.0 – 1.0)
iframe.contentWindow.postMessage({ volume: 0.5 }, '*');

// Bitrate
iframe.contentWindow.postMessage({ bitrate: 5000 }, '*');  // high quality
iframe.contentWindow.postMessage({ bitrate: 30 }, '*');    // low bandwidth
iframe.contentWindow.postMessage({ bitrate: -1 }, '*');    // default

// Stats and loudness
iframe.contentWindow.postMessage({ getStats: true }, '*');
iframe.contentWindow.postMessage({ getLoudness: true }, '*');

// Reload / disconnect
iframe.contentWindow.postMessage({ reload: true }, '*');
iframe.contentWindow.postMessage({ close: true }, '*');
```

Full sandbox: [vdo.ninja/iframe](https://vdo.ninja/iframe) | Source: [iframe.html on GitHub](https://github.com/steveseguin/vdoninja/blob/master/iframe.html)

---

## `iframe` Permissions

The iframe uses the full permission string from the official VDO.Ninja docs:

```
encrypted-media;sync-xhr;usb;web-share;midi *;geolocation;camera *;microphone *;
fullscreen;picture-in-picture;display-capture;accelerometer;autoplay;gyroscope;screen-wake-lock;
```

---

## Transparency

The iframe has `allowtransparency="true"` and the view URL includes `&transparent`, so the video background is `rgba(0,0,0,0)`. Remove `&transparent` from the `src` if you want VDO.Ninja's default dark background.

---

## Securing Your Stream

Use `&audience` (VDO.Ninja v25.2+) so only you can publish to the stream ID. See the [&audience docs](https://docs.vdo.ninja/advanced-settings/setup-parameters/and-audience).

---

## Troubleshooting

**LAN devices can't connect:**
- Make sure both devices are on the same Wi-Fi network
- Accept the cert warning on **both** `https://<ip>:8444` AND `https://<ip>:8443` — missing either one will block the connection
- Check that your Mac's firewall allows incoming connections on ports 8443 and 8444

**Cert warning persists after accepting:**
- Try in a different browser, or clear the browser's certificate exceptions for the IP
- Regenerate certs with `bash setup-certs.sh` and restart

**IP address changed:**
- Run `bash setup-certs.sh` again to regenerate certs for the new IP, then restart with `node lan-run.js`

**Signaling connects but no video:**
- Confirm both the push and view `?wss=` parameter point to the same signaling server URL
- Try the two-tab test on the same machine first to isolate the issue

---

## Project Context

This setup is part of a physical installation connecting:
- An **Arduino** reading the state of a real model train
- **Unity** rendering a virtual train simulation
- **VDO.Ninja** streaming live video between physical and virtual environments over LAN

The GitHub Pages site at [jonathaniscarroll.github.io/vdo-ninja-embed](https://jonathaniscarroll.github.io/vdo-ninja-embed/) is the public-facing embed. The local server described above is used for on-site LAN streaming during the installation.

---

## Resources

- [VDO.Ninja official docs](https://docs.vdo.ninja)
- [VDO.Ninja iframe guide](https://docs.vdo.ninja/guides/how-to-use-vdo.ninja-on-a-website)
- [steveseguin/vdo.ninja on GitHub](https://github.com/steveseguin/vdo.ninja)
- [steveseguin/websocket_server on GitHub](https://github.com/steveseguin/websocket_server)
