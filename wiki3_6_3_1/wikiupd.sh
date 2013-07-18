#!/bin/sh

rm /var/www/vhosts/goo.to/wiki3_6_3_1/jawiki-latest-pages-meta-current.xml.bz2
rm /var/www/vhosts/goo.to/wiki3_6_3_1/*.txt

echo "rm file ";

wget --output-document='/var/www/vhosts/goo.to/wiki3_6_3_1/jawiki-latest-pages-meta-current.xml.bz2' 'http://download.wikimedia.org/jawiki/latest/jawiki-latest-pages-meta-current.xml.bz2'

echo "wget ";

bzcat /var/www/vhosts/goo.to/wiki3_6_3_1/jawiki-latest-pages-meta-current.xml.bz2 | sed -e "s/<redirect>.*<\/redirect>\|<redirect.*\/>\|<ns>.*<\/ns>\|<parentid>.*<\/parentid>\|<sha1>.*<\/sha1>\|<model>.*<\/model>\|<format>.*<\/format>//g" | xml2sql

echo "xml2sql";

mv /root/*.txt /var/www/vhosts/goo.to/wiki3_6_3_1/

/var/www/vhosts/goo.to/wiki3_6_3_1/truncatetable.pl

echo "trancate table";

mysqlimport -f -u mysqlweb -pWaAoqzxe7h6yyHz waao /var/www/vhosts/goo.to/wiki3_6_3_1/*.txt

echo "mysqlimport";

