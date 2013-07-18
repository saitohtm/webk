package Waao::Pc;
use Exporter;
@ISA = (Exporter);
@EXPORT = qw(pc_page);
use Waao::Html;
use Waao::Data;
use Waao::Utility;
use Jcode;
use CGI qw( escape );

sub pc_page(){
	my $self = shift;
	
	if($ENV{'SERVER_NAME'} eq 's.waao.jp'){
		&_smf_pc($self);
		return;
	}elsif($ENV{'SERVER_NAME'} eq 'smax.tv'){
		&_smf_pc($self);
		return;
	}

	my $keyword = $self->{cgi}->param('q');
	
	if($keyword =~/list-/){
		$keyword = undef;
	}
	unless($keyword){
		my $memkey = "trendperson";
		my $today_trend;
#		$today_trend = $self->{mem}->get( $memkey );
		if($today_trend){
			foreach my $val (@{$today_trend->{rank}}){
				$keyword = $val;
				last unless($self->{date_sec} % 10);
			}
		}else{
			my $randcnt = int(rand(50));
			my $sth = $self->{dbi}->prepare(qq{ select id, keyword from keyword where person = 1 and av is null order by cnt desc limit $randcnt} );
			$sth->execute();
			while(my @row = $sth->fetchrow_array) {
					$keyword = $row[1];
			}
		}
	}
	my ( $keyword_id, $cnt, $wikipedia, $yahookeyword, $blogurl, $person, $ana, $model, $artist);

	my $sth;
	$sth = $self->{dbi}->prepare(qq{ select id, keyword, cnt, simplewiki, yahookeyword, blogurl, person, ana, model, artist from keyword where keyword = ? limit 1} );
	$sth->execute($keyword);
	while(my @row = $sth->fetchrow_array) {
		( $keyword_id, $keyword, $cnt, $wikipedia, $yahookeyword, $blogurl, $person, $ana, $model, $artist) = @row;
	}
	my $id = $keyword_id;

	my $keyword_utf8 = $keyword;
	Encode::from_to($keyword_utf8,'cp932','utf8');
	my $keyword_encode = &str_encode($keyword);
	$wikipedia =~s/&gt;/\>/g;
	$wikipedia =~s/&lt;/\</g;



if($ana){
	&_header($self,"女子アナウンサー$keywordの画像・動画・最新ニュースや噂を無料配信中!!","$keyword,女子アナ,アナウンサー,画像,動画,プロフィール,データ,情報","$keyword大好き -女子アナ名鑑-",$keyword);
}elsif($model){
	&_header($self,"モデル$keywordの画像・動画・最新ニュースや噂を無料配信中!!","$keyword,モデル,読者モデル,ファッション,画像,動画,プロフィール,データ,情報","$keyword大好き -人気モデル名鑑-",$keyword);
}elsif($artist){
	&_header($self,"$keywordのPV・最新曲・歌詞・画像・動画・最新ニュースや噂を無料配信中!!","$keyword,新曲,pv,歌詞,画像,動画,プロフィール,データ,情報","$keyword大好き -アーティスト名鑑-",$keyword);
}elsif($person){
	&_header($self,"$keywordの画像・動画・最新ニュースや噂を無料配信中!!","$keyword,画像,動画,プロフィール,データ,情報","$keyword大好き -人物名鑑-",$keyword);
}else{
	&_header($self,"$keywordの画像・動画・wiki情報を無料配信中!!","$keyword,画像,動画,wiki,wikipedia,データ,情報","$keyword -wikiデータベース-",$keyword);
}

print << "END_OF_HTML";
<div id="wrapper">
<div id="header">
<h1>$keyword</h1>
<p class="logo">
<form action="http://www.google.co.jp/cse" id="cse-search-box" target="_blank">
  <div>
<img src="http://goo.to/img/cn11.gif" width=46 height=52>
「$keyword」
    <input type="hidden" name="cx" value="partner-pub-2078370187404934:nqwfgk9rnxl" />
    <input type="hidden" name="ie" value="utf-8" />
    <input type="text" value="$keyword" name="q" size="31" />
    <input type="submit" name="sa" value="&#x691c;&#x7d22;" />
  </div>
</form>
<script type="text/javascript" src="http://www.google.co.jp/cse/brand?form=cse-search-box&amp;lang=ja"></script> 
</p>
</div><!-- / header end -->

<div id="contents">
END_OF_HTML

&_body_best_photo($self,$keyword);
&_body_wiki($self, $keyword, $wikipedia);
&_body_uwasa($self, $keyword, $keyword_id);
&_body_shoplist($self, $keyword);
&_body_bbs($self, $keyword, $keyword_id);
&_body_qanda($self, $keyword, $keyword_id);
&_body_photolist($self,$keyword);
&_body_keyword($self, $keyword, $keyword_id);
&_body_pop_person($self);


print << "END_OF_HTML";
<center>
<a href="http://clickbokin.ekokoro.jp/" target="_blank"><img src="http://www.ekokoro.jp/supporter/br_468_60.jpg" width="468" height="60" border="0" alt="募金サイト イーココロ！"></a>
</center>
<p class="description">$keyword大好きは、携帯サイト みんなのモバイル -<a href="http://goo.to/">http://goo.to/</a>- で提供されています。<br><font color="#FF0000">携帯電話からアクセスしてください。</font></p>

<!-- コンテンツ ここまで -->

</div><!-- / contents end -->

END_OF_HTML
&_side_bar($self,$keyword);
&_footer($self,"$keyword データベース");
	return;
}


sub _header(){
	my $self = shift;
	my $description = shift;
	my $keywords = shift;
	my $title = shift;
	my $keyword = shift;
	my $keyword_encode = &str_encode($keyword);
	
print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html lang="ja">
<head>
<meta http-equiv="Content-Style-Type" content="text/css">
<meta http-equiv="Content-Script-Type" content="text/javascript">
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta name="Description" content="$description">
<meta name="Keywords" content="$keywords">
<title>$title</title>
<link rel="stylesheet" href="http://waao.jp/base.css" type="text/css" media="screen,tv">
<link rel="alternate" media="handheld" href="http://goo.to/keyword$keyword_encode/" />
</head>
<body>


END_OF_HTML

	return;
}

sub _footer(){
	my $self = shift;
	my $title = shift;

print << "END_OF_HTML";
<div id="footer">
<!-- コピーライト -->
<p>Copyright &copy; $title All Rights Reserved.</p>
<p id="cds">CSS Template <a href="http://www.css-designsample.com/">CSSデザインサンプル</a></p>
<img src="http://ameblo.jp/nsr250-se/" width=0 height=0>
<img src="http://ameblo.jp/saitohtm/" width=0 height=0>
<img src="http://ameblo.jp/rousemilk/" width=0 height=0>
</div><!-- / footer end -->
</div><!-- / wrapper end -->
</body>
</html>
END_OF_HTML
	
	return;
}

sub _img_iframe(){
	my $self = shift;
	my $keyword = shift;
	my $keyword_encode = &str_encode($keyword);
	
if($self->{session}->{_session_id} ne "robot"){
print << "END_OF_HTML";
<br>
<img src="http://goo.to/img/lamp1.gif" width=14 height=11><a href="http://www.google.co.jp/images?hl=ja&source=imghp&biw=908&bih=676&q=$keyword_encode&uss=1" target="_blank">$keywordの画像検索(Google)</a><br>
<iframe src="http://www.google.co.jp/images?hl=ja&source=imghp&biw=908&bih=676&q=$keyword_encode&uss=1" width=550 height=500></iframe>
<img src="http://goo.to/img/lamp1.gif" width=14 height=11><a href="http://search.naver.jp/image?sm=tab_opt&q=$keyword_encode&o_sz=all&o_sf=0&t_size=0" target="_blank">$keywordの画像検索(NAVER)</a><br>
<iframe src="http://search.naver.jp/image?sm=tab_opt&q=$keyword_encode&o_sz=all&o_sf=0&t_size=0" width=550 height=500></iframe>
END_OF_HTML
}
	return;
}

sub _body_best_photo(){
	my $self = shift;
	my $keyword = shift;

print << "END_OF_HTML";
<!-- 写真 -->
<table border="0" width=100%><tr><td BGCOLOR="#555555">
END_OF_HTML

my $sth = $self->{dbi}->prepare(qq{ select url, fullurl,id from photo where keyword = ? and yahoo=1 order by good desc limit 4} );
$sth->execute($keyword);
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<a href="/photoid$row[2]/" title="$keywordの画像"><img src="$row[0]" alt="$keyword写真" width=120 memo="拡大" /></a>
END_OF_HTML
}

print << "END_OF_HTML";
</td></tr></table>
END_OF_HTML
	
	return;
}
sub _body_wiki(){
	my $self = shift;
	my $keyword = shift;
	my $wikipedia =shift;
	
if($wikipedia){
print << "END_OF_HTML";
<h2>$keywordとは</h2>
<font color="#AAAAAA">$wikipedia </font><br>
END_OF_HTML

if($self->{session}->{_session_id} ne "robot"){
print << "END_OF_HTML";
<div align="right"><img src="http://goo.to/img/right07.gif" widht=10 height=10><a href="http://ja.wikipedia.org/wiki/$keyword" target="_blank">wikipediaで検索</a></div><br>
<br>
END_OF_HTML
}
}
	
	return;
}

sub _body_uwasa(){
	my $self = shift;
	my $keyword = shift;
	my $id = shift;
	my $cnt = shift;
	
	$cnt = 10 unless($cnt);

	my $uwasalist;
	my $sth;
	if($cnt == 10){
		$sth = $self->{dbi}->prepare(qq{ select id, keywordid, keyword, keypersonid, keyperson, type, point
	                         from keyword_recomend  where  keywordid = ? and point >= 2 order by point desc limit $cnt});
	}else{
		$sth = $self->{dbi}->prepare(qq{ select id, keywordid, keyword, keypersonid, keyperson, type, point
	                         from keyword_recomend  where  keywordid = ? and point >= -100 order by point desc limit $cnt});
	}
	$sth->execute($id);
	while(my @row = $sth->fetchrow_array) {
		my $str = $row[2];
		$str =~ s/([^0-9A-Za-z_ ])/'%'.unpack('H2',$1)/ge;
		$str =~ s/ /%20/g;
		my $str2 = $row[4];
		$str2 =~ s/([^0-9A-Za-z_ ])/'%'.unpack('H2',$1)/ge;
		$str2 =~ s/ /%20/g;

		$uwasalist.=qq{<table border="0" width=100%><tr><td BGCOLOR="#FFEAEF"><img src="http://goo.to/img/kya-.gif" width=15 height=15><a href="/uwasa$row[0]/">$row[2]</a>は};
		$uwasalist.=qq{<a href="/id$row[3]/">$row[4]</a>};
		$uwasalist.=qq{と恋人<img src="http://goo.to/img/kaochu03.gif" width=72 height=15><br>} if($row[5] eq 1);
		$uwasalist.=qq{と元恋人<img src="http://goo.to/img/kaobye06.gif" width=44 height=12><br>} if($row[5] eq 2);
		$uwasalist.=qq{と夫婦<img src="http://goo.to/img/kaow01.gif" width=53 height=15><br>} if($row[5] eq 3);
		$uwasalist.=qq{と友人<img src="http://goo.to/img/kaobye03.gif" width=35 height=15><br>} if($row[5] eq 4);
		$uwasalist.=qq{が好き<img src="http://goo.to/img/kao-a08.gif" width=15 height=15><br>} if($row[5] eq 5);
		$uwasalist.=qq{が嫌い<img src="http://goo.to/img/kaoikari03.gif" width=60 height=15><br>} if($row[5] eq 6);
		$uwasalist.=qq{とメル友<img src="http://goo.to/img/kaobye01.gif" width=35 height=15><br>} if($row[5] eq 7);
		$uwasalist.=qq{と親子<br>} if($row[5] eq 8);
		$uwasalist.=qq{と兄弟/姉妹<br>} if($row[5] eq 9);
		$uwasalist.=qq{と共演者<br>} if($row[5] eq 10);
		$uwasalist.=qq{と同郷<br>} if($row[5] eq 11);
		$uwasalist.=qq{と同じ事務所<br>} if($row[5] eq 12);
		$uwasalist.=qq{と元夫婦<br>} if($row[5] eq 13);
		$uwasalist.=qq{とライバル<br>} if($row[5] eq 14);
		$uwasalist.=qq{と同年代<br>} if($row[5] eq 15);
		$uwasalist.=qq{<div align=right><font size=1>うわさ度 <font color="red">$row[6]</font>!!</font></div></td></tr></table>};
	}

if($uwasalist){
print << "END_OF_HTML";
<!-- コンテンツ ここから -->
<h2>$keyword うわさ</h2>
$uwasalist
<div align=right><img src="http://goo.to/img/right07.gif" widht=10 height=10><a href="/uwasalist$id/" title="$keywordのうわさ">$keywordのうわさを見る</a></div>
END_OF_HTML
}else{
print << "END_OF_HTML";
<h2>$keyword うわさ</h2>
$keywordのうわさがありません。<br>
$keywordのうわさにご協力ください（<img src="http://goo.to/img/right07.gif" widht=10 height=10><a href="/uwasalist$id/" title="$keywordのうわさ">うわさを投稿</a>）<br>
END_OF_HTML
}
	return;
}

sub _body_shoplist(){
	my $self = shift;
	my $keyword = shift;

	my $keyword_utf8 = $keyword;
	Encode::from_to($keyword_utf8,'cp932','utf8');
	
print << "END_OF_HTML";
<h2>$keyword 関連商品</h2>
<iframe src="http://rcm-jp.amazon.co.jp/e/cm?t=gooto-22&o=9&p=15&l=st1&mode=dvd-jp&search=$keyword_utf8&fc1=000000&lt1=&lc1=3366FF&bg1=FFFFFF&f=ifr" marginwidth="0" marginheight="0" width="468" height="240" border="0" frameborder="0" style="border:none;" scrolling="no"></iframe>
<br>
<iframe src="http://rcm-jp.amazon.co.jp/e/cm?t=gooto-22&o=9&p=15&l=st1&mode=books-jp&search=$keyword_utf8&fc1=000000&lt1=&lc1=3366FF&bg1=FFFFFF&f=ifr" marginwidth="0" marginheight="0" width="468" height="240" border="0" frameborder="0" style="border:none;" scrolling="no"></iframe>
<br>
END_OF_HTML

	return;
}

sub _body_bbs(){
	my $self = shift;
	my $keyword = shift;
	my $id = shift;

my $bbslist;
my $sth = $self->{dbi}->prepare(qq{ select id, bbs, keywordid  from bbs  where keywordid = ? order by id desc limit 10} );
$sth->execute($id);
while(my @row = $sth->fetchrow_array) {
	my $str2 = $keyword;
	$str2 =~ s/([^0-9A-Za-z_ ])/'%'.unpack('H2',$1)/ge;
	$str2 =~ s/ /%20/g;
#	$bbslist .= qq{<a href="/bbs$row[2]/">$keyword</a><br>};
	$bbslist .= $row[1];
}
if($bbslist){
print << "END_OF_HTML";
<h2>$keyword の掲示板</h2>
$bbslist
<div align=right><img src="http://goo.to/img/right07.gif" widht=10 height=10><a href="/bbslist$id/" title="$keywordの掲示板">$keyword掲示板を見る</a></div>
END_OF_HTML
}else{
print << "END_OF_HTML";
<h2>$keyword の掲示板</h2>
$keywordの投稿がありません。<br>
$keywordの書き込みにご協力ください（<img src="http://goo.to/img/right07.gif" widht=10 height=10><a href="/bbslist$id/" title="$keywordの掲示板">投稿</a>）<br>
END_OF_HTML
}

	return;
}

sub _body_qanda(){
	my $self = shift;
	my $keyword = shift;
	my $id  =shift;

print << "END_OF_HTML";
<h2>$keyword のQ&A</h2>
END_OF_HTML

my $sth = $self->{dbi}->prepare(qq{select id, question, bestanswer, url from qanda where keywordid = ? limit 10 } );
$sth->execute( $id );
while(my @row = $sth->fetchrow_array) {
my $answer = substr($row[2], 0, 64);
print << "END_OF_HTML";
<table border="0" width=100%><tr><td BGCOLOR="#FFEAEF">
<img src="http://goo.to/img/kaohatena02.gif" width=50 height=12><img src="http://goo.to/img/kaohatena03.gif" width=44 height=15><br>
<font color="#555555" size=1>
<font color="#0035D5">■質問</font>:$row[1]<br>
<img src="http://goo.to/img/kaow02.gif" width=56 height=12><br>
<font color="#FF0000">■回答</font>:$answer <a href="/qanda$row[0]/" title="$keywordの質問">⇒詳細を見る</a><br>
</font>
</td></tr></table>
END_OF_HTML
}

print << "END_OF_HTML";
<div align=right><img src="http://goo.to/img/right07.gif" widht=10 height=10><a href="/qandalist$id/" title="$keywordのQ&A">$keywordのQ&Aを見る</a></div>
END_OF_HTML

	return;
}

sub _body_photolist(){
	my $self = shift;
	my $keyword = shift;
	
print << "END_OF_HTML";
<h2>$keyword 関連画像</h2>
<br>
<table border="0" width=100%><tr><td BGCOLOR="#555555">
END_OF_HTML

my $imgcnt;
my $sth = $self->{dbi}->prepare(qq{ select url, fullurl, id from photo where keyword = ? order by yahoo desc, good desc} );
$sth->execute($keyword);
while(my @row = $sth->fetchrow_array) {
$imgcnt++;
print << "END_OF_HTML";
<a href="/photoid$row[2]/" title="$keywordの画像"><img src="$row[0]" alt="$keyword写真" width=120 memo="拡大" /></a>
END_OF_HTML
}

unless($imgcnt){
print << "END_OF_HTML";
画像が見つかりませんでした。<br>
END_OF_HTML
&_img_iframe($self,$keyword);
}
print << "END_OF_HTML";
</td></tr></table>
END_OF_HTML
	return;
}

sub _body_pop_person(){
	my $self = shift;
	
print << "END_OF_HTML";
</td></tr></table>
<h2>話題の人物</h2>
END_OF_HTML

my $keywords = $self->{mem}->get("randperson");
my @randpersonlist = split(/:::/,$keywords);
foreach my $persondata (@randpersonlist){
    my @personval = split(/::/,$persondata);
print << "END_OF_HTML";
<a href="http://good.goo.to/?q=$personval[1]">$personval[0]</a> 
END_OF_HTML
}
	return;
}

sub _body_keyword(){
	my $self = shift;
	my $keyword = shift;
	my $keyword_id = shift;

print << "END_OF_HTML";
</td></tr></table>
<h2>$keywordの関連キーワード</h2>
END_OF_HTML

my $sth = $self->{dbi}->prepare(qq{ select id, keyword, cnt from keyword_chainx  where parentid = ? and id != ? order by cnt desc limit 20});
$sth->execute($keyword_id, $keyword_id);
while(my @row = $sth->fetchrow_array) {
		my $str_encode = &str_encode($row[1]);
print << "END_OF_HTML";
<a href="http://good.goo.to/?q=$str_encode">$row[1]</a> 
END_OF_HTML
}
	return;
}

sub _side_bar(){
	my $self = shift;
	my $keyword = shift;

print << "END_OF_HTML";
<div id="sidebar">
<!-- サイドバー ここから -->
<center>
<br>

<OBJECT classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="http://fpdownload.macromedia.com/get/flashplayer/current/swflash.cab" id="Player_73cb6eea-490b-4a1f-be5a-b5d07172fbed"  WIDTH="160px" HEIGHT="400px"> <PARAM NAME="movie" VALUE="http://ws.amazon.co.jp/widgets/q?ServiceVersion=20070822&MarketPlace=JP&ID=V20070822%2FJP%2Fgooto-22%2F8009%2F73cb6eea-490b-4a1f-be5a-b5d07172fbed&Operation=GetDisplayTemplate"><PARAM NAME="quality" VALUE="high"><PARAM NAME="bgcolor" VALUE="#FFFFFF"><PARAM NAME="allowscriptaccess" VALUE="always"><embed src="http://ws.amazon.co.jp/widgets/q?ServiceVersion=20070822&MarketPlace=JP&ID=V20070822%2FJP%2Fgooto-22%2F8009%2F73cb6eea-490b-4a1f-be5a-b5d07172fbed&Operation=GetDisplayTemplate" id="Player_73cb6eea-490b-4a1f-be5a-b5d07172fbed" quality="high" bgcolor="#ffffff" name="Player_73cb6eea-490b-4a1f-be5a-b5d07172fbed" allowscriptaccess="always"  type="application/x-shockwave-flash" align="middle" height="400px" width="160px"></embed></OBJECT> <NOSCRIPT><A HREF="http://ws.amazon.co.jp/widgets/q?ServiceVersion=20070822&MarketPlace=JP&ID=V20070822%2FJP%2Fgooto-22%2F8009%2F73cb6eea-490b-4a1f-be5a-b5d07172fbed&Operation=NoScript">Amazon.co.jp ウィジェット</A></NOSCRIPT><br>
<br>
<script type="text/javascript"><!--
amazon_ad_tag = "gooto-22"; amazon_ad_width = "160"; amazon_ad_height = "600"; amazon_ad_link_target = "new"; amazon_ad_price = "retail";//--></script>
<script type="text/javascript" src="http://www.assoc-amazon.jp/s/ads.js"></script><!-- サイドバー ここまで -->
</div><!-- / sidebar end -->
</center>
<br>
<!-- Begin Yahoo! JAPAN Web Services Attribution Snippet -->
<a href="http://developer.yahoo.co.jp/about">
<img src="http://i.yimg.jp/images/yjdn/yjdn_attbtn1_125_17.gif" title="Webサービス by Yahoo! JAPAN" alt="Web Services by Yahoo! JAPAN" width="125" height="17" border="0" style="margin:15px 15px 15px 15px"></a>
<!-- End Yahoo! JAPAN Web Services Attribution Snippet -->
<br>
wikipedia(SimpleAPI)の情報を利用しています。
<br>
END_OF_HTML

	return;
}

sub _smf_pc(){
	my $self = shift;

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

<!DOCTYPE html>
<html lang="ja">
<head>
	<meta charset="UTF-8">
	<title>スマフォナビ -PCアクセス-</title>
	<meta name="ROBOTS" content="NOINDEX, FOLLOW">
	<meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1, maximum-scale=1"/>
	<meta name="title" content="スマートフォンナビ PCアクセス" xml:lang="ja" lang="ja"/>
	<meta name="format-detection" content="telephone=no" />
<link rel="apple-touch-icon" href="http://s.waao.jp/img/home.png" />
<link rel="stylesheet" href="/css/smf.css" />
<link rel="stylesheet" href="/jquery.mobile-1.0a3.min.css" />
<script type="text/javascript" src="/jquery-1.5.min.js"></script>
<script type="text/javascript" src="/my.js"></script>
<script type="text/javascript" src="/jquery.mobile-1.0a3.min.js"></script>
</head>
<body>
<div id="home" data-role="page">
<div data-role="header"> 
<h1><a href="/" style="display: block;"><img src="/img/smftop.jpg" width=100% alt="MAX"></a></h1>
</div>
<div data-role="content">
<ul data-role="listview">
<li data-role="list-divider">PCアクセスエラー</li>
<br>
<center>
<img src="/img/E252_20.gif">スマフォMAXは、スマートフォンからしか見ることができません<img src="/img/E00F_20.gif">
</center>
<br>
スマフォMAXには、スマートフォンで見ることができる<img src="/img/E315_20.gif">情報が満載<img src="/img/E106_20_ani.gif"><br>
スマフォで、 http://smax.tv/ にアクセス<img src="/img/E330_20.gif"><br>

<br>
<li><img src="/img/E110_20.gif" height="20" class="ui-li-icon"><a href="/">スマートフォンナビTOP</a></li>
<li><img src="/img/blog.jpg" height="25" class="ui-li-icon"><a href="/blog/">$geinou人ブログ</a></li>
<li><img src="/img/twitter.png" height="25" class="ui-li-icon"><a href="/twitter/">有名人ツイッター</a></li>
<li><img src="/img/E151_20.gif" height="20" class="ui-li-icon"><a href="/person.htm">大人気！人物名鑑でもっと探す</a></li>
<li><img src="/img/E207_20.gif" height="20" class="ui-li-icon"><a href="http://s.goodgirl.jp/">おとなのスマフォ</a></li>
<li><img src="/img/E209_20.gif" height="20" class="ui-li-icon"><a href="/sitelist/">カテゴリ別に探す</a></li>
<li><img src="/img/E209_20.gif" height="20" class="ui-li-icon"><a href="http://y.brand-search.biz/">Y!ショッピング</a></li>
</ul>
</div>
<div id="footer">
<table border="0" width=100%><tr><td BGCOLOR="#FFFFFF">
<a href="http://waao.jp/privacy/"  target="_blank">プライバシーポリシー</a>｜
<a href="http://waao.jp/kiyaku/" alt="免責" target="_blank">免責</a>
<center><img src="/img/We_Aer_All_One.png"><br>- <a href="http://waao.jp/">http://waao.jp/</a> -</center>
</td></tr></table>
</div>

</div>
<script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-12681370-1']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>

</body>
</html>
END_OF_HTML

	return;
}
1;