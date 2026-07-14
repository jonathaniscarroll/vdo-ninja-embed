# Running VDO.Ninja Locally

This guide follows the official [steveseguin/vdo.ninja install.md](https://github.com/steveseguin/vdo.ninja/blob/develop/install.md).

---

## What you need

- **Node.js** (any recent LTS — used only to run `serve.js`; no npm install required)
- **Git** (to clone the VDO.Ninja source)
- A modern browser (Chrome or Edge recommended for full WebRTC + credentialless iframe support)

---

## Quick Start (5 steps)

### 1 — Clone VDO.Ninja source next to this repo

```bash
# From the folder that contains this repo:
git clone https://github.com/steveseguin/vdo.ninja vdoninja
```

Your directory should now look like:
```
vdoninja/          ← full VDO.Ninja source (steveseguin develop branch)
  index.html
  main.js
  webrtc.js
  iframe.html
  ...
serve.js           ← local dev server (in THIS repo)
iframe.html        ← your custom iframe API page
index.html         ← your custom embed page
README-local.md    ← this file
```

> **Alternative**: if you want to serve your own customized files instead  
> (your `iframe.html`, `index.html`, etc.), just copy the full VDO.Ninja repo  
> INTO this folder and let `serve.js` auto-detect `index.html` here.

### 2 — Start the local server

```bash
node serve.js
# or specify a port:
node serve.js 3000
```

You'll see:
```
Serving from: /path/to/vdoninja

  ✅  VDO.Ninja local server running
  👉  http://localhost:8443
  👉  http://localhost:8443/iframe.html
```

### 3 — Open in Chrome/Edge

```
http://localhost:8443
```

Camera and microphone access will work because `localhost` is treated as a  
**secure context** by all browsers, even over plain HTTP.

### 4 — Test your iframe API page

```
http://localhost:8443/iframe.html
```

Paste any VDO.Ninja URL (e.g. `https://vdo.ninja/?view=abc123`) into the  
address bar and click **Load**. The COOP + COEP headers served by `serve.js`  
enable credentialless iframes in Chrome.

### 5 — Keep VDO.Ninja updated

```bash
cd vdoninja
git pull
```

Steve recommends updating every few months at minimum as the app changes frequently.

---

## How `serve.js` works

`serve.js` is a zero-dependency Node.js HTTP server that adds two critical headers
to **every** response:

| Header | Value | Why |
|--------|-------|-----|
| `Cross-Origin-Opener-Policy` | `same-origin` | Required for `SharedArrayBuffer` (audio worklets) |
| `Cross-Origin-Embedder-Policy` | `require-corp` | Required for cross-origin isolation + credentialless iframes |

Without these headers, features like `SharedArrayBuffer` and credentialless  
iframe embedding are blocked by the browser even on localhost.

File lookup order for any URL path:
1. Exact file match
2. Path + `.html`
3. Path + `/index.html`
4. SPA fallback → `index.html`

---

## Serving your custom files vs. stock VDO.Ninja

By default `serve.js` looks for `./vdoninja/index.html` first, then `./index.html`.  
If you want your customized `iframe.html` and `index.html` (from this repo) to be  
served **instead of** the stock ones, copy all VDO.Ninja files into this directory  
(the root of this repo) and let them coexist — your modified files will simply  
overwrite the stock ones.

```bash
cp -r vdoninja/. .
# Then edit iframe.html / index.html as desired
node serve.js
```

---

## Troubleshooting

### Camera/mic not working
- Make sure you are on `http://localhost:…` (not a local IP like `192.168.x.x`)
- On Chrome, `localhost` is a secure context even without HTTPS
- If accessing from another device on LAN, you **must** use HTTPS — see the
  [SSL section of install.md](https://github.com/steveseguin/vdo.ninja/blob/develop/install.md#internet-free-deployments)

### "SharedArrayBuffer is not defined"
- The COOP/COEP headers are not being sent — confirm `serve.js` is running
  (not another server like `python -m http.server`)

### Iframe shows blank / blocked
- The target URL (`https://vdo.ninja/…`) must include `&allowIFrame` or equivalent
  parameter, otherwise VDO.Ninja blocks being embedded
- Try: `https://vdo.ninja/?view=STREAMID&allowIFrame`

### Port already in use
```bash
node serve.js 3000   # use a different port
```

---

## Optional: Full offline / LAN deployment

For a fully internet-free setup (air-gapped LAN), you also need to run your own
handshake (signalling) server. Steve provides a ready-made script:

```bash
git clone https://github.com/steveseguin/websocket_server
```

Then update the `wss` line near the top of `vdoninja/index.html` to point to
your local signalling server. See
[install.md — Handshake server deployment](https://github.com/steveseguin/vdo.ninja/blob/develop/install.md#hand-shake-server-deployment)
for details.

---

## License

VDO.Ninja source is licensed AGPLv3 by Steve Seguin.
This repo's additions (`serve.js`, `iframe.html`, `index.html`, `README-local.md`)
are provided under the same AGPLv3 terms.
