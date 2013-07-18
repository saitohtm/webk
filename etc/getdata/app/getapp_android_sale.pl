#!/usr/bin/perl
# セール情報を取得するプログラム
use lib qw(/var/www/vhosts/goo.to/etc/lib /var/www/vhosts/goo.to/lib/Waao);

#use strict;
use DBI;
use Unicode::Japanese;
use LWP::UserAgent;
use Jcode;
use URI::Escape;

use Date::Simple ('date', 'today');

if($ARGV[0] eq 'octoba'){
	&_octoba();
}else{
	&_androwire();
}

exit;

sub _octoba(){
	my $date = Date::Simple->new();
	my $ymd = $date->format('%Y%m%d');
	my $y = $date->format('%Y');
	my $m = $date->format('%m');

	$ymd = $ARGV[0] if($ARGV[0]);
print "$ymd\n";

	my $dl_url = qq{http://octoba.net/archives/$ymd-android-sale.html};

	print "$dl_url _octoba \n";

	my $get_url = `GET "$dl_url"`;

	my $app_url;
	my $price;
	my $saleprice;
	
	my @lines = split(/\n/,$get_url);
	foreach my $line (@lines){
#		$line = Jcode->new($line, 'utf8')->sjis;

		if($line =~/(.*)\/\/market(.*)id=(.*)\"(.*)class(.*)external(.*)/){

#			$app_url = q{https://market.android.com/details?id=}.$3;
#			print "$app_url \n\n";
print "$app_url $price $saleprice \n";
			&_get_app_info($3,$price,$saleprice);
		}

		if($line =~/(.*)color=deeppink>(.*)円→(.*)<\/font>(.*)/){

#print "$app_url $price $saleprice \n";
			$price = $2;
			$saleprice = $3;
			if($saleprice eq "無料"){
				$saleprice = 0;
			}else{
#				chop $saleprice;
			}
			$saleprice=~s/約//;
			$saleprice=~s/円//;
			$price=~s/\\//;
			$saleprice=~s/\\//;
			$price=~s/￥//;
			$saleprice=~s/￥//;
			$price=~s/\?//;
			$saleprice=~s/\?//;
			$price=~s/,//;
			$saleprice=~s/,//;
		}
	}

	return;
}


sub _androwire(){
	my $date = Date::Simple->new();
	my $ymd = $date->format('%Y%m%d');
	my $y = $date->format('%Y');
	my $m = $date->format('%m');

	$ymd = $ARGV[0] if($ARGV[0]);
print "$ymd\n";

	my $dl_url = qq{http://androwire.jp/genres/newrelease/genre:ALL/price:discount/};

	print "$dl_url _androwire \n";

	my $get_url = `GET "$dl_url"`;

	my $app_url;
	my $price;
	my $saleprice;
	
	my @lines = split(/\n/,$get_url);
	foreach my $line (@lines){
#		$line = Jcode->new($line, 'utf8')->sjis;

		if($line =~/(.*)href=\"\/market\/app\/(.*)\/\" title=\"Android(.*)/){

#			$app_url = q{https://market.android.com/details?id=}.$2;
			print "$app_url \n\n";
print "$app_url $price $saleprice \n";
			&_get_app_info($2,$price,$saleprice);
		}


		if($line =~/(.*)<s>約(.*)円<\/s>(.*)<b>(.*)<\/b>/){

			$price = $2;
			$saleprice = $4;
			if($saleprice eq "無料"){
				$saleprice = 0;
			}else{
#				chop $saleprice;
			}
			$saleprice=~s/約//;
			$saleprice=~s/円//;
			$price=~s/\\//;
			$saleprice=~s/\\//;
			$price=~s/￥//;
			$saleprice=~s/￥//;
			$price=~s/\?//;
			$saleprice=~s/\?//;
			$price=~s/,//;
			$saleprice=~s/,//;
		}
	}

	return;
}



sub _get_app_info(){
	my $app_id = shift;
	my $price = shift;
	my $saleprice = shift;
	
#	if($url=~/(.*)app\/(.*)id(.*)/){
#		$url=$1.qq{app/id}.$3;
#	}
	print "$url $price $saleprice \n\n";

	my $date = Date::Simple->new();
	my $ymd = $date->format('%Y%m%d');

	my $dbh = &_db_connect();

	# ログ記録
my $logname = "androwire";
if($ARGV[0] eq 'touchlab'){
	$logname = "touchlab";
}

eval{

	my $sth = $dbh->prepare(qq{update app_android_sale set delflag = 1 where app_id = ? and delflag = 0 });
	$sth->execute($app_id);
	my $sth = $dbh->prepare(qq{insert into app_android_sale (app_id, price, sale_price, datestr, siteinfo) values(?,?,?,?,?)});
	$sth->execute($app_id,$price,$saleprice,$ymd,$logname);

};
	
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
