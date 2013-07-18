#!/usr/bin/perl
# スマフォページ作成処理
use lib qw(/var/www/vhosts/goo.to/etc/lib /var/www/vhosts/goo.to/lib/Waao);

use strict;
use Utility;
use DBI;
use Jcode;
#use Seolinks;
use XML::Simple;
use LWP::Simple;
use URI::Escape;
use CGI qw( escape );
use Date::Simple;

if($ARGV[0] eq "sale"){
	&_iphone_sale();
	exit;
}

# top
&_top();

# iphone
&_iphone();

# android

exit;

sub _top(){
	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/smf/};
	mkdir($dirname, 0755);

	my $html = &_load_tmpl("smf_top.html");
	$html = &_parts_set($html);

	&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/smf/index.html",$html);
	return;
}

sub _parts_set(){
	my $html = shift;

	# header
	my $header = &_load_tmpl("smf_header.html");
	# footer
	my $footer = &_load_tmpl("smf_footer.html");
	$html =~s/<!--HEADER-->/$header/g;
	$html =~s/<!--FOOTER-->/$footer/g;

	my $adsence = &_load_tmpl("adsence.html");
	$html =~s/<!--ADSENCE-->/$adsence/g;

	return $html;
}


sub _iphone(){

# ディレクトリ作成
my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/smf/iphone/};
mkdir($dirname, 0755);

&_iphone_top();

&_iphone_category();

&_iphone_charge();

&_iphone_sale();

&_iphone_new();

&_iphone_ranking();

return;

#&_iphone_top100();

my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/smf/iphone/free/};
mkdir($dirname, 0755);
my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/smf/iphone/charge/};
mkdir($dirname, 0755);

my $html = &_load_tmpl("iphone_top.html");
my $categorylist;
my $game_flag;
my $dbh = &_db_connect();
my $sth = $dbh->prepare(qq{select id,name,img,game from app_category where flag = 1 });
$sth->execute();
while(my @row = $sth->fetchrow_array) {
	if($row[3]){
		$categorylist .= qq{<li data-role="list-divider">ゲーム</li>\n} unless($game_flag);
		$game_flag = 1;
	}
	$categorylist .= qq{<li><a href="/iphone-$row[0]-1"><img src="/img/$row[2]" height="20" class="ui-li-icon">$row[1]</a></li>\n};
#	&_iphone_category($row[0],$row[1],1);
#	&_iphone_category($row[0],$row[1],1,"free");
#	&_iphone_category($row[0],$row[1],1,"charge");
#	&_iphone_category($row[0],$row[1],1,"new");
}
$html =~s/<!--CATELIST-->/$categorylist/g;

&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/smf/iphone/index.html",$html);

$dbh->disconnect;

return;
}

sub _iphone_top(){
	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/smf/};
	mkdir($dirname, 0755);

	my $html = &_load_tmpl("iphone_top.html");
	$html = &_parts_set($html);

	&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/smf/iphone/index.html",$html);
	return;
}


sub _iphone_sale(){
	
my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/smf/iphone/sale/};
mkdir($dirname, 0755);

	my $dbh = &_db_connect();
	# 共通パーツ
	&_iphone_sale_detaile($dbh,1);
	$dbh->disconnect;

	return;
}

sub _iphone_sale_detaile(){
	my $dbh = shift;
	my $page = shift;

	return if($page >= 300);
	
	my $html = &_load_tmpl("iphone_sale.html");
	$html =~s/<!--PAGE-->/$page/g;
	$html = &_parts_set($html);

	my $pagemax = 50;
	my $start = 0 + ($pagemax * ($page - 1));
	my $list = &_make_list($dbh, " where device < 4 and sale_flag = 1 and lang_flag = 1 group by appname order by saledate desc, review desc, eva desc  limit $start, $pagemax ", $start,1);
	$html =~s/<!--LIST-->/$list/g;
	my $pager .= &_pager($page,"saleapp");
	$html =~s/<!--PAGER-->/$pager/g;

	&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/smf/iphone/sale/$page.html",$html);
	$page++;
	&_iphone_sale_detaile($dbh,$page);
	
	return;
}

sub _iphone_new(){

my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/smf/iphone/new/};
mkdir($dirname, 0755);

	my $dbh = &_db_connect();
	# 共通パーツ
	&_iphone_new_detaile($dbh,1);
	$dbh->disconnect;

	return;
}

sub _iphone_new_detaile(){
	my $dbh = shift;
	my $page = shift;
	
	return if($page >= 300);

	my $html = &_load_tmpl("iphone_new.html");
	$html =~s/<!--PAGE-->/$page/g;
	$html = &_parts_set($html);

	my $pagemax = 50;
	my $start = 0 + ($pagemax * ($page - 1));
	my $list = &_make_list($dbh, " where device < 4 and price = 0 and lang_flag = 1 group by appname order by rdate desc, eva desc  limit $start, $pagemax ",$start);
	$html =~s/<!--LIST-->/$list/g;
	my $pager .= &_pager($page,"newapp");
	$html =~s/<!--PAGER-->/$pager/g;

	if($list){
		&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/smf/iphone/new/$page.html",$html);
		$page++;
		&_iphone_new_detaile($dbh,$page);
	}
	
	return;
}


sub _iphone_ranking(){

my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/smf/iphone/ranking/};
mkdir($dirname, 0755);

	my $dbh = &_db_connect();
	# 共通パーツ
	&_iphone_ranking_detaile($dbh,1);
	$dbh->disconnect;

	return;
}

sub _iphone_ranking_detaile(){
	my $dbh = shift;
	my $page = shift;
	
	return if($page >= 3000);

	my $html = &_load_tmpl("iphone_ranking.html");
	$html =~s/<!--PAGE-->/$page/g;
	$html = &_parts_set($html);

	my $pagemax = 50;
	my $start = 0 + ($pagemax * ($page - 1));
	my $list = &_make_list($dbh, " where device < 4 and price = 0 and lang_flag = 1 group by appname order by eva desc,review desc limit $start, $pagemax ",$start);
	$html =~s/<!--LIST-->/$list/g;
	my $pager .= &_pager($page,"appranking");
	$html =~s/<!--PAGER-->/$pager/g;

	if($list){
		&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/smf/iphone/ranking/$page.html",$html);
		$page++;
		&_iphone_ranking_detaile($dbh,$page);
	}
	
	return;
}

sub _iphone_charge(){

	my $dbh = &_db_connect();
	# 共通パーツ
	&_iphone_charge_detaile($dbh,1);
	$dbh->disconnect;

	return;
}

sub _iphone_charge_detaile(){
	my $dbh = shift;
	my $page = shift;
	
	return if($page >= 3000);

	my $html = &_load_tmpl("iphone_charge.html");
	$html =~s/<!--PAGE-->/$page/g;
	$html = &_parts_set($html);

	my $pagemax = 50;
	my $start = 0 + ($pagemax * ($page - 1));
	my $list = &_make_list($dbh, " where device < 4 and price > 0 and lang_flag = 1 group by appname order by eva desc,review desc limit $start, $pagemax ",$start,2);
#print "\n\n$list\n\n";
	$html =~s/<!--LIST-->/$list/g;
	my $pager .= &_pager($page,"chargeapp");
	$html =~s/<!--PAGER-->/$pager/g;

	if($list){
		&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/smf/iphone/charge/$page.html",$html);
		$page++;
		&_iphone_charge_detaile($dbh,$page);
	}
	
	return;
}

sub _iphone_category(){

my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/smf/iphone/category/};
mkdir($dirname, 0755);

	my $dbh = &_db_connect();

	my $html = &_load_tmpl("iphone_category_top.html");
	$html = &_parts_set($html);

my $sth = $dbh->prepare(qq{select id,name,img,game from app_category where flag = 1 });
$sth->execute();
my $categorylist;
my $game_flag;
while(my @row = $sth->fetchrow_array) {
	if($row[3]){
		$categorylist .= qq{<li data-role="list-divider">ゲーム</li>\n} unless($game_flag);
		$game_flag = 1;
	}
	$categorylist .= qq{<li><a href="/smf/iphone/category$row[0]-1/"><img src="/img/$row[2]" height="20" class="ui-li-icon">$row[1]</a></li>\n};
}
$html =~s/<!--CATELIST-->/$categorylist/g;

&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/smf/iphone/category/index.html",$html);

	my $sth = $dbh->prepare(qq{select id,name from app_category where id >= 6000 });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/smf/iphone/category$row[0]/};
		mkdir($dirname, 0755);
		# 共通パーツ
		&_iphone_category_detaile($dbh,1,$row[0],$row[1]);
	}
	
	$dbh->disconnect;

	return;
}

sub _iphone_category_detaile(){
	my $dbh = shift;
	my $page = shift;
	my $category_id = shift;
	my $category_name = shift;
	
	return if($page >= 3000);

	my $html = &_load_tmpl("iphone_category.html");
	$html =~s/<!--PAGE-->/$page/g;
	$html =~s/<!--CNAME-->/$category_name/g;
	$html = &_parts_set($html);

	my $pagemax = 50;
	my $start =  0 + ($pagemax * ($page - 1));
	my $list = &_make_list($dbh, " where device < 4 and category = $category_id and price = 0 and lang_flag = 1 group by appname order by eva desc,review desc limit $start, $pagemax ",$start);
	$html =~s/<!--LIST-->/$list/g;
	my $pager .= &_pager($page,"category$category_id");
	$html =~s/<!--PAGER-->/$pager/g;

	if($list){
		&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/smf/iphone/category$category_id/$page.html",$html);
		$page++;
		&_iphone_category_detaile($dbh,$page,$category_id,$category_name);
	}
	
	return;
}



sub _make_list(){
	my $dbh = shift;
	my $where = shift;
	my $startno = shift;
	my $type_free = shift;

	my $list;
print " $where _make_list \n";	
	my $sth = $dbh->prepare(qq{select id, img, dl_url, appname, ex_str, device, category, developer, price, sale, rdate, eva, review, rank, saledate from app $where });
	$sth->execute();
	$startno = 0 unless($startno);
	my $no = $startno;
	while(my @row = $sth->fetchrow_array) {
		$no++;
		if($type_free eq 1){
			next if($row[9] != 0);
		}

		my $star_str = &_star_img($row[11]);
		my $review = qq{未評価};
		$review = $row[12] if($row[12]);

		my $price_str;
		if($type_free eq 2){
			if($row[8] > $row[9]){
				if($row[9] eq 0){
					$price_str .= qq{<S>$row[8]</S> → <font color="#FF0000"><b>無料!!</b></font>};
				}else{
					$price_str .= qq{<S>$row[8]</S> → <font color="#FF0000"><b>$row[9]</b></font>};
				}
			}else{
				$price_str .= qq{<b>$row[8]</b>};
			}
		}elsif($type_free){
			$price_str .= qq{<S>$row[8]</S> → <font color="#FF0000"><b>無料!!</b></font>};
		}else{
			$price_str .= qq{<font color="#FF0000"><b>無料!!</b></font>};
		}

		$list.=qq{<li><a href="/smf/app-$row[0]/"><img src="$row[1]" alt="$row[3]"><h3>$no.$row[3]</h3><p>$price_str<br />$star_str（$review）</p></a></li>\n};

	}
print "$where: $no\n";

	
	return $list;
}

sub _pager(){
	my $page = shift;
	my $type = shift;
	my $pagelist;

	my $next_page = $page + 1;
    $pagelist .= qq{<div aligne=right><a href="/smf/iphone/$type-$next_page/" data-role="button" data-inline="true">次へ</a></div>\n};

	return $pagelist;
}


sub _file_output(){
	my $filename = shift;
	my $html = shift;
print $filename."\n";	
	open(OUT,"> $filename") || die('error');
	print OUT "$html";
	close(OUT);

	return;
}


sub _load_tmpl(){
	my $tmpl = shift;
	
my $file = qq{/var/www/vhosts/goo.to/etc/makehtml/app/tmpl_smf/$tmpl};
print "$file\n";
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
