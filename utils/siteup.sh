#!/usr/bin/sh

cd ~/projects/site/cgi-bin/sitegen/utils/

SITE=~/projects/site/htdocs
CRONFILE=tmp/cron.txt

if [ -f "$CRONFILE" ]; then
git pull

rm $SITE/*.html

mv $CRONFILE pages/cron.txt
cd pages

wget --no-check-certificate --input-file cron.txt

mv -vf *.html $SITE
rm cron.txt

echo "Updated"
fi


