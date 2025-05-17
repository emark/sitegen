#!/usr/bin/bash

TITLE='Sitegen configuration setup'
VERSION=0.02
DESCRIPTION='Create default configuration files'

echo -e $TITLE"\n"$DESCRIPTION "v"$VERSION

function setconf() {

if [ ! -f $conf ]; then
	echo -n "Create configuration file [$conf] ... "
	echo -e $var > $conf
	echo "Ok"
else
	echo "Configuration file [$conf] is exists"
fi
}

conf='site.env'
var="SITE_NAME=sitegen\nSITE_URL=http://localhost\nSITE_PORT=3000\nHTML_STATIC=../public\nCRONFILE=./tmp/cron.txt\nDATABASE=../db/sitegen.sql\nDB_DATA=./dump/dump.sql\nDB_DUMP=0\nGIT_PULL=0"
setconf

conf='../sitegen.conf'
var="{\n\tdsn => \"dbi:SQLite:dbname=../db/sitegen.sql\",\n\tdbuser => \"dbuser\",\n\tdbpassword => \"dbpass\",\n\tprefix => \"site_\",\n\tsitename => \"sitegen\",\n\tmode => \"development\",\n\tsecrets => \"somesecretword\",\n\tlogin => \"admin\",\n\tpass => \"sitegen\",\n\tdownloads => \"../public/downloads/\",\n\tupdate => \"../utils/tmp/cron.txt\",\n\tstatic => \"../public/\",\n\tstatic_extension => \".html\",\n\turl => \"http://localhost\",\n\tlog_upd => \"../utils/cron.log\"\n}"
setconf

source site.env
conf='../db/schema.sql'
var="CREATE TABLE site_$SITE_NAME (url text, meta text, content text);"
setconf

conf='../.crontab'
var="#$TITLE\n#$DESCRIPTION\n% bash $PWD/siteup.sh $PWD > $PWD/cron.log\n"
setconf
sed -i "s/%/* * * * */g" $conf
