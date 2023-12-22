# PostgreSQL Replication

## Setup a primary postgres server

- setup data volumes for each server
- setup unique config files for each instance
- create and run docker containers in the same network

### Steps

- Create a new docker network to allow instances to talk with each other

```shell
docker network create postgres
```

Start primary instance

```shell
cd storage/databases/postgresql/replication

docker run -it --rm --name postgres-primary \
--network postgres \
-e POSTGRES_USER=postgresadmin \
-e POSTGRES_PASSWORD=admin123 \
-e POSTGRES_DB=postgresdb \
-e PGDATA="/data" \
-v $PWD/postgres-primary/pgdata:/data \
-v $PWD/postgres-primary/config:/config \
-v $PWD/postgres-primary/archive:/mnt/server/archive \
-p 5000:5432 \
postgres:15 -c 'config_file=/config/postgresql.conf'

```

## Configuration

```conf
ata_directory = '/data'
hba_file = '/config/pg_hba.conf'
ident_file = '/config/pg_ident.conf'

port = 5432
listen_addresses = '*'
max_connections = 100
shared_buffers = 128MB
dynamic_shared_memory_type = posix
max_wal_size = 1GB
min_wal_size = 80MB
log_timezone = 'Etc/UTC'
datestyle = 'iso, mdy'
timezone = 'Etc/UTC'

# Locale settings
lc_messages = 'en_US.utf8'			# locale for system error message
lc_monetary = 'en_US.utf8'			# locale for monetary formatting
lc_numeric = 'en_US.utf8'			# locale for number formatting
lc_time = 'en_US.utf8'				# locale for time formatting

default_text_search_config = 'pg_catalog.english'

# Replication
wal_level = replica  # allows connection from replication or standby servers
archive_mode = on 
archive_command = 'test ! -f /mnt/server/archive/%f && cp %p /mnt/server/archive/%f'
max_wal_senders = 3 
```

## Create a Replication User

Create a new user account with replication permission to take backups of the database.
Login to `postgres-primary`:

```shell
docker exec -it postgres-primary bash

# Create a new user
createuser -U postgresadmin -P -c 5 --replication replicationUser

exit
```

## Enable Write-Ahead Log (WAL) and Replication

WAL -> Mechanism of writing transaction logs to a file. Postgres does not accept the transaction until it has been written to the transaction log and saved to disk. If there is ever a system crash, the database can be recovered from the transaction log. "Writing Ahead"

```shell
wal_level = replica
max_wal_senders = 3
```



## Enable Archiving

https://www.postgresql.org/docs/current/runtime-config-wal.html#GUC-ARCHIVE-MODE

```shell
archive_mode = on
archive_command = 'test ! -f /mnt/server/archive/%f && cp %p /mnt/server/archive/%f
```

## Take a base backup

Use `pg_backup` utility. The utility is in the docker postgresql image so we can run it without running a db by changing the entrypoint.
Mount out blank data directory as we will make a new backup in there.

```shell
cd storage/databases/postgresql/replication

docker run -it --rm \
--network postgres \
-v ${PWD}/postgres-2/pgdata:/data \
--entrypoint /bin/bash postgres:15

```

Take the backup by logging into `postgres-primary` with `replicationUser` and writing the backup to `/data`

```shell
pg_basebackup -h postgres-primary -p 5432 -U replicationUser -D /data/ -Fp -Xs -R
```

## Start Standby Instance

```shell
cd storage/databases/postgresql/replication

docker run -it --rm --name postgres-2 \
--net postgres \
-e POSTGRES_USER=postgresadmin \
-e POSTGRES_PASSWORD=admin123 \
-e POSTGRES_DB=postgresdb \
-e PGDATA="/data" \
-v ${PWD}/postgres-2/pgdata:/data \
-v ${PWD}/postgres-2/config:/config \
-v ${PWD}/postgres-2/archive:/archive \
-p 5001:5432 \
postgres:15 -c 'config_file=/config/postgresql.conf'
```

## Test the replication

Test the replication by creating a new table in `postgres-primary`, the primary instance

```shell
# Login to postgres
psql --username=postgresadmin postgresdb

# Create table
CREATE TABLE customers (firstname text, customer_id serial, date_created timestamp);

# Show the table
\dt
```

Login to `postgres-2` secondary and view the table:

```shell
docker exec -it postgres-2 bash

# Login to postgres
psql --username=postgresadmin postgresdb

# Show the tables
\dt
```

## Failover

Postgres does not have built-in automatic failover, it requires 3rd party tooling to achieve.
So If `postgres-primary` fails we use a utility called `pg_ctl` to promote the standby server to a primary server.
Next build a new stand by server
Configure replication on the new primary


Let's stop the primary server to simulate failure:

```shell

docker rm -f postgres-primary

Then log into postgres-2 and promote it to primary:

docker exec -it postgres-2 bash

# confirm we cannot create a table as its a stand-by server
CREATE TABLE customers (firstname text, customer_id serial, date_created timestamp);

# run pg_ctl as postgres user (cannot be run as root!)
runuser -u postgres -- pg_ctl promote

# confirm we can create a table as its a primary server
CREATE TABLE customers (firstname text, customer_id serial, date_created timestamp);

```
