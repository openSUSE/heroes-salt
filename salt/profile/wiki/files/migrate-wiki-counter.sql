/*
 * migrate hit counter data to the separate table used by the HitCounters extension
 *
 * run this BEFORE running maintenance/update.php, or counter data will be lost!
 *
 * Source: https://www.mediawiki.org/wiki/Extension_talk:HitCounters#Manual_generation_of_DB_tables_during_upgrade
 */

RENAME TABLE hitcounter TO hit_counter_extension;
CREATE TABLE hit_counter (
  page_id INT(8) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
  page_counter BIGINT(20) UNSIGNED NOT NULL DEFAULT '0'
) ;
CREATE INDEX page_counter ON hit_counter (page_counter);
INSERT INTO hit_counter (page_id, page_counter) SELECT page.page_id, page.page_counter FROM page;
