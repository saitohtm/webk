#!/usr/bin/perl
use lib qw(/var/www/vhosts/goo.to/etc/lib /var/www/vhosts/goo.to/lib/Waao);

#use strict;
use DBI;
use Data::Dumper;
use Date::Simple ('date', 'today');
use CarPhoto;

my $dsn = 'DBI:mysql:waao';
my $user = 'mysqlweb';
my $password = 'WaAoqzxe7h6yyHz';
my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 1, AutoCommit => 0});

if($ARGV[0]){
	# 引数 1:サイトURL 2:textファイル

}else{
my @tablename = ("car","celebrities","animal","travel");

foreach my $tablename (@tablename){
print $tablename."\n";
sleep 2;
	my $sth = $dbh->prepare(qq{select id,url from $tablename}.qq{_photo_site});
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		next unless($row[1]);
		&car_photo($dbh,$row[1],$row[0],$tablename);
	}
}


	my $sth = $dbh->prepare(qq{select id,url from car_photo_site});
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		next unless($row[1]);
		&car_photo($dbh,$row[1],$row[0]);
	}
}




$dbh->disconnect;

exit;


