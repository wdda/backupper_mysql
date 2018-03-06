#!/bin/bash

# Backupper MySQL
# Author Alferov D. WDDA
# https://github.com/wdda/backupper_mysql

# Connection settings
DBUSER="root"
DBPASS=""
DBHOST=""

# Archives retention period
DAYS_STORE=20

# A list of excluded databases (database is a part of SHOW DATABASES output)
EXCLUDES_DB=(
    'Database'
    'information_schema'
    'mysql'
    'performance_schema'
    'phpmyadmin'
    'sys'
)

# An array of excluded tables (requires BASH v. 4 >=).
# The structure of the excluded tables will be saved in the backup file.
#
# if you want to exclude tables uncomment the lines
#
# declare -A EXCLUDED_TABLES
# EXCLUDED_TABLES[example_db]="example_table,example_table2"

DATE=`date +%Y-%M-%d`
YEAR=`date +%Y`
MONTH=`date +%m`
DAY=`date +%d`
HOURS=`date +%H`
MINUTES=`date +%M`

BASEDIR=`dirname $0`
PROJECT_PATH=`cd $BASEDIR; pwd`
cd $PROJECT_PATH

DATA_BASE_FROM_KEY=0
EXCLUDES_TABLE_FROM_KEY=0
PARAMETERS=""

while getopts ":b:e:p:h" opt; do
    case $opt in
        b)
            DATA_BASE_FROM_KEY="$OPTARG"
            ;;
        e)
            EXCLUDES_TABLE_FROM_KEY="$OPTARG"
            ;;
        p)
            PARAMETERS="$OPTARG"
            ;;
        t)  DAYS_STORE="$OPTARG"
            ;;
        h)
            echo "-b Data bases for backup. Default all. Example: run.sh -b \"example_db example_db2\""
            echo "-e For ignore table. Example: run.sh -e \"data_base.table data_base2.table2\""
            echo "-p Custom parameters. Example: run.sh -p \"--hex-blob\""
            echo "-t Storage time (days). Example: run.sh -t 3"
            exit
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            ;;
    esac
done

DIR="tmp"
if [ ! -d "$DIR" ]; then
    mkdir "$DIR"
fi

# Create backup dir
BACKUP_DIR="backups"

if [ ! -d "$BACKUP_DIR" ]; then
    mkdir "$BACKUP_DIR"
fi

if [ "" != "$DBPASS" ] ; then
    DBPASS="-p$DBPASS"
fi

# Create list of databases
mysql -u $DBUSER $DBPASS -e "show databases;" > tmp/databases.list

if [ "$DATA_BASE_FROM_KEY" == 0 ] ; then
    LIST_DB=`cat tmp/databases.list`
else
    LIST_DB="$DATA_BASE_FROM_KEY"
fi

# Now we can backup current database
cd $BACKUP_DIR

for database in $LIST_DB
do
    skip=0
    let count=0
    while [ $count -lt ${#EXCLUDES_DB[@]} ] ; do
        # check if this name in excludes list
        if [ "$database" = ${EXCLUDES_DB[$count]} ] ; then
            let skip=1
            break
        fi

        let count=$count+1
    done

    if [ $skip -eq 0 ] ; then

        IGNORED_TABLES_STRING=''
        for i in "${!EXCLUDED_TABLES[@]}"
        do
            if [ "$i" = "$database" ] ; then
                 EXCLUDED_TABLE=(${EXCLUDED_TABLES[$i]//,/ })
                for b in "${EXCLUDED_TABLE[@]}"
                do
                     IGNORED_TABLES_STRING+=" --ignore-table="${database}"."${b}
                done
            fi
        done

        if [ "$EXCLUDES_TABLE_FROM_KEY" != 0 ] ; then
            for ignore_table in $EXCLUDES_TABLE_FROM_KEY
            do
                IGNORED_TABLES_STRING+=" --ignore-table="${ignore_table}
            done
        fi


        echo ""
        echo "*---- start backup  $database"

        backup_name="$YEAR-$MONTH-$DAY.$HOURS-$MINUTES.$database.backup.sql"
        backup_tarball_name="$backup_name.tar.gz"

        `/usr/bin/mysqldump -h "$DBHOST" --databases --single-transaction --no-data "$database" -u "$DBUSER" ${DBPASS} ${IGNORED_TABLES_STRING} > "$backup_name"`
        echo "**--- add structure $backup_name"

        `/usr/bin/mysqldump -h "$DBHOST" --databases "$database" -u "$DBUSER" ${DBPASS} ${IGNORED_TABLES_STRING} >> "$backup_name"`
        echo "***-- add data      $backup_name"

        `/bin/tar -zcf "$backup_tarball_name" "$backup_name"`
        echo "****- compress      $backup_tarball_name"

        `/bin/rm "$backup_name"`
        echo "***** cleanup       $backup_name"
    fi
done

echo "Delete old backups"

find *.sql.tar.gz -maxdepth 1 -mtime +$DAYS_STORE -type f -delete
echo "Done!"
