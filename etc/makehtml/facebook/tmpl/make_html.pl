#!/usr/bin/perl
# facebookページ作成処理
use lib qw(/var/www/vhosts/waao.jp/etc/lib /var/www/vhosts/waao.jp/lib/Waao);

use strict;
use Utility;
use Date::Simple;

if($ARGV[0] eq "top"){
	&_top();
	exit;
}

# category_slide_list作成
&_cate_slide_list();

# header作成
&_header_make();

# そのた
&_else_pages();

# person
&_person();

# top
&_top();

# pop();
&_pop();

# ranking();
&_ranking();

# now();
&_now();

# new();
&_new();

# celebrity();
&_celebrity();

# category();
&_category();


exit;

sub _person(){

	my $dirname = qq{/var/www/vhosts/waao.jp/httpdocs-facebook/person/};
	mkdir($dirname, 0755);

	my $dbh = &_db_connect();

	for(my $i=1;$i<=15;$i++){
		&_person_list($dbh,$i,1);
	}

	$dbh->disconnect;

	return;
}

sub _person_list(){
	my $dbh = shift;
	my $meikantype = shift;
	my $page = shift;

	my $html = &_load_tmpl("facebookperson.html");
	$html = &_parts_set($html);

	my ($meikanname, $sql_str) = &_meikan_name($meikantype);
	$html =~s/<!--MAIKANNAME-->/$meikanname/g;

	my $pagemax = 50;
	my $start = 0 + ($pagemax * ($page - 1));
	my $list = &_make_list($dbh, "  where person_type = $meikantype order by likecnt desc limit $start, $pagemax ", $start);
	$html =~s/<!--LIST-->/$list/g;
	my $pager .= &_pager2($page,"person",$meikantype);
	$html =~s/<!--PAGER-->/$pager/g;

	if($list){
		&_file_output("/var/www/vhosts/waao.jp/httpdocs-facebook/person/$meikantype-$page.html",$html);
		$page++;
		&_person_list($dbh,$meikantype,$page);
	}

	return;
}

sub _meikan_name(){
	my $meikantype = shift;
	
	my $meikanname;
	my $sql_str;
	$meikanname->{1} = qq{男性タレント};
	$sql_str->{1} = qq{ person = 3 };
	$meikanname->{2} = qq{女性タレント};
	$sql_str->{2} = qq{ person = 2 };
	$meikanname->{3} = qq{グラビアアイドル};
	$sql_str->{3} = qq{ person = 1 };
	$meikanname->{4} = qq{お笑いタレント};
	$sql_str->{4} = qq{ person = 4 };
	$meikanname->{6} = qq{子役};
	$sql_str->{6} = qq{ person = 6 };
	$meikanname->{7} = qq{落語家};
	$sql_str->{7} = qq{ person = 7 };
	$meikanname->{8} = qq{声優};
	$sql_str->{8} = qq{ person = 8 };
	$meikanname->{9} = qq{男性アーティスト};
	$sql_str->{9} = qq{ artist = 1 and sex = 1 };
	$meikanname->{10} = qq{女性アーティスト};
	$sql_str->{10} = qq{ artist = 1 and sex = 2 };
	$meikanname->{11} = qq{モデル};
	$sql_str->{11} = qq{ model = 1 };
	$meikanname->{12} = qq{レースクィーン};
	$sql_str->{12} = qq{ model = 2 };
	$meikanname->{13} = qq{女子アナウンサー};
	$sql_str->{13} = qq{ ana is not null };
	$meikanname->{14} = qq{AV女優};
	$sql_str->{14} = qq{ av = 1 };
	$meikanname->{15} = qq{ブログ};
	$sql_str->{15} = qq{ blogurl is not null };


	return ($meikanname->{$meikantype}, $sql_str->{$meikantype});
}

sub _else_pages(){

	my $html = &_load_tmpl("facebookranking.html");
	$html = &_parts_set($html);
	&_file_output("/var/www/vhosts/waao.jp/httpdocs-facebook/facebookranking/index.html",$html);

	my $html = &_load_tmpl("privacy.html");
	$html = &_parts_set($html);
	&_file_output("/var/www/vhosts/waao.jp/httpdocs-facebook/privacy/index.html",$html);

	my $html = &_load_tmpl("manage.html");
	$html = &_parts_set($html);
	&_file_output("/var/www/vhosts/waao.jp/httpdocs-facebook/manage/index.html",$html);

	my $html = &_load_tmpl("legal.html");
	$html = &_parts_set($html);
	&_file_output("/var/www/vhosts/waao.jp/httpdocs-facebook/legal/index.html",$html);

	my $html = &_load_tmpl("howtofacebook.html");
	$html = &_parts_set($html);
	&_file_output("/var/www/vhosts/waao.jp/httpdocs-facebook/howtofacebook.html",$html);

	my $html = &_load_tmpl("sitelist.html");
	$html = &_parts_set($html);
	&_file_output("/var/www/vhosts/waao.jp/httpdocs-facebook/sitelist.html",$html);

	return;
}

sub _header_make(){
	my $html = &_load_tmpl("header_tmp.html");

	my $dbh = &_db_connect();
	my $sth = $dbh->prepare(qq{select count(*) as total from facebook });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my $total = &price_dsp($row[0]);
		$html =~s/<!--TOTAL-->/$total/g;
	}
	$dbh->disconnect;


	&_file_output("/var/www/vhosts/waao.jp/etc/facebook/tmpl/header.html",$html);
	return;
}

sub _cate_slide_list(){

	my $dbh = &_db_connect();

	my $list;
	$list .= qq{<div class="well">\n};
	$list .= qq{<h3>facebookカテゴリ</h3>\n};

	my $sth = $dbh->prepare(qq{select id, name from facebook_category where pid = 0 order by id });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$list .= qq{<a href="/category-$row[0]-1/">$row[1]</a><br />\n};
	}
	$list .= qq{</div>\n};

	&_file_output("/var/www/vhosts/waao.jp/etc/facebook/tmpl/slider_category.html",$list);

	$dbh->disconnect;

	return;
}


sub _category(){
	my $self = shift;

	my $dirname = qq{/var/www/vhosts/waao.jp/httpdocs-facebook/category/};
	mkdir($dirname, 0755);

	my $dbh = &_db_connect();
	# 共通パーツ
	&_category_detaile($dbh,1,0);

	my $sth = $dbh->prepare(qq{select id, name from facebook_category});
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		&_category_detaile($dbh,1,$row[0]);
	}

	$dbh->disconnect;

	return;
}

sub _category_detaile(){
	my $dbh = shift;
	my $page = shift;
	my $category_id = shift;

	my $dirname = qq{/var/www/vhosts/waao.jp/httpdocs-facebook/category/$category_id/};
	mkdir($dirname, 0755);

	return if($page >= 30000);

	my $html;
	if($category_id eq 0){
		$html = &_load_tmpl("category_top.html");
	}else{
		$html = &_load_tmpl("category.html");
	}
	$html = &_parts_set($html);
	$html =~s/<!--PAGE-->/$page/g;

	# カテゴリ
	my $categoryname = "カテゴリ";
	my $sth = $dbh->prepare(qq{select id, name from facebook_category where id = ?});
	$sth->execute($category_id);
	while(my @row = $sth->fetchrow_array) {
		$categoryname = $row[1];
	}
	$html =~s/<!--CNAME-->/$categoryname/g;

	# 子カテゴリ
	my $categoryids = $category_id.",";
	my $category_list;
	my $sth = $dbh->prepare(qq{select id, name from facebook_category where pid = ?});
	$sth->execute($category_id);
	while(my @row = $sth->fetchrow_array) {
		$category_list .= qq{<a href="/category-$row[0]-1/">$row[1]</a> | };
		$categoryids .= $row[0].",";
	}
	$category_list = qq{<br />▼カテゴリを選択<br />$category_list<br /><br />} if($category_list);
	$html =~s/<!--CATELIST-->/$category_list/g;

	chop $categoryids;
	
	my $pagemax = 50;
	my $start = 0 + ($pagemax * ($page - 1));
	my $list = &_make_list($dbh, " where category_id in ( $categoryids ) group by name order by likecnt desc limit $start, $pagemax ", $start);
	$html =~s/<!--LIST-->/$list/g;
	my $pager .= &_pager($page,"category-$category_id", );
	if($category_id ne 0){
		$html =~s/<!--PAGER-->/$pager/g;
	}
	if($list){
		&_file_output("/var/www/vhosts/waao.jp/httpdocs-facebook/category/$category_id/$page.html",$html);
		$page++;
		&_category_detaile($dbh,$page,$category_id );
	}else{
		&_file_output("/var/www/vhosts/waao.jp/httpdocs-facebook/category/$category_id/$page.html",$html);
	}
	return;
}

sub _pop(){
	my $self = shift;

	my $dirname = qq{/var/www/vhosts/waao.jp/httpdocs-facebook/pop/};
	mkdir($dirname, 0755);

	my $dbh = &_db_connect();
	# 共通パーツ
	&_pop_detaile($dbh,1);
	$dbh->disconnect;

	return;
}

sub _pop_detaile(){
	my $dbh = shift;
	my $page = shift;

	return if($page >= 30000);

	my $html = &_load_tmpl("pop.html");
	$html = &_parts_set($html);
	$html =~s/<!--PAGE-->/$page/g;

	my $pagemax = 50;
	my $start = 0 + ($pagemax * ($page - 1));
	my $list = &_make_list($dbh, "  group by name order by diff_talking desc limit $start, $pagemax ", $start);
	$html =~s/<!--LIST-->/$list/g;
	my $pager .= &_pager($page,"pop");
	$html =~s/<!--PAGER-->/$pager/g;

	if($list){
		&_file_output("/var/www/vhosts/waao.jp/httpdocs-facebook/pop/$page.html",$html);
		$page++;
		&_pop_detaile($dbh,$page);
	}

	return;
}

sub _celebrity(){
	my $self = shift;

	my $dirname = qq{/var/www/vhosts/waao.jp/httpdocs-facebook/celebrity/};
	mkdir($dirname, 0755);

	my $dbh = &_db_connect();
	# 共通パーツ
	&_celebrity_detaile($dbh,1);
	$dbh->disconnect;

	return;
}

sub _celebrity_detaile(){
	my $dbh = shift;
	my $page = shift;

	return if($page >= 30000);
	
	my $html = &_load_tmpl("celebrity.html");
	$html = &_parts_set($html);
	$html =~s/<!--PAGE-->/$page/g;

	my $pagemax = 50;
	my $start = 0 + ($pagemax * ($page - 1));
	my $list = &_make_list($dbh, " where category_id between 103 and 125 group by name order by likecnt desc limit $start, $pagemax ", $start);
	$html =~s/<!--LIST-->/$list/g;
	my $pager .= &_pager($page,"celebrity");
	$html =~s/<!--PAGER-->/$pager/g;

	if($list){
		&_file_output("/var/www/vhosts/waao.jp/httpdocs-facebook/celebrity/$page.html",$html);
		$page++;
		&_celebrity_detaile($dbh,$page);
	}

	return;
}

sub _new(){
	my $self = shift;

	my $dirname = qq{/var/www/vhosts/waao.jp/httpdocs-facebook/new/};
	mkdir($dirname, 0755);

	my $dbh = &_db_connect();
	# 共通パーツ
	&_new_detaile($dbh,1);
	$dbh->disconnect;

	return;
}

sub _new_detaile(){
	my $dbh = shift;
	my $page = shift;

	return if($page >= 100);
	
	my $html = &_load_tmpl("new.html");
	$html = &_parts_set($html);
	$html =~s/<!--PAGE-->/$page/g;

	my $pagemax = 50;
	my $start = 0 + ($pagemax * ($page - 1));
	my $list = &_make_list($dbh, " group by name order by id desc limit $start, $pagemax ", $start);
	$html =~s/<!--LIST-->/$list/g;
	my $pager .= &_pager($page,"new");
	$html =~s/<!--PAGER-->/$pager/g;

	if($list){
		&_file_output("/var/www/vhosts/waao.jp/httpdocs-facebook/new/$page.html",$html);
		$page++;
		&_new_detaile($dbh,$page);
	}

	return;
}


sub _now(){
	my $self = shift;

	my $dirname = qq{/var/www/vhosts/waao.jp/httpdocs-facebook/now/};
	mkdir($dirname, 0755);

	my $dbh = &_db_connect();
	# 共通パーツ
	&_now_detaile($dbh,1);
	$dbh->disconnect;

	return;
}

sub _now_detaile(){
	my $dbh = shift;
	my $page = shift;

	return if($page >= 100);
	
	my $html = &_load_tmpl("now.html");
	$html = &_parts_set($html);
	$html =~s/<!--PAGE-->/$page/g;

	my $pagemax = 50;
	my $start = 0 + ($pagemax * ($page - 1));
	my $list = &_make_list($dbh, " group by name order by diff_cnt desc limit $start, $pagemax ", $start);
	$html =~s/<!--LIST-->/$list/g;
	my $pager .= &_pager($page,"now");
	$html =~s/<!--PAGER-->/$pager/g;

	if($list){
		&_file_output("/var/www/vhosts/waao.jp/httpdocs-facebook/now/$page.html",$html);
		$page++;
		&_now_detaile($dbh,$page);
	}

	return;
}

sub _ranking(){
	my $self = shift;

	my $dirname = qq{/var/www/vhosts/waao.jp/httpdocs-facebook/ranking/};
	mkdir($dirname, 0755);

	my $dbh = &_db_connect();
	# 共通パーツ
	&_ranking_detaile($dbh,1);
	$dbh->disconnect;

	return;
}

sub _ranking_detaile(){
	my $dbh = shift;
	my $page = shift;

	return if($page >= 3000);
	
	my $html = &_load_tmpl("ranking.html");
	$html = &_parts_set($html);
	$html =~s/<!--PAGE-->/$page/g;

	my $pagemax = 50;
	my $start = 0 + ($pagemax * ($page - 1));
	my $list = &_make_list($dbh, " group by name order by likecnt desc limit $start, $pagemax ", $start);
	$html =~s/<!--LIST-->/$list/g;
	my $pager .= &_pager($page,"ranking");
	$html =~s/<!--PAGER-->/$pager/g;

	if($list){
		&_file_output("/var/www/vhosts/waao.jp/httpdocs-facebook/ranking/$page.html",$html);
		$page++;
		&_ranking_detaile($dbh,$page);
	}

	return;
}

sub _top(){


	my $dbh = &_db_connect();

	# main
	my $html = &_load_tmpl("top.html");
	$html = &_parts_set($html);

	# ニューストピックス
	my $newstopics;
	my $sth = $dbh->prepare(qq{select id, title from fmfm where type <=2 order by id desc limit 8 });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$newstopics.=qq{・<a href="/rd.html?id=$row[0]" target="_blank" ref=nofollow>$row[1]</a><img src="/img/E008_20.gif"><br />};
	}

	$html =~s/<!--NEWS-->/$newstopics/g;
	
	# 新着
	my $list;
	$list = &_make_list($dbh, " where likecnt <= 50000 group by name order by diff_cnt desc limit 30 ");
	$html =~s/<!--RANKING_LIST-->/$list/g;
	my $pager .= &_pager(1,"now");
	$html =~s/<!--PAGENATION-->/$pager/g;

	$dbh->disconnect;

	&_file_output("/var/www/vhosts/waao.jp/httpdocs-facebook/index.html",$html);
	return;
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
	my $slider_main = &_load_tmpl("slider_main.html");
	# slider
	my $slider_regist = &_load_tmpl("slider_regist.html");
	# slider
	my $slider_category = &_load_tmpl("slider_category.html");

	$html =~s/<!--META-->/$meta/g;
	$html =~s/<!--HEADER-->/$header/g;
	$html =~s/<!--FOOTER-->/$footer/g;
	$html =~s/<!--SLIDER_MAIN-->/$slider_main/g;
	$html =~s/<!--SLIDER_REGIST-->/$slider_regist/g;
	$html =~s/<!--SLIDER_CATEGORY-->/$slider_category/g;

	return $html;
}

sub _pager(){
	my $page = shift;
	my $type = shift;
	my $pagelist;

	$pagelist .= qq{<div class="pagination">\n};
	$pagelist .= qq{<ul>\n};
	if($page == 1){
	   	$pagelist .= qq{<li class="prev disabled"><a href="/$type-1/">&larr; Previous</a></li>\n};
	}else{
		my $preno = $page - 1;
	   	$pagelist .= qq{<li class="prev"><a href="/$type-$preno/">&larr; Previous</a></li>\n};
	}
	my $pageno;
	for(my $i=0; $i<10; $i++){
		$pageno = $page + $i;
		if($page eq $pageno){
		    $pagelist .= qq{<li class="active"><a href="/$type-$pageno/">$pageno</a></li>\n};
		}else{
		    $pagelist .= qq{<li><a href="/$type-$pageno/">$pageno</a></li>\n};
		}
	}
	$pageno++;
	my $page_next = $page + 1;
    $pagelist .= qq{<li class="next"><a href="/$type-$page_next/">Next &rarr;</a></li>\n};
    $pagelist .= qq{</ul>\n};
    $pagelist .= qq{</div>\n};

	return $pagelist;
}

sub _pager2(){
	my $page = shift;
	my $type = shift;
	my $type2 = shift;
	my $pagelist;

	$pagelist .= qq{<div class="pagination">\n};
	$pagelist .= qq{<ul>\n};
	if($page == 1){
	   	$pagelist .= qq{<li class="prev disabled"><a href="/$type-$type2-1/">&larr; Previous</a></li>\n};
	}else{
		my $preno = $page - 1;
	   	$pagelist .= qq{<li class="prev"><a href="/$type-$type2-$preno/">&larr; Previous</a></li>\n};
	}
	my $pageno;
	for(my $i=0; $i<10; $i++){
		$pageno = $page + $i;
		if($page eq $pageno){
		    $pagelist .= qq{<li class="active"><a href="/$type-$type2-$pageno/">$pageno</a></li>\n};
		}else{
		    $pagelist .= qq{<li><a href="/$type-$type2-$pageno/">$pageno</a></li>\n};
		}
	}
	$pageno++;
	my $page_next = $page + 1;
    $pagelist .= qq{<li class="next"><a href="/$type-$type2-$page_next/">Next &rarr;</a></li>\n};
    $pagelist .= qq{</ul>\n};
    $pagelist .= qq{</div>\n};

	return $pagelist;
}

sub _make_list(){
	my $dbh = shift;
	my $where = shift;
	my $startno = shift;

	my $list;
	my $sth = $dbh->prepare(qq{select id, img, url, name, category_id, likecnt, diff_cnt,f_exp,talking_about_count,diff_talking from facebook $where });
	$sth->execute();
	$startno = 1 unless($startno);
	my $no = $startno;
	while(my @row = $sth->fetchrow_array) {
		my $star_str = &_star_img($row[5]);
#		my $facebook = qq{<div class="fb-like" data-href="http://facebookranking.info/facebook$row[0]/" data-send="false" data-layout="button_count" data-width="50" data-show-faces="false" data-action="like" data-font="lucida grande"></div>};
		my $facebook = qq{<a href="/facebook$row[0]/" target="_blank"><img src="/img/facebook_like.png" width="80"></a>};
#		my $facebook = qq{<iframe src="http://www.facebook.com/plugins/like.php?href=http://facebookranking.info/facebook$row[0]/&layout=button_count&show_faces=true&width=250&action=like&colorscheme=light" scrolling="no" frameborder="0" allowTransparency="true" style="border:none; overflow:hidden; width:105px; height:24px"></iframe>};
#		my $twitter = qq{<a href="https://twitter.com/share" class="twitter-share-button" data-url="http://applease.info/facebook$row[0]/" data-text="イイ！アプリ:$row[3]" data-count="none" data-lang="ja">ツイート</a><script type="text/javascript" src="//platform.twitter.com/widgets.js"></script>};
my $twitter;
		my $category_name;

		my $sth2 = $dbh->prepare(qq{select id, name from facebook_category where id = ?});
		$sth2->execute($row[4]);
		while(my @row2 = $sth2->fetchrow_array) {
			$category_name = qq{カテゴリ：<a href="/category-$row2[0]-1/">$row2[1]のfacebookページ</a>};
		}
		my $exp_str = $row[7];
		$exp_str = substr($exp_str,0,256);
		my $talking_about_count = &price_dsp($row[8]);
		$talking_about_count = 0 unless($talking_about_count);
		my $talking_about_diff = &price_dsp($row[9]);
		$talking_about_diff = 0 unless($talking_about_diff);
		my $like_str = &price_dsp($row[5]);
		my $like_diff_str = &price_dsp($row[6]);
		$list .= qq{<tr>\n};
		$list .= qq{<td><b>$no</b></td>\n};
		$list .= qq{<td><img src="$row[1]" alt="$row[3]"></td>\n};
		$list .= qq{<td><h3><a href="/facebook$row[0]/">$row[3]</a></h3>};

		if($exp_str){
			$list .= qq{<div class="well">$exp_str <a href="/facebook$row[0]/">...続きを見る</a></div>\n};
		}else{
			$list .= qq{<br />\n};
		}
		$list .= qq{$star_str<br />$category_name</td>\n};
		$list .= qq{<td width=15%>$like_str<br /><font color="#FF0000">+$like_diff_str</font><br />話題:$talking_about_count<br /><font color="#FF0000">+$talking_about_diff</font><br />$facebook</td>\n};
		$list .= qq{</tr>\n};
		$no++;

	}
print "$where: $no\n";

	
	return $list;
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
	
my $file = qq{/var/www/vhosts/waao.jp/etc/facebook/tmpl/$tmpl};
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
	$html =~s/<!--DATE-->/$ymd/gi;
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
	if($point >= 100000){
		$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif">};
	}elsif($point >= 80000){
		$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star_half.gif">};
	}elsif($point >= 50000){
		$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star_off.gif">};
	}elsif($point >= 30000){
		$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star_half.gif"><img src="/img/review_all_star_off.gif">};
	}elsif($point >= 10000){
		$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif">};
	}elsif($point >= 8000){
		$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star_half.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif">};
	}elsif($point >= 5000){
		$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif">};
	}elsif($point >= 3000){
		$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star_half.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif">};
	}elsif($point >= 1000){
		$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif">};
	}elsif($point >= 800){
		$str = qq{<img src="/img/review_all_star_half.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif">};
	}elsif($point >= 500){
		$str = qq{<img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif">};
	}
	return $str;
}


