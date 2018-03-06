Backupper MySQL
---------------
This script is designed to create MySQL database backups.

The script automatically finds all databases, so you don't have to add new, unless you have some exceptions. You can also transfer the key to back up only certain databases.

----------

**The script contains the following settings:**

Connection settings:

    DBUSER="root"
    DBPASS=""
    DBHOST=""

Archives retention period:

    DAYS_STORE=20

Directory for save archive:

    BACKUP_DIR="backups"

A list of excluded databases (database is a part of SHOW DATABASES output):

    EXCLUDES_DB=(
     'example_db'
     'example_db2'
    )
    
An array of excluded tables (requires BASH v. 4 >=). 
The structure of the excluded tables will be saved in the backup file:

    EXCLUDED_TABLES[example_db]="example_table example_table2"
    
Parameter for change the store time (days) "-t":

    $ ./run.sh -t 10

If you do not want the script to back up the new bases, then upon running, specify that you want to back up, using the "-b" parameter:

    $ ./run.sh -b "example_db example_db2"
    
Or as parameter "-e":

    $ ./run.sh -e "example_db.example_table example_db.example_table2"
    
If you want add custom parameters, use the parameter "-p":

    $ ./run.sh -p "--hex-blob"
    
Example for cron. Backup all databases:

    0 * * * * backupper_mysql/run.sh >/dev/null 2>&1
    
![](https://raw.githubusercontent.com/wdda/backupper_mysql/master/example.gif)