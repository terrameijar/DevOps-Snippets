# WordPress Backup Script

A Wordpress backup script that backs up a WordPress database and public html directory to a local directory as well as to an AWS S3 bucket on a schedule. Work in progress. I plan to add the ability to send notifications via email or AWS SNS if the backup fails.

## Requirements

1. AWS [credentials configured](https://docs.aws.amazon.com/cli/v1/userguide/cli-chap-configure.html#configure-precedence) on the server
1. MySQL credentials saved to a [MYSQL option file](https://dev.mysql.com/doc/refman/8.4/en/option-files.html)
1. An existing Existing AWS S3 bucket you have write-access to.

## Steps

1. Configure AWS and MySQL credentials
1. Create an AWS S3 bucket
1. Modify the `Resource` value in [this IAM policy](./iam_policy.json). Replace the value with the name of your S3 bucket. [Add the IAM policy](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_manage-attach-detach.html) to your AWS user account to allow it to upload files to the S3 bucket.
1. Populate the following variables in the `wp_backup.sh` script:

### Environment Variables

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

## Running the script

To run the script:

```shell
# Make the script executable
chmod +x wp_backup.sh
./wp_backup.sh
```
