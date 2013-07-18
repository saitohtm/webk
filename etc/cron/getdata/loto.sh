#!/bin/sh

LOG_DATE=`date '+%Y-%m-%d'`
LOG_TIME=`date '+%H:%M:%S'`
echo "START ${LOG_DATE} ${LOG_TIME}";

/var/www/vhosts/goo.to/etc/getdata/loto/getloto6.pl

LOG_DATE=`date '+%Y-%m-%d'`
LOG_TIME=`date '+%H:%M:%S'`
echo "END getloto6 ${LOG_DATE} ${LOG_TIME}";

/var/www/vhosts/goo.to/etc/getdata/loto/getloto7.pl

LOG_DATE=`date '+%Y-%m-%d'`
LOG_TIME=`date '+%H:%M:%S'`
echo "END getloto7 ${LOG_DATE} ${LOG_TIME}";

/var/www/vhosts/goo.to/etc/getdata/loto/getmililoto.pl

LOG_DATE=`date '+%Y-%m-%d'`
LOG_TIME=`date '+%H:%M:%S'`
echo "END getmililoto ${LOG_DATE} ${LOG_TIME}";

/var/www/vhosts/goo.to/etc/getdata/loto/gettakarakuji.pl

LOG_DATE=`date '+%Y-%m-%d'`
LOG_TIME=`date '+%H:%M:%S'`
echo "END gettakarakuji ${LOG_DATE} ${LOG_TIME}";

