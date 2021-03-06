set hive.stats.dbclass=fs;
CREATE TABLE srcpart_rc (key int, value string) PARTITIONED BY (ds string, hr int) STORED AS RCFILE;

INSERT OVERWRITE TABLE srcpart_rc PARTITION (ds='2008-04-08', hr=11) SELECT key, value FROM srcpart WHERE ds = '2008-04-08' AND hr = 11;
INSERT OVERWRITE TABLE srcpart_rc PARTITION (ds='2008-04-08', hr=12) SELECT key, value FROM srcpart WHERE ds = '2008-04-08' AND hr = 12;
INSERT OVERWRITE TABLE srcpart_rc PARTITION (ds='2008-04-09', hr=11) SELECT key, value FROM srcpart WHERE ds = '2008-04-09' AND hr = 11;
INSERT OVERWRITE TABLE srcpart_rc PARTITION (ds='2008-04-09', hr=12) SELECT key, value FROM srcpart WHERE ds = '2008-04-09' AND hr = 12;

CREATE INDEX srcpart_rc_index ON TABLE srcpart_rc(key) as 'COMPACT' WITH DEFERRED REBUILD;
ALTER INDEX srcpart_rc_index ON srcpart_rc REBUILD;
SELECT x.* FROM default__srcpart_rc_srcpart_rc_index__ x WHERE x.ds = '2008-04-08' and x.hr = 11 ORDER BY key;

SET hive.input.format=org.apache.hadoop.hive.ql.io.HiveInputFormat;
INSERT OVERWRITE DIRECTORY "${system:test.tmp.dir}/index_test_index_result" SELECT `_bucketname` ,  `_offsets` FROM default__srcpart_rc_srcpart_rc_index__ x WHERE x.key=100 AND x.ds = '2008-04-08';
SET hive.index.compact.file=${system:test.tmp.dir}/index_test_index_result;
SET hive.input.format=org.apache.hadoop.hive.ql.index.compact.HiveCompactIndexInputFormat;
SELECT key, value FROM srcpart_rc WHERE key=100 AND ds = '2008-04-08' ORDER BY key;

SET hive.input.format=org.apache.hadoop.hive.ql.io.HiveInputFormat;
INSERT OVERWRITE DIRECTORY "${system:test.tmp.dir}/index_test_index_result" SELECT `_bucketname` ,  `_offsets` FROM default__srcpart_rc_srcpart_rc_index__ x WHERE x.key=100 AND x.ds = '2008-04-08' and x.hr = 11;
SET hive.index.compact.file=${system:test.tmp.dir}/index_test_index_result;
SET hive.input.format=org.apache.hadoop.hive.ql.index.compact.HiveCompactIndexInputFormat;
SELECT key, value FROM srcpart_rc WHERE key=100 AND ds = '2008-04-08' and hr = 11 ORDER BY key;

SET hive.input.format=org.apache.hadoop.hive.ql.io.HiveInputFormat;
SELECT key, value FROM srcpart_rc WHERE key=100 AND ds = '2008-04-08' and hr = 11 ORDER BY key;

DROP INDEX srcpart_rc_index on srcpart_rc;

EXPLAIN
CREATE INDEX srcpart_rc_index ON TABLE srcpart_rc(key) as 'COMPACT' WITH DEFERRED REBUILD;
CREATE INDEX srcpart_rc_index ON TABLE srcpart_rc(key) as 'COMPACT' WITH DEFERRED REBUILD;
ALTER  INDEX srcpart_rc_index ON srcpart_rc REBUILD;
SELECT x.* FROM default__srcpart_rc_srcpart_rc_index__ x ORDER BY key;

SET hive.input.format=org.apache.hadoop.hive.ql.io.HiveInputFormat;
INSERT OVERWRITE DIRECTORY "${system:test.tmp.dir}/index_result" SELECT `_bucketname` ,  `_offsets` FROM default__srcpart_rc_srcpart_rc_index__ WHERE key=100;
SET hive.index.compact.file=${system:test.tmp.dir}/index_result;
SET hive.input.format=org.apache.hadoop.hive.ql.index.compact.HiveCompactIndexInputFormat;
SELECT key, value FROM srcpart_rc WHERE key=100 ORDER BY key;

SET hive.input.format=org.apache.hadoop.hive.ql.io.HiveInputFormat;
SELECT key, value FROM srcpart_rc WHERE key=100 ORDER BY key;

DROP INDEX srcpart_rc_index on srcpart_rc;
DROP TABLE srcpart_rc;
