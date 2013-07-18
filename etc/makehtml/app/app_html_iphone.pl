#!/usr/bin/perl
# スマフォページ作成処理
# ディリーは、100頁のみ更新
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

# New Directory
# / 総合トップ
# /iphone/ iphoneトップ
# /iphone/charge-iphone-app-<PAGE>/
#   └D:/iphone/charge/
# /iphone/ranking-iphone-app-<PAGE>/
#   └D:/iphone/ranking/

# 旧URL
# /iphone/chargeapp-<PAGE>/
#   └D:/charge/

#use encoding "sjis";
if($ARGV[0] eq "top"){
# header作成
&_header_make();
	&_top2();
	exit;
}
# ２重起動防止
if ($$ != `/usr/bin/pgrep -fo $0`) {
print "exit \n";
    exit 1;
}
print "start \n";

# header作成
#&_header_make();


if($ARGV[0] eq "sale"){
	&_sale_free();
	exit;
}

&_top2();

# ランキング
&_apprank();

&_sale_free();

exit;

&_top();
&_top2();

my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/iphone/list/};
mkdir($dirname, 0755);
my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/iphone/category/};
mkdir($dirname, 0755);

# category page
&_category_free();

# ranking page
&_ranking_free();

# charge page
&_charge();

&_cate_top();

# category_slide_list作成
&_cate_slide_list();

# new page
&_new_free();

# sale page
&_sale_free();

# そのた
&_else_pages();


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

&_mkdir("appranklist");
foreach my $genre (@genres){
	&_mkdir("appranklist/$genre");

	my $url = qq{https://itunes.apple.com/jp/rss/$genre/limit=100/xml};
	print "all:$url\n";
	&_get_rsslist($dbh,$url,$genre);
	foreach my $category (@categorys){
		&_mkdir("appranklist/$genre/$category");
		my $url = qq{https://itunes.apple.com/jp/rss/$genre/limit=100/genre=$category/xml};
		print "cat:$url\n";
		&_get_rsslist($dbh,$url,$genre,$category);

	}
}


&_mkdir("apprank300");
foreach my $genre (@genres){
	&_mkdir("apprank300/$genre");

	my $url = qq{https://itunes.apple.com/jp/rss/$genre/limit=300/xml};
	print "all:$url\n";
	&_get_rss300($dbh,$url,$genre);
	foreach my $category (@categorys){
		&_mkdir("apprank300/$genre/$category");
		my $url = qq{https://itunes.apple.com/jp/rss/$genre/limit=300/genre=$category/xml};
		print "cat:$url\n";
		&_get_rss300($dbh,$url,$genre,$category);

	}
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

sub _else_pages(){

	my $html = &_load_tmpl("applease.html");
	$html = &_parts_set($html);
	&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/applease/index.html",$html);

	my $html = &_load_tmpl("privacy.html");
	$html = &_parts_set($html);
	&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/privacy/index.html",$html);

	my $html = &_load_tmpl("manage.html");
	$html = &_parts_set($html);
	&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/manage/index.html",$html);

	my $html = &_load_tmpl("legal.html");
	$html = &_parts_set($html);
	&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/legal/index.html",$html);

	return;
}

sub _header_make(){
	my $html = &_load_tmpl("header_tmp.html");

	my $totalsale;

	my $dbh = &_db_connect();
	my $sth = $dbh->prepare(qq{select count(*) as total from app_iphone });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my $total = &price_dsp($row[0]);
		$html =~s/<!--TOTAL_I-->/$total/g;
	}
	my $sth = $dbh->prepare(qq{select count(*) as total from app_iphone_sale where delflag = 0 });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$totalsale = $row[0];
	}

	my $sth = $dbh->prepare(qq{select count(*) as total from app_android });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my $total = &price_dsp($row[0]);
		$html =~s/<!--TOTAL_A-->/$total/g;
	}
	my $sth = $dbh->prepare(qq{select count(*) as total from app_android_sale where delflag = 0 });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$totalsale = $totalsale + $row[0];
	}

	my $totalsale = &price_dsp($totalsale);
	$html =~s/<!--TOTAL_S-->/$totalsale/g;

	$dbh->disconnect;


	&_file_output("/var/www/vhosts/goo.to/etc/makehtml/app/tmpl/header.html",$html);
	return;
}

sub _cate_top(){

	my $dbh = &_db_connect();

	my $html = &_load_tmpl("new_category_top.html");

	my $list;
	my $cnt;
	my $sth = $dbh->prepare(qq{select id,name from app_category where id >= 6000 order by id });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		# ジャンルの代表アプリを選出
		my $start = int(rand(15));
		my $sth2 = $dbh->prepare(qq{select img100 from app_iphone where genreIds like "%$row[0]%" order by evaCurrent desc, id desc limit $start,1});
		$sth2->execute();
		my $img200;
		while(my @row2 = $sth2->fetchrow_array) {
			$img200 = $row2[0];
			$img200=~s/\.jpg/\.200x200-75\.jpg/ig;
			$img200=~s/\.png/\.200x200-75\.png/ig;
		}
		
		$list.=qq{<div>};
		$list.=qq{<form action="/iphone/category$row[0]-iphone-app-1/">};
		$list.=qq{<button class="btn primary" type="submit">$row[1]</button>};
		$list.=qq{</form>};
		$list.=qq{<span class="rounded-img" style="background: url($img200) no-repeat center center; width: 200px; height: 200px;"><a href="/iphone/category$row[0]-iphone-app-1/"><img src="$img200" style="opacity: 0;" alt="$row[1]" /></a></span>};
		$list.=qq{</div>};
	}
	if($list){
		$list = qq{<div id="grid-content">}.$list.qq{</div>};
	}

	$html =~s/<!--CATELIST-->/$list/g;
	$html = &_parts_set($html);
	&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/iphone/category/index.html",$html);

	$dbh->disconnect;
	
	return;
}

sub _cate_slide_list(){

	my $dbh = &_db_connect();

	my $list;

	my $sth = $dbh->prepare(qq{select id,name from app_category where id >= 6000 order by id });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$list .= qq{<a href="/category$row[0]-1/">$row[1]</a><br />\n};
	}
	
	&_file_output("/var/www/vhosts/goo.to/etc/makehtml/app/tmpl/cate_list.html",$list);

	$dbh->disconnect;
	
	return;
}

sub _category_list(){
	my $dbh = shift;

	my $list = &_load_tmpl("cate_list.html");

	return $list;
}


sub _category_free(){

	my $dbh = &_db_connect();

	my $sth = $dbh->prepare(qq{select id,name from app_category where id >= 6000 });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/iphone/category$row[0]/};
		mkdir($dirname, 0755);
		my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/iphone/list/category$row[0]/};
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
	my $pager .= &_pager($page,"category$category_id-iphone-app");
	$html =~s/<!--PAGER-->/$pager/g;

	my $pagemax = 50;
	my $start =  0 + ($pagemax * ($page - 1));

	my $html_list = $html;
	my $list2 = &_make_list2($dbh, qq{ where genreIds like "%$category_id%" order by eva desc,evacount desc limit $start, $pagemax },$start);
	$html_list =~s/<!--LIST-->/$list2/g;
	my $listdsp=qq{リストモード};
	$html_list =~s/<!--LISTDSP-->/$listdsp/g;

	my $list = &_make_list($dbh, qq{ where genreIds like "%$category_id%" order by eva desc,evacount desc limit $start, $pagemax },$start);
	$html =~s/<!--LIST-->/$list/g;

	if($list){
		&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/iphone/category$category_id/$page.html",$html);
		&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/iphone/list/category$category_id/$page.html",$html_list);
		$page++;
		&_category_free_detaile($dbh,$page,$category_id,$category_name);
	}
	
	return;
}

sub _charge(){

	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/iphone/charge/};
	mkdir($dirname, 0755);
	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/iphone/list/charge/};
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
	
print "A";
	return if($page >= 50);

	my $html = &_load_tmpl("new_charge.html");
	$html =~s/<!--PAGE-->/$page/g;
	$html = &_parts_set($html);
	my $pager .= &_pager($page,"charge-iphone-app");
	$html =~s/<!--PAGER-->/$pager/g;
print "B";

	my $pagemax = 50;
	my $start = 0 + ($pagemax * ($page - 1));

	my $html_list = $html;
	my $list2 = &_make_list2($dbh, " where price > 0 order by eva desc,evacount desc limit $start, $pagemax ",$start,2);
	$html_list =~s/<!--LIST-->/$list2/g;
	my $listdsp=qq{リストモード};
	$html_list =~s/<!--LISTDSP-->/$listdsp/g;
print "C";
	
	my $list = &_make_list($dbh, " where price > 0 order by eva desc,evacount desc limit $start, $pagemax ",$start,2);
	$html =~s/<!--LIST-->/$list/g;
	$html_list =~s/<!--LISTDSP-->//g;
print "D";

	if($list){
		&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/iphone/charge/$page.html",$html);
		&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/iphone/list/charge/$page.html",$html_list);
		$page++;
		&_charge_detaile($dbh,$page);
	}
	
	return;
}


sub _ranking_free(){

	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/iphone/ranking/};
	mkdir($dirname, 0755);
	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/iphone/list/ranking/};
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
	my $pager .= &_pager($page,"ranking-iphone-app");
	$html =~s/<!--PAGER-->/$pager/g;

	my $pagemax = 50;
	my $start = 0 + ($pagemax * ($page - 1));

	my $html_list = $html;
	my $list2 = &_make_list2($dbh, " where price = 0 order by eva desc,evacount desc limit $start, $pagemax ",$start);
	$html_list =~s/<!--LIST-->/$list2/g;
	my $listdsp=qq{リストモード};
	$html_list =~s/<!--LISTDSP-->/$listdsp/g;

	my $list = &_make_list($dbh, " where price = 0 order by eva desc,evacount desc limit $start, $pagemax ",$start);
	$html =~s/<!--LIST-->/$list/g;

	if($list){
		&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/iphone/ranking/$page.html",$html);
		&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/iphone/list/ranking/$page.html",$html_list);
		$page++;
		&_ranking_free_detaile($dbh,$page);
	}
	
	return;
}

sub _new_free(){
	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/iphone/new/};
	mkdir($dirname, 0755);
	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/iphone/list/new/};
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
	my $pager .= &_pager($page,"new-iphone-app");
	$html =~s/<!--PAGER-->/$pager/g;

	my $pagemax = 50;
	my $start = 0 + ($pagemax * ($page - 1));
	
	my $html_list = $html;
	my $list2 = &_make_list2($dbh, " where price = 0 order by releaseDate desc, eva desc  limit $start, $pagemax ",$start);
	$html_list =~s/<!--LIST-->/$list2/g;
	my $listdsp=qq{リストモード};
	$html_list =~s/<!--LISTDSP-->/$listdsp/g;

	my $list = &_make_list($dbh, " where price = 0 order by releaseDate desc, eva desc  limit $start, $pagemax ",$start);
	$html =~s/<!--LIST-->/$list/g;

	if($list){
		&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/iphone/new/$page.html",$html);
		&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/iphone/list/new/$page.html",$html_list);
		$page++;
		&_new_free_detaile($dbh,$page);
	}
	
	return;
}

sub _sale_free(){

	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/iphone/sale/};
	mkdir($dirname, 0755);
	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/iphone/list/sale/};
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

	my $pager .= &_pager($page,"sale-iphone-app");
	$html =~s/<!--PAGER-->/$pager/g;

	my $pagemax = 50;
	my $start = 0 + ($pagemax * ($page - 1));

	my $html_list = $html;
	my $list2 = &_make_list2($dbh, ",B.price,B.sale_price,B.datestr from  app_iphone as A, app_iphone_sale as B where A.id = B.app_id and delflag = 0 order by datestr desc limit $start, $pagemax ", $start,1,1);
	$html_list =~s/<!--LIST-->/$list2/g;
	my $listdsp=qq{リストモード};
	$html_list =~s/<!--LISTDSP-->/$listdsp/g;

	my $list = &_make_list($dbh, ",B.price,B.sale_price,B.datestr from  app_iphone as A, app_iphone_sale as B where A.id = B.app_id and delflag = 0 order by datestr desc limit $start, $pagemax ",$start,0,1);
	$html =~s/<!--LIST-->/$list/g;

#	if($list){
		&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/iphone/sale/$page.html",$html);
		&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/iphone/list/sale/$page.html",$html_list);
		$page++;
		&_sale_free_detaile($dbh,$page);
#	}
	
	return;
}

sub _top(){
	my $html = &_load_tmpl("new_index.html");

#	my $side_free = &_load_tmpl("side_free.html");
#	$html =~s/<!--SIDE_FREE-->/$side_free/g;
	$html = &_parts_set($html);

	my $dbh = &_db_connect();

	# ニューストピックス
	my $newstopics;
	my $datetime;
	my $sth = $dbh->prepare(qq{select id, title, now() from fmfm where type >=5 and type <=9 order by id desc limit 8 });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$datetime = $row[2];
		$newstopics.=qq{・<a href="/rd.htm?id=$row[0]" target="_blank" ref=nofollow>$row[1]</a> <img src="/img/E008_20.gif"><br />};
	}

	$html =~s/<!--DATETIME-->/$datetime/g;
	$html =~s/<!--NEWS-->/$newstopics/g;
	
	my $newslist;
	my $sth = $dbh->prepare(qq{select id,newsdate,title from app_news order by id desc limit 5 });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$newslist .= qq{$row[1] <a href="/iphone/newsid-$row[0]/">$row[2]</a><br />};
	}
	$html =~s/<!--NEWSLIST-->/$newslist/g;

	# 新着 無料セール中
	my $list = &_make_list($dbh, ",B.price,B.sale_price,B.datestr from  app_iphone as A, app_iphone_sale as B where A.id = B.app_id and delflag = 0 order by datestr desc limit 0, 30 ",0,0,1);
	$html =~s/<!--LIST-->/$list/g;
	my $pager .= &_pager(1,"sale-iphone-app");
	$html =~s/<!--PAGER_SALE-->/$pager/g;


	# 外部サイト
	my $site_list;
	my $sth = $dbh->prepare(qq{select name,logo,url,id from app_site where type = 0 });
	$sth->execute();
	my $cnt;
	while(my @row = $sth->fetchrow_array) {
		$cnt++;
		$site_list .= qq{<tr>} if($cnt eq 1);
		$site_list .= qq{<td width=25%>};
		$site_list .= qq{<a href="/applinks.htm?clickid=$row[3]" target="_blank" rel="nofollow" alt="$row[0]"><img src="/img/link/$row[1]" width=150></a>};
		$site_list .= qq{</td>};
		$site_list .= qq{</tr>} if($cnt eq 4);
		$cnt = 0 if($cnt eq 4);
	}
	if($cnt eq 1){
		$site_list .= qq{<td width=25%>};
		$site_list .= qq{</td>};
		$site_list .= qq{<td width=25%>};
		$site_list .= qq{</td>};
		$site_list .= qq{<td width=25%>};
		$site_list .= qq{</td>};
		$site_list .= qq{</tr>};
	}elsif($cnt eq 2){
		$site_list .= qq{<td width=25%>};
		$site_list .= qq{</td>};
		$site_list .= qq{<td width=25%>};
		$site_list .= qq{</td>};
		$site_list .= qq{</tr>};
	}elsif($cnt eq 3){
		$site_list .= qq{<td width=25%>};
		$site_list .= qq{</td>};
		$site_list .= qq{</tr>};
	}
	$html =~s/<!--APPLE_LINK-->/$site_list/g;
	
	my $site_list;
	my $sth = $dbh->prepare(qq{select name,logo,url,id from app_site where type = 1 });
	$sth->execute();
	my $cnt;
	while(my @row = $sth->fetchrow_array) {
		$cnt++;
		$site_list .= qq{<tr>} if($cnt eq 1);
		$site_list .= qq{<td width=25%>};
		$site_list .= qq{<a href="/applinks.htm?clickid=$row[3]" target="_blank" rel="nofollow" alt="$row[0]"><img src="/img/link/$row[1]"  width=150></a>};
		$site_list .= qq{</td>};
		$site_list .= qq{</tr>} if($cnt eq 4);
		$cnt = 0 if($cnt eq 4);
	}
	if($cnt eq 1){
		$site_list .= qq{<td width=25%>};
		$site_list .= qq{</td>};
		$site_list .= qq{<td width=25%>};
		$site_list .= qq{</td>};
		$site_list .= qq{<td width=25%>};
		$site_list .= qq{</td>};
		$site_list .= qq{</tr>};
	}elsif($cnt eq 2){
		$site_list .= qq{<td width=25%>};
		$site_list .= qq{</td>};
		$site_list .= qq{<td width=25%>};
		$site_list .= qq{</td>};
		$site_list .= qq{</tr>};
	}elsif($cnt eq 3){
		$site_list .= qq{<td width=25%>};
		$site_list .= qq{</td>};
		$site_list .= qq{</tr>};
	}
	$html =~s/<!--ANDROID_LINK-->/$site_list/g;


	&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/index.html",$html);

	$dbh->disconnect;

	return;
}


sub _top2(){
	my $html = &_load_tmpl("new_index2.html");

	$html = &_parts_set($html);

	my $dbh = &_db_connect();

	# 300件 スモール
	my $url = qq{https://itunes.apple.com/jp/rss/topfreeapplications/limit=300/xml};
	my $list = &_get_rss2($dbh,$url,"topfreeapplications");
	$html =~s/<!--TOP300LIST-->/$list/g;
	my $a = qq{my.css};
	my $b = qq{smartphone.css};
	$html =~s/$a/$b/g;

	# ニューストピックス
	my $newstopics;
	my $datetime;
	my $sth = $dbh->prepare(qq{select id, title, now() from fmfm where type >=5 and type <=9 order by id desc limit 8 });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$datetime = $row[2];
		$newstopics.=qq{・<a href="/rd.htm?id=$row[0]" target="_blank" ref=nofollow>$row[1]</a> <img src="/img/E008_20.gif"><br />};
	}

	$html =~s/<!--DATETIME-->/$datetime/g;
	$html =~s/<!--NEWS-->/$newstopics/g;
	
	my $newslist;
	my $sth = $dbh->prepare(qq{select id,newsdate,title from app_news order by id desc limit 5 });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$newslist .= qq{$row[1] <a href="/iphone/newsid-$row[0]/">$row[2]</a><br />};
	}
	$html =~s/<!--NEWSLIST-->/$newslist/g;

	# 外部サイト
	my $site_list;
	my $sth = $dbh->prepare(qq{select name,logo,url,id from app_site where type = 0 });
	$sth->execute();
	my $cnt;
	while(my @row = $sth->fetchrow_array) {
		$cnt++;
		$site_list .= qq{<tr>} if($cnt eq 1);
		$site_list .= qq{<td width=25%>};
		$site_list .= qq{<a href="/applinks.htm?clickid=$row[3]" target="_blank" rel="nofollow" alt="$row[0]"><img src="/img/link/$row[1]" width=150></a>};
		$site_list .= qq{</td>};
		$site_list .= qq{</tr>} if($cnt eq 4);
		$cnt = 0 if($cnt eq 4);
	}
	if($cnt eq 1){
		$site_list .= qq{<td width=25%>};
		$site_list .= qq{</td>};
		$site_list .= qq{<td width=25%>};
		$site_list .= qq{</td>};
		$site_list .= qq{<td width=25%>};
		$site_list .= qq{</td>};
		$site_list .= qq{</tr>};
	}elsif($cnt eq 2){
		$site_list .= qq{<td width=25%>};
		$site_list .= qq{</td>};
		$site_list .= qq{<td width=25%>};
		$site_list .= qq{</td>};
		$site_list .= qq{</tr>};
	}elsif($cnt eq 3){
		$site_list .= qq{<td width=25%>};
		$site_list .= qq{</td>};
		$site_list .= qq{</tr>};
	}
	$html =~s/<!--APPLE_LINK-->/$site_list/g;
	
	my $site_list;
	my $sth = $dbh->prepare(qq{select name,logo,url,id from app_site where type = 1 });
	$sth->execute();
	my $cnt;
	while(my @row = $sth->fetchrow_array) {
		$cnt++;
		$site_list .= qq{<tr>} if($cnt eq 1);
		$site_list .= qq{<td width=25%>};
		$site_list .= qq{<a href="/applinks.htm?clickid=$row[3]" target="_blank" rel="nofollow" alt="$row[0]"><img src="/img/link/$row[1]"  width=150></a>};
		$site_list .= qq{</td>};
		$site_list .= qq{</tr>} if($cnt eq 4);
		$cnt = 0 if($cnt eq 4);
	}
	if($cnt eq 1){
		$site_list .= qq{<td width=25%>};
		$site_list .= qq{</td>};
		$site_list .= qq{<td width=25%>};
		$site_list .= qq{</td>};
		$site_list .= qq{<td width=25%>};
		$site_list .= qq{</td>};
		$site_list .= qq{</tr>};
	}elsif($cnt eq 2){
		$site_list .= qq{<td width=25%>};
		$site_list .= qq{</td>};
		$site_list .= qq{<td width=25%>};
		$site_list .= qq{</td>};
		$site_list .= qq{</tr>};
	}elsif($cnt eq 3){
		$site_list .= qq{<td width=25%>};
		$site_list .= qq{</td>};
		$site_list .= qq{</tr>};
	}
	$html =~s/<!--ANDROID_LINK-->/$site_list/g;

	&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/index.html",$html);

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
		$sth = $dbh->prepare(qq{select name, url, img100, eva, evacount,formattedPrice,id,genres,genre_id $where }) ;
	}else{
		$sth = $dbh->prepare(qq{select name, url, img100, eva, evacount,formattedPrice,id,genres,genre_id from app_iphone $where });
	}
	$sth->execute();
	$startno = 0 unless($startno);
	my $no = $startno;
	while(my @row = $sth->fetchrow_array) {
		$no++;
		my $img200 = $row[2];
		$img200=~s/\.jpg/\.200x200-75\.jpg/ig;
		$img200=~s/\.png/\.200x200-75\.png/ig;
		my $eva = $row[3];
		$eva=0 unless($eva);
		my $star_str = &_star_img($eva);
		my $price_str = &_price_str($row[5]);
		my $genrestr = substr($row[7],0,30);
		$row[4] = 0 unless($row[4]);
		
		$genrestr.=qq{...};
		$list.=qq{<div>};
		$list.=qq{<span class="rounded-img" style="background: url($img200) no-repeat center center; width: 200px; height: 200px;"><a href="/iphoneapp-$row[6]/"><img src="$img200" style="opacity: 0;" alt="$row[0]" /></a></span>};
		$list.=qq{<p><img src="/img/E20D_20.gif" width="15">$row[0]</p>};
		$list.=qq{<a href="/category$row[8]-iphone-app-1/">$genrestr</a><br />};
		$list.=qq{$star_str ($row[4])<br />};
		if($sale_flag){
			if($row[10] > 0 ){
				$list.=qq{￥$row[9] → ￥$row[10]<br />};
			}else{
				$list.=qq{￥$row[9] → <img src="/img/Free.gif" height=15> 無料<br />};
			}
		}else{
			$list.=qq{$price_str<br />};
		}
		$list.= &_af_link($row[6],$row[1]);

		$list.=qq{</div>};

#		$list.=qq{<form action="$row[1]">};
#		$list.=qq{<button class="btn primary" type="submit">アプリをインストール</button>};
#		$list.=qq{</form>};
#		$list.=qq{</div>};
	}
print "$where: $no\n";
	if($list){
		$list = qq{<div id="grid-content">}.$list.qq{</div>};
	}
	
	return $list;
}

sub _make_list2(){
	my $dbh = shift;
	my $where = shift;
	my $startno = shift;
	my $type_free = shift;
	my $sale_flag = shift;

	my $list;
print " $where _make_list2 \n";	
	my $sth;
	if($sale_flag){
		$sth = $dbh->prepare(qq{select name, url, img100, eva, evacount,formattedPrice,id,genres,genre_id,description $where }) if($sale_flag);
	}else{
		$sth = $dbh->prepare(qq{select name, url, img100, eva, evacount,formattedPrice,id,genres,genre_id,description from app_iphone $where });
	}
	$sth->execute();
	$startno = 0 unless($startno);
	my $no = $startno;
	while(my @row = $sth->fetchrow_array) {

	my $shotimgs;
	my $sth2 = $dbh->prepare(qq{select type,img1,img2,img3,img4,img5 from app_iphone_img where app_id = ? limit 1});
	$sth2->execute($row[6]);
	while(my @row2 = $sth2->fetchrow_array) {
		my ($type,$img1,$img2,$img3,$img4,$img5) = @row2;
		$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img1" alt="$row[0]" /><img src="$img1" alt="$row[0]" class="preview" /></a></li>} if($img1);
		$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img2" alt="$row[0]" /><img src="$img2" alt="$row[0]" class="preview" /></a></li>} if($img2);
		$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img3" alt="$row[0]" /><img src="$img3" alt="$row[0]" class="preview" /></a></li>} if($img3);
		$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img4" alt="$row[0]" /><img src="$img4" alt="$row[0]" class="preview" /></a></li>} if($img4);
		$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img5" alt="$row[0]" /><img src="$img5" alt="$row[0]" class="preview" /></a></li>} if($img5);
	}

		my $img200 = $row[2];
		$img200=~s/\.jpg/\.200x200-75\.jpg/ig;
		$img200=~s/\.png/\.200x200-75\.png/ig;
		my $eva = $row[3];
		$eva=0 unless($eva);
		my $star_str = &_star_img($eva);
		my $price_str = &_price_str($row[5]);
		my $genrestr = substr($row[7],0,30);
		$genrestr.=qq{...};
		my $ex_str = substr($row[9],0,400);
		$ex_str.=qq{...};
		$row[4] = 0 unless($row[4]);

		$list .= qq{<tr>};
		$list .= qq{<td width="200" bgcolor="#000000">};
		$list .= qq{<font color="#FFFFFF">};
		$list .= qq{<span class="rounded-img" style="background: url($img200) no-repeat center center; width: 200px; height: 200px;"><a href="/iphoneapp-$row[6]/" target="_blank" rel="nofollow"><img src="$img200" style="opacity: 0;" alt="$row[0]" /></a></span>};
		$list .= qq{<br />};
		$list .=qq{<p><img src="/img/E20D_20.gif" width="15">$row[0]</p>};
		$list .=qq{<a href="/category$row[8]-iphone-app-1/">$genrestr</a><br />};
		if($sale_flag){
			if($row[11] > 0 ){
				$list .= qq{<p>￥$row[10] → ￥$row[11]<br />};
			}else{
				$list .= qq{<p>￥$row[10] → <img src="/img/Free.gif" height=15> 無料<br />};
			}


		}else{
			$list .= qq{<p>	$star_str ($row[4])<br />$price_str<br />};
		}
		$list.= &_af_link($row[6],$row[1]);
#		$list .= qq{<form action="$row[1]"><button class="btn primary" type="submit">アプリをインストール</button></form>};

		$list .= qq{</font>};
		$list .= qq{</p>};
		$list .= qq{</td>};
		$list .= qq{<td>};
		$list .= qq{$ex_str<br /><br />};
		$list .= qq{<ul class="hoverbox">};
		$list .= qq{$shotimgs};
		$list .= qq{</ul>};
		$list .= qq{</td>};
		$list .= qq{</tr>};


	}
print "$where: $no\n";
	if($list){
		$list = qq{<table><tbody>}.$list.qq{</tbody></table>};
	}
	
	return $list;
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

	$html =~s/<!--LISTDSP-->//g;
print "$filename";
	open(OUT,"> $filename") || die('error');
	print OUT "$html";
	close(OUT);

	return;
}


sub _load_tmpl(){
	my $tmpl = shift;
	
my $file = qq{/var/www/vhosts/goo.to/etc/makehtml/app/tmpl/$tmpl};
#print "$file\n";
my $fh;
my $filedata;
open( $fh, "<", $file );
while( my $line = readline $fh ){ 
	$filedata .= $line;
}
close ( $fh );
	$filedata = &_date_set($filedata);
	$filedata = &_tab_set($filedata,$tmpl);

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
	$tabs .= qq{<li$activ_sale><a href="$dir_str/sale-iphone-app-1/">セールアプリ</a></li>\n};
	$tabs .= qq{<li$activ_app><a href="$dir_str/app-1/">アプリまとめ</a></li>\n};
	$tabs .= qq{<li$activ_ranking><a href="$dir_str/ranking-iphone-app-1/">無料アプリランキング</a></li>\n};
	$tabs .= qq{<li$activ_new><a href="$dir_str/new-iphone-app-1/">新着無料アプリ</a></li>\n};
	$tabs .= qq{<li$activ_charge><a href="$dir_str/charge-iphone-app-1/">新着有料アプリ</a></li>\n};
	$tabs .= qq{<li$activ_category><a href="$dir_str/category-iphone-app/">カテゴリ別</a></li>\n};
	$tabs .= qq{<li$activ_category><a href="$dir_str/itunes/">アップル公式</a></li>\n};
	$tabs .= qq{<li$activ_news><a href="$dir_str/news/">ニュース</a></li>\n};
	$tabs .= qq{</ul>\n};
	$tabs .= qq{</div>\n};

	$html =~s/<!--TABS-->/$tabs/gi;
	return $html;
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
	
	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/iphone/$dir/};
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

		if($img100=~/-75/){
			$img100=~s/175/200/ig;
		}else{
			$img100=~s/\.jpg/\.200x200-75\.jpg/ig;
			$img100=~s/\.png/\.200x200-75\.png/ig;
		}
		$eva=0 unless($eva);
		$evacount=0 unless($evacount);
		my $star_str = &_star_img($eva);
		my $price_str = &_price_str($formattedPrice);
		my $genrestr = substr($genres,0,30);
		$genrestr.=qq{...};

		$list.=qq{<div>};
		$list.=qq{<span class="rounded-img" style="background: url($img100) no-repeat center center; width: 200px; height: 200px;"><a href="/iphoneapp-$id/"><img src="$img100" style="opacity: 0;" alt="$name" /></a></span>};
		$list.=qq{<p><img src="/img/E20D_20.gif" width="15">$name</p>};
		$list.=qq{<a href="/category$genre_id}.qq{-iphone-app-1/">$genrestr</a><br />};
		$list.=qq{$star_str ($eva)<br />};
		$list.=qq{$price_str<br />};

		$list.= &_af_link($id,$url);

		$list.=qq{</div>};
		

	}

	if($list){
		$list = qq{<div id="grid-content">}.$list.qq{</div>};
	}

	my $html = &_load_tmpl("new_apprank.html");
	$html =~s/<!--LIST-->/$list/g;

	my $titlestr = &_get_name($genre);
	$html =~s/<!--TITLESTR-->/$titlestr/g;
	my $ranktab = &_rank_tab_set($genre);
	$html =~s/<!--RANK_TABS-->/$ranktab/g;

	my $caterank;
	my $caterankstr.=qq{<form><select onChange="location.href=value;">};
	$caterankstr.=qq{<option value="#">選択</option>};
	my $sth = $dbh->prepare(qq{SELECT id,name FROM app_category where id >= 6000 order by id });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$caterank .= qq{<a href="/iphone/apprank/$genre/$row[0]/">$row[1]</a> };
		$caterankstr.=qq{<option value="/iphone/apprank/$genre/$row[0]/">$row[1]</option>};
	}
	$caterankstr.=qq{</select></form>};
	
	$html =~s/<!--CATERANKLISTSTR-->/$caterankstr/g;
	$html =~s/<!--CATERANKLIST-->/$caterank/g;


	$html = &_parts_set($html);

	my $dir_str = qq{$genre};

	if($category){
		$dir_str = qq{$genre/$category};
	}
	$html =~s/<!--DIRSTR-->/$dir_str/g;

	&_move_file($dir_str);

	# 履歴
	my $backstr;
	my $back.=qq{<form><select onChange="location.href=value;">};
	$back.=qq{<option value="#">選択</option>};
	for (my $i=1; $i<=30; $i++){
		$backstr .= qq{<a href="/iphone/apprank/$dir_str/index$i.html">$i日前</a> };
		$back.=qq{<option value="/iphone/apprank/$dir_str/index$i.html">$i日前</option>};
	}
	$back.=qq{</select></form>};
	$html =~s/<!--BACKLIST-->/$backstr/g;
	$html =~s/<!--BACKLISTSTR-->/$back/g;

	&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/iphone/apprank/$dir_str/index.html",$html);


	return;
}

sub _get_rss2(){
	my $dbh = shift;
	my $url = shift;
	my $genre = shift;

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
			$name = $data->{trackName};
			$url = $data->{trackViewUrl};
			$img100 = $data->{artworkUrl100};
			$eva = $data->{averageUserRating};
			$evacount = $data->{userRatingCount};
			$formattedPrice = $data->{price};
			$id = $app_id;
			$genres = $data->{genres1}; 
			$genre_id =$data->{genreIds1};

		}
		if($img100=~/-75/){
			$img100=~s/175/100/ig;
		}else{
			$img100=~s/\.jpg/\.100x100-75\.jpg/ig;
			$img100=~s/\.png/\.100x100-75\.png/ig;
		}
		$eva=0 unless($eva);
		$evacount=0 unless($evacount);
		my $star_str = &_star_img($eva);
		my $price_str = &_price_str($formattedPrice);
		my $genrestr = substr($genres,0,30);
		$genrestr.=qq{...};

		$list.=qq{<div>\n};
		$list.=qq{<a href="/iphoneapp-$id/">\n};
		$list.=qq{<p class=price>\n};
#		$list.=qq{$price_str\n};
		$list.=qq{<span class="rounded-img" style="background: url($img100) no-repeat center center; width: 86px; height: 86px;">\n};
		$list.=qq{<img src="$img100" style="opacity: 0;" alt="$name" /></span>\n};
		$list.=qq{</p>\n};
		$list.=qq{<h3 class="textOverflow">$name</h3>};
		$list.=qq{$star_str};
		$list.=qq{<p class="textOverflow category">$genrestr</p>};
		$list.=qq{</a>\n};
		$list.=qq{</div>\n};

	}

	if($list){
		$list = qq{<div id="grid-content">}.$list.qq{</div>};
	}

	return $list;
}

sub _get_rss300(){
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

		if($img100=~/-75/){
			$img100=~s/175/100/ig;
		}else{
			$img100=~s/\.jpg/\.100x100-75\.jpg/ig;
			$img100=~s/\.png/\.100x100-75\.png/ig;
		}
		$eva=0 unless($eva);
		$evacount=0 unless($evacount);
		my $star_str = &_star_img($eva);
		my $price_str = &_price_str($formattedPrice);
		my $genrestr = substr($genres,0,30);
		$genrestr.=qq{...};

		$list.=qq{<div>\n};
		$list.=qq{<a href="/iphoneapp-$id/">\n};
		$list.=qq{<p class=price>\n};
		$list.=qq{$price_str\n} if($formattedPrice);
		$list.=qq{<span class="rounded-img" style="background: url($img100) no-repeat center center; width: 86px; height: 86px;">\n};
		$list.=qq{<img src="$img100" style="opacity: 0;" alt="$name" /></span>\n};
		$list.=qq{</p>\n};
		$list.=qq{<h3 class="textOverflow">$name</h3>};
		$list.=qq{$star_str};
		$list.=qq{<p class="textOverflow category">$genrestr</p>};
		$list.=qq{</a>\n};
		$list.=qq{</div>\n};
	}

	if($list){
		$list = qq{<div id="grid-content">}.$list.qq{</div>};
	}

	my $html = &_load_tmpl("new_apprank300.html");
	$html =~s/<!--LIST-->/$list/g;

	my $titlestr = &_get_name($genre);
	$html =~s/<!--TITLESTR-->/$titlestr/g;
	my $ranktab = &_rank_tab_set($genre);
	$html =~s/<!--RANK_TABS-->/$ranktab/g;

	my $caterank;
	my $caterankstr.=qq{<form><select onChange="location.href=value;">};
	$caterankstr.=qq{<option value="#">選択</option>};
	my $sth = $dbh->prepare(qq{SELECT id,name FROM app_category where id >= 6000 order by id });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$caterank .= qq{<a href="/iphone/apprank300/$genre/$row[0]/">$row[1]</a> };
		$caterankstr.=qq{<option value="/iphone/apprank300/$genre/$row[0]/">$row[1]</option>};
	}
	$caterankstr.=qq{</select></form>};
	
	$html =~s/<!--CATERANKLISTSTR-->/$caterankstr/g;
	$html =~s/<!--CATERANKLIST-->/$caterank/g;


	$html = &_parts_set($html);

	my $dir_str = qq{$genre};

	if($category){
		$dir_str = qq{$genre/$category};
	}
	
	$html =~s/<!--DIRSTR-->/$dir_str/g;
	&_move_file300($dir_str);

	# 履歴
	my $backstr;
	my $back.=qq{<form><select onChange="location.href=value;">};
	$back.=qq{<option value="#">選択</option>};
	for (my $i=1; $i<=30; $i++){
		$backstr .= qq{<a href="/iphone/apprank300/$dir_str/index$i.html">$i日前</a> };
		$back.=qq{<option value="/iphone/apprank300/$dir_str/index$i.html">$i日前</option>};
	}
	$back.=qq{</select></form>};
	$html =~s/<!--BACKLIST-->/$backstr/g;
	$html =~s/<!--BACKLISTSTR-->/$back/g;

	my $a = qq{my.css};
	my $b = qq{smartphone.css};
	$html =~s/$a/$b/g;

	&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/iphone/apprank300/$dir_str/index.html",$html);


	return;
}

sub _get_rsslist(){
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
		my ($name, $url, $img100, $eva, $evacount, $formattedPrice, $id, $genres, $genre_id,$description);
		my $sth = $dbh->prepare(qq{SELECT name, url, img100, eva, evacount,formattedPrice,id,genres,genre_id,description FROM app_iphone where id = ? limit 1 });
		$sth->execute($app_id);
		while(my @row = $sth->fetchrow_array) {
			$check_flag = 1;
			($name, $url, $img100, $eva, $evacount, $formattedPrice, $id, $genres, $genre_id,$description) = @row;
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

		if($img100=~/-75/){
			$img100=~s/175/200/ig;
		}else{
			$img100=~s/\.jpg/\.200x200-75\.jpg/ig;
			$img100=~s/\.png/\.200x200-75\.png/ig;
		}
		$eva=0 unless($eva);
		$evacount=0 unless($evacount);
		my $star_str = &_star_img($eva);
		my $price_str = &_price_str($formattedPrice);
		my $genrestr = substr($genres,0,30);
		$genrestr.=qq{...};

	my $shotimgs;
	my $sth2 = $dbh->prepare(qq{select type,img1,img2,img3,img4,img5 from app_iphone_img where app_id = ? limit 1});
	$sth2->execute($app_id);
	while(my @row2 = $sth2->fetchrow_array) {
		my ($type,$img1,$img2,$img3,$img4,$img5) = @row2;
		$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img1" alt="$name" /><img src="$img1" alt="$name" class="preview" /></a></li>} if($img1);
		$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img2" alt="$name" /><img src="$img2" alt="$name" class="preview" /></a></li>} if($img2);
		$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img3" alt="$name" /><img src="$img3" alt="$name" class="preview" /></a></li>} if($img3);
		$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img4" alt="$name" /><img src="$img4" alt="$name" class="preview" /></a></li>} if($img4);
		$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img5" alt="$name" /><img src="$img5" alt="$name" class="preview" /></a></li>} if($img5);
	}

		my $ex_str = substr($description,0,1000);
		$ex_str.=qq{...};

		$list .= qq{<tr>};
		$list .= qq{<td width="200" bgcolor="#000000">};
		$list .= qq{<font color="#FFFFFF">};
		$list .= qq{<span class="rounded-img" style="background: url($img100) no-repeat center center; width: 200px; height: 200px;"><a href="/iphoneapp-$app_id/" target="_blank" rel="nofollow"><img src="$img100" style="opacity: 0;" alt="$name" /></a></span>};
		$list .= qq{<br />};
		$list .=qq{<p><img src="/img/E20D_20.gif" width="15">$name</p>};
		$list .=qq{<a href="/category$genre_id-iphone-app-1/">$genrestr</a><br />};
		$list .= qq{<p>	$star_str ($evacount)<br />$price_str<br />};
		$list.= &_af_link($id,$url);
#		$list .= qq{<form action="$row[1]"><button class="btn primary" type="submit">アプリをインストール</button></form>};

		$list .= qq{</font>};
		$list .= qq{</p>};
		$list .= qq{</td>};
		$list .= qq{<td>};
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

	my $html = &_load_tmpl("new_appranklist.html");
	$html =~s/<!--LIST-->/$list/g;

	my $titlestr = &_get_name($genre);
	$html =~s/<!--TITLESTR-->/$titlestr/g;
	my $ranktab = &_rank_tab_set($genre);
	$html =~s/<!--RANK_TABS-->/$ranktab/g;

	my $caterank;
	my $caterankstr.=qq{<form><select onChange="location.href=value;">};
	$caterankstr.=qq{<option value="#">選択</option>};
	my $sth = $dbh->prepare(qq{SELECT id,name FROM app_category where id >= 6000 order by id });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$caterank .= qq{<a href="/iphone/appranklist/$genre/$row[0]/">$row[1]</a> };
		$caterankstr.=qq{<option value="/iphone/appranklist/$genre/$row[0]/">$row[1]</option>};
	}
	$caterankstr.=qq{</select></form>};
	
	$html =~s/<!--CATERANKLISTSTR-->/$caterankstr/g;
	$html =~s/<!--CATERANKLIST-->/$caterank/g;


	$html = &_parts_set($html);

	my $dir_str = qq{$genre};

	if($category){
		$dir_str = qq{$genre/$category};
	}
	$html =~s/<!--DIRSTR-->/$dir_str/g;
	&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/iphone/appranklist/$dir_str/index.html",$html);


	return;
}


sub _move_file(){
	my $dir = shift;
	
	for (my $i=30; $i>=0; $i--){
		if($i eq 30){
		}else{
			my $next = $i + 1;
			$i = undef if($i eq 0);
			my $cmd = qq{mv /var/www/vhosts/goo.to/httpdocs-applease/iphone/apprank/$dir/index$i.html /var/www/vhosts/goo.to/httpdocs-applease/iphone/apprank/$dir/index$next.html};
eval{
			`$cmd`;
};
		}
	}

	return;
}

sub _move_file300(){
	my $dir = shift;
	
	for (my $i=30; $i>=0; $i--){
		if($i eq 30){
		}else{
			my $next = $i + 1;
			$i = undef if($i eq 0);
			my $cmd = qq{mv /var/www/vhosts/goo.to/httpdocs-applease/iphone/apprank300/$dir/index$i.html /var/www/vhosts/goo.to/httpdocs-applease/iphone/apprank300/$dir/index$next.html};
eval{
			`$cmd`;
};
		}
	}

	return;
}

sub _rank_tab_set(){
	my $genre = shift;
	my $tabs;


	my $activ_1;
	$activ_1 = qq{ class="active"} if($genre eq "topfreeapplications");
	my $activ_2;
	$activ_2 = qq{ class="active"} if($genre eq "toppaidapplications");
	my $activ_3;
	$activ_3 = qq{ class="active"} if($genre eq "topgrossingapplications");
	my $activ_4;
	$activ_4 = qq{ class="active"} if($genre eq "topfreeipadapplications");
	my $activ_5;
	$activ_5 = qq{ class="active"} if($genre eq "toppaidipadapplications");
	my $activ_6;
	$activ_6 = qq{ class="active"} if($genre eq "newfreeapplications");
	my $activ_7;
	$activ_7 = qq{ class="active"} if($genre eq "newpaidapplications");

	$tabs .= qq{<div class="container-fluid">\n};
	$tabs .= qq{<ul class="tabs">\n};
	$tabs .= qq{<li$activ_1><a href="/iphone/apprank300/topfreeapplications/">無料アプリ</a></li>\n};
	$tabs .= qq{<li$activ_2><a href="/iphone/apprank300/toppaidapplications/">有料アプリ</a></li>\n};
	$tabs .= qq{<li$activ_3><a href="/iphone/apprank300/topgrossingapplications/">トップセールス</a></li>\n};
	$tabs .= qq{<li$activ_6><a href="/iphone/apprank300/newfreeapplications/">新着無料アプリ</a></li>\n};
	$tabs .= qq{<li$activ_7><a href="/iphone/apprank300/newpaidapplications/">新着有料アプリ</a></li>\n};
	$tabs .= qq{<li$activ_4><a href="/iphone/apprank300/topfreeipadapplications/">無料ipadアプリ</a></li>\n};
	$tabs .= qq{<li$activ_5><a href="/iphone/apprank300/toppaidipadapplications/">有料ipadアプリ</a></li>\n};
	$tabs .= qq{</ul>\n};
	$tabs .= qq{</div>\n};

	return $tabs;
}
