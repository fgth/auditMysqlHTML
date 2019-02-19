-- AUDIT BASES MYSQL
-- v1.4
-- Compatible MySQL 5.0.6 minimum (information_schema.global_status), MariaDB 10
-- (c) 2013, Frank Soyer <frank.soyer@gmail.com>

-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 2
-- of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- The GNU General Public License is available at:
-- http://www.gnu.org/copyleft/gpl.html

-- ================================================= SCRIPT D'AUDIT =========================================

-- *************************************** Table historique d'audit *********************
-- drop table if exists histaudit;
create table if not exists histaudit
     (date_audit date,
      object_type varchar(5),
      object_name varchar(100),
      valeur varchar(255));

-- *************************************** Entête ************************************
select '<!DOCTYPE public "-//w3c//dtd html 4.01 strict//en" "http://www.w3.org/TR/html4/strict.dtd">';
select '<html>';
select '<head>';
select '<meta http-equiv=Content-Type" content="text/html; charset=iso-8859-1">';
select '<meta name="description" content="Audit Oracle HTML">';
select concat('<title>Audit MYSQL (',@@hostname,')</title>');
select '</head>';
select '<BODY BGCOLOR="#003366">';
select '<table border=0 width=90% bgcolor="#003366" align=center><tr><td>';

select '<table border=1 width=100% bgcolor="WHITE">';
select '<tr><td bgcolor="#3399CC" align=center>';
select concat('<font color=WHITE size=+2><b>Audit MYSQL (',@@hostname,')');
select concat(' le ',date_format(sysdate(),'%d/%m/%Y'),'</b>');
select IF((select count(*) from histaudit where date_audit < DATE_FORMAT(NOW(),'%Y-%m-%d') > 0), concat('</font></td></tr><tr><td bgcolor="LIGHTBLUE" align=center><b>Pr&eacute;c&eacute;dent audit : ',date_format(max(distinct date_audit),'%d/%m/%Y')), '</font></td></tr><tr><td bgcolor="ORANGE" align=center><b>Premier audit') from histaudit where date_audit < DATE_FORMAT(NOW(),'%Y-%m-%d');
select '</b></td></tr></table>';
select '<br>';

-- valeurs initiales (PREMIER AUDIT) à 0 pour éviter les select vides
-- si et seulement si histaudit ne contient pas déjà des valeurs pour les types
insert into histaudit SELECT DATE_FORMAT(NOW() - INTERVAL 1 DAY,'%Y-%m-%d'), 'VERS', 'version', 'Premier audit' from dual
where (select count(*) from histaudit where object_type='VERS' and object_name='version')=0;
insert into histaudit SELECT DATE_FORMAT(NOW() - INTERVAL 1 DAY,'%Y-%m-%d'), 'VERS', 'OSversion', 'Premier audit' from dual
where (select count(*) from histaudit where object_type='VERS' and object_name='OSversion')=0;
insert into histaudit SELECT DATE_FORMAT(NOW() - INTERVAL 1 DAY,'%Y-%m-%d'), 'DSIZE', table_schema, 0
FROM information_schema.tables, INFORMATION_SCHEMA.SCHEMATA
where information_schema.tables.table_schema=INFORMATION_SCHEMA.SCHEMATA.SCHEMA_NAME
and (select count(*) from histaudit where object_type='DSIZE')=0 -- seulement si aucune valeur retournée
GROUP BY table_schema;
insert into histaudit SELECT DATE_FORMAT(NOW() - INTERVAL 1 DAY,'%Y-%m-%d'), 'ISIZE', table_schema, 0
FROM information_schema.tables, INFORMATION_SCHEMA.SCHEMATA
where information_schema.tables.table_schema=INFORMATION_SCHEMA.SCHEMATA.SCHEMA_NAME
and (select count(*) from histaudit where object_type='ISIZE')=0 -- seulement si aucune valeur retournée
GROUP BY table_schema;
insert into histaudit select DATE_FORMAT(NOW() - INTERVAL 1 DAY,'%Y-%m-%d'), 'MSIZE','total server memory', 0 from dual
where (select count(*) from histaudit where object_type='MSIZE' and object_name='total server memory')=0;
insert into histaudit SELECT DATE_FORMAT(NOW() - INTERVAL 1 DAY,'%Y-%m-%d'), 'PARAM', variable_name, variable_value
   FROM INFORMATION_SCHEMA.global_variables 
   where variable_name in (
'query_cache_type',
'query_cache_size',
'query_cache_limit',
'have_query_cache',
'key_buffer_size',
'innodb_buffer_pool_size',
'innodb_buffer_pool_instances',
'innodb_additional_mem_pool_size',
'innodb_log_buffer_size',
'innodb_log_file_size',
'innodb_thread_concurrency',
'innodb_flush_method',
'innodb_file_per_table',
'read_buffer_size',
'read_rnd_buffer_size',
'sort_buffer_size', 
'thread_stack',
'join_buffer_size',
'binlog_cache_size',
'max_heap_table_size',
'tmp_table_size',
'max_connections',
'table_cache',
'table_open_cache')
and (select count(*) from histaudit where object_type='PARAM')=0;

-- SECTION TEMPLATE
-- *************************************** Section xxxxxx template *******************
-- select '<hr>';
-- select '<div align=center><b><font color="WHITE">SECTION XXXXX</font></b></div>';
--
-- select '<hr>';
-- *************************************** Sous-section xxxxxx
-- select '<table border=1 width=100% bgcolor="WHITE">';
-- select '<tr><td bgcolor="#3399CC" align=center colspan=3><font color="WHITE"><b>TITRE</b></font></td></tr>';
-- select '<tr><td bgcolor="WHITE" align=center width=40%><b>Colonne1</b></td><td bgcolor="WHITE" align=center><b>Colonne2</b></td><td bgcolor="WHITE" align=center><b>Colonne3</b></td></tr>';
-- ... TRAITEMENTS...
-- SELECT concat('<tr><td bgcolor="LIGHTBLUE" align=left><b>',COLONNE1,'</b></td><td bgcolor="LIGHTBLUE" align=left>',COLONNE2,'</td><td bgcolor="LIGHTBLUE" align=left>',COLONNE3,'</td><tr>') FROM INFORMATION_SCHEMA.XXXX;
-- ...
-- select '</table>';
-- select '<br>';
--

-- *************************************** Début script audit *****************************

-- *************************************** Section informations *********************
select '<hr>';
select '<div align=center><b><font color="WHITE">SECTION INFORMATIONS</font></b></div>';

select '<hr>';
-- *************************************** Informations générales
select '<table border=1 width=100% bgcolor="WHITE">';

select '<tr><td bgcolor="#3399CC" align=center colspan=3><font color="WHITE"><b>Informations g&eacute;n&eacute;rales</b></font></td></tr>';
select '<tr><td width=20%>Version</td>';
select '<td bgcolor="',IF(histaudit.valeur <> @@version, 'ORANGE', 'LIGHTBLUE'),'" colspan=2>'
    from (select * from (select valeur from histaudit where histaudit.date_audit < DATE_FORMAT(NOW(),'%Y-%m-%d')
      and histaudit.object_type='VERS' and histaudit.object_name='version'
    order by histaudit.date_audit DESC LIMIT 1) histaudit) histaudit;
select 'MySQL ', @@version, ' (OS : ', @@version_compile_os,')';
select @vers := (substring(@@version,5));
select '</td></tr>';
select '<tr><td width=20%>Uptime</td>';
-- uptime to date : J = sec DIV 86400, RESTEH := sec MOD 86400, H := RESTEH DIV 3600, RESTEM := RESTEH MOD 3600 M := RESTEM DIV 60 S := RESTEM MOD 60
select '<td bgcolor="LIGHTBLUE" align=left colspan=2>';
select 'Depuis le ',concat(date_format(NOW() - INTERVAL VARIABLE_VALUE SECOND, '%d/%m/%Y %H:%i:%s'), ' (', floor(variable_value/86400),' jours ',floor(mod(variable_value,86400)/3600),' heures)')
-- ,floor(mod(mod(variable_value,86400),3600)/60),' minutes ',floor(mod(mod(mod(variable_value,86400),3600),60)),' secondes)'
 from information_schema.global_status where variable_name='Uptime';
select '</td></tr>';
select '<tr><td width=20%>Binary logs</td>';
select concat('<td bgcolor="',IF (variable_value = 'ON', 'LIGHTBLUE" align=left colspan=2>', 'LIGHTGREY" align=left colspan=2>'),variable_value)
	from information_schema.global_variables where variable_name = 'log_bin';
select '</td></tr></table>';
-- ***************** Historique *****************
delete from histaudit where date_audit = DATE_FORMAT(NOW(),'%Y-%m-%d') and object_type='VERS';
insert into histaudit SELECT DATE_FORMAT(NOW(),'%Y-%m-%d'), 'VERS', 'version', @@version;
insert into histaudit SELECT DATE_FORMAT(NOW(),'%Y-%m-%d'), 'VERS', 'OSversion', @@version_compile_os;

-- ************************************** Ratio read/write
select '<br/><table border=1 width=100% bgcolor="WHITE">';
select '<tr><td bgcolor="#3399CC" align=center colspan=2><font color="WHITE"><b>Ratio reads / writes</b></font></td></tr>';

SELECT IF(gsq.variable_value > 0, IF(gss.variable_value > 0,
		concat('<tr><td bgcolor="WHITE" align=center width=',ROUND((gss.variable_value / (gss.variable_value+gsd.variable_value+gsi.variable_value+gsu.variable_value+gsp.variable_value))*100, 2),'%><b>READS</b></td><td bgcolor="WHITE" align=center width=',ROUND( 100 - ((gss.variable_value / (gss.variable_value+gsd.variable_value+gsi.variable_value+gsu.variable_value+gsp.variable_value))*100),2),'%><b>WRITES</b></td></tr>',
		'<tr><td bgcolor="#01DF3A" align=center>', ROUND((gss.variable_value / (gss.variable_value+gsd.variable_value+gsi.variable_value+gsu.variable_value+gsp.variable_value))*100, 2), '%</td><td bgcolor="#04B404" align=center>', ROUND( 100 - ((gss.variable_value / (gss.variable_value+gsd.variable_value+gsi.variable_value+gsu.variable_value+gsp.variable_value))*100),2),'%</td></tr>'),
		'<tr><td bgcolor="WHITE" align=center width=20%><b>READS</b></td><td bgcolor="WHITE" align=center width=80%><b>WRITES</b></td></tr><tr><td td bgcolor="LIGHTBLUE" align=center>0%</td><td bgcolor="LIGHTBLUE" align=center>100%</td></tr>'),
		'<tr><td bgcolor="LIGHTGREY" align=left>&nbsp; </td></tr>')
	FROM INFORMATION_SCHEMA.global_status gsq, INFORMATION_SCHEMA.global_status gss, INFORMATION_SCHEMA.global_status gsd,
	     INFORMATION_SCHEMA.global_status gsi, INFORMATION_SCHEMA.global_status gsu, INFORMATION_SCHEMA.global_status gsp
	WHERE gsq.variable_name = 'Questions'
	and gss.variable_name = 'Com_select'
	and gsd.variable_name = 'Com_delete'
	and gsi.variable_name = 'Com_insert'
	and gsu.variable_name = 'Com_update'
	and gsp.variable_name = 'Com_replace';

select '</table>';
select '<br>';

-- *************************************** Section stockage ***************************
select '<hr>';
select '<div align=center><b><font color="WHITE">SECTION STOCKAGE</font></b></div>';

select '<hr>';
select '<table border=1 width=100% bgcolor="WHITE">';
select '<tr><td bgcolor="#3399CC" align=center colspan=7><font color="WHITE"><b>Chemin des fichiers</b></font></td></tr>';
SELECT '<tr><td bgcolor="WHITE" align=center colspan=7><b>&nbsp;', @@datadir, '</b></td></tr>';
select '</table>';
select '<br>';
-- *************** Liste et taille des bases ********************
select '<table border=1 width=100% bgcolor="WHITE">';
select '<tr><td bgcolor="#3399CC" align=center colspan=7><font color="WHITE"><b>Taille des bases</b></font></td></tr>';
select '<tr><td bgcolor="WHITE" align=center width=20%><b>Database</b></td><td bgcolor="WHITE" align=center width=15%><b>Default character set</b></td><td bgcolor="WHITE" align=center><b>Default collation</b></td><td bgcolor="WHITE" align=center><b>Taille tables</b><td bgcolor="WHITE" align=center><b>Taille indexes</b></td></td><td bgcolor="WHITE" align=center><b>Taille totale</b></td><td bgcolor="WHITE" align=center width=15%><b>Différences de taille depuis dernier audit</b></td></tr>';

-- NOTE : si cette requête devient trop longues (plusieures dizaines de minutes parfois !) modifier le paramètre :
-- innodb_stats_on_metadata=OFF (my.cnf)
-- et/ou set innodb_stats_on_metadata=0 (en root dans le client mysql)

SELECT concat('<tr><td bgcolor="',IF(table_schema not in (select table_schema from histaudit where date_audit < DATE_FORMAT(NOW(),'%Y-%m-%d')), 'ORANGE','LIGHTBLUE'),'" align=left><b>', table_schema, '</b></td><td bgcolor="LIGHTBLUE" align=left>',DEFAULT_CHARACTER_SET_NAME,'</td><td bgcolor="LIGHTBLUE" align=left>',DEFAULT_COLLATION_NAME, '</td>',
'<td bgcolor="LIGHTBLUE" align=right>',
-- datas
  IF (sum(data_length) > 1048576,
      IF (sum(data_length) > 1073741824, 
          concat(ROUND(sum(data_length)/1024/1024/1024,2),' Go</td>'),
          concat(ROUND(sum(data_length)/1024/1024,2),' Mo</td>')),
      concat(ROUND(sum(data_length)/1024,2),' Ko</td>')),
'<td bgcolor="LIGHTBLUE" align=right>',
-- indexes
  IF (sum(index_length) > 1048576,
      IF (sum(index_length) > 1073741824,
          concat(ROUND(sum(index_length)/1024/1024/1024,2),' Go</td>'),
          concat(ROUND(sum(index_length)/1024/1024,2),' Mo</td>')),
      concat(ROUND(sum(index_length)/1024,2),' Ko</td>')),
'<td bgcolor="LIGHTBLUE" align=right>',
-- total
  IF (sum(data_length+index_length) > 1048576,
      IF (sum(data_length+index_length) > 1073741824,
          concat(ROUND(sum(data_length+index_length)/1024/1024/1024,2),' Go</td>'),
          concat(ROUND(sum(data_length+index_length)/1024/1024,2),' Mo</td>')),
      concat(ROUND(sum(data_length+index_length)/1024,2),' Ko</td>')),
'<td bgcolor="LIGHTBLUE" align=right>',
-- diff
  IF (sum(data_length+index_length)-(histaudit_d.valeur + histaudit_i.valeur) = 0,
      '0.00',
      IF (sum(data_length+index_length)-(histaudit_d.valeur + histaudit_i.valeur) > 0,
          IF (sum(data_length+index_length)-(histaudit_d.valeur + histaudit_i.valeur) > 1048576,
              IF (sum(data_length+index_length)-(histaudit_d.valeur + histaudit_i.valeur) > 1073741824,
                  concat('+',ROUND((sum(data_length+index_length)-(histaudit_d.valeur + histaudit_i.valeur))/1024/1024/1024,2),' Go</td>'),
                  concat('+',ROUND((sum(data_length+index_length)-(histaudit_d.valeur + histaudit_i.valeur))/1024/1024,2),' Mo</td>')),
              concat('+',ROUND((sum(data_length+index_length)-(histaudit_d.valeur + histaudit_i.valeur))/1024,2),' Ko</td>')),
          IF (sum(data_length+index_length)-(histaudit_d.valeur + histaudit_i.valeur) < -1048576,
              IF (sum(data_length+index_length)-(histaudit_d.valeur + histaudit_i.valeur) < -1073741824,
                  concat(ROUND((sum(data_length+index_length)-(histaudit_d.valeur + histaudit_i.valeur))/1024/1024/1024,2),' Go</td>'),
                  concat(ROUND((sum(data_length+index_length)-(histaudit_d.valeur + histaudit_i.valeur))/1024/1024,2),' Mo</td>')),
              concat(ROUND((sum(data_length+index_length)-(histaudit_d.valeur + histaudit_i.valeur))/1024,2),' Ko</td>'))))
),
'</td></tr>'
FROM information_schema.tables, INFORMATION_SCHEMA.SCHEMATA,

(select object_name,valeur from histaudit
 where date_audit = (select date_audit from histaudit
 where date_audit < DATE_FORMAT(NOW(),'%Y-%m-%d')
 order by histaudit.date_audit DESC LIMIT 1)
 and object_type = 'DSIZE') histaudit_d,

(select object_name,valeur from histaudit
 where date_audit = (select date_audit from histaudit
 where date_audit < DATE_FORMAT(NOW(),'%Y-%m-%d')
 order by histaudit.date_audit DESC LIMIT 1)
 and object_type = 'ISIZE') histaudit_i

WHERE information_schema.tables.table_schema = INFORMATION_SCHEMA.SCHEMATA.SCHEMA_NAME
AND information_schema.tables.table_schema = histaudit_d.object_name
AND information_schema.tables.table_schema = histaudit_i.object_name
AND histaudit_d.object_name = histaudit_i.object_name
-- AND table_schema not in ('information_schema','performance_schema')
GROUP BY table_schema;

/*
SELECT concat('<tr><td bgcolor="WHITE" align=left><b>Total sur disque</b></td>', '<td bgcolor="LIGHTBLUE" align=right colspan=6><b>',
  IF (sum(data_length+index_length) > 1048576,
      IF (sum(data_length+index_length) > 1073741824, concat(ROUND(sum(data_length+index_length)/1024/1024/1024,2),' Go</b></td>'),
                                                      concat(ROUND(sum(data_length+index_length)/1024/1024,2),' Mo</b></td>')),
      concat(ROUND(sum(data_length+index_length)/1024,2),' Ko</b></td>'))
)
FROM information_schema.tables;
*/
-- Total global
SELECT concat('<tr><td bgcolor="WHITE" align=left><b>Total sur disque</b></td>', '<td bgcolor="LIGHTBLUE" align=right colspan=5><b>',
  IF (total > 1048576,
      IF (total > 1073741824,
          concat(ROUND(total/1024/1024/1024,2),' Go</b></td>'),
          concat(ROUND(total/1024/1024,2),' Mo</b></td>')),
      concat(ROUND(total/1024,2),' Ko</b></td>')),
'<td bgcolor="LIGHTBLUE" align=right>',
  IF (total-valeur = 0,
      '0.00',
      IF (total-valeur > 0,
          IF (total-valeur > 1048576,
              IF (total-valeur > 1073741824,
                  concat('+',ROUND((total-valeur)/1024/1024/1024,2),' Go</td>'),
                  concat('+',ROUND((total-valeur)/1024/1024,2),' Mo</td>')),
              concat('+',ROUND((total-valeur)/1024,2),' Ko</td>')),
          IF (total-valeur < -1048576,
              IF (total-valeur < -1073741824,
                  concat(ROUND((total-valeur)/1024/1024/1024,2),' Go</td>'),
                  concat(ROUND((total-valeur)/1024/1024,2),' Mo</td>')),
              concat(ROUND((total-valeur)/1024,2),' Ko</td>')))),
'</tr>'
)
FROM
(select sum(data_length)+sum(index_length) total from information_schema.tables) information_schema_t,
(select sum(valeur) valeur from histaudit
 where date_audit = (select date_audit from histaudit
 where date_audit < DATE_FORMAT(NOW(),'%Y-%m-%d')
 order by histaudit.date_audit DESC LIMIT 1)
 and object_type in ('DSIZE','ISIZE')) histaudit_t;
select '</table>';
select '<br>';

-- N'ACTIVER LE QUERY CACHE QUE SI LA BASE EST TRES SOLLICITEE EN LECTURE, ET/OU SI LES BASES UTILISATEURS UTILISENT PRINCIPALEMENT MYISAM
-- => SI PRINCIPALEMENT INNODB, LE LAISSER OFF
select '<table border=1 width=100% bgcolor="WHITE">';
select '<tr><td bgcolor="#3399CC" align=center colspan=2><font color="WHITE"><b>R&eacute;partition par type de stockage (bases utilisateurs uniquement)</b></font></td></tr>';
select '<tr><td bgcolor="WHITE" align=center width=40%><b>Base</b></td><td bgcolor="WHITE" align=center><b>Type</b></td></tr>';
select concat('<td bgcolor="LIGHTBLUE" align=left><b>',TABLE_SCHEMA, '</b></td><td bgcolor="LIGHTBLUE" align=right>',ENGINE, ' (',
IF((SUM(DATA_LENGTH)+SUM(INDEX_LENGTH)) > 1048576, IF((SUM(DATA_LENGTH)+SUM(INDEX_LENGTH)) > 1073741824, round((SUM(DATA_LENGTH)+SUM(INDEX_LENGTH))/1024/1024/1024,2), round((SUM(DATA_LENGTH)+SUM(INDEX_LENGTH))/1024/1024,2)), round((SUM(DATA_LENGTH)+SUM(INDEX_LENGTH))/1024,2)),
 IF((SUM(DATA_LENGTH)+SUM(INDEX_LENGTH)) > 1048576, IF((SUM(DATA_LENGTH)+SUM(INDEX_LENGTH)) > 1073741824,' Go)', ' Mo)'), ' Ko)'),
'</td></tr>')
 from information_schema.TABLES
   where TABLE_SCHEMA not in ('mysql','information_schema','performance_schema')
   AND ENGINE IS NOT NULL
   group by TABLE_SCHEMA,ENGINE order by TABLE_SCHEMA;
select '</table>';
select '<br>';

select '<table border=1 width=100% bgcolor="WHITE">';
select '<tr><td bgcolor="#3399CC" align=center colspan=2><font color="WHITE"><b>Taille totale des donn&eacute;es (tables + indexes) par type de stockage (bases utilisateurs uniquement)</b></font></td></tr>';
select '<tr><td bgcolor="WHITE" align=center width=40%><b>Type</b></td><td bgcolor="WHITE" align=center><b>Taille totale</b></td></tr>';
SELECT concat('<td bgcolor="LIGHTBLUE" align=left><b>', ENGINE, '</b></td><td bgcolor="LIGHTBLUE" align=right>',
 IF((SUM(DATA_LENGTH)+SUM(INDEX_LENGTH)) > 1048576, IF((SUM(DATA_LENGTH)+SUM(INDEX_LENGTH)) > 1073741824, round((SUM(DATA_LENGTH)+SUM(INDEX_LENGTH))/1024/1024/1024,2), round((SUM(DATA_LENGTH)+SUM(INDEX_LENGTH))/1024/1024,2)), round((SUM(DATA_LENGTH)+SUM(INDEX_LENGTH))/1024,2)),
 IF((SUM(DATA_LENGTH)+SUM(INDEX_LENGTH)) > 1048576, IF((SUM(DATA_LENGTH)+SUM(INDEX_LENGTH)) > 1073741824,' Go dans ', ' Mo dans '), ' Ko dans '),
 COUNT(ENGINE), ' tables</td></tr>')
  FROM information_schema.TABLES
  WHERE TABLE_SCHEMA not in ('mysql','information_schema','performance_schema')
  AND ENGINE IS NOT NULL
  GROUP BY ENGINE ORDER BY ENGINE ASC;
select '</table>';
select '<br>';
-- ***************** Historique *****************
delete from histaudit where date_audit = DATE_FORMAT(NOW(),'%Y-%m-%d') and (object_type='DSIZE' or object_type='ISIZE');
insert into histaudit SELECT DATE_FORMAT(NOW(),'%Y-%m-%d'), 'DSIZE', table_schema, SUM(data_length)
FROM information_schema.tables
GROUP BY table_schema;
insert into histaudit SELECT DATE_FORMAT(NOW(),'%Y-%m-%d'), 'ISIZE', table_schema, SUM(index_length)
FROM information_schema.tables
GROUP BY table_schema;

-- *************************************** Section mémoire **************************
select '<hr>';
select '<div align=center><b><font color="WHITE">SECTION MEMOIRE ET CACHES</font></b></div>';

select '<hr>';
-- *************************************** Mémoire utilisée
select '<table border=1 width=100% bgcolor="WHITE">';
select '<tr><td bgcolor="#3399CC" align=center colspan=2><font color="WHITE"><b>M&eacute;moire totale utilis&eacute;e</b></font></td></tr>';
select '<tr><td bgcolor="WHITE" align=center width=40%><b>Type</b></td><td bgcolor="WHITE" align=center><b>Valeur</b></td></tr>';
SELECT concat('<tr><td bgcolor="LIGHTBLUE" align=left>Buffers</td><td bgcolor="',
 IF (round((kbs.variable_value + IF(tts.variable_value > mhts.variable_value, mhts.variable_value, tts.variable_value) + IF(ibps.variable_value IS NOT NULL, ibps.variable_value, 0) + IF(iamps.variable_value IS NOT NULL, iamps.variable_value, 0) + IF(ilbs.variable_value IS NOT NULL, ilbs.variable_value, 0) + IF(qcs.variable_value IS NOT NULL, qcs.variable_value, 0))/1024/1024,2) > round(hist.valeur/1024/1024,2), 'ORANGE', 'LIGHTBLUE'),
'" align=right>',round((kbs.variable_value + IF(tts.variable_value > mhts.variable_value, mhts.variable_value, tts.variable_value) + IF(ibps.variable_value IS NOT NULL, ibps.variable_value, 0) + IF(iamps.variable_value IS NOT NULL, iamps.variable_value, 0) + IF(ilbs.variable_value IS NOT NULL, ilbs.variable_value, 0) + IF(qcs.variable_value IS NOT NULL, qcs.variable_value, 0))/1024/1024,2),' Mo ',
 IF (round((kbs.variable_value + IF(tts.variable_value > mhts.variable_value, mhts.variable_value, tts.variable_value) + IF(ibps.variable_value IS NOT NULL, ibps.variable_value, 0) + IF(iamps.variable_value IS NOT NULL, iamps.variable_value, 0) + IF(ilbs.variable_value IS NOT NULL, ilbs.variable_value, 0) + IF(qcs.variable_value IS NOT NULL, qcs.variable_value, 0))/1024/1024, 2) > round(hist.valeur/1024/1024,2),
     concat('(+',
           round((kbs.variable_value + IF(tts.variable_value > mhts.variable_value, mhts.variable_value, tts.variable_value) + IF(ibps.variable_value IS NOT NULL, ibps.variable_value, 0) + IF(iamps.variable_value IS NOT NULL, iamps.variable_value, 0) + IF(ilbs.variable_value IS NOT NULL, ilbs.variable_value, 0) + IF(qcs.variable_value IS NOT NULL, qcs.variable_value, 0))/1024/1024,2) - round(hist.valeur/1024/1024,2),
           ')'),
     ''),
'</td></tr>')
  FROM (select variable_value from INFORMATION_SCHEMA.global_variables where variable_name = 'key_buffer_size') kbs,
        (select variable_value from INFORMATION_SCHEMA.global_variables where variable_name = 'max_heap_table_size') mhts,
        (select variable_value from INFORMATION_SCHEMA.global_variables where variable_name = 'tmp_table_size') tts,
        (select variable_value from INFORMATION_SCHEMA.global_variables where variable_name = 'query_cache_size') qcs,
        (select IF(EXISTS(select variable_value from INFORMATION_SCHEMA.global_variables where variable_name = 'innodb_buffer_pool_size')=1,(select variable_value from INFORMATION_SCHEMA.global_variables where variable_name = 'innodb_buffer_pool_size'), 0) variable_value) ibps, -- les variables innodb n'existent pas si innodb desactivé
        (select IF(EXISTS(select variable_value from INFORMATION_SCHEMA.global_variables where variable_name = 'innodb_additional_mem_pool_size')=1,(select variable_value from INFORMATION_SCHEMA.global_variables where variable_name = 'innodb_additional_mem_pool_size'), 0) variable_value) iamps,
        (select IF(EXISTS(select variable_value from INFORMATION_SCHEMA.global_variables where variable_name = 'innodb_log_buffer_size')=1,(select variable_value from INFORMATION_SCHEMA.global_variables where variable_name = 'innodb_log_buffer_size'), 0) variable_value) ilbs,

(select histaudit.valeur from histaudit where histaudit.object_type='MSIZE' and histaudit.date_audit < DATE_FORMAT(NOW(),'%Y-%m-%d') order by histaudit.date_audit DESC LIMIT 1) hist;
-- (select IF(EXISTS(select histaudit.valeur from histaudit where histaudit.object_type='MSIZE' and histaudit.date_audit < DATE_FORMAT(NOW(),'%Y-%m-%d') order by histaudit.date_audit DESC LIMIT 1)=0,0,(select histaudit.valeur from histaudit where histaudit.object_type='MSIZE' and histaudit.date_audit < DATE_FORMAT(NOW(),'%Y-%m-%d') order by histaudit.date_audit DESC LIMIT 1)) valeur) hist;
select '</table>';
select '<br>';
-- ***************** Historique *****************
delete from histaudit where date_audit = DATE_FORMAT(NOW(),'%Y-%m-%d') and object_type='MSIZE';
insert into histaudit SELECT DATE_FORMAT(NOW(),'%Y-%m-%d'), 'MSIZE', 'total server memory', (kbs.variable_value + IF(tts.variable_value > mhts.variable_value, mhts.variable_value, tts.variable_value) + IF(ibps.variable_value IS NOT NULL, ibps.variable_value, 0) + IF(iamps.variable_value IS NOT NULL, iamps.variable_value, 0) + IF(iampi.variable_value IS NOT NULL, iampi.variable_value, 0) + IF(ilbs.variable_value IS NOT NULL, ilbs.variable_value, 0) + IF(qcs.variable_value IS NOT NULL, qcs.variable_value, 0))
  FROM (select variable_value from INFORMATION_SCHEMA.global_variables where variable_name = 'key_buffer_size') kbs,
        (select variable_value from INFORMATION_SCHEMA.global_variables where variable_name = 'max_heap_table_size') mhts,
        (select variable_value from INFORMATION_SCHEMA.global_variables where variable_name = 'tmp_table_size') tts,
        (select variable_value from INFORMATION_SCHEMA.global_variables where variable_name = 'query_cache_size') qcs,
        (select IF(EXISTS(select variable_value from INFORMATION_SCHEMA.global_variables where variable_name = 'innodb_buffer_pool_size')=1,(select variable_value from INFORMATION_SCHEMA.global_variables where variable_name = 'innodb_buffer_pool_size'), 0) variable_value) ibps, -- les variables innodb n'existent pas si innodb desactivé
        (select IF(EXISTS(select variable_value from INFORMATION_SCHEMA.global_variables where variable_name = 'innodb_additional_mem_pool_size')=1,(select variable_value from INFORMATION_SCHEMA.global_variables where variable_name = 'innodb_additional_mem_pool_size'), 0) variable_value) iamps,
        (select IF(EXISTS(select variable_value from INFORMATION_SCHEMA.global_variables where variable_name = 'innodb_buffer_pool_instances')=1,(select variable_value from INFORMATION_SCHEMA.global_variables where variable_name = 'innodb_buffer_pool_instances'), 0) variable_value) iampi,
        (select IF(EXISTS(select variable_value from INFORMATION_SCHEMA.global_variables where variable_name = 'innodb_log_buffer_size')=1,(select variable_value from INFORMATION_SCHEMA.global_variables where variable_name = 'innodb_log_buffer_size'), 0) variable_value) ilbs;

-- *************************************** Valeurs actuelle des caches
select '<table border=1 width=100% bgcolor="WHITE">';
select '<tr><td bgcolor="#3399CC" align=center colspan=2><font color="WHITE"><b>Valeurs des caches et buffers</b></font></td></tr>';
select '<tr><td bgcolor="WHITE" align=center width=40%><b>Cache</b></td><td bgcolor="WHITE" align=center><b>Valeur</b></td></tr>';
-- variables in size
SELECT concat('<tr><td bgcolor="LIGHTBLUE" align=left>',variable_name,'</td><td bgcolor="',
 'LIGHTBLUE',
/*
-- ne fonctionne pas car le LIMIT 1 sur histaudit ne ramère qu'une seule ligne ! Comment ramener tous les paramètres du dernier audit ?
IF (variable_value <> valeur, 'ORANGE', 'LIGHTBLUE'), */
'" align=right>', IF(variable_value > 1048576, ROUND(variable_value/1024/1024,2), ROUND(variable_value/1024,2)),IF(variable_value > 1048576,' Mo',' Ko'),'</td></tr>') 
   FROM INFORMATION_SCHEMA.global_variables
-- -
/* ,(select histaudit.object_name, histaudit.valeur from histaudit where histaudit.object_type='PARAM' and histaudit.date_audit < DATE_FORMAT(NOW(),'%Y-%m-%d') order by histaudit.date_audit DESC LIMIT 1) hist */
-- -
   where variable_name in (
'query_cache_type',
'query_cache_size',
'query_cache_limit',
'key_buffer_size',
'innodb_buffer_pool_size',
'innodb_additional_mem_pool_size',
'innodb_log_buffer_size',
'innodb_log_file_size',
'innodb_thread_concurrency',
'innodb_flush_method',
'innodb_file_per_table',
'read_buffer_size',
'read_rnd_buffer_size',
'sort_buffer_size', 
'thread_stack',
'thread_cache_size',
'join_buffer_size',
'binlog_cache_size',
'max_heap_table_size',
'tmp_table_size')
/*   and variable_name = hist.object_name */
   UNION
SELECT concat('<tr><td bgcolor="LIGHTBLUE" align=left>',variable_name,'</td><td bgcolor="',
 IF (substring(@@version,1,3) > 5.7, 'RED" align=right> (deprecated since 5.7.20) ','LIGHTBLUE" align=right>'),
 variable_value,'</td></tr>') 
   FROM INFORMATION_SCHEMA.global_variables
   where variable_name = 'have_query_cache'
   UNION
-- variables in number 
SELECT concat('<tr><td bgcolor="LIGHTBLUE" align=left>',variable_name,'</td><td bgcolor="',
 'LIGHTBLUE',
/*
 IF (variable_value <> valeur, 'ORANGE', 'LIGHTBLUE'), */
'" align=right>',variable_value,'</td></tr>') 
   FROM INFORMATION_SCHEMA.global_variables
-- -
/* ,(select histaudit.object_name, histaudit.valeur from histaudit where histaudit.object_type='PARAM' and histaudit.date_audit < DATE_FORMAT(NOW(),'%Y-%m-%d') order by histaudit.date_audit DESC LIMIT 1) hist */
-- -
   where variable_name in ('max_connections',
'table_cache',
'table_open_cache')
/*   and variable_name = hist.object_name */
   UNION
-- variables to check by other(s) variable(s) values(s)
 SELECT concat('<tr><td bgcolor="LIGHTBLUE" align=left>',gvi.variable_name,
                  '</td><td bgcolor="',
                  IF(cast(gvs.variable_value/(1024*1024*1024) as unsigned) > gvi.variable_value,
                     IF(cast(gvs.variable_value/(1024*1024*1024) as unsigned) > 64,
                        concat('ORANGE" align=right>',gvi.variable_value,' (devrait &ecirc;tre 64)'),
                        concat('ORANGE" align=right>',gvi.variable_value,' (devrait &ecirc;tre ',cast(gvs.variable_value/(1024*1024*1024) as unsigned),')')
                     ),
                     concat('LIGHTBLUE" align=right>',gvi.variable_value)
                  ),
               '</td></tr>')
   FROM (select variable_name,variable_value from INFORMATION_SCHEMA.global_variables
      where variable_name = 'innodb_buffer_pool_size') gvs,
        (select variable_name,variable_value from INFORMATION_SCHEMA.global_variables
      where variable_name ='innodb_buffer_pool_instances') gvi
order by 1;
   
select '</table>';
select '<br>';

-- ***************** Historique *****************
delete from histaudit where date_audit = DATE_FORMAT(NOW(),'%Y-%m-%d') and object_type='PARAM';
insert into histaudit SELECT DATE_FORMAT(NOW(),'%Y-%m-%d'), 'PARAM', variable_name, variable_value
   FROM INFORMATION_SCHEMA.global_variables 
   where variable_name in (
'query_cache_type',
'query_cache_size',
'query_cache_limit',
'have_query_cache',
'key_buffer_size',
'innodb_buffer_pool_size',
'innodb_buffer_pool_instances',
'innodb_additional_mem_pool_size',
'innodb_log_buffer_size',
'innodb_log_file_size',
'innodb_thread_concurrency',
'innodb_flush_method',
'innodb_file_per_table',
'read_buffer_size',
'read_rnd_buffer_size',
'sort_buffer_size', 
'thread_stack',
'join_buffer_size',
'binlog_cache_size',
'max_heap_table_size',
'tmp_table_size',
'max_connections',
'table_cache',
'table_open_cache');

-- *************************************** Section performances  **************************
select '<hr>';
select '<div align=center><b><font color="WHITE">SECTION PERFORMANCES</font></b></div>';

select '<hr>';
-- *************************************** Tables caches et ratios
select '<table border=1 width=100% bgcolor="WHITE">';
select '<tr><td bgcolor="#3399CC" align=center colspan=3><font color="WHITE"><b>Cache tables (table[_open]_cache)</b></font></td></tr>';
select '<tr><td bgcolor="WHITE" align=center width=40%><b>Variable</b></td><td bgcolor="WHITE" align=center><b>Valeur</b></td><td bgcolor="WHITE" align=center><b>Ratio d\'utilisation</b></td></tr>';
-- show variables like 'table_cache'; (< 5.1.3)
-- show variables like 'table_open_cache'; (> 5.1.3)
select concat('<tr><td bgcolor="LIGHTBLUE" align=left>',gs.variable_name,'</td><td bgcolor="LIGHTBLUE" align=right>',gs.variable_value,'</td><td bgcolor="',CASE WHEN round((gs.variable_value/gv.variable_value)*100,0) > 90 AND round((gs.variable_value/gv.variable_value)*100,0) < 99 THEN 'ORANGE' WHEN round((gs.variable_value/gv.variable_value)*100,0) > 99 THEN '#FF0000' ELSE 'LIGHTBLUE' END,'" align=right>',IF (gv.variable_value > 0, round((gs.variable_value/gv.variable_value)*100,2), 0), '% de ',gv.variable_value,'</td></tr>') 
  FROM INFORMATION_SCHEMA.global_status gs, INFORMATION_SCHEMA.global_variables gv
  where gs.variable_name ='Open_tables' and (gv.variable_name = 'TABLE_CACHE' or gv.variable_name = 'TABLE_OPEN_CACHE');
select concat('<tr><td bgcolor="LIGHTBLUE" align=left>',gs.variable_name, '</td><td bgcolor="LIGHTBLUE" align=right>',gs.variable_value,'</td><td bgcolor="LIGHTGREY" align=right><img src="data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7"></td></tr>' )
  FROM INFORMATION_SCHEMA.global_status gs
  where gs.variable_name ='Opened_tables';
select '</table>';
select '<br>';

-- *************************************** Indexes caches et ratios
select '<table border=1 width=100% bgcolor="WHITE">';
select '<tr><td bgcolor="#3399CC" align=center colspan=3><font color="WHITE"><b>Cache indexes (key_buffer_size)</b></font></td></tr>';
select '<tr><td bgcolor="WHITE" align=center width=40%><b>Statistique</b></td><td bgcolor="WHITE" align=center><b>Valeur</b></td><td bgcolor="WHITE" align=center><b>Ratio d\'utilisation</b></td></tr>';
select concat('<tr><td bgcolor="LIGHTBLUE" align=left>',s.variable_name,'</td><td bgcolor="LIGHTBLUE" align=right>',round(s.variable_value/1024,2),' Mo</td><td bgcolor="',CASE WHEN round((s.variable_value*100/(v.variable_value/1024)),0) > 90 AND  round((s.variable_value*100/(v.variable_value/1024)),0) < 99 THEN 'ORANGE' WHEN round((s.variable_value*100/(v.variable_value/1024)),0) > 99 THEN '#FF0000' ELSE 'LIGHTBLUE' END,'" align=right>',round((s.variable_value*100/(v.variable_value/1024)),2),'% de ',round(v.variable_value/1024/1024,2),' Mo','</td></tr>') FROM INFORMATION_SCHEMA.global_status s, INFORMATION_SCHEMA.global_variables v where s.variable_name in ('Key_blocks_used') and v.variable_name = 'key_buffer_size';
select concat('<tr><td bgcolor="WHITE" align=left colspan=2>Ratio read hits</td></td><td bgcolor="LIGHTBLUE" align=right>',IF (rs.variable_value > 0, round(100 - (s.variable_value/rs.variable_value)*100,2), 0),'%</td></tr>') FROM INFORMATION_SCHEMA.global_status s, INFORMATION_SCHEMA.global_status rs where s.variable_name = 'Key_reads' and rs.variable_name = 'Key_read_requests';
select concat('<td bgcolor="WHITE" align=left colspan=2>Ratio write hits</td><td bgcolor="LIGHTBLUE" align=right>',IF (rs.variable_value > 0, round(100 - (s.variable_value/rs.variable_value)*100,2), 0),'%</td><tr>') FROM INFORMATION_SCHEMA.global_status s, INFORMATION_SCHEMA.global_status rs where s.variable_name = 'Key_writes' and rs.variable_name = 'Key_write_requests';
select '</td></tr></table>';
select '<br>';

-- *************************************** Query cache
select '<table border=1 width=100% bgcolor="WHITE">';
select '<tr><td bgcolor="#3399CC" align=center colspan=3><font color="WHITE"><b>Cache requ&ecirc;tes (query_cache_size)</b></font></td></tr>';
select '<tr><td bgcolor="WHITE" align=center width=40%><b>Statistique</b></td><td bgcolor="WHITE" align=center><b>Valeur</b></td><td bgcolor="WHITE" align=center><b>Ratio d\'utilisation</b></td></tr>'; -- \'

SELECT IF(q.variable_value = 'YES',
		IF(v.variable_value > 0,
		concat('<tr><td bgcolor="LIGHTBLUE" align=left>','M&eacute;moire utilis&eacute;e (<b>valeur instantan&eacute;e</b>)','</td><td bgcolor="LIGHTBLUE" align=right>',round((v.variable_value-s.variable_value)/1024/1024,2),' Mo</td><td bgcolor="', CASE WHEN round(((v.variable_value-s.variable_value)/v.variable_value)*100,0) > 90 AND round(((v.variable_value-s.variable_value)/v.variable_value)*100,0) < 99 THEN 'ORANGE' WHEN round(((v.variable_value-s.variable_value)/v.variable_value)*100,0) > 99 THEN '#FF0000' ELSE 'LIGHTBLUE' END,'" align=right>', round(((v.variable_value-s.variable_value)/v.variable_value)*100,2),'% de ',  round(v.variable_value/1024/1024,2),' Mo</td></tr>'),
		'<tr><td bgcolor="ORANGE">Cache activ&eacute; (have_query_cache=YES) mais query_cache_size=0</td><td bgcolor="ORANGE" align=right>0</td><td bgcolor="LIGHTGREY"> </td></tr>'),
		'<tr><td bgcolor="ORANGE">Cache non activ&eacute;</td><td bgcolor="ORANGE">N/A</td><td bgcolor="ORANGE">N/A</td></tr>')
	FROM INFORMATION_SCHEMA.global_status s, INFORMATION_SCHEMA.global_variables v, INFORMATION_SCHEMA.global_variables q
	where s.variable_name = 'Qcache_free_memory'
	and v.variable_name = 'query_cache_size'
	and q.variable_name = 'have_query_cache';
SELECT IF(q.variable_value = 'YES' AND v.variable_value > 0,
        IF (sqch.variable_value > 0 AND sq.variable_value > 0,
		  concat('<tr><td bgcolor="LIGHTBLUE" align=left>','Ratio QC hits','</td><td bgcolor="LIGHTBLUE" align=right>', sqch.variable_value,' hits</td><td bgcolor="',IF (round((sqch.variable_value/(sqch.variable_value+sq.variable_value))*100,0) <= 50,'ORANGE','LIGHTBLUE'),'" align=right>', round((sqch.variable_value/(sqch.variable_value+sq.variable_value))*100,2),'% de ', sq.variable_value, ' requ&ecirc;tes cachables','</td></tr>'),
          '<tr><td bgcolor="ORANGE">Ratio QC hits</td><td bgcolor="ORANGE">0</td><td bgcolor="ORANGE" align=center>Aucune requ&ecirc;te sur la p&eacute;riode</td></tr>'),
		'')
	FROM INFORMATION_SCHEMA.global_status sqch, INFORMATION_SCHEMA.global_status sq, INFORMATION_SCHEMA.global_variables v, INFORMATION_SCHEMA.global_variables q
	WHERE sqch.variable_name = 'Qcache_hits'
--	and sq.variable_name = 'Com_select' -- for "all queries" (even not cacheable) hit ratio
	and sq.variable_name = 'Qcache_inserts' -- hit ratio only for cacheable queries
	and v.variable_name = 'query_cache_size'
	and q.variable_name = 'have_query_cache';
	
SELECT IF(q.variable_value = 'YES' AND v.variable_value > 0,
		concat('<tr><td bgcolor="LIGHTBLUE" align=left>','QC prune / jour','</td><td bgcolor="',IF(sq.variable_value/(squ.variable_value/86400)>98, 'ORANGE"','LIGHTBLUE"'),' align=right colspan=2>', round(sq.variable_value/(squ.variable_value/86400),0) ,'</td></tr>'),
		'')
	FROM INFORMATION_SCHEMA.global_status squ, INFORMATION_SCHEMA.global_status sq, INFORMATION_SCHEMA.global_variables v, INFORMATION_SCHEMA.global_variables q
	WHERE squ.variable_name = 'Uptime'
	and sq.variable_name = 'Qcache_lowmem_prunes'
	and v.variable_name = 'query_cache_size'
	and q.variable_name = 'have_query_cache';

-- ratio = Qcache_hits / (Qcache_hits + Com_select)

-- A integrer : SELECT GRANTEE, PRIVILEGE_TYPE FROM USER_PRIVILEGES;
-- TODO : voir section Questions -> mysqlreport + section Query cache
-- TODO : Performance Metrics (voir mysqltuner)

select '</table>';
select '<br>';

-- *************************************** Table locks
select '<table border=1 width=100% bgcolor="WHITE">';
select '<tr><td bgcolor="#3399CC" align=center colspan=2><font color="WHITE"><b>Verrous de tables</b></font></td></tr>';
select '<tr><td bgcolor="WHITE" align=center width=40%><b>Statistique</b></td><td bgcolor="WHITE" align=center><b>Valeur</b></td></tr>';
SELECT concat('<tr><td bgcolor="LIGHTBLUE" align=left>', 'acquis imm&eacute;diatement','</td><td bgcolor="LIGHTBLUE" align=right>', i.variable_value, '</td></tr>')
FROM INFORMATION_SCHEMA.global_status i
WHERE i.variable_name = 'Table_locks_immediate';
SELECT concat('<tr><td bgcolor="LIGHTBLUE" align=left>', 'n&eacute;cessitant une attente','</td><td bgcolor="LIGHTBLUE" align=right>', w.variable_value, '</td></tr>')
FROM INFORMATION_SCHEMA.global_status w
WHERE w.variable_name = 'Table_locks_waited';
SELECT concat('<tr><td bgcolor="WHITE" align=left>', 'Ratio','</td><td bgcolor="LIGHTBLUE" align=right>', round(w.variable_value/(i.variable_value + w.variable_value)*100,2), '%</td></tr>')
FROM INFORMATION_SCHEMA.global_status i,INFORMATION_SCHEMA.global_status w WHERE i.variable_name = 'Table_locks_immediate' and w.variable_name = 'Table_locks_waited';

select '</table>';
select '<br>';

-- *************************************** Section processus et sessions **************************
select '<hr>';
select '<div align=center><b><font color="WHITE">SECTION PROCESSUS ET SESSIONS</font></b></div>';

select '<hr>';
-- *************************************** Connexions
select '<table border=1 width=100% bgcolor="WHITE">';
select '<tr><td bgcolor="#3399CC" align=center colspan=3><font color="WHITE"><b>Connexions</b></font></td></tr>';
select '<tr><td bgcolor="WHITE" align=center width=40%><b>Statistique</b></td><td bgcolor="WHITE" align=center><b>Nombre</b></td><td bgcolor="WHITE" align=center><b>Ratio d\'utilisation</b></td></tr>'; -- \'

-- max_connection = HWM of concurrent connections since boot
SELECT concat('<tr><td bgcolor="LIGHTBLUE" align=left>', 'Nombre de connexions simultan&eacute;es (max. atteint)','</td><td bgcolor="LIGHTBLUE" align=right>', s.variable_value,'</td><td bgcolor="',CASE WHEN round((s.variable_value/v.variable_value)*100,0) > 90 AND round((s.variable_value/v.variable_value)*100,0) < 99 THEN 'ORANGE' WHEN round((s.variable_value/v.variable_value)*100,0) > 99 THEN '#FF0000' ELSE 'LIGHTBLUE' END,'" align=right>', IF (v.variable_value > 0, round((s.variable_value/v.variable_value)*100,2), 0),'% de ', v.variable_value, ' (max_connections)') FROM INFORMATION_SCHEMA.global_status s,INFORMATION_SCHEMA.global_variables v WHERE s.variable_name = 'Max_used_connections' and v.variable_name = 'max_connections';
select '</td></tr>';

-- Aborted_clients = connectes puis deconnectes (coupure); Aborted_connects = meme pas connectes (droits)
SELECT concat('<tr><td bgcolor="LIGHTBLUE" align=left>', 'Connexions interrompues','</td><td bgcolor="LIGHTBLUE" align=right colspan=2>', scl.variable_value, 
CASE WHEN scl.variable_value > (upt.variable_value/86400) AND upt.variable_value/86400 > 1 THEN concat(' (', round(scl.variable_value / (floor(upt.variable_value/86400)),0), ' / jour)')
     WHEN scl.variable_value = 0 THEN ''
     WHEN upt.variable_value/86400 < 1 THEN ' ( uptime < 1 jour )'
 ELSE ' ( < 1/jour )' END,
 '</td></tr><td bgcolor="LIGHTBLUE" align=left>', 'Connexions invalides', '</td><td bgcolor="LIGHTBLUE" align=right colspan=2>', sco.variable_value, 
CASE WHEN sco.variable_value > (upt.variable_value/86400) AND upt.variable_value/86400 > 1 THEN concat(' (', round(sco.variable_value / (floor(upt.variable_value/86400)),0), ' / jour)')
     WHEN sco.variable_value = 0 THEN ''
     WHEN upt.variable_value/86400 < 1 THEN ' ( uptime < 1 jour )'
 ELSE ' ( < 1/jour )' END,
 '</td>') FROM INFORMATION_SCHEMA.global_status scl, INFORMATION_SCHEMA.global_status sco, information_schema.global_status upt
 WHERE scl.variable_name = 'Aborted_clients'
 AND sco.variable_name = 'Aborted_connects'
 AND upt.variable_name='Uptime';

-- *************************************** Threads
select '<tr><td bgcolor="#3399CC" align=center colspan=3><font color="WHITE"><b>Threads</b></font></td></tr>';
select '<tr><td bgcolor="WHITE" align=center width=40%><b>Statistique</b></td><td bgcolor="WHITE" align=center colspan=2><b>Valeur</b></td></tr>';
select concat('<tr><td bgcolor="LIGHTBLUE" align=left>',IF(gs.variable_name='THREADS_CONNECTED', concat(gs.variable_name,' (Connexions en cours)'),gs.variable_name),'</td><td bgcolor="LIGHTBLUE" align=right colspan=2>', gs.variable_value, '</td><tr>')
  FROM INFORMATION_SCHEMA.global_status gs
  where gs.variable_name = 'Threads_created' or gs.variable_name = 'Threads_connected' or gs.variable_name = 'Connections'
order by gs.variable_name ASC;

-- 100 - ((Threads_created / Connections) * 100)
-- Thread hits ratio < 100% indicates a thread_cache_size to increase
select concat('<tr><td bgcolor="WHITE" align=left>Ratio Thread hits (Threads_created / Connections)</td><td bgcolor="LIGHTBLUE" align=right colspan=2>', round(100 - ((gs.variable_value/gsq.variable_value) * 100), 2), '%</td><tr>')
  FROM INFORMATION_SCHEMA.global_status gs, INFORMATION_SCHEMA.global_status gsq
  where gs.variable_name = 'Threads_created' and gsq.variable_name = 'Connections';

select '</td></tr></table>';
select '<br>';

-- *************************************** Statistiques réseau
select '<table border=1 width=100% bgcolor="WHITE">';
select '<tr><td bgcolor="#3399CC" align=center colspan=2><font color="WHITE"><b>Statistiques r&eacute;seau</b></font></td></tr>';
select '<tr><td bgcolor="WHITE" align=center width=40%><b>In/Out</b></td><td bgcolor="WHITE" align=center><b>Valeur</b></td></tr>';
select concat('<tr><td bgcolor="LIGHTBLUE" align=left>Octets envoy&eacute;s</td><td bgcolor="LIGHTBLUE" align=right>', IF(variable_value > 1048576, IF(variable_value > 1073741824, round(variable_value/1024/1024/1024,2), round(variable_value/1024/1024,2)), round(variable_value/1024,2)), IF(variable_value > 1048576, IF(variable_value > 1073741824,' Go', ' Mo'), ' Ko'), '</td></tr>')
  FROM INFORMATION_SCHEMA.global_status
  where variable_name = 'Bytes_sent';
select concat('<tr><td bgcolor="LIGHTBLUE" align=left>Octets re&ccedil;us</td><td bgcolor="LIGHTBLUE" align=right>', IF(variable_value > 1048576, IF(variable_value > 1073741824, round(variable_value/1024/1024/1024,2), round(variable_value/1024/1024,2)), round(variable_value/1024,2)), IF(variable_value > 1048576, IF(variable_value > 1073741824,' Go', ' Mo'), ' Ko'))
  FROM INFORMATION_SCHEMA.global_status
  where variable_name = 'Bytes_received';

select '</td></tr></table>';
select '<br>';

-- *************************************** Section Requêtes **************************
select '<hr>';
select '<div align=center><b><font color="WHITE">SECTION REQUETES</font></b></div>';

select '<hr>';

-- *************************************** Tris
select '<table border=1 width=100% bgcolor="WHITE">';
select '<tr><td bgcolor="#3399CC" align=center colspan=3><font color="WHITE"><b>Tris</b></font></td></tr>';
select '<tr><td bgcolor="WHITE" align=center width=40%><b>Statistique</b></td><td bgcolor="WHITE" align=center><b>Valeur</b></td></tr>';
select concat('<tr><td bgcolor="LIGHTBLUE" align=left> Total des tris </td>', '<td bgcolor="LIGHTBLUE" align=right>', gss.variable_value + gsr.variable_value, '</td></tr>')
  FROM INFORMATION_SCHEMA.global_status gss, INFORMATION_SCHEMA.global_status gsr
  where gss.variable_name = 'Sort_scan'
  and gsr.variable_name = 'Sort_range';

-- ratio must be < 10%, else increase sort_buffer_size and read_rnd_buffer_size
select concat('<tr><td bgcolor="WHITE" align=left>Tris n&eacute;cessitant une table temporaire</td>', '<td bgcolor="LIGHTBLUE" align=right>', IF (gss.variable_value + gsr.variable_value > 0, round((gsmp.variable_value / (gss.variable_value + gsr.variable_value) *100),2), 0), '%</td></tr>')
  FROM INFORMATION_SCHEMA.global_status gss, INFORMATION_SCHEMA.global_status gsr, INFORMATION_SCHEMA.global_status gsmp
  where gss.variable_name = 'Sort_scan'
  and gsr.variable_name = 'Sort_range'
  and gsmp.variable_name = 'Sort_merge_passes';

select '</table>'; -- </td></tr>
select '<br>';

-- *************************************** Jointures sans indexes
select '<table border=1 width=100% bgcolor="WHITE">';
select '<tr><td bgcolor="#3399CC" align=center colspan=2><font color="WHITE"><b>Jointures sans indexes</b></font></td></tr>';
select '<tr><td bgcolor="WHITE" align=center width=40%><b>Statistique</b></td><td bgcolor="WHITE" align=center><b>Valeur</b></td></tr>';
select '<tr><td bgcolor="LIGHTBLUE" align=left>','Nombre de jointures sans indexes', '</td>', concat('<td bgcolor=', IF((sum(gs.variable_value)/(squ.variable_value/86400)) > 100, '"ORANGE"','"LIGHTBLUE"'), ' align=right>'), sum(gs.variable_value), ' (', IF (squ.variable_value >= 86400, round(sum(gs.variable_value)/(squ.variable_value/86400)), sum(gs.variable_value)), ' / jour)</td><tr>'
  FROM INFORMATION_SCHEMA.global_status gs, INFORMATION_SCHEMA.global_status squ
  where gs.variable_name in ( 'Select_range_check', 'Select_full_join')
  and squ.variable_name = 'Uptime';

select '</table>'; -- </td></tr>
select '<br>';

-- *************************************** état des tables et indexes NOT OK
-- TODO : vérifier si des indexes sont à reconstruire ? CHECK TABLE sur toutes les tables (=mysqlcheck) de toutes les bases et récupérer Msg_test ?
-- SELECT table_name, engine, table_type, table_schema FROM information_schema.tables;
-- check table <schema_name>.<table_name>;

-- *************************************** Tables temporaires
select sum(variable_value) into @tmp_total
  FROM INFORMATION_SCHEMA.global_status
  where variable_name in ( 'Created_tmp_tables', 'Created_tmp_disk_tables', 'Created_tmp_files');
select '<table border=1 width=100% bgcolor="WHITE">';
select '<tr><td bgcolor="#3399CC" align=center colspan=3><font color="WHITE"><b>Tables temporaires</b></font></td></tr>';
select '<tr><td bgcolor="WHITE" align=center width=40%><b>Statistique</b></td><td bgcolor="WHITE" align=center><b>Valeur</b></td><td bgcolor="WHITE" align=center><b>% du total tables temporaires</b></td></tr>';
select concat('<tr><td bgcolor="LIGHTBLUE" align=left>', CASE WHEN gs.variable_name='Created_tmp_disk_tables' THEN 'Tables sur disque' WHEN gs.variable_name='Created_tmp_tables' THEN 'Tables en m&eacute;moire' ELSE 'Tables en fichiers' END,'</td><td bgcolor="LIGHTBLUE" align=right>', gs.variable_value,'</td><td bgcolor="',IF (round((gs.variable_value/@tmp_total)*100, 0) >= 30 AND gs.variable_name  = 'Created_tmp_disk_tables','ORANGE','LIGHTBLUE'),'" align=right>', round((gs.variable_value/@tmp_total)*100, 2), '%</td><tr>')
  FROM INFORMATION_SCHEMA.global_status gs
  where gs.variable_name in ( 'Created_tmp_tables', 'Created_tmp_disk_tables', 'Created_tmp_files')
  order by gs.variable_name DESC;
  
select '</table>'; -- </td></tr>
select '<br>';

-- *************************************** Slow queries
select '<table border=1 width=100% bgcolor="WHITE">';
select '<tr><td bgcolor="#3399CC" align=center colspan=2><font color="WHITE"><b>Slow queries</b></font></td></tr>';
select '<tr><td bgcolor="WHITE" align=center width=40%><b>Journalisation slow queries</b></td><td bgcolor="WHITE" align=center><b>Fichier journal</b></td></tr>';
select concat('<tr><td align=left bgcolor="', IF(sq.variable_value = 'ON','#33FF33','ORANGE'),'">', sq.variable_value, '</td><td bgcolor="',IF(sq.variable_value = 'ON', 'LIGHTBLUE', 'LIGHTGREY'),'" align=right>', IF(sq.variable_value = 'ON', sf.variable_value, ''), '</td></tr>')
	from INFORMATION_SCHEMA.global_variables sq, INFORMATION_SCHEMA.global_variables sf
	where sq.variable_name = 'SLOW_QUERY_LOG'
	and sf.variable_name = 'SLOW_QUERY_LOG_FILE';
select IF(sq.variable_value = 'ON',
	'<tr><td bgcolor="WHITE" align=center width=40%><b>Statistique</b></td><td bgcolor="WHITE" align=center><b>Valeur</b></td></tr>',
	'')
	from INFORMATION_SCHEMA.global_variables sq
	where sq.variable_name = 'SLOW_QUERY_LOG';
select IF(sq.variable_value = 'ON',
	concat('<tr><td bgcolor="LIGHTBLUE" align=left>Nombre slow queries (>', round(gv.variable_value,2), ' s)</td><td bgcolor="LIGHTBLUE" align=right>', gs.variable_value, '</td><tr>'),
	'')
  FROM INFORMATION_SCHEMA.global_status gs, INFORMATION_SCHEMA.global_variables gv, INFORMATION_SCHEMA.global_variables sq
  where gs.variable_name = 'Slow_queries' 
  and gv.variable_name = 'long_query_time'
  and sq.variable_name = 'SLOW_QUERY_LOG';
select IF(sq.variable_value = 'ON',
	concat('<tr><td bgcolor="LIGHTBLUE" align=left>Nombre total requ&ecirc;tes</td><td bgcolor="LIGHTBLUE" align=right>', gsq.variable_value, '</td><tr>'),
	'')
  FROM INFORMATION_SCHEMA.global_status gsq, INFORMATION_SCHEMA.global_variables sq
  where gsq.variable_name = 'Questions'
  and sq.variable_name = 'SLOW_QUERY_LOG';
select IF(sq.variable_value = 'ON',
	concat('<tr><td bgcolor="WHITE" align=left>Ratio (slow queries/requ&ecirc;tes)</td><td bgcolor="LIGHTBLUE" align=right>', round((gs.variable_value * 100) / gsq.variable_value, 2), '%</td><tr>'),
	'')
  FROM INFORMATION_SCHEMA.global_status gs, INFORMATION_SCHEMA.global_status gsq, INFORMATION_SCHEMA.global_variables sq
  where gs.variable_name = 'Slow_queries' 
  and gsq.variable_name = 'Questions'
  and sq.variable_name = 'SLOW_QUERY_LOG';
  
select '</table>'; -- </td></tr>
select '<br>';

--  *************************************** Section INNODB **************************
-- BUGS
-- : si InnoDB non activé (variable ignore_builtin_innodb n'existe pas pour engine "InnoDB"), les requêtes renvoie "empty" et n'affiche donc rien. Comment forcer des cellules vides (couleur grise)?
-- : read bits peut être incohérent

select '<hr>';
select '<div align=center><b><font color="WHITE">SECTION INNODB</font></b></div>';
select '<hr>';

select '<table border=1 width=100% bgcolor="WHITE">';
select '<tr><td bgcolor="#3399CC" align=center colspan=3><font color="WHITE"><b>InnoDB</b></font></td></tr>';
select '<tr><td bgcolor="WHITE" align=center width=40%><b>Activ&eacute; ?</b></td><td bgcolor="WHITE" align=center><b>Utilis&eacute; ?</b></td><td bgcolor="WHITE" align=center><b>Volumes</b></td></tr>';

select concat('<tr><td align=left bgcolor="', IF(sq.variable_value = 'ON','ORANGE','#33FF33'),'">', IF(sq.variable_value = 'ON','NO','YES'), '</td><td bgcolor="',IF(sq.variable_value = 'ON','LIGHTGREY','#33FF33'),'">', IF(SUM(it.DATA_LENGTH+it.INDEX_LENGTH) > 0,'YES','NO'), '</td><td bgcolor="',IF(sq.variable_value = 'ON','LIGHTGREY','LIGHTBLUE'),'" align=right>', IF(SUM(it.DATA_LENGTH+it.INDEX_LENGTH) > 0,concat('Datas: ',round(SUM(it.DATA_LENGTH)/1024/1024,2),' Mo, Indexes: ',round(SUM(it.INDEX_LENGTH)/1024/1024,2),' Mo'),'Ajouter skip-innodb &agrave: la configuration'), '</td></tr>')
  from INFORMATION_SCHEMA.global_variables sq, information_schema.TABLES it
  where sq.variable_name = 'ignore_builtin_innodb'
  and TABLE_SCHEMA NOT IN ('information_schema', 'performance_schema', 'mysql')
  AND ENGINE = 'InnoDB'
  GROUP BY ENGINE;
select IF(count(*) = 0, '<td align=center bgcolor="ORANGE"><b>NON</b></td><td bgcolor="LIGHTGREY">&nbsp;</td><td bgcolor="LIGHTGREY" align=right>&nbsp;</td></tr>','')
  from INFORMATION_SCHEMA.global_variables sq, information_schema.TABLES it
  where sq.variable_name = 'ignore_builtin_innodb'
  and TABLE_SCHEMA NOT IN ('information_schema', 'performance_schema', 'mysql')
  AND ENGINE = 'InnoDB';

select IF(sq.variable_value <> 'ON',
			'<tr><td bgcolor="#3399CC" align=center colspan=3><font color="WHITE"><b>Buffer pool InnoDB</b></font></td></tr>','')
 	from INFORMATION_SCHEMA.global_variables sq
 	where sq.variable_name = 'ignore_builtin_innodb';
select IF(sq.variable_value <> 'ON',
			'<tr><td bgcolor="WHITE" align=center width=40%><b>Statistique</b></td><td bgcolor="WHITE" align=center><b>Valeur</b></td><td bgcolor="WHITE" align=center><b>Ratio d\'utilisation</b></td></tr>','') -- \'
	from INFORMATION_SCHEMA.global_variables sq
	where sq.variable_name = 'ignore_builtin_innodb';

select IF(sq.variable_value <> 'ON',
		concat('<tr><td align=left bgcolor="LIGHTBLUE">Buffer pool</td>', '<td align=right bgcolor="LIGHTBLUE">',round(((gspt.variable_value - gspf.variable_value) * gsps.variable_value)/1024/1024,2), ' Mo</td>', '<td align=right bgcolor="LIGHTBLUE">', 		
		 IF (gspt.variable_value > 0, round((((gspt.variable_value - gspf.variable_value) / gspt.variable_value) * 100),2), 0), ' % de ', round((gspt.variable_value * gsps.variable_value)/1024/1024,2), ' Mo</td></tr>'), '')
	FROM INFORMATION_SCHEMA.global_variables sq, INFORMATION_SCHEMA.global_status gspt, INFORMATION_SCHEMA.global_status gspf, INFORMATION_SCHEMA.global_status gsps
	WHERE sq.variable_name = 'ignore_builtin_innodb'
	AND gspt.variable_name = 'Innodb_buffer_pool_pages_total'
	AND gspf.variable_name = 'Innodb_buffer_pool_pages_free'
	AND gsps.variable_name = 'Innodb_page_size';
select IF(sq.variable_value <> 'ON',
			concat('<tr><td align=left bgcolor="LIGHTBLUE">Read hits</td>', '<td align=right bgcolor="LIGHTBLUE" colspan=2>', 
				IF(gsprr.variable_value > 0,concat(round((gsprr.variable_value / (gspr.variable_value + gsprr.variable_value) * 100),2), ' %'), 0),'</td></tr>'), '')
	FROM INFORMATION_SCHEMA.global_variables sq, INFORMATION_SCHEMA.global_status gsprr, INFORMATION_SCHEMA.global_status gspr
	WHERE sq.variable_name = 'ignore_builtin_innodb'
	AND gsprr.variable_name = 'Innodb_buffer_pool_read_requests'
	AND gspr.variable_name = 'Innodb_buffer_pool_reads';
select IF(sq.variable_value <> 'ON',
			concat('<tr><td align=left bgcolor="LIGHTBLUE">Locks waits</td>', '<td align=right bgcolor="LIGHTBLUE" colspan=2>', 
				gsl.variable_value, '</td></tr>'), '')
	FROM INFORMATION_SCHEMA.global_variables sq, INFORMATION_SCHEMA.global_status gsl
	WHERE sq.variable_name = 'ignore_builtin_innodb'
	AND gsl.variable_name = 'Innodb_row_lock_waits';
select IF(count(*) = 0,'<tr><td bgcolor="LIGHTGREY" align=center width=40%>&nbsp;</td><td bgcolor="LIGHTGREY" align=center>&nbsp;</td><td bgcolor="LIGHTGREY" align=center></td>&nbsp;</tr>','')
  from INFORMATION_SCHEMA.global_variables sq, information_schema.TABLES it
  where sq.variable_name = 'ignore_builtin_innodb'
  and TABLE_SCHEMA NOT IN ('information_schema', 'performance_schema', 'mysql')
  AND ENGINE = 'InnoDB';

select '</table>'; -- </td></tr>
select '<br>';

select '<hr>';

-- ********************** Percona ******************************
-- show status like wsrep
-- si 'wsrep_ready' = ON alors lister les autres paramètres
-- 
-- étudier https://www.percona.com/sites/default/files/innodb_performance_optimization_final.pdf

-- *************************************** Fin de rapport **************************
select '</body>'; -- </td></tr>
select '</html>';
