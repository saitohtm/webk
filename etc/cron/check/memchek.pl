#!/usr/bin/perl

#use strict;
my @comand = `ps aux | grep memcach`;
my $checkflag;
foreach my $line (@comand){
	$checkflag = 1 if($line =~/memcached/);
}

unless($checkflag){
#	print "LD_LIBRARY_PATH";
#	`export LD_LIBRARY_PATH=/usr/local/lib/`;
#	`sleep 1`;
	print "memcached start";
	`/usr/bin/memcached -d -m 1g -l 127.0.0.1 -p 11211 -u daemon`;
#	`sleep 5`;
#	print "mem programs start";
#	`/var/www/vhosts/waao.jp/etc/mem/mem_h.sh`;
}

exit;

