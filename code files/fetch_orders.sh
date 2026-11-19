#!/bin/bash
# fetch_orders.sh
# Fetches the latest order records from MySQL and appends them to a report file.
# Every execution (success or failure) is logged with its date and time.

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
DB_CONFIG="$BASE_DIR/db.cnf"
DB_NAME="company_db"
REPORT_FILE="$BASE_DIR/orders_report.txt"
LOG_FILE="$BASE_DIR/cron_execution.log"

MAX_RETRIES=3
RETRY_DELAY=10

QUERY="SELECT order_id, customer_name, product, amount, order_time FROM orders ORDER BY order_time DESC LIMIT 10;"

now() { date '+%Y-%m-%d %H:%M:%S'; }

echo "[$(now)] Job started" >> "$LOG_FILE"

attempt=1
while [ "$attempt" -le "$MAX_RETRIES" ]; do
    OUTPUT=$(mysql --defaults-extra-file="$DB_CONFIG" --table "$DB_NAME" -e "$QUERY" 2>&1)
    STATUS=$?

    if [ "$STATUS" -eq 0 ]; then
        {
            echo "=============================================="
            echo " Report generated: $(now)"
            echo "=============================================="
            echo "$OUTPUT"
            echo ""
        } >> "$REPORT_FILE"
        echo "[$(now)] SUCCESS: latest orders saved to $REPORT_FILE (attempt $attempt)" >> "$LOG_FILE"
        exit 0
    fi

    echo "[$(now)] WARNING: attempt $attempt/$MAX_RETRIES failed: $OUTPUT" >> "$LOG_FILE"
    if [ "$attempt" -lt "$MAX_RETRIES" ]; then
        sleep "$RETRY_DELAY"
    fi
    attempt=$((attempt + 1))
done

echo "[$(now)] ERROR: database unavailable after $MAX_RETRIES attempts. No report written." >> "$LOG_FILE"
exit 1
