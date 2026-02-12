#!/bin/bash

LOG_FILE="/home/jlamere/ansible-supabase/sync_db.log"
ENV_FILE="/home/jlamere/ansible-supabase/env/.env"
TEMP_DUMP="/tmp/public.dump"

# Function to log messages with timestamps
log_with_timestamp() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $1" | tee -a "$LOG_FILE"
}

# Load environment variables from the env file
if [ -f "$ENV_FILE" ]; then
  export $(grep -v '^#' "$ENV_FILE" | xargs)
else
  log_with_timestamp "[ERROR] Environment file not found at $ENV_FILE."
  exit 1
fi

# Ensure the source database URL is set
if [ -z "$SRC_DB_URL" ]; then
  log_with_timestamp "[ERROR] SRC_DB_URL environment variable is not set."
  log_with_timestamp "Please set it in the environment file: $ENV_FILE"
  exit 1
fi

# Ensure the source database password is set
if [ -z "$SRC_DB_PASSWORD" ]; then
  log_with_timestamp "[ERROR] SRC_DB_PASSWORD environment variable is not set."
  log_with_timestamp "Please set it in the environment file: $ENV_FILE"
  exit 1
fi

# Log the start of the process
log_with_timestamp "[INFO] Starting database sync process..."

# Drop the public schema if it exists
log_with_timestamp "[INFO] Dropping the public schema if it exists..."
sudo docker exec -i supabase-db psql -U postgres -d postgres -c "DROP SCHEMA IF EXISTS public CASCADE;" >> "$LOG_FILE" 2>&1

# Dump the public schema from the source database
log_with_timestamp "[INFO] Dumping the public schema from the source database..."
sudo docker exec -e PGPASSWORD="$SRC_DB_PASSWORD" -i supabase-db \
  pg_dump --schema=public --no-owner --no-privileges --format=custom "$SRC_DB_URL" > "$TEMP_DUMP" 2>> "$LOG_FILE"

# Restore the public schema to the local database
log_with_timestamp "[INFO] Restoring the public schema to the local database..."
sudo docker exec -i supabase-db \
  pg_restore --clean --if-exists --no-owner --no-privileges -U postgres -d postgres < "$TEMP_DUMP" >> "$LOG_FILE" 2>&1

# Cleanup temporary files
log_with_timestamp "[INFO] Cleaning up temporary files..."
rm -f "$TEMP_DUMP"

# Log the completion of the process
log_with_timestamp "[INFO] Database sync process completed successfully."