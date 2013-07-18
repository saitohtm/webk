#!/usr/bin/perl

use strict;
use URI::Escape;
use DBI;
use Cache::Memcached;

use Jcode;

# pref
&_pref();


exit;

sub str_encode(){
	my $str = shift;
	return uri_escape($str);
}


sub _pref(){

	my $datestr = &_get_date();

my $dbh = &_db_connect();

my $sth = $dbh->prepare(qq{ select addr1 from zip group by addr1} );
$sth->execute();
my $cnt;
my $preflist;
while(my @row = $sth->fetchrow_array) {
	$cnt++;
	my $pref_name = $row[0];
	my $str_encode = &str_encode($pref_name);
print "$cnt $pref_name\n";
	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-postcode/mb/$cnt/};
	mkdir($dirname, 0755);
	$preflist.=qq{<font color="#009525">》</font><a href="/mb/$cnt/" title="$pref_name">$pref_name</a><br>};
	my $html;

	$html .= &_html_header("郵便番号検索 $pref_name","郵便番号,検索,postcode,送料,$pref_name","$pref_nameの郵便番号検索は、日本全国の郵便番号と送料が検索できる検索サイトです。","http://waao.jp/zip/");


	my $dirname;
	my $sth2 = $dbh->prepare(qq{ select addr2 from zip where addr1 = ? group by addr2 order by addr2} );
	$sth2->execute($pref_name);
	my $cnt2;
	while(my @row2 = $sth2->fetchrow_array) {
		$cnt2++;
		my $area_name = $row2[0];
		my $str_encode2 = &str_encode($area_name);
		$dirname = qq{/var/www/vhosts/goo.to/httpdocs-postcode/mb/$cnt/$cnt2/};
		mkdir($dirname, 0755);
		$html .= qq{<font color="#009525">》</font><a href="/mb/$cnt/$cnt2/" title="$row[1]">$area_name</a><br>};
		&_area($cnt,$cnt2,$area_name);
	}

	$html .= &_html_footer();
	my $filename = qq{/var/www/vhosts/goo.to/httpdocs-postcode/mb/$cnt/}.qq{index.html};
	open(OUT,"> $filename") || die('error');
	print OUT "$html";
	close(OUT);
	print $filename."\n";
}
	

	$dbh->disconnect;

	my $html = &_html_header("郵便番号検索 postcode","郵便番号,検索,postcode,送料","郵便番号検索は、日本全国の郵便番号と送料が検索できる検索サイトです。","http://waao.jp/zip/");
	$html .= $preflist;
	$html .= &_html_footer();
	my $filename = qq{/var/www/vhosts/goo.to/httpdocs-postcode/mb/}.qq{index.html};
	open(OUT,"> $filename") || die('error');
	print OUT "$html";
	close(OUT);
	print $filename."\n";

	return;
}


sub _area(){
	my $cnt = shift;
	my $cnt2 = shift;
	my $area_name = shift;
	my $datestr = &_get_date();

my $dbh = &_db_connect();

my $sth = $dbh->prepare(qq{ select addr3,zip,allstr,addr1,addr2 from zip where addr2 = ? order by addr3} );
$sth->execute($area_name);
my $htmllist;
my $city_name;
my $pref_name;
my $zipcode;
my $allstr;
while(my @row = $sth->fetchrow_array) {
	$city_name = $row[0];
	$zipcode = $row[1];
	$allstr = $row[2];
	$pref_name = $row[3];
	$area_name = $row[4];
	my $str_encode = &str_encode($city_name);
	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-postcode/mb/$cnt/$cnt2/$zipcode/};
	mkdir($dirname, 0755);
	$htmllist.=qq{<font color="#009525">》</font><a href="/mb/$cnt/$cnt2/$zipcode/" title="$city_name">$city_name</a><br>};
	my $html;

	$html .= &_html_header("郵便番号検索 $zipcode $city_name","郵便番号,検索,postcode,送料,$city_name,$zipcode","$zipcode $allstrの郵便番号検索は、日本全国の郵便番号と送料が検索できる検索サイトです。","http://waao.jp/list-detail/zip/$zipcode/");


	$html .= qq{〒郵便番号：$zipcode<br>};
	$html .= qq{住所：$allstr<br>};

	$html .= &_html_footer();
	my $filename = qq{/var/www/vhosts/goo.to/httpdocs-postcode/mb/$cnt/$cnt2/$zipcode/}.qq{index.html};
	open(OUT,"> $filename") || die('error');
	print OUT "$html";
	close(OUT);
}
	
	my $html;
	$html .= &_html_header("郵便番号検索 $area_name","郵便番号,検索,postcode,送料,$area_name,$zipcode","$pref_name$area_nameの郵便番号検索は、日本全国の郵便番号と送料が検索できる検索サイトです。","http://waao.jp/zip/");


	$html .= $htmllist;

	$html .= &_html_footer();
	my $filename = qq{/var/www/vhosts/goo.to/httpdocs-postcode/mb/$cnt/$cnt2/}.qq{index.html};

	open(OUT,"> $filename") || die('error');
	print OUT "$html";
	close(OUT);


	$dbh->disconnect;

	return;
}



sub _html_footer(){
	my $html;

	$html .= qq{<hr color="#009525">\n};
	$html .= &_html_meikanlist();
	$html .= qq{<hr color="#009525">\n};
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
	$html .= qq{<meta http-equiv="content-type" CONTENT="text/html;charset=UTF-8">};
	$html .= qq{<meta name="google-site-verification" content="Z0BhZHzNzEAtl_D0ck_Ip6xc1kR4yrM2JJbfdCJPlqA" />};
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
		$html .= qq{<center><a href="http://cgi.i-mobile.co.jp/ad_link.aspx?guid=on&asid=12525&pnm=0&asn=1"><img border="0" src="http://cgi.i-mobile.co.jp/ad_img.aspx?guid=on&asid=12525&pnm=0&asn=1&asz=0&atp=3&lnk=6666ff&bg=&txt=000000" alt="i-mobile"></a></center>\n};
		$html .= qq{<hr color="#009525">\n};
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
my $file = qq{/var/www/vhosts/waao.jp/etc/makehtml/meikanlist.html};
my $fh;
my $filedata;
open( $fh, "<", $file );
while( my $line = readline $fh ){ 
	$filedata .= $line;
}
close ( $fh );
	
	return $filedata;
}

