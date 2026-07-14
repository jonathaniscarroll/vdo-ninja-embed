# vdo-ninja-embed

A minimal GitHub Pages site that embeds a [VDO.Ninja](https://vdo.ninja) live stream via iframe.

## Setup

1. Edit `index.html` and replace `YOUR_STREAM_ID` with your VDO.Ninja stream ID.
   - If your push link is `https://vdo.ninja/?push=AbCdEf`, your stream ID is `AbCdEf`.
2. Enable GitHub Pages in **Settings → Pages → Source: Deploy from branch → `main` / `/ (root)`**.
3. Your stream page will be live at `https://jonathaniscarroll.github.io/vdo-ninja-embed/`.

## URL Parameters

| Parameter | Effect |
|---|---|
| `&cleanoutput` | Hides VDO.Ninja UI chrome |
| `&autoplay` | Auto-starts video on load |
| `&muted` | Mutes audio (required for silent autoplay) |
| `&transparent` | Transparent background |
| `&codec=h264` | Force H.264 codec |

## IFRAME API

For advanced control (mute, swap streams, get video frames), see the [VDO.Ninja IFRAME API docs](https://docs.vdo.ninja/guides/iframe-api-documentation).
