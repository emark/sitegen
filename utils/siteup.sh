#!/usr/bin/bash

date "+%D %T"
echo -e "Run script siteup.sh\nExample: sudo -u www-data ./siteup.sh"

cd $PWD 

source site.env

echo "Attemp to open $CRONFILE"
if [ -f "$CRONFILE" ]; then

if [ $DB_DUMP == 1 ]; then
	mysqldump $DB_CONNECT --result-file=$DB_DATA
fi

if [ $GIT_PULL == 1 ]; then
	git pull 
fi

rm $HTML/*.html

cd tmp
wget --no-check-certificate --input-file cron.txt --base=$SITE_URL
cd ../

mv -vf tmp/*.html $HTML
rm $CRONFILE

echo "Updated"
fi
