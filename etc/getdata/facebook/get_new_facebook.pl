#!/usr/bin/perl
use lib qw(/var/www/vhosts/goo.to/etc/lib /var/www/vhosts/goo.to/lib/Waao);

#use strict;
use DBI;
use PageAnalyze;
use DataController;
use LWP::UserAgent;
use Jcode;

use Date::Simple ('date', 'today');

if ($$ != `/usr/bin/pgrep -fo $0`) {
print "exit \n";
    exit 1;
}
print "start \n";


my $dbh = &_db_connect();

my $dl_url = qq{http://facebook.boo.jp/new-page};

my $get_url = `GET "$dl_url"`;
my @lines = split(/\n/,$get_url);
foreach my $line (@lines){
#	$line = Jcode->new($line, 'utf8')->sjis;
	if($line =~/(.*)<a href=\"(.*)\" rel(.*)class=\"fanpage-title\"(.*)/){
print $2."\n";
		my $data = &facebook_page($2);
		&facebook_data($dbh,$data);
		foreach my $key ( sort keys( %{$data} ) ) {
    		print "$key:$data->{$key}\n ";
		}
	}
}

$dbh->disconnect;
exit;

	




sub _db_connect(){

    my $dsn = 'DBI:mysql:waao';
    my $user = 'mysqlweb';
    my $password = 'WaAoqzxe7h6yyHz';
    my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 1, AutoCommit => 0});

    return $dbh;
}

1;
