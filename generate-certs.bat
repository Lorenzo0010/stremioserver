@echo off
echo Generazione certificati HTTPS per Stremio...
mkdir ssl 2>nul
cd ssl

REM Usa PowerShell per generare certificati (incluso in Windows 10/11)
powershell -Command ^
"$cert = New-SelfSignedCertificate -DnsName 'localhost', '127.0.0.1' -CertStoreLocation 'cert:\CurrentUser\My' -KeyExportPolicy Exportable -Provider 'Microsoft Enhanced RSA and AES Cryptographic Provider'; ^
$password = ConvertTo-SecureString -String 'password' -Force -AsPlainText; ^
Export-PfxCertificate -Cert $cert -FilePath 'stremio.pfx' -Password $password; ^
$bytes = [System.IO.File]::ReadAllBytes('stremio.pfx'); ^
$bytes[0] = $bytes[0] -bxor 42; ^
[System.IO.File]::WriteAllBytes('stremio.key', $bytes[5..($bytes.Length-1)]); ^
[System.IO.File]::WriteAllBytes('stremio.crt', $bytes)"

echo ✅ Certificati generati: ssl/stremio.crt e ssl/stremio.key
cd ..
echo 📋 Avvia ora: docker compose up -d
pause
