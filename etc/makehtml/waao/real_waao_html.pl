#!/usr/bin/perl

use strict;
use URI::Escape;
use DBI;
use Cache::Memcached;

use Jcode;

# top page
&_top();

&_keyword("yahookeyword",1);

#&_keyword("googlekeyword",2);

exit;

sub str_encode(){
	my $str = shift;
	return uri_escape($str);
}


sub _top(){

	my $geinou = &html_mojibake_str("geinou");
	my $datestr = &_get_date();
	my $html;
		
	$html .= &_html_header('先読み検索 -みんなの携帯辞書-','キーワード,検索,辞書','連想キーワード検索は、検索の先読みして検索してくれる検索サイトです',"http://waao.jp/real/");

	$html .= qq{<center><h1><img src="http://img.waao.jp/sakiyomi.gif" width=120 height=28 alt="先読み携帯検索"></h1>};
	$html .= qq{<form action="http://waao.jp/search.html" method="POST" ><input type="text" name="q" value="" size="12"><input type="hidden" name="guid" value="ON"><input type="submit" value="検索"></form></center>\n};
	$html .= qq{<font size=1>先読み検索は、検索したｷｰﾜｰﾄﾞで良く検索される連想ｷｰﾜｰﾄﾞを先読みして検索できる携帯検索ｴﾝｼﾞﾝです</font>\n};
	$html .= qq{<table border=0 bgcolor="#000000" width="100%"><tr><td><font size=1  color="#FFFF2B">人気検索ｷｰﾜｰﾄﾞ($datestr)</font><br></td></tr></table>\n};

	# 今日の芸能人
	my $dbh = &_db_connect();
	
	my $sth = $dbh->prepare(qq{ select id, keyword, yahookeyword, googlekeyword from keyword where yahookeyword is not null order by cnt desc limit 20} );
$sth->execute();
while(my @row = $sth->fetchrow_array) {
	my $link_path = &_make_file_path($row[0]);

	$html .= qq{<font color="#009525">》</font><a href="$link_path" title="$row[1]">$row[1]</a><br>};
	my $ksugest = &_each_keyword($row[0],$row[2],1);
	$html .= qq{<font size=1>$ksugest</font><br>};
}
	$html .= qq{<img src="http://img.waao.jp/m2028.gif" width=48 height=9><a href="http://waao.jp/real/">次へ</a><br>\n};
	$html .= qq{<hr color="#009525">\n};
	$html .= &_html_meikanlist();
	$html .= qq{<hr color="#009525">\n};
	$html .= qq{<a href="http://waao.jp/" title="みんなのﾓﾊﾞｲﾙ">みんなのﾓﾊﾞｲﾙﾌﾟﾗｽ</a><br>\n};
	$html .= qq{<a href="http://waao.jp/kiyaku/">免責事項・利用規約</a><br>\n};
	$html .= qq{<a href="http://waao.jp/privacy/">ﾌﾟﾗｲﾊﾞｼｰﾎﾟﾘｼｰ</a><br>\n};
	$html .= qq{<a href="http://waao.jp/sp-policy/">ｻｲﾄ健全化</a><br>\n};
	$html .= qq{<a href="http://waao.jp/sp-infomation/">運営元</a><br>\n};
	$html .= qq{<hr color="#009525">\n};
	
	$html .= &_html_footer();
	
	$dbh->disconnect;
	
	my $filename = qq{/var/www/vhosts/goo.to/httpdocs-real/index.html};
	open(OUT,"> $filename") || die('error');
	print OUT "$html";
	close(OUT);
	print $filename."\n";

	# robots.txt
#	my $robots_str = qq{Sitemap: http://real.goo.to/\n};
	my $robots_str;
	
	my $robots = qq{/var/www/vhosts/goo.to/httpdocs-real/robots.txt};
	open(OUT,"> $robots") || die('error');
	print OUT "$robots_str";
	close(OUT);
	
	return;
}


sub _keyword(){
	my $table = shift;
	my $type = shift;
	
	my $geinou = &html_mojibake_str("geinou");
	my $datestr = &_get_date();

	my $dbh = &_db_connect();

	# 人物のみ作成
for(my $i=0;$i<100;$i++){
	my $start = $i * 1000;
#	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-real/};
#	mkdir($dirname, 0755);
	print "start $start \n";
	my $sitemaptxt;
	$sitemaptxt .= qq{<?xml version="1.0" encoding="UTF-8"?>\n};
	$sitemaptxt .= qq{<urlset xmlns="http://www.google.com/schemas/sitemap/0.84"\n};
	$sitemaptxt .= qq{  xmlns:mobile="http://www.google.com/schemas/sitemap-mobile/1.0">\n};

	# ランダムパーソン
	my $recommend;
	my $sth = $dbh->prepare(qq{ select id, keyword, $table from keyword where $table is not null order by rand() limit 10} );
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my $link_path = &_make_file_path($row[0]);
		$recommend .= qq{<a href="$link_path" title="$row[1]">$row[1]</a> };
	}

print "AAA \n";

	my $sth = $dbh->prepare(qq{ select id, keyword, $table, simplewiki from keyword where $table is not null limit $start, 1000 } );
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my ($id, $keyword, $keywords, $simplewiki) = @row;
		my $keyword_encode = &str_encode($keyword);
print "BBB \n";

		my $sth2 = $dbh->prepare(qq{ select id, url from photo where keywordid = ? order by good desc limit 1} );
		$sth2->execute( $id );
		my ($photoid,$photourl);
		while(my @row2 = $sth2->fetchrow_array) {
			($photoid,$photourl) = @row2;
		}

# page make start
		my $html;		
		my $link_path = &_make_file_path($id);
		$html .= &_html_header("$keywordのまるごと検索","$keyword,$keywords","$keywordのことが全て分かる先読み検索","http://waao.jp/$keyword_encode/real/$id/");
		if($simplewiki){
			$simplewiki =~s/\?//g;
			$html .= qq{<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">$simplewiki </font></marquee>};
		}

		$html .= qq{<table border=0 bgcolor="#DFFFBF" width="100%"><tr><td><center><h1>$keyword</h1></center>\n};
		$html .= qq{<center><h2><font color="#FF0000" size=1>先読み検索ﾌﾟﾗｽ</font></h2></center></td></tr></table>\n};
		$html .= qq{<hr color="#009525">\n};

print "CCC \n";
		my $ksugest = &_each_keyword($id,$keywords,1);
print "DDD \n";

		$html .= qq{<h3><font color="#009525">$keyword</font></h3><font size=1>$ksugest</font><br>};

		unless($photourl){
			$html .= qq{<img src="http://img.waao.jp/noimage95.gif" width=95 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left">};
		}else{
			$html .= qq{<a href="http://waao.jp/$keyword_encode/photolist/0-1/"><img src="$photourl" alt="$keyword画像" width=95 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"></a>};
		}
		$html .= qq{<a href="http://waao.jp/$keyword_encode/uwasa/" title="$keywordのうわさ">うわさ</a><br>};
		$html .= qq{<a href="http://waao.jp/$keyword_encode/bbs/" title="$keywordの掲示板">掲示板</a><br>};
		$html .= qq{<a href="http://waao.jp/$keyword_encode/qanda/" title="$keywordのQ&A">Q&A</a><br>};
		$html .= qq{<a href="http://waao.jp/$keyword_encode/bookmark/" title="$keywordの携帯ｻｲﾄ">ﾓﾊﾞｲﾙｻｲﾄ</a><br>};
		$html .= qq{<a href="http://waao.jp/$keyword_encode/shopping/" title="$keywordのｱﾀﾞﾙﾄﾋﾞﾃﾞｵ">関連商品</a><br>};
		$html .= qq{<a href="http://waao.jp/$keyword_encode/news/" title="$keywordの関連ﾆｭｰｽ">関連ﾆｭｰｽ</a><br>};
		$html .= qq{</font>};
		$html .= qq{<br clear="all" />};
		
		$html .= qq{<hr color="#009525">\n};
		$html .= qq{<center><a href="http://cgi.i-mobile.co.jp/ad_link.aspx?guid=on&asid=12525&pnm=0&asn=1"><img border="0" src="http://cgi.i-mobile.co.jp/ad_img.aspx?guid=on&asid=12525&pnm=0&asn=1&asz=0&atp=3&lnk=6666ff&bg=&txt=000000" alt="i-mobile"></a></center>\n};
		$html .= qq{<hr color="#009525">\n};
		$html .= qq{<h3><font color="#009525">$keyword</font>の関連ｷｰﾜｰﾄﾞ</h3><font size=1>$recommend</font><br>};
		$html .= qq{<hr color="#009525">\n};
		$html .= qq{<center><a href="http://cgi.i-mobile.co.jp/ad_link.aspx?guid=on&asid=12525&pnm=0&asn=3"><img border="0" src="http://cgi.i-mobile.co.jp/ad_img.aspx?guid=on&asid=12525&pnm=0&asn=3&asz=0&atp=3&lnk=6666ff&bg=&txt=000000" alt="i-mobile"></a></center>\n};
		$html .= qq{<hr color="#009525">\n};
		$html .= qq{<a href="http://waao.jp/$keyword_encode/real/$id/" title="$keyword">$keywordﾌﾟﾗｽ</a><br>\n};
		$html .= qq{<a href="/" title="先読み検索検索">先読み検索検索</a>&gt;<strong>$keyword</strong><br>};
		$html .= qq{<font color="#AAAAAA">$keywordの㌻は$keywordに関して検索されている$keywordの関連キーワードを検索できる先読み携帯検索ｴﾝｼﾞﾝです<br>$datestr更新データ</font>};
		$html .= &_html_footer();
		
		my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-real}.$link_path;
		mkdir($dirname, 0755);

		$sitemaptxt .= qq{<url>\n};
		$sitemaptxt .= qq{<loc>http://real.waao.jp$link_path</loc>\n};
		$sitemaptxt .= qq{<mobile:mobile/>\n};
		$sitemaptxt .= qq{</url>\n};

		my $filename = qq{/var/www/vhosts/goo.to/httpdocs-real}.$link_path.qq{index.html};
		print "BBB $id $filename \n";
eval{
		open(OUT,"> $filename") || die('error');
		print OUT "$html";
		close(OUT);
#		print "$id $filename \n";
	};
if($@){
	print "$@ \n";
}
	
		
	} #while
	
	# sitemap
	$sitemaptxt .= qq{</urlset>\n};
	my $sitemap = qq{/var/www/vhosts/goo.to/httpdocs-real/sitemap$i.xml};
	open(OUT,"> $sitemap") || die('error');
	print OUT "$sitemaptxt";
	close(OUT);
	
	# robots.txt
	my $robots_str = qq{Sitemap: http://real.waao.jp/sitemap$i.xml\n};
	
	my $robots = qq{/var/www/vhosts/goo.to/httpdocs-real/robots.txt};
	open(OUT,">> $robots") || die('error');
	print OUT "$robots_str";
	close(OUT);

}
	$dbh->disconnect;
	return;
}
sub _make_file_path(){
	my $keyword_id = shift;
	my $type = shift;

	my $dir = int($keyword_id / 1000);
	my $file = $keyword_id % 1000;
		
	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-real/$dir/};
	mkdir($dirname, 0755);
	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-real/$dir/$keyword_id/};
	mkdir($dirname, 0755);

	my $filepath = qq{/$dir/$keyword_id/};
	$filepath = qq{/$dir/$keyword_id/$type/} if($type);
	
	return $filepath;
}

sub _each_keyword(){
	my $keyword_id = shift;
	my $list = shift;
	my $type = shift;
	my $flag = shift;

	my $dbh3 = &_db_connect();
	my $recommend;
	my $sth = $dbh3->prepare(qq{ select id, keyword from keyword where yahookeyword is not null order by rand() limit 10} );
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my $link_path = &_make_file_path($row[0]);
		$recommend .= qq{<a href="$link_path" title="$row[1]">$row[1]</a> };
	}
	$dbh3->disconnect;

	my $html;
	
	my $link_path = &_make_file_path($keyword_id);
	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-real}.$link_path.qq{$type};
	mkdir($dirname, 0755);
	my $cnt;
	my @val = split(/\t/,$list);
	foreach my $value (@val){
		next unless($value);
		$cnt++;
		$html .=qq{<a href="$link_path$type/$cnt.html" title="$value">$value</a> };
		&_make_sugest($keyword_id,$value,$type,$cnt,$recommend) unless($flag);
	}

	return $html;
}

sub _html_footer(){
	my $html;

	$html .= qq{<center><img src="http://img.waao.jp/logo.jpg" alt="waao.jp"></center>\n};
	$html .= qq{</body>\n};
	$html .= qq{</html>\n};
	
	return $html;

}

sub _html_header(){
	my $title = shift;
	my $keywords = shift;
	my $description = shift;
	my $mld = shift;
	
	my $html;
	
	$html .= qq{<!DOCTYPE HTML PUBLIC "-//W3C//DTD Compact HTML 1.0 Draft //EN">};
	$html .= qq{<html>};
	$html .= qq{<head>};
	$html .= qq{<meta http-equiv="content-type" CONTENT="text/html;charset=Shift_JIS">};
	$html .= qq{<meta name="google-site-verification" content="cxJSvOw2PI0z0sXEEx3KDvT3mvpKq8CP7PE1Ge1zPgs" />};
	$html .= qq{<meta name="robots" content="index,follow">};
	$html .= qq{<meta http-equiv="Expires" content="0">};
	$html .= qq{<meta http-equiv="Pragma" CONTENT="no-cache">};
	$html .= qq{<meta http-equiv="Cache-Control" CONTENT="no-cache">};
	$html .= qq{<meta name="keywords" content="$keywords">\n};
	$html .= qq{<meta name="description" content="$description">\n};
	$html .= qq{<title>$title</title>\n};
	$html .= qq{<link rel="alternate" media="handheld" href="$mld" />\n} if($mld);
	$html .= qq{</head>\n};
	$html .= qq{<body>\n};
	
	return $html;

}

sub _db_connect(){

	my $dsn = 'DBI:mysql:waao';
	my $user = 'mysqlweb';
	my $password = 'WaAoqzxe7h6yyHz';
	my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 1, AutoCommit => 0});

	return $dbh;
}

sub html_mojibake_str(){
	my $tmpl = shift;
	
my $file = qq{/var/www/vhosts/goo.to/tmpl/$tmpl};
my $fh;
my $filedata;
open( $fh, "<", $file );
while( my $line = readline $fh ){ 
	$filedata .= $line;
}
close ( $fh );

	return $filedata;
}

sub _memcache(){

	my $memd = new Cache::Memcached {
    'servers' => [ "localhost:11211" ],
    'debug' => 0,
    'compress_threshold' => 1_000,
	};

	return $memd;
}

sub _get_yicha_url(){
	my $str  = shift;
	my $type = shift;

	# type
	# p ｻｲﾄ
	# v 動画
	# i 画像
	# m 音楽
	
	$type = 'p' unless($type);

	my $url;
	my $str_encode = &str_encode($str);

	$url = qq{http://u.yicha.jp/union/u.jsp?st=$type&s=108402691&keyword=$str_encode};

	return $url;
}

sub _get_date(){
	my $date;
	my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
	$year = $year + 1900;
	$mon = $mon + 1;
	$date = sprintf("%d-%02d-%02d",$year,$mon,$mday);

	return $date;
}

sub _yicha_sp_menu(){
	my $keyword =shift;
	my $html;
	
	my $y_p = &_get_yicha_url($keyword,'p');
	my $y_v = &_get_yicha_url($keyword,'v');
	my $y_i = &_get_yicha_url($keyword,'i');
	my $y_m = &_get_yicha_url($keyword,'m');
	$html .= qq{<h3>$keyword<font color="#ff0000">特別ﾒﾆｭｰ</font></h3>\n};
	$html .= qq{<center><img src="http://img.waao.jp/kya-.gif" widht=15 height=15> <a href="$y_p">ｵｽｽﾒ</a> <a href="$y_v">動画</a> <a href="$y_i">画像</a> <a href="$y_m">音楽</a> </center>};

	return $html;
}
sub _html_meikanlist(){
my $file = qq{/var/www/vhosts/goo.to/etc/makehtml/meikanlist.html};
my $fh;
my $filedata;
open( $fh, "<", $file );
while( my $line = readline $fh ){ 
	$filedata .= $line;
}
close ( $fh );
	
	return $filedata;
}

sub _make_sugest(){
	my $keyword_id = shift;
	my $word = shift;
	my $type = shift;
	my $cnt = shift;
	my $recommend = shift;
	
	my $table = "yahookeyword";
	$table = "googlekeyword" if($type eq 2);
	
	my $datestr = &_get_date();

	my $dbh2 = &_db_connect();


	my $sth = $dbh2->prepare(qq{ select id, keyword, $table from keyword where id = ?} );
	$sth->execute($keyword_id);
	while(my @row = $sth->fetchrow_array) {
		my ($id, $keyword,$keywords) = @row;
		my $keyword_encode = &str_encode($keyword);
# page make start
		my $html;		
		my $link_path = &_make_file_path($id);
		$html .= &_html_header("$keyword:$word","$keyword,$word,検索","$keywordの$word。$keywordの$wordの情報ならココ","http://waao.jp/$keyword_encode/real/$id/$type-$cnt/");
		$html .= qq{<table border=0 bgcolor="#DFFFBF" width="100%"><tr><td><center><h1>$keyword</h1></center>\n};
		$html .= qq{<center><h2><font color="#FF0000" size=1>$wordﾌﾟﾗｽ</font></h2></center></td></tr></table>\n};
		$html .= qq{<hr color="#009525">\n};
		$html .= qq{<br>\n};
		$html .= qq{<center>↓入り口↓</center>\n};

		my $y_p = &_get_yicha_url($keyword,'p');
		$html .= qq{<center><a href="$y_p">$keyword$word</a></center>\n};

		$html .= qq{<center>↑入り口↑</center>\n};
		$html .= qq{<br>\n};
		$html .= qq{<hr color="#009525">\n};

		my $sth2 = $dbh2->prepare(qq{ select id, url from photo where keywordid = ? order by good desc limit 1} );
		$sth2->execute( $id );
		my ($photoid,$photourl);
		while(my @row2 = $sth2->fetchrow_array) {
			($photoid,$photourl) = @row2;
		}
		unless($photourl){
			$html .= qq{<img src="http://img.waao.jp/noimage95.gif" width=95 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left">};
		}else{
			$html .= qq{<a href="http://waao.jp/$keyword_encode/photolist/0-1/"><img src="$photourl" alt="$keyword画像" width=95 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"></a>};
		}
		$html .= qq{<a href="http://waao.jp/$keyword_encode/uwasa/" title="$keywordのうわさ">うわさ</a><br>};
		$html .= qq{<a href="http://waao.jp/$keyword_encode/bbs/" title="$keywordの掲示板">掲示板</a><br>};
		$html .= qq{<a href="http://waao.jp/$keyword_encode/qanda/" title="$keywordのQ&A">Q&A</a><br>};
		$html .= qq{<a href="http://waao.jp/$keyword_encode/bookmark/" title="$keywordの携帯ｻｲﾄ">ﾓﾊﾞｲﾙｻｲﾄ</a><br>};
		$html .= qq{<a href="http://waao.jp/$keyword_encode/shopping/" title="$keywordのｱﾀﾞﾙﾄﾋﾞﾃﾞｵ">関連商品</a><br>};
		$html .= qq{<a href="http://waao.jp/$keyword_encode/news/" title="$keywordの関連ﾆｭｰｽ">関連ﾆｭｰｽ</a><br>};
		$html .= qq{</font>};
		$html .= qq{<br clear="all" />};

		$html .= qq{<hr color="#009525">\n};
		$html .= qq{<center><a href="http://cgi.i-mobile.co.jp/ad_link.aspx?guid=on&asid=12525&pnm=0&asn=1"><img border="0" src="http://cgi.i-mobile.co.jp/ad_img.aspx?guid=on&asid=12525&pnm=0&asn=1&asz=0&atp=3&lnk=6666ff&bg=&txt=000000" alt="i-mobile"></a></center>\n};
		$html .= qq{<hr color="#009525">\n};
		my $ksugest = &_each_keyword($id,$keywords,1,1);
		$html .= qq{<h3><font color="#009525">$keyword</font>の関連ｷｰﾜｰﾄﾞ</h3><font size=1>$ksugest</font><br>};
		$html .= qq{<hr color="#009525">\n};
		$html .= qq{<h3><font color="#009525">$keyword</font>を検索した人はこんな検索をしています</h3><font size=1>$recommend</font><br>};
		$html .= qq{<hr color="#009525">\n};
		$html .= qq{<center><a href="http://cgi.i-mobile.co.jp/ad_link.aspx?guid=on&asid=12525&pnm=0&asn=3"><img border="0" src="http://cgi.i-mobile.co.jp/ad_img.aspx?guid=on&asid=12525&pnm=0&asn=3&asz=0&atp=3&lnk=6666ff&bg=&txt=000000" alt="i-mobile"></a></center>\n};
		$html .= qq{<hr color="#009525">\n};
		$html .= qq{<a href="http://waao.jp/$keyword_encode/real/$id/$type-$cnt/" title="$keyword">$keywordﾌﾟﾗｽ</a><br>\n};
		$html .= qq{<a href="/" >先読み検索検索</a>&gt;<a href="$link_path">$keyword</a>&gt;<strong>$keywordの$word</strong><br>};
		$html .= qq{<font color="#AAAAAA">$keywordの$word㌻は$keywordについてよく検索される$keywordの$wordを先読みして検索できる携帯検索ｴﾝｼﾞﾝです<br>$datestr更新データ</font>};
		$html .= &_html_footer();
		
		my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-real}.$link_path;
		mkdir($dirname, 0755);

		my $filename = qq{/var/www/vhosts/goo.to/httpdocs-real}.$link_path.qq{$type/$cnt.html};
		print "AAA $id $filename \n";
eval{
		open(OUT,"> $filename") || die('error');
		print OUT "$html";
		close(OUT);
#		print "$id $filename \n";
	};
if($@){
	print "$@ \n";
}
	}
	$dbh2->disconnect;
	return;
}
