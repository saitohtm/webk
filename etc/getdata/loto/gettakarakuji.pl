#!/usr/bin/perl
# http://www.mizuhobank.co.jp/index.html からデータを取得するプログラム

#use strict;
use DBI;
use Unicode::Japanese;
use LWP::UserAgent;
use Jcode;

use Date::Simple ('date', 'today');

my $dsn = 'DBI:mysql:waao';
my $user = 'mysqlweb';
my $password = 'WaAoqzxe7h6yyHz';

# 全国
&_get_real('http://www.mizuhobank.co.jp/takarakuji/tsujyo/zenkoku/index.html' ,1);
# 地域
&_get_real('http://www.mizuhobank.co.jp/takarakuji/tsujyo/chiiki/index.html' ,2);
# 東京
&_get_real('http://www.mizuhobank.co.jp/takarakuji/tsujyo/tokyo/index.html' ,3);
# 関東
&_get_real('http://www.mizuhobank.co.jp/takarakuji/tsujyo/kct/index.html' ,4);
# 近畿
&_get_real('http://www.mizuhobank.co.jp/takarakuji/tsujyo/kinki/index.html' ,5);
# 西日本
&_get_real('http://www.mizuhobank.co.jp/takarakuji/tsujyo/nishinihon/index.html' ,6);


sub _get_real(){
	my $url = shift;
	my $type = shift;

	my $get_url = `GET $url`;
#print "$url\n";
	my @lines = split(/\n/,$get_url);
	my $loto_date;
	foreach my $line (@lines){
#		$line = Jcode->new($line, 'utf8')->sjis;
		if($line=~/<td class=\"noBorderL left\">(.*)年(.*)月(.*)日<\/th>/){
			$loto_date = $1.qq{-}.$2.qq{-}.$3;
		}
		if($line=~/<td class=\"left\"><a href=\"(.*)\" tabindex=(.*)/){
			&_get_data($1,$type,$loto_date);
		}
	}

	return;
}

sub _get_data(){
	my $url = shift;
	my $type = shift;
	my $loto_date = shift;
	$url = qq{http://www.mizuhobank.co.jp}.$url;

#print "2st: $url\n";

	my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 1, AutoCommit => 0});
	my $get_url = `GET $url`;

    # 取得データ
	my $id;
	my $name;
	my @vals;

	my @lines = split(/\n/,$get_url);
	foreach my $line (@lines){
#		$line = Jcode->new($line, 'utf8')->sjis;

		if($line=~/<h2 class=\"h2Tit\"><span>第(.*)回(.*)<\/span><\/h2>/){
			$id = $1;
			$name = $2;
			# DB 登録
#print "DB: $id $name $loto_date \n";
eval{
my $sth = $dbh->prepare(qq{insert into loto_jumbo ( `id`,`area`,`name`,`date_loto`) values (?,?,?,?)});
$sth->execute($id,$type,$name,$loto_date);
};
		}
		
		if($line=~/<td>(.*)<\/td>/){
#print "id::$1\n";
			push (@vals,$1);
		}
		if($line=~/<td class=(.*)>(.*)<\/td>/){
#print "val::$2\n";
			push (@vals,$2);
		}
		if($line=~/<\/tr>/){
eval{
#print "vals::$vals[1] $vals[2] $vals[3] $vals[4] \n";
my $sth = $dbh->prepare(qq{insert into loto_kuji ( `loto_id`,`ranking`,`price`,`kumi`,`no`) values (?,?,?,?,?)});
$sth->execute($id,$vals[1],$vals[2],$vals[3],$vals[4]);
};
			@vals = undef;
		}


	}

	$dbh->disconnect;
	return;
}


exit;