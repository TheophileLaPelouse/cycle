# LIEGES

Bienvenue sur le github de **LIEGES**, logiciel de quantification des gaz à effet sur le service de l'eau et l'assainissement.

# Installation de LIEGES

## Exigences

En tant qu'extension de QGIS, pour utiliser LIEGES vous devez disposer de QGIS, logiciel de SIG open source que vous pouvez télécharger ici https://qgis.org/. De plus les projets LIEGES sont stocké sur une base de données PostgreSQL. Pour une installation facile, vous pouvez passer par l'installeur d'Hydra et Expresseau depuis https://hydra-software.net/telechargement-2/. Pour faire fonctionner LIEGES, il vous suffit de télécharger la version gratuite de ces logiciels.

Si vous ne voulez pas télécharger hydra et Expresseau, vous devrez installer [PostgreSQL](https://www.postgresql.org/). Vous devrez ensuite créer un utilisateur nommé "hydra" avec le mot de passe "hydra" qui dispose des permissions de créer ses propres base de données, il faudra aussi que la base de donnée nommé `postgres` existe. Enfin, il vous faudra faire tourner `postgres` sur le port 5454.

## Installation de l'extension LIEGES dans QGIS

Pour télécharger cette extension, vous pouvez télécharger ce projet git au format zip (cliquer sur Code/Download zip en haut de la page du github). Pour une meilleure stabilité veuillez sélectionner la branche Alpha pour le moment, sélectionnez les branches en cliquant sur le menu déroulant en haut à gauche du code de la page du github. 

Rendez-vous ensuite dans QGIS, dans le menu extensions/Installer et gérer les extensions. Cliquez sur installer depuis un zip et sélectionner votre archive zip.

Vous pourrez bientôt retrouver directement cette extension dans le catalogue de QGIS.

Enfin si vous souhaitez développer sur cette extension, vous pouvez cloner ce dépôt dans le dossier des extensions QGIS.

Il suffit ensuite de cocher la case de l'extension pour l'activer. Un message d'erreur apparaîtra si vous n'avez pas installer la base de données PostgreSQL.

# Documentation
Voici le [Guide utilisateur](https://github.com/user-attachments/files/18167025/Guide_utilisateurV1.pdf).
La documentation de ce logiciel est entièrement présente dans le [Wiki](https://github.com/TheophileLaPelouse/LIEGES/wiki) de ce dépôt.
