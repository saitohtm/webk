package Waao::Pages::SMFPhoto;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Html5;
use Waao::Data;
use Waao::Utility;

sub dispatch(){
	my $self = shift;
	
	if($self->{cgi}->param('good')){
		&eva_photo($self,$self->{cgi}->param('id'),1,"");
	}elsif($self->{cgi}->param('bad')){
		&eva_photo($self,$self->{cgi}->param('id'),"",1);
	}
	
	if($self->{cgi}->param('id')){
		&_photo($self);
	}elsif($self->{cgi}->param('all')){
		&_photoall($self);
	}elsif($self->{cgi}->param('keywordid')){
		&_photolist($self);
	}
	
	return;
}

sub _photoall(){
	my $self = shift;
	my $keywordid = $self->{cgi}->param('keywordid');
	
	my ($datacnt, $keyworddata) = &get_keyword($self, "", $self->{cgi}->param('keywordid'));
	my $keyword = $keyworddata->{keyword};
	my $keyword_encode = &str_encode($keyword);
	my $keyword_utf8 = Jcode->new($keyword, 'sjis')->utf8;
	my $keyword_encode_utf8 = &str_encode($keyword_utf8);

	my $photolist;
	my $cnt;
	my $sth = $self->{dbi}->prepare(qq{ select id, good, url, fullurl from photo where keywordid = ? and good >= -100 order by good desc limit 100} );
	$sth->execute($self->{cgi}->param('keywordid'));
	while(my @row = $sth->fetchrow_array) {
		$cnt++;
		$photolist .= qq{<a href="/photoid$row[0]/"><img src="$row[2]" width="115" alt="$keyword画像"></a>};
#		$photolist .= qq{<br>} unless($cnt % 4);
	}

	my $a = "$keyword画像MAX(スマフォに最適な写真と壁紙検索) 一覧 スマフォMAX";
	$self->{html_title} = qq{$a};
	my $b = "$keyword,画像,写真,壁紙,画像一覧";
	$self->{html_keywords} = qq{$b};
	my $c = "$keyword画像MAXは、$keywordの画像が必ず見つかる複合横断画像検索サービスです　一覧";
	$self->{html_description} = qq{$c};
	&html_header($self);

print << "END_OF_HTML";
<div data-role="header"> 
<h1>$keywordの画像</h1> 
</div>
<a href="/">スマフォMAX</a>&gt;<a href="/person$keywordid/">$keyword</a>&gt;<strong>$keyword画像一覧</strong>

<div data-role="content">
<ul data-role="listview">
<li data-role="list-divider">$keyword画像一覧</li>
</ul>
$photolist
<ul data-role="listview">
<li><img src="/img/E00F_20.gif" height="20" class="ui-li-icon"><a href="/person$keywordid/">$keywordとは</a></li>
</ul>
</div>
<img src="/img/E426_20.gif" height="20">$keywordの画像一覧ページは、リンクフリーです<img src="/img/E425_20.gif" height="20"><br>

END_OF_HTML
	
&html_footer($self);

	return;
}

sub _photo(){
	my $self = shift;
	
	my ($photoid, $good, $url, $fullurl, $keywordid);
	my $sth = $self->{dbi}->prepare(qq{ select id, good, url, fullurl, keywordid from photo where id = ? limit 1} );
	$sth->execute($self->{cgi}->param('id'));
	while(my @row = $sth->fetchrow_array) {
		($photoid, $good, $url, $fullurl, $keywordid) = @row;
	}
	my ($datacnt, $keyworddata) = &get_keyword($self, "", $keywordid);
	my $keyword = $keyworddata->{keyword};
	my $keyword_encode = &str_encode($keyword);
	my $keyword_utf8 = Jcode->new($keyword, 'sjis')->utf8;
	my $keyword_encode_utf8 = &str_encode($keyword_utf8);

	my $goodstr;
	if($self->{cgi}->param('good')){
		$goodstr = qq{評価の高い画像};
	}elsif($self->{cgi}->param('bad')){
		$goodstr = qq{評価の低い画像};
	}

	my $a = "$keywordの画像／写真／壁紙 画像ID $photoid $goodstr";
	$self->{html_title} = qq{$a};
	my $b = "$keyword,画像,写真,壁紙";
	$self->{html_keywords} = qq{$b};
	my $c = "$keyword画像は、スマートフォンに最適化された$keywordの画像／写真が探せる便利なサイトです。$keyword画像ID $photoid $goodstr";
	$self->{html_description} = qq{$c};
	&html_header($self);

print << "END_OF_HTML";
<div data-role="header"> 
<h1>$keywordの画像</h1> 
</div>
<a href="/">スマフォMAX</a>&gt;<a href="/person$keywordid/">$keyword</a>&gt;<a href="/photolist$keywordid/">$keyword画像一覧</a>&gt;<strong>$keyword画像</strong>

<div data-role="content">
<ul data-role="listview">
<li data-role="list-divider">$keyword画像</li>
<center>
<a href="$fullurl"><img src="$url" alt="$keyword画像"></a><br>
みんなの評価：<font color="#FF0000">$goodポイント</font><br>
<a href="/goodphoto$photoid/" data-role="button" data-inline="true">Good</a>
<a href="/badphoto$photoid/" data-role="button" data-inline="true">Bad!</a>
</center>
<li><img src="/img/E022_20.gif" height="20" class="ui-li-icon"><a href="http://person.smax.tv/keyword-$keyworddata->{id}/">$keyword PERSONS</a></li>
<li><img src="/img/E008_20.gif" height="20" class="ui-li-icon"><a href="/photolist$keyworddata->{id}/">$keywordの画像一覧</a></li>
<li><img src="/img/E00F_20.gif" height="20" class="ui-li-icon"><a href="/person$keywordid/">$keywordとは</a></li>
<li data-role="list-divider">NAVER 画像検索</li>
<iframe src="http://search.naver.jp/m/image?q=$keyword_encode" height=300 width=300></iframe>
<li><a href="http://image.search.yahoo.co.jp/search?rkf=2&ei=UTF-8&p=$keyword_encode" target="_blank"><font size=1>Yahoo!画像検索</font></a></li>
<li data-role="list-divider">$keyword Yahoo! 画像検索</li>
<iframe src="http://image.search.yahoo.co.jp/search?rkf=2&ei=UTF-8&p=$keyword_encode_utf8" height=300 width=300></iframe>
</ul>
</div>
<img src="/img/E426_20.gif" height="20">$keywordの画像ページは、リンクフリーです<img src="/img/E425_20.gif" height="20"><br>

END_OF_HTML

	
&html_footer($self);

	return;
}

sub _photolist(){
	my $self = shift;
	my $keywordid = $self->{cgi}->param('keywordid');
	my $page = $self->{cgi}->param('page');
	$page=0 unless($page);
	
	my ($datacnt, $keyworddata) = &get_keyword($self, "", $self->{cgi}->param('keywordid'));
	my $keyword = $keyworddata->{keyword};
	my $keyword_encode = &str_encode($keyword);
	my $keyword_utf8 = Jcode->new($keyword, 'sjis')->utf8;
	my $keyword_encode_utf8 = &str_encode($keyword_utf8);

	my $photolist;
	my $cnt;
	my $startpage = $page * 10;
	my $sth = $self->{dbi}->prepare(qq{ select id, good, url, fullurl from photo where keywordid = ? and good >= -100 order by good desc limit $startpage,10} );
	$sth->execute($self->{cgi}->param('keywordid'));
	while(my @row = $sth->fetchrow_array) {
		$cnt++;
		$photolist .= qq{<li><a href="/photoid$row[0]/"><img src="$row[2]" width="115" alt="$keyword画像"><h3>$keywordの画像</h3><p>評価:$row[1]</p></a></li>};
#		$photolist .= qq{<br>} unless($cnt % 4);
	}
	my $pagenext = $page + 1;
	$photolist .= qq{<li><img src="/img/E23C_20.gif" class="ui-li-icon"><a href="/photolist$keywordid-$pagenext/">次へ $keywordの画像 $pagenextページ</a></li>} if($cnt eq 10);
	$photolist .= qq{<li><img src="/img/E326_20_ani.gif" class="ui-li-icon"><a href="/photoall$keywordid/">$keywordの画像 一覧</a></li>};

	my $a = "$keyword画像MAX(スマフォに最適な写真と壁紙検索) $page目 スマフォMAX";
	$self->{html_title} = qq{$a};
	my $b = "$keyword,画像,写真,壁紙,画像一覧";
	$self->{html_keywords} = qq{$b};
	my $c = "$keyword画像MAXは、$keywordの画像が必ず見つかる複合横断画像検索サービスです $page目";
	$self->{html_description} = qq{$c};
	&html_header($self);

print << "END_OF_HTML";
<div data-role="header"> 
<h1>$keywordの画像</h1> 
</div>
<a href="/">スマフォMAX</a>&gt;<a href="/person$keywordid/">$keyword</a>&gt;<strong>$keyword画像一覧</strong>

<div data-role="content">
<ul data-role="listview">
<li data-role="list-divider">$keyword画像一覧</li>
$photolist
<li><img src="/img/E00F_20.gif" height="20" class="ui-li-icon"><a href="/person$keywordid/">$keywordとは</a></li>
<li data-role="list-divider">$keyword NAVER 画像検索</li>
<iframe src="http://search.naver.jp/m/image?q=$keyword_encode" height=300 width=300></iframe>
<li data-role="list-divider">$keyword Yahoo! 画像検索</li>
<iframe src="http://image.search.yahoo.co.jp/search?rkf=2&ei=UTF-8&p=$keyword_encode_utf8" height=300 width=300></iframe>
</ul>
</div>
<img src="/img/E426_20.gif" height="20">$keywordの画像一覧ページは、リンクフリーです<img src="/img/E425_20.gif" height="20"><br>

END_OF_HTML
#<li data-role="list-divider">$keyword Google 画像検索</li>
#<iframe src="http://www.google.co.jp/m?site=images&gl=jp&source=mog&q=$keyword_encode_utf8&safe=off&gwt=off&hl=ja" height=300 width=300></iframe>
	
&html_footer($self);

	return;
}

1;