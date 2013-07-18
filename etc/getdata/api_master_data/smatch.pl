#!/usr/bin/perl
# スマッチAPI用マスター取得処理

#use strict;
use DBI;
use XML::Simple;
use LWP::Simple;
use Jcode;
use CGI qw( escape );
use Data::Dumper;

&_station();
exit;
# エリアマスター
&_area();

# カテゴリマスター
&_category();

# 都道府県マスター
&_pref();

# 市郡区マスター
&_city();

# 沿線方面マスター
&_line_area();

# 沿線マスター
&_line();

# 駅マスター
&_station();


exit;

sub _station(){

my $dbh = &_db_connect();

my $sth = $dbh->prepare( qq{select code, name, area_code, area_name, line_area_code, line_area_name from smc_line } );
$sth->execute();
while(my @row = $sth->fetchrow_array) {
	my ($line_code, $line_name, $area_code, $area_name, $line_area_code, $line_area_name) = @row;

	my $url= qq{http://api.smatch.jp/station/?key=9a62bda886ec7031&line=$line_code&line_area=$line_area_code};
print $url."\n";
sleep 1;
	my $response = get($url);	
	my $xml = new XML::Simple;
	my $xml_val = $xml->XMLin($response);
	foreach my $name (keys %{$xml_val->{station}}) {
		my $code = $xml_val->{station}->{$name}->{code};
print $code."\n";
		my $link_station = $xml_val->{station}->{$name}->{link_station};
		my $link_mobile = $xml_val->{station}->{$name}->{link_mobile};
		my $name = $name;
eval{
		my $sth2 = $dbh->prepare( qq{insert into smc_station ( `code`,`name`,`link_station`,`link_mobile`,`area_code`,`area_name`,`line_area_code`,`line_area_name`,`line_code`,`line_name`) values (?,?,?,?,?,?,?,?,?,?)} );
		$sth2->execute($code, $name, $link_station, $link_mobile, $area_code, $area_name,$line_area_code, $line_area_name,$line_code, $line_name);
};
	}
}

$dbh->disconnect;

	return;
}

sub _line(){

my $dbh = &_db_connect();

my $sth = $dbh->prepare( qq{select code, name, area_code, area_name from smc_line_area } );
$sth->execute();
while(my @row = $sth->fetchrow_array) {
	my ($line_area_code, $line_area_name, $area_code, $area_name) = @row;

	my $url= qq{http://api.smatch.jp/line/?key=9a62bda886ec7031&area=$area_code&line_area=$line_area_code};
sleep 1;
	my $response = get($url);	
	my $xml = new XML::Simple;
	my $xml_val = $xml->XMLin($response);
	foreach my $name (keys %{$xml_val->{line}}) {
		my $code = $xml_val->{line}->{$name}->{code};
		my $link_line = $xml_val->{line}->{$name}->{link_line};
		my $link_mobile = $xml_val->{line}->{$name}->{link_mobile};
		my $name = $name;
eval{
		my $sth2 = $dbh->prepare( qq{insert into smc_line ( `code`,`name`,`link_line`,`link_mobile`,`area_code`,`area_name`,`line_area_code`,`line_area_name`) values (?,?,?,?,?,?,?,?)} );
		$sth2->execute($code, $name, $link_line, $link_mobile, $area_code, $area_name,$line_area_code, $line_area_name);
};
	}
}

$dbh->disconnect;

	return;
}

sub _line_area(){

my $dbh = &_db_connect();

my $sth = $dbh->prepare( qq{select code, name from smc_area } );
$sth->execute();
while(my @row = $sth->fetchrow_array) {
	my ($area_code, $area_name) = @row;

	my $url= qq{http://api.smatch.jp/line_area/?key=9a62bda886ec7031&area=$area_code};
sleep 1;
	my $response = get($url);	
	my $xml = new XML::Simple;
	my $xml_val = $xml->XMLin($response);
	foreach my $name (keys %{$xml_val->{line_area}}) {
		my $code = $xml_val->{line_area}->{$name}->{code};
		my $link_line_area = $xml_val->{line_area}->{$name}->{link_line_area};
		my $link_mobile = $xml_val->{line_area}->{$name}->{link_mobile};
		my $name = $name;
eval{
		my $sth2 = $dbh->prepare( qq{insert into smc_line_area ( `code`,`name`,`link_line_area`,`link_mobile`,`area_code`,`area_name`) values (?,?,?,?,?,?)} );
		$sth2->execute($code, $name, $link_line_area, $link_mobile, $area_code, $area_name);
};
	}
}

$dbh->disconnect;

	return;
}

sub _city(){

my $dbh = &_db_connect();

my $sth = $dbh->prepare( qq{select code, name,  area_code, area_name from smc_pref } );
$sth->execute();
while(my @row = $sth->fetchrow_array) {
	my ($pref_code, $pref_name, $area_code, $area_name) = @row;

	my $url= qq{http://api.smatch.jp/city/?key=9a62bda886ec7031&area=$area_code&pref=$pref_code};
sleep 1;
print $url."\n";
	my $response = get($url);	
	my $xml = new XML::Simple;
	my $xml_val = $xml->XMLin($response);
	foreach my $name (keys %{$xml_val->{city}}) {
		my $code = $xml_val->{city}->{$name}->{code};
		my $link_city = $xml_val->{city}->{$name}->{link_city};
		my $link_mobile = $xml_val->{city}->{$name}->{link_mobile};
		my $name = $name;
		next unless($code);
eval{
		my $sth2 = $dbh->prepare( qq{insert into smc_city ( `code`,`name`,`link_city`,`link_mobile`,`pref_code`,`pref_name`,`area_code`,`area_name`) values (?,?,?,?,?,?,?,?)} );
		$sth2->execute($code, $name, $link_city, $link_mobile, $pref_code, $pref_name, $area_code, $area_name);
};
	}
}

$dbh->disconnect;

	return;
}

sub _pref(){

my $urlarea= qq{http://api.smatch.jp/area/?key=9a62bda886ec7031};
my $responsearea = get($urlarea);	
my $xmlarea = new XML::Simple;
my $xmlarea_val = $xmlarea->XMLin($responsearea);
foreach my $arename (keys %{$xmlarea_val->{area}}) {
	my $areacode = $xmlarea_val->{area}->{$arename}->{code};
	$arename = $arename;
	my $url= qq{http://api.smatch.jp/pref/?key=9a62bda886ec7031&area=$areacode};
sleep 1;
	my $response = get($url);	
	my $xml = new XML::Simple;
	my $xml_val = $xml->XMLin($response);
	my $dbh = &_db_connect();
	foreach my $name (keys %{$xml_val->{pref}}) {
		my $code = $xml_val->{pref}->{$name}->{code};
		my $link_pref = $xml_val->{pref}->{$name}->{link_pref};
		my $link_mobile = $xml_val->{pref}->{$name}->{link_mobile};
		my $name = $name;
eval{
		my $sth = $dbh->prepare( qq{insert into smc_pref ( `code`,`name`,`link_pref`,`link_mobile`,`area_code`,`area_name`) values (?,?,?,?,?,?)} );
		$sth->execute($code, $name, $link_pref, $link_mobile, $areacode, $arename);
};
	}
	$dbh->disconnect;
}
	
	return;
}

sub _category(){

my $urlarea= qq{http://api.smatch.jp/area/?key=9a62bda886ec7031};
sleep 1;
my $responsearea = get($urlarea);	
my $xmlarea = new XML::Simple;
my $xmlarea_val = $xmlarea->XMLin($responsearea);
foreach my $arename (keys %{$xmlarea_val->{area}}) {
	my $areacode = $xmlarea_val->{area}->{$arename}->{code};
	$arename = $arename;
	my $url= qq{http://api.smatch.jp/category/?key=9a62bda886ec7031&area=$areacode};
	sleep 1;
	my $response = get($url);	
	my $xml = new XML::Simple;
	my $xml_val = $xml->XMLin($response);
	my $dbh = &_db_connect();
	foreach my $name (keys %{$xml_val->{category}}) {
		my $code = $xml_val->{category}->{$name}->{code};
		my $link_category = $xml_val->{category}->{$name}->{link_category};
		my $link_mobile = $xml_val->{category}->{$name}->{link_mobile};
		my $name = $name;
eval{
		my $sth = $dbh->prepare( qq{insert into smc_category ( `code`,`name`,`link_category`,`link_mobile`,`area_code`,`area_name`) values (?,?,?,?,?,?)} );
		$sth->execute($code, $name, $link_category, $link_mobile, $areacode, $arename);
};
	}
	$dbh->disconnect;
}
	
	return;
}

# 予算マスター
sub _area(){

my $url= qq{http://api.smatch.jp/area/?key=9a62bda886ec7031};
my $response = get($url);	
my $xml = new XML::Simple;
my $xml_val = $xml->XMLin($response);
my $dbh = &_db_connect();

foreach my $name (keys %{$xml_val->{area}}) {
	my $code = $xml_val->{area}->{$name}->{code};
	my $name = $name;
eval{
	my $sth = $dbh->prepare( qq{insert into smc_area ( `code`,`name`) values (?,?)} );
	$sth->execute($code, $name);
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