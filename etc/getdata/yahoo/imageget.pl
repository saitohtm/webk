#!/usr/bin/perl
# IMG GET取得プログラム
# 2013.3 まで 24/ 1000リクエスト
#use strict;
use DBI;
use CGI qw( escape );
use Unicode::Japanese;
use LWP::UserAgent;
use Jcode;
use XML::Simple;
use LWP::Simple;
use URI::Escape;

my $dsn = 'DBI:mysql:waao';
my $user = 'mysqlweb';
my $password = 'WaAoqzxe7h6yyHz';

my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 1, AutoCommit => 0});

my $sth = $dbh->prepare( qq{select cnt from photo_upd limit 1} );
$sth->execute();
my $maxid;
while(my @row = $sth->fetchrow_array) {
	$maxid = $row[0];
}
my $start = $maxid * 950;
print "START : $start \n";
$sth = $dbh->prepare( qq{select id, keyword from keyword where person=1 order by cnt desc limit $start,950} );
$sth->execute();
my $request_cnt;
while(my @row = $sth->fetchrow_array) {
	$request_cnt++;
	print "$row[0]\n";
	# yahoo
	&_yahoo($dbh,$row[0],$row[1]);
	# flickr
#	&_flickr($dbh,$row[0],$row[1]);
	sleep 1;
}

if($request_cnt<950){
	my $sth = $dbh->prepare(qq{ update photo_upd set cnt = 0 limit 1} );
	$sth->execute();
}else{
	my $sth = $dbh->prepare(qq{ update photo_upd set cnt = cnt + 1 limit 1} );
	$sth->execute();
}
exit;

# 最新1000件
$sth = $dbh->prepare( qq{select id, keyword from keyword order by updated desc limit 1000} );
$sth->execute();
while(my @row = $sth->fetchrow_array) {
	print "$row[0]\n";
	# yahoo
	&_yahoo($dbh,$row[0],$row[1]);
	# flickr
#	&_flickr($dbh,$row[0],$row[1]);
	sleep 1;
}

# 画像削除
$sth = $dbh->prepare( qq{delete from photo where good < 0 limit 1000} );
$sth->execute();

$dbh->disconnect;

exit;

sub _yahoo(){
	my $dbh = shift;
	my $id = shift;
	my $keyword = shift;
	my $keyword_utf8 = $keyword;
#	Encode::from_to($keyword_utf8,'cp932','utf8');
#	$keyword_utf8 = escape ( $keyword_utf8 );

eval{
#	my $api_url = qq{http://search.yahooapis.jp/ImageSearchService/V1/imageSearch?appid=goooooto&query=$keyword_utf8&results=30&adult_ok=1&start=1};
#	my $api_url = qq{http://search.yahooapis.jp/ImageSearchService/V2/imageSearch?appid=goooooto&query=$keyword_utf8&results=20&adult_ok=1&start=1};
	my $api_url = qq{http://search.yahooapis.jp/PremiumImageSearchService/V1/imageSearch?appid=uipkcOmxg67yZjQwsgL3Grbxt0Xikum3p5kmYx6EzJMZO703ufgCqy6vB_DkY4rdZnFc3mY-&query=$keyword_utf8&results=20&adult_ok=1&start=1};
	print "$api_url\n";
    my $response = get($api_url);
	my $xml = new XML::Simple;
	my $yahoo_xml = $xml->XMLin($response);
	foreach my $result (@{$yahoo_xml->{Result}}) {
		my $url = $result->{Thumbnail}->{Url};
		my $urlm = $result->{Url};
		my $back_url = $result->{RefererUrl};
		my $title = $result->{Title};
		my $summary = $result->{Summary};
		my $width = $result->{Width};
		my $height = $result->{Height};

		my $sth = $dbh->prepare( qq{select id from photo where url=? limit 1} );
		$sth->execute($url);
		my $photo_id;
		while(my @row = $sth->fetchrow_array) {
			$photo_id = $row[0];
		}
		
		if($photo_id){
			my $sth2 = $dbh->prepare(qq{ update photo set keywordid=?,url=?,keyword=?,yahoo=1,fit_img_url=?,backurl=?,title=?,summary=?,width=?,height=? where id = ? limit 1} );
			$sth2->execute($id,$url,$keyword,$urlm,$back_url,$title,$summary,$width,$height,$photo_id);
		}else{
			my $sth2 = $dbh->prepare(
	        qq{insert into photo ( `keywordid`,`url`,`keyword`,`yahoo`,`fit_img_url`,`backurl`,`title`,`summary`,`width`,`height` ) values (?,?,?,1,?,?,?,?,?,?)}
			);
			$sth2->execute($id,$url,$keyword,$urlm,$back_url,$title,$summary,$width,$height);
		}
	}
};

	return;
}

sub _flickr(){
	my $dbh = shift;
	my $id = shift;
	my $keyword = shift;
	my $keyword_utf8 = $keyword;
#	Encode::from_to($keyword_utf8,'cp932','utf8');
#	$keyword_utf8 = escape ( $keyword_utf8 );
eval{	
	my $api_url = qq{http://www.flickr.com/services/rest/?method=flickr.photos.search&format=rest&api_key=fe5c28cda2b5d06c5de2041577f4e49a&per_page=30&license=1,2,3,4,5,6&extras=owner_name&text=$keyword_utf8&page=1};
	print "$api_url\n";
    my $response = get($api_url);
	my $xml = new XML::Simple;
	my $flickr_xml = $xml->XMLin($response);
	foreach my $photoid (keys %{$flickr_xml->{photos}->{photo}}) {
		my $url = &_flickr_img_url($photoid, $flickr_xml->{photos}->{photo}->{$photoid}, "s");
		my $urlm = &_flickr_img_url($photoid, $flickr_xml->{photos}->{photo}->{$photoid}, "m");
		my $sth2 = $dbh->prepare(
	        qq{insert into photo ( `keywordid`,`url`,`keyword`,`flickr`,`fit_img_url`,`backurl` ) values (?,?,?,1,?,?)}
			);
		$sth2->execute($id,$url->{photo},$keyword,$urlm->{photo},$url->{link});
	}
};
	return;
}

sub _flickr_img_url(){
	my $id = shift;
	my $val = shift;
	my $size = shift;

	my $farm_id = $val->{"farm"};
	my $server_id = $val->{"server"};
	my $secret = $val->{"secret"};
	my $user_id = $val->{"owner"};
	
	my $url;
	$url->{photo} = qq{http://farm}.$farm_id.qq{.static.flickr.com/}.$server_id.qq{/}.$id.qq{_}.$secret.qq{_}.$size.qq{.jpg};
	$url->{link} = qq{http://www.flickr.com/people/}.$user_id.qq{/};

	return $url;
}

