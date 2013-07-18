#!/bin/sh

LOG_DATE=`date '+%Y-%m-%d'`
LOG_TIME=`date '+%H:%M:%S'`
echo "START ${LOG_DATE} ${LOG_TIME}";

# yahooデータ取得
/var/www/vhosts/goo.to/etc/getdata/yahoo/yahoonews.pl

LOG_DATE=`date '+%Y-%m-%d'`
LOG_TIME=`date '+%H:%M:%S'`
echo "END yahoonews ${LOG_DATE} ${LOG_TIME}";

# RSSデータ取得
/var/www/vhosts/goo.to/etc/getdata/car/rss_datas.pl

LOG_DATE=`date '+%Y-%m-%d'`
LOG_TIME=`date '+%H:%M:%S'`
echo "END get_f1_data.pl ${LOG_DATE} ${LOG_TIME}";

# RSSデータ取得
/var/www/vhosts/goo.to/etc/getdata/rss/rss_goo_datas.pl

LOG_DATE=`date '+%Y-%m-%d'`
LOG_TIME=`date '+%H:%M:%S'`
echo "END rss_goo_datas.pl ${LOG_DATE} ${LOG_TIME}";


# carデータ取得
/var/www/vhosts/goo.to/etc/getdata/car/get_car_photo.pl

LOG_DATE=`date '+%Y-%m-%d'`
LOG_TIME=`date '+%H:%M:%S'`
echo "END get_car_photo.pl ${LOG_DATE} ${LOG_TIME}";

# carデータ取得
/var/www/vhosts/goo.to/etc/getdata/keyword/keywordsearch.pl

LOG_DATE=`date '+%Y-%m-%d'`
LOG_TIME=`date '+%H:%M:%S'`
echo "END keywordsearch.pl ${LOG_DATE} ${LOG_TIME}";
