#!/usr/bin/bash

TITLE='Configuration setup'
VERSION=0.02
DESCRIPTION='Creatng defaults configuration files'

echo -e $TITLE"\n"$DESCRIPTION "v"$VERSION

function setconf() {

if [ ! -f $conf ]; then
	echo "Create configuration file [$conf]"
	echo -e $var > $conf
else
	echo "Configuration file [$conf] exists"
fi
}

conf='site.env'
var="SITE_NAME=sitegen\nSITE_URL=http://sitegen/\nHTML_STATIC=../public/\nCRONFILE=cron.txt\nDATABASE=../db/sitegen.sql\nDB_DATA=./dump/dump.sql\nDB_DUMP=0\nGIT_PULL=0"
setconf

conf='../sitegen.conf'
var="{\n\tdsn => [dbi:SQLite:dbname=../db/sitegen.sql],\n\tdbuser => [dbuser],\n\tdbpassword => [dbuser],\n\tprefix => [site_],\n\tsitename => [sitegen],\n\tmode => [production],\n\tsecrets => [somesecretword],\n\t\
login => [login],\n\tpass => [pass],\n\tdownloads => [../public/downloads/],\n\tupdate => [../utils/tmp/cron.txt],\n\tstatic => [../public/],\n\tstatic_extension => [.html],\n\t\
url => [http://sitegen]\n\tlog_upd => [../utils/cron.log]\n}"
setconf

source site.env
conf='../db/schema.sql'
var="CREATE TABLE site_$SITE_NAME (url text, meta text, content text);"
setconf

conf='../.crontab'
var="#$TITLE\n#$DESCRIPTION\n% bash $PWD/siteup.sh $PWD > $PWD/cron.log\n"
setconf
sed -i "s/%/* * * * */g" $conf
