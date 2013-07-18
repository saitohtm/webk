#!/usr/bin/perl
use lib qw(/var/www/vhosts/goo.to/etc/lib /var/www/vhosts/goo.to/lib/Waao);

use strict;
use Utility;
use DBI;
use Jcode;
use Seolinks;
use XML::Simple;
use LWP::Simple;
use URI::Escape;
use CGI qw( escape );
use Date::Simple;
use PageAnalyze;
use DataController;


#use encoding "sjis";
if($ARGV[0] eq "top"){
	# header作成
	&_header_make();
	&_top();
	exit;
}
# ２重起動防止
if ($$ != `/usr/bin/pgrep -fo $0`) {
print "exit \n";
    exit 1;
}
print "start \n";

# header作成
&_header_make();

&_top();

exit;
sub _header_make(){
	my $html = &_load_tmpl("header_tmp.html");

	my $totalsale;

	my $dbh = &_db_connect();
	# アプリ会社件数
#	my $sth = $dbh->prepare(qq{select count(*) as total from app_iphone });
#	$sth->execute();
#	while(my @row = $sth->fetchrow_array) {
#		my $total = &price_dsp($row[0]);
#		$html =~s/<!--TOTAL_I-->/$total/g;
#	}
	$dbh->disconnect;

	&_file_output("/var/www/vhosts/goo.to/etc/makehtml/app_developer/tmpl/header.html",$html);
	return;
}



sub _top(){
	my $html = &_load_tmpl("new_index2.html");

	$html = &_parts_set($html);

	my $dbh = &_db_connect();

	# OS
	my $os;
	my $sth = $dbh->prepare(qq{SELECT id, name FROM app_dev_os order by id });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$os.=qq{<option value="$row[0]">$row[1]</option>};
	}
	$html =~s/<!--OSLIST-->/$os/g;

	# ジャンル
	my $genre;
	my $sth = $dbh->prepare(qq{SELECT id, name FROM app_dev_genre order by id });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$genre.=qq{<label class="checkbox inline">};
		$genre.=qq{<input type="checkbox" name="s_genre_$row[0]" value="1"> $row[1]};
		$genre.=qq{</label>};
	}
	$html =~s/<!--GENRELIST-->/$genre/g;

	# 依頼範囲
	my $orderlist;
	my $sth = $dbh->prepare(qq{SELECT id, name FROM app_dev_order order by id });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$orderlist.=qq{<label class="checkbox inline">};
		$orderlist.=qq{<input type="checkbox" name="s_order_$row[0]" value="1"> $row[1]};
		$orderlist.=qq{</label>};
	}
	$html =~s/<!--ORDERLIST-->/$orderlist/g;
	
	# 開発予算(上限)
	my $yosan;
	my $sth = $dbh->prepare(qq{SELECT id, yosan FROM app_dev_yosan order by id });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$yosan.=qq{<option value="$row[0]">$row[1]</option>};
	}
	$html =~s/<!--YOSANLIST-->/$yosan/g;

	# 納期
	my $limit;
	my $sth = $dbh->prepare(qq{SELECT id, name FROM app_dev_limit order by id });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$limit.=qq{<option value="$row[0]">$row[1]</option>};
	}
	$html =~s/<!--LIMITLIST-->/$limit/g;

	# 機能
	my $kinou;
	my $sth = $dbh->prepare(qq{SELECT id, name FROM app_dev_kinou order by id });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$kinou.=qq{<label class="checkbox inline">};
		$kinou.=qq{<input type="checkbox" name="s_kinou_$row[0]" value="1"> $row[1]};
		$kinou.=qq{</label>};
	}
	$html =~s/<!--KINOULIST-->/$kinou/g;

	# 想定画面数
	my $gamen;
	my $sth = $dbh->prepare(qq{SELECT id, name FROM app_dev_gamen order by id });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$gamen.=qq{<option value="$row[0]">$row[1]</option>};
	}
	$html =~s/<!--GAMENLIST-->/$gamen/g;

	# 都道府県
	my $pref;
	my $sth = $dbh->prepare(qq{SELECT id, name FROM pref order by id });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$pref.=qq{<option value="$row[0]">$row[1]</option>};
	}
	$html =~s/<!--PREFLIST-->/$pref/g;

	# 検討度合い(任意)
	my $doai;
	my $sth = $dbh->prepare(qq{SELECT id, name FROM app_dev_doai order by id });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$doai.=qq{<option value="$row[0]">$row[1]</option>};
	}
	$html =~s/<!--DOAILIST-->/$doai/g;

	&_file_output("/var/www/vhosts/goo.to/httpdocs-developer-applease/index.html",$html);

	$dbh->disconnect;

	return;
}

sub _pager(){
	my $page = shift;
	my $type = shift;
	my $pagelist;

	$pagelist .= qq{<div class="pagination">\n};
	$pagelist .= qq{<ul>\n};
	if($page == 1){
	   	$pagelist .= qq{<li class="prev disabled"><a href="/iphone/$type-1/">&larr; Previous</a></li>\n};
	}else{
		my $preno = $page - 1;
	   	$pagelist .= qq{<li class="prev"><a href="/iphone/$type-$preno/">&larr; Previous</a></li>\n};
	}
	my $pageno;
	for(my $i=0; $i<10; $i++){
		$pageno = $page + $i;
		if($page eq $pageno){
		    $pagelist .= qq{<li class="active"><a href="/iphone/$type-$pageno/">$pageno</a></li>\n};
		}else{
		    $pagelist .= qq{<li><a href="/iphone/$type-$pageno/">$pageno</a></li>\n};
		}
	}
	$pageno++;
    $pagelist .= qq{<li class="next"><a href="/iphone/$type-$pageno/">Next &rarr;</a></li>\n};
    $pagelist .= qq{</ul>\n};
    $pagelist .= qq{</div>\n};

	return $pagelist;
}

sub _price_str(){
	my $price = shift;
	my $price_str;
    $price =~s/\?/￥/g;

	if($price eq 0){
		$price_str = qq{<img src="/img/Free.gif" alt="無料アプリ">};
	}elsif($price eq "無料"){
		$price_str = qq{<img src="/img/Free.gif" alt="無料アプリ">};
	}else{
		$price_str = qq{<img src="/img/E12F_20.gif" height=15> $price};
	}

	return $price_str;
}

sub _parts_set(){
	my $html = shift;

	# meta
	my $meta = &_load_tmpl("meta.html");
	$html =~s/<!--META-->/$meta/g;
	# header
	my $header = &_load_tmpl("header.html");
	$html =~s/<!--HEADER-->/$header/g;
	# social
	my $social_tag = &_load_tmpl("social_tag.html");
	$html =~s/<!--SOCIAL_TAG-->/$social_tag/g;
	# footer
	my $footer = &_load_tmpl("footer.html");
	$html =~s/<!--FOOTER-->/$footer/g;
	# slider
	my $side_free = &_load_tmpl("side_free.html");
	$html =~s/<!--SIDE_FREE-->/$side_free/g;


	# slider
	my $social_tag = &_load_tmpl("social_tag.html");
	$html =~s/<!--SOCIAL_TAG-->/$social_tag/g;

	# ad
	my $ad_header = &_load_tmpl("ad_header.html");
	$html =~s/<!--AD_HEADER-->/$ad_header/g;

	return $html;
}

sub _file_output(){
	my $filename = shift;
	my $html = shift;

	$html =~s/<!--LISTDSP-->//g;
print "$filename";
	open(OUT,"> $filename") || die('error');
	print OUT "$html";
	close(OUT);

	return;
}


sub _load_tmpl(){
	my $tmpl = shift;
	
my $file = qq{/var/www/vhosts/goo.to/etc/makehtml/app_developer/tmpl/$tmpl};
#print "$file\n";
my $fh;
my $filedata;
open( $fh, "<", $file );
while( my $line = readline $fh ){ 
	$filedata .= $line;
}
close ( $fh );
	$filedata = &_date_set($filedata);

	return $filedata;
}


sub _date_set(){
	my $html = shift;
	my $date = Date::Simple->new();
	my $ymd = $date->format('%Y/%m/%d');
	$html =~s/<!--DATE-->/$ymd/ig;
	return $html;
}

sub _db_connect(){

	my $dsn = 'DBI:mysql:waao';
	my $user = 'mysqlweb';
	my $password = 'WaAoqzxe7h6yyHz';
	my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 1, AutoCommit => 0});

	return $dbh;
}

sub price_dsp(){
	my $price = shift;

	1 while $price =~ s/(.*\d)(\d\d\d)/$1,$2/;	

	return $price;
}

sub _star_img(){
	my $point = shift;
	$point=~s/ //g;
	
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

sub _af_link(){
	my $aid = shift;
	my $link_str = shift;
	
use URI::Escape;
	my $af_link;
	
	if( $ENV{'HTTP_USER_AGENT'} =~/bot/i ){
		$af_link.=qq{<form action="$link_str">};
		$af_link.=qq{<button class="btn primary" type="submit">アプリをインストール</button>};
		$af_link.=qq{</form>};
	}else{
		#https://itunes.apple.com/jp/app/jiu-hu-zhong-xin/id619607676?mt=8&uo=4		
		my $escapestr = uri_escape($link_str);
		
#		my $str = qq{http://click.linksynergy.com/link?id=AfFNaqUQKyA&offerid=94348.}.$aid.qq{&type=2&murl=$escapestr};

		$af_link.=qq{<form action="http://click.linksynergy.com/link">};
		$af_link.=qq{<input type=hidden name=id value="AfFNaqUQKyA">};
		$af_link.=qq{<input type=hidden name=offerid value="94348.$aid">};
		$af_link.=qq{<input type=hidden name=type value=2>};
		$af_link.=qq{<input type=hidden name=murl value="$escapestr">};
		$af_link.=qq{<button class="btn primary" type="submit">アプリをインストール</button>};
		$af_link.=qq{</form>};
		$af_link.=qq{<IMG border=0 width=1 height=1 src="http://ad.linksynergy.com/fs-bin/show?id=AfFNaqUQKyA&bids=94348.}.$aid.qq{&type=2&subid=0" >};

	}

	return $af_link;
}

sub _mkdir(){
	my $dir = shift;
	
	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-developer-applease/iphone/$dir/};
	mkdir($dirname, 0755);

	return;
}

