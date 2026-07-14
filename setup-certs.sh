#!/usr/bin/env bash
# setup-certs.sh — Generate a self-signed TLS certificate for local LAN use
#
# Usage:
#   bash setup-certs.sh
#
# Outputs:
#   ssl/cert.pem
#   ssl/key.pem
#
# After running this, start the server with:
#   node serve.js

set -e

mkdir -p ssl

# Detect this machine's LAN IP to bake into the cert's SAN
LAN_IP=$(node -e "
const os = require('os');
const ifaces = os.networkInterfaces();
for (const name of Object.keys(ifaces)) {
  for (const i of ifaces[name]) {
    if (i.family === 'IPv4' && !i.internal) { process.stdout.write(i.address); process.exit(0); }
  }
}
process.stdout.write('127.0.0.1');
" 2>/dev/null || echo '127.0.0.1')

echo ""
echo "  Detected LAN IP: $LAN_IP"
echo "  Generating self-signed cert valid for localhost + $LAN_IP ..."
echo ""

# Write OpenSSL config with Subject Alternative Names
cat > ssl/openssl.cnf <<EOF
[req]
default_bits       = 2048
prompt             = no
default_md         = sha256
distinguished_name = dn
x509_extensions    = v3_req

[dn]
CN = vdo-ninja-local

[v3_req]
subjectAltName = @alt_names
basicConstraints = CA:FALSE
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth

[alt_names]
DNS.1 = localhost
IP.1  = 127.0.0.1
IP.2  = $LAN_IP
EOF

openssl req \
  -x509 \
  -newkey rsa:2048 \
  -keyout ssl/key.pem \
  -out ssl/cert.pem \
  -days 825 \
  -nodes \
  -config ssl/openssl.cnf

echo ""
echo "  ✅  Done! Certificate written to ssl/cert.pem"
echo "  ✅  Private key written to  ssl/key.pem"
echo ""
echo "  Next: node serve.js"
echo ""
echo "  ──────────────────────────────────────────────────"
echo "  To trust this cert on OTHER devices (optional but"
echo "  avoids the browser warning):  copy ssl/cert.pem to"
echo "  that device and install it as a trusted CA."
echo ""
echo "  macOS:  open ssl/cert.pem → Keychain Access"
echo "          → Always Trust"
echo "  iOS:    AirDrop cert.pem → Settings → Profile"
echo "          → Install → Settings → General →"
echo "          About → Certificate Trust Settings → Enable"
echo "  Android: Settings → Security → Install certificate"
echo "  Windows: Double-click cert.pem → Install →"
echo "           Trusted Root Certification Authorities"
echo "  ──────────────────────────────────────────────────"
echo ""
