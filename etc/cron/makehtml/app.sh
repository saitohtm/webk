#!/bin/sh

LOG_DATE=`date '+%Y-%m-%d'`
LOG_TIME=`date '+%H:%M:%S'`
echo "START ${LOG_DATE} ${LOG_TIME}";

/var/www/vhosts/goo.to/etc/makehtml/app/app_html_iphone.pl
echo "app_html_iphone";

LOG_DATE=`date '+%Y-%m-%d'`
LOG_TIME=`date '+%H:%M:%S'`
echo "END app_html_iphone ${LOG_DATE} ${LOG_TIME}";

/var/www/vhosts/goo.to/etc/makehtml/app/app_html_android.pl
echo "app_html_android";

LOG_DATE=`date '+%Y-%m-%d'`
LOG_TIME=`date '+%H:%M:%S'`
echo "END app_html_android ${LOG_DATE} ${LOG_TIME}";


/var/www/vhosts/goo.to/etc/makehtml/app/app_html_smf_iphone.pl
echo "app_html_smf_iphone";

LOG_DATE=`date '+%Y-%m-%d'`
LOG_TIME=`date '+%H:%M:%S'`
echo "END app_html_smf_iphone ${LOG_DATE} ${LOG_TIME}";


/var/www/vhosts/goo.to/etc/makehtml/app/app_html_smf_android.pl
echo "app_html_smf_android";

LOG_DATE=`date '+%Y-%m-%d'`
LOG_TIME=`date '+%H:%M:%S'`
echo "END app_html_smf_android ${LOG_DATE} ${LOG_TIME}";
date

/var/www/vhosts/goo.to/etc/makehtml/app/app_html_iphone.pl top
echo "app_html_iphone";

LOG_DATE=`date '+%Y-%m-%d'`
LOG_TIME=`date '+%H:%M:%S'`
echo "END app_html_iphone ${LOG_DATE} ${LOG_TIME}";

