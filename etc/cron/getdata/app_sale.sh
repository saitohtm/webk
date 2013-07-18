#!/bin/sh

LOG_DATE=`date '+%Y-%m-%d'`
LOG_TIME=`date '+%H:%M:%S'`
echo "START ${LOG_DATE} ${LOG_TIME}";


/var/www/vhosts/goo.to/etc/getdata/app/getapp_iphone_sale.pl

LOG_DATE=`date '+%Y-%m-%d'`
LOG_TIME=`date '+%H:%M:%S'`
echo "getapp_sale ${LOG_DATE} ${LOG_TIME}";


/var/www/vhosts/goo.to/etc/getdata/app/getapp_android_sale.pl

LOG_DATE=`date '+%Y-%m-%d'`
LOG_TIME=`date '+%H:%M:%S'`
echo "getapp_sale_android ${LOG_DATE} ${LOG_TIME}";


/var/www/vhosts/goo.to/etc/getdata/app/getapp_android_sale.pl octoba

LOG_DATE=`date '+%Y-%m-%d'`
LOG_TIME=`date '+%H:%M:%S'`
echo "getapp_sale_android ${LOG_DATE} ${LOG_TIME}";

date
