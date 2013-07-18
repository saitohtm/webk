package Waao::Twitter::PicSearch;
use strict;
use DBI;
use CGI;
use XML::Simple;
use LWP::Simple;
use Jcode;

sub dispatch(){
	my $class = shift;
	
	# list 表示
	&_top();
	
	return;
}


sub _top(){
	my $q = new CGI;
	my $twid = $q->param('twid');
	my $page = $q->param('page');
	my $keyword_sjis = $q->param('q');

	my $dsp_type = &_mobile_access_check();
	my $keyword = Jcode->new($keyword_sjis, 'sjis')->utf8;

	my $dsp_str_mb;
	my $dsp_str;

	my $url= qq{http://search.twitter.com/search.atom?q=twitpic+$keyword&lang=ja&rpp=100};
	my $response = get($url);	
	my $xml = new XML::Simple;
	my $xml_val = $xml->XMLin($response);
foreach my $key (keys %{$xml_val->{entry}}) {
	my $txtlink = $xml_val->{entry}->{$key}->{link}->[0]->{href};
	my $imglink = $xml_val->{entry}->{$key}->{link}->[1]->{href};
	my $title = Jcode->new($xml_val->{entry}->{$key}->{title}, 'utf8')->sjis;
	my $author = Jcode->new($xml_val->{entry}->{$key}->{author}->{name}, 'utf8')->sjis;
	my $authorid = $xml_val->{entry}->{$key}->{author}->{uri};
	my $twitpicid;
	if( $title =~/(.*)http:\/\/twitpic\.com\/(.*)/){
		my @vals = split(/ /,$2);
		$twitpicid = $vals[0];
	}
	$authorid=~s/http:\/\/twitter\.com\///;

	my $tmpreq = q{http://twitpic.com/}.$twitpicid;
	$title=~s/$tmpreq//g;

	$dsp_str_mb .=qq{<table border=0 bgcolor="#DFFFBF" width="100%"><tr><td><font color="#00968c"><img src="$imglink" height=24><font size=1><a href="/?guid=on&twid=$authorid">$author</a></font></font><br></td></tr></table>};
	$dsp_str_mb .=qq{<img src="http://twitpic.com/show/mini/$twitpicid" width=75 height=75 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;"><br>};
	$dsp_str_mb .=qq{<a href="$txtlink">■</a>$title<br>};
	$dsp_str_mb .=qq{<br clear="all" />};
	$dsp_str_mb .=qq{<hr color="#009525">};

	$dsp_str .=qq{<table border=0 bgcolor="#8FDADA" width="100%"><tr><td><font color="#00968c"><img src="$imglink" height=24><a href="/?guid=on&twid=$authorid">$author</a></font><br></td></tr></table>};
	$dsp_str .=qq{<img src="http://twitpic.com/show/mini/$twitpicid" width=75 height=75 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;"><br>};
	$dsp_str .=qq{<a href="$txtlink">$title</a><br>};
	$dsp_str .=qq{<br clear="all" />};
	$dsp_str .=qq{<hr color="#009525">};
}

	if( $dsp_type eq 1 ){
print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

<!DOCTYPE HTML PUBLIC "-//W3C//DTD Compact HTML 1.0 Draft //EN"> 
<html>
<head>
<meta http-equiv="content-type" CONTENT="text/html;charset=UTF-8">
<meta name="robots" content="index,follow">
<meta http-equiv="Expires" content="0">
<meta http-equiv="Pragma" CONTENT="no-cache">
<meta http-equiv="Cache-Control" CONTENT="no-cache">
<meta name="google-site-verification" content="nUfdeL2U8b1jmAbvxf8A9JRrxM6HrIH0GMDKyJuA5GQ" />
<title>みんなの写メッター - pic.waao.jp -</title>
</head>
<body>
<center>
<img src="http://img.waao.jp/syametter.gif" width=120 height=28>
</center>
<center>
<form action="/search.html" method="POST" >
<input type="text" name="q" value="" size="20">
<input type="hidden" name="guid" value="ON">
<br />
<input type="submit" value="検索"><br />
</form>
</center>
<hr color="#009525">
$dsp_str_mb
<a href="/">TOP</a><br>
<font size=1>
みんなの写メッターは、画像付のつぶやきを検索できるTwitterサービスです。
</font>
<center><a href="http://waao.jp/" access_key=0>みんなのモバイル</a></center>
<center><img src="http://img.waao.jp/logo.jpg" alt="waao.jp"></center>
<a href="http://waao.jp/">http://waao.jp/</a>
</body>
</html>
END_OF_HTML
	}elsif( $dsp_type eq 2 ){
print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

<!DOCTYPE HTML PUBLIC "-//W3C//DTD Compact HTML 1.0 Draft //EN"> 
<html>
<head>
<meta http-equiv="content-type" CONTENT="text/html;charset=UTF-8">
<meta name="robots" content="index,follow">
<meta http-equiv="Expires" content="0">
<meta http-equiv="Pragma" CONTENT="no-cache">
<meta http-equiv="Cache-Control" CONTENT="no-cache">
<meta name="apple-mobile-web-app-capable">
<meta name="viewport" content="width=device-width" />  
<meta name="google-site-verification" content="nUfdeL2U8b1jmAbvxf8A9JRrxM6HrIH0GMDKyJuA5GQ" />
<title>みんなの写メッター - pic.waao.jp -</title>
</head>
<body>
<center>
<img src="http://img.waao.jp/syametter.gif" width=120 height=28>
</center>
<center>
<form action="/search.html" method="POST" >
<input type="text" name="q" value="" size="20">
<input type="hidden" name="guid" value="ON">
<br />
<input type="submit" value="検索"><br />
</form>
</center>
<hr color="#009525">
$dsp_str_mb
<a href="/">TOP</a><br>
<font size=1>
みんなの写メッターは、画像付のつぶやきを検索できるTwitterサービスです。
</font>
<center><a href="http://waao.jp/" access_key=0>みんなのモバイル</a></center>
<center><img src="http://img.waao.jp/logo.jpg" alt="waao.jp"></center>
<a href="http://waao.jp/">http://waao.jp/</a>
</body>
</html>
END_OF_HTML
	}else{
print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ja" lang="ja">
<head>
<meta http-equiv="content-type" content="text/html; charset=UTF-8" />
<meta http-equiv="Content-style-Type" content="text/css" />
<link rel="stylesheet" href="base.css" type="text/css" />
<title>みんなの写メッター - pic.waao.jp -</title>
</head>
<body>
<script type="text/javascript" src="http://shots.snap.com/snap_shots.js?ap=1&amp;key=d708678ff333c1147a0e7fc90cbc3cd2&amp;sb=1&amp;th=orange&amp;cl=0&amp;si=0&amp;po=0&amp;df=0&amp;oi=0&amp;lang=en-us&amp;domain=admin.goo.to/&amp;as=1"></script>

<div id="top">
   <div id="header">
      <h1><a href="index.html"><img src="http://img.waao.jp/syametter.png"></a></h1>
      <div id="pr">
         <p>みんなの写メッターは、画像付のつぶやきを検索できるTwittersサービスです。</p>
      </div>
      <div id="menu">
         <img src="http://img.waao.jp/3ca.PNG">
         <img src="http://img.waao.jp/iphone.PNG">
         <img src="http://img.waao.jp/picwaaojp.png" height="44">
      </div><!-- menu end -->
   </div><!-- header end -->
   <div id="contents">
      <div id="main">
         <h2>画像付つぶやき検索</h2>
<center>
<form action="/search.html" method="POST" >
<input type="text" name="q" value="" size="20">
<input type="hidden" name="guid" value="ON">
<br />
<input type="submit" value="検索"><br />
</form>
</center>
         <h2>最新のつぶやき</h2>
$dsp_str
<a href="/">TOP</a><br>
      </div><!-- main end -->
      <div id="sub">
         <div class="section">
<script type="text/javascript"><!--
google_ad_client = "pub-2078370187404934";
/* 200x200, 作成済み 10/04/08 */
google_ad_slot = "6955074634";
google_ad_width = 200;
google_ad_height = 200;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
         </div>
         <div class="section">
            <h2>運営</h2>
<img src="http://img.waao.jp/logo.png">
            <h2>管理人</h2>
    <a href="http://twitter.com/weare_allone" class="url" rel="contact" title="ゆうと"><img alt="ゆうと" class="side_thumb photo fn" height="48" src="http://a3.twimg.com/profile_images/797036017/icon12703846725347_normal.jpg" width="48" /><span id="me_name">weare_allone</span><span id="me_tweets"></a>
<br>
<center>
<script language='JavaScript' src='http://bnr.dff.jp/001click.js'> </script>
</center>
         </div><!-- section end -->
      </div><!-- sub end -->
         <div class="section">
      </div><!-- sub end -->
      <div id="totop">
         <p><a href="#top">ページのトップへ戻る</a></p>
      </div><!-- totop end -->
   </div><!-- contents end -->
   <div id="footMenu">
      <ul>
         <li><a href="index.html">ホーム</a></li>
      </ul>
   </div><!-- footerMenu end -->
   <div id="footer">
      <address>Copyright &copy; 2010 We Are All One All Rights Reserved.</address>
   </div><!-- footer end -->
</div><!-- top end -->
</body>
</html>
END_OF_HTML
	}

	return;
}


sub _db_connect(){
    my $dsn = 'DBI:mysql:waao';
    my $user = 'mysqlweb';
    my $password = 'WaAoqzxe7h6yyHz';

    my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 0, AutoCommit => 1, PrintError => 0});
	
	return $dbh;
}

sub _mobile_access_check(){

    if( $ENV{'REMOTE_HOST'} =~/docomo/i ){
		return 1;
    }elsif( $ENV{'REMOTE_HOST'} =~/ezweb/i ){
		return 1;
    }elsif( $ENV{'REMOTE_HOST'} =~/^J-PHONE|^Vodafone|^SoftBank/i ){
		return 1;
    }elsif( $ENV{'REMOTE_HOST'} =~/panda-world\.ne\.jp/i ){
		return 2;
	}elsif( $ENV{'HTTP_USER_AGENT'} =~/Googlebot-Mobile/i ){
		return 1;
	}

	return 0;
}


1;