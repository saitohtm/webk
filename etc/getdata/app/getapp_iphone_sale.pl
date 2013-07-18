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

# app_bank
&_app_bank(); 

# osuban.jp
&_osuban();

# catch app
&_catch_app(1);
&_catch_app(2);
&_catch_app(3);

# セール終了チェック

exit;
sub _catch_app(){
	my $page = shift;

	my $dl_url = qq{http://catchapp.net/item/search/genre/all?p=$page&dc=1&sort=pc};
	my $cmd = qq{$dl_url};
	print "$cmd _catch_app \n";
	sleep 1;

	my $get_url = `GET "$cmd"`;

	my @lines = split(/\n/,$get_url);
	my $flag=0;
	my $url;
	my $price;
	my $saleprice;
	my $cnt;
	foreach my $line (@lines){
#		$line = Jcode->new($line, 'utf8')->sjis;
		if($line =~/(.*)<a class=\"app_name_a\" href=\"\/item\/detail\/(.*)\">(.*)<\/a(.*)/){
			$app_id = $2;
			$url = qq{https://itunes.apple.com/jp/app/id$app_id};
		}
		my $tmp = q{style="text-decoration:line-through;"};
		if($line =~/(.*)$tmp>(.*)<\/span>(.*)<img(.*)/){
			$price = $2;
			$saleprice = $3;
			$price =~s/,//g;
			$price =~s/\\//g;
			$price =~s/\?//g;

			$saleprice =~s/\\//g;
			$saleprice =~s/ //g;
			$saleprice =~s/\?//g;
			if($saleprice eq "無料"){
				$saleprice = 0;
			}
			$cnt++;
print "_catch_app $url $price → $saleprice \n";
				&_get_app_info($url,$price,$saleprice,"catch_app");
			last if($cnt >= 20);
		}
	}

	return;
}

sub _osuban(){

	my $dl_url = qq{http://osuban.jp/sale/?p=24};
	my $cmd = qq{$dl_url};
	print "$cmd _osuban \n";
	sleep 1;

	my $get_url = `GET "$cmd"`;

	my @lines = split(/\n/,$get_url);
	my $flag=0;
	my $url;
	my $price;
	my $saleprice;
	foreach my $line (@lines){
#		$line = Jcode->new($line, 'utf8')->sjis;
		if($line =~/<td class=\"icon\"><a href=\"(.*)\?mt=8\"><img(.*)/){
			$url = $1;
			$flag = 1;
		}
		if($flag eq 1){
			if($line =~/<td class=\"price\">(.*)<\/td>/){
				$price = $1;
				$price =~s/,//g;
				$flag = 2;
			}
		}elsif($flag eq 2){
			if($line =~/<td class=\"price\">(.*)<\/td>/){
				$saleprice = $1;
				my $tmp = q{&yen;};
				
				$saleprice =~s/$tmp//g;
				if($saleprice eq "無料"){
					$saleprice = 0;
				}
				$flag = 0;
print "osuban $url $price → $saleprice \n";
				&_get_app_info($url,$price,$saleprice,"osuban");
			}
		}
	}

	return;
}

sub _app_bank(){

	my $dl_url = qq{http://www.appbank.net/category/sale};
	my $cmd = qq{$dl_url};
	print "$cmd _app_bank \n";
	sleep 1;

	my $get_url = `GET "$cmd"`;

	my $date = Date::Simple->new();
	my $ymd = $date->format('%Y%m%d');
	$ymd = substr($ymd,2,6)."sale";

	$ymd = $ARGV[0] if($ARGV[0]);
print "$ymd\n";

	my @lines = split(/\n/,$get_url);
	foreach my $line (@lines){
		if($line =~/$ymd/){
			if($line =~/<a href=\"(.*)\"><img/ ){
#print "$1 \n";
				&_app_bank_detail($1);
			}
		}
	}

	return;
}

sub _app_bank_detail(){
	my $detail_url = shift;

	print "$detail_url _app_bank_detail \n";

	my $get_url = `GET "$detail_url"`;

	my $app_url;
	my $price;
	my $saleprice;
	
	my @lines = split(/\n/,$get_url);
	foreach my $line (@lines){
#		$line = Jcode->new($line, 'utf8')->sjis;
		if($line =~/(.*)itunes(.*)%3Fmt(.*)itunes(.*)/){
#			print "$2 \n\n";
			$app_url = q{http://itunes}.$2;
			$app_url = uri_unescape( $app_url ); 
		}
		my $a=q{。};
		my $b=q{円→};
		if($line =~/(.*)$a(.*)$b(.*)$a<\/p>/){
			$price = $2;
			$saleprice = $3;
			if($3 eq "無料"){
				$saleprice = 0;
			}else{
				chop $saleprice;
			}
			
			&_get_app_info($app_url,$price,$saleprice);
		}
	}

	return;
}

sub _get_app_info(){
	my $url = shift;
	my $price = shift;
	my $saleprice = shift;
	my $sitename = shift;
	
	$sitename = qq{appbank} unless($sitename);

	my $app_id;	
	if($url=~/(.*)app\/(.*)id(.*)/){
		$app_id = $3;
	}
	print "$app_id $price $saleprice \n\n";

	my $date = Date::Simple->new();
	my $ymd = $date->format('%Y%m%d');

	my $dbh = &_db_connect();

	my $data = &itunes_page_lookup($app_id);
	&app_iphone_data($dbh, $data);

eval{
	my $sth = $dbh->prepare(qq{update app_iphone_sale set delflag = 1 where app_id = ? and delflag = 0 });
	$sth->execute($app_id);
	my $sth = $dbh->prepare(qq{insert into app_iphone_sale (app_id, price, sale_price, datestr, siteinfo) values(?,?,?,?,?)});
	$sth->execute($app_id,$price,$saleprice,$ymd,$sitename);
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
