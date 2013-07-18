#!/usr/bin/perl
# IMG GET取得プログラム

#use strict;
use lib qw(/var/www/vhosts/goo.to/etc/lib /var/www/vhosts/goo.to/lib/Waao);
use DBI;
use Cache::Memcached;
use CGI qw( escape );
use Unicode::Japanese;
use XML::FeedPP;
use XML::Simple;
use LWP::Simple;
use URI::Escape;
use Data::Dumper;
use Jcode;
use utf8;
use encoding 'utf8', 
STDIN=>'utf8', STDOUT=>'utf8';
use Date::Simple ('date', 'today');
use Apis;

# ２重起動防止
if ($$ != `/usr/bin/pgrep -fo $0`) {
print "exit \n";
    exit 1;
}
print "start \n";

#人名検索数ﾗﾝｷﾝｸﾞ
&_get_rss('http://searchranking.yahoo.co.jp/rss/total_ranking-people-rss.xml' , 6);
## kizasi.jp
&_get_rss('http://kizasi.jp/kizapi.py?type=rank' , 1);

## yahoo!RSS
#急上昇
&_get_rss('http://searchranking.yahoo.co.jp/rss/burst_ranking-rss.xml' , 2);
#今がわかる急上昇ワード5
&_get_rss('http://searchranking.yahoo.co.jp/rss/word5-rss.xml' , 3);
#ただいま、検索急上昇中
&_get_rss('http://searchranking.yahoo.co.jp/rss/rt_ranking-rss.xml' , 4);
#検索数ﾗﾝｷﾝｸﾞ
&_get_rss('http://searchranking.yahoo.co.jp/rss/total_ranking-general-rss.xml' , 5);
#テレビ検索数ﾗﾝｷﾝｸﾞ
&_get_rss('http://searchranking.yahoo.co.jp/rss/total_ranking-tv-rss.xml' , 7);
#ゲーム・アニメ検索数ﾗﾝｷﾝｸﾞ
&_get_rss('http://searchranking.yahoo.co.jp/rss/total_ranking-game_and_animation-rss.xml' , 8);
#スポーツ検索数ﾗﾝｷﾝｸﾞ
&_get_rss('http://searchranking.yahoo.co.jp/rss/total_ranking-sports-rss.xml' , 9);
#ﾄﾚﾝﾄﾞｻｰﾌｨﾝ検索数ﾗﾝｷﾝｸﾞ
&_get_rss('http://searchranking.yahoo.co.jp/rss/trend-rss.xml' , 10);

## allabout
&_get_rss('http://feeds.feedburner.jp/allabout/all' , 11);

## はてぶ
&_get_rss('http://feeds.feedburner.com/hatena/b/hotentry' , 12);

## R25
&_get_rss('http://r25.yahoo.co.jp/rss/' , 13);


exit;

sub _get_rss(){
my $source = shift;
my $flag = shift;

my $dsn = 'DBI:mysql:waao';
my $user = 'mysqlweb';
my $password = 'WaAoqzxe7h6yyHz';

my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 1, AutoCommit => 0});

print $source."\n";
my $feed = XML::FeedPP->new( $source );
foreach my $item ( $feed->get_item() ) {
    my $date = substr($item->pubDate(),0,10);
    $date = substr($item->date(),0,10) unless($date);
	my $title = $item->title();
	my $description = $item->description();
eval{
	unless($description){
		$description = $item->content();
	}
};
eval{
    my $sth = $dbh->prepare( qq{insert into rssdata ( `type`,`title`,`datestr`,`geturl`,`bodystr`) values ($flag,?,?,?,?)});
    $sth->execute($title, $date, $item->link(), $description);
};

if($flag eq 6){
	&get_photo($dbh,$title);
	&get_qanda($dbh,$title);
	&get_news($dbh,$title);
}

}



$dbh->disconnect;


return;
}

