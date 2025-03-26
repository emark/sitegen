#!/usr/bin/bash

TITLE='Site Update tools'
VERSION=0.03

date "+%D %T"
echo -e "$TITLE, v$VERSION\nExample: sudo -u www-data ./siteup.sh [WORKDIR]"

if [ $1 ]; then
	WORKDIR=$1
	cd $WORKDIR
fi

source site.env

echo "Attemp to open file: $CRONFILE"

if [ -f "$CRONFILE" ]; then

	if [ $DB_DUMP == 1 ]; then
		echo "Start to dump database: $DB_DATA"
		sqlite3 $DATABASE .dump > $DB_DATA
	fi

	if [ $GIT_PULL == 1 ]; then
		echo "Get updates from git repository"
		git pull 
	fi

	rm $HTML_STATIC/*.html

	cd tmp
	wget --no-check-certificate --input-file cron.txt --base=$SITE_URL
	cd ../

	mv -vf tmp/*.html $HTML_STATIC
	rm $CRONFILE

	echo "Updated"
else

	echo "File didn't exists!"
fi

