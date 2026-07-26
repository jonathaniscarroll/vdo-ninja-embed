#!/usr/bin/env node
const { spawn } = require('child_process');
const path = require('path');

const root = __dirname;
const signalScript = path.join(root, 'websocket_server', 'vdoninja.js');
const webScript = path.join(root, 'serve.js');

const SIGNAL_PORT = process.env.SIGNAL_PORT || '8444';
const WEB_PORT = process.env.WEB_PORT || '8443';
const HOST = process.env.HOST || '0.0.0.0';

function run(name, cmd, args, opts = {}) {
  const child = spawn(cmd, args, {
    cwd: opts.cwd || root,
    env: { ...process.env, ...opts.env },
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
    env: {
      PORT: SIGNAL_PORT
    }
  }
);

const web = run(
  'web',
  'node',
  [webScript, WEB_PORT],
  {
    cwd: root,
    env: {
      VDO_SIGNAL_URL: `wss://10.0.28.102:${SIGNAL_PORT}`
    }
  }
);

function shutdown() {
  signal.kill('SIGINT');
  web.kill('SIGINT');
  process.exit(0);
}

process.on('SIGINT', shutdown);
process.on('SIGTERM', shutdown);