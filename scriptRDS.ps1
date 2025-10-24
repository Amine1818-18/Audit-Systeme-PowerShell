# 1 Installation de RDS :
Install-WindowsFeature -Name RDS-RD-Server, RDS-Web-Access, RDS-Connection-Broker -IncludeManagementTools
# 2 Création du déploiement RDS
$Broker = "WIN-S00CQS0BKET.text.fr"
$WebAccess = "WIN-S00CQS0BKET.text.fr"
$SessionHost = "WIN-S00CQS0BKET.text.fr"

New-RDSessionDeployment -ConnectionBroker $Broker -WebAccessServer $WebAccess -SessionHost $SessionHost

# 3 Création de la collection de sessions
New-RDSessionCollection -CollectionName "Collection_Bureau" `
    -SessionHost $SessionHost `
    -ConnectionBroker $Broker `
    -CollectionDescription "Bureau à distance pour les utilisateurs. "
# Attribution des droits 
Set-RDSessionCollectionConfiguration -CollectionName "Collection_Bureau" `
    -UserGroup "text\Utilisateurs du domaine" `
    -ConnectionBroker "WIN-S00CQS0BKET.text.fr"

# 4 Publication des applications RemoteApp
New-RDRemoteApp -CollectionName "Collection_Bureau" `
    -DisplayName "Bloc-notes" `
    -FilePath "C:\Windows\System32\notepad.exe" `
    -ConnectionBroker "WIN-S00CQS0BKET.text.fr"
New-RDRemoteApp -CollectionName "Collection_Bureau" `
    -DisplayName "Calculatrice" `
    -FilePath "C:\Windows\System32\calc.exe" `
    -ConnectionBroker "WIN-S00CQS0BKET.text.fr"

# 5 Création du SSL
$cert = New-SelfSignedCertificate -DnsName "WIN-S00CQS0BKET.text.fr" -CertStoreLocation "Cert:\LocalMachine\My"
# Application du certificat aux rôles RDS
Set-RDCertificate -Role RDPublishing -Thumbprint $cert.Thumbprint -ConnectionBroker "WIN-S00CQS0BKET.text.fr" -Force
Set-RDCertificate -Role RDWebAccess -Thumbprint $cert.Thumbprint -ConnectionBroker "WIN-S00CQS0BKET.text.fr" -Force
# Vérification 
Get-RDCertificate -ConnectionBroker "WIN-S00CQS0BKET.text.fr"

