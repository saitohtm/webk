package Waao::Twitter::Pic;
use strict;
use DBI;
use CGI;
use URI::Escape;

sub dispatch(){
	my $class = shift;
	
	my $q = new CGI;
	my $twid = $q->param('twid');
	if($twid){
		&_mytwit();
	# list 表示
	}else{
		&_top();
	}	
	return;
}
sub _mytwit(){
	my $q = new CGI;
	my $twid = $q->param('twid');
	my $page = $q->param('page');

	my $dbh = &_db_connect();
	my $dsp_str_mb;
	my $dsp_str;
	my $sth;

	my $dsp_type = &_mobile_access_check();

	my $limit_s = 0;
	my $limit = 10;
	if($dsp_type ne 1){
		$limit = 30;
	}
	my $next_page = $page + 1;
	if( $page ){
		$limit_s = $limit * $page;
	}
	my $autherstr;
	my $autherstr_mb;
	my $text = qq{.%40}.qq{$twid my photo history http://pic.waao.jp/$twid/ %23syametter};
	my $twitter_post = qq{<a href="http://twitter.com/home?status=$text">写メール履歴をtwitterに投稿する</a>};
	unless($q->param('aaa')){
		$twitter_post = qq{<a href="/">自分の写メール履歴を見る</a>};
	}
	$sth = $dbh->prepare(qq{ select twitpicid, title, author,authorimage, authorid, imgurl, link from twitpic where authorid = ? order by id desc limit $limit_s, $limit});
	$sth->execute($twid);
	my $cnt;
	while(my @row = $sth->fetchrow_array) {
		$cnt++;
		my ($twitpicid, $title, $author, $authorimage, $authorid, $imgurl, $link) = @row;
		my $tmpreq = q{http://twitpic.com/}.$twitpicid;
		$title=~s/$tmpreq//g;

		$autherstr_mb =qq{<table border=0 bgcolor="#DFFFBF" width="100%"><tr><td><font color="#00968c"><img src="$authorimage" height=24><font size=1><a href="http://twitter.com/$authorid">$author</a></font></font><br></td></tr></table>};
		$dsp_str_mb .=qq{<img src="http://twitpic.com/show/mini/$twitpicid" width=75 height=75 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;"><br>};
		$dsp_str_mb .=qq{<a href="$link">$title</a><br>};
		$dsp_str_mb .=qq{<br clear="all" />};
		$dsp_str_mb .=qq{<hr color="#009525">};


		$autherstr =qq{<table border=0 bgcolor="#8FDADA" width="100%"><tr><td><font color="#00968c"><img src="$authorimage" height=24><a href="http://twitter.com/$authorid">$author</a></font><br></td></tr></table>};
		$dsp_str .=qq{<img src="http://twitpic.com/show/mini/$twitpicid" width=75 height=75 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;"><br>};
		$dsp_str .=qq{<a href="$link">$title</a><br>};
		$dsp_str .=qq{<br clear="all" />};
		$dsp_str .=qq{<hr color="#009525">};
	}

	$dbh->disconnect;
	
	my $next_url = qq{<img src="http://img.waao.jp/m2028.gif" width=48 height=9><a href="/?guid=on&page=$next_page&twid=$twid">次へ</a>};
	$next_url = qq{<img src="http://img.waao.jp/m2028.gif" width=48 height=9><a href="http://pic.waao.jp/search.html?q=$twid">もっと見る</a>} if($cnt ne $limit);
	if( $dsp_type eq 1 ){
print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

<!DOCTYPE HTML PUBLIC "-//W3C//DTD Compact HTML 1.0 Draft //EN"> 
<html>
<head>
<meta http-equiv="content-type" CONTENT="text/html;charset=utf-8">
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
<hr color="#009525">
$autherstr_mb
$twitter_post<br>
$dsp_str_mb
$next_url
<hr color="#009525">
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
<hr color="#009525">
$autherstr_mb
<h1>$twitter_post</h1><br>
$dsp_str_mb
$next_url
<hr color="#009525">
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
          <h2>写メッター履歴</h2>
$autherstr
<center>
$twitter_post
</center>
$dsp_str
$next_url
<hr color="#009525">
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
    <a href="http://twitter.com/weare_allone" class="url" rel="contact" title="ゆうと"><img alt="ゆうと" class="side_thumb photo fn" height="48" src="http://a1.twimg.com/profile_images/817291006/icon12703846725347_bigger.jpg" width="48" /><span id="me_name">weare_allone</span><span id="me_tweets"></a>
<br>
<center>
<script language='JavaScript' src='http://bnr.dff.jp/001click.js'> </script>
</center>
         </div><!-- section end -->
      </div><!-- sub end -->
         <div class="section">
            <h2>更新履歴</h2>
            2010.5.01 my photo history をTwit機能追加<br>
            2010.4.14 マイ写メール履歴追加<br>
            2010.4.10 キーワード検索追加<br>
            2010.4.10 クリック募金追加<br>
            2010.4.8 version β<br>
            m(_ _)m<br>
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


sub _top(){
	my $q = new CGI;
	my $twid = $q->param('twid');
	my $page = $q->param('page');

	my $dbh = &_db_connect();
	my $dsp_str_mb;
	my $dsp_str;
	my $sth;

	my $dsp_type = &_mobile_access_check();

	my $limit_s = 0;
	my $limit = 10;
	if($dsp_type ne 1){
		$limit = 30;
	}
	my $next_page = $page + 1;
	if( $page ){
		$limit_s = $limit * $page;
	}

	if($twid){
		$sth = $dbh->prepare(qq{ select twitpicid, title, author,authorimage, authorid, imgurl, link from twitpic where authorid = ? order by id desc limit $limit_s, $limit});
		$sth->execute($twid);
	}else{
		$sth = $dbh->prepare(qq{ select twitpicid, title, author,authorimage, authorid, imgurl, link from twitpic  order by id desc limit  $limit_s, $limit});
		$sth->execute();
	}
	while(my @row = $sth->fetchrow_array) {
		my ($twitpicid, $title, $author, $authorimage, $authorid, $imgurl, $link) = @row;
		my $tmpreq = q{http://twitpic.com/}.$twitpicid;
		$title=~s/$tmpreq//g;

		if($twid){
			$dsp_str_mb .=qq{<table border=0 bgcolor="#DFFFBF" width="100%"><tr><td><font color="#00968c"><img src="$authorimage" height=24><font size=1><a href="http://twitter.com/$authorid">$author</a></font></font><br></td></tr></table>};
		}else{
			$dsp_str_mb .=qq{<table border=0 bgcolor="#DFFFBF" width="100%"><tr><td><font color="#00968c"><img src="$authorimage" height=24><font size=1><a href="/?guid=on&twid=$authorid">$author</a></font></font><br></td></tr></table>};
		}
		$dsp_str_mb .=qq{<img src="http://twitpic.com/show/mini/$twitpicid" width=75 height=75 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;"><br>};
		$dsp_str_mb .=qq{<a href="$link">$title</a><br>};
		$dsp_str_mb .=qq{<br clear="all" />};
		$dsp_str_mb .=qq{<hr color="#009525">};


		if($twid){
			$dsp_str .=qq{<table border=0 bgcolor="#8FDADA" width="100%"><tr><td><font color="#00968c"><img src="$authorimage" height=24><a href="http://twitter.com/$authorid">$author</a></font><br></td></tr></table>};
		}else{
			$dsp_str .=qq{<table border=0 bgcolor="#8FDADA" width="100%"><tr><td><font color="#00968c"><img src="$authorimage" height=24><a href="/?guid=on&twid=$authorid">$author</a></font><br></td></tr></table>};
		}
		$dsp_str .=qq{<img src="http://twitpic.com/show/mini/$twitpicid" width=75 height=75 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;"><br>};
		$dsp_str .=qq{<a href="$link">$title</a><br>};
		$dsp_str .=qq{<br clear="all" />};
		$dsp_str .=qq{<hr color="#009525">};
	}

	$dbh->disconnect;
	

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
<img src="http://img.waao.jp/m2028.gif" width=48 height=9><a href="/?guid=on&page=$next_page&twid=$twid">次へ</a>
<hr color="#009525">
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
<br />
<input type="submit" value="検索"><br />
</form>
</center>
<hr color="#009525">
$dsp_str_mb
<img src="http://img.waao.jp/m2028.gif" width=48 height=9><a href="/?guid=on&page=$next_page&twid=$twid">次へ</a>
<hr color="#009525">
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
         <h2>My 写メッター履歴</h2>
<center>
TwitterIDを入力
<form action="/" method="POST" >
<input type="text" name="twid" value="" size="20">
<input type="hidden" name="guid" value="ON">
<input type="hidden" name="aaa" value="1">
<br />
<input type="submit" value="検索"><br />
</form>
</center>
         <h2>画像付つぶやき検索</h2>
<center>
検索したいキーワードを入力
<form action="/search.html" method="POST" >
<input type="text" name="q" value="" size="20">
<input type="hidden" name="guid" value="ON">
<br />
<input type="submit" value="検索"><br />
</form>
</center>

         <h2>最新のつぶやき</h2>
$dsp_str
<img src="http://img.waao.jp/m2028.gif" width=48 height=9><a href="/?guid=on&page=$next_page&twid=$twid">次へ</a>
<hr color="#009525">
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
    <a href="http://twitter.com/weare_allone" class="url" rel="contact" title="ゆうと"><img alt="ゆうと" class="side_thumb photo fn" height="48" src="http://a1.twimg.com/profile_images/817291006/icon12703846725347_bigger.jpg" width="48" /><span id="me_name">weare_allone</span><span id="me_tweets"></a>
<br>
<center>
<script language='JavaScript' src='http://bnr.dff.jp/001click.js'> </script>
</center>
         </div><!-- section end -->
      </div><!-- sub end -->
         <div class="section">
            <h2>更新履歴</h2>
            2010.4.14 マイ写メール履歴追加<br>
            2010.4.10 キーワード検索追加<br>
            2010.4.10 クリック募金追加<br>
            2010.4.8 version β<br>
            m(_ _)m<br>
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