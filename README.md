🔐 Hardening Windows Server / Active Directory
📌 Description
Ce projet propose un script de sécurisation pour un serveur Windows et un environnement Microsoft Active Directory, automatisé avec Windows PowerShell.
Le script applique plusieurs mesures de hardening système et réseau afin de renforcer la sécurité d’un contrôleur de domaine ou d’un serveur Windows.

⚙️ Fonctionnalités principales
🖥 Sécurisation réseau :
  -Désactivation du protocole SMBv1
  -Audit des accès aux partages SMB
  -Vérification des partages existants

🗄 Sécurisation Active Directory :
  -Blocage des binds LDAP anonymes
  -Préparation à l’utilisation de LDAPS

🔑 Sécurisation des accès :
  -Activation de NLA pour RDP
  -Restriction des connexions RDP via firewall
  -Verrouillage des comptes après plusieurs échecs

👤 Gestion des comptes utilisateurs :
  -Désactivation du compte invité
  -Politique de mot de passe renforcée
  -Complexité des mots de passe activée

🔥 Protection du système :
-Activation du pare-feu Windows
-Désactivation de services inutiles
-Activation de l’audit des événements de sécurité

🎯 Objectif
Ce script permet de renforcer rapidement la sécurité d’un serveur Windows ou d’un contrôleur de domaine en appliquant plusieurs bonnes pratiques de sécurité utilisées dans les environnements professionnels.

⚠️ Avertissement
Ce script doit être testé dans un environnement de laboratoire avant déploiement en production.
