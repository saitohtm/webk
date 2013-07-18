#!/bin/sh

LOG_DATE=`date '+%Y-%m-%d'`
LOG_TIME=`date '+%H:%M:%S'`
echo "START ${LOG_DATE} ${LOG_TIME}";

/var/www/vhosts/goo.to/etc/makehtml/facebook/make_html.pl
echo "make_html";

LOG_DATE=`date '+%Y-%m-%d'`
LOG_TIME=`date '+%H:%M:%S'`
echo "END ${LOG_DATE} ${LOG_TIME}";
