package Waao::Pages::Site::Photo;
use Exporter;
@ISA = (Exporter);
@EXPORT = qw(image_index);
use Waao::Html;
use Waao::Utility;
use Waao::Ad;

sub image_index(){
	my $self = shift;

	#ドメイン設定
	# q=keyword p1=date p2=word
	my $domain = $ENV{'SERVER_NAME'};

	if($self->{cgi}->param('q')){
		&_image($self);
	}else{
		&_top( $self );
	}
	return;
}

sub _get_banner_ad(){
	my $self = shift;
	
	my $ad_str = qq{<center><a href="http://cgi.i-mobile.co.jp/ad_link.aspx?guid=on&asid=22272&pnm=0&asn=1"><img border="0" src="http://cgi.i-mobile.co.jp/ad_img.aspx?guid=on&asid=22272&pnm=0&asn=1&asz=0&atp=3&lnk=6666ff&bg=&txt=000000" alt="i-mobile"></a><br>
</center>};
	
	return $ad_str;
}

sub _get_define(){
	my $self = shift;

	my ($title, $sitename, $googlemeta);
	my $geinou = &html_mojibake_str('geinou');

	$title = qq{$geinou人の画像検索 -QVGA検索-};
	$sitename = qq{$geinou人の画像検索};
	$googlemeta = qq{<meta name="google-site-verification" content="jgZ29RAGdFN0r3L3lpajdbZV19kRJmyHR3tzPARdnig" />\n};

$googlemeta = qq{<head>\n}.$googlemeta;
$googlemeta .= qq{<meta http-equiv="content-type" CONTENT="text/html;charset=UTF-8">\n};
$googlemeta .= qq{<meta name="robots" content="index,follow">\n};
$googlemeta .= qq{<meta http-equiv="Expires" content="0">\n};
$googlemeta .= qq{<meta http-equiv="Pragma" CONTENT="no-cache">\n};
$googlemeta .= qq{<meta http-equiv="Cache-Control" CONTENT="no-cache">\n};

	return($title, $sitename, $googlemeta);
}

sub _top(){
	my $self = shift;
	
	my $geinou = &html_mojibake_str('geinou');
	my ($title, $sitename, $googlemeta) = &_get_define();
	my $hr = qq{<hr color="#007495" noshade>};

	my $ad_str = &_get_banner_ad($self);
	my $date = $self->{date_yyyy_mm_dd};
	my $startid = int(rand(178282));
print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

<!DOCTYPE html PUBLIC "-//i-mode group (ja)//DTD XHTML i-XHTML(Locale/Ver.=ja/2.1) 1.0//EN" "i-xhtml_4ja_10.dtd">
<html>
$googlemeta
<title>$title</title>
</head>
<body>
<marquee bgcolor="black" loop="INFINITY"><font color="#FF9900">$sitename：$title</font></marquee>
<table border=0 bgcolor="#FFFFEA" width="100%">
<tr>
<td>
<center>
<h1>$sitename</h1>
<h2><font size=1>$title</font></h2>
</center>
</td></tr>
</table>
$hr
$ad_str
$hr
<strong>$geinou人</strong>画像TOP10<br>
END_OF_HTML

my $sth = $self->{dbi}->prepare(qq{ select keyword, id from keyword order by cnt desc limit 10} );
$sth->execute();
while(my @row = $sth->fetchrow_array) {
	my $str_encode = &str_encode($row[0]);
print << "END_OF_HTML";
<a href="/$str_encode/$date/$row[1]/"><font color="#333333">$row[0]の画像</font></a> 
END_OF_HTML

}

my $randstr1;
my $randstr2;

my $rand_id = int(rand(30));
my $start = 20 + $rand_id * 5;
my $sth = $self->{dbi}->prepare(qq{ select keyword, id from keyword order by cnt desc limit $start, 10} );
$sth->execute();
while(my @row = $sth->fetchrow_array) {
	my $str_encode = &str_encode($row[0]);
	$randstr1 .=qq{<a href="/$str_encode/$date/$row[1]/">$row[0]の画像</a> };
	$randstr2 .=qq{<a href="http://waao.jp/$str_encode/search/"><font color="#333333">$row[0]の画像</font></a> };
}


print << "END_OF_HTML";
$hr
オススメ<br>
$randstr1
END_OF_HTML


# ランダム掲示板(bbs.goo.to)
print << "END_OF_HTML";
$hr
欺述欺述2<br>
$randstr2
END_OF_HTML


print << "END_OF_HTML";
$hr
德<a href="/" accesskey=0>$sitename眺餅</a><br>
<a href="http://waao.jp/imagesearch/">画像検索</a><br>
$hr
無料OVGA画像検索は、無料で利用できる携帯専用の$geinou人の画像検索エンジンです。<br>
さまざまなジャンルやタレントのお宝画像を探すことができます！<br>
いつでもどこでも高画質なQVGA画像を見たい人は、無料で使える携帯画像検索を使ってみてください<br>
<table border="0" width=100%>
<tr>
<td BGCOLOR="#E9E9E9">
<center>
(c)<strong><a href="http://waao.jp/imagesearch/">$sitename</font></strong>
</center>
</td></tr>
</table>
<font color="#D4D4D4" size=1>
※無料画像検索は、携帯専用の画像検索エンジンです。<br>
</font>
</body>
</html>
END_OF_HTML

return;
}

sub _image(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('q');
	my $str_encode = &str_encode($keyword);
	my $date = $self->{cgi}->param('p1');
	my $keyword_id = $self->{cgi}->param('p2');

	my $geinou = &html_mojibake_str('geinou');
	my ($title, $sitename, $googlemeta) = &_get_define();
	my $hr = qq{<hr color="#007495" noshade>};

	my $ad_str = &_get_banner_ad($self);
	
	my $date = $self->{date_yyyy_mm_dd};
	
unless($keyword_id){
	my $sth = $self->{dbi}->prepare(qq{ select id, yahookeyword from keyword where keyword = ? limit 1} );
	$sth->execute($keyword);
	while(my @row = $sth->fetchrow_array) {
		$keyword_id = $row[0];
	}
}

my $image_url=qq{http://waao.jp/?guid=on&q=$str_encode};

if($self->{real_mobile}){
	$image_url = &get_yicha_url("$keywordの画像",'p');
}
print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

<!DOCTYPE html PUBLIC "-//i-mode group (ja)//DTD XHTML i-XHTML(Locale/Ver.=ja/2.1) 1.0//EN" "i-xhtml_4ja_10.dtd">
<html>
$googlemeta
<title>$keywordの画像 -$date更新-</title>
</head>
<body>
<marquee bgcolor="black" loop="INFINITY"><font color="#FF9900">$keywordの画像：$title</font></marquee>
<table border=0 bgcolor="#FFFFEA" width="100%">
<tr>
<td>
<center>
<h1>$keyword</h1>
<h2><font size=1>$keywordの画像</font></h2>
</center>
</td></tr>
</table>
$hr
$ad_str
$hr
$keyword画像<br>
<font size=1>$keywordの画像がたくさん探せます。</font><br>
<br>
<br>
<img src="http://img.waao.jp/m2009.gif" width=48 height=9><a href="$image_url">$keywordの画像</a>
<br>
<br>
<br>
<font size=1>$keywordの画像でお楽しみください。</font><br>
$hr
$ad_str

END_OF_HTML

my $randstr1;
my $randstr2;

my $rand_id = int(rand(30));
my $start = 20 + $rand_id * 5;
my $sth = $self->{dbi}->prepare(qq{ select keyword, id from keyword order by cnt desc limit $start, 10} );
$sth->execute();
while(my @row = $sth->fetchrow_array) {
	my $str_encode = &str_encode($row[0]);
	$randstr1 .=qq{<a href="/$str_encode/$date/$row[1]/">$row[0]の画像</a> };
	$randstr2 .=qq{<a href="http://waao.jp/$str_encode/search/"><font color="#333333">$row[0]</font>の画像</a> };
}

print << "END_OF_HTML";
$hr
オススメ画像<br>
$randstr1
END_OF_HTML


# ランダム掲示板(bbs.goo.to)
print << "END_OF_HTML";
$hr
欺述2<br>
$randstr2
END_OF_HTML


print << "END_OF_HTML";
$hr
德<a href="/" accesskey=0>$sitename眺餅</a><br>
<a href="http://waao.jp/imagesearch/">画像検索</a><br>
$hr
無料OVGA画像検索は、無料で利用できる携帯専用の$geinou人の画像検索エンジンです。<br>
さまざまなジャンルやタレントのお宝画像を探すことができます！<br>
いつでもどこでも高画質なQVGA画像を見たい人は、無料で使える携帯画像検索を使ってみてください<br>
<table border="0" width=100%>
<tr>
<td BGCOLOR="#E9E9E9">
<center>
(c)<strong><a href="http://waao.jp/imagesearch/">$keyword画像</font></strong> $date
</center>
</td></tr>
</table>
<font color="#D4D4D4" size=1>
※$keyword画像は、携帯専用の画像検索サイトです。<br>
</font>
</body>
</html>
END_OF_HTML

	return;
}

1;