# Clickhouse set up tutorial

## What is Clickhouse

ClickHouse is an open-source high-performance, SQL database for online and analytical processing (OLAP). Online analytical processing tools allow businesses to store, analyse and query large datasets.

This snippet contains code samples and commands with no explanations. For a more detailed write-up of how to set up a ClickHouse server, refer to [my article here](https://vuyisile.com/setting-up-a-clickhouse-database/).

## Installation

Install ClickHouse using the [supplied docker-compose.yml file](./docker-compose.yml). Run
`docker compose up -d` to run it.

The container exposes port 8123 for the HTTP interface⁠ and port 9000 for the native client⁠.
ClickHouse stores configuration files in XML files. Sample user configuration files are included in the [config](./config/) directory.

## Connecting to ClickHouse

### Using the Native Client

```shell
clickhouse-client --host <HOSTNAME> \
                  --secure \
                  --port 9440 \
                  --user <USERNAME> \
                  --password <PASSWORD>
```

### Connect using Docker

```shell
docker exec -it clickhouse_container clickhouse-client --user <user> --password <password>
```

## Creating Users

1. Enable SQL-driven access management for the admin user by setting the following configuration options

```xml
<clickhouse>
    <users>
        <default>
	        <access_management>1</access_management>
            <named_collection_control>1</named_collection_control>
            <show_named_collections>1</show_named_collections>
            <show_named_collections_secrets>1</show_named_collections_secrets>
        </default>
    </users>
</clickhouse>
```

1. Create user account

```sql
CREATE USER admin_user IDENTIFIED WITH bcrypt_password BY '<your-secure-password-here';
```

1. Grant Full privileges

```sql
GRANT ALL ON *.* TO admin_user WITH GRANT OPTION;
```
