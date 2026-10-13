SET PAGESIZE 100
SET LINESIZE 200
SET FEEDBACK OFF
SET HEADING ON
SET VERIFY OFF

PROMPT === DATABASE HEALTH ===
SELECT name, open_mode, database_role
FROM v$database;

PROMPT === DATAFILE STATUS ===
SELECT tablespace_name, status, COUNT(*) AS file_count
FROM dba_data_files
GROUP BY tablespace_name, status
ORDER BY tablespace_name;

PROMPT === TABLESPACE USAGE ===
SELECT tablespace_name,
       ROUND(used_percent, 2) AS used_percent
FROM dba_tablespace_usage_metrics
ORDER BY used_percent DESC;

PROMPT === INVALID OBJECT COUNT ===
SELECT COUNT(*) AS invalid_objects
FROM dba_objects
WHERE status = 'INVALID';

PROMPT === BLOCKING SESSION COUNT ===
SELECT COUNT(*) AS blocking_sessions
FROM v$session
WHERE blocking_session IS NOT NULL;

PROMPT === END ===
EXIT
