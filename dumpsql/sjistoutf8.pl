#!/usr/bin/perl
# スマフォページ作成処理
use lib qw(/var/www/vhosts/goo.to/etc/lib /var/www/vhosts/goo.to/lib/Waao);

use strict;
use Utility;
use DBI;
use Jcode;
use XML::Simple;
use LWP::Simple;
use URI::Escape;
use CGI qw( escape );
use Date::Simple;

if($ARGV[0]){
	my $file = qq{/var/www/vhosts/goo.to/dumpsql/$ARGV[0]};
	my $filename = qq{/var/www/vhosts/goo.to/dumpsql/$ARGV[0]}.qq{utf8};
	print "A $file\n";
	print "B $filename\n";
	my $fh;
	my $filedata;
	my $cnt;
	open( $fh, "<", $file );
	while( my $line = readline $fh ){ 
		$cnt++;
		print $cnt."\n" if($cnt % 1000);
		$line = Jcode->new($line, 'sjis')->utf8;
		$filedata = $line;
		$filedata =~s/\\//g;
		open(OUT,">> $filename") || die('error');
		print OUT "$filedata";
		close(OUT);
	}
	close ( $fh );


}

1;