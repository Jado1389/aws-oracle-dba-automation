-- Run while connected to the intended Oracle database/PDB.
-- Read-only inventory of tablespaces and datafiles.

SET PAGESIZE 100
SET LINESIZE 220
SET TRIMSPOOL ON
COLUMN tablespace_name FORMAT A25
COLUMN file_name FORMAT A90
COLUMN status FORMAT A12

PROMPT === TABLESPACES ===
SELECT tablespace_name,
       status,
       contents,
       extent_management,
       allocation_type
FROM dba_tablespaces
ORDER BY tablespace_name;

PROMPT === DATAFILES ===
SELECT tablespace_name,
       file_name,
       ROUND(bytes / 1024 / 1024, 2) AS size_mb,
       autoextensible,
       ROUND(maxbytes / 1024 / 1024, 2) AS max_size_mb,
       status
FROM dba_data_files
ORDER BY tablespace_name, file_name;

PROMPT === DATABASE FILE DESTINATION ===
SHOW PARAMETER db_create_file_dest
