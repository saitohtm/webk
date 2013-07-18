#!/usr/bin/perl
use lib qw(/var/www/vhosts/goo.to/etc/lib /var/www/vhosts/goo.to/lib/Waao);

# iphoneの情報をRSS経由で取得

#use strict;
use DBI;
use Unicode::Japanese;
use LWP::UserAgent;
use Jcode;
use XML::Simple;
use LWP::Simple;
use PageAnalyze;
use DataController;

use Date::Simple;

my $dbh = &_db_connect();
my @genres;
my $sth = $dbh->prepare(qq{SELECT id FROM app_category where id >= 6000 order by id desc });
$sth->execute();
while(my @row = $sth->fetchrow_array) {
	push @genres,$row[0];
}

# 登録系
# 新規／無料／新規有料
# newapplications／newfreeapplications/newpaidapplications
# ｘジャンル
# https://itunes.apple.com/jp/rss/newapplications/limit=300/genre=6012/xml
my @regist_str = (newapplications,newfreeapplications,newpaidapplications);
foreach my $regist (@regist_str){
	my $url = qq{https://itunes.apple.com/jp/rss/$regist/limit=300};
	&_all_rss($dbh,$url,\@genres);
}

if($ARGV[0] eq "new"){
	exit;
}


# ランキング
# 無料／有料／セールス
# topfreeapplications/toppaidapplications/topgrossingapplications
# ｘジャンル
# https://itunes.apple.com/jp/rss/topgrossingapplications/limit=300/genre=6012/xml
my @regist_str = (topfreeapplications,toppaidapplications,topgrossingapplications);
my $cnt;
foreach my $regist (@regist_str){
	$cnt++;
	my $url = qq{https://itunes.apple.com/jp/rss/$regist/limit=300};
	&_all_rss_ranking($dbh, $url,$cnt,1,\@genres);
}


# ランキングipad
# 無料／有料／セールス
# topfreeipadapplications/toppaidipadapplications/topgrossingipadapplications
# ｘジャンル
# https://itunes.apple.com/jp/rss/topfreeipadapplications/limit=300/genre=6012/xml
my @regist_str = (topfreeipadapplications,toppaidipadapplications,topgrossingipadapplications);
my $cnt;
foreach my $regist (@regist_str){
	$cnt++;
	my $url = qq{https://itunes.apple.com/jp/rss/$regist/limit=300};
	&_all_rss_ranking($dbh,$url,$cnt,2,\@genres);
}

$dbh->disconnect;
exit;

sub _all_rss(){
	my $dbh = shift;
	my $url = shift;
	my $genres = shift;
	my $all_url = $url."/xml";
print $all_url."\n";
	&_install_rss($dbh,$all_url);
	foreach my $genre (@{$genres}){
		my $genre_url = qq{$url/genre=$genre/xml};
		print $genre_url."\n";
# やめる
#		&_install_rss($dbh,$genre_url);
	}
	return;
}

sub _install_rss(){
	my $dbh = shift;
	my $url = shift;

print "INS $url \n";
	my $response = get($url);	
print "INS $response \n";
	my $xml = new XML::Simple;
	my $xml_val = $xml->XMLin($response);
	
	foreach my $app_info (@{$xml_val->{entry}}){
		my $a = qq{im:id};
		my $app_id = $app_info->{id}->{$a};
print "INS $app_id \n";
		my $data = &itunes_page_lookup($app_id);
		&app_iphone_data($dbh, $data);
	}

	return;
}

sub _all_rss_ranking(){
	my $dbh = shift;
	my $url = shift;
	my $ranktype = shift;
	my $type = shift;
	my $genres = shift;

	my $all_url = $url."/xml";
print $all_url."\n";
	&_ins_ranking($dbh,$all_url,$ranktype,$type,0);
	foreach my $genre (@{$genres}){
		my $genre_url = qq{$url/genre=$genre/xml};
		print $genre_url."\n";
		&_ins_ranking($dbh,$genre_url,$ranktype,$type,$genre);
	}


	return;
}

sub _ins_ranking(){
	my $dbh = shift;
	my $url = shift;
	my $ranktype = shift;
	my $type = shift;
	my $genre = shift;

	my $table = qq{app_iphone_rank};
	$table = qq{app_ipad_rank} if($type eq 2);

print $url."\n";
	my $response = get($url);	
	my $xml;
	my $xml_val;
eval{
	$xml = new XML::Simple;
	$xml_val = $xml->XMLin($response);
};	
	my $rank_no;
	foreach my $app_info (@{$xml_val->{entry}}){
		$rank_no++;
		my $a = qq{im:id};
		my $app_id = $app_info->{id}->{$a};
print "RANK $app_id \n";
		# データの確認
		my $check_flag;
		my $sth = $dbh->prepare(qq{SELECT id FROM app_iphone where id = ? limit 1 });
		$sth->execute($app_id);
		while(my @row = $sth->fetchrow_array) {
			$check_flag = 1;
		}

		unless($check_flag){
			my $data = &itunes_page_lookup($app_id);
			&app_iphone_data($dbh, $data);
		}
		
		# データ登録
		my $date = Date::Simple->new();
		my $ymd = $date->format('%Y-%m-%d');
eval{
my $sth = $dbh->prepare(qq{insert into $table ( `app_id`,`type`,`genre`,`rankdate`,`rankno`) values (?,?,?,?,?)} );
$sth->execute($app_id,$ranktype,$genre,$ymd,$rank_no);
}
		
	}

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
