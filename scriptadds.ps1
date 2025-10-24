Import-Module activedirectory

New-ADOrganizationalUnit -Name "Direction" -Path "DC=text,DC=fr"
New-ADOrganizationalUnit -Name "RH" -Path "DC=text,DC=fr"
New-ADOrganizationalUnit -Name "IT" -Path "DC=text,DC=fr"

New-ADGroup -Name "IT_Group" -GroupScope Global -Path "OU=IT,DC=text,DC=fr"
New-ADGroup -Name "Direction_Group" -GroupScope Global -Path "OU=Direction,DC=text,DC=fr"
New-ADGroup -Name "RH_Group" -GroupScope Global -Path "OU=RH,DC=text,DC=fr"

New-ADUser -Name "titi toto" -GivenName "titi" -Surname "toto" -SamAccountName "tito" -UserPrincipalName "tito@text.fr" -Path "DC=text,DC=fr" -AccountPassword (ConvertTo-SecureString "Lemdp123" -AsPlainText -Force) -Enabled $true
New-ADUser -Name "lili lolo" -GivenName "lili" -Surname "lolo" -SamAccountName "lilo" -UserPrincipalName "lilo@text.fr" -Path "DC=text,DC=fr" -AccountPassword (ConvertTo-SecureString "Lemdp123" -AsPlainText -Force) -Enabled $true
Add-ADGroupMember -Identity "IT_Group" -Members "lilo" 
Add-ADGroupMember -Identity "IT_Group" -Members "tito" 

New-ADUser -Name "sisi soso" -GivenName "sisi" -Surname "soso" -SamAccountName "siso" -UserPrincipalName "siso@text.fr" -Path "DC=text,DC=fr" -AccountPassword (ConvertTo-SecureString "Lemdp123" -AsPlainText -Force) -Enabled $true
New-ADUser -Name "riri roro" -GivenName "riri" -Surname "roro" -SamAccountName "riro" -UserPrincipalName "riro@text.fr" -Path "DC=text,DC=fr" -AccountPassword (ConvertTo-SecureString "Lemdp123" -AsPlainText -Force) -Enabled $true
Add-ADGroupMember -Identity "RH_Group" -Members "riro" 
Add-ADGroupMember -Identity "RH_Group" -Members "siso" 

New-ADUser -Name "mimi momo" -GivenName "mimi" -Surname "momo" -SamAccountName "mimo" -UserPrincipalName "mimo@text.fr" -Path "DC=text,DC=fr" -AccountPassword (ConvertTo-SecureString "Lemdp123" -AsPlainText -Force) -Enabled $true
New-ADUser -Name "nini nono" -GivenName "nini" -Surname "nono" -SamAccountName "nino" -UserPrincipalName "nino@text.fr" -Path "DC=text,DC=fr" -AccountPassword (ConvertTo-SecureString "Lemdp123" -AsPlainText -Force) -Enabled $true
Add-ADGroupMember -Identity "Direction_Group" -Members "mimo" 
Add-ADGroupMember -Identity "Direction_Group" -Members "nino"




# Nom de domaine NetBIOS (à adapter selon ton AD)
$domainNetBIOS = "TEXT"

# Configuration des dossiers, groupes et permissions
$shares = @(
    @{
        Name = "Direction"
        FolderPath = "C:\Partages\Direction"
        ShareName = "Direction_Partage"
        GroupName = "$domainNetBIOS\Direction_Group"
        Permissions = "FullControl"
    },
    @{
        Name = "RH"
        FolderPath = "C:\Partages\RH"
        ShareName = "RH_Partage"
        GroupName = "$domainNetBIOS\RH_Group"
        Permissions = "Modify"
    },
    @{
        Name = "Informatique"
        FolderPath = "C:\Partages\Informatique"
        ShareName = "Informatique_Partage"
        GroupName = "$domainNetBIOS\IT_Group"
        Permissions = "Modify"
    }
)

foreach ($share in $shares) {

    # Création du dossier s'il n'existe pas
    if (-not (Test-Path -Path $share.FolderPath)) {
        New-Item -ItemType Directory -Path $share.FolderPath | Out-Null
        Write-Host "✅ Dossier créé : $($share.FolderPath)"
    } else {
        Write-Host "ℹ️  Le dossier existe déjà : $($share.FolderPath)"
    }

    # Création du partage réseau 
    $existingShare = Get-SmbShare -Name $share.ShareName -ErrorAction SilentlyContinue
    if ($existingShare) {
        Write-Host "⚠️  Le partage $($share.ShareName) existe déjà."
    } else {
        try {
            New-SmbShare -Name $share.ShareName -Path $share.FolderPath -Description "Partage $($share.Name)" -FullAccess "Administrators" -ChangeAccess $share.GroupName
            Write-Host "✅ Partage $($share.ShareName) créé avec accès $($share.Permissions) pour $($share.GroupName)."
        } catch {
            Write-Host "❌ Erreur lors de la création du partage $($share.ShareName) : $($_.Exception.Message)"
        }
    }

    # Configuration des permissions NTFS
    try {
        $acl = Get-Acl -Path $share.FolderPath

        # Suppression des anciennes règles pour ce groupe (évite les doublons)
        $acl.Access | Where-Object { $_.IdentityReference -eq $share.GroupName } | ForEach-Object {
            $acl.RemoveAccessRule($_)
        }

        # Ajout de la nouvelle règle d'accès
        $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
            $share.GroupName,
            $share.Permissions,
            "ContainerInherit,ObjectInherit",
            "None",
            "Allow"
        )

        $acl.AddAccessRule($accessRule)
        Set-Acl -Path $share.FolderPath -AclObject $acl

        Write-Host "✅ Permissions NTFS ($($share.Permissions)) appliquées pour $($share.GroupName) sur $($share.FolderPath)."
    }
    catch {
        Write-Host "❌ Erreur lors de la configuration NTFS pour $($share.FolderPath) : $($_.Exception.Message)"
    }
}

Write-Host " Script terminé avec succès."
