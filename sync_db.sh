#!/bin/bash

LOG_FILE="/home/jlamere/ansible-supabase/sync_db.log"
ENV_FILE="/home/jlamere/ansible-supabase/env/.env"

# Load environment variables from the env file
if [ -f "$ENV_FILE" ]; then
  export $(grep -v '^#' "$ENV_FILE" | xargs)
else
  echo "[ERROR] Environment file not found at $ENV_FILE." | tee -a "$LOG_FILE"
  exit 1
fi

# Ensure the source database URL is set
if [ -z "$SRC_DB_URL" ]; then
  echo "[ERROR] SRC_DB_URL environment variable is not set." | tee -a "$LOG_FILE"
  echo "Please set it in the environment file: $ENV_FILE" | tee -a "$LOG_FILE"
  exit 1
fi

# Ensure the source database password is set
if [ -z "$SRC_DB_PASSWORD" ]; then
  echo "[ERROR] SRC_DB_PASSWORD environment variable is not set." | tee -a "$LOG_FILE"
  echo "Please set it in the environment file: $ENV_FILE" | tee -a "$LOG_FILE"
  exit 1
fi

# Log the start of the process
echo "[INFO] Starting database sync process..." >> "$LOG_FILE"

# Drop the public schema if it exists
echo "[INFO] Dropping the public schema if it exists..." >> "$LOG_FILE"
sudo docker exec -i supabase-db psql -U postgres -d postgres -c "DROP SCHEMA IF EXISTS public CASCADE;" >> "$LOG_FILE" 2>&1

# Dump the public schema from the source database
echo "[INFO] Dumping the public schema from the source database..." >> "$LOG_FILE"
sudo docker exec -e PGPASSWORD="$SRC_DB_PASSWORD" -i supabase-db \
  pg_dump --schema=public --no-owner --no-privileges --format=custom "$SRC_DB_URL" > /tmp/public.dump 2>> "$LOG_FILE"

# Restore the public schema to the local database
echo "[INFO] Restoring the public schema to the local database..." >> "$LOG_FILE"
sudo docker exec -i supabase-db \
  pg_restore --clean --if-exists --no-owner --no-privileges -U postgres -d postgres < /tmp/public.dump >> "$LOG_FILE" 2>&1

# Log the completion of the process
echo "[INFO] Database sync process completed successfully." >> "$LOG_FILE"