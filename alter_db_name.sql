SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'sandbox'
  AND pid <> pg_backend_pid(); -- Don't kill this current connection

-- 2. Rename it
ALTER DATABASE sadbox RENAME TO foresty_research;