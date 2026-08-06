#!/usr/bin/env bash
# setup.sh — First-time setup for vdo-ninja-embed
#
# What this does:
#   1. Checks for required dependencies (node, npm, git, openssl)
#   2. Installs root npm dependencies
#   3. Clones steveseguin/vdo.ninja → vdoninja/ (if not already present)
#   4. Clones steveseguin/websocket_server (if not already present)
#   5. Installs websocket_server npm dependencies
#   6. Generates self-signed SSL certs for localhost + your LAN IP
#
# Usage:
#   bash setup.sh
#
# After setup, start the server with:
#   node lan-run.js

set -e

# ── Colours ────────────────────────────────────────────────────────────────────
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m" # no colour

ok()   { echo -e "  ${GREEN}✅  $*${NC}"; }
warn() { echo -e "  ${YELLOW}⚠️   $*${NC}"; }
fail() { echo -e "  ${RED}❌  $*${NC}"; exit 1; }
step() { echo -e "\n${YELLOW}── $* ──${NC}"; }

echo ""
echo "  ╔══════════════════════════════════════╗"
echo "  ║     vdo-ninja-embed  setup.sh        ║"
echo "  ╚══════════════════════════════════════╝"
echo ""

# ── 1. Check dependencies ──────────────────────────────────────────────────────
step "Checking dependencies"

check_cmd() {
  if command -v "$1" &>/dev/null; then
    ok "$1 found ($("$1" --version 2>&1 | head -1))"
  else
    fail "$1 is not installed. $2"
  fi
}

check_cmd node  "Install from https://nodejs.org"
check_cmd npm   "Install from https://nodejs.org"
check_cmd git   "Install from https://git-scm.com"
check_cmd openssl "Install via: brew install openssl  (macOS) or apt install openssl (Linux)"

# Require Node ≥ 18
NODE_MAJOR=$(node -e "process.stdout.write(process.versions.node.split('.')[0])")
if [ "$NODE_MAJOR" -lt 18 ]; then
  fail "Node.js v18 or later required (found v$(node --version)). Update at https://nodejs.org"
fi
ok "Node.js version OK (v$(node --version))"

# ── 2. Root npm install ────────────────────────────────────────────────────────
step "Installing root npm dependencies"

if [ ! -f package.json ]; then
  warn "No package.json found in root — skipping root npm install"
else
  npm install
  ok "Root dependencies installed"
fi

# ── 3. Clone vdo.ninja → vdoninja/ ────────────────────────────────────────────
step "Setting up vdoninja/"

if [ -d vdoninja ] && [ "$(ls -A vdoninja 2>/dev/null)" ]; then
  ok "vdoninja/ already exists and is non-empty — skipping clone"
else
  echo "  Cloning steveseguin/vdo.ninja into vdoninja/ ..."
  git clone --depth=1 https://github.com/steveseguin/vdo.ninja.git vdoninja
  ok "vdoninja/ cloned"
fi

# ── 4. Clone websocket_server ──────────────────────────────────────────────────
step "Setting up websocket_server/"

if [ -d websocket_server ] && [ "$(ls -A websocket_server 2>/dev/null)" ]; then
  ok "websocket_server/ already exists and is non-empty — skipping clone"
else
  echo "  Cloning steveseguin/websocket_server ..."
  git clone --depth=1 https://github.com/steveseguin/websocket_server.git websocket_server
  ok "websocket_server/ cloned"
fi

# ── 5. websocket_server npm install ───────────────────────────────────────────
step "Installing websocket_server dependencies"

if [ -f websocket_server/package.json ]; then
  (cd websocket_server && npm install)
  ok "websocket_server dependencies installed"
else
  warn "websocket_server/package.json not found — skipping"
fi

# ── 6. Generate SSL certs ──────────────────────────────────────────────────────
step "Generating SSL certificates"

bash setup-certs.sh

# ── Done ───────────────────────────────────────────────────────────────────────
echo ""
echo "  ╔══════════════════════════════════════╗"
echo "  ║   Setup complete! Start the server:  ║"
echo "  ║                                      ║"
echo "  ║     node lan-run.js                  ║"
echo "  ╚══════════════════════════════════════╝"
echo ""
echo "  Then open in your browser:"
echo "    This machine:  https://localhost:8443/?wss=wss://localhost:8444"

# Print the LAN IP for convenience
LAN_IP=$(node -e "
const os = require('os');
const ifaces = os.networkInterfaces();
for (const name of Object.keys(ifaces)) {
  for (const i of ifaces[name]) {
    if (i.family === 'IPv4' && !i.internal) { process.stdout.write(i.address); process.exit(0); }
  }
}
process.stdout.write('YOUR_LAN_IP');
" 2>/dev/null || echo 'YOUR_LAN_IP')

echo "    LAN devices:   https://$LAN_IP:8443/?wss=wss://$LAN_IP:8444"
echo ""
echo "  ⚠️   LAN devices must accept the cert warning on both:"
echo "    https://$LAN_IP:8444   (signaling — accept first)"
echo "    https://$LAN_IP:8443   (web app)"
echo ""
