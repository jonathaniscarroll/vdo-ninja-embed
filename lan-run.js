#!/usr/bin/env node
const { spawn, exec } = require('child_process');
const path = require('path');
const os = require('os');

const root = __dirname;
const signalScript = path.join(root, 'websocket_server', 'vdoninja.js');
const webScript = path.join(root, 'serve.js');

const SIGNAL_PORT = process.env.SIGNAL_PORT || '8444';
const WEB_PORT    = process.env.WEB_PORT    || '8443';

function getLanIP() {
  const ifaces = os.networkInterfaces();
  for (const name of Object.keys(ifaces)) {
    for (const iface of ifaces[name]) {
      if (iface.family === 'IPv4' && !iface.internal) return iface.address;
    }
  }
  return '127.0.0.1';
}

const LAN_IP = getLanIP();

// Open a URL in the default browser (macOS / Linux / Windows)
function openURL(url) {
  const cmd =
    process.platform === 'darwin'  ? `open "${url}"` :
    process.platform === 'win32'   ? `start "" "${url}"` :
                                     `xdg-open "${url}"`;
  exec(cmd, err => { if (err) console.warn(`  Could not open browser: ${err.message}`); });
}

function run(name, cmd, args, opts = {}) {
  const child = spawn(cmd, args, {
    cwd:   opts.cwd || root,
    env:   { ...process.env, ...opts.env },
    stdio: 'inherit',
    shell: process.platform === 'win32',
  });
  child.on('exit', code => {
    console.log(`${name} exited with code ${code}`);
    process.exit(code || 0);
  });
  return child;
}

const signal = run(
  'signal',
  'node',
  [signalScript],
  {
    cwd: path.join(root, 'websocket_server'),
    env: { PORT: SIGNAL_PORT }
  }
);

const web = run(
  'web',
  'node',
  [webScript, WEB_PORT],
  {
    cwd: root,
    env: { VDO_SIGNAL_URL: `wss://${LAN_IP}:${SIGNAL_PORT}` }
  }
);

// Print URLs and open the local one after a short delay so the
// server has time to bind before the browser hits it.
setTimeout(() => {
  const localURL = `https://localhost:${WEB_PORT}/?wss=wss://localhost:${SIGNAL_PORT}`;
  const lanURL   = `https://${LAN_IP}:${WEB_PORT}/?wss=wss://${LAN_IP}:${SIGNAL_PORT}`;

  console.log('');
  console.log('  \u2705  VDO.Ninja HTTPS server running');
  console.log(`  Serving from: ${path.join(root, 'vdoninja')}`);
  console.log('');
  console.log(`  This machine:   ${localURL}`);
  console.log(`  This machine:   https://localhost:${WEB_PORT}/iframe.html`);
  console.log('');
  console.log(`  LAN devices:    ${lanURL}`);
  console.log(`  LAN devices:    https://${LAN_IP}:${WEB_PORT}/iframe.html`);
  console.log('');
  console.log('  \u26a0\ufe0f   LAN devices will see a cert warning \u2014 click Advanced \u2192 Proceed');
  console.log(`  Signaling:      wss://${LAN_IP}:${SIGNAL_PORT}`);
  console.log('');
  console.log('  Press Ctrl+C to stop.');
  console.log('');

  // Open the local app URL automatically
  console.log(`  Opening ${localURL} ...`);
  openURL(localURL);
}, 1500);

function shutdown() {
  signal.kill('SIGINT');
  web.kill('SIGINT');
  process.exit(0);
}

process.on('SIGINT',  shutdown);
process.on('SIGTERM', shutdown);
