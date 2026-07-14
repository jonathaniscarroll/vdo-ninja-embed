@echo off
REM setup-certs.bat — Generate a self-signed TLS certificate for local LAN use (Windows)
REM
REM Requirements: OpenSSL must be in PATH.
REM   - Git for Windows includes it: C:\Program Files\Git\usr\bin\openssl.exe
REM   - Or install: https://slproweb.com/products/Win32OpenSSL.html
REM
REM Usage: Double-click or run from cmd:
REM   setup-certs.bat

if not exist ssl mkdir ssl

REM Get LAN IP via Node
for /f %%i in ('node -e "const os=require('os');const n=os.networkInterfaces();for(const k of Object.keys(n))for(const i of n[k])if(i.family==='IPv4'&&!i.internal){process.stdout.write(i.address);process.exit(0);}process.stdout.write('127.0.0.1');"') do set LAN_IP=%%i

echo.
echo   Detected LAN IP: %LAN_IP%
echo   Generating self-signed certificate...
echo.

(
echo [req]
echo default_bits       = 2048
echo prompt             = no
echo default_md         = sha256
echo distinguished_name = dn
echo x509_extensions    = v3_req
echo.
echo [dn]
echo CN = vdo-ninja-local
echo.
echo [v3_req]
echo subjectAltName = @alt_names
echo basicConstraints = CA:FALSE
echo keyUsage = digitalSignature, keyEncipherment
echo extendedKeyUsage = serverAuth
echo.
echo [alt_names]
echo DNS.1 = localhost
echo IP.1  = 127.0.0.1
echo IP.2  = %LAN_IP%
) > ssl\openssl.cnf

openssl req -x509 -newkey rsa:2048 -keyout ssl\key.pem -out ssl\cert.pem -days 825 -nodes -config ssl\openssl.cnf

echo.
echo   Done! ssl\cert.pem and ssl\key.pem created.
echo   Run: node serve.js
echo.
pause
