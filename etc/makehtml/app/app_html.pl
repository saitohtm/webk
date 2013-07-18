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

# ２重起動防止
if ($$ != `/usr/bin/pgrep -fo $0`) {
print "exit \n";
    exit 1;
}
print "start \n";

# category_slide_list作成
&_cate_slide_list();

# header作成
&_header_make();

# そのた
&_else_pages();

# top
&_top();

my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/charge/};
mkdir($dirname, 0755);
# charge page
&_charge();

my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/sale/};
mkdir($dirname, 0755);
# sale page
&_sale_free();

my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/new/};
mkdir($dirname, 0755);
# new page
&_new_free();

my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/ranking/};
mkdir($dirname, 0755);
# ranking page
&_ranking_free();

# category page
&_category_free();

exit;

sub _else_pages(){

	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/applease/};
	mkdir($dirname, 0755);
	my $html = &_load_tmpl("applease.html");
	$html = &_parts_set($html);
	&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/applease/index.html",$html);

	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/privacy/};
	mkdir($dirname, 0755);
	my $html = &_load_tmpl("privacy.html");
	$html = &_parts_set($html);
	&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/privacy/index.html",$html);

	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/manage/};
	mkdir($dirname, 0755);
	my $html = &_load_tmpl("manage.html");
	$html = &_parts_set($html);
	&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/manage/index.html",$html);

	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/legal/};
	mkdir($dirname, 0755);
	my $html = &_load_tmpl("legal.html");
	$html = &_parts_set($html);
	&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/legal/index.html",$html);

	return;
}

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


	&_file_output("/var/www/vhosts/goo.to/etc/makehtml/app/tmpl/header.html",$html);
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
		my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/category$row[0]/};
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
	
	return if($page >= 3000);

	my $html = &_load_tmpl("category.html");
	$html =~s/<!--PAGE-->/$page/g;
	$html =~s/<!--CNAME-->/$category_name/g;
	$html = &_parts_set($html);

	my $pagemax = 50;
	my $start =  1 + ($pagemax * ($page - 1));
	my $list = &_make_list($dbh, " where category = $category_id and price = 0 and lang_flag = 1 group by appname order by eva desc,review desc limit $start, $pagemax ");
	$html =~s/<!--LIST-->/$list/g;
	my $pager .= &_pager($page,"category$category_id");
	$html =~s/<!--PAGER-->/$pager/g;

	if($list){
		&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/category$category_id/$page.html",$html);
		$page++;
		&_category_free_detaile($dbh,$page,$category_id,$category_name);
	}
	
	return;
}

sub _charge(){

	my $dbh = &_db_connect();
	# 共通パーツ
	&_charge_detaile($dbh,1);
	$dbh->disconnect;

	return;
}

sub _charge_detaile(){
	my $dbh = shift;
	my $page = shift;
	
	return if($page >= 3000);

	my $html = &_load_tmpl("charge.html");
	$html =~s/<!--PAGE-->/$page/g;
	$html = &_parts_set($html);

	my $pagemax = 50;
	my $start =  1 + ($pagemax * ($page - 1));
	my $list = &_make_list($dbh, " where price > 0 and lang_flag = 1 group by appname order by eva desc,review desc limit $start, $pagemax ",2);
	$html =~s/<!--LIST-->/$list/g;
	my $pager .= &_pager($page,"charge");
	$html =~s/<!--PAGER-->/$pager/g;

	if($list){
		&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/charge/$page.html",$html);
		$page++;
		&_charge_detaile($dbh,$page);
	}
	
	return;
}


sub _ranking_free(){

	my $dbh = &_db_connect();
	# 共通パーツ
	&_ranking_free_detaile($dbh,1);
	$dbh->disconnect;

	return;
}

sub _ranking_free_detaile(){
	my $dbh = shift;
	my $page = shift;
	
	return if($page >= 3000);

	my $html = &_load_tmpl("ranking.html");
	$html =~s/<!--PAGE-->/$page/g;
	$html = &_parts_set($html);

	my $pagemax = 50;
	my $start =  1 + ($pagemax * ($page - 1));
	my $list = &_make_list($dbh, " where price = 0 and lang_flag = 1 group by appname order by eva desc,review desc limit $start, $pagemax ");
	$html =~s/<!--LIST-->/$list/g;
	my $pager .= &_pager($page,"ranking");
	$html =~s/<!--PAGER-->/$pager/g;

	if($list){
		&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/ranking/$page.html",$html);
		$page++;
		&_ranking_free_detaile($dbh,$page);
	}
	
	return;
}

sub _new_free(){

	my $dbh = &_db_connect();
	# 共通パーツ
	&_new_free_detaile($dbh,1);
	$dbh->disconnect;

	return;
}

sub _new_free_detaile(){
	my $dbh = shift;
	my $page = shift;
	
	return if($page >= 300);

	my $html = &_load_tmpl("new.html");
	$html =~s/<!--PAGE-->/$page/g;
	$html = &_parts_set($html);

	my $pagemax = 50;
	my $start =  1 + ($pagemax * ($page - 1));
	my $list = &_make_list($dbh, " where price = 0 and lang_flag = 1 group by appname order by rdate desc, eva desc  limit $start, $pagemax ");
	$html =~s/<!--LIST-->/$list/g;
	my $pager .= &_pager($page,"new");
	$html =~s/<!--PAGER-->/$pager/g;

	if($list){
		&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/new/$page.html",$html);
		$page++;
		&_new_free_detaile($dbh,$page);
	}
	
	return;
}

sub _sale_free(){

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
	
	my $html = &_load_tmpl("sale.html");
	$html =~s/<!--PAGE-->/$page/g;
	$html = &_parts_set($html);

	my $pagemax = 50;
	my $start =  1 + ($pagemax * ($page - 1));
	my $list = &_make_list($dbh, " where sale_flag = 1 and lang_flag = 1 group by appname order by sale desc, saledate desc, review desc, eva desc  limit $start, $pagemax ", 1);
	$html =~s/<!--LIST-->/$list/g;
	my $pager .= &_pager($page,"sale");
	$html =~s/<!--PAGER-->/$pager/g;

	if($list){
		&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/sale/$page.html",$html);
		$page++;
		&_sale_free_detaile($dbh,$page);
	}
	
	return;
}

sub _top(){
	my $html = &_load_tmpl("index.html");

	my $side_free = &_load_tmpl("side_free.html");
	$html =~s/<!--SIDE_FREE-->/$side_free/g;
	$html = &_parts_set($html);

	my $dbh = &_db_connect();
	
	# 無料アプリ＋セール無料アプリの件数
	my $sth = $dbh->prepare(qq{select count(*) from app where lang_flag=1 and price = 0 });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my $count =	&price_dsp($row[0]);
		$count = qq{<font color="#FF0000">$count</font>};
		$html =~s/<!--TOTAL-->/$count/g;
	}
	
	# 新着 無料セール中
	my $list;
	$list = &_make_list($dbh, " where sale_flag = 1 and lang_flag = 1 group by appname order by sale desc, updated desc limit 10 ", 1);
	$html =~s/<!--LIST_SALE-->/$list/g;
	my $pager .= &_pager(1,"sale");
	$html =~s/<!--PAGER_SALE-->/$pager/g;

	# 新着 10件
	$list = &_make_list($dbh, " where price = 0 and lang_flag = 1 group by appname order by rdate desc limit 10 ");
	$html =~s/<!--LIST_NEW-->/$list/g;
	my $pager .= &_pager(1,"new");
	$html =~s/<!--PAGER_NEW-->/$pager/g;

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
	my $type_free = shift;

	my $list;
print " $where _make_list \n";	
	my $sth = $dbh->prepare(qq{select id, img, dl_url, appname, ex_str, device, category, developer, price, sale, rdate, eva, review, rank, saledate from app $where });
	$sth->execute();
	my $no = 0;
	while(my @row = $sth->fetchrow_array) {
		$no++;
		if($type_free){
			next if($row[9] != 0);
		}
		$list .= qq{<tr>\n};
		$list .= qq{<td><b>$no</b></td>\n};
		$list .= qq{<td width=10%><span class="rounded-img" style="background: url($row[1]) no-repeat center center; width: 100px; height: 100px;"><a href="/app-$row[0]/" target="_blank"><img src="$row[1]" style="opacity: 0;" alt="無料アプリ $row[2]" /></span></td>\n};
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

#		my $facebook = qq{<div class="fb-like" data-href="http://applease.info/app-$row[0]/" data-send="false" data-layout="button_count" data-width="50" data-show-faces="false" data-action="recommend" data-font="lucida grande"></div>};
#		my $twitter = qq{<a href="https://twitter.com/share" class="twitter-share-button" data-url="http://applease.info/app-$row[0]/" data-text="イイ！アプリ:$row[3]" data-count="none" data-lang="ja">ツイート</a><script type="text/javascript" src="//platform.twitter.com/widgets.js"></script>};

		my $facebook = qq{<a href="/app-$row[0]/" target="_blank"><img src="/img/facebook_like.png" width="80"></a>};

		$list .= qq{<td width=20%><a href="/app-$row[0]/">$row[3]</a><br />$star_str（$review）<br />$price_str<br />$row[10]</td>\n};
		$list .= qq{<td><div class="well">$row[4]</div></td>\n};
		$list .= qq{<td>$facebook</td>\n};
		$list .= qq{</tr>\n};
	}
print "$where: $no\n";

	
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

	return $html;
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
	
my $file = qq{/var/www/vhosts/goo.to/etc/makehtml/app/tmpl/$tmpl};
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
	$str = qq{<img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif">};
	$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif">} if($point eq "5");
	$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star_half.gif">} if($point eq "4.5");
	$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star_off.gif">} if($point eq "4");
	$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star_half.gif"><img src="/img/review_all_star_off.gif">} if($point eq "3.5");
	$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif">} if($point eq "3");
	$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star_half.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif">} if($point eq "2.5");
	$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif">} if($point eq "2");
	$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star_half.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif">} if($point eq "1.5");
	$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif">} if($point eq "1");
	$str = qq{<img src="/img/review_all_star_half.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif">} if($point eq "0.5");
	$str = qq{<img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif">} if($point eq "0");

	return $str;
}

