# auditMysqlHTML
Script de génération d'un rapport d'audit MySQL au format HTML

Librement inspiré d'internet (Google can be your friend, reasonably used) et des scripts suivants :
* mysqltuner.pl - Version 1.6.2.001
* http://mysqltuner.com
* Copyright (C) 2006-2015 Major Hayden - major@mhtx.net

* mysqlreport v3.5 Apr 16 2008
* http://hackmysql.com/mysqlreport
* Copyright 2006-2008 Daniel Nichter

* tuning-primer.sh - Version: 1.6-r1 Released: 2011-08-06
* Writen by: Matthew Montgomery
* https://bugs.launchpad.net/mysql-tuning-primer
* Inspired by: MySQLARd (http://gert.sos.be/demo/mysqlar)

Que leurs auteurs soient remerciés.

*********** USAGE ****************

Le script crée une table d'historique d'audit ("histaudit") et une ou plusieurs procédures ou fonctions.
Deux solutions de connexion :
1. en root. Rien à faire dans ce cas.
2. avec un utilisateur "audit" :

CAS 1 : Le plus simple est de créer une base dédiée "audit" et de lui donner tous les droits dessus (en plus des droits de lectures sur les autres bases)
create database audit;
```
grant all privileges on audit.* to audit@'%';
grant select on *.* to audit@'%';
```
CAS 2 : Droits minimums
* Si InnoDB n'est pas utilisé (statistiques inutiles) :

"audit" doit être autorisé en lecture sur les bases du serveur
```
grant select on *.* to audit@'%' identified by 'PASSWORD';
```
TODO: voir les grants spécifiques nécessaires si on doit créer des procédures ou fonctions. ALTER ? CREATE ? EXECUTE ?
```
grant all privileges on <audit_database>.histaudit to audit@'%' identified by 'PASSWORD';
```
* Si InnoDB est utilisé et doit être audité, utiliser soit "root", soit un user qui doit avoir les droits d'administrateur
```
grant SUPER on *.* to audit@'%';
```
3. Lancer:
```
mysql -h [HOST] -u[USER] -p[PWD] --skip-column-names [base_table_histaudit|mysql] < audit_mysql_html.sql > fichier.html"
```
NOTE : la syntaxe "< audit_mysql_html.sql" permet de quitter le script à la première erreur, alors que "-e source audit_mysql_html.sql"
execute tout le script quoiqu'il arrive. Ici, la première requête étant un "create..if not exists", on est sûr de ne continuer le
script que si une base (celle qui doit contenir la table histaudit) a été sélectionnée sur la ligne de commande. 

-----------
Changelog

  10/2013 v0.1 : Creation du script, reprise et automatisation des requêtes d'audit utilisees manuellement.

  08/2015 v1.0 : fin phase 1 : affichage HTML des infos et ratios de base, sans InnoDB.

  01/2016 v1.1 : ajout stats de base InnoDB (nécessite accès root ou "ALL PRIVILEGES")

  09/2016 v1.2 : création table histaudit et insertion param, tailles données, taille mémoire.

  02/2017 v1.3 : ajout stat nombre de jointures sans indexes

	ajout stats table locks

  01/2017      : affichage version en ORANGE si version modifiée depuis dernier audit

  2017         : ajout différence taille mémoire utilisée

  04/2018 v1.4 : ajout des différences de tailles de données depuis dernier audit

