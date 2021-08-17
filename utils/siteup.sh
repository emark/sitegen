#!/usr/bin/sh

cd ~/projects/site/cgi-bin/sitegen/utils/

SITE=~/projects/site/htdocs
CRONFILE=tmp/cron.txt
DB_CONNECT=$(cat db.conf)

if [ -f "$CRONFILE" ]; then

#Dump database
mysqldump $DB_CONNECT --result-file=dump/dump.sql 

git pull

rm $SITE/*.html

cd tmp

wget --no-check-certificate --input-file cron.txt

mv -vf *.html $SITE
rm cron.txt

echo "Updated"
fi
