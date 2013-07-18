#!/usr/bin/perl
# スマフォページ作成処理
use lib qw(/var/www/vhosts/goo.to/etc/lib /var/www/vhosts/goo.to/lib/Waao);

use strict;
use Utility;
use DBI;
use Jcode;
use URI::Escape;
use CGI qw( escape );
use Date::Simple;

my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/smart/};
mkdir($dirname, 0755);

if($ARGV[0] eq "sale"){
	# android セール
	&_android_sale();
	exit;
}
if($ARGV[0] eq "top"){
	# android top
	&_android_top();
	exit;
}

# ２重起動防止
if ($$ != `/usr/bin/pgrep -fo $0`) {
print "exit \n";
    exit 1;
}
print "start \n";

# top
#&_top();


# android top
&_android_top();

# menu
&_menu();

# android カテゴリ
&_cate_top();
&_category();
&_category_free();
&_category_charge();

# android セール
&_android_sale();

# android 新着
&_android_new();

# android 新着(有料)
&_android_new_charge();

# android 新着(無料)
&_android_new_free();

# android 有料
&_android_charge();

# android 人気
&_android_pop();

&_android_free();


exit;

sub _top(){

	my $html = &_load_tmpl("top.html");
	$html = &_parts_set($html);
	my $dbh = &_db_connect();

	# android 登録件数
	my $sth = $dbh->prepare(qq{select count(*) as total from app_android });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my $total = &price_dsp($row[0]);
		$html =~s/<!--TOTAL_I-->/$total/g;
	}

	# android セール件数
	my $sth = $dbh->prepare(qq{select count(*) as total from app_android_sale where delflag = 0 });
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

sub _android_top(){
    my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/smart/android/};
    mkdir($dirname, 0755);

	my $html = &_load_tmpl("top_android.html");
	$html = &_parts_set($html);

	my $title = qq{androidアプリ};
	$html =~s/<!--H1_TITLE-->/$title/g;

	my $dbh = &_db_connect();

	# android 登録件数
	my $sth = $dbh->prepare(qq{select count(*) as total from app_android });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my $total = &price_dsp($row[0]);
		$html =~s/<!--TOTAL_I-->/$total/g;
	}

	# android セール件数
	my $sth = $dbh->prepare(qq{select count(*) as total from app_android_sale where delflag = 0 });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my $total = &price_dsp($row[0]);
		$html =~s/<!--TOTAL_I_SALE-->/$total/g;
	}

	# セール中リスト
	my $list = &_make_list($dbh, ",B.price,B.sale_price,B.datestr from  app_android as A, app_android_sale as B where A.id = B.app_id and delflag = 0 order by datestr desc limit 0, 6 ",0,0,1);
	$html =~s/<!--LIST-->/$list/g;
	
	$dbh->disconnect;

	&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/smart/android/index.html",$html);
	return;
}

sub _menu(){
    my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/smart/android/menu/};
    mkdir($dirname, 0755);

	my $html = &_load_tmpl("menu_android.html");
	$html = &_parts_set($html);

	my $android_menu = &_load_tmpl("android_menu.html");
	$html =~s/<!--androidMENU-->/$android_menu/g;

	&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/smart/android/menu/index.html",$html);
	return;
}

sub _android_sale(){
    my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/smart/android/sale/};
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

	return if($page >= 50);

	my $html = &_load_tmpl("android_sale.html");
	$html =~s/<!--PAGE-->/$page/g;
	$html = &_parts_set($html);

	my $h1title = qq{セール中のアプリ(android app)};
	$html =~s/<!--H1_TITLE-->/$h1title/g;

	my $pagemax = 51;
	my $start = 0 + ($pagemax * ($page - 1));

	my $list = &_make_list($dbh, ",B.price,B.sale_price,B.datestr from  app_android as A, app_android_sale as B where A.id = B.app_id and delflag = 0 order by datestr desc limit $start, $pagemax ",$start,0,1);
	$html =~s/<!--LIST-->/$list/g;

	my $pager .= &_pager(1,"sale-android-app");
	$html =~s/<!--PAGER-->/$pager/g;

	&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/smart/android/sale/$page.html",$html);
	$page++;
	&_sale_free_detaile($dbh,$page);

	return;
}

sub _android_new(){
    my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/smart/android/new/};
    mkdir($dirname, 0755);

	my $dbh = &_db_connect();
	# 共通パーツ
	&_android_new_detaile($dbh,1);
	$dbh->disconnect;

	return;
}

sub _android_new_detaile(){
	my $dbh = shift;
	my $page = shift;

	return if($page >= 50);

	my $html = &_load_tmpl("android_new.html");
	$html =~s/<!--PAGE-->/$page/g;
	$html = &_parts_set($html);

	my $h1title = qq{新着アプリ(android app)};
	$html =~s/<!--H1_TITLE-->/$h1title/g;

	my $pagemax = 51;
	my $start = 0 + ($pagemax * ($page - 1));

	my $list = &_make_list($dbh, " order by rdate desc, rateno desc   limit $start, $pagemax ",$start,0,0);
	$html =~s/<!--LIST-->/$list/g;

	my $pager .= &_pager(1,"new-android-app");
	$html =~s/<!--PAGER-->/$pager/g;

	&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/smart/android/new/$page.html",$html);
	$page++;
	&_android_new_detaile($dbh,$page);

	return;
}

sub _android_new_charge(){
    my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/smart/android/new-charge/};
    mkdir($dirname, 0755);

	my $dbh = &_db_connect();
	# 共通パーツ
	&_android_new_charge_detaile($dbh,1);
	$dbh->disconnect;

	return;
}

sub _android_new_charge_detaile(){
	my $dbh = shift;
	my $page = shift;

	return if($page >= 50);

	my $html = &_load_tmpl("android_new_charge.html");
	$html =~s/<!--PAGE-->/$page/g;
	$html = &_parts_set($html);

	my $h1title = qq{新着有料アプリ(android app)};
	$html =~s/<!--H1_TITLE-->/$h1title/g;

	my $pagemax = 51;
	my $start = 0 + ($pagemax * ($page - 1));

	my $list = &_make_list($dbh, " where price > 0 order by rdate desc, rateno desc  limit $start, $pagemax ",$start,0,0);
	$html =~s/<!--LIST-->/$list/g;

	my $pager .= &_pager(1,"new-charge-android-app");
	$html =~s/<!--PAGER-->/$pager/g;

	&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/smart/android/new-charge/$page.html",$html);
	$page++;
	&_android_new_charge_detaile($dbh,$page);

	return;
}

sub _android_new_free(){
    my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/smart/android/new-free/};
    mkdir($dirname, 0755);

	my $dbh = &_db_connect();
	# 共通パーツ
	&_android_new_free_detaile($dbh,1);
	$dbh->disconnect;

	return;
}

sub _android_new_free_detaile(){
	my $dbh = shift;
	my $page = shift;

	return if($page >= 50);

	my $html = &_load_tmpl("android_new_free.html");
	$html =~s/<!--PAGE-->/$page/g;
	$html = &_parts_set($html);

	my $h1title = qq{新着無料アプリ(android app)};
	$html =~s/<!--H1_TITLE-->/$h1title/g;

	my $pagemax = 51;
	my $start = 0 + ($pagemax * ($page - 1));

	my $list = &_make_list($dbh, " where price = 0 order by rdate desc, rateno desc   limit $start, $pagemax ",$start,0,0);
	$html =~s/<!--LIST-->/$list/g;

	my $pager .= &_pager(1,"new-free-android-app");
	$html =~s/<!--PAGER-->/$pager/g;

	&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/smart/android/new-free/$page.html",$html);
	$page++;
	&_android_new_free_detaile($dbh,$page);

	return;
}

sub _android_charge(){
    my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/smart/android/charge/};
    mkdir($dirname, 0755);

	my $dbh = &_db_connect();
	# 共通パーツ
	&_android_charge_detaile($dbh,1);
	$dbh->disconnect;

	return;
}

sub _android_charge_detaile(){
	my $dbh = shift;
	my $page = shift;

	return if($page >= 50);

	my $html = &_load_tmpl("android_charge.html");
	$html =~s/<!--PAGE-->/$page/g;
	$html = &_parts_set($html);

	my $h1title = qq{人気有料アプリ(android app)};
	$html =~s/<!--H1_TITLE-->/$h1title/g;

	my $pagemax = 51;
	my $start = 0 + ($pagemax * ($page - 1));

	my $list = &_make_list($dbh, " where price > 0 order by rateno desc,revcnt desc limit $start, $pagemax ",$start,0,0);
	$html =~s/<!--LIST-->/$list/g;

	my $pager .= &_pager(1,"charge-android-app");
	$html =~s/<!--PAGER-->/$pager/g;

	&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/smart/android/charge/$page.html",$html);
	$page++;
	&_android_new_free_detaile($dbh,$page);

	return;
}

sub _android_pop(){
    my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/smart/android/pop/};
    mkdir($dirname, 0755);

	my $dbh = &_db_connect();
	# 共通パーツ
	&_android_pop_detaile($dbh,1);
	$dbh->disconnect;

	return;
}

sub _android_pop_detaile(){
	my $dbh = shift;
	my $page = shift;

	return if($page >= 50);

	my $html = &_load_tmpl("android_pop.html");
	$html =~s/<!--PAGE-->/$page/g;
	$html = &_parts_set($html);

	my $h1title = qq{人気アプリ(android app)};
	$html =~s/<!--H1_TITLE-->/$h1title/g;

	my $pagemax = 51;
	my $start = 0 + ($pagemax * ($page - 1));

	my $list = &_make_list($dbh, " order by rateno desc,revcnt desc limit $start, $pagemax ",$start,0,0);
	$html =~s/<!--LIST-->/$list/g;

	my $pager .= &_pager(1,"pop-android-app");
	$html =~s/<!--PAGER-->/$pager/g;

	&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/smart/android/pop/$page.html",$html);
	$page++;
	&_android_pop_detaile($dbh,$page);

	return;
}

sub _android_free(){
    my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/smart/android/free/};
    mkdir($dirname, 0755);

	my $dbh = &_db_connect();
	# 共通パーツ
	&_android_free_detaile($dbh,1);
	$dbh->disconnect;

	return;
}

sub _android_free_detaile(){
	my $dbh = shift;
	my $page = shift;

	return if($page >= 50);

	my $html = &_load_tmpl("android_free.html");
	$html =~s/<!--PAGE-->/$page/g;
	$html = &_parts_set($html);

	my $h1title = qq{無料アプリ(android app)};
	$html =~s/<!--H1_TITLE-->/$h1title/g;

	my $pagemax = 51;
	my $start = 0 + ($pagemax * ($page - 1));

	my $list = &_make_list($dbh, " where price = 0 order by rateno desc,revcnt desc limit $start, $pagemax ",$start,0,0);
	$html =~s/<!--LIST-->/$list/g;

	my $pager .= &_pager(1,"free-android-app");
	$html =~s/<!--PAGER-->/$pager/g;

	&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/smart/android/free/$page.html",$html);
	$page++;
	&_android_free_detaile($dbh,$page);

	return;
}

sub _cate_top(){

    my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/smart/android/category/};
    mkdir($dirname, 0755);

	my $dbh = &_db_connect();

	my $html = &_load_tmpl("android_category_top.html");
	$html = &_parts_set($html);

	my $list;
	my $cnt;
	my $sth = $dbh->prepare(qq{select key_value,name from app_category where id < 6000 order by id });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		# ジャンルの代表アプリを選出
		my $start = int(rand(15));
		my $sth2 = $dbh->prepare(qq{select img from app_android where category_id =? order by rateno desc, id desc limit $start,1});
		$sth2->execute($row[0]);
		my $img;
		while(my @row2 = $sth2->fetchrow_array) {
			$img = $row2[0];
			$img=~s/\.jpg/\.100x100-75\.jpg/ig;
 			$img=~s/\.png/\.100x100-75\.png/ig;
		}
		
		$list.=qq{<div>\n};
		$list.=qq{<a href="/smart/android/category$row[0]/1.html">\n};
		$list.=qq{<h3 class="textOverflow">$row[1]</h3>};
		$list.=qq{<span class="rounded-img" style="background: url($img) no-repeat center center; width: 86px; height: 86px;">\n};
		$list.=qq{<img src="$img" style="opacity: 0;" alt="$row[1]" /></span>\n};
		$list.=qq{</a>\n};
		$list.=qq{</div>\n};

	}

	$html =~s/<!--LIST-->/$list/g;
	&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/smart/android/category/index.html",$html);

	$dbh->disconnect;
	
	return;
}

sub _category(){

	my $dbh = &_db_connect();

	my $sth = $dbh->prepare(qq{select key_value,name from app_category where id < 6000 });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/smart/android/category$row[0]/};
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

	my $html = &_load_tmpl("android_category.html");
	$html =~s/<!--PAGE-->/$page/g;
	$html =~s/<!--CNAME-->/$category_name/g;
	$html =~s/<!--CID-->/$category_id/g;
	$html = &_parts_set($html);
	my $pager .= &_pager2($page,$category_id);
	$html =~s/<!--PAGER-->/$pager/g;

	my $pagemax = 50;
	my $start =  0 + ($pagemax * ($page - 1));

	my $html_list = $html;

	my $list = &_make_list($dbh, qq{ where category_id = "$category_id" order by rateno desc,revcnt desc limit $start, $pagemax },$start);
	$html =~s/<!--LIST-->/$list/g;

	if($list){
		&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/smart/android/category$category_id/$page.html",$html);
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
		my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/smart/android/free-category$row[0]/};
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

	my $html = &_load_tmpl("android_category_free.html");
	$html =~s/<!--PAGE-->/$page/g;
	$html =~s/<!--CNAME-->/$category_name/g;
	$html =~s/<!--CID-->/$category_id/g;
	$html = &_parts_set($html);
	my $pager .= &_pager($page,"free-category$category_id-android-app");
	$html =~s/<!--PAGER-->/$pager/g;

	my $pagemax = 50;
	my $start =  0 + ($pagemax * ($page - 1));

	my $html_list = $html;

	my $list = &_make_list($dbh, qq{ where category_id = "$category_id" order by rateno desc,revcnt desc limit $start, $pagemax },$start);
	$html =~s/<!--LIST-->/$list/g;

	if($list){
		&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/smart/android/free-category$category_id/$page.html",$html);
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
		my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/smart/android/charge-category$row[0]/};
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

	my $html = &_load_tmpl("android_category_charge.html");
	$html =~s/<!--PAGE-->/$page/g;
	$html =~s/<!--CNAME-->/$category_name/g;
	$html =~s/<!--CID-->/$category_id/g;
	$html = &_parts_set($html);
	my $pager .= &_pager($page,"charge-category$category_id-android-app");
	$html =~s/<!--PAGER-->/$pager/g;

	my $pagemax = 50;
	my $start =  0 + ($pagemax * ($page - 1));

	my $html_list = $html;

	my $list = &_make_list($dbh, qq{ where category_id = "$category_id" order by rateno desc,revcnt desc limit $start, $pagemax },$start);
	$html =~s/<!--LIST-->/$list/g;

	if($list){
		&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/smart/android/charge-category$category_id/$page.html",$html);
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
	my $top_html_android = &_load_tmpl("top_html_android.html");
	$html =~s/<!--TOP_HTML_android-->/$top_html_android/g;

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
		$sth = $dbh->prepare(qq{select id,name,url,developer_id,developer_name,img,category_id,category_name,rdate,rateno,revcnt,detail,dl_max $where });
	}else{
		$sth = $dbh->prepare(qq{select id,name,url,developer_id,developer_name,img,category_id,category_name,rdate,rateno,revcnt,detail,dl_max,price from app_android  $where });
	}
	$sth->execute();
	$startno = 0 unless($startno);
	my $no = $startno;
	while(my @row = $sth->fetchrow_array) {
		$no++;
		my ($id,$name,$url,$developer_id,$developer_name,$img,$category_id,$category_name,$rdate,$rateno,$revcnt,$detail,$dl_max,$price) = @row;

		$img=~s/w124/w200/g;

		my $star_str = &_star_img($rateno);

		my $price_str;
		if($sale_flag){
			if($price > 0 ){
				$price_str.=qq{￥$row[13] → ￥$row[14]<br />};
			}else{
				$price_str.=qq{￥$row[13] → <img src="/img/Free.gif" height=15> 無料<br />};
			}
		}else{
			if($price > 0 ){
				$price_str.=qq{￥$price<br />};
			}else{
				$price_str.=qq{<img src="/img/Free.gif" height=15> 無料<br />};
			}
		}

		my $genrestr = substr($category_name,0,30);
		$revcnt = 0 unless($revcnt);

		$list.=qq{<div>\n};
		$list.=qq{<a href="/smart/android-app-$id/">\n};
		$list.=qq{<p class=price>\n};
		$list.=qq{$price_str\n};
		$list.=qq{<span class="rounded-img" style="background: url($img) no-repeat center center; width: 86px; height: 86px;">\n};
		$list.=qq{<img src="$img" style="opacity: 0;" alt="$name" /></span>\n};
		$list.=qq{</p>\n};
		$list.=qq{<h3 class="textOverflow">$name</h3>};
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
    $pagelist .= qq{<div class="ui-block-a"><a href="/smart/android/$type-$pre_page/" data-role="button" >前へ</a></div>\n};
    $pagelist .= qq{<div class="ui-block-b"><a href="/smart/android/$type-$next_page/" data-role="button" >次へ</a></div>\n};
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
    $pagelist .= qq{<div class="ui-block-a"><a href="/smart/android/category$category_id/$pre_page}.qq{.html" data-role="button" >前へ</a></div>\n};
    $pagelist .= qq{<div class="ui-block-b"><a href="/smart/android/category$category_id/$next_page}.qq{.html" data-role="button" >次へ</a></div>\n};
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
	
my $file = qq{/var/www/vhosts/goo.to/etc/makehtml/app/tmp_smf_android/$tmpl};
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
