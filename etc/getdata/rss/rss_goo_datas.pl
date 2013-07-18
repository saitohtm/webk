#!/usr/bin/perl

# http://www.goo.ne.jp/rss/

#use strict;
use DBI;
use Cache::Memcached;
use CGI qw( escape );
use Unicode::Japanese;
use XML::FeedPP;
use XML::Simple;
use LWP::Simple;
use URI::Escape;
use Data::Dumper;
use Date::Simple ('date', 'today');

&_get_rss('http://ranking.goo.ne.jp/rss/keyword/keyrank_male/index.rdf' , 58);
&_get_rss('http://ranking.goo.ne.jp/rss/keyword/keyrank_female/index.rdf' , 57);
&_get_rss('http://tvtopic.goo.ne.jp/ranking/cast/rss.xml' , 88);


# 車
&_get_rss('http://autos.goo.ne.jp/news/technology/index.rdf' , 105);
&_get_rss('http://autos.goo.ne.jp/news/ecocar/index.rdf' , 104);
&_get_rss('http://autos.goo.ne.jp/news/motorsports/index.rdf' , 103);
&_get_rss('http://autos.goo.ne.jp/news/society/index.rdf' , 102);
&_get_rss('http://autos.goo.ne.jp/news/industry/index.rdf' , 101);
&_get_rss('http://autos.goo.ne.jp/news/newcar/index.rdf' , 100);

# TV
&_get_rss('http://tvtopic.goo.ne.jp/ranking/item/rss.xml' , 90);
&_get_rss('http://tvtopic.goo.ne.jp/ranking/topic/rss.xml' , 89);
&_get_rss('http://tvtopic.goo.ne.jp/ranking/cast/rss.xml' , 88);
&_get_rss('http://tvtopic.goo.ne.jp/ranking/program/rss.xml' , 87);

# ランキング
&_get_rss('http://ranking.goo.ne.jp/rss/index.rdf' , 86);


# 映画
&_get_rss('http://music.goo.ne.jp/whatsnew/index.rdf' , 85);
&_get_rss('http://movie.goo.ne.jp/review/newreviews.rdf' , 83);
&_get_rss('http://movie.goo.ne.jp/special/index.rdf' , 82);
# 映画今週公開
&_get_rss('http://movie.goo.ne.jp/schedule/thisweek.rdf' , 81);
# 映画NEWS
&_get_rss('http://movie.goo.ne.jp/news/index.rdf' , 80);

# おしえてぐー
&_get_rss('http://c.oshiete.goo.ne.jp/rss.php' , 70);

# スポーツ
&_get_rss('http://news.goo.ne.jp/rss/topstories/sports/index.rdf' , 68);

# エンタメ
&_get_rss('http://news.goo.ne.jp/rss/topstories/entertainment/index.rdf' , 67);

# 生活術
&_get_rss('http://news.goo.ne.jp/rss/topstories/life/index.rdf' , 66);

# 仕事術
&_get_rss('http://news.goo.ne.jp/rss/topstories/bizskills/index.rdf' , 65);

# 経済
&_get_rss('http://news.goo.ne.jp/rss/topstories/business/index.rdf' , 64);

# 政治
&_get_rss('http://news.goo.ne.jp/rss/topstories/politics/index.rdf' , 63);

# 国際社会
&_get_rss('http://news.goo.ne.jp/rss/topstories/world/index.rdf' , 62);

# 社会
&_get_rss('http://news.goo.ne.jp/rss/topstories/nation/index.rdf' , 61);

# NEWS
&_get_rss('http://news.goo.ne.jp/rss/topstories/gootop/index.rdf' , 60);


# エンタメ
&_get_rss('http://ranking.goo.ne.jp/rss/keyword/keyrank_entame/index.rdf' , 59);

# 男性
&_get_rss('http://ranking.goo.ne.jp/rss/keyword/keyrank_male/index.rdf' , 58);

# 女性検索上昇
&_get_rss('http://ranking.goo.ne.jp/rss/keyword/keyrank_female/index.rdf' , 57);

# 検索上昇
&_get_rss('http://ranking.goo.ne.jp/rss/keyword/keyrank_all1/index.rdf' , 56);

#ウェブ最新キーワード
&_get_rss('http://ranking.goo.ne.jp/rss/keyword/keyrank_web1/index.rdf' , 52);

#ウェブ最新キーワード
&_get_rss('http://search.goo.ne.jp/rss/newkw.rdf' , 51);

# いまトピ
&_get_rss('http://ima.goo.ne.jp/rank.rss' , 50);



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
	print $item."\n";
    my $date = substr($item->pubDate(),0,10);
eval{
    $date = substr($item->date(),0,10) unless($date);
};
unless($date){
    $date = today();
}	
	my $title = $item->title();
	my $description = $item->description();
eval{
	unless($description){
		$description = $item->content();
	}
};
eval{
    my $sth = $dbh->prepare( qq{insert into rssdata_goo ( `type`,`title`,`datestr`,`geturl`,`bodystr`,`img`) values ($flag,?,?,?,?,?)});
    $sth->execute($title, $date, $item->link(), $description,$item->{enclosure}->{-url});
};
print $@;
}

$dbh->disconnect;

return;
}

