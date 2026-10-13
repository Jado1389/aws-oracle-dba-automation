-- Read-only control-file monitoring.
-- Run as an account with appropriate catalog privileges.

SET PAGESIZE 100
SET LINESIZE 200
SET TRIMSPOOL ON

PROMPT === DATABASE IDENTITY ===
SELECT name, dbid, open_mode, database_role
FROM v$database;

PROMPT === CONTROL FILE LOCATIONS AND STATUS ===
SELECT name, status, is_recovery_dest_file,
       block_size, file_size_blks
FROM v$controlfile
ORDER BY name;

PROMPT === CONTROL FILE RECORD SECTION USAGE ===
SELECT type,
       record_size,
       records_total,
       records_used,
       ROUND(records_used * 100 / NULLIF(records_total, 0), 2)
         AS percent_used
FROM v$controlfile_record_section
ORDER BY type;

