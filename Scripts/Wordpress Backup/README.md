# WordPress Backup Script

A Wordpress backup script that backs up the WordPress database and and public html directory to a local directory and an AWS S3 bucket on a schedule. Sends notifications via email or AWS SNS if the backup fails.

## Environment Variables

Populate the following variables to configure backup options:

```shell
WP_DB_NAME=""
WP_HOSTNAME="" # e.g localhost
MYSQL_OPTS_FILE=""
WP_BACKUP_LOCATION=""
WP_BACKUP_FILE="$WP_BACKUP_LOCATION/${WP_DB_NAME}_backup_$DATE.sql.gz"
WP_ROOT_DIR_BACKUP_FILE="$WP_BACKUP_LOCATION/public_html_backup_$DATE.tar.gz"
WP_DATA_DIR="" # e.g /home/wordpress/public_html

S3_BUCKET="" # e.g S3 Bucket name e.g `wordpress-backups`
```

- `WP_DB_NAME` - The name of the WordPress database you want to back up
- `WP_HOSTNAME` - WordPress Hostname
- `MYSQL_OPTS_FILE` - Path to file containing MySQL credentials
- `WP_BACKUP_LOCATION` - Local path where the Wordpress Database backup should be saved
- `WP_BACKUP_FILE` - WordPress backup file name
- `WP_DATA_DIR` - Path to the WordPress public html directory
- `WP_ROOT_DIR_BACKUP_FILE` - Local path where the WordPress Public Html backup should be saved
- `S3_BUCKET` - AWS S3 bucket to save the backup to
