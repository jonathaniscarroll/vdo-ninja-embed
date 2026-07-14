# vdo-ninja-embed

A minimal [GitHub Pages](https://pages.github.com/) site that embeds a [VDO.Ninja](https://vdo.ninja) live stream via iframe, following the [official VDO.Ninja iframe docs](https://docs.vdo.ninja/guides/how-to-use-vdo.ninja-on-a-website).

## Stream ID

Currently set to `Ce4HsNS`. Edit the `STREAM_ID` variable in `index.html` to change it.

## Setup

1. Enable GitHub Pages — go to **Settings → Pages → Source: Deploy from branch → `main` / `/ (root)`**.
2. Your page will be live at `https://jonathaniscarroll.github.io/vdo-ninja-embed/`.

## `allow` Attribute

The iframe uses the full permission string from the official docs:

```
encrypted-media;sync-xhr;usb;web-share;midi *;geolocation;camera *;microphone *;
fullscreen;picture-in-picture;display-capture;accelerometer;autoplay;gyroscope;screen-wake-lock;
```

## IFRAME API

Send commands to the embedded instance via `postMessage`:

```js
// Mute/unmute speaker
iframe.contentWindow.postMessage({ mute: true }, '*');
iframe.contentWindow.postMessage({ mute: false }, '*');
iframe.contentWindow.postMessage({ mute: 'toggle' }, '*');

// Volume
iframe.contentWindow.postMessage({ volume: 0.5 }, '*');

// Bitrate
iframe.contentWindow.postMessage({ bitrate: 5000 }, '*');  // high
iframe.contentWindow.postMessage({ bitrate: 30 }, '*');    // low
iframe.contentWindow.postMessage({ bitrate: -1 }, '*');    // default

// Stats + loudness
iframe.contentWindow.postMessage({ getStats: true }, '*');
iframe.contentWindow.postMessage({ getLoudness: true }, '*');

// Reload / disconnect
iframe.contentWindow.postMessage({ reload: true }, '*');
iframe.contentWindow.postMessage({ close: true }, '*');
```

Full sandbox: [vdo.ninja/iframe](https://vdo.ninja/iframe) | Source: [iframe.html on GitHub](https://github.com/steveseguin/vdoninja/blob/master/iframe.html)

## Transparency

The iframe has `allowtransparency="true"` and the view URL includes `&transparent`, so the video background is `rgba(0,0,0,0)`. Remove `&transparent` from the `src` if you want VDO.Ninja's default dark background.

## Securing Your Stream

Use `&audience` (VDO.Ninja v25.2+) so only you can publish to the stream ID. See the [&audience docs](https://docs.vdo.ninja/advanced-settings/setup-parameters/and-audience).
