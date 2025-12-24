SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'sandbox'
  AND pid <> pg_backend_pid();


ALTER DATABASE sandbox RENAME TO foresty_research;