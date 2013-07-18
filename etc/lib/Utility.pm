package Utility;
use Exporter;
@ISA = (Exporter);
@EXPORT = qw(str_encode db_connect html_footer html_header get_yicha_url make_file_path memcache html_mojibake_str get_date yicha_sp_menu html_meikanlist load_tmpl price_dsp star_img);
use URI::Escape;
use Digest::MD5;
use DBI;
use Cache::Memcached;

sub str_encode(){
	my $str = shift;
	return uri_escape($str);
}

sub db_connect(){

	my $dsn = 'DBI:mysql:waao';
	my $user = 'mysqlweb';
	my $password = 'WaAoqzxe7h6yyHz';
	my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 1, AutoCommit => 0});

	return $dbh;
}

sub html_header(){
	my $title = shift;
	my $keywords = shift;
	my $description = shift;
	my $google = shift;
	my $mld = shift;
	
	my $html;
	
	$html .= qq{<!DOCTYPE HTML PUBLIC "-//W3C//DTD Compact HTML 1.0 Draft //EN">};
	$html .= qq{<html>};
	$html .= qq{<head>};
	$html .= qq{<meta http-equiv="content-type" CONTENT="text/html;charset=Shift_JIS">};
	$html .= qq{$google};
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

sub html_footer(){
	my $html;

	$html .= qq{<center><img src="http://img.waao.jp/logo.jpg" alt="waao.jp"></center>\n};
	$html .= qq{</body>\n};
	$html .= qq{</html>\n};
	
	return $html;

}

sub get_yicha_url(){
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

sub make_file_path(){
	my $keyword_id = shift;
	my $type = shift;

	my $dir = int($keyword_id / 1000);
	my $file = $keyword_id % 1000;
		
	my $filepath = qq{/$dir/$keyword_id/};
	$filepath = qq{/$dir/$keyword_id/$type/} if($type);
	
	return $filepath;
}

sub memcache(){

	my $memd = new Cache::Memcached {
    'servers' => [ "localhost:11211" ],
    'debug' => 0,
    'compress_threshold' => 1_000,
	};

	return $memd;
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

sub get_date(){
	my $date;
	my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
	$year = $year + 1900;
	$mon = $mon + 1;
	$date = sprintf("%d-%02d-%02d",$year,$mon,$mday);

	return $date;
}

sub yicha_sp_menu(){
	my $keyword =shift;
	my $html;
	
	my $y_p = &get_yicha_url($keyword,'p');
	my $y_v = &get_yicha_url($keyword,'v');
	my $y_i = &get_yicha_url($keyword,'i');
	my $y_m = &get_yicha_url($keyword,'m');
	$html .= qq{<h3>$keyword<font color="#ff0000">特別ﾒﾆｭｰ</font></h3>\n};
	$html .= qq{<center><img src="http://img.waao.jp/kya-.gif" widht=15 height=15> <a href="$y_p">ｵｽｽﾒ</a> <a href="$y_v">動画</a> <a href="$y_i">画像</a> <a href="$y_m">音楽</a> </center>};

	return $html;
}

sub html_meikanlist(){
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

sub load_tmpl(){
	my $base = shift;
	my $tmpl = shift;
	
my $file = qq{/var/www/vhosts/waao.jp/etc/$base/tmpl/$tmpl};
my $fh;
my $filedata;
open( $fh, "<", $file );
while( my $line = readline $fh ){ 
	$filedata .= $line;
}
close ( $fh );

	return $filedata;
}

sub price_dsp(){
	my $price = shift;

	1 while $price =~ s/(.*\d)(\d\d\d)/$1,$2/;	

	return $price;
}

sub star_img(){
	my $point = shift;
	
	my $str;
	$str = qq{<img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">};
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png">} if($point eq "5");
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-half.png">} if($point eq "4.5");
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-off.png">} if($point eq "4");
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-half.png"><img src="/img/star-off.png">} if($point eq "3.5");
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-off.png"><img src="/img/star-off.png">} if($point eq "3");
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-half.png"><img src="/img/star-off.png"><img src="/img/star-off.png">} if($point eq "2.5");
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">} if($point eq "2");
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-half.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">} if($point eq "1.5");
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">} if($point eq "1");
	$str = qq{<img src="/img/star-half.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">} if($point eq "0.5");
	$str = qq{<img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">} if($point eq "0");

	return $str;
}

1;