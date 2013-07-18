#!/bin/sh

LOG_DATE=`date '+%Y-%m-%d'`
LOG_TIME=`date '+%H:%M:%S'`
echo "START ${LOG_DATE} ${LOG_TIME}";

/var/www/vhosts/goo.to/etc/getdata/toto/gettoto.pl

LOG_DATE=`date '+%Y-%m-%d'`
LOG_TIME=`date '+%H:%M:%S'`
echo "END getloto6 ${LOG_DATE} ${LOG_TIME}";

