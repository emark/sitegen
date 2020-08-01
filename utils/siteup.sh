#!/usr/bin/sh

cd ~/projects/site/cgi-bin/sitegen/utils/

SITE=~/projects/site/htdocs
CRONFILE=tmp/cron.txt
GIT=tmp/git.txt

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
