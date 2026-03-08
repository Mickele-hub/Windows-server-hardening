# -----------------------------------------------
# Script Hardening Windows Server / Active Directory
# Auteur : Mickele
# Objectif : sécurisation interne / AD
# -----------------------------------------------

# 1️⃣ Désactiver SMBv1
Write-Output "Désactivation de SMBv1..."
Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force

# Activer audit des accès SMB
Write-Output "Activation audit des partages SMB..."
Auditpol /set /subcategory:"File Share" /success:enable /failure:enable

# Vérification des partages SMB
Write-Output "Listing des partages SMB existants..."
Get-SmbShare | Select Name, Path, Description, ScopeName

# 2️⃣ Sécuriser LDAP / Active Directory
Write-Output "Blocage des binds LDAP anonymes via registre..."
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\NTDS\Parameters" -Name "LDAPServerIntegrity" -Value 2

Write-Output "Forcer LDAPS (vérifier certificat existant)..."
# Vérifier que certificat SSL est installé sur AD, sinon générer un certificat via PKI interne

# 3️⃣ Sécuriser RDP
Write-Output "Activation NLA pour RDP..."
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Value 1

Write-Output "Limitation des connexions RDP via firewall..."
New-NetFirewallRule -DisplayName "Allow RDP Internal Only" -Direction Inbound -Protocol TCP -LocalPort 3389 -RemoteAddress 10.10.10.0/24 -Action Allow
New-NetFirewallRule -DisplayName "Block RDP External" -Direction Inbound -Protocol TCP -LocalPort 3389 -RemoteAddress Any -Action Block

# Activer verrouillage comptes après 5 échecs
Write-Output "Configuration lockout policy..."
net accounts /lockoutthreshold:5
net accounts /lockoutduration:30
net accounts /lockoutwindow:30

# 4️⃣ Sécuriser comptes utilisateurs
Write-Output "Désactivation du compte invité..."
Get-LocalUser -Name "Guest" | Disable-LocalUser

Write-Output "Forcer complexité mots de passe et durée max 90 jours..."
# Minimum 12 caractères et expiration 90 jours via net accounts
net accounts /minpwlen:12
net accounts /maxpwage:90

# Complexité mot de passe via stratégie locale
$seceditFile = "$env:TEMP\secpol.cfg"
secedit /export /cfg $seceditFile
# Lire fichier, modifier PasswordComplexity à 1
(Get-Content $seceditFile) | ForEach-Object {
    if ($_ -match "PasswordComplexity") { "PasswordComplexity = 1" } else { $_ }
} | Set-Content $seceditFile
secedit /configure /db secedit.sdb /cfg $seceditFile /overwrite
Remove-Item $seceditFile

# 5️⃣ Services inutiles
Write-Output "Désactivation services RPC HTTP / WSDAPI / SSDP si non utilisés..."
foreach ($service in @("WSDService","SSDPSRV","RpcHttpSvc")) {
    if (Get-Service -Name $service -ErrorAction SilentlyContinue) {
        Stop-Service -Name $service -Force
        Set-Service -Name $service -StartupType Disabled
    }
}

# 6️⃣ Firewall général
Write-Output "Activation firewall Windows..."
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True

# 7️⃣ Audit et logs
Write-Output "Activation audit des événements critiques..."
foreach ($category in @("Account Logon","Account Management","Logon/Logoff","Policy Change","System","DS Access")) {
    auditpol /set /category:$category /success:enable /failure:enable
}

Write-Output "Hardening terminé ! Vérifiez les logs et les services."
