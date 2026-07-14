#!/usr/bin/env node
/**
 * serve.js — Local dev server for VDO.Ninja
 *
 * Required because:
 *  1. Browsers block camera/mic on non-localhost HTTP (needs secure context)
 *  2. SharedArrayBuffer (used for audio worklets) requires Cross-Origin-Isolation
 *     headers: COOP + COEP
 *  3. Service Workers require HTTPS or localhost
 *
 * Usage:
 *   node serve.js [port]        (default port: 8443)
 *
 * Then open: http://localhost:8443
 */

const http = require('http');
const fs   = require('fs');
const path = require('path');
const url  = require('url');

const PORT = parseInt(process.argv[2]) || 8443;

const MIME = {
  '.html': 'text/html; charset=utf-8',
  '.js':   'application/javascript; charset=utf-8',
  '.css':  'text/css; charset=utf-8',
  '.json': 'application/json',
  '.png':  'image/png',
  '.jpg':  'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.gif':  'image/gif',
  '.svg':  'image/svg+xml',
  '.ico':  'image/x-icon',
  '.woff': 'font/woff',
  '.woff2':'font/woff2',
  '.ttf':  'font/ttf',
  '.eot':  'application/vnd.ms-fontobject',
  '.mp4':  'video/mp4',
  '.webm': 'video/webm',
  '.ogg':  'audio/ogg',
  '.mp3':  'audio/mpeg',
  '.xml':  'application/xml',
  '.txt':  'text/plain',
  '.md':   'text/plain',
  '.map':  'application/json',
};

// The two headers that enable Cross-Origin-Isolation (required for
// SharedArrayBuffer and credentialless iframes in Chrome).
const COOP_COEP = {
  'Cross-Origin-Opener-Policy':   'same-origin',
  'Cross-Origin-Embedder-Policy': 'require-corp',
};

// VDO.Ninja source — clone of steveseguin/vdo.ninja placed next to serve.js.
// Priority order:
//   1. ./vdoninja/          (git clone target, see README)
//   2. ./                   (files served from same dir as serve.js)
const ROOTS = [
  path.join(__dirname, 'vdoninja'),
  __dirname,
];

function findRoot() {
  for (const r of ROOTS) {
    if (fs.existsSync(path.join(r, 'index.html'))) return r;
  }
  return __dirname;
}

const ROOT = findRoot();
console.log(`Serving from: ${ROOT}`);

const server = http.createServer((req, res) => {
  let pathname = url.parse(req.url).pathname;

  // Strip query string, decode URI
  try { pathname = decodeURIComponent(pathname); } catch (e) {}

  // Prevent directory traversal
  const safePath = path.normalize(pathname).replace(/^(\.\.[\/\\])+/, '');

  // Try candidate file paths (no ext → try .html, then /index.html)
  const candidates = [
    path.join(ROOT, safePath),
    path.join(ROOT, safePath + '.html'),
    path.join(ROOT, safePath, 'index.html'),
    path.join(ROOT, 'index.html'),  // SPA fallback
  ];

  let filePath = null;
  for (const c of candidates) {
    if (fs.existsSync(c) && fs.statSync(c).isFile()) {
      filePath = c;
      break;
    }
  }

  if (!filePath) {
    res.writeHead(404, { 'Content-Type': 'text/plain', ...COOP_COEP });
    res.end('404 Not Found: ' + pathname);
    return;
  }

  const ext  = path.extname(filePath).toLowerCase();
  const mime = MIME[ext] || 'application/octet-stream';

  fs.readFile(filePath, (err, data) => {
    if (err) {
      res.writeHead(500, { 'Content-Type': 'text/plain', ...COOP_COEP });
      res.end('500 Internal Error');
      return;
    }
    res.writeHead(200, {
      'Content-Type':   mime,
      'Content-Length': data.length,
      'Cache-Control':  'no-cache',
      ...COOP_COEP,
    });
    res.end(data);
  });
});

server.listen(PORT, '127.0.0.1', () => {
  console.log('');
  console.log('  ✅  VDO.Ninja local server running');
  console.log(`  👉  http://localhost:${PORT}`);
  console.log(`  👉  http://localhost:${PORT}/iframe.html`);
  console.log('');
  console.log('  Press Ctrl+C to stop.');
  console.log('');
});
