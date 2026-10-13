-- Read-only tablespace capacity report.
-- Run in the intended database/PDB with access to DBA views.

SET PAGESIZE 100
SET LINESIZE 180
COLUMN tablespace_name FORMAT A30

SELECT m.tablespace_name,
       ROUND(m.used_space * t.block_size / 1024 / 1024, 2) AS used_mb,
       ROUND(m.tablespace_size * t.block_size / 1024 / 1024, 2) AS capacity_mb,
       ROUND(
         100 * m.used_space / NULLIF(m.tablespace_size, 0), 2
       ) AS used_pct
FROM dba_tablespace_usage_metrics m
JOIN dba_tablespaces t
  ON t.tablespace_name = m.tablespace_name
ORDER BY used_pct DESC NULLS LAST;
