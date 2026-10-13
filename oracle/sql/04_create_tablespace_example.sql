-- EXAMPLE: intentionally not executed automatically.
-- First inspect 01_database_storage_report.sql and verify:
-- 1. You are connected to the intended PDB.
-- 2. DB_CREATE_FILE_DEST is set to a valid Oracle-managed destination.
-- 3. The underlying disk has sufficient free space.
-- 4. The tablespace name does not already exist.
--
-- Run only with an authorized DBA account.
-- The example has a 500 MB maximum datafile size.

CREATE TABLESPACE app_data
  DATAFILE SIZE 100M
  AUTOEXTEND ON NEXT 10M
  MAXSIZE 500M
  EXTENT MANAGEMENT LOCAL
  SEGMENT SPACE MANAGEMENT AUTO;

-- Verify after creation:
SELECT tablespace_name, status, contents
FROM dba_tablespaces
WHERE tablespace_name = 'APP_DATA';

SELECT tablespace_name, file_name,
       ROUND(bytes / 1024 / 1024, 2) AS size_mb,
       autoextensible,
       ROUND(maxbytes / 1024 / 1024, 2) AS max_size_mb
FROM dba_data_files
WHERE tablespace_name = 'APP_DATA';
