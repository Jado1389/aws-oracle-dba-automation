-- Read-only Oracle DBA monitoring report.
SET PAGESIZE 100
SET LINESIZE 220
SET TRIMSPOOL ON
SET FEEDBACK ON

PROMPT === DATABASE STATUS ===
SELECT name, open_mode, database_role FROM v$database;

PROMPT === CONTROL FILES ===
SELECT name, status FROM v$controlfile ORDER BY name;

PROMPT === DATAFILE STATUS AND SIZE ===
SELECT tablespace_name, file_name, status,
       ROUND(bytes/1024/1024,2) AS size_mb,
       autoextensible,
       ROUND(maxbytes/1024/1024,2) AS max_size_mb
FROM dba_data_files
ORDER BY tablespace_name, file_name;

PROMPT === TABLESPACE UTILIZATION ===
SELECT tablespace_name,
       ROUND(used_space * block_size / 1024 / 1024, 2) AS used_mb,
       ROUND(tablespace_size * block_size / 1024 / 1024, 2) AS capacity_mb,
       ROUND(used_percent, 2) AS used_percent
FROM dba_tablespace_usage_metrics
ORDER BY used_percent DESC;

PROMPT === INVALID OBJECTS ===
SELECT owner, object_type, COUNT(*) AS invalid_count
FROM dba_objects
WHERE status = 'INVALID'
GROUP BY owner, object_type
ORDER BY invalid_count DESC;

PROMPT === BLOCKING SESSIONS ===
SELECT sid, serial#, username, blocking_session, event,
       seconds_in_wait
FROM v$session
WHERE blocking_session IS NOT NULL
ORDER BY seconds_in_wait DESC;

PROMPT === END OF REPORT ===
EXIT
