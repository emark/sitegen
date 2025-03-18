#!/usr/bin/bash

TITLE='Configuration setup'
VERSION=0.02
DESCRIPTION='Create defaults configuration files'

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
var="SITENAME=sitegen\nSITE_URL=http://sitegen/\nHTML=\nCRONFILE=\nDB_CONNECT=\nDB_DATA=\nDB_DUMP=\nGIT_PULL="
setconf

conf='../sitegen.conf'
var="{\n\tdsn => ,\n\tdbuser => ,\n\tdbpassword => ,\n\tprefix => ,\n\tsitename => ,\n\tmode => ,\n\tsecrets => ,\n\t\
login => ,\n\tpass => ,\n\tdownloads => ,\n\tupdate => ,\n\tgit => ,\n\tstatic => ,\n\tstatic_extension => ,\n\t\
url => \n}"
setconf

source site.env
conf='../db/schema.sql'
var="CREATE TABLE site_$SITENAME (url text, meta text, content text);"
setconf

conf='../.crontab'
var="#$TITLE\n#$DESCRIPTION\n% bash $PWD/siteup.sh $PWD > $PWD/cron.log"
setconf
sed -i "s/%/* * * * */g" $conf
