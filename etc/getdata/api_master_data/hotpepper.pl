#!/usr/bin/perl
# ホットペッパーAPI用マスター取得処理

#use strict;
use DBI;
use XML::Simple;
use LWP::Simple;
use Jcode;
use CGI qw( escape );

# 予算マスター
&_yosan();

# 大サービスエリアマスタ
&_large_service_area();

# サービスエリアマスタ
&_service_area();

#　大エリアマスタ
&_large_area();

#　中エリアマスタ
&_middle_area();

#　小エリアマスタ
&_small_area();

#　ジャンルマスタ
&_genre();

#　料理名マスタ
&_food();

#　特集マスタ
&_special();

#　特集カテゴリマスタ
&_special_category();

exit;

# 予算マスター
sub _yosan(){
	my $self = shift;

my $url= qq{http://webservice.recruit.co.jp/hotpepper/budget/v1/?key=9a62bda886ec7031};
my $response = get($url);	
my $xml = new XML::Simple;
my $xml_val = $xml->XMLin($response);

my $dbh = &_db_connect();

foreach my $key (keys %{$xml_val->{budget}}) {
	my $code = $xml_val->{budget}->{$key}->{code};
	my $name = $key;
	$name =~s/\?/～/;
eval{
	my $sth = $dbh->prepare( qq{insert into hpp_yosan ( `code`,`name`) values (?,?)} );
	$sth->execute($code, $name);
};

}
$dbh->disconnect;
	
	
	return;
}

# 大サービスエリアマスタ
sub _large_service_area(){
	my $self = shift;

my $url= qq{http://webservice.recruit.co.jp/hotpepper/large_service_area/v1/?key=9a62bda886ec7031};
my $response = get($url);	
my $xml = new XML::Simple;
my $xml_val = $xml->XMLin($response);

my $dbh = &_db_connect();

foreach my $key (keys %{$xml_val->{large_service_area}}) {
	my $code = $xml_val->{large_service_area}->{$key}->{code};
	my $name = $key;
eval{
	my $sth = $dbh->prepare( qq{insert into hpp_large_service_area ( `code`,`name`) values (?,?)} );
	$sth->execute($code, $name);
};

}
$dbh->disconnect;
	
	
	return;
}

# サービスエリアマスタ
sub _service_area(){
	my $self = shift;

my $url= qq{http://webservice.recruit.co.jp/hotpepper/service_area/v1/?key=9a62bda886ec7031};
my $response = get($url);	
my $xml = new XML::Simple;
my $xml_val = $xml->XMLin($response);

my $dbh = &_db_connect();

foreach my $key (keys %{$xml_val->{service_area}}) {
	my $code = $xml_val->{service_area}->{$key}->{code};
	my $name = $key;
	my $large_code = $xml_val->{service_area}->{$key}->{large_service_area}->{code};
	my $large_name = $xml_val->{service_area}->{$key}->{large_service_area}->{name};
eval{
	my $sth = $dbh->prepare( qq{insert into hpp_service_area ( `code`,`name`,`large_code`,`large_name`) values (?,?,?,?)} );
	$sth->execute($code, $name, $large_code, $large_name);
};

}
$dbh->disconnect;
	
	
	return;
}

# 大エリアマスタ
sub _large_area(){
	my $self = shift;

my $url= qq{http://webservice.recruit.co.jp/hotpepper/large_area/v1/?key=9a62bda886ec7031};
my $response = get($url);	
my $xml = new XML::Simple;
my $xml_val = $xml->XMLin($response);

my $dbh = &_db_connect();

foreach my $key (keys %{$xml_val->{large_area}}) {
	my $code = $xml_val->{large_area}->{$key}->{code};
	my $name = $key;
	my $large_service_code = $xml_val->{large_area}->{$key}->{large_service_area}->{code};
	my $large_service_name = $xml_val->{large_area}->{$key}->{large_service_area}->{name};
	my $service_code = $xml_val->{large_area}->{$key}->{service_area}->{code};
	my $service_name = $xml_val->{large_area}->{$key}->{service_area}->{name};
eval{
	my $sth = $dbh->prepare( qq{insert into hpp_large_area ( `code`,`name`,`large_service_code`,`large_service_name`,`service_code`,`service_name`) values (?,?,?,?,?,?)} );
	$sth->execute($code, $name, $large_service_code, $large_service_name, $service_code, $service_name);
};

}
$dbh->disconnect;
	
	
	return;
}

sub _middle_area(){
	my $self = shift;

my $url= qq{http://webservice.recruit.co.jp/hotpepper/middle_area/v1/?key=9a62bda886ec7031};
my $response = get($url);	
my $xml = new XML::Simple;
my $xml_val = $xml->XMLin($response);

my $dbh = &_db_connect();

foreach my $key (keys %{$xml_val->{middle_area}}) {
	my $code = $xml_val->{middle_area}->{$key}->{code};
	my $name = $key;
	my $large_code = $xml_val->{middle_area}->{$key}->{large_area}->{code};
	my $large_name = $xml_val->{middle_area}->{$key}->{large_area}->{name};
	my $large_service_code = $xml_val->{middle_area}->{$key}->{large_service_area}->{code};
	my $large_service_name = $xml_val->{middle_area}->{$key}->{large_service_area}->{name};
	my $service_code = $xml_val->{middle_area}->{$key}->{service_area}->{code};
	my $service_name = $xml_val->{middle_area}->{$key}->{service_area}->{name};
eval{
	my $sth = $dbh->prepare( qq{insert into hpp_middle_area ( `code`,`name`,`large_service_code`,`large_service_name`,`service_code`,`service_name`,`large_code`,`large_name`) values (?,?,?,?,?,?,?,?)} );
	$sth->execute($code, $name, $large_service_code, $large_service_name, $service_code, $service_name, $large_code, $large_name);
};

}
$dbh->disconnect;
	
	
	return;
}

sub _small_area(){
	my $self = shift;

my $url= qq{http://webservice.recruit.co.jp/hotpepper/small_area/v1/?key=9a62bda886ec7031};
my $response = get($url);	
my $xml = new XML::Simple;
my $xml_val = $xml->XMLin($response);

my $dbh = &_db_connect();

foreach my $key (keys %{$xml_val->{small_area}}) {
	my $code = $xml_val->{small_area}->{$key}->{code};
	my $name = $key;
	my $large_code = $xml_val->{small_area}->{$key}->{large_area}->{code};
	my $large_name = $xml_val->{small_area}->{$key}->{large_area}->{name};
	my $middle_code = $xml_val->{small_area}->{$key}->{middle_area}->{code};
	my $middle_name = $xml_val->{small_area}->{$key}->{middle_area}->{name};
	my $large_service_code = $xml_val->{small_area}->{$key}->{large_service_area}->{code};
	my $large_service_name = $xml_val->{small_area}->{$key}->{large_service_area}->{name};
	my $service_code = $xml_val->{small_area}->{$key}->{service_area}->{code};
	my $service_name = $xml_val->{small_area}->{$key}->{service_area}->{name};
eval{
	my $sth = $dbh->prepare( qq{insert into hpp_small_area ( `code`,`name`,`large_service_code`,`large_service_name`,`service_code`,`service_name`,`large_code`,`large_name`,`middle_code`,`middle_name`) values (?,?,?,?,?,?,?,?,?,?)} );
	$sth->execute($code, $name, $large_service_code, $large_service_name, $service_code, $service_name, $large_code, $large_name, $middle_code, $middle_name);
};

}
$dbh->disconnect;
	
	
	return;
}

# ジャンルマスタ
sub _genre(){
	my $self = shift;

my $url= qq{http://webservice.recruit.co.jp/hotpepper/genre/v1/?key=9a62bda886ec7031};
my $response = get($url);	
my $xml = new XML::Simple;
my $xml_val = $xml->XMLin($response);

my $dbh = &_db_connect();

foreach my $key (keys %{$xml_val->{genre}}) {
	my $code = $xml_val->{genre}->{$key}->{code};
	my $name = $key;
eval{
	my $sth = $dbh->prepare( qq{insert into hpp_genre ( `code`,`name`) values (?,?)} );
	$sth->execute($code, $name);
};

}
$dbh->disconnect;
	
	
	return;
}

# 料理名マスタ
sub _food(){
	my $self = shift;

my $url= qq{http://webservice.recruit.co.jp/hotpepper/food/v1/?key=9a62bda886ec7031};
my $response = get($url);	
my $xml = new XML::Simple;
my $xml_val = $xml->XMLin($response);

my $dbh = &_db_connect();

foreach my $key (keys %{$xml_val->{food}}) {
	my $code = $xml_val->{food}->{$key}->{code};
	my $name = Jcode->new($key, 'utf8')->sjis;
eval{
	my $sth = $dbh->prepare( qq{insert into hpp_food ( `code`,`name`) values (?,?)} );
	$sth->execute($code, $name);
};

}
$dbh->disconnect;
	
	
	return;
}

# 特集マスタ
sub _special(){
	my $self = shift;

my $url= qq{http://webservice.recruit.co.jp/hotpepper/special/v1/?key=9a62bda886ec7031};
my $response = get($url);	
my $xml = new XML::Simple;
my $xml_val = $xml->XMLin($response);

my $dbh = &_db_connect();

foreach my $key (keys %{$xml_val->{special}}) {
	my $code = $xml_val->{special}->{$key}->{code};
	my $name = Jcode->new($key, 'utf8')->sjis;
	my $category_code = $xml_val->{special}->{$key}->{special_category}->{code};
	my $category_name = Jcode->new($xml_val->{special}->{$key}->{special_category}->{name}, 'utf8')->sjis;
eval{
	my $sth = $dbh->prepare( qq{insert into hpp_special ( `code`,`name`,`category_code`,`category_name`) values (?,?,?,?)} );
	$sth->execute($code, $name, $category_code, $category_name);
};

}
$dbh->disconnect;
	
	return;
}

# 特集カテゴリマスタ
sub _special_category(){
	my $self = shift;

my $url= qq{http://webservice.recruit.co.jp/hotpepper/special_category/v1/?key=9a62bda886ec7031};
my $response = get($url);	
my $xml = new XML::Simple;
my $xml_val = $xml->XMLin($response);

my $dbh = &_db_connect();

foreach my $key (keys %{$xml_val->{special_category}}) {
	my $code = $xml_val->{special_category}->{$key}->{code};
	my $name = Jcode->new($key, 'utf8')->sjis;
eval{
	my $sth = $dbh->prepare( qq{insert into hpp_special_category ( `code`,`name` ) values (?,?)} );
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