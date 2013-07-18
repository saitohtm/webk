#!/bin/sh

/var/www/vhosts/goo.to/etc/makehtml/smax/top_html.pl
echo "top_html";

/var/www/vhosts/goo.to/etc/makehtml/smax/bloglist_html.pl
echo "bloglist_html.pl";

/var/www/vhosts/goo.to/etc/makehtml/smax/twitlist_html.pl
echo "twitlist_html.pl";

/var/www/vhosts/goo.to/etc/makehtml/smax/meikanlist_html.pl
echo "meikanlist_html.pl";

/var/www/vhosts/goo.to/etc/makehtml/smax/sitelist_html.pl
echo "sitelist_html.pl";

date
