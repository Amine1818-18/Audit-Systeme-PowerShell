#Déclaration de variables

$ScopeName = "LAN_EntrepriseXYZ"
$ScopeStart = "192.168.147.200"
$ScopeEnd = "192.168.147.220"
$SubnetMask = "255.255.255.0"
$Gateway = "192.168.147.1"
$DNSServer = "192.168.147.10"
$DomainName = "entreprisexyz.local"

# Installation du rôle DHCP si absent
if (-not (Get-WindowsFeature DHCP).Installed) {
    Install-WindowsFeature DHCP -IncludeManagementTools
}

# Création de l’étendue DHCP
if (-not (Get-DhcpServerv4Scope -ScopeId 192.168.147.0 -ErrorAction SilentlyContinue)) {
    Add-DhcpServerv4Scope -Name $ScopeName -StartRange $ScopeStart -EndRange $ScopeEnd -SubnetMask $SubnetMask -State Active
}

# Configuration des options DHCP
Set-DhcpServerv4OptionValue -ScopeId 192.168.147.0 -DnsServer $DNSServer -Router $Gateway -DnsDomain $DomainName

# Réservation d'ip pour un poste 
$ReservationIP = "192.168.147.210"
$MAC = "00-11-22-33-44-55"  # Remplace par l’adresse MAC réelle du poste
Add-DhcpServerv4Reservation -ScopeId 192.168.147.0 -IPAddress $ReservationIP -ClientId $MAC -Description "Poste Administratif" -Name "PC-Admin"

# Vérification
Get-DhcpServerv4Scope
Get-DhcpServerv4Lease
