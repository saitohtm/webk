package Waao::Pages::PopWord;
use strict;
use base qw(Waao::Pages::Base);
use Waao::Html;
use Waao::Data;
use Waao::Utility;

# 人気ワードを表示するページ
# /popword/
# /list-popword/popword/pageno/

sub dispatch(){
	my $self = shift;

	if($self->{cgi}->param('p1')){
		&_keyword_rank($self);
	}else{
		&_top($self);
	}
	return;
}
sub _top(){
	my $self = shift;

	$self->{html_title} = qq{今話題の有名人 $self->{date_yyyy_mm_dd}};
	$self->{html_keywords} = qq{有名人,人気,話題,キーワード,検索};
	$self->{html_description} = qq{ディリー今話題になっている有名人/タレントはこの人だ！毎日変っちゃうからお見逃し無く};

	my $hr = &html_hr($self,1);	
	&html_header($self);

	my $ad = &html_google_ad($self);

if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML
	
}elsif($self->{access_type} eq 4){

&html_table($self, qq{<h1>今話題の<font color="#FF0000">有名人</font></h1>}, 1, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
今、<font color="#FF0000">話題</font>になっている<strong>有名人</strong>は、この人炻
<center>
<img src="http://img.waao.jp/kaow03.gif" width=84 height=15>
</center>
END_OF_HTML


my $memkey = "trendperson";
my $today_trend;
$today_trend = $self->{mem}->get( $memkey );

if($today_trend){
	my $cnt = 0;
	foreach my $keyword (@{$today_trend->{rank}}){
		$cnt++;
		my $str_encode = &str_encode($keyword);
print << "END_OF_HTML";
寀<a href="/$str_encode/search/">$keyword</a><br>
END_OF_HTML
	}
}
print << "END_OF_HTML";
$hr
END_OF_HTML


&html_table($self, qq{<font color="#FF0000">人気</font>検索キーワード}, 0, 0);
my $sth = $self->{dbi}->prepare(qq{ select id, keyword from keyword order by cnt desc limit 10} );
$sth->execute();
while(my @row = $sth->fetchrow_array) {
		my $str_encode = &str_encode($row[1]);
print << "END_OF_HTML";
<a href="/$str_encode/search/">$row[1]</a><br>
END_OF_HTML
}

print << "END_OF_HTML";
<div align=right><img src="http://img.waao.jp/m2028.gif" width=48 height=9 ><a href="/list-rank/popword/1/" accesskey="#">人気ワードを見る</a>(#)</div>
$hr
<a href="/news/" accesskey=1>話題の最新ニュース</a><br>
<a href="/shopping/" accesskey=2>話題の売れ筋商品</a><br>
<a href="/car/" accesskey=3>新車・中古車検索</a><br>
<a href="/uta/" accesskey=4>着うた検索</a><br>
<a href="/photo/" accesskey=5>画像検索</a><br>
<!--
<a href="http://r.smaf.jp/_rotate_ad?m=408004&c=50&fg=&bg=ffffff&hr=008000" accesskey=6>占い検索</a><br>
<a href="" accesskey=7></a>Comming Soon<br>
<a href="" accesskey=8></a>Comming Soon<br>
<a href="/waao/" accesskey=9>Waao餅杣洽個</a><br>
-->
$hr
偂<a href="http://waao.jp/list-in/ranking/14/">みんなのランキング</a><br>
<a href="/" accesskey=0>トップ</a>&gt;<strong>話題の有名人</strong><br>
<font size=1 color="#AAAAAA">話題の有名人・タレント㌻は、検索数を元に今、まさに話題となっている有名人やタレント情報を提供しています。<br>
<a href="http://developer.yahoo.co.jp/about">Webサービス by Yahoo! JAPAN</a>
END_OF_HTML

}else{
# xhmlt chtml

&html_table($self, qq{<h1>今話題の<font color="#FF0000">有名人</font>棈</h1>}, 1, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
<img src="http://img.waao.jp/mini050.gif" width=18 height=8>今、<font color="#FF0000">話題</font>になっている<strong>有名人</strong>は、この人炻
<center>
<img src="http://img.waao.jp/kaow03.gif" width=84 height=15>
</center>
END_OF_HTML


my $memkey = "trendperson";
my $today_trend;
$today_trend = $self->{mem}->get( $memkey );

if($today_trend){
	my $cnt = 0;
	foreach my $keyword (@{$today_trend->{rank}}){
		$cnt++;
		my $str_encode = &str_encode($keyword);
print << "END_OF_HTML";
寀<a href="/$str_encode/search/">$keyword</a><br>
END_OF_HTML
	}
}
print << "END_OF_HTML";
$hr
END_OF_HTML


&html_table($self, qq{<font color="#FF0000">人気</font>検索キーワード}, 0, 0);
my $sth = $self->{dbi}->prepare(qq{ select id, keyword from keyword order by cnt desc limit 10} );
$sth->execute();
while(my @row = $sth->fetchrow_array) {
		my $str_encode = &str_encode($row[1]);
print << "END_OF_HTML";
<a href="/$str_encode/search/">$row[1]</a><br>
END_OF_HTML
}

print << "END_OF_HTML";
<div align=right><img src="http://img.waao.jp/m2028.gif" width=48 height=9 ><a href="/list-rank/popword/1/" accesskey="#">人気ワードを見る</a>(#)</div>
$hr
<img src="http://img.waao.jp/mb17.gif" width=11 height=12><a href="/meikan/">人物名鑑プラス</a><br>
<a href="/news/" accesskey=1>話題の最新ニュース</a><br>
<a href="/shopping/" accesskey=2>話題の売れ筋商品</a><br>
<a href="/car/" accesskey=3>新車・中古車検索</a><br>
<a href="/uta/" accesskey=4>着うた検索</a><br>
<a href="/photo/" accesskey=5>画像検索</a><br>
<!--
<a href="http://r.smaf.jp/_rotate_ad?m=408004&c=50&fg=&bg=ffffff&hr=008000" accesskey=6>占い検索</a><br>
<a href="" accesskey=7></a>Comming Soon<br>
<a href="" accesskey=8></a>Comming Soon<br>
<a href="/waao/" accesskey=9>Waao餅杣洽個</a><br>
-->
$hr
偂<a href="http://waao.jp/list-in/ranking/14/">みんなのランキング</a><br>
<a href="/" accesskey=0>トップ</a>&gt;<strong>話題の有名人</strong><br>
<font size=1 color="#AAAAAA">話題の有名人・タレント㌻は、検索数を元に今、まさに話題となっている有名人やタレント情報を提供しています。<br>
<a href="http://developer.yahoo.co.jp/about">Webサービス by Yahoo! JAPAN</a>
END_OF_HTML

}
	
	&html_footer($self);
	
	return;
}

sub _keyword_rank(){
	my $self = shift;
	my $page = $self->{cgi}->param('p1');
	
	$self->{html_title} = qq{人気検索 $page㌻ $self->{date_yyyy_mm_dd}};
	$self->{html_keywords} = qq{有名人,人気,話題,キーワード,検索};
	$self->{html_description} = qq{ディリー今もっとも検索されている有名人/タレントはこの人だ！毎日変っちゃうからお見逃し無く};

	my $hr = &html_hr($self,1);	
	&html_header($self);

	my $ad = &html_google_ad($self);

if($self->{access_type} eq 4){

&html_table($self, qq{<h1>人気<font color="#FF0000">検索キーワード</font></h1>}, 1, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

	# ページ制御
	my $limit_s = 0;
	my $limit = 10;
	if( $page > 1 ){
		$limit_s = $limit * $page;
	}else{
		$page=1;
	}
	my $next_page = $page + 1;
	my $sth = $self->{dbi}->prepare(qq{ select id, keyword, cnt, simplewiki from keyword order by cnt desc limit $limit_s, $limit} );
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my $photourl;
		my $str_encode = &str_encode($row[1]);
		my $wiki;
		if($row[3]){
			my $wikistr = $row[3];
			$wikistr =~ s/<.*?>//g;
			$wiki = substr($wikistr,0,256);
		}
		my $sth2 = $self->{dbi}->prepare(qq{ select id, url, key1, key2, key3, key4, key5, good, bad, backurl, yahoo, fullurl from photo where keywordid = ? order by good desc limit 1} );
		$sth2->execute( $row[0] );
		while(my @row2 = $sth2->fetchrow_array) {
			$photourl = $row2[1];
		}

print << "END_OF_HTML";
<a href="/$str_encode/search/"><img src="$photourl"  width=125  style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"></a><a href="/$str_encode/search/">$row[1]</a><br>
<font color="#5F5F5F">$wiki </font>...
<br clear="all" />
$hr
END_OF_HTML

	}
	
print << "END_OF_HTML";
<div align=right><img src="http://img.waao.jp/m2028.gif" width=48 height=9 ><a href="/list-rank/popword/$next_page/" accesskey="#">次の人気ワードを見る</a>(#)</div>
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/popword/">話題の有名人</a>&gt;<strong>検索キーワード</strong><br>
<font size=1 color="#AAAAAA">話題の有名人・タレント㌻は、検索数を元に今、まさに話題となっている有名人やタレント情報を提供しています。<br>
END_OF_HTML

}else{

&html_table($self, qq{<h1>人気<font color="#FF0000">検索キーワード</font></h1>}, 1, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
<font size=1>
END_OF_HTML

	# ページ制御
	my $limit_s = 0;
	my $limit = 10;
	if( $page > 1 ){
		$limit_s = $limit * $page;
	}else{
		$page=1;
	}
	my $next_page = $page + 1;
	my $sth = $self->{dbi}->prepare(qq{ select id, keyword, cnt, simplewiki from keyword order by cnt desc limit $limit_s, $limit} );
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my $str_encode = &str_encode($row[1]);
print << "END_OF_HTML";
<a href="/$str_encode/search/">$row[1]</a><br>
END_OF_HTML
		if($row[3]){
			my $wikistr = $row[3];
			$wikistr =~ s/<.*?>//g;
			my $wiki = substr($wikistr,0,128);
print << "END_OF_HTML";
<font color="#5F5F5F">$wiki </font>...<br>
END_OF_HTML
		}
print << "END_OF_HTML";
$hr
END_OF_HTML
	}
print << "END_OF_HTML";
<div align=right><img src="http://img.waao.jp/m2028.gif" width=48 height=9 ><a href="/list-rank/popword/$next_page/" accesskey="#">の人気ワードを見る</a>(#)</div>
</font>
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/popword/">話題の有名人</a>&gt;<strong>検索キーワード</strong><br>
<font size=1 color="#AAAAAA">話題の有名人・タレント㌻は、検索数を元に今、まさに話題となっている有名人やタレント情報を提供しています。<br>
END_OF_HTML
}	
	&html_footer($self);
	return;
}
1;