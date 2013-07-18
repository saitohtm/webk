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
#use encoding "sjis";


# ２重起動防止
if ($$ != `/usr/bin/pgrep -fo $0`) {
    exit 1;
}


my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/androidnew/};
mkdir($dirname, 0755);

# category_slide_list作成
&_cate_slide_list();

# header作成
&_header_make();

# カテゴリ
&_cate_top();

# category page
&_category_free();

# top
#&_top();

# sale page
&_sale_free();

# charge page
&_charge();


# new page
&_new_free();

# ranking page
&_ranking_free();


exit;


sub _header_make(){
	my $html = &_load_tmpl("header_tmp.html");

	my $dbh = &_db_connect();
	my $sth = $dbh->prepare(qq{select count(*) as total from app });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my $total = &price_dsp($row[0]);
		$html =~s/<!--TOTAL-->/$total/g;
	}
	$dbh->disconnect;


	&_file_output("/var/www/vhosts/goo.to/etc/makehtml/app/tmpl_android/header.html",$html);
	return;
}

sub _cate_slide_list(){

	my $dbh = &_db_connect();

	my $list;

	my $sth = $dbh->prepare(qq{select id,name from app_category where id < 6000 order by id });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$list .= qq{<a href="/android/category$row[0]-1/">$row[1]</a><br />\n};
	}
	
	&_file_output("/var/www/vhosts/goo.to/etc/makehtml/app/tmpl_android/cate_list.html",$list);

	$dbh->disconnect;
	
	return;
}

sub _category_list(){
	my $dbh = shift;

	my $list = &_load_tmpl("cate_list.html");

	return $list;
}


sub _cate_top(){

	my $dbh = &_db_connect();

	my $html = &_load_tmpl("new_category_top.html");

	my $list;
	my $cnt;
	my $sth = $dbh->prepare(qq{select key_value,name from app_category where id < 6000 order by id });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		# ジャンルの代表アプリを選出
		my $start = int(rand(15));
		my $sth2 = $dbh->prepare(qq{select img from app_android where category_id =? order by rateno desc, id desc limit $start,1});
		$sth2->execute($row[0]);
		my $img200;
		while(my @row2 = $sth2->fetchrow_array) {
			$img200 = $row2[0];
			$img200=~s/w124/w200/g;
		}
		
		$list.=qq{<div>};
		$list.=qq{<form action="/android/category$row[0]-android-app-1/">};
		$list.=qq{<button class="btn primary" type="submit">$row[1]</button>};
		$list.=qq{</form>};
		$list.=qq{<span class="rounded-img" style="background: url($img200) no-repeat center center; width: 200px; height: 200px;"><a href="/android/category$row[0]-android-app-1/"><img src="$img200" style="opacity: 0;" alt="$row[1]" /></a></span>};
		$list.=qq{</div>};
	}
	if($list){
		$list = qq{<div id="grid-content">}.$list.qq{</div>};
	}

	$html =~s/<!--CATELIST-->/$list/g;
	$html = &_parts_set($html);
	&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/androidnew/category/index.html",$html);

	$dbh->disconnect;
	
	return;
}

sub _category_free(){

	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/androidnew/list/};
	mkdir($dirname, 0755);
	my $dbh = &_db_connect();

	my $sth = $dbh->prepare(qq{select key_value,name from app_category where id < 6000 });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/androidnew/category$row[0]/};
		mkdir($dirname, 0755);
		my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/androidnew/list/category$row[0]/};
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

	my $html = &_load_tmpl("new_category.html");
	$html =~s/<!--PAGE-->/$page/g;
	$html =~s/<!--CNAME-->/$category_name/g;
	$html =~s/<!--CID-->/$category_id/g;
	$html = &_parts_set($html);
	my $pager .= &_pager($page,"category$category_id-android-app");
	$html =~s/<!--PAGER-->/$pager/g;

	my $pagemax = 50;
	my $start =  0 + ($pagemax * ($page - 1));
	
	my $html_list = $html;
	my $list2 = &_make_list2($dbh, qq{ where category_id = "$category_id" and price = 0 order by rateno desc,revcnt desc limit $start, $pagemax },$start);
	$html_list =~s/<!--LIST-->/$list2/g;
	my $listdsp=qq{リストモード};
	$html_list =~s/<!--LISTDSP-->/$listdsp/g;

	my $list = &_make_list($dbh, qq{ where category_id = "$category_id" and price = 0 order by rateno desc,revcnt desc limit $start, $pagemax },$start);
	$html =~s/<!--LIST-->/$list/g;

	if($list){
		&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/androidnew/category$category_id/$page.html",$html);
		&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/androidnew/list/category$category_id/$page.html",$html_list);
		$page++;
		&_category_free_detaile($dbh,$page,$category_id,$category_name);
	}
	
	return;
}

sub _charge(){

my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/androidnew/charge/};
mkdir($dirname, 0755);
my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/androidnew/list/charge/};
mkdir($dirname, 0755);

	my $dbh = &_db_connect();
	# 共通パーツ
	&_charge_detaile($dbh,1);
	$dbh->disconnect;

	return;
}

sub _charge_detaile(){
	my $dbh = shift;
	my $page = shift;
	
	return if($page >= 50);

	my $html = &_load_tmpl("new_charge.html");
	$html =~s/<!--PAGE-->/$page/g;
	$html = &_parts_set($html);
	my $pager .= &_pager($page,"charge-android-app");
	$html =~s/<!--PAGER-->/$pager/g;

	my $pagemax = 50;
	my $start = 0 + ($pagemax * ($page - 1));
	my $html_list = $html;
	my $list2 = &_make_list2($dbh, " where price > 0 order by rateno desc,revcnt desc limit $start, $pagemax ",$start,2);
	$html_list =~s/<!--LIST-->/$list2/g;
	my $listdsp=qq{リストモード};
	$html_list =~s/<!--LISTDSP-->/$listdsp/g;

	my $list = &_make_list($dbh, " where price > 0 order by rateno desc,revcnt desc limit $start, $pagemax ",$start,2);
	$html =~s/<!--LIST-->/$list/g;
	if($list){
		&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/androidnew/charge/$page.html",$html);
		&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/androidnew/list/charge/$page.html",$html_list);
		$page++;
		&_charge_detaile($dbh,$page);
	}
	
	return;
}


sub _ranking_free(){

my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/androidnew/ranking/};
mkdir($dirname, 0755);
my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/androidnew/list/ranking/};
mkdir($dirname, 0755);

	my $dbh = &_db_connect();
	# 共通パーツ
	&_ranking_free_detaile($dbh,1);
	$dbh->disconnect;

	return;
}

sub _ranking_free_detaile(){
	my $dbh = shift;
	my $page = shift;
	
	return if($page >= 50);

	my $html = &_load_tmpl("new_ranking.html");
	$html =~s/<!--PAGE-->/$page/g;
	$html = &_parts_set($html);
	my $pager .= &_pager($page,"ranking-android-app");
	$html =~s/<!--PAGER-->/$pager/g;

	my $pagemax = 50;
	my $start = 0 + ($pagemax * ($page - 1));
	my $html_list = $html;
	my $list2 = &_make_list2($dbh, " where price = 0 order by rateno desc,revcnt desc limit $start, $pagemax ",$start);
	$html_list =~s/<!--LIST-->/$list2/g;
	my $listdsp=qq{リストモード};
	$html_list =~s/<!--LISTDSP-->/$listdsp/g;

	my $list = &_make_list($dbh, " where price = 0 order by rateno desc,revcnt desc limit $start, $pagemax ",$start);
	$html =~s/<!--LIST-->/$list/g;
	if($list){
		&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/androidnew/ranking/$page.html",$html);
		&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/androidnew/list/ranking/$page.html",$html_list);
		$page++;
		&_ranking_free_detaile($dbh,$page);
	}
	
	return;
}

sub _new_free(){

my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/androidnew/new/};
mkdir($dirname, 0755);
my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/androidnew/list/new/};
mkdir($dirname, 0755);
	my $dbh = &_db_connect();
	# 共通パーツ
	&_new_free_detaile($dbh,1);
	$dbh->disconnect;

	return;
}

sub _new_free_detaile(){
	my $dbh = shift;
	my $page = shift;
	
	return if($page >= 50);

	my $html = &_load_tmpl("new_new.html");
	$html =~s/<!--PAGE-->/$page/g;
	$html = &_parts_set($html);
	my $pager .= &_pager($page,"new-android-app");
	$html =~s/<!--PAGER-->/$pager/g;

	my $pagemax = 50;
	my $start = 0 + ($pagemax * ($page - 1));
	my $html_list = $html;
	my $list2 = &_make_list2($dbh, " where price = 0 order by rdate desc, rateno desc  limit $start, $pagemax ",$start);
	$html_list =~s/<!--LIST-->/$list2/g;
	my $listdsp=qq{リストモード};
	$html_list =~s/<!--LISTDSP-->/$listdsp/g;

	my $list = &_make_list($dbh, " where price = 0 order by rdate desc, rateno desc  limit $start, $pagemax ",$start);
	$html =~s/<!--LIST-->/$list/g;

	if($list){
		&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/androidnew/new/$page.html",$html);
		&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/androidnew/list/new/$page.html",$html_list);
		$page++;
		&_new_free_detaile($dbh,$page);
	}
	
	return;
}

sub _sale_free(){

my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/androidnew/sale/};
mkdir($dirname, 0755);
my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/androidnew/list/sale/};
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
	
	my $html = &_load_tmpl("new_sale.html");
	$html =~s/<!--PAGE-->/$page/g;
	$html = &_parts_set($html);
	my $pager .= &_pager($page,"sale-android-app");
	$html =~s/<!--PAGER-->/$pager/g;

	my $pagemax = 50;
	my $start = 0 + ($pagemax * ($page - 1));
	my $html_list = $html;
	my $list2 = &_make_list2($dbh, ",B.price,B.sale_price,B.datestr from app_android as A, app_android_sale as B where A.id = B.app_id and delflag = 0 order by datestr desc limit $start, $pagemax ", $start,1,1);
	$html_list =~s/<!--LIST-->/$list2/g;
	my $listdsp=qq{リストモード};
	$html_list =~s/<!--LISTDSP-->/$listdsp/g;

	my $list = &_make_list($dbh, ",B.price,B.sale_price,B.datestr from app_android as A, app_android_sale as B where A.id = B.app_id and delflag = 0 order by datestr desc limit $start, $pagemax ", $start,1,1);
	$html =~s/<!--LIST-->/$list/g;

#	if($list){
		&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/androidnew/sale/$page.html",$html);
		&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/androidnew/list/sale/$page.html",$html_list);
		$page++;
		&_sale_free_detaile($dbh,$page);
#	}
	
	return;
}

sub _top(){
	my $html = &_load_tmpl("index.html");

	my $side_free = &_load_tmpl("side_free.html");
	$html =~s/<!--SIDE_FREE-->/$side_free/g;
	$html = &_parts_set($html);

	my $dbh = &_db_connect();
	
	
	# 新着 無料セール中
	my $list;
	$list = &_make_list($dbh, " where device >= 4 and sale_flag = 1 and lang_flag = 1 group by appname order by sale desc, updated desc limit 10 ", 0,1);
	$html =~s/<!--LIST_SALE-->/$list/g;
	my $pager .= &_pager(1,"saleapp");
	$html =~s/<!--PAGER_SALE-->/$pager/g;

	# 新着 10件
	$list = &_make_list($dbh, " where device >= 4 and price = 0 and lang_flag = 1 group by appname order by rdate desc limit 10 ");
	$html =~s/<!--LIST_NEW-->/$list/g;
	my $pager .= &_pager(1,"newapp");
	$html =~s/<!--PAGER_NEW-->/$pager/g;

	&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/androidnew/index.html",$html);

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
	   	$pagelist .= qq{<li class="prev disabled"><a href="/android/$type-1/">&larr; Previous</a></li>\n};
	}else{
		my $preno = $page - 1;
	   	$pagelist .= qq{<li class="prev"><a href="/android/$type-$preno/">&larr; Previous</a></li>\n};
	}
	my $pageno;
	for(my $i=0; $i<10; $i++){
		$pageno = $page + $i;
		if($page eq $pageno){
		    $pagelist .= qq{<li class="active"><a href="/android/$type-$pageno/">$pageno</a></li>\n};
		}else{
		    $pagelist .= qq{<li><a href="/android/$type-$pageno/">$pageno</a></li>\n};
		}
	}
	$pageno++;
    $pagelist .= qq{<li class="next"><a href="/android/$type-$pageno/">Next &rarr;</a></li>\n};
    $pagelist .= qq{</ul>\n};
    $pagelist .= qq{</div>\n};

	return $pagelist;
}

sub _make_list2(){
	my $dbh = shift;
	my $where = shift;
	my $startno = shift;
	my $type_free = shift;
	my $sale_flag = shift;

	my $list;
print " $where _make_list2 $sale_flag\n";	
	my $sth;
	if($sale_flag){
		$sth = $dbh->prepare(qq{select id,name,url,developer_id,developer_name,img,category_id,category_name,rdate,rateno,revcnt,detail,dl_max $where });
	}else{
		$sth = $dbh->prepare(qq{select id,name,url,developer_id,developer_name,img,category_id,category_name,rdate,rateno,revcnt,detail,dl_max,price from app_android $where });
	}
	$sth->execute();
	$startno = 0 unless($startno);
	my $no = $startno;
	while(my @row = $sth->fetchrow_array) {
		$no++;
		my ($id,$name,$url,$developer_id,$developer_name,$img,$category_id,$category_name,$rdate,$rateno,$revcnt,$detail,$dl_max,$price) = @row;

	my $shotimgs;
	my $sth2 = $dbh->prepare(qq{select type,img1,img2,img3,img4,img5 from app_android_img where app_id = ? limit 1});
	$sth2->execute($id);
	while(my @row2 = $sth2->fetchrow_array) {
		my ($type,$img1,$img2,$img3,$img4,$img5) = @row2;
		$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img1" alt="$row[0]" /><img src="$img1" alt="$row[0]" class="preview" /></a></li>} if($img1);
		$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img2" alt="$row[0]" /><img src="$img2" alt="$row[0]" class="preview" /></a></li>} if($img2);
		$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img3" alt="$row[0]" /><img src="$img3" alt="$row[0]" class="preview" /></a></li>} if($img3);
		$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img4" alt="$row[0]" /><img src="$img4" alt="$row[0]" class="preview" /></a></li>} if($img4);
		$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img5" alt="$row[0]" /><img src="$img5" alt="$row[0]" class="preview" /></a></li>} if($img5);
	}

		$img=~s/w124/w200/g;

		my $star_str = &_star_img($rateno);

		$list .= qq{<tr>};
		$list .= qq{<td width="200" bgcolor="#000000">};
		$list .= qq{<font color="#FFFFFF">};
		$list .= qq{<span class="rounded-img" style="background: url($img) no-repeat center center; width: 200px; height: 200px;"><a href="/androidapp-$id/" target="_blank" rel="nofollow"><img src="$img" style="opacity: 0;" alt="$name" /></a></span>};
		$list .= qq{<br />};
		$list .=qq{<p><img src="/img/E20D_20.gif" width="15">$name</p>};
		$list .=qq{<a href="/category$category_id-android-app-1/">$category_name</a><br />};
		if($sale_flag){
			if($price > 0 ){
				$list .= qq{<p>￥$row[13] → ￥$row[14]<br />};
			}else{
				$list .= qq{<p>￥$row[13] → <img src="/img/Free.gif" height=15> 無料<br />};
			}


		}else{
			$list .= qq{<p>	$star_str ($revcnt)<br />$price<br />};
		}
		$list .= qq{<form action="$url"><button class="btn primary" type="submit">アプリをインストール</button></form>};
		$list .= qq{</font>};
		$list .= qq{</p>};
		$list .= qq{</td>};
		$list .= qq{<td>};

		my $ex_str = substr($detail,0,400);
		$ex_str.=qq{...};

		$list .= qq{$ex_str<br /><br />};
		$list .= qq{<ul class="hoverbox">};
		$list .= qq{$shotimgs};
		$list .= qq{</ul>};
		$list .= qq{</td>};
		$list .= qq{</tr>};

	}
	
	if($list){
		$list = qq{<table><tbody>}.$list.qq{</tbody></table>};
	}

	return $list;
}

sub _make_list(){
	my $dbh = shift;
	my $where = shift;
	my $startno = shift;
	my $type_free = shift;
	my $sale_flag = shift;

	my $list;
print " $where _make_list $sale_flag\n";	
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
		$list.=qq{<div>};
		$list.=qq{<span class="rounded-img" style="background: url($img) no-repeat center center; width: 200px; height: 200px;"><a href="/androidapp-$id/"><img src="$img" style="opacity: 0;" alt="$name" /></a></span>};
		$list.=qq{<p><img src="/img/E20D_20.gif" width="15">$name</p>};
		$list.=qq{<a href="/category>$category_id-android-app-1/">$category_name</a><br />};
		$list.=qq{$star_str ($revcnt)<br />};
		if($sale_flag){
			if($price > 0 ){
				$list.=qq{￥$row[13] → ￥$row[14]<br />};
			}else{
				$list.=qq{￥$row[13] → <img src="/img/Free.gif" height=15> 無料<br />};
			}
		}else{
			if($price > 0 ){
				$list.=qq{￥$price<br />};
			}else{
				$list.=qq{<img src="/img/Free.gif" height=15> 無料<br />};
			}
		}
		$list.=qq{<form action="$url">};
		$list.=qq{<button class="btn primary" type="submit">アプリをインストール</button>};
		$list.=qq{</form>};
		$list.=qq{</div>};
	}

	if($list){
		$list = qq{<div id="grid-content">}.$list.qq{</div>};
	}
	
	return $list;
}

sub _parts_set(){
	my $html = shift;

	# meta
	my $meta = &_load_tmpl("meta.html");
	# header
	my $header = &_load_tmpl("header.html");
	# footer
	my $footer = &_load_tmpl("footer.html");
	# slider
	my $side_free = &_load_tmpl("side_free.html");
	$html =~s/<!--SIDE_FREE-->/$side_free/g;
	my $catelist = &_category_list();
	$html =~s/<!--CATELIST-->/$catelist/g;

	$html =~s/<!--META-->/$meta/g;
	$html =~s/<!--HEADER-->/$header/g;
	$html =~s/<!--FOOTER-->/$footer/g;

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
	
print "$filename \n";
	open(OUT,"> $filename") || die('error');
	print OUT "$html";
	close(OUT);

	return;
}


sub _load_tmpl(){
	my $tmpl = shift;
	
my $file = qq{/var/www/vhosts/goo.to/etc/makehtml/app/tmpl_android/$tmpl};
$file = qq{/var/www/vhosts/goo.to/etc/makehtml/app/tmpl/$tmpl} if($tmpl eq "header.html");

#print "$file\n";
my $fh;
my $filedata;
open( $fh, "<", $file );
while( my $line = readline $fh ){ 
	$filedata .= $line;
}
close ( $fh );
	$filedata = &_date_set($filedata);
	$filedata = &_tab_set($filedata,$tmpl,2);

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
sub _tab_set(){
	my $html = shift;
	my $tmpl = shift;
	my $type = shift;
	my $tabs;

	my $dir_str=qq{/iphone};
	$dir_str=qq{/android} if($type eq 2);

	my $activ_new;
	$activ_new = qq{ class="active"} if($tmpl eq "new_new.html");
	my $activ_app;
	$activ_app = qq{ class="active"} if($tmpl eq "new_pop.html");
	my $activ_sale;
	$activ_sale = qq{ class="active"} if($tmpl eq "new_sale.html");
	my $activ_ranking;
	$activ_ranking = qq{ class="active"} if($tmpl eq "new_ranking.html");
	my $activ_charge;
	$activ_charge = qq{ class="active"} if($tmpl eq "new_charge.html");
	my $activ_category;
	$activ_category = qq{ class="active"} if($tmpl eq "new_category.html");
	my $activ_news;
	$activ_news = qq{ class="active"} if($tmpl eq "facebooksite.html");

	my $geinou = &html_mojibake_str("geinou");
	my $kyujosho = &html_mojibake_str("kyujosho");
	$tabs .= qq{<div class="container-fluid">\n};
	$tabs .= qq{<ul class="tabs">\n};
	$tabs .= qq{<li$activ_new><a href="$dir_str/new-android-app-1/">新着無料アプリ</a></li>\n};
	$tabs .= qq{<li$activ_ranking><a href="$dir_str/ranking-android-app-1/">無料アプリランキング</a></li>\n};
	$tabs .= qq{<li$activ_app><a href="$dir_str/app-1/">アプリまとめ</a></li>\n};
	$tabs .= qq{<li$activ_sale><a href="$dir_str/sale-android-app-1/">セールアプリ</a></li>\n};
	$tabs .= qq{<li$activ_charge><a href="$dir_str/charge-android-app-1/">有料アプリ</a></li>\n};
	$tabs .= qq{<li$activ_category><a href="$dir_str/category-android-app/">カテゴリ別</a></li>\n};
	$tabs .= qq{<li$activ_news><a href="$dir_str/news/">ニュース</a></li>\n};
	$tabs .= qq{</ul>\n};
	$tabs .= qq{</div>\n};

	$html =~s/<!--TABS-->/$tabs/gi;
	return $html;
}

