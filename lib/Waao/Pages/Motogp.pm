package Waao::Pages::Motogp;
use strict;
use base qw(Waao::Pages::Base);
use Waao::Data;
use Waao::Html;
use Waao::Utility;

# /motogp/
sub dispatch(){
	my $self = shift;
	
	if($self->{cgi}->param('q') eq 'list-news'){
		&_news($self);
	}elsif($self->{cgi}->param('q') eq 'list-newsdetail'){
		&_newsdetail($self);
	}elsif($self->{cgi}->param('q') eq 'list-point'){
		&_driver($self);
	}elsif($self->{cgi}->param('q') eq 'list-driver'){
		&_driver($self);
	}elsif($self->{cgi}->param('q') eq 'list-race'){
		&_schedule($self);
	}elsif($self->{cgi}->param('q') eq 'list-result'){
		&_result($self);
	}else{
		&_top($self);
	}
	return;
}

sub _top(){
	my $self = shift;
	
	$self->{html_title} = qq{2010年 MotoGPレースLive速報プラス };
	$self->{html_keywords} = qq{MotoGP,2010,MotoGP,モトGP,レース,ニュース};
	$self->{html_description} = qq{2010年 MotoGPレースLive速報。無料で使えてライダーの情報もプラスして分かる！};
	$self->{html_body} = qq{<body bgcolor="#555555" text="#F4F4F4" link="#FFFF2B" vlink="#cc0000" alink="#FFEEEE">};
	$self->{html_hr} = qq{<hr color="#F4F4F4">};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);

print << "END_OF_HTML";
<center>
<img src="http://img.waao.jp/motogp.gif" width=120 height=28 alt="2010MotoGPレース速報"><font size=1 color="#FF0000">プラス</font>
</center>
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

&html_table_black($self, qq{<img src="http://img.waao.jp/lamp1.gif" width=14 height=11 alt="MotoGPレース速報"><font color="#FF0000">MotoGPレース速報</font>丨}, 0, 0);

my $sth = $self->{dbi}->prepare(qq{ select raceday, tv, racename, cirkit, raceno, id from race_schedule where type=2 and raceday >= DATE_ADD(CURRENT_DATE, INTERVAL -5 DAY) limit 1});
$sth->execute();
my $racetopics;
while(my @row = $sth->fetchrow_array) {
	$racetopics = qq{埇$row[0]<br><a href="/list-result/motogp/$row[5]/"><font color="blue">$row[2]</font></a><br>};
	my $tvstr;
	if($row[1]){
		$tvstr = $row[1];
		$tvstr =~s/\?//g;
	}else{
		$tvstr = qq{TV放送スケジュール確認中};
	}
	$racetopics .= qq{$tvstr};
}

print << "END_OF_HTML";
$racetopics
$hr
<center>
<a href="http://twitter.com/motogp_now">Twitter(MotoGPなう)</a><br>
<a href="/list-sign/sign/1/">日本のF1復活プロジェクト</a><br>
</center>
$hr
END_OF_HTML

&html_table_black($self, qq{<img src="http://img.waao.jp/kira01.gif" width=15 height=15 alt="MotoGPレース速報"><font color="#FF0000">MotoGPニュース速報</font>}, 0, 0);

print << "END_OF_HTML";
<font size=1>
END_OF_HTML

$sth = $self->{dbi}->prepare(qq{ select title, datestr, id from race_rss where type=2 order by datestr desc limit 5});
$sth->execute();
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<a href="/list-newsdetail/motogp/$row[2]/">$row[0]</a><br>
END_OF_HTML
}

print << "END_OF_HTML";
<div align="right"><img src="http://img.waao.jp/right07.gif" width=11 height=11 alt="MotoGPニュース"><a href="/list-news/motogp/">MotoGPニュース一覧</a></div>
</font>
END_OF_HTML

&_motogpmenu($self);
print << "END_OF_HTML";
$hr
END_OF_HTML

&html_table_black($self, qq{<img src="http://img.waao.jp/mb36.gif" width=11 height=11 alt="MotoGP検索"><font color="#FF0000">MotoGP関連検索プラス</font>}, 0, 0);

&html_keyword_info2($self,"MotoGP");

print << "END_OF_HTML";
$hr
偂<a href="http://waao.jp/list-in/ranking/16/">みんなのランキング</a><br>
<a href="/" accesskey=0>トップ</a>&gt;<strong>2010年MotoGPレース速報</strong><br>
<font size=1 color="#AAAAAA">MotoGPレース速報は、2010年シーズンのMotoGPレース速報、MotoGPテレビ放送日程、MotoGPニュースや、MotoGPライダーなどをマルチに検索できるMotoGP総合携帯サイトです。利用料は無料です。<br>
</font>
END_OF_HTML
&_rand_link($self);
&html_footer($self,1);
	
	return;
}

sub _result(){
	my $self = shift;
	
	my ($raceday,$racename,$cirkit,$raceno);
	my $sth = $self->{dbi}->prepare(qq{ select raceday, racename, cirkit, raceno from race_schedule where id=? limit 1});
	$sth->execute($self->{cgi}->param('p1'));
	while(my @row = $sth->fetchrow_array) {
		($raceday,$racename,$cirkit,$raceno) = @row;
	}
	
	$self->{html_title} = qq{2010年 $raceno $racename MotoGPレース結果 };
	$self->{html_keywords} = qq{MotoGP,2010,MotoGP,MotoGP,エフワン,レース,$racename};
	$self->{html_description} = qq{2010年 $raceno $racename MotoGPレース結果、MotoGPレースLive速報。};
	$self->{html_body} = qq{<body bgcolor="#555555" text="#F4F4F4" link="#FFFF2B" vlink="#cc0000" alink="#FFEEEE">};
	$self->{html_hr} = qq{<hr color="#F4F4F4">};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);

&html_table_black($self, qq{<img src="http://img.waao.jp/lamp1.gif" width=14 height=11 alt="MotoGPレース速報"><font color="#FF0000">$racename <br>MotoGPレース結果</font>}, 0, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
$racename<br>
$raceday<br>
$cirkit<br>
$hr
END_OF_HTML

$sth = $self->{dbi}->prepare(qq{ select R$raceno, name, team from race_driver where type=2 and R$raceno >= 1 and season = YEAR(CURRENT_DATE) order by R$raceno });
$sth->execute();
while(my @row = $sth->fetchrow_array) {
my $str_encode = &str_encode($row[1]);
my $subimg;
$subimg=qq{<img src="http://img.waao.jp/kaowink02.gif" width=53 height=15>} if($row[0] eq 1);
$subimg=qq{<img src="http://img.waao.jp/kaow04.gif" width=40 height=15>} if($row[0] eq 2);
$subimg=qq{<img src="http://img.waao.jp/kaohanaji03.gif" width=50 height=15>} if($row[0] eq 3);
print << "END_OF_HTML";
$row[0]位$subimg<br>
<a href="/$str_encode/search/">$row[1]</a><br>
<font size=1>
$row[2]<br>
</font>
END_OF_HTML
}

&_motogpmenu($self);

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/motogp/">2010年MotoGPレース速報</a>&gt;<strong>$racenameレース結果</strong><br>
<font size=1 color="#AAAAAA">MotoGP $racenameのレース結果、レース速報、テレビ放送時間などMotoGP$racenameの情報が検索できます。利用料は無料です。<br>
</font>

END_OF_HTML
&_rand_link($self);
&html_footer($self,1);
	
	return;
}

sub _schedule(){
	my $self = shift;

	$self->{html_title} = qq{2010年 MotoGPレース日程・開催スケジュール };
	$self->{html_keywords} = qq{MotoGP,2010,MotoGP,日程,スケジュール,レース};
	$self->{html_description} = qq{2010年 MotoGPレース日程・開催スケジュール。無料で使えてライダーの情報もプラスして分かる！};
	$self->{html_body} = qq{<body bgcolor="#555555" text="#F4F4F4" link="#FFFF2B" vlink="#cc0000" alink="#FFEEEE">};
	$self->{html_hr} = qq{<hr color="#F4F4F4">};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);

&html_table_black($self, qq{<img src="http://img.waao.jp/lamp1.gif" width=14 height=11 alt="MotoGPレース日程"><font color="#FF0000">MotoGPレース日程・スケジュール</font>}, 0, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

my $sth = $self->{dbi}->prepare(qq{ select raceday, racename, cirkit,raceno,id from race_schedule where type=2 and YEAR(raceday) = YEAR(CURRENT_DATE) order by raceday });
$sth->execute();
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
R$row[3] $row[0]<br>
<a href="/list-result/motogp/$row[4]/">$row[1]</a><br>
$row[2]<br><br>
END_OF_HTML
}

&_motogpmenu($self);

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/motogp/">2010年MotoGPレース速報</a>&gt;<strong>レース日程・スケジュール</strong><br>
<font size=1 color="#AAAAAA">MotoGP 2010年シーズンののレース日程、レーススケジュールの情報が検索できます。利用料は無料です。<br>
</font>

END_OF_HTML
&_rand_link($self);
&html_footer($self,1);


	return;
}

sub _driver(){
	my $self = shift;

	$self->{html_title} = qq{2010年 MotoGP参戦ライダー ポイントランキング};
	$self->{html_keywords} = qq{MotoGP,2010,MotoGP,ライダー,参戦,レース,ポイント,ランキング};
	$self->{html_description} = qq{2010年 MotoGPレース参戦ライダー一覧。無料で使えてライダーの情報もプラスして分かる！};
	$self->{html_body} = qq{<body bgcolor="#555555" text="#F4F4F4" link="#FFFF2B" vlink="#cc0000" alink="#FFEEEE">};
	$self->{html_hr} = qq{<hr color="#F4F4F4">};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);

&html_table_black($self, qq{<img src="http://img.waao.jp/lamp1.gif" width=14 height=11 alt="MotoGPレースライダー"><font color="#FF0000">MotoGP参戦ライダー</font>}, 0, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
気になるMotoGP 2010シーズンのライダーズポイント<br>
今シーズンの椣拂涸盆弓ヘ?<br>
$hr
END_OF_HTML

my $sth = $self->{dbi}->prepare(qq{ select name, team, point from race_driver where type=2 and season = YEAR(CURRENT_DATE) order by point desc });
$sth->execute();
while(my @row = $sth->fetchrow_array) {
my $str_encode = &str_encode($row[0]);
print << "END_OF_HTML";
$row[2]<font color="red">point</font><br>
<a href="/$str_encode/search/">$row[0]</a><br>
$row[1]<br>
<br>
END_OF_HTML
}

&_motogpmenu($self);

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/motogp/">2010年MotoGPレース速報</a>&gt;<strong>ライダー</strong><br>
<font size=1 color="#AAAAAA">MotoGP 2010年シーズンののレース参戦ライダーとライダーポイント,ライダーランキングの情報が検索できます。利用料は無料です。<br>
</font>

END_OF_HTML
&_rand_link($self);
&html_footer($self,1);


	return;
}

sub _news(){
	my $self = shift;
	my $page = $self->{cgi}->param('p1');

	$self->{html_title} = qq{2010年 MotoGPニュース速報 $page};
	$self->{html_keywords} = qq{MotoGP,2010,MotoGP,ニュース,速報};
	$self->{html_description} = qq{2010年 MotoGPニュース速報。無料で使えてライダーの情報もプラスして分かる！};
	$self->{html_body} = qq{<body bgcolor="#555555" text="#F4F4F4" link="#FFFF2B" vlink="#cc0000" alink="#FFEEEE">};
	$self->{html_hr} = qq{<hr color="#F4F4F4">};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);

	my $imglist;
	my $pagecnt = 10;
	my ($limit_s, $limit, $next_page) = &pager( $pagecnt, ($page || 0) );
	my $next_page = $page + 1;
	my $next_str = qq{⇒<a href="/list-news/motogp/$next_page/">次へ</a><br>};


&html_table_black($self, qq{<img src="http://img.waao.jp/lamp1.gif" width=14 height=11 alt="MotoGPニュース速報"><font color="#FF0000">MotoGPニュース速報</font>}, 0, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

my $sth = $self->{dbi}->prepare(qq{ select id,title, datestr from race_rss where type = 2 order by datestr desc limit $limit_s, $limit});
$sth->execute();
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<a href="/list-newsdetail/motogp/$row[0]/">$row[1]</a><br>
<div align="right">$row[2]</div>
END_OF_HTML
}

print << "END_OF_HTML";
$next_str
END_OF_HTML

&_motogpmenu($self);

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/motogp/">2010年MotoGPレース速報</a>&gt;<strong>MotoGPニュース速報</strong><br>
<font size=1 color="#AAAAAA">MotoGP 2010年シーズンのMotoGPニュースやライダー関連情報などのMotoGP総合情報が検索できます。利用料は無料です。<br>
</font>

END_OF_HTML
&_rand_link($self);
&html_footer($self,1);


	return;
}

sub pager(){
	use strict;
	my $limit = shift;
	my $page = shift;
	
	my $limit_s = 0;
	if( $page ){
		$limit_s = $limit * $page;
	}
	my $next_page = $page + 1;

	return ($limit_s, $limit, $next_page);
}
sub _newsdetail(){
	my $self = shift;
	
	my ($title, $datestr, $bodystr,$geturl);
	my $sth = $self->{dbi}->prepare(qq{ select title, datestr, body, geturl from race_rss where id = ? limit 1});
	$sth->execute($self->{cgi}->param('p1'));
	while(my @row = $sth->fetchrow_array) {
		($title, $datestr, $bodystr, $geturl) = @row;
	}
	
	$self->{html_title} = qq{MotoGPニュース $title};
	$self->{html_keywords} = qq{MotoGP,2010,MotoGP,ニュース};
	$self->{html_description} = qq{MotoGPニュース速報 $title $datestrのMotoGPニュース};
	$self->{html_body} = qq{<body bgcolor="#555555" text="#F4F4F4" link="#FFFF2B" vlink="#cc0000" alink="#FFEEEE">};
	$self->{html_hr} = qq{<hr color="#F4F4F4">};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);

&html_table_black($self, qq{<img src="http://img.waao.jp/lamp1.gif" width=14 height=11 alt="MotoGPニュース速報"><font color="#FF0000">MotoGPニュース結果</font>}, 0, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
$title<br>
$datestr<br>
$hr
$bodystr<br>
<div align=right><a href="$geturl">配信元</a></div>
END_OF_HTML

&_motogpmenu($self);

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/motogp/">2010年MotoGPレース速報</a>&gt;<strong>$title</strong><br>
<font size=1 color="#AAAAAA">MotoGPニュース速報 $titleの情報が検索できます。利用料は無料です。<br>
MotoGP専用のRSSリーダーのため、内容については、RSS配信元にてご確認ください。<br>
</font>
END_OF_HTML
&_rand_link($self);
&html_footer($self,1);
	
	return;
}

sub _motogpmenu(){
	my $self =shift;
	my $hr = &html_hr($self,1);	

print << "END_OF_HTML";
$hr
END_OF_HTML

&html_table_black($self, qq{<img src="http://img.waao.jp/mb36.gif" width=11 height=11 alt="MotoGP検索"><font color="#FF0000">MotoGP情報</font>}, 0, 0);

print << "END_OF_HTML";
<a href="/list-race/motogp/" accesskey=1>MotoGPレーススケジュール</a><br>
<a href="/list-driver/motogp/2010/" accesskey=2>MotoGPライダー一覧</a><br>
<a href="/list-point/motogp/" accesskey=3>ポイントランキング</a><br>
<a href="http://motogpbike.blog46.fc2.com/" accesskey=4>MotoGPブログ</a><br>
<a href="/list-news/motogp/" accesskey=5>MotoGPニュース速報</a><br>
<a href="/MotoGP/shopping/" accesskey=6>MotoGPグッズ専門店</a><br>
<a href="/MotoGP/search/" accesskey=7>MotoGPデータベース</a><br>
<a href="http://twitter.com/motogp_now" accesskey=8>Twitter(MotoGPなう)</a><br>
<a href="/f1/" accesskey=9>F1ニュース速報</a><br>
<a href="http://motogptwitter.goo.to/">みんなのMotoPGライト版</a><br>
END_OF_HTML
	
	return;
}

sub _rand_link(){
	my $self=shift;
	
	my $link;
	
	if($self->{date_min} <= 10){
		$link = qq{http://motogp.gokigen.com/};
	}else{
		$link = qq{http://motogp.goo.to/};
	}
	
	my $linkstr = qq{<a href="$link" title="MotoGPニュース">MotoGPニュース</a><br>};
print << "END_OF_HTML";
$linkstr
END_OF_HTML

	return;
}
1;