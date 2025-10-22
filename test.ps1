# Audit-Systeme-PowerShell
Audit complet de mon ordinateur 
# ===============================================
# Script : audit_complet.ps1
# Auteur : SARHANE Amine
# Objectif : Réaliser un audit complet du poste
# ===============================================

# --- Initialisation ---
$Date = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
$ComputerName = $env:COMPUTERNAME
$User = $env:USERNAME
$OS = (Get-ComputerInfo).OsName
$OSVersion = (Get-ComputerInfo).OsVersion
$LastBoot = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
$CPU = (Get-CimInstance Win32_Processor).Name
$Cores = (Get-CimInstance Win32_Processor).NumberOfCores
$Threads = (Get-CimInstance Win32_Processor).NumberOfLogicalProcessors
$RAM = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)
$GPU = (Get-CimInstance Win32_VideoController).Name
$IP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike "169.*" -and $_.IPAddress -notlike "127.*" }).IPAddress -join ", "
$MAC = (Get-NetAdapter | Where-Object {$_.Status -eq "Up"}).MacAddress -join ", "
$Disks = Get-CimInstance Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3}
$InstalledSoftwares = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | 
                      Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | 
                      Where-Object { $_.DisplayName } |
                      Sort-Object DisplayName

# --- Rapport principal ---
$Rapport = @"
==================== AUDIT SYSTEME ====================
Date du rapport : $Date
Nom du poste     : $ComputerName
Utilisateur       : $User

-------------------- Système --------------------
OS               : $OS ($OSVersion)
Dernier démarrage : $LastBoot
Processeur       : $CPU
Cœurs/Threads    : $Cores / $Threads
Mémoire RAM (Go) : $RAM
Carte graphique  : $GPU

-------------------- Réseau --------------------
Adresse(s) IP    : $IP
Adresse(s) MAC   : $MAC

-------------------- Disques --------------------
"@

foreach ($disk in $Disks) {
    $size = [math]::Round($disk.Size / 1GB, 2)
    $free = [math]::Round($disk.FreeSpace / 1GB, 2)
    $used = $size - $free
    $percent = [math]::Round(($used / $size) * 100, 1)
    $Rapport += "Lecteur $($disk.DeviceID) : $used Go utilisés sur $size Go ($percent% occupé)`n"
}

$Rapport += @"

-------------------- Logiciels installés --------------------
"@

foreach ($app in $InstalledSoftwares) {
    $Rapport += "$($app.DisplayName)  |  Version: $($app.DisplayVersion)  |  Éditeur: $($app.Publisher)`n"
}

$Rapport += "=========================================================`n"

# --- Export du rapport ---
$ExportPath = ".\exports"
if (!(Test-Path $ExportPath)) { New-Item -ItemType Directory -Path $ExportPath | Out-Null }

$FileName = "$ExportPath\audit_$($ComputerName)_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
$Rapport | Out-File $FileName -Encoding UTF8

Write-Host "`n✅ Rapport complet généré : $FileName" -ForegroundColor Green

