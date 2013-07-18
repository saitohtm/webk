#!/usr/bin/perl
# タウンマーケットAPI用マスター取得処理

#use strict;
use DBI;
use XML::Simple;
use LWP::Simple;
use Jcode;
use CGI qw( escape );
use Data::Dumper;

# 屋号マスター
#&_trade();

# 業種マスター

# 都道府県マスター
&_pref();
# 市郡区マスター
&_city();

exit;

sub _city(){
my $dbh = &_db_connect();
my $sth = $dbh->prepare( qq{select code, name from tmk_pref} );
$sth->execute();
while(my @row = $sth->fetchrow_array) {
	my ($pref_code, $pref_name) = @row;
my $url= qq{http://webservice.recruit.co.jp/townmarket/city/v1/?key=9a62bda886ec7031&count=100&pref=$pref_code};
my $response = get($url);	
my $xml = new XML::Simple;
my $xml_val = $xml->XMLin($response);
foreach my $name (keys %{$xml_val->{city}}) {
	my $code = $xml_val->{city}->{$name}->{code};
	my $url = $xml_val->{city}->{$name}->{urls}->{pc};
	my $name = $name;
eval{
		my $sth2 = $dbh->prepare( qq{insert into tmk_city ( `code`,`name`,`url`,`pref_code`,`pref_name`) values (?,?,?,?,?)} );
		$sth2->execute($code, $name, $url, $pref_code, $pref_name);
};
}

}
$dbh->disconnect;
	
	return;
}

sub _pref(){

my $url= qq{http://webservice.recruit.co.jp/townmarket/pref/v1/?key=9a62bda886ec7031};
my $response = get($url);	
my $xml = new XML::Simple;
my $xml_val = $xml->XMLin($response);
my $dbh = &_db_connect();
foreach my $name (keys %{$xml_val->{pref}}) {
	my $code = $xml_val->{pref}->{$name}->{code};
	my $url = $xml_val->{pref}->{$name}->{urls}->{pc};
	my $name = $name;
eval{
		my $sth = $dbh->prepare( qq{insert into tmk_pref ( `code`,`name`,`url`) values (?,?,?)} );
		$sth->execute($code, $name, $url);
};
}
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