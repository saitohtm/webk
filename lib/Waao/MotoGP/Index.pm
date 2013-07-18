package Waao::MotoGP::Index;
use strict;
use DBI;
use CGI;

sub dispatch(){
	my $class = shift;
	my $flag = &_mobile_access_check();
	
	if($flag){
		print qq{Location: http://waao.jp/motogp/\n\n};
		return;
	}
	# list 表示
	&_index();
	
	return;
}


sub _index(){

	my $q = new CGI;
	my $page = $q->param('page');
	my $dbh = &_db_connect();
	my $sth;

#		$sth = $dbh->prepare(qq{ select twitpicid, title, author,authorimage, authorid, imgurl, link from twitpic  order by id desc limit  $limit_s, $limit});
#		$sth->execute();
#	while(my @row = $sth->fetchrow_array) {
#		my ($twitpicid, $title, $author, $authorimage, $authorid, $imgurl, $link) = @row;
#	}

	$dbh->disconnect;
	

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta name="copyright" content="Nikukyu-Punch" />
<meta http-equiv="Content-Style-Type" content="text/css">
<title>みんなのMotoGP レース速報</title>
<link href="style.css" rel="stylesheet" type="text/css" />
</head>

<body>
<script type="text/javascript" src="http://shots.snap.com/snap_shots.js?ap=1&amp;key=d708678ff333c1147a0e7fc90cbc3cd2&amp;sb=1&amp;th=orange&amp;cl=0&amp;si=0&amp;po=0&amp;df=0&amp;oi=0&amp;lang=en-us&amp;domain=admin.goo.to/&amp;as=1"></script>

<h1>MotoGP</h1>
<div id="container">
<div id="contents">
END_OF_HTML

if($page eq "race"){
	&_race();
}elsif($page eq "rider"){
	&_driver();
}else{
	&_top();
}


print << "END_OF_HTML";
<div id="sub">
<!--<img src="images/logo.gif" width="196" height="196" />-->
<center>
<iframe src="http://sports.geocities.jp/sb_parts/MotoGP1.html" width="180" height="250" frameborder="0" scrolling="no">ここに未対応ブラウザ向けの内容</iframe>
</center>
<ul id="menu">
<li><a href="index.html">HOME</a></li><!--
--><li><a href="index.html?page=race">レース</a></li><!--
--><li><a href="index.html?page=rider">ライダー</a></li><!--
--><li><a href="#">BLOG</a></li><!--
--><li><a href="#">LINKS</a></li><!--
--><li><a href="#">CONTACT</a></li><!--
--></ul>
このスペースも使えます。ここに画像を入れる場合は、上のメニューと同じ横幅196pxでぴったりです。</div>
</div>
<div id="side">
<h3>side</h3>
<p>上の「side」などの見出しはh3タグで囲めばOK。<br />
html側の例だと、<br />
&lt;h3&gt;side&lt;/h3&gt;</p>
<p>ここに画像を置く場合、横幅156pxがちょうどです。段落タグの外に置くなら、176pxが最大。</p>
<h3>support</h3>
<p>テンプレート編集のサポートも充実しています。詳しくは<a href="about.html">ABOUTページ</a>に記載しております。</p>
</div>
</div>

<div id="footer">Copyright(C)2010 We Are All One All Rights Reserved.<br />
<a href="http://nikukyu-punch.com/" target="_blank">Template design by Nikukyu-Punch</a></div>

</body>
</html>
END_OF_HTML

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

sub _top(){


my $file = qq{/var/www/vhosts/waao.jp/tmpl/motogp/top}.qq{.html};
my $fh;
my $filedata;
open( $fh, "<", $file );
while( my $line = readline $fh ){ 
	$filedata .= $line;
}
close ( $fh );

print << "END_OF_HTML";
$filedata
END_OF_HTML

	return;
}

sub _race(){

my $file = qq{/var/www/vhosts/waao.jp/tmpl/motogp/race}.qq{.html};
my $fh;
my $filedata;
open( $fh, "<", $file );
while( my $line = readline $fh ){ 
	$filedata .= $line;
}
close ( $fh );

print << "END_OF_HTML";
$filedata
END_OF_HTML


	return;
}

sub _driver(){

my $file = qq{/var/www/vhosts/waao.jp/tmpl/motogp/driver}.qq{.html};
my $fh;
my $filedata;
open( $fh, "<", $file );
while( my $line = readline $fh ){ 
	$filedata .= $line;
}
close ( $fh );

print << "END_OF_HTML";
$filedata
END_OF_HTML
	return;
}
1;