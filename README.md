# vdo-ninja-embed

A minimal [GitHub Pages](https://pages.github.com/) site that embeds a [VDO.Ninja](https://vdo.ninja) live stream via iframe, following the [official VDO.Ninja embedding docs](https://docs.vdo.ninja/guides/how-to-use-vdo.ninja-on-a-website).

## Setup

1. **Edit `index.html`** — replace `YOUR_STREAM_ID` with your VDO.Ninja stream ID.
   - If your push link is `https://vdo.ninja/?push=JkYwyxy`, your ID is `JkYwyxy`.
2. **Enable GitHub Pages** — go to **Settings → Pages → Source: Deploy from branch → `main` / `/ (root)`**.
3. Your page will be live at `https://jonathaniscarroll.github.io/vdo-ninja-embed/`.

## How It Works

The `<iframe>` `src` is set **on button click** rather than on page load. This is required because browsers block audio autoplay unless a user gesture has already occurred on the page.

The page also wires up the **VDO.Ninja IFRAME API** (`postMessage`) to receive connection events and display a status message.

## Key URL Parameters

| Parameter | Effect |
|---|---|
| `&cleanoutput` | Hides VDO.Ninja UI chrome — shows only video |
| `&autoplay` | Auto-starts video after user gesture |
| `&muted` | Mutes audio (allows silent autoplay without gesture) |
| `&transparent` | Transparent background (also set `allowtransparency="true"` on iframe) |
| `&codec=h264` | Force H.264 codec |

## Security: Audience Parameter

For public deployments, use the `&audience` parameter (VDO.Ninja v25.2+) so viewers can't publish to your stream ID:

- Push link: `https://vdo.ninja/?audience=YOUR_TOKEN&push=YOUR_STREAM_ID`
- View link: `https://vdo.ninja/?audience=VIEWER_TOKEN&view=YOUR_STREAM_ID`

See the [VDO.Ninja audience docs](https://docs.vdo.ninja/guides/how-to-use-vdo.ninja-on-a-website) for details.

## IFRAME API

Send commands to the embedded VDO.Ninja instance via `postMessage`:

```js
// Mute speakers
iframe.contentWindow.postMessage({ mute: true }, '*');

// Get current stream IDs
iframe.contentWindow.postMessage({ getStreamIDs: true, cib: 'my-callback' }, '*');
```

Full reference: [VDO.Ninja IFRAME API Basics](https://docs.vdo.ninja/guides/iframe-api-documentation/iframe-api-basics)
