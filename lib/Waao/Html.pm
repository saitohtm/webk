package Waao::Html;
use Waao::Ad;
use Waao::Utility;
use Exporter;
@ISA = (Exporter);
@EXPORT = qw(html_header html_footer html_hr html_google_ad html_yicha_url html_amazon_url html_table html_uwasa_type html_keyword_info html_sex_type html_age_type html_search_plus html_shopping_search_plus html_keyword_plus html_keyword_plus2 html_shopping_plus html_pc_2_mb melmaga_link html_table_black html_keyword_info2 html_link_no_robot html_mojibake_str html_keyword_info3 html_sitelist);

# $self->{html_title}
# $self->{html_keywords}
# $self->{html_description}
# $self->{html_body}
# $self->{html_hr}
# $self->{html_footertitle}
sub html_header(){
	my $self = shift;

	# xhtml対応
	if($self->{xhtml}){
print << "END_OF_HTML";
Content-type: application/xhtml+xml; charset=shift_jis

END_OF_HTML

		# docomo
		if($self->{access_type} eq 1){

print << "END_OF_HTML";
<?xml version="1.0" encoding="shift_jis"?>
<!DOCTYPE html PUBLIC "-//i-mode group (ja)//DTD XHTML
i-XHTML(Locale/Ver.=ja/1.0) 1.0//EN" "i-xhtml_4ja_10.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="ja" xml:lang="ja">
<head>
<meta http-equiv="Content-Type" content="application/xhtml+xml; charset=UTF-8" />
END_OF_HTML

		# au
		}elsif($self->{access_type} eq 2){

print << "END_OF_HTML";
<?xml version="1.0" encoding="shift_jis"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.0//EN"
"http://www.w3.org/TR/xhtml-basic/xhtml-basic10.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="ja" xml:lang="ja">
<head>
<meta http-equiv="Content-Type" content="application/xhtml+xml; charset=UTF-8" />
END_OF_HTML

		# softbank
		}elsif($self->{access_type} eq 3){

print << "END_OF_HTML";
<?xml version="1.0" encoding="shift_jis"?>
<!DOCTYPE html PUBLIC "-//J-PHONE//DTD XHTML Basic 1.0 Plus//EN"
"xhtml-basic10-plus.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="ja" xml:lang="ja">
<head>
<meta http-equiv="Content-Type" content="application/xhtml+xml; charset=UTF-8" />
END_OF_HTML

		}else{

print << "END_OF_HTML";
<?xml version="1.0" encoding="shift_jis"?>
<!DOCTYPE html PUBLIC "-//J-PHONE//DTD XHTML Basic 1.0 Plus//EN"
"xhtml-basic10-plus.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="ja" xml:lang="ja">
<head>
<meta http-equiv="Content-Type" content="application/xhtml+xml; charset=UTF-8" />
END_OF_HTML

		}
	}elsif($self->{access_type} eq 4){
#iphone
print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

<!DOCTYPE HTML PUBLIC "-//W3C//DTD Compact HTML 1.0 Draft //EN"> 
<html>
<head>
<meta http-equiv="content-type" CONTENT="text/html;charset=UTF-8">
<meta name="apple-mobile-web-app-capable">
<meta name="viewport" content="width=device-width" />  
END_OF_HTML


	}else{
print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

<!DOCTYPE HTML PUBLIC "-//W3C//DTD Compact HTML 1.0 Draft //EN"> 
<html>
<head>
<meta http-equiv="content-type" CONTENT="text/html;charset=UTF-8">
END_OF_HTML
	}
	

# 共通のmeta

my $googlemeta = qq{<meta name="google-site-verification" content="nUfdeL2U8b1jmAbvxf8A9JRrxM6HrIH0GMDKyJuA5GQ" />};
if($ENV{'SERVER_NAME'} eq 'x.waao.jp'){
	$googlemeta = qq{<meta name="google-site-verification" content="nUfdeL2U8b1jmAbvxf8A9JRrxM6HrIH0GMDKyJuA5GQ" />};
}
if($ENV{'SERVER_NAME'} eq 'wiki.waao.jp'){
	$googlemeta = qq{<meta name="google-site-verification" content="nUfdeL2U8b1jmAbvxf8A9JRrxM6HrIH0GMDKyJuA5GQ" />};
}
if($ENV{'SERVER_NAME'} eq 'chintai.goo.to'){
	$googlemeta = qq{<meta name="google-site-verification" content="QjNvJJqnNq6nQFTnVjwMuw56PZ95SMOoCEw17NTvj6Y" />};
}

if($ENV{'SERVER_NAME'} eq 'town.goo.to'){
	$googlemeta = qq{<meta name="google-site-verification" content="gFD1FnygNb4ar9IzD4rqGrvzWPn0R0Ab1-2PNu4i5mI" />};
}
if($ENV{'SERVER_NAME'} eq 'job.goo.to'){
	$googlemeta = qq{<meta name="google-site-verification" content="WXpyPjtetiG_-yOjmHYS8EbCVj245LQPxWqIiff8ffk" />};
}

if($ENV{'SERVER_NAME'} eq 'homes.goo.to'){
	$googlemeta = qq{<meta name="google-site-verification" content="FUdSewBp5OGQ4r6wnUnNkkMq0c4tiOWERHDSA-tNJe0" />};
}

if($ENV{'SERVER_NAME'} eq 'blog.tsukaeru.info'){
	$googlemeta = qq{<meta name="google-site-verification" content="rzbeE0LtYgvWgV9Nof69DnuUBK3EoURYnxU0KMorB4k" />};
}

if($ENV{'SERVER_NAME'} eq 'twitter.tsukaeru.info'){
	$googlemeta = qq{<meta name="google-site-verification" content="rzbeE0LtYgvWgV9Nof69DnuUBK3EoURYnxU0KMorB4k" />};
}

print << "END_OF_HTML";
<meta name="robots" content="index,follow">
<meta http-equiv="Expires" content="0">
<meta http-equiv="Pragma" CONTENT="no-cache">
<meta http-equiv="Cache-Control" CONTENT="no-cache">
$googlemeta
<meta name="msvalidate.01" content="03D3FBB9D4A35D9DBE64599CB7C4669A" />
END_OF_HTML

if($self->{html_keywords}){
print << "END_OF_HTML";
<meta name="keywords" content="$self->{html_keywords}">
END_OF_HTML
}

if($self->{html_description}){
print << "END_OF_HTML";
<meta name="description" content="$self->{html_description}">
END_OF_HTML
}

if($self->{html_title}){
print << "END_OF_HTML";
<title>$self->{html_title}</title>
END_OF_HTML
}else{
print << "END_OF_HTML";
<title>みんなのモバイル - waao.jp -</title>
END_OF_HTML
}

print << "END_OF_HTML";
</head>
END_OF_HTML

if($self->{html_body}){
print << "END_OF_HTML";
$self->{html_body}
END_OF_HTML
}else{
print << "END_OF_HTML";
<body>
END_OF_HTML
}

	
	return;
}

sub html_footer(){
	my $self = shift;
	my $no_img=shift;

	&html_hr($self);
	
	# 検索ワードチョイス
my $memkey = "trendperson";
my $today_trend;
$today_trend = $self->{mem}->get( $memkey );
print << "END_OF_HTML";
<font size=1>
END_OF_HTML

if($today_trend){
	my $cnt = 0;
#<a href="http://waao.jp/$str_encode/search/">$keyword</a> 
	foreach my $keyword (@{$today_trend->{rank}}){
		$cnt++;
		my $str_encode = &str_encode($keyword);
print << "END_OF_HTML";
<a href="http://waao.goo.to/$str_encode/" title="$keyword">$keyword</a> 
END_OF_HTML
		last if($cnt >=20 );
	}
}

print << "END_OF_HTML";
<a href="http://blog.tsukaeru.info/">タレントブログ</a><br>
<a href="http://ana.goo.to/" title="アナウンサー名鑑">アナウンサー名鑑</a> 
</font>
END_OF_HTML
	
if($self->{html_footertitle}){
print << "END_OF_HTML";
<center>$self->{html_footertitle}</center>
END_OF_HTML
}else{
print << "END_OF_HTML";
<center><a href="http://waao.jp/" access_key=0>みんなのモバイル</a></center>
END_OF_HTML
}
unless($no_img){
	if($ENV{'REMOTE_HOST'} =~/ezweb/i){
print << "END_OF_HTML";
<center><img src="http://img.waao.jp/logo.jpg" alt="waao.jp"></center>
END_OF_HTML
	}else{
print << "END_OF_HTML";
<center><img src="http://img.waao.jp/logo.jpg" alt="waao.jp"></center>
END_OF_HTML
	}
}

print << "END_OF_HTML";
<a href="/">http://waao.jp/</a>
END_OF_HTML

if($self->{real_mobile}){
print '<img src="' . google_analytics_get_image_url() . '" />';
}

	# ユニーククリック対策
	&_uniq_click($self);

print << "END_OF_HTML";
</body>
</html>
END_OF_HTML

	return;
}

# 
sub html_hr(){
	my $self = shift;
	my $type = shift;
	
	my $hr;
	if($self->{html_hr}){
		$hr = $self->{html_hr};
	}else{
		$hr = qq{<hr color="#009525">};
	}

	if($type){
		return $hr;
	}else{
print << "END_OF_HTML";
$hr
END_OF_HTML
	}
	return;
}

sub _uniq_click(){
	my $self =shift;

	my $click;
	if($self->{access_type} eq 1){
		# DoCoMo
	}elsif($self->{access_type} eq 2){
		# Au
	}elsif($self->{access_type} eq 3){
		# SoftBank
#		$click .= qq{<img src="http://redirect.tsukaeru.info/?http://j.chintai.net/?uid=1&sid=A209&pid=P122" width=0 height=0>};
	}
	
		$click .= qq{<img src="http://ameblo.jp/saitohtm/" width=0 height=0>};
		$click .= qq{<img src="http://ameblo.jp/nsr250-se/" width=0 height=0>};

print << "END_OF_HTML";
$click
END_OF_HTML
	
	return;
}

sub html_google_ad(){
	my $self = shift;

	my $ad = &get_google_ad($self);

	return $ad;
}

sub html_yicha_url(){
	my $self = shift;
	my $str  = shift;
	my $type = shift;
	
	my $ad = &get_yicha_url($self,$str,$type);

	return $ad;
}

sub html_amazon_url(){
	my $self = shift;
	my $str  = shift;

	my $ad = &get_amazon_ad($self,$str);

	return $ad;
}

sub html_table(){
	my $self = shift;
	my $message = shift;
	my $centerflag = shift;
	my $fontsize = shift;

	if($self->{real_mobile}){
		$message =~s/<h1>//ig;
		$message =~s/<\/h1>//ig;
	}
	
	my $str;
	$str .= qq{<table border=0 bgcolor="#DFFFBF" width="100%"><tr><td>};
	$str .= qq{<center>} if($centerflag);
	$str .= qq{<font size=1>} if($fontsize);
	$str .= qq{$message};
	$str .= qq{</font>} if($fontsize);
	$str .= qq{</center>} if($centerflag);
	$str .= qq{<br>} unless($centerflag);
	$str .= qq{</td></tr></table>};

print << "END_OF_HTML";
$str
END_OF_HTML

	return;
}

sub html_table_black(){
	my $self = shift;
	my $message = shift;
	my $centerflag = shift;
	my $fontsize = shift;

	if($self->{real_mobile}){
		$message =~s/<h1>//ig;
		$message =~s/<\/h1>//ig;
	}
	
	my $str;
	$str .= qq{<table border=0 bgcolor="#000000" width="100%"><tr><td>};
	$str .= qq{<center>} if($centerflag);
	$str .= qq{<font size=1>} if($fontsize);
	$str .= qq{$message};
	$str .= qq{</font>} if($fontsize);
	$str .= qq{</center>} if($centerflag);
	$str .= qq{<br>} unless($centerflag);
	$str .= qq{</td></tr></table>};

print << "END_OF_HTML";
$str
END_OF_HTML

	return;
}
sub html_uwasa_type(){
	my $type = shift;
	
	return qq{と恋人}   if($type eq 1);
	return qq{と元恋人} if($type eq 2);
	return qq{と夫婦}   if($type eq 3);
	return qq{と友人}   if($type eq 4);
	return qq{が好き}   if($type eq 5);
	return qq{が嫌い}   if($type eq 6);
	return qq{とメル友倞} if($type eq 7);
	return qq{と親子}   if($type eq 8);
	return qq{と兄弟/姉妹} if($type eq 9);
	return qq{と共演者}   if($type eq 10);
	return qq{と同郷}     if($type eq 11);
	return qq{と同じ事務所} if($type eq 12);
	return qq{と元夫婦} if($type eq 13);
	return qq{とライバル} if($type eq 14);
	return qq{と同年代}   if($type eq 15);

	return;
}

sub html_keyword_info(){
	my $self = shift;
	my $keyworddata = shift;
	my $photodata   = shift;
	my $keyword = $keyworddata->{keyword};

	my $keyword_encode = &str_encode($keyworddata->{keyword});

	my $ad_yicha_site = &html_yicha_url($self, $keyworddata->{keyword}, 'p');
	my $ad_yicha_video = &html_yicha_url($self, $keyworddata->{keyword}, 'v');
	my $ad_yicha_image = &html_yicha_url($self, $keyworddata->{keyword}, 'i');
	my $ad_yicha_music = &html_yicha_url($self, $keyworddata->{keyword}, 'm');

	my $domain = qq{http://waao.jp};
	if($ENV{'SERVER_NAME'} eq 'waao.jp'){
		$domain = undef;
	}
	my $wikilink;
	if($keyworddata->{wiki_id}){
		if($keyworddata->{person}){
			$wikilink = qq{<a href="$domain/$keyword_encode/wiki/$keyworddata->{wiki_id}/">人物</a><br>} 
		}else{
			$wikilink = qq{<a href="$domain/$keyword_encode/wiki/$keyworddata->{wiki_id}/">wikipedia</a><br>} 
		}
	}
	my $blogurl = qq{<a href="$keyworddata->{blogurl}">公式ブログ</a><br>} if($keyworddata->{blogurl});

if($self->{access_type} eq 4){
	# 画像がある場合
	if($photodata){
		# 画像はリアルモバイルのみ
		$photodata->{url} = qq{http://img.waao.jp/noimage95.gif} unless( $self->{real_mobile} );
		if($keyworddata->{photo}){
print << "END_OF_HTML";
<a href="$domain/$keyword_encode/photolist/0-1/"><img src="$keyworddata->{photo}"  width=125  style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"></a>
<a href="$domain/$keyword_encode/photolist/0-1/">画像一覧</a><br>
END_OF_HTML
		}else{
print << "END_OF_HTML";
<a href="$domain/$keyword_encode/photolist/0-1/"><img src="$photodata->{url}"  width=125  style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"></a>
<a href="$domain/$keyword_encode/photolist/0-1/">画像一覧</a><br>
END_OF_HTML
		}
	}else{
print << "END_OF_HTML";
<img src="http://img.waao.jp/ol03s.gif" width=125 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left">
END_OF_HTML
	}

print << "END_OF_HTML";
$wikilink
$blogurl
<a href="$domain/$keyword_encode/uwasa/" title="$keywordのうわさ">うわさ</a><br>
<a href="$domain/$keyword_encode/qanda/" title="$keywordのQ&A">Q&A</a><br>
<a href="$domain/$keyword_encode/bookmark/" title="$keywordのモバイルサイト">モバイルサイト</a><br>
<a href="$domain/$keyword_encode/bbs/" title="$keywordの掲示板">掲示板</a><br>
<a href="$domain/$keyword_encode/shopping/" title="$keywordの関連商品">関連商品</a><br>
<a href="$domain/$keyword_encode/news/" title="$keywordの関連ニュース">関連ニュース</a><br>
<br clear="all" />
<center>
<img src="http://img.waao.jp/kya-.gif" widht=15 height=15> <a href="$ad_yicha_site">オススメ</a> 
<a href="$ad_yicha_video">動画</a> 
<a href="$ad_yicha_image">画像</a> 
<a href="$ad_yicha_music">音楽</a> 
</center>
END_OF_HTML
}else{
	# 画像がある場合
	if($photodata){
		# 画像はリアルモバイルのみ
		$photodata->{url} = qq{http://img.waao.jp/noimage95.gif} unless( $self->{real_mobile} );
print << "END_OF_HTML";
<a href="$domain/$keyword_encode/photo/$photodata->{id}/"><img src="$photodata->{url}"  width=95  style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"></a>
<font size=1>
<a href="$domain/$keyword_encode/photolist/0-1/">画像一覧</a><br>
END_OF_HTML

	}else{
print << "END_OF_HTML";
<img src="http://img.waao.jp/ol03s.gif" width=75 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left">
<font size=1>
END_OF_HTML
	}

print << "END_OF_HTML";
$wikilink
$blogurl
<a href="$domain/$keyword_encode/uwasa/" title="$keywordのうわさ">うわさ</a><br>
<a href="$domain/$keyword_encode/qanda/" title="$keywordのQ&A">Q&A</a><br>
<a href="$domain/$keyword_encode/bookmark/" title="$keywordのモバイルサイト">モバイルサイト</a><br>
<a href="$domain/$keyword_encode/bbs/" title="$keywordの掲示板">掲示板</a><br>
<a href="$domain/$keyword_encode/shopping/" title="$keywordの関連商品">関連商品</a><br>
<a href="$domain/$keyword_encode/news/" title="$keywordの関連ニュース">関連ニュース</a><br>
</font>
<br clear="all" />
<center>
<img src="http://img.waao.jp/kya-.gif" widht=15 height=15> <a href="$ad_yicha_site">オススメ</a> 
<a href="$ad_yicha_video">動画</a> 
<a href="$ad_yicha_image">画像</a> 
<a href="$ad_yicha_music">音楽</a> 
</center>
END_OF_HTML
}
	return;
}

sub html_keyword_info2(){
	my $self = shift;
	my $keyword = shift;
	my $keyword_encode = &str_encode($keyword);

	my $ad_yicha_site = &html_yicha_url($self, $keyword, 'p');
	my $ad_yicha_video = &html_yicha_url($self, $keyword, 'v');
	my $ad_yicha_image = &html_yicha_url($self, $keyword, 'i');
	my $ad_yicha_music = &html_yicha_url($self, $keyword, 'm');

print << "END_OF_HTML";
<center>
<img src="http://img.waao.jp/kya-.gif" widht=15 height=15> <a href="$ad_yicha_site">オススメ</a> 
<a href="$ad_yicha_video">動画</a> 
<a href="$ad_yicha_image">画像</a> 
<a href="$ad_yicha_music">音楽</a> 
</center>
END_OF_HTML

	return;
}

sub html_keyword_info3(){
	my $self = shift;
	my $keyworddata = shift;
	my $photodata   = shift;
	my $keyword = $keyworddata->{keyword};
	my $keyword_encode = &str_encode($keyworddata->{keyword});

	my $ad_yicha_site = &html_yicha_url($self, $keyworddata->{keyword}, 'p');
	my $ad_yicha_video = &html_yicha_url($self, $keyworddata->{keyword}, 'v');
	my $ad_yicha_image = &html_yicha_url($self, $keyworddata->{keyword}, 'i');
	my $ad_yicha_music = &html_yicha_url($self, $keyworddata->{keyword}, 'm');

	my $wikilink;
	if($keyworddata->{wiki_id}){
		if($keyworddata->{person}){
			$wikilink = qq{<a href="http://waao.jp/$keyword_encode/wiki/$keyworddata->{wiki_id}/">人物</a><br>} 
		}else{
			$wikilink = qq{<a href="http://waao.jp/$keyword_encode/wiki/$keyworddata->{wiki_id}/">wikipedia</a><br>} 
		}
	}
	my $blogurl = qq{<a href="$keyworddata->{blogurl}">公式ブログ</a><br>} if($keyworddata->{blogurl});

if($self->{access_type} eq 4){
	# 画像がある場合
	if($photodata){
		# 画像はリアルモバイルのみ
		$photodata->{url} = qq{http://img.waao.jp/noimage95.gif} unless( $self->{real_mobile} );
print << "END_OF_HTML";
<a href="http://waao.jp/$keyword_encode/photolist/0-1/"><img src="$photodata->{url}"  width=125  style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"></a>
<a href="http://waao.jp/$keyword_encode/photolist/0-1/">画像一覧</a><br>
END_OF_HTML

	}else{
print << "END_OF_HTML";
<img src="http://img.waao.jp/ol03s.gif" width=125 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left">
END_OF_HTML
	}

print << "END_OF_HTML";
$wikilink
$blogurl
<a href="http://waao.jp/$keyword_encode/uwasa/" title="$keywordのうわさ">うわさ</a><br>
<a href="http://waao.jp/$keyword_encode/qanda/" title="$keywordのQ&A">Q&A</a><br>
<a href="http://waao.jp/$keyword_encode/bookmark/" title="$keywordのモバイルサイト">モバイルサイト</a><br>
<a href="http://waao.jp/$keyword_encode/bbs/" title="$keywordの掲示板">掲示板</a><br>
<a href="http://waao.jp/$keyword_encode/shopping/" title="$keywordの関連商品">関連商品</a><br>
<a href="http://waao.jp/$keyword_encode/news/" title="$keywordの関連ニュース">関連ニュース</a><br>
<br clear="all" />
<center>
<img src="http://img.waao.jp/kya-.gif" widht=15 height=15> <a href="$ad_yicha_site">オススメ</a> 
<a href="$ad_yicha_video">動画</a> 
<a href="$ad_yicha_image">画像</a> 
<a href="$ad_yicha_music">音楽</a> 
</center>
END_OF_HTML
}else{
	# 画像がある場合
	if($photodata){
		# 画像はリアルモバイルのみ
		$photodata->{url} = qq{http://img.waao.jp/noimage95.gif} unless( $self->{real_mobile} );
print << "END_OF_HTML";
<a href="http://waao.jp/$keyword_encode/photo/$photodata->{id}/"><img src="$photodata->{url}"  width=95  style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"></a>
<font size=1>
<a href="http://waao.jp/$keyword_encode/photolist/0-1/">画像一覧</a><br>
END_OF_HTML

	}else{
print << "END_OF_HTML";
<img src="http://img.waao.jp/ol03s.gif" width=75 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left">
<font size=1>
END_OF_HTML
	}

print << "END_OF_HTML";
$wikilink
$blogurl
<a href="http://waao.jp/$keyword_encode/uwasa/" title="$keywordのうわさ">うわさ</a><br>
<a href="http://waao.jp/$keyword_encode/qanda/" title="$keywordのQ&A">Q&A</a><br>
<a href="http://waao.jp/$keyword_encode/bookmark/" title="$keywordのモバイルサイト">モバイルサイト</a><br>
<a href="http://waao.jp/$keyword_encode/bbs/" title="$keywordの掲示板">掲示板</a><br>
<a href="http://waao.jp/$keyword_encode/shopping/" title="$keywordの関連商品">関連商品</a><br>
<a href="http://waao.jp/$keyword_encode/news/" title="$keywordの関連ニュース">関連ニュース</a><br>
</font>
<br clear="all" />
<center>
<img src="http://img.waao.jp/kya-.gif" widht=15 height=15> <a href="$ad_yicha_site">オススメ</a> 
<a href="$ad_yicha_video">動画</a> 
<a href="$ad_yicha_image">画像</a> 
<a href="$ad_yicha_music">音楽</a> 
</center>
END_OF_HTML
}
	return;
}

sub html_sex_type(){
	my $sex = shift;
	
	my $sextxt;
	
	if($sex eq 1){
		$sextxt = qq{男};
	}elsif($sex eq 2){
		$sextxt = qq{女};
	}

	return $sextxt;
}

sub html_age_type(){
	my $age = shift;
	
	my $agetxt;
	
	if($age eq 1){
		$agetxt = qq{10代};
	}elsif($age eq 2){
		$agetxt = qq{20代};
	}elsif($age eq 3){
		$agetxt = qq{30代};
	}elsif($age eq 4){
		$agetxt = qq{40代};
	}elsif($age eq 5){
		$agetxt = qq{50代};
	}

	return $agetxt;
}

sub html_search_plus(){
	my $self = shift;
	my $keyword = shift;

	my $keyword_encode = &str_encode($keyword);
	
	my $ad_yicha_site = &html_yicha_url($self, $keyword, 'p');
	my $ad_yicha_video = &html_yicha_url($self, $keyword, 'v');
	my $ad_yicha_image = &html_yicha_url($self, $keyword, 'i');
	my $ad_yicha_music = &html_yicha_url($self, $keyword, 'm');
	my $ad_amazon = &html_amazon_url($self, $keyword);

&html_table($self, qq{<img src="http://img.waao.jp/mb17.gif" width=11 height=12><font color="#00968c">$keyword</font><font color="#FF0000">プラス</font>}, 0, 0);

print << "END_OF_HTML";
<font size=1>$keywordをもっと知りたい人</font><br>
<center>
<a href="$ad_yicha_site">$keyword<font color="#FF0000">餅彌</font></a><br>
<img src="http://img.waao.jp/kaoonegai01t.gif" width=77 height=15>
</center>
<font size=1>
他のオススメ<strong>検索</strong>サイト<br>
<a href="/$keyword_encode/google/">Googleで探す</a><br>
<a href="/$keyword_encode/yahoo/">Yahoo!で探す</a><br>
<a href="$ad_amazon">amazonで探す</a><br>
<a href="/$keyword_encode/goo/">gooで探す</a><br>
<a href="/$keyword_encode/froute/">Frouteで探す</a><br>
</font>
END_OF_HTML

	return;
}

sub html_shopping_search_plus(){
	my $self = shift;
	my $keyword = shift;
	my $keyword_encode = &str_encode($keyword);

&html_table($self, qq{$keyword専門店}, 0, 0);
print << "END_OF_HTML";
<font color="#FF0000">$keyword</font>の通販商品情報を更に詳しく検索できます<br>
<a href="/$keyword_encode/yahooshopping/">Yahoo!で探す</a><br>
<a href="/$keyword_encode/amazon/">amazonで探す</a><br>
<a href="/$keyword_encode/rakuten/">楽天で探す</a><br>
END_OF_HTML

	return;
}

sub html_keyword_plus(){
	my $self = shift;
	my $keyworddata = shift;
	my $keyword = $keyworddata->{keyword};
	my $keyword_encode = &str_encode($keyword);
	my @val = split(/\t/,$keyworddata->{yahookeyword});
	my @val1 = split(/\t/,$keyworddata->{googlekeyword});
	push @val, @val1;

	return if($#val < 1);
&html_table($self, qq{<img src="http://img.waao.jp/kao-a08.gif" width=15 height=15><font color="#00968c">$keyword</font><font color="#FF0000">関連ワード</font>}, 0, 0);

print << "END_OF_HTML";
<font size=1>
みんなはこんなキーワードで検索しているヨ<br>
END_OF_HTML
	foreach my $value (@val){
		my $url;
		if($self->{real_mobile}){
			$url = &get_yicha_url($self, $value);
		}else{
			$value =~s/$keyword//g;
			$value =~s/ //g;
			my $val_encode = &str_encode($value);
			$url = qq{/$keyword_encode/search/words/$val_encode/};
		}
print << "END_OF_HTML";
<a href="$url">$value</a> 
END_OF_HTML
	}
print << "END_OF_HTML";
</font>
END_OF_HTML
	
	return;
}
sub html_keyword_plus2(){
	my $self = shift;
	my $keyworddata = shift;
	my $keyword = $keyworddata->{keyword};
	my $keyword_id = $keyworddata->{id};
	my $keyword_encode = &str_encode($keyword);
&html_table($self, qq{<img src="http://img.waao.jp/kao-a08.gif" width=15 height=15><font color="#00968c">$keyword</font><font color="#FF0000">関連ワード</font>}, 0, 0);

print << "END_OF_HTML";
<font size=1>
みんなはこんなキーワードで検索しているヨ<br>
END_OF_HTML
	my @val = split(/\t/,$keyworddata->{yahookeyword});
	my $cnt;
	foreach my $value (@val){
		my $url;
		$cnt++;
		if($self->{real_mobile}){
			$url = &get_yicha_url($self, $value);
		}else{
			$value =~s/$keyword//g;
			$value =~s/ //g;
			my $val_encode = &str_encode($value);
			$url = qq{/$keyword_encode/real/$keyword_id/1-$cnt/};
		}
print << "END_OF_HTML";
<a href="$url">$value</a> 
END_OF_HTML
	}

	my @val = split(/\t/,$keyworddata->{googlekeyword});
	my $cnt;
	foreach my $value (@val){
		my $url;
		$cnt++;
		if($self->{real_mobile}){
			$url = &get_yicha_url($self, $value);
		}else{
			$value =~s/$keyword//g;
			$value =~s/ //g;
			my $val_encode = &str_encode($value);
			$url = qq{/$keyword_encode/real/$keyword_id/1-$cnt/};
		}
print << "END_OF_HTML";
<a href="$url">$value</a> 
END_OF_HTML
	}


print << "END_OF_HTML";
</font>
END_OF_HTML
	
	return;
}

sub html_shopping_plus(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('q');

	return unless($self->{real_mobile});

use XML::Simple;
use LWP::Simple;
use Waao::Api;
use Jcode;
use CGI qw( escape );
	my $yahooapi = &yahoo_api();

	my $keyword_utf8 = $keyword;
	Encode::from_to($keyword_utf8,'cp932','utf8');
	$keyword_utf8 = escape ( $keyword_utf8 );
	
	my $url = qq{http://shopping.yahooapis.jp/ShoppingWebService/V1/itemSearch};
	$url .= qq{?appid=}.$yahooapi->{appid};
	$url .= qq{&affiliate_type=yid&affiliate_id=}.$yahooapi->{affiliate_id};
	$url .= qq{&query=$keyword_utf8};
	$url .= qq{&hits=5&availability=1&price_from=1000};

my ($response, $xml, $yahoo_xml);
eval{
	$response = get($url);
	$xml = new XML::Simple;
	$yahoo_xml = $xml->XMLin($response);
};

	return if( $yahoo_xml->{totalResultsReturned} < 1);

&html_table($self, qq{<img src="http://img.waao.jp/mb17.gif" width=15 height=15><font color="#00968c">$keyword</font><font color="#FF0000">欺述</font>}, 0, 0);

print << "END_OF_HTML";
<center>
END_OF_HTML
	my $cnt;
	foreach my $result (@{$yahoo_xml->{Result}->{Hit}}) {
		my $link_url = qq{$result->{Url}};
		next unless($result->{Image});
		# 画像処理
		my $img_url;
		if($result->{Image}->{Small}){
			$img_url = $result->{Image}->{Small};
		}else{
			next;
		}
		last if($cnt >=3);
print << "END_OF_HTML";
<a href="$link_url"><img src="$img_url" width=70 height=70></a>
END_OF_HTML
		$cnt++;
	}
print << "END_OF_HTML";
</center>
END_OF_HTML

	return;
}

sub html_pc_2_mb(){
	my $url = shift;
	
	my $encode_url = &str_encode($url);
	$url = qq{http://www.google.co.jp/gwt/n?u=}.$encode_url;
	return $url;
}

sub melmaga_link(){
	my $self = shift;

	my $linktag;
	my $randcnt = int(rand(5));

	if( $randcnt eq 1 ){
print << "END_OF_HTML";
<center>
<a href="mailto:mg-141795s\@sgw.st"><font color="#FF0000">無料</font>で読めるメルマガ<br>有名人の恋愛事情<br>登録は、空メール送信<br></a>
</center>
END_OF_HTML
	}elsif( $randcnt eq 2 ){
print << "END_OF_HTML";
<center>
<a href="mailto:mg-141795s\@sgw.st">
毎日配信エンタメ速報<br>
登録はもちろん無料<br>
今すぐ空メール送信倞<br>
</a>
</center>
END_OF_HTML

	}else{
print << "END_OF_HTML";
<center>
<a href="mailto:mg-141795s\@sgw.st">他では手に入らない<br>エンタメニュース速報!メルマガ倞<br><font color="#FF0000">無料登録</font>は空メール<br></a>
</center>
END_OF_HTML
	}

	return $linktag;
}


# Copyright 2009 Google Inc. All Rights Reserved.
use URI::Escape;
use constant GA_ACCOUNT => 'MO-4170130-2';
use constant GA_PIXEL => '/ga.html';

sub google_analytics_get_image_url {
  my $url = '';
  $url .= GA_PIXEL . '?';
  $url .= 'utmac=' . GA_ACCOUNT;
  $url .= '&utmn=' . int(rand(0x7fffffff));
  my $referer = $ENV{'HTTP_REFERER'};
  my $query = $ENV{'QUERY_STRING'};
  my $path = $ENV{'REQUEST_URI'};
  if ($referer eq "") {
    $referer = '-';
  }
  $url .= '&utmr=' . uri_escape($referer);
  $url .= '&utmp=' . uri_escape($path);
  $url .= '&guid=ON';
  $url =~ s/&/&amp;/g;
  $url;
}

sub html_link_no_robot(){
	my $self = shift;
	my $url = shift;

use URI::Escape;
	
	unless($self->{real_mobile}){
		my $keyword = $self->{cgi}->param('q');
		if($keyword){
			my $encode_keyword = uri_escape($keyword);
			$url = qq{http://waao.jp/$encode_keyword/search/};
		}else{
			$url = qq{http://waao.jp/};
		}
	}
	
	return $url;
}
sub html_mojibake_str(){
	my $tmpl = shift;
	
my $file = qq{/var/www/vhosts/waao.jp/tmpl/$tmpl};
my $fh;
my $filedata;
open( $fh, "<", $file );
while( my $line = readline $fh ){ 
	$filedata .= $line;
}
close ( $fh );

	return $filedata;
}

sub html_sitelist(){
	my $self = shift;
	my $keyword = shift;
	my $keyword_id = shift;
	my $cnt  = shift;
	return unless($keyword_id);
	$cnt = 30 unless($cnt);

&html_table($self, qq{<img src="http://img.waao.jp/mb17.gif" width=15 height=15><font color="#00968c">$keyword</font><font color="#FF0000">人気サイト</font>}, 0, 0);
	my $str_encode = &str_encode($keyword);

	my $sth = $self->{dbi}->prepare(qq{ select id,title,url,comment from sitelist where keyword_id = ? order by cnt desc limit $cnt} );
	$sth->execute($keyword_id);
	while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<a href="/$str_encode/bookmark/$row[0]/">$row[1]</a><br>
END_OF_HTML

	}

	return;
}
1;

