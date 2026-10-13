-- Read-only database health checks.
-- Some queries require appropriate catalog privileges.

SET PAGESIZE 100
SET LINESIZE 180

PROMPT === DATABASE / INSTANCE ===
SELECT name, open_mode, database_role
FROM v$database;

SELECT instance_name, status, database_status
FROM v$instance;

PROMPT === INVALID OBJECTS ===
SELECT owner, object_type, COUNT(*) AS invalid_count
FROM dba_objects
WHERE status = 'INVALID'
GROUP BY owner, object_type
ORDER BY invalid_count DESC;

PROMPT === NON-IDLE SESSION COUNTS ===
SELECT username, status, COUNT(*) AS session_count
FROM v$session
WHERE type = 'USER'
GROUP BY username, status
ORDER BY session_count DESC;

PROMPT === BLOCKING SESSIONS ===
SELECT sid, serial#, username, blocking_session,
       event, seconds_in_wait
FROM v$session
WHERE blocking_session IS NOT NULL
ORDER BY seconds_in_wait DESC;
