#!/usr/bin/perl

#use strict;
use URI::Escape;
use DBI;
use LWP::Simple;
use Jcode;

my $dsn = 'DBI:mysql:waao';
my $user = 'mysqlweb';
my $password = 'WaAoqzxe7h6yyHz';

my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 0, AutoCommit => 0});

# “s“¹•{Œ§
my $prefdata;
my $sth = $dbh->prepare( qq{select id,name from pref });
$sth->execute();
while(my @row = $sth->fetchrow_array) {
	$prefdata->{$row[1]}=$row[0];
}
my $hdata;
my $file = qq{/var/www/vhosts/waao.jp/etc/getdata/siniorhome/home.txt};
my $fh;
my $filedata;
open( $fh, "<", $file );
while( my $line = readline $fh ){
	if($line =~/<a href=\"(.*)\">(.*)<\/a>/){
		$hdata->{pref_name} = $2;
		$hdata->{pref_id} = $prefdata->{$2};
		&_pref($dbh,$1,$hdata);
	}
}
close ( $fh );

$dbh->disconnect;

exit;

sub _pref(){
	my $dbh = shift;
	my $url = shift;
	my $hdata = shift;
	
	my $get_url = get( "http://rjhome.org/zenkoku/$url" );
	my @lines = split(/\n/,$get_url);
	foreach my $line (@lines){
		$line = Jcode->new($line, 'utf8')->sjis;
		if($line =~/<li><a href=\"(.*)\" target=\"_blank\">(.*)<\/a><br>ZŠF(.*)<br>“d˜b”Ô†F(.*)<\/li>/){
			my $url = $1;
			my $name = $2;
			my $address = $3;
			my $tel = $4;
			$address =~s/$hdata->{pref_name}//g;
eval{
my $sth = $dbh->prepare(qq{insert into sinior_home (name,pref_name,pref_id,address,tel,type,homepage) values(?,?,?,?,?,?,?)} );
$sth->execute($name,$hdata->{pref_name},$hdata->{pref_id},$address,$tel,1,$url); 
};
		}
	}	

	return;
}

