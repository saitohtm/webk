package Waao::Pages::SMF;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Html5;
use Waao::Data;
use Waao::Utility;

sub dispatch(){
	my $self = shift;

	my $a = 'スマフォMAX (アプリ/ドコモ/au/iphone/アンドロイド情報) -スマフォMAX-';
	$self->{html_title} = qq{$a};
	my $b = 'スマフォ,スマートフォン,アプリ,ドコモ,au,iphone,アンドロイド';
	$self->{html_keywords} = qq{$b};
	my $c = 'スマフォMAXは、スマフォサイトを集めて、みんなで評価するから優良スマフォサイトが一発で検索できます';
	$self->{html_description} = qq{$c};
	my $geinou = &html_mojibake_str("geinou");

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1, maximum-scale=1"/>
<meta name="format-detection" content="telephone=no" />
<link rel="apple-touch-icon" href="http://s.waao.jp/img/home.png" />
<link rel="stylesheet" href="/css/smf.css" />

<link rel="stylesheet" href="/jquery.mobile-1.0.1.min.css" />
<script type="text/javascript" src="/jquery-1.6.4.js"></script>
<script type="text/javascript" src="/jquery.mobile-1.0.1.min.js"></script>

<script type="text/javascript" src="/my.js"></script>
<meta name="keyword" content="$self->{html_keywords}" xml:lang="ja" lang="ja"/>
<meta name="description" content="$self->{html_description}" xml:lang="ja" lang="ja"/>
<meta name="title" content="$self->{html_title}" xml:lang="ja" lang="ja"/>
<meta name="google-site-verification" content="cxJSvOw2PI0z0sXEEx3KDvT3mvpKq8CP7PE1Ge1zPgs" />
<title>$self->{html_title}</title>
</head>
<body>
<div id="home" data-role="page">
END_OF_HTML
	
	# トピックス
	my $persons = &_get_rss_data_person($self);
	my $topics = &_get_rss_data($self, 3);
	
print << "END_OF_HTML";
<div id="header">
<h1><a href="/" style="display: block;"><img src="/img/smftop.jpg" width=100% alt="スマフォMAX"></a></h1>
</div>
<table border="0" width=100%><tr><td BGCOLOR="#FFFFFF">
<a href="/search/" data-role="button" data-icon="search" data-inline="true">検索</a>
<a href="/tv.htm" data-role="button" data-icon="alert" data-inline="true">TV番組</a>
<a href="/tv.htm" data-role="button" data-icon="alert" data-inline="true">あ</a>
</td></tr></table>
<ul data-role="listview">
<li><a href="/earth.htm">首都圏版運行状況と空気汚染情報</a></li>
<li><img src="/img/blog.jpg" height="25" class="ui-li-icon" data-transition="slide"><a href="/blog/" >$geinou人ブログ</a></li>
<li><img src="/img/twitter.png" height="25" class="ui-li-icon"><a href="/twitter/">有名人ツイッター</a></li>
</ul>

<div data-role="header">
<h2>今話題になっている人物</h2>
</div>

<div data-role="content">
<ul data-role="listview">
$persons
<li><a href="/person.htm">大人気！人物名鑑でもっと探す</a></li>
<li><a href="/pop-0/">今人気な人物一覧</a></li>
</ul>
</div>

<div data-role="header">
<h2>今話題になっている事</h2>
</div>

<div data-role="content">
<ul data-role="listview">
$topics
</ul>
</div>

<div data-role="header">
<h2>オススメスマフォサイト</h2>
</div>

<div data-role="content">
<ul data-role="listview">
<li><a href="/sitelist/"><img src="/img/ol01s.gif" height="25" class="ui-li-icon"> カテゴリ別に探す</a></li>
<li><img src="/img/yahoo.png" height="25" class="ui-li-icon"><a href="http://ipn.yahoo.co.jp/" rel=nofollow target="_blank">Yahoo!</a></li>
<li><img src="/img/google.png" height="25" class="ui-li-icon"><a href="http://google.co.jp/" rel=nofollow target="_blank">google</a></li>
<li><img src="/img/goo.png" height="25" class="ui-li-icon"><a href="http://goo.ne.jp/" rel=nofollow target="_blank">goo</a></li>
<li><img src="/img/naver.png" height="25" class="ui-li-icon"><a href="http://ipn.naver.jp/" rel=nofollow target="_blank">NAVER</a></li>
<li><img src="/img/livedoor.png" height="25" class="ui-li-icon"><a href="http://www.livedoor.com/lite/" rel=nofollow target="_blank">LiveDoor</a></li>
<li><img src="/img/ana.png" height="25" class="ui-li-icon"><a href="http://rps.ana.co.jp/web/top.php" rel=nofollow target="_blank">ANA</a></li>
<li><img src="/img/amazon.jpg" height="25" class="ui-li-icon"><a href="http://www.amazon.com/" rel=nofollow target="_blank">amazon</a></li>
<li><img src="/img/zip.jpg" height="25" class="ui-li-icon"><a href="/zip.htm" target="_blank">郵便番号検索</a></li>
<li><img src="/img/c5.gif" height="25" class="ui-li-icon"><a href="/regist.html">サイト登録</a></li>
</ul>
</div>
<p>スマフォナビは、スマートフォンに最適化された優良サイトのみを厳選して登録したスマートフォン専用の検索サイトです</p>
END_OF_HTML
	
&html_footer($self);

	return;
}

sub _get_rss_data_person(){
	my $self = shift;

	my $str;
	my $limitcnt = 5;
	my 	$sth = $self->{dbi}->prepare(qq{ select id, title, bodystr, datestr, type, geturl, ext from rssdata where type = ? order by datestr desc,id limit $limitcnt} );
	$sth->execute(6);
	my $cnt;
	while(my @row = $sth->fetchrow_array) {
		my ($datacnt, $keyworddata) = &get_keyword($self, $row[1]);
		my ($photodatacnt, $photodata) = &get_photo($self, $keyworddata->{id});
		$str.=qq{<li><img src="$photodata->{url}" height="25" width="25" class="ui-li-icon"><a href="/person$keyworddata->{id}/">$row[1]</a></li>};
		next if($row[2] eq "utf8");
	}

	return $str;
}

sub _get_rss_data(){
	my $self = shift;
	my $type = shift;

	my $str;
	my 	$sth = $self->{dbi}->prepare(qq{ select id, title, bodystr, datestr, type, geturl, ext from rssdata where type = ? and datestr >= ADDDATE(CURRENT_DATE,INTERVAL -1 DAY) order by datestr desc,id limit 10} );
	$sth->execute($type);
	my $cnt;
	while(my @row = $sth->fetchrow_array) {
		$cnt++;
		$str.=qq{<li>【$row[1]】<br>};
		next if($type eq 1);
		next if($row[2] eq "utf8");
		$row[2] =~s/border=\"0\" align=\"left\" hspace=\"5\"\>/\>\<br>/;
		$str.=qq{$row[2]</li>};
	}
	unless($cnt){
		my $limitcnt = 5;
		my 	$sth = $self->{dbi}->prepare(qq{ select id, title, bodystr, datestr, type, geturl, ext from rssdata where type = ? order by datestr desc,id limit $limitcnt} );
		$sth->execute($type);
		my $cnt;
		while(my @row = $sth->fetchrow_array) {
			$str.=qq{<li>【$row[1]】<br>};
			next if($type eq 1);
			next if($row[2] eq "utf8");
			$row[2] =~s/border=\"0\" align=\"left\" hspace=\"5\"\>/\>\<br>/;
			$str.=qq{$row[2]</li>};
		}
	}

	return $str;
}
1;