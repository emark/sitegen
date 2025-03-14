#!/usr/bin/bash
# Default site.env
# SITE_URL=""
# HTML=""
# CRONFILE=""
# DB_CONNECT=""
# DB_DATA=""
# DB_DUMP=0
# GIT_PULL=0

date "+%D %T"
echo -e "Run script siteup.sh\nExample: sudo -u www-data ./siteup.sh [WORKDIR]"


if [ $1 ]; then
	WORKDIR=$1
	cd $WORKDIR
fi



source site.env

echo "Attemp to open file: $CRONFILE"
if [ -f "$CRONFILE" ]; then

	if [ $DB_DUMP == 1 ]; then
		echo "Start to dump database: $DB_DATA"
		sqlite3 $DB_CONNECT .dump > $DB_DATA
	fi

	if [ $GIT_PULL == 1 ]; then
		echo "Get updates from git repository"
		git pull 
	fi

	rm $HTML/*.html

	cd tmp
	wget --no-check-certificate --input-file cron.txt --base=$SITE_URL
	cd ../

	mv -vf tmp/*.html $HTML
	rm $CRONFILE

	echo "Updated"
else
	echo "File didn't exists!"
fi

