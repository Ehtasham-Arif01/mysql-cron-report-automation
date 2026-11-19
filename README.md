# Cron Job: Automated MySQL Orders Report

DevOps assignment (**23P-0567**). A Bash script, run by `cron`, fetches the latest orders from a MySQL database and appends them to a report file. Every run is logged with a timestamp. If the database is down, the script retries before giving up.

## Repository Structure

```
.
├── Cron_Job_Report.pdf        # Full write-up with screenshots
└── code files/
    ├── fetch_orders.sh        # Main script run by cron
    ├── setup_db.sql           # Creates DB, orders table, sample data, read-only user
    ├── db.cnf                 # MySQL client credentials (used via --defaults-extra-file)
    ├── orders_report.txt      # Sample output: appended reports
    └── cron_execution.log     # Sample output: execution log (incl. a failure + retries)
```

## How It Works

1. `fetch_orders.sh` runs a query for the 10 most recent orders, ordered by `order_time`.
2. On success it appends a timestamped table to `orders_report.txt`.
3. On failure it retries up to **3 times**, waiting **10 s** between attempts.
4. Each start, success, warning and final error goes into `cron_execution.log`.
5. Credentials are read from `db.cnf`, so the password never appears on the command line or in the process list.

## Setup

```bash
# 1. Create the database, table, sample data and read-only user
sudo mysql < "code files/setup_db.sql"

# 2. Lock down the credentials file and make the script executable
chmod 600 "code files/db.cnf"
chmod +x  "code files/fetch_orders.sh"

# 3. Run it once by hand
"./code files/fetch_orders.sh"
```

## Scheduling with Cron

Open your crontab with `crontab -e` and add this line to run the job every minute:

```cron
* * * * * /full/path/to/code\ files/fetch_orders.sh
```

The script sets its own `PATH` and resolves every file relative to its own location, so it works under cron's minimal environment.

## Sample Log

```
[2026-11-07 20:20:52] Job started
[2026-11-07 20:20:52] WARNING: attempt 1/3 failed: ERROR 2002 (HY000): Can't connect to local MySQL server ...
[2026-11-07 20:21:02] WARNING: attempt 2/3 failed: ...
[2026-11-07 20:21:12] WARNING: attempt 3/3 failed: ...
[2026-11-07 20:21:12] ERROR: database unavailable after 3 attempts. No report written.
[2026-11-07 20:21:29] Job started
[2026-11-07 20:21:29] SUCCESS: latest orders saved to .../orders_report.txt (attempt 1)
```

## Note on Credentials

`db.cnf` holds demo credentials for a local, `SELECT`-only user created by `setup_db.sql`. Use your own credentials for anything real, and keep that file out of version control.
