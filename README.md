   <h1> Mise en place d’une infrastructure Active Directory, DNS, DHCP et RDS sous Windows Server<h1>
    <h6>Mettre en place un domaine d’entreprise nommé texte.fr, structuré en unités d’organisation (OU) et groupes de sécurité, afin de gérer les utilisateurs et les ressources du réseau.<h6>

![alt text](image-5.png)

![alt text](image-1.png)

![alt text](image-4.png)
<h6> Création du domaine texte.fr

Création de trois unités d’organisation :

Direction

RH

IT

Création des groupes associés : Direction_Group, RH_Group, IT_Group

Ajout des utilisateurs et affectation aux groupes
<h6>
<br><br>


![alt text](image-3.png)

![alt text](image.png)

![alt text](image.png)
Création d’une zone primaire : entreprisexyz.local

Ajout d’un enregistrement A pour le serveur : srv-dc1.entreprisexyz.local → 192.168.147.10

Configuration des redirecteurs vers Google DNS


Création d’une étendue LAN : 192.168.147.200 → 192.168.147.220

Définition des options : DNS, passerelle et domaine

Réservation d’adresse IP pour un poste administratif


![alt text](image-6.png)

![alt text](image-7.png)

![alt text](image-8.png)

