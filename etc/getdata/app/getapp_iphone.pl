#!/usr/bin/perl

# セール情報を取得するプログラム
use lib qw(/var/www/vhosts/goo.to/etc/lib /var/www/vhosts/goo.to/lib/Waao);

#use strict;
use DBI;
use Unicode::Japanese;
use LWP::UserAgent;
use Jcode;
use URI::Escape;
use PageAnalyze;
use DataController;

use Date::Simple ('date', 'today');

if($ARGV[0]){
	&_app($ARGV[0]);
}

exit;
sub _app(){
	my $app_id = shift;

	my $dbh = &_db_connect();

	my $data = &itunes_page_lookup($app_id);
	&app_iphone_data($dbh, $data);

	$dbh->disconnect;

	return;
}


sub _db_connect(){

    my $dsn = 'DBI:mysql:waao';
    my $user = 'mysqlweb';
    my $password = 'WaAoqzxe7h6yyHz';
    my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 1, AutoCommit => 0});

    return $dbh;
}

1;
