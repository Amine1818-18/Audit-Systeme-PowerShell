# Configuration DNS EntrepriseXYZ
# Domaine AD : text.fr

$ZoneName = "entreprisexyz.local"
$RecordName = "srv-dc1"
$RecordIP = "192.168.147.10"
$Forwarders = @("8.8.8.8", "8.8.4.4")

# Vérification de la présence du rôle DNS
if (-not (Get-WindowsFeature DNS).Installed) {
    Install-WindowsFeature DNS -IncludeManagementTools
}

# Création de la zone primaire DNS
if (-not (Get-DnsServerZone -Name $ZoneName -ErrorAction SilentlyContinue)) {
    Add-DnsServerPrimaryZone -Name $ZoneName -ReplicationScope "Domain"
}

# Ajout de l’enregistrement hôte (A)
if (-not (Get-DnsServerResourceRecord -ZoneName $ZoneName -Name $RecordName -ErrorAction SilentlyContinue)) {
    Add-DnsServerResourceRecordA -Name $RecordName -ZoneName $ZoneName -IPv4Address $RecordIP
}

# Configuration des redirecteurs DNS
Set-DnsServerForwarder -IPAddress $Forwarders -PassThru

# Vérification
Get-DnsServerZone | Select-Object ZoneName, ZoneType
Resolve-DnsName "$RecordName.$ZoneName"
