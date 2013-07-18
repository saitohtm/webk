#!/usr/bin/perl
# カーセンサーAPI用マスター取得処理

#use strict;
use DBI;
use XML::Simple;
use LWP::Simple;
use Jcode;
use CGI qw( escape );
use Data::Dumper;

# ブランドマスター
&_brand();

# 国マスター
&_country();

# 大ｴﾘｱマスター
&_area();

# 都道府県マスター
&_pref();

# ボディタイプマスター
&_body_type();

# ボディカラーマスター
&_body_color();

# カタログデータ
&_catalog();

# ピリオド
&_priod();

exit;
sub _priod(){
	
my $dbh = &_db_connect();

my $sth = $dbh->prepare( qq{select id, period from cs_catalog} );
$sth->execute();
while(my @row = $sth->fetchrow_array) {
	my $period = $row[1];
	my @vals = split(/-/,$period);
	my $start = $vals[0];
	my $end = $vals[1];
eval{
	my $sth2 = $dbh->prepare(qq{update cs_catalog set start_piriod = ?, end_piriod = ? where id = ? limit 1 });
	$sth2->execute($start, $end, $row[0]);
};

}

$dbh->disconnect;

	return;
}

sub _catalog(){
	
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);

return if($mday % 10);
$year = $year + 1900;
my $dbh = &_db_connect();

my $sth = $dbh->prepare( qq{select code, name, country_code , country_name from cs_brand} );
$sth->execute();
while(my @row = $sth->fetchrow_array) {
	my ($brand_code, $brand_name, $country_code , $country_name) = @row;
	for(my $i=0;$i<500;$i++){
		my $start = 1 + (10 * $i);
		my $url= qq{http://webservice.recruit.co.jp/carsensor/catalog/v1/?key=9a62bda886ec7031&country=$country_code&brand=$brand_code&start=$start&year_old=$year};
		print $url."\n";
		my $response = get($url);	
		my $xml = new XML::Simple;
		my $xml_val = $xml->XMLin($response);
		last if($xml_val->{results_returned} eq 0);
eval{
		&_get_car_data($xml_val,$brand_code, $brand_name, $country_code , $country_name);
};
		sleep 1;
	}
}
$dbh->disconnect;

	return;
}

sub _get_car_data(){
	my ($xml_val,$brand_code, $brand_name, $country_code , $country_name) = @_;
	
eval{
foreach my $result (@{$xml_val->{catalog}}) {
		&_data_set($result,$brand_code, $brand_name, $country_code , $country_name);
}
};
if($@){
		&_data_set($xml_val->{catalog},$brand_code, $brand_name, $country_code , $country_name);
}
	return;
}

sub _data_set(){
	my ($result,$brand_code, $brand_name, $country_code , $country_name) = @_;
	
	my $dbh2 = &_db_connect();

	my ($body_code, $body_name,
		$model,$grade,$price,$person,$period,$series,
		$width,$height,$length,
		$photo_frot_l,$photo_frot_s,$photo_frot_caption,
		$photo_rear_l,$photo_rear_s,$photo_rear_caption,
	    $photo_inpane_l,$photo_inpane_s,$photo_inpane_caption,
		$shop_url_pc,$shop_url_mobile,$desc
		);
eval{
	$model = $result->{model};
	$grade = $result->{grade};
	$price = $result->{price};
};
eval{
	$body_code = $result->{body}->{code};
	$body_name = $result->{body}->{name};

};
eval{
	$person = $result->{person};
	$period = $result->{period};
	$series = $result->{series};
};
eval{
	$width = $result->{width};
	$height = $result->{height};
	$length = $result->{length};
};

eval{
	$photo_frot_l = $result->{photo}->{front}->{l};
	$photo_frot_s = $result->{photo}->{front}->{s};
	$photo_frot_caption = $result->{photo}->{front}->{caption};

	$photo_rear_l = $result->{photo}->{rear}->{l};
	$photo_rear_s = $result->{photo}->{rear}->{s};
	$photo_rear_caption = $result->{photo}->{rear}->{caption};

	$photo_inpane_l = $result->{photo}->{inpane}->{l};
	$photo_inpane_s = $result->{photo}->{inpane}->{s};
	$photo_inpane_caption = $result->{photo}->{inpane}->{caption};
};
eval{
	$shop_url_pc = $result->{urls}->{pc};
	$shop_url_mobile = $result->{urls}->{mobile};
};
eval{
	$desc = $result->{desc};
};

eval{
		my $sth = $dbh2->prepare( qq{insert into cs_catalog  
		( `brand_code`,`brand_name`,`country_code`,`country_name`,`body_code`,`body_name`,
		  `model`,`grade`,`price`,`person`,`period`,`series`,
		  `width`,`height`,`length_val`,
		  `photo_frot_l`,`photo_frot_s`,`photo_frot_caption`,
		  `photo_rear_l`,`photo_rear_s`,`photo_rear_caption`,
		  `photo_inpane_l`,`photo_inpane_s`,`photo_inpane_caption`,
		  `shop_url_pc`,`shop_url_mobile`,`desc`
		 ) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)} );
		$sth->execute($brand_code, $brand_name, $country_code , $country_name, $body_code, $body_name,
		$model,$grade,$price,$person,$period,$series,
		$width,$height,$length,
		$photo_frot_l,$photo_frot_s,$photo_frot_caption,
		$photo_rear_l,$photo_rear_s,$photo_rear_caption,
	    $photo_inpane_l,$photo_inpane_s,$photo_inpane_caption,
		$shop_url_pc,$shop_url_mobile,$desc
		);
};
	$dbh2->disconnect;

	return;
}

sub _body_color(){

my $url= qq{http://webservice.recruit.co.jp/carsensor/color/v1/?key=9a62bda886ec7031};
my $response = get($url);	
my $xml = new XML::Simple;
my $xml_val = $xml->XMLin($response);
my $dbh = &_db_connect();
foreach my $name (keys %{$xml_val->{color}}) {
	my $code = $xml_val->{color}->{$name}->{code};
	my $name = $name;
eval{
		my $sth = $dbh->prepare( qq{insert into cs_body_color ( `code`,`name`) values (?,?)} );
		$sth->execute($code, $name);
};
}
$dbh->disconnect;
	
	return;
}

sub _body_type(){

my $url= qq{http://webservice.recruit.co.jp/carsensor/body/v1/?key=9a62bda886ec7031};
my $response = get($url);	
my $xml = new XML::Simple;
my $xml_val = $xml->XMLin($response);
my $dbh = &_db_connect();
foreach my $name (keys %{$xml_val->{body}}) {
	my $code = $xml_val->{body}->{$name}->{code};
	my $name = $name;
eval{
		my $sth = $dbh->prepare( qq{insert into cs_body ( `code`,`name`) values (?,?)} );
		$sth->execute($code, $name);
};
}
$dbh->disconnect;
	
	return;
}

sub _pref(){

my $url= qq{http://webservice.recruit.co.jp/carsensor/pref/v1/?key=9a62bda886ec7031};
my $response = get($url);	
my $xml = new XML::Simple;
my $xml_val = $xml->XMLin($response);
my $dbh = &_db_connect();
foreach my $name (keys %{$xml_val->{pref}}) {
	my $code = $xml_val->{pref}->{$name}->{code};
	my $large_area_code = $xml_val->{pref}->{$name}->{large_area}->{code};
	my $large_area_name = $xml_val->{pref}->{$name}->{large_area}->{name};
	my $name = $name;
eval{
		my $sth = $dbh->prepare( qq{insert into cs_pref ( `code`,`name`,`large_area_code`,`large_area_name`) values (?,?,?,?)} );
		$sth->execute($code, $name,$large_area_code, $large_area_name);
};
}
$dbh->disconnect;
	
	return;
}

sub _area(){

my $url= qq{http://webservice.recruit.co.jp/carsensor/large_area/v1/?key=9a62bda886ec7031};
my $response = get($url);	
my $xml = new XML::Simple;
my $xml_val = $xml->XMLin($response);
my $dbh = &_db_connect();
foreach my $name (keys %{$xml_val->{large_area}}) {
	my $code = $xml_val->{large_area}->{$name}->{code};
	my $name = $name;
eval{
		my $sth = $dbh->prepare( qq{insert into cs_area ( `code`,`name`) values (?,?)} );
		$sth->execute($code, $name);
};
}
$dbh->disconnect;
	
	return;
}


sub _country(){

my $url= qq{http://webservice.recruit.co.jp/carsensor/country/v1/?key=9a62bda886ec7031};
my $response = get($url);	
my $xml = new XML::Simple;
my $xml_val = $xml->XMLin($response);
my $dbh = &_db_connect();
foreach my $name (keys %{$xml_val->{country}}) {
	my $code = $xml_val->{country}->{$name}->{code};
	my $name = $name;
eval{
		my $sth = $dbh->prepare( qq{insert into cs_country ( `code`,`name`) values (?,?)} );
		$sth->execute($code, $name);
};
}
$dbh->disconnect;
	
	return;
}

sub _brand(){

my $url= qq{http://webservice.recruit.co.jp/carsensor/brand/v1/?key=9a62bda886ec7031};
my $response = get($url);	
my $xml = new XML::Simple;
my $xml_val = $xml->XMLin($response);
my $dbh = &_db_connect();
foreach my $name (keys %{$xml_val->{brand}}) {
	my $code = $xml_val->{brand}->{$name}->{code};
	my $country_code = $xml_val->{brand}->{$name}->{country}->{code};
	my $country_name = $xml_val->{brand}->{$name}->{country}->{name};
	my $name = $name;
eval{
		my $sth = $dbh->prepare( qq{insert into cs_brand ( `code`,`name`,`country_code`,`country_name`) values (?,?,?,?)} );
		$sth->execute($code, $name, $country_code, $country_name);
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