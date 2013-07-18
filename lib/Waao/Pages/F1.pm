package Waao::Pages::F1;
use strict;
use base qw(Waao::Pages::Base);
use Waao::Data;
use Waao::Html;
use Waao::Utility;

# /f1/
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
	
	$self->{html_title} = qq{2010年 F1レースLive速報プラス };
	$self->{html_keywords} = qq{F1,2010,F1,f1,エフワン,レース,ニュース};
	$self->{html_description} = qq{2010年 F1レースLive速報。無料で使えてドライバーの情報もプラスして分かる！};
	$self->{html_body} = qq{<body bgcolor="#555555" text="#F4F4F4" link="#FFFF2B" vlink="#cc0000" alink="#FFEEEE">};
	$self->{html_hr} = qq{<hr color="#F4F4F4">};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);

print << "END_OF_HTML";
<center>
<img src="http://img.waao.jp/f1live.gif" width=120 height=28 alt="2010F1レース速報"><font size=1 color="#FF0000">プラス</font>
</center>
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

&html_table_black($self, qq{<img src="http://img.waao.jp/lamp1.gif" width=14 height=11 alt="F1レース速報"><font color="#FF0000">F1レース速報</font>丨}, 0, 0);

my $sth = $self->{dbi}->prepare(qq{ select raceday, tv, racename, cirkit, raceno, id from race_schedule where type=1 and raceday >= DATE_ADD(CURRENT_DATE, INTERVAL -5 DAY) limit 1});
$sth->execute();
my $racetopics;
while(my @row = $sth->fetchrow_array) {
	$racetopics = qq{埇$row[0]<br><a href="/list-result/f1/$row[5]/"><font color="blue">$row[2]</font></a><br>};
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
<a href="http://twitter.com/f1_fun " accesskey=8>Twitter(F1なう)</a><br>
<a href="/list-sign/sign/1/">日本のF1復活プロジェクト</a>
</center>
$hr
END_OF_HTML

&html_table_black($self, qq{<img src="http://img.waao.jp/kira01.gif" width=15 height=15 alt="F1レース速報"><font color="#FF0000">F1ニュース速報</font>}, 0, 0);

print << "END_OF_HTML";
<font size=1>
END_OF_HTML

$sth = $self->{dbi}->prepare(qq{ select title, datestr, id from race_rss where type=1 order by datestr desc limit 5});
$sth->execute();
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<a href="/list-newsdetail/f1/$row[2]/">$row[0]</a><br>
END_OF_HTML
}

print << "END_OF_HTML";
<div align="right"><img src="http://img.waao.jp/right07.gif" width=11 height=11 alt="F1ニュース"><a href="/list-news/f1/">F1ニュース一覧</a></div>
</font>
END_OF_HTML

&_f1menu($self);

print << "END_OF_HTML";
$hr
END_OF_HTML

&html_table_black($self, qq{<img src="http://img.waao.jp/mb36.gif" width=11 height=11 alt="F1検索"><font color="#FF0000">F1関連検索プラス</font>}, 0, 0);

&html_keyword_info2($self,"F1");

print << "END_OF_HTML";
$hr
偂<a href="http://waao.jp/list-in/ranking/15/">みんなのランキング</a><br>
<a href="/" accesskey=0>トップ</a>&gt;<strong>2010年F1レース速報</strong><br>
<font size=1 color="#AAAAAA">F1レース速報は、2010年シーズンのF1レース速報、F1テレビ放送日程、F1ニュースや、F1ドライバーなどをマルチに検索できるF1総合携帯サイトです。利用料は無料です。<br>
</font>
END_OF_HTML

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
	
	$self->{html_title} = qq{2010年 $raceno $racename F1レース結果 };
	$self->{html_keywords} = qq{F1,2010,F1,f1,エフワン,レース,$racename};
	$self->{html_description} = qq{2010年 $raceno $racename F1レース結果、F1レースLive速報。};
	$self->{html_body} = qq{<body bgcolor="#555555" text="#F4F4F4" link="#FFFF2B" vlink="#cc0000" alink="#FFEEEE">};
	$self->{html_hr} = qq{<hr color="#F4F4F4">};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);

&html_table_black($self, qq{<img src="http://img.waao.jp/lamp1.gif" width=14 height=11 alt="F1レース速報"><font color="#FF0000">$racename <br>F1攬ス結果</font>}, 0, 0);

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

$sth = $self->{dbi}->prepare(qq{ select R$raceno, name, team from race_driver where type=1 and R$raceno >= 1 and season = YEAR(CURRENT_DATE) order by R$raceno });
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

&_f1menu($self);

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/f1/">2010年F1レース速報</a>&gt;<strong>$racenameレース結果</strong><br>
<font size=1 color="#AAAAAA">F1 $racenameのレース結果、レース速報、テレビ放送時間などF1$racenameの情報が検索できます。利用料は無料です。<br>
</font>

END_OF_HTML
&html_footer($self,1);
	
	return;
}

sub _schedule(){
	my $self = shift;

	$self->{html_title} = qq{2010年 F1レース日程・開催スケジュール };
	$self->{html_keywords} = qq{F1,2010,F1,日程,スケジュール,レース};
	$self->{html_description} = qq{2010年 F1レース日程・開催スケジュール。無料で使えてドライバーの情報もプラスして分かる！};
	$self->{html_body} = qq{<body bgcolor="#555555" text="#F4F4F4" link="#FFFF2B" vlink="#cc0000" alink="#FFEEEE">};
	$self->{html_hr} = qq{<hr color="#F4F4F4">};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);

&html_table_black($self, qq{<img src="http://img.waao.jp/lamp1.gif" width=14 height=11 alt="F1レース日程"><font color="#FF0000">F1レース日程・スケジュール</font>}, 0, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

my $sth = $self->{dbi}->prepare(qq{ select raceday, racename, cirkit,raceno,id from race_schedule where type=1 and YEAR(raceday) = YEAR(CURRENT_DATE) order by raceday });
$sth->execute();
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
R$row[3] $row[0]<br>
<a href="/list-result/f1/$row[4]/">$row[1]</a><br>
$row[2]<br><br>
END_OF_HTML
}

&_f1menu($self);

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/f1/">2010年F1レース速報</a>&gt;<strong>レース日程・スケジュール</strong><br>
<font size=1 color="#AAAAAA">F1 2010年シーズンののレース日程、レーススケジュールの情報が検索できます。利用料は無料です。<br>
</font>

END_OF_HTML
&html_footer($self,1);


	return;
}

sub _driver(){
	my $self = shift;

	$self->{html_title} = qq{2010年 F1参戦ドライバー ポイントランキング};
	$self->{html_keywords} = qq{F1,2010,F1,ドライバー,参戦,レース,ポイント,ランキング};
	$self->{html_description} = qq{2010年 F1レース参戦ドライバー一覧。無料で使えてドライバーの情報もプラスして分かる！};
	$self->{html_body} = qq{<body bgcolor="#555555" text="#F4F4F4" link="#FFFF2B" vlink="#cc0000" alink="#FFEEEE">};
	$self->{html_hr} = qq{<hr color="#F4F4F4">};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);

&html_table_black($self, qq{<img src="http://img.waao.jp/lamp1.gif" width=14 height=11 alt="F1レースドライバー"><font color="#FF0000">F1参戦ドライバー</font>}, 0, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
気になるF1 2010シーズンのドライバーズポイント<br>
今シーズンの椣拂涸盆弓ヘ?<br>
$hr
END_OF_HTML

my $sth = $self->{dbi}->prepare(qq{ select name, team, point from race_driver where type=1 and season = YEAR(CURRENT_DATE) order by point desc });
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

&_f1menu($self);

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/f1/">2010年F1レース速報</a>&gt;<strong>ドライバー</strong><br>
<font size=1 color="#AAAAAA">F1 2010年シーズンののレース参戦ドライバーとドライバーポイント,ドライバーランキングの情報が検索できます。利用料は無料です。<br>
</font>

END_OF_HTML
&html_footer($self,1);


	return;
}

sub _news(){
	my $self = shift;
	my $page = $self->{cgi}->param('p1');

	$self->{html_title} = qq{2010年 F1ニュース速報 $page};
	$self->{html_keywords} = qq{F1,2010,F1,ニュース,速報};
	$self->{html_description} = qq{2010年 F1ニュース速報。無料で使えてドライバーの情報もプラスして分かる！};
	$self->{html_body} = qq{<body bgcolor="#555555" text="#F4F4F4" link="#FFFF2B" vlink="#cc0000" alink="#FFEEEE">};
	$self->{html_hr} = qq{<hr color="#F4F4F4">};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);

	my $imglist;
	my $pagecnt = 10;
	my ($limit_s, $limit, $next_page) = &pager( $pagecnt, ($page || 0) );
	my $next_page = $page + 1;
	my $next_str = qq{<div align=right><img src="http://img.waao.jp/m2028.gif" width=48 height=9><a href="/list-news/f1/$next_page/">次へ</a></div>};


&html_table_black($self, qq{<img src="http://img.waao.jp/lamp1.gif" width=14 height=11 alt="F1ニュース速報"><font color="#FF0000">F1ニュース速報</font>}, 0, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

my $sth = $self->{dbi}->prepare(qq{ select id,title, datestr from race_rss where type = 1 order by datestr desc limit $limit_s, $limit});
$sth->execute();
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<a href="/list-newsdetail/f1/$row[0]/">$row[1]</a><br>
<div align="right">$row[2]</div>
END_OF_HTML
}

print << "END_OF_HTML";
$next_str
END_OF_HTML

&_f1menu($self);

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/f1/">2010年F1レース速報</a>&gt;<strong>F1ニュース速報</strong><br>
<font size=1 color="#AAAAAA">F1 2010年シーズンのF1ニュースやドライバー関連情報などのF1総合情報を集めたRSSリーダーです。<br>
利用料は無料です。<br>
F1専用のRSSリーダーのため、内容については、RSS配信元にてご確認ください。<br>
</font>

END_OF_HTML
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
	
	my ($title, $datestr, $bodystr, $geturl);
	my $sth = $self->{dbi}->prepare(qq{ select title, datestr, body, geturl from race_rss where id = ? limit 1});
	$sth->execute($self->{cgi}->param('p1'));
	while(my @row = $sth->fetchrow_array) {
		($title, $datestr, $bodystr, $geturl) = @row;
	}
	$geturl = &html_pc_2_mb($geturl);
	$self->{html_title} = qq{F1ニュース $title};
	$self->{html_keywords} = qq{F1,2010,F1,ニュース};
	$self->{html_description} = qq{F1ニュース速報 $title $datestrのF1ニュース};
	$self->{html_body} = qq{<body bgcolor="#555555" text="#F4F4F4" link="#FFFF2B" vlink="#cc0000" alink="#FFEEEE">};
	$self->{html_hr} = qq{<hr color="#F4F4F4">};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);

&html_table_black($self, qq{<img src="http://img.waao.jp/lamp1.gif" width=14 height=11 alt="F1ニュース速報"><font color="#FF0000">F1ニュース結果</font>}, 0, 0);

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

&_f1menu($self);

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/f1/">2010年F1レース速報</a>&gt;<strong>$title</strong><br>
<font size=1 color="#AAAAAA">F1ニュース速報 $titleの情報が検索できます。利用料は無料です。<br>
F1専用のRSSリーダーのため、内容については、RSS配信元にてご確認ください。<br>
</font>
END_OF_HTML
&html_footer($self,1);
	
	return;
}

sub _f1menu(){
	my $self =shift;
	my $hr = &html_hr($self,1);	

print << "END_OF_HTML";
$hr
END_OF_HTML

&html_table_black($self, qq{<img src="http://img.waao.jp/mb36.gif" width=11 height=11 alt="F1検索"><font color="#FF0000">F1情報</font>}, 0, 0);

print << "END_OF_HTML";
<a href="/list-race/f1/" accesskey=1>F1レーススケジュール</a><br>
<a href="/list-driver/f1/2010/" accesskey=2>F1ドライバー一覧</a><br>
<a href="/list-point/f1/" accesskey=3>ポイントランキング</a><br>
<a href="http://formula1car.blog70.fc2.com/" accesskey=4>F1ブログLive</a><br>
<a href="/list-news/f1/" accesskey=5>F1ニュース速報</a><br>
<a href="/F1/shopping/" accesskey=6>F1グッズ専門店</a><br>
<a href="/F1/search/" accesskey=7>F1データベース</a><br>
<a href="http://twitter.com/f1_fun " accesskey=8>Twitter(F1なう)</a><br>
<a href="/motogp/" accesskey=9>MotoGPニュース速報</a><br>
END_OF_HTML
	
	return;
}

1;