#!/bin/sh

LOG_DATE=`date '+%Y-%m-%d'`
LOG_TIME=`date '+%H:%M:%S'`
echo "START ${LOG_DATE} ${LOG_TIME}";

# totoデータ取得
/var/www/vhosts/goo.to/etc/getdata/toto/gettoto.pl

LOG_DATE=`date '+%Y-%m-%d'`
LOG_TIME=`date '+%H:%M:%S'`
echo "END gettoto ${LOG_DATE} ${LOG_TIME}";

# Y!NEWS取得
/var/www/vhosts/goo.to/etc/getdata/yahoo/yahoonews.pl

LOG_DATE=`date '+%Y-%m-%d'`
LOG_TIME=`date '+%H:%M:%S'`
echo "END yahoonews ${LOG_DATE} ${LOG_TIME}";

# RSSデータ取得
/var/www/vhosts/goo.to/etc/getdata/rss/rss_datas.pl

LOG_DATE=`date '+%Y-%m-%d'`
LOG_TIME=`date '+%H:%M:%S'`
echo "END rss_datas ${LOG_DATE} ${LOG_TIME}";


# RSSデータ取得
/var/www/vhosts/goo.to/etc/getdata/rss/rss_goo_datas.pl

LOG_DATE=`date '+%Y-%m-%d'`
LOG_TIME=`date '+%H:%M:%S'`
echo "END rss_goo_datas ${LOG_DATE} ${LOG_TIME}";


# RSSデータ取得
/var/www/vhosts/goo.to/etc/getdata/rss/get_motogp_data.pl

LOG_DATE=`date '+%Y-%m-%d'`
LOG_TIME=`date '+%H:%M:%S'`
echo "END get_motogp_data.pl ${LOG_DATE} ${LOG_TIME}";

# RSSデータ取得
/var/www/vhosts/goo.to/etc/getdata/rss/get_f1_data.pl

LOG_DATE=`date '+%Y-%m-%d'`
LOG_TIME=`date '+%H:%M:%S'`
echo "END get_f1_data.pl ${LOG_DATE} ${LOG_TIME}";


# facebookデータ取得
/var/www/vhosts/goo.to/etc/getdata/facebook/get_new_facebook.pl

LOG_DATE=`date '+%Y-%m-%d'`
LOG_TIME=`date '+%H:%M:%S'`
echo "END get_new_facebook ${LOG_DATE} ${LOG_TIME}";

# RSSデータ取得
/var/www/vhosts/goo.to/etc/getdata/keyword/keyword.pl

LOG_DATE=`date '+%Y-%m-%d'`
LOG_TIME=`date '+%H:%M:%S'`
echo "END keyword ${LOG_DATE} ${LOG_TIME}";
