#!/usr/bin/sh

SITE=~/projects/site/htdocs
CRONFILE=~projects/site/cgi-bin/sitegen/utils/tmp/cron.txt
GIT=~projects/site/cgi-bin/sitegen/utils/tmp/git.txt

if [ -f "$CRONFILE" ]; then

rm $SITE/*.html

mv $CRONFILE pages/cron.txt
cd pages

wget --no-check-certificate --input-file cron.txt

mv -vf *.html $SITE
rm cron.txt

echo "Updated"
fi

if [ -f "$GIT" ]; then
git pull
rm $GIT

echo "Pull request"
fi
