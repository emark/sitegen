#!/usr/bin/sh

SITE=~/projects/site/htdocs
CRONFILE=~/projects/site/cgi-bin/sitegen/utils/tmp/cron.txt

if [ -f "$CRONFILE" ]; then

rm $SITE/*.html

cd pages
mv $CRONFILE cron.txt

wget --no-check-certificate --input-file cron.txt

mv -vf *.html $SITE
rm cron.txt

echo "Updated"
fi
