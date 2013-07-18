#!/usr/bin/perl
# スマフォページ作成処理
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

my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/smart/};
mkdir($dirname, 0755);

if($ARGV[0] eq "sale"){
	# iphone セール
	&_iphone_sale();
	exit;
}
if($ARGV[0] eq "top"){
	# iphone top
	&_iphone_top();
	exit;
}

# ２重起動防止
if ($$ != `/usr/bin/pgrep -fo $0`) {
print "exit \n";
    exit 1;
}
print "start \n";

# ランキング
&_apprank();

exit;

# top
&_top();


# iphone top
&_iphone_top();

# menu
&_menu();

# iphone カテゴリ
&_cate_top();
&_category();
&_category_free();
&_category_charge();


# iphone セール
&_iphone_sale();

# iphone 新着
&_iphone_new();

# iphone 新着(有料)
&_iphone_new_charge();

# iphone 新着(無料)
&_iphone_new_free();

# iphone 有料
&_iphone_charge();

# iphone 人気
&_iphone_pop();

&_iphone_free();


exit;

sub _apprank(){
&_mkdir("apprank");

my @genres = ("topfreeapplications","toppaidapplications","topgrossingapplications","topfreeipadapplications","toppaidipadapplications","topgrossingipadapplications","newfreeapplications","newpaidapplications");

my $dbh = &_db_connect();
my @categorys;
my $sth = $dbh->prepare(qq{SELECT id FROM app_category where id >= 6000 order by id desc });
$sth->execute();
while(my @row = $sth->fetchrow_array) {
	push @categorys,$row[0];
}

#
foreach my $genre (@genres){
	&_mkdir("apprank/$genre");

	my $url = qq{https://itunes.apple.com/jp/rss/$genre/limit=100/xml};
	print "all:$url\n";
	&_get_rss($dbh,$url,$genre);
	foreach my $category (@categorys){
		&_mkdir("apprank/$genre/$category");
		my $url = qq{https://itunes.apple.com/jp/rss/$genre/limit=100/genre=$category/xml};
		print "cat:$url\n";
		&_get_rss($dbh,$url,$genre,$category);

	}

}

	return;
}


sub _top(){

	my $html = &_load_tmpl("top.html");
	$html = &_parts_set($html);
	my $dbh = &_db_connect();

	# iphone 登録件数
	my $sth = $dbh->prepare(qq{select count(*) as total from app_iphone });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my $total = &price_dsp($row[0]);
		$html =~s/<!--TOTAL_I-->/$total/g;
	}

	# iphone セール件数
	my $sth = $dbh->prepare(qq{select count(*) as total from app_iphone_sale where delflag = 0 });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my $total = &price_dsp($row[0]);
		$html =~s/<!--TOTAL_I_SALE-->/$total/g;
	}

	# android 登録件数
	my $sth = $dbh->prepare(qq{select count(*) as total from app_android });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my $total = &price_dsp($row[0]);
		$html =~s/<!--TOTAL_A-->/$total/g;
	}
	# android セール件数
	my $sth = $dbh->prepare(qq{select count(*) as total from app_android_sale where delflag = 0 });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my $total = &price_dsp($row[0]);
		$html =~s/<!--TOTAL_A_SALE-->/$total/g;
	}

	$dbh->disconnect;

	&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/smart/index.html",$html);
	return;
}

sub _iphone_top(){
    my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/smart/iphone/};
    mkdir($dirname, 0755);

	my $html = &_load_tmpl("top_iphone.html");
	$html = &_parts_set($html);

	my $title = qq{iphoneアプリ};
	$html =~s/<!--H1_TITLE-->/$title/g;

	my $dbh = &_db_connect();

	# iphone 登録件数
	my $sth = $dbh->prepare(qq{select count(*) as total from app_iphone });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my $total = &price_dsp($row[0]);
		$html =~s/<!--TOTAL_I-->/$total/g;
	}

	# iphone セール件数
	my $sth = $dbh->prepare(qq{select count(*) as total from app_iphone_sale where delflag = 0 });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my $total = &price_dsp($row[0]);
		$html =~s/<!--TOTAL_I_SALE-->/$total/g;
	}

	# セール中リスト
	my $list = &_make_list($dbh, ",B.price,B.sale_price,B.datestr from  app_iphone as A, app_iphone_sale as B where A.id = B.app_id and delflag = 0 order by datestr desc limit 0, 6 ",0,0,1);
	$html =~s/<!--LIST-->/$list/g;
	
	$dbh->disconnect;

	&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/smart/iphone/index.html",$html);
	return;
}

sub _menu(){
    my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/smart/iphone/menu/};
    mkdir($dirname, 0755);

	my $html = &_load_tmpl("menu_iphone.html");
	$html = &_parts_set($html);

	my $iphone_menu = &_load_tmpl("iphone_menu.html");
	$html =~s/<!--IPHONEMENU-->/$iphone_menu/g;

	&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/smart/iphone/menu/index.html",$html);
	return;
}

sub _iphone_sale(){
    my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/smart/iphone/sale/};
    mkdir($dirname, 0755);

	my $dbh = &_db_connect();
	# 共通パーツ
	&_sale_free_detaile($dbh,1);
	$dbh->disconnect;

	return;
}

sub _sale_free_detaile(){
	my $dbh = shift;
	my $page = shift;

	return if($page >= 300);

	my $html = &_load_tmpl("iphone_sale.html");
	$html =~s/<!--PAGE-->/$page/g;
	$html = &_parts_set($html);

	my $h1title = qq{セール中のアプリ(iphone app)};
	$html =~s/<!--H1_TITLE-->/$h1title/g;

	my $pagemax = 51;
	my $start = 0 + ($pagemax * ($page - 1));

	my $list = &_make_list($dbh, ",B.price,B.sale_price,B.datestr from  app_iphone as A, app_iphone_sale as B where A.id = B.app_id and delflag = 0 order by datestr desc limit $start, $pagemax ",$start,0,1);
	$html =~s/<!--LIST-->/$list/g;

	my $pager .= &_pager(1,"sale-iphone-app");
	$html =~s/<!--PAGER-->/$pager/g;

	&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/smart/iphone/sale/$page.html",$html);
	$page++;
	&_sale_free_detaile($dbh,$page);

	return;
}

sub _iphone_new(){
    my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/smart/iphone/new/};
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

	my $h1title = qq{新着アプリ(iphone app)};
	$html =~s/<!--H1_TITLE-->/$h1title/g;

	my $pagemax = 51;
	my $start = 0 + ($pagemax * ($page - 1));

	my $list = &_make_list($dbh, " order by releaseDate desc, eva desc  limit $start, $pagemax ",$start,0,0);
	$html =~s/<!--LIST-->/$list/g;

	my $pager .= &_pager(1,"new-iphone-app");
	$html =~s/<!--PAGER-->/$pager/g;

	&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/smart/iphone/new/$page.html",$html);
	$page++;
	&_iphone_new_detaile($dbh,$page);

	return;
}

sub _iphone_new_charge(){
    my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/smart/iphone/new-charge/};
    mkdir($dirname, 0755);

	my $dbh = &_db_connect();
	# 共通パーツ
	&_iphone_new_charge_detaile($dbh,1);
	$dbh->disconnect;

	return;
}

sub _iphone_new_charge_detaile(){
	my $dbh = shift;
	my $page = shift;

	return if($page >= 300);

	my $html = &_load_tmpl("iphone_new_charge.html");
	$html =~s/<!--PAGE-->/$page/g;
	$html = &_parts_set($html);

	my $h1title = qq{新着有料アプリ(iphone app)};
	$html =~s/<!--H1_TITLE-->/$h1title/g;

	my $pagemax = 51;
	my $start = 0 + ($pagemax * ($page - 1));

	my $list = &_make_list($dbh, " where price > 0 order by releaseDate desc, eva desc  limit $start, $pagemax ",$start,0,0);
	$html =~s/<!--LIST-->/$list/g;

	my $pager .= &_pager(1,"new-charge-iphone-app");
	$html =~s/<!--PAGER-->/$pager/g;

	&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/smart/iphone/new-charge/$page.html",$html);
	$page++;
	&_iphone_new_charge_detaile($dbh,$page);

	return;
}

sub _iphone_new_free(){
    my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/smart/iphone/new-free/};
    mkdir($dirname, 0755);

	my $dbh = &_db_connect();
	# 共通パーツ
	&_iphone_new_free_detaile($dbh,1);
	$dbh->disconnect;

	return;
}

sub _iphone_new_free_detaile(){
	my $dbh = shift;
	my $page = shift;

	return if($page >= 300);

	my $html = &_load_tmpl("iphone_new_free.html");
	$html =~s/<!--PAGE-->/$page/g;
	$html = &_parts_set($html);

	my $h1title = qq{新着無料アプリ(iphone app)};
	$html =~s/<!--H1_TITLE-->/$h1title/g;

	my $pagemax = 51;
	my $start = 0 + ($pagemax * ($page - 1));

	my $list = &_make_list($dbh, " where price = 0 order by releaseDate desc, eva desc  limit $start, $pagemax ",$start,0,0);
	$html =~s/<!--LIST-->/$list/g;

	my $pager .= &_pager(1,"new-free-iphone-app");
	$html =~s/<!--PAGER-->/$pager/g;

	&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/smart/iphone/new-free/$page.html",$html);
	$page++;
	&_iphone_new_free_detaile($dbh,$page);

	return;
}

sub _iphone_charge(){
    my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/smart/iphone/charge/};
    mkdir($dirname, 0755);

	my $dbh = &_db_connect();
	# 共通パーツ
	&_iphone_charge_detaile($dbh,1);
	$dbh->disconnect;

	return;
}

sub _iphone_charge_detaile(){
	my $dbh = shift;
	my $page = shift;

	return if($page >= 300);

	my $html = &_load_tmpl("iphone_charge.html");
	$html =~s/<!--PAGE-->/$page/g;
	$html = &_parts_set($html);

	my $h1title = qq{人気有料アプリ(iphone app)};
	$html =~s/<!--H1_TITLE-->/$h1title/g;

	my $pagemax = 51;
	my $start = 0 + ($pagemax * ($page - 1));

	my $list = &_make_list($dbh, " where price > 0 order by eva desc,evacount desc limit $start, $pagemax ",$start,0,0);
	$html =~s/<!--LIST-->/$list/g;

	my $pager .= &_pager(1,"charge-iphone-app");
	$html =~s/<!--PAGER-->/$pager/g;

	&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/smart/iphone/charge/$page.html",$html);
	$page++;
	&_iphone_new_free_detaile($dbh,$page);

	return;
}

sub _iphone_pop(){
    my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/smart/iphone/pop/};
    mkdir($dirname, 0755);

	my $dbh = &_db_connect();
	# 共通パーツ
	&_iphone_pop_detaile($dbh,1);
	$dbh->disconnect;

	return;
}

sub _iphone_pop_detaile(){
	my $dbh = shift;
	my $page = shift;

	return if($page >= 50);

	my $html = &_load_tmpl("iphone_pop.html");
	$html =~s/<!--PAGE-->/$page/g;
	$html = &_parts_set($html);

	my $h1title = qq{人気アプリ(iphone app)};
	$html =~s/<!--H1_TITLE-->/$h1title/g;

	my $pagemax = 51;
	my $start = 0 + ($pagemax * ($page - 1));

	my $list = &_make_list($dbh, " order by eva desc,evacount desc limit $start, $pagemax ",$start,0,0);
	$html =~s/<!--LIST-->/$list/g;

	my $pager .= &_pager(1,"pop-iphone-app");
	$html =~s/<!--PAGER-->/$pager/g;

	&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/smart/iphone/pop/$page.html",$html);
	$page++;
	&_iphone_pop_detaile($dbh,$page);

	return;
}

sub _iphone_free(){
    my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/smart/iphone/free/};
    mkdir($dirname, 0755);

	my $dbh = &_db_connect();
	# 共通パーツ
	&_iphone_free_detaile($dbh,1);
	$dbh->disconnect;

	return;
}

sub _iphone_free_detaile(){
	my $dbh = shift;
	my $page = shift;

	return if($page >= 50);

	my $html = &_load_tmpl("iphone_free.html");
	$html =~s/<!--PAGE-->/$page/g;
	$html = &_parts_set($html);

	my $h1title = qq{無料アプリ(iphone app)};
	$html =~s/<!--H1_TITLE-->/$h1title/g;

	my $pagemax = 51;
	my $start = 0 + ($pagemax * ($page - 1));

	my $list = &_make_list($dbh, " where price = 0 order by eva desc,evacount desc limit $start, $pagemax ",$start,0,0);
	$html =~s/<!--LIST-->/$list/g;

	my $pager .= &_pager(1,"free-iphone-app");
	$html =~s/<!--PAGER-->/$pager/g;

	&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/smart/iphone/free/$page.html",$html);
	$page++;
	&_iphone_free_detaile($dbh,$page);

	return;
}

sub _cate_top(){

    my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/smart/iphone/category/};
    mkdir($dirname, 0755);

	my $dbh = &_db_connect();

	my $html = &_load_tmpl("iphone_category_top.html");
	$html = &_parts_set($html);

	my $list;
	my $cnt;
	my $sth = $dbh->prepare(qq{select id,name from app_category where id >= 6000 order by id });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		# ジャンルの代表アプリを選出
		my $start = int(rand(15));
		my $sth2 = $dbh->prepare(qq{select img100 from app_iphone where genreIds like "%$row[0]%" order by evaCurrent desc, id desc limit $start,1});
		$sth2->execute();
		my $img;
		while(my @row2 = $sth2->fetchrow_array) {
			$img = $row2[0];
			$img=~s/\.jpg/\.100x100-75\.jpg/ig;
 			$img=~s/\.png/\.100x100-75\.png/ig;
		}
		
		$list.=qq{<div>\n};
		$list.=qq{<a href="/smart/iphone/category$row[0]/1.html">\n};
		$list.=qq{<h3 class="textOverflow">$row[1]</h3>};
		$list.=qq{<span class="rounded-img" style="background: url($img) no-repeat center center; width: 86px; height: 86px;">\n};
		$list.=qq{<img src="$img" style="opacity: 0;" alt="$row[1]" /></span>\n};
		$list.=qq{</a>\n};
		$list.=qq{</div>\n};

	}

	$html =~s/<!--LIST-->/$list/g;
	&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/smart/iphone/category/index.html",$html);

	$dbh->disconnect;
	
	return;
}

sub _category(){

	my $dbh = &_db_connect();

	my $sth = $dbh->prepare(qq{select id,name from app_category where id >= 6000 });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/smart/iphone/category$row[0]/};
		mkdir($dirname, 0755);
		# 共通パーツ
		&_category_detaile($dbh,1,$row[0],$row[1]);
	}
	
	$dbh->disconnect;

	return;
}

sub _category_detaile(){
	my $dbh = shift;
	my $page = shift;
	my $category_id = shift;
	my $category_name = shift;
	
	return if($page >= 50);

	my $html = &_load_tmpl("iphone_category.html");
	$html =~s/<!--PAGE-->/$page/g;
	$html =~s/<!--CNAME-->/$category_name/g;
	$html =~s/<!--CID-->/$category_id/g;
	$html = &_parts_set($html);
	my $pager .= &_pager2($page,$category_id);
	$html =~s/<!--PAGER-->/$pager/g;

	my $pagemax = 50;
	my $start =  0 + ($pagemax * ($page - 1));

	my $html_list = $html;

	my $list = &_make_list($dbh, qq{ where genreIds like "%$category_id%" order by eva desc,evacount desc limit $start, $pagemax },$start);
	$html =~s/<!--LIST-->/$list/g;

	if($list){
		&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/smart/iphone/category$category_id/$page.html",$html);
		$page++;
		&_category_detaile($dbh,$page,$category_id,$category_name);
	}
	
	return;
}

sub _category_free(){

	my $dbh = &_db_connect();

	my $sth = $dbh->prepare(qq{select id,name from app_category where id >= 6000 });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/smart/iphone/free-category$row[0]/};
		mkdir($dirname, 0755);
		# 共通パーツ
		&_category_free_detaile($dbh,1,$row[0],$row[1]);
	}
	
	$dbh->disconnect;

	return;
}

sub _category_free_detaile(){
	my $dbh = shift;
	my $page = shift;
	my $category_id = shift;
	my $category_name = shift;
	
	return if($page >= 50);

	my $html = &_load_tmpl("iphone_category_free.html");
	$html =~s/<!--PAGE-->/$page/g;
	$html =~s/<!--CNAME-->/$category_name/g;
	$html =~s/<!--CID-->/$category_id/g;
	$html = &_parts_set($html);
	my $pager .= &_pager($page,"free-category$category_id-iphone-app");
	$html =~s/<!--PAGER-->/$pager/g;

	my $pagemax = 50;
	my $start =  0 + ($pagemax * ($page - 1));

	my $html_list = $html;

	my $list = &_make_list($dbh, qq{ where genreIds like "%$category_id%" order by eva desc,evacount desc limit $start, $pagemax },$start);
	$html =~s/<!--LIST-->/$list/g;

	if($list){
		&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/smart/iphone/free-category$category_id/$page.html",$html);
		$page++;
		&_category_detaile($dbh,$page,$category_id,$category_name);
	}
	
	return;
}

sub _category_charge(){

	my $dbh = &_db_connect();

	my $sth = $dbh->prepare(qq{select id,name from app_category where id >= 6000 });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/smart/iphone/charge-category$row[0]/};
		mkdir($dirname, 0755);
		# 共通パーツ
		&_category_charge_detaile($dbh,1,$row[0],$row[1]);
	}
	
	$dbh->disconnect;

	return;
}

sub _category_charge_detaile(){
	my $dbh = shift;
	my $page = shift;
	my $category_id = shift;
	my $category_name = shift;
	
	return if($page >= 50);

	my $html = &_load_tmpl("iphone_category_charge.html");
	$html =~s/<!--PAGE-->/$page/g;
	$html =~s/<!--CNAME-->/$category_name/g;
	$html =~s/<!--CID-->/$category_id/g;
	$html = &_parts_set($html);
	my $pager .= &_pager($page,"charge-category$category_id-iphone-app");
	$html =~s/<!--PAGER-->/$pager/g;

	my $pagemax = 50;
	my $start =  0 + ($pagemax * ($page - 1));

	my $html_list = $html;

	my $list = &_make_list($dbh, qq{ where genreIds like "%$category_id%" order by eva desc,evacount desc limit $start, $pagemax },$start);
	$html =~s/<!--LIST-->/$list/g;

	if($list){
		&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/smart/iphone/charge-category$category_id/$page.html",$html);
		$page++;
		&_category_charge_detaile($dbh,$page,$category_id,$category_name);
	}
	
	return;
}

sub _parts_set(){
	my $html = shift;

	# meta
	my $meta = &_load_tmpl("meta.html");
	$html =~s/<!--META-->/$meta/g;

	# header
	my $header = &_load_tmpl("header.html");
	$html =~s/<!--HEADER-->/$header/g;

	# top_html
	my $top_html = &_load_tmpl("top_html.html");
	$html =~s/<!--TOP_HTML-->/$top_html/g;

	# top_html
	my $top_html_iphone = &_load_tmpl("top_html_iphone.html");
	$html =~s/<!--TOP_HTML_IPHONE-->/$top_html_iphone/g;

	# footer
	my $footer = &_load_tmpl("footer.html");
	$html =~s/<!--FOOTER-->/$footer/g;

	my $footer_top = &_load_tmpl("footer_top.html");
	$html =~s/<!--FOOTER_TOP-->/$footer_top/g;

	my $adsence = &_load_tmpl("adsence.html");
	$html =~s/<!--ADSENCE-->/$adsence/g;

	my $adlantice = &_load_tmpl("adlantice.html");
	$html =~s/<!--ADLANTICE-->/$adlantice/g;

	return $html;
}

sub _make_list(){
	my $dbh = shift;
	my $where = shift;
	my $startno = shift;
	my $type_free = shift;
	my $sale_flag = shift;

	my $list;
print " $where _make_list \n";	
	my $sth;

	if($sale_flag){
		$sth = $dbh->prepare(qq{select name, url, img100, eva, evacount,formattedPrice,id,genres,genre_id $where });
	}else{
		$sth = $dbh->prepare(qq{select name, url, img100, eva, evacount,formattedPrice,id,genres,genre_id from app_iphone $where });
	}
	$sth->execute();
	$startno = 0 unless($startno);
	my $no = $startno;
	while(my @row = $sth->fetchrow_array) {
		$no++;
		my $img = $row[2];
		$img=~s/\.jpg/\.100x100-75\.jpg/ig;
		$img=~s/\.png/\.100x100-75\.png/ig;

		if($type_free eq 1){
			next if($row[9] != 0);
		}

		my $eva = $row[3];
		$eva=0 unless($eva);
		my $star_str = &_star_img($eva);

		my $price_str;
		if($sale_flag){
			if($row[10] > 0 ){
				$price_str.=qq{￥$row[9] → ￥$row[10]<br />};
			}else{
				$price_str.=qq{￥$row[9] → <img src="/img/Free.gif" height=15><br />};
			}
		}else{
			$price_str.=qq{$price_str<br />};
		}

		my $genrestr = substr($row[7],0,30);
		$row[4] = 0 unless($row[4]);

		$list.=qq{<div>\n};
		$list.=qq{<a href="/smart/iphone-app-$row[6]/">\n};
		$list.=qq{<p class=price>\n};
		$list.=qq{$price_str\n};
		$list.=qq{<span class="rounded-img" style="background: url($img) no-repeat center center; width: 86px; height: 86px;">\n};
		$list.=qq{<img src="$img" style="opacity: 0;" alt="$row[0]" /></span>\n};
		$list.=qq{</p>\n};
		$list.=qq{<h3 class="textOverflow">$row[0]</h3>};
		$list.=qq{$star_str};
		$list.=qq{<p class="textOverflow category">$genrestr</p>};
		$list.=qq{</a>\n};
		$list.=qq{</div>\n};

	}
print "$where: $no\n";

	
	return $list;
}

sub _pager(){
	my $page = shift;
	my $type = shift;
	my $pagelist;

	my $pre_page = $page - 1;
	$pre_page = 1 if($pre_page <= 1);
	my $next_page = $page + 1;

    $pagelist .= qq{<div class="ui-grid-a">\n};
    $pagelist .= qq{<div class="ui-block-a"><a href="/smart/iphone/$type-$pre_page/" data-role="button" >前へ</a></div>\n};
    $pagelist .= qq{<div class="ui-block-b"><a href="/smart/iphone/$type-$next_page/" data-role="button" >次へ</a></div>\n};
    $pagelist .= qq{</div><!-- /grid-a -->\n};


	return $pagelist;
}
sub _pager2(){
	my $page = shift;
	my $category_id = shift;
	my $pagelist;

	my $pre_page = $page - 1;
	$pre_page = 1 if($pre_page <= 1);
	my $next_page = $page + 1;

    $pagelist .= qq{<div class="ui-grid-a">\n};
    $pagelist .= qq{<div class="ui-block-a"><a href="/smart/iphone/category$category_id/$pre_page}.qq{.html" data-role="button" >前へ</a></div>\n};
    $pagelist .= qq{<div class="ui-block-b"><a href="/smart/iphone/category$category_id/$next_page}.qq{.html" data-role="button" >次へ</a></div>\n};
    $pagelist .= qq{</div><!-- /grid-a -->\n};


	return $pagelist;
}


sub _file_output(){
	my $filename = shift;
	my $html = shift;
	
	open(OUT,"> $filename") || die('error');
	print OUT "$html";
	close(OUT);

	return;
}


sub _load_tmpl(){
	my $tmpl = shift;
	
my $file = qq{/var/www/vhosts/goo.to/etc/makehtml/app/tmp_smf_iphone/$tmpl};
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

sub _mkdir(){
	my $dir = shift;
	
	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/smart/iphone/$dir/};
	mkdir($dirname, 0755);

	return;
}

sub _get_name(){
	my $keyword = shift;
	
	my $name;
	$name->{topfreeapplications} = qq{無料アプリ};
	$name->{toppaidapplications} = qq{有料アプリ};
	$name->{topgrossingapplications} = qq{トップセールスアプリ};
	$name->{topfreeipadapplications} = qq{無料ipadアプリ};
	$name->{toppaidipadapplications} = qq{有料ipadアプリ};
	$name->{topgrossingipadapplications} = qq{トップセールスipadアプリ};
	$name->{newfreeapplications} = qq{新着無料アプリ};
	$name->{newpaidapplications} = qq{新着有料アプリ};

	
	return $name->{$keyword};
}

sub _get_rss(){
	my $dbh = shift;
	my $url = shift;
	my $genre = shift;
	my $category = shift;

	my $response = get($url);	
	my $xml = new XML::Simple;
	my $xml_val = $xml->XMLin($response);

	my $list;

	foreach my $app_info (@{$xml_val->{entry}}){
		my $a = qq{im:id};
		my $app_id = $app_info->{id}->{$a};
print "INS $app_id \n";
		# データ更新
		my $check_flag;
		my ($name, $url, $img100, $eva, $evacount, $formattedPrice, $id, $genres, $genre_id);
		my $sth = $dbh->prepare(qq{SELECT name, url, img100, eva, evacount,formattedPrice,id,genres,genre_id FROM app_iphone where id = ? limit 1 });
		$sth->execute($app_id);
		while(my @row = $sth->fetchrow_array) {
			$check_flag = 1;
			($name, $url, $img100, $eva, $evacount, $formattedPrice, $id, $genres, $genre_id) = @row;
		}

		unless($check_flag){
			my $data = &itunes_page_lookup($app_id);
			&app_iphone_data($dbh, $data);

			$name = $data->{name};
			$url = $data->{dl_url};
			$img100 = $data->{icon};
			$eva = $data->{rateno};
			$evacount = $data->{revcnt};
			$formattedPrice = $data->{sale_price};
			$id = $app_id;
			$genres = $data->{category_name}; 
			$genre_id =$data->{category_id};
		}

		$img100=~s/\.jpg/\.100x100-75\.jpg/ig;
		$img100=~s/\.png/\.100x100-75\.png/ig;
		$eva=0 unless($eva);
		$evacount=0 unless($evacount);
		my $star_str = &_star_img($eva);
		my $price_str = &_price_str($formattedPrice);
		my $genrestr = substr($genres,0,30);
		$genrestr.=qq{...};


		$list.=qq{<div>\n};
		$list.=qq{<a href="/smart/iphone-app-$id/">\n};
		$list.=qq{<p class=price>\n};
		$list.=qq{$price_str\n};
		$list.=qq{<span class="rounded-img" style="background: url($img100) no-repeat center center; width: 86px; height: 86px;">\n};
		$list.=qq{<img src="$img100" style="opacity: 0;" alt="$name" /></span>\n};
		$list.=qq{</p>\n};
		$list.=qq{<h3 class="textOverflow">$name</h3>};
		$list.=qq{$star_str};
		$list.=qq{<p class="textOverflow category">$genrestr</p>};
		$list.=qq{</a>\n};
		$list.=qq{</div>\n};

#		$list.= &_af_link($id,$url);
		

	}

	my $html = &_load_tmpl("new_apprank.html");
	$html =~s/<!--LIST-->/$list/g;

	my $titlestr = &_get_name($genre);
	$html =~s/<!--TITLESTR-->/$titlestr/g;
#	my $ranktab = &_rank_tab_set($genre);
#	$html =~s/<!--RANK_TABS-->/$ranktab/g;

	my $caterank;
	my $sth = $dbh->prepare(qq{SELECT id,name FROM app_category where id >= 6000 order by id });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$caterank .= qq{<li><a href="/smart/iphone/apprank/$genre/$row[0]/">$row[1]</a></li> };
	}
	$html =~s/<!--CATERANKLIST-->/$caterank/g;


	$html = &_parts_set($html);

	my $dir_str = qq{$genre};

	if($category){
		$dir_str = qq{$genre/$category};
	}else{
		my $menu_html = &_load_tmpl("new_apprank_menu.html");
		$menu_html = &_parts_set($menu_html);
		$menu_html =~s/<!--CATERANKLIST-->/$caterank/g;
		my $pre_str = qq{menu/};
		my $af_str = qq{apprank/$dir_str/menu.html};
		$menu_html =~s/$pre_str/$af_str/g;

		&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/smart/iphone/apprank/$dir_str/menu.html",$menu_html);
	}
	
	&_move_file($dir_str);

	# 履歴
	my $backstr;
	for (my $i=1; $i<=30; $i++){
		$backstr .= qq{<li><a href="/smart/iphone/apprank/$dir_str/index$i.html">$i日前</a></li> };
	}
	$html =~s/<!--BACKLIST-->/$backstr/g;

	my $pre_str = qq{menu/};
	my $af_str = qq{apprank/$dir_str/menu.html};
	$html =~s/$pre_str/$af_str/g;


	&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/smart/iphone/apprank/$dir_str/index.html",$html);


	return;
}

sub _move_file(){
	my $dir = shift;
	
	for (my $i=30; $i>=0; $i--){
		if($i eq 30){
		}else{
			my $next = $i + 1;
			$i = undef if($i eq 0);
			my $cmd = qq{mv /var/www/vhosts/goo.to/httpdocs-applease/smart/iphone/apprank/$dir/index$i.html /var/www/vhosts/goo.to/httpdocs-applease/smart/iphone/apprank/$dir/index$next.html};
eval{
			`$cmd`;
};
		}
	}

	return;
}

sub _price_str(){
	my $price = shift;
	my $price_str;
    $price =~s/\?/￥/g;

	if($price eq 0){
#		$price_str = qq{<img src="/img/Free.gif" alt="無料アプリ">};
	}elsif($price eq "無料"){
#		$price_str = qq{<img src="/img/Free.gif" alt="無料アプリ">};
	}else{
		$price_str = qq{<img src="/img/E12F_20.gif" height=15> $price};
	}

	return $price_str;
}
