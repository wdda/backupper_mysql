Backupper MySQL
---------------
This script is designed to create MySQL database backups.

The script automatically finds all databases, so you don't have to add new, unless you have some exceptions. You can also transfer the key to back up only certain databases.

----------

**The script contains the following settings:**

Connection settings

    DBUSER="root"
    DBPASS=""
    DBHOST=""

Archives retention period

    DAYS_STORE=20

A list of excluded databases (database is a part of SHOW DATABASES output)

    EXCLUDES_DB=(
     'example_db'
     'example_db2'
    )

An array of excluded tables (requires BASH v. 4 >=). 
The structure of the excluded tables will be saved in the backup file.

    EXCLUDED_TABLES[example_db]="example_table example_table2"

If you do not want the script to back up the new bases, then upon running, specify that you want to back up, using the "-db" key.

Example:  $ ./run.sh -db "example_db example_db2"