#!/usr/bin/perl
# facebookページ作成処理
use lib qw(/var/www/vhosts/goo.to/etc/lib /var/www/vhosts/goo.to/lib/Waao);

use strict;
use Utility;
use Date::Simple;

# ２重起動防止
if ($$ != `/usr/bin/pgrep -fo $0`) {
print "exit \n";
    exit 1;
}
print "start \n";

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

# new();
&_new();


# person
&_person();

# top
&_top();

# celebrity();
&_celebrity();

# category();
&_category();

# now();
&_now();

# pop();
&_pop();

# ranking();
&_ranking();


exit;

sub _person(){

	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-facebook/person/};
	mkdir($dirname, 0755);
	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-facebook/list/};
	mkdir($dirname, 0755);
	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-facebook/list/person/};
	mkdir($dirname, 0755);

	my $dbh = &_db_connect();

	for(my $i=1;$i<=15;$i++){
		&_person_detail($dbh,$i,1);
		&_person_detail_list($dbh,$i,1);
	}

	$dbh->disconnect;

	return;
}

sub _person_detail(){
	my $dbh = shift;
	my $meikantype = shift;
	my $page = shift;

	my $html = &_load_tmpl("facebookperson.html");
	$html = &_parts_set($html);

	my ($meikanname, $sql_str) = &_meikan_name($meikantype);
	$html =~s/<!--MAIKANNAME-->/$meikanname/g;
	$html =~s/<!--MEIKAN-->/$meikantype/g;
	$html =~s/<!--PAGE-->/$page/g;

	my $pagemax = 50;
	my $start = 0 + ($pagemax * ($page - 1));
	my $list = &_make_list($dbh, "  where person_type = $meikantype order by likecnt desc limit $start, $pagemax ", $start);
	$html =~s/<!--LIST-->/$list/g;
	my $pager .= &_pager2($page,"person",$meikantype);
	$html =~s/<!--PAGER-->/$pager/g;

	if($list){
		print "$meikantype-$page.html\n";
		&_file_output("/var/www/vhosts/goo.to/httpdocs-facebook/person/$meikantype-$page.html",$html);
		$page++;
		&_person_detail($dbh,$meikantype,$page);
	}

	return;
}

sub _person_detail_list(){
	my $dbh = shift;
	my $meikantype = shift;
	my $page = shift;

	my $html = &_load_tmpl("facebookperson.html");
	$html = &_parts_set($html,1);

	my ($meikanname, $sql_str) = &_meikan_name($meikantype);
	$html =~s/<!--MAIKANNAME-->/$meikanname/g;
	$html =~s/<!--MEIKAN-->/$meikantype/g;
	$html =~s/<!--PAGE-->/$page/g;

	my $pagemax = 50;
	my $start = 0 + ($pagemax * ($page - 1));
	my $list = &_make_list2($dbh, "  where person_type = $meikantype order by likecnt desc limit $start, $pagemax ", $start);
	$html =~s/<!--LIST-->/$list/g;
	my $pager .= &_pager2($page,"person",$meikantype,1);
	$html =~s/<!--PAGER-->/$pager/g;

	if($list){
		&_file_output("/var/www/vhosts/goo.to/httpdocs-facebook/list/person/$meikantype-$page.html",$html);
		$page++;
		&_person_detail_list($dbh,$meikantype,$page);
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

	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-facebook/facebookranking/};
	mkdir($dirname, 0755);
	my $html = &_load_tmpl("facebookranking.html");
	$html = &_parts_set($html);
	&_file_output("/var/www/vhosts/goo.to/httpdocs-facebook/facebookranking/index.html",$html);

	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-facebook/privacy/};
	mkdir($dirname, 0755);
	my $html = &_load_tmpl("privacy.html");
	$html = &_parts_set($html);
	&_file_output("/var/www/vhosts/goo.to/httpdocs-facebook/privacy/index.html",$html);

	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-facebook/manage/};
	mkdir($dirname, 0755);
	my $html = &_load_tmpl("manage.html");
	$html = &_parts_set($html);
	&_file_output("/var/www/vhosts/goo.to/httpdocs-facebook/manage/index.html",$html);

	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-facebook/legal/};
	mkdir($dirname, 0755);
	my $html = &_load_tmpl("legal.html");
	$html = &_parts_set($html);
	&_file_output("/var/www/vhosts/goo.to/httpdocs-facebook/legal/index.html",$html);

	my $html = &_load_tmpl("howtofacebook.html");
	$html = &_parts_set($html);
	&_file_output("/var/www/vhosts/goo.to/httpdocs-facebook/howtofacebook.html",$html);

	my $html = &_load_tmpl("sitelist.html");
	$html = &_parts_set($html);
	&_file_output("/var/www/vhosts/goo.to/httpdocs-facebook/sitelist.html",$html);

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


	&_file_output("/var/www/vhosts/goo.to/etc/makehtml/facebook/tmpl/header.html",$html);
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

	&_file_output("/var/www/vhosts/goo.to/etc/makehtml/facebook/tmpl/slider_category.html",$list);

	$dbh->disconnect;

	return;
}


sub _category(){
	my $self = shift;

	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-facebook/category/};
	mkdir($dirname, 0755);
	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-facebook/list/};
	mkdir($dirname, 0755);
	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-facebook/list/category/};
	mkdir($dirname, 0755);

	my $dbh = &_db_connect();
	# 共通パーツ
	&_category_detaile($dbh,1,0);

	my $sth = $dbh->prepare(qq{select id, name from facebook_category});
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		&_category_detaile($dbh,1,$row[0]);
		&_category_detaile_list($dbh,1,$row[0]);
	}

	$dbh->disconnect;

	return;
}

sub _category_detaile(){
	my $dbh = shift;
	my $page = shift;
	my $category_id = shift;

	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-facebook/category/$category_id/};
	mkdir($dirname, 0755);

	return if($page >= 50);

	my $html;
	if($category_id eq 0){
		$html = &_load_tmpl("category_top.html");
	}else{
		$html = &_load_tmpl("category.html");
	}
	$html = &_parts_set($html);
	$html =~s/<!--PAGE-->/$page/g;
	$html =~s/<!--CATE_ID-->/$category_id/g;

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
		my $countno;
		my $sth2 = $dbh->prepare(qq{select count(*) from facebook where category_id = ? });
#		$sth2->execute($row[0]);
#		while(my @row2 = $sth2->fetchrow_array) {
#			$countno = $row2[0];
#		}

		if($category_id eq 0){
			$category_list .= qq{<img src="/img/E23C_20.gif" width="15"><a href="/category-$row[0]-1/">$row[1]</a>};
			my $sub_category;
			my $sth3 = $dbh->prepare(qq{select id, name from facebook_category where pid = ?});
			$sth3->execute($row[0]);
			while(my @row3 = $sth3->fetchrow_array) {
				$sub_category .= qq{<a href="/category-$row3[0]-1/">$row3[1]</a> | };
			}
			$category_list .= qq{<div class="well">$sub_category</div>};

		}else{
			$category_list .= qq{<a href="/category-$row[0]-1/">$row[1]</a> | };
		}
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
		&_file_output("/var/www/vhosts/goo.to/httpdocs-facebook/category/$category_id/$page.html",$html);
		$page++;
		&_category_detaile($dbh,$page,$category_id );
	}else{
		&_file_output("/var/www/vhosts/goo.to/httpdocs-facebook/category/$category_id/$page.html",$html);
	}
	return;
}

sub _category_detaile_list(){
	my $dbh = shift;
	my $page = shift;
	my $category_id = shift;

	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-facebook/list/category/$category_id/};
	mkdir($dirname, 0755);

	return if($page >= 50);

	my $html;
	if($category_id eq 0){
		$html = &_load_tmpl("category_top.html");
	}else{
		$html = &_load_tmpl("category.html");
	}
	$html = &_parts_set($html,1);
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
		$category_list .= qq{<a href="/list/category-$row[0]-1/">$row[1]</a> | };
		$categoryids .= $row[0].",";
	}
	$category_list = qq{<br />▼カテゴリを選択<br />$category_list<br /><br />} if($category_list);
	$html =~s/<!--CATELIST-->/$category_list/g;

	chop $categoryids;
	
	my $pagemax = 50;
	my $start = 0 + ($pagemax * ($page - 1));
	my $list = &_make_list2($dbh, " where category_id in ( $categoryids ) group by name order by likecnt desc limit $start, $pagemax ", $start);
	$html =~s/<!--LIST-->/$list/g;
	my $pager .= &_pager($page,"category-$category_id", 1);
	if($category_id ne 0){
		$html =~s/<!--PAGER-->/$pager/g;
	}
	if($list){
		&_file_output("/var/www/vhosts/goo.to/httpdocs-facebook/list/category/$category_id/$page.html",$html);
		$page++;
		&_category_detaile_list($dbh,$page,$category_id );
	}else{
		&_file_output("/var/www/vhosts/goo.to/httpdocs-facebook/list/category/$category_id/$page.html",$html);
	}
	return;
}

sub _pop(){
	my $self = shift;

	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-facebook/pop/};
	mkdir($dirname, 0755);
	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-facebook/list/};
	mkdir($dirname, 0755);
	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-facebook/list/pop/};
	mkdir($dirname, 0755);

	my $dbh = &_db_connect();
	# 共通パーツ
	&_pop_detaile_list($dbh,1);
	&_pop_detaile($dbh,1);
	$dbh->disconnect;

	return;
}

sub _pop_detaile(){
	my $dbh = shift;
	my $page = shift;

	return if($page >= 50);

	my $html = &_load_tmpl("pop.html");
	$html = &_parts_set($html);
	$html =~s/<!--PAGE-->/$page/g;

	my $pagemax = 50;
	my $start = 0 + ($pagemax * ($page - 1));
	my $list = &_make_list($dbh, "  group by name order by talking_about_count desc limit $start, $pagemax ", $start);
	$html =~s/<!--LIST-->/$list/g;
	my $pager .= &_pager($page,"pop");
	$html =~s/<!--PAGER-->/$pager/g;

	if($list){
		&_file_output("/var/www/vhosts/goo.to/httpdocs-facebook/pop/$page.html",$html);
		$page++;
		&_pop_detaile($dbh,$page);
	}

	return;
}

sub _pop_detaile_list(){
	my $dbh = shift;
	my $page = shift;

	return if($page >= 50);

	my $html = &_load_tmpl("pop.html");
	$html = &_parts_set($html,1);
	$html =~s/<!--PAGE-->/$page/g;

	my $pagemax = 50;
	my $start = 0 + ($pagemax * ($page - 1));
	my $list = &_make_list2($dbh, "  group by name order by talking_about_count desc limit $start, $pagemax ", $start);
	$html =~s/<!--LIST-->/$list/g;
	my $pager .= &_pager($page,"pop",1);
	$html =~s/<!--PAGER-->/$pager/g;

	if($list){
		&_file_output("/var/www/vhosts/goo.to/httpdocs-facebook/list/pop/$page.html",$html);
		$page++;
		&_pop_detaile_list($dbh,$page);
	}

	return;
}

sub _celebrity(){
	my $self = shift;

	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-facebook/celebrity/};
	mkdir($dirname, 0755);
	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-facebook/list/};
	mkdir($dirname, 0755);
	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-facebook/list/celebrity/};
	mkdir($dirname, 0755);

	my $dbh = &_db_connect();
	# 共通パーツ
	&_celebrity_detaile($dbh,1);
	&_celebrity_detaile_list($dbh,1);
	$dbh->disconnect;

	return;
}

sub _celebrity_detaile(){
	my $dbh = shift;
	my $page = shift;

	return if($page >= 50);
	
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
		&_file_output("/var/www/vhosts/goo.to/httpdocs-facebook/celebrity/$page.html",$html);
		$page++;
		&_celebrity_detaile($dbh,$page);
	}

	return;
}

sub _celebrity_detaile_list(){
	my $dbh = shift;
	my $page = shift;

	return if($page >= 50);
	
	my $html = &_load_tmpl("celebrity.html");
	$html = &_parts_set($html,1);
	$html =~s/<!--PAGE-->/$page/g;

	my $pagemax = 50;
	my $start = 0 + ($pagemax * ($page - 1));
	my $list = &_make_list2($dbh, " where category_id between 103 and 125 group by name order by likecnt desc limit $start, $pagemax ", $start);
	$html =~s/<!--LIST-->/$list/g;
	my $pager .= &_pager($page,"celebrity",1);
	$html =~s/<!--PAGER-->/$pager/g;

	if($list){
		&_file_output("/var/www/vhosts/goo.to/httpdocs-facebook/list/celebrity/$page.html",$html);
		$page++;
		&_celebrity_detaile_list($dbh,$page);
	}

	return;
}

sub _new(){
	my $self = shift;

print "_new\n\n";
	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-facebook/new/};
	mkdir($dirname, 0755);

	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-facebook/list/};
	mkdir($dirname, 0755);

	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-facebook/list/new/};
	mkdir($dirname, 0755);

	my $dbh = &_db_connect();
	# 共通パーツ
	&_new_detaile_list($dbh,1);
	&_new_detaile($dbh,1);
	$dbh->disconnect;

	return;
}

sub _new_detaile(){
	my $dbh = shift;
	my $page = shift;

	return if($page >= 50);
	
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
		&_file_output("/var/www/vhosts/goo.to/httpdocs-facebook/new/$page.html",$html);
		$page++;
		&_new_detaile($dbh,$page);
	}

	return;
}

sub _new_detaile_list(){
	my $dbh = shift;
	my $page = shift;

	return if($page >= 50);
	
	my $html = &_load_tmpl("new.html");
	$html = &_parts_set($html,1);
	$html =~s/<!--PAGE-->/$page/g;

	my $pagemax = 50;
	my $start = 0 + ($pagemax * ($page - 1));
	my $list = &_make_list2($dbh, " group by name order by id desc limit $start, $pagemax ", $start);
	$html =~s/<!--LIST-->/$list/g;
	my $pager .= &_pager($page,"new",1);
	$html =~s/<!--PAGER-->/$pager/g;

	if($list){
		&_file_output("/var/www/vhosts/goo.to/httpdocs-facebook/list/new/$page.html",$html);
		$page++;
		&_new_detaile_list($dbh,$page);
	}

	return;
}


sub _now(){
	my $self = shift;

	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-facebook/now/};
	mkdir($dirname, 0755);
	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-facebook/list/};
	mkdir($dirname, 0755);
	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-facebook/list/now/};
	mkdir($dirname, 0755);

	my $dbh = &_db_connect();
	# 共通パーツ
	&_now_detaile_list($dbh,1);
	&_now_detaile($dbh,1);
	$dbh->disconnect;

	return;
}

sub _now_detaile(){
	my $dbh = shift;
	my $page = shift;

	return if($page >= 50);
	
	my $html = &_load_tmpl("now.html");
	$html = &_parts_set($html);
	$html =~s/<!--PAGE-->/$page/g;

	my $pagemax = 50;
	my $start = 0 + ($pagemax * ($page - 1));
	my $list = &_make_list($dbh, " group by name order by diff_cnt desc limit $start, $pagemax ", $start,1);
	$html =~s/<!--LIST-->/$list/g;
	my $pager .= &_pager($page,"now");
	$html =~s/<!--PAGER-->/$pager/g;

	if($list){
		&_file_output("/var/www/vhosts/goo.to/httpdocs-facebook/now/$page.html",$html);
		$page++;
		&_now_detaile($dbh,$page);
	}

	return;
}

sub _now_detaile_list(){
	my $dbh = shift;
	my $page = shift;

	return if($page >= 50);
	
	my $html = &_load_tmpl("now.html");
	$html = &_parts_set($html,1);
	$html =~s/<!--PAGE-->/$page/g;

	my $pagemax = 50;
	my $start = 0 + ($pagemax * ($page - 1));
	my $list = &_make_list2($dbh, " group by name order by diff_cnt desc limit $start, $pagemax ", $start,1);
	$html =~s/<!--LIST-->/$list/g;
	my $pager .= &_pager($page,"now",1);
	$html =~s/<!--PAGER-->/$pager/g;

	if($list){
		&_file_output("/var/www/vhosts/goo.to/httpdocs-facebook/list/now/$page.html",$html);
		$page++;
		&_now_detaile_list($dbh,$page);
	}

	return;
}

sub _ranking(){
	my $self = shift;

	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-facebook/ranking/};
	mkdir($dirname, 0755);
	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-facebook/list/};
	mkdir($dirname, 0755);
	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-facebook/list/ranking/};
	mkdir($dirname, 0755);

	my $dbh = &_db_connect();
	# 共通パーツ
	&_ranking_detaile_list($dbh,1);
	&_ranking_detaile($dbh,1);
	$dbh->disconnect;

	return;
}

sub _ranking_detaile(){
	my $dbh = shift;
	my $page = shift;

	return if($page >= 50);
	
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
		&_file_output("/var/www/vhosts/goo.to/httpdocs-facebook/ranking/$page.html",$html);
		$page++;
		&_ranking_detaile($dbh,$page);
	}

	return;
}
sub _ranking_detaile_list(){
	my $dbh = shift;
	my $page = shift;

	return if($page >= 50);
	
	my $html = &_load_tmpl("ranking.html");
	$html = &_parts_set($html,1);
	$html =~s/<!--PAGE-->/$page/g;

	my $pagemax = 50;
	my $start = 0 + ($pagemax * ($page - 1));
	my $list = &_make_list2($dbh, " group by name order by likecnt desc limit $start, $pagemax ", $start);
	$html =~s/<!--LIST-->/$list/g;
	my $pager .= &_pager($page,"ranking",1);
	$html =~s/<!--PAGER-->/$pager/g;

	if($list){
		&_file_output("/var/www/vhosts/goo.to/httpdocs-facebook/list/ranking/$page.html",$html);
		$page++;
		&_ranking_detaile_list($dbh,$page);
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
	my $datetime;
	my $sth = $dbh->prepare(qq{select id, title, now() from fmfm where type <=2 order by id desc limit 8 });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$datetime = $row[2];
		$newstopics.=qq{・<a href="/rd.htm?id=$row[0]" target="_blank" ref=nofollow>$row[1]</a> <img src="/img/E008_20.gif"><br />};
	}

	$html =~s/<!--DATETIME-->/$datetime/g;
	$html =~s/<!--NEWS-->/$newstopics/g;

	# レビュー
	my $reviewlist;
	my $sth = $dbh->prepare(qq{select id, f_id, title, review from facebook_review order by id desc limit 1});
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my $sth2 = $dbh->prepare(qq{select img, url, name, likecnt, diff_cnt, talking_about_count, diff_talking from facebook where id = ? limit 1});
		$sth2->execute($row[1]);
		while(my @row2 = $sth2->fetchrow_array) {
			$reviewlist.=qq{<tr>\n};
			$reviewlist.=qq{<td><img src="$row2[0]"></td>\n};
			$reviewlist.=qq{<td><h3><a href="/facebook$row[1]/">$row2[2]</a></h3><div class="well">$row[2]</div></td>\n};
			$reviewlist.=qq{<td width=15%>$row2[3]<br /><font color="#FF0000">+$row2[4]</font><br />話題:$row2[5]<br /><font color="#FF0000">+$row2[6]</font></td>\n};
			$reviewlist.=qq{</tr>\n};
		}
	}
	$html =~s/<!--REVIEW-->/$reviewlist/g;

	
	# 新着
	my $list;
	$list = &_make_list($dbh, " where likecnt <= 50000 group by name order by diff_cnt desc limit 30 ");
	$html =~s/<!--RANKING_LIST-->/$list/g;
	my $pager .= &_pager(1,"now");
	$html =~s/<!--PAGENATION-->/$pager/g;

	$dbh->disconnect;

	&_file_output("/var/www/vhosts/goo.to/httpdocs-facebook/index.html",$html);
	return;
}

sub _parts_set(){
	my $html = shift;
	my $flag = shift;

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
	if($flag){
		my $list_str = qq{/list};
		$html =~s/<!--LISTSTR-->/$list_str/g;
		my $listseo_str = qq{リストモード};
		$html =~s/<!--LISTSEO-->/$listseo_str/g;
	}else{
		$html =~s/<!--LISTSTR-->//g;
		$html =~s/<!--LISTSEO-->//g;
	}

	# ad
	my $ad_header = &_load_tmpl("ad_header.html");
	$html =~s/<!--AD_HEADER-->/$ad_header/g;

	my $footermenu = &_load_tmpl("footermenu.html");
	$html =~s/<!--FOOTERMENU-->/$footermenu/g;

	return $html;
}

sub _pager(){
	my $page = shift;
	my $type = shift;
	my $listflag = shift;
	my $pagelist;

	my $liststr;
	$liststr = qq{/list} if($listflag);

	$pagelist .= qq{<div class="pagination">\n};
	$pagelist .= qq{<ul>\n};
	if($page == 1){
	   	$pagelist .= qq{<li class="prev disabled"><a href="$liststr/$type-1/">&larr; Previous</a></li>\n};
	}else{
		my $preno = $page - 1;
	   	$pagelist .= qq{<li class="prev"><a href="$liststr/$type-$preno/">&larr; Previous</a></li>\n};
	}
	my $pageno;
	for(my $i=0; $i<10; $i++){
		$pageno = $page + $i;
		if($page eq $pageno){
		    $pagelist .= qq{<li class="active"><a href="$liststr/$type-$pageno/">$pageno</a></li>\n};
		}else{
		    $pagelist .= qq{<li><a href="$liststr/$type-$pageno/">$pageno</a></li>\n};
		}
	}
	$pageno++;
	my $page_next = $page + 1;
    $pagelist .= qq{<li class="next"><a href="$liststr/$type-$page_next/">Next &rarr;</a></li>\n};
    $pagelist .= qq{</ul>\n};
    $pagelist .= qq{</div>\n};

	return $pagelist;
}

sub _pager2(){
	my $page = shift;
	my $type = shift;
	my $type2 = shift;
	my $listflag = shift;
	my $pagelist;

	my $liststr;
	$liststr = qq{/list} if($listflag);

	$pagelist .= qq{<div class="pagination">\n};
	$pagelist .= qq{<ul>\n};
	if($page == 1){
	   	$pagelist .= qq{<li class="prev disabled"><a href="$liststr/$type-$type2-1/">&larr; Previous</a></li>\n};
	}else{
		my $preno = $page - 1;
	   	$pagelist .= qq{<li class="prev"><a href="$liststr/$type-$type2-$preno/">&larr; Previous</a></li>\n};
	}
	my $pageno;
	for(my $i=0; $i<10; $i++){
		$pageno = $page + $i;
		if($page eq $pageno){
		    $pagelist .= qq{<li class="active"><a href="$liststr/$type-$type2-$pageno/">$pageno</a></li>\n};
		}else{
		    $pagelist .= qq{<li><a href="$liststr/$type-$type2-$pageno/">$pageno</a></li>\n};
		}
	}
	$pageno++;
	my $page_next = $page + 1;
    $pagelist .= qq{<li class="next"><a href="$liststr/$type-$type2-$page_next/">Next &rarr;</a></li>\n};
    $pagelist .= qq{</ul>\n};
    $pagelist .= qq{</div>\n};

	return $pagelist;
}

sub _make_list(){
	my $dbh = shift;
	my $where = shift;
	my $startno = shift;
	my $diff_flag = shift;

	my $listcnt;
	my $list;
	$list .= qq{<div id="grid-content">\n};
	my $sth = $dbh->prepare(qq{select id, img, url, name, category_id, likecnt, diff_cnt,f_exp,talking_about_count,diff_talking from facebook $where });
	$sth->execute();
	$startno = 1 unless($startno);
	my $no = $startno;
	while(my @row = $sth->fetchrow_array) {
		$listcnt++;
		my $star_str = &_star_img($row[5]);
		my $facebook = qq{<a href="/facebook$row[0]/" target="_blank"><img src="/img/facebook_like.png" width="80"></a>};
		my $twitter;
		my $category_name;

		my $sth2 = $dbh->prepare(qq{select id, name from facebook_category where id = ?});
		$sth2->execute($row[4]);
		while(my @row2 = $sth2->fetchrow_array) {
			$category_name = qq{カテゴリ：<a href="/category-$row2[0]-1/">$row2[1]</a>};
		}
		my $exp_str = $row[7];
		$exp_str = substr($exp_str,0,256);
		my $talking_about_count = &price_dsp($row[8]);
		$talking_about_count = 0 unless($talking_about_count);
		my $talking_about_diff = &price_dsp($row[9]);
		$talking_about_diff = 0 unless($talking_about_diff);
		my $like_str = &price_dsp($row[5]);
		my $like_diff_str = &price_dsp($row[6]);

		$list .= qq{<div>\n};
		$list .= qq{<img src="/img/E20D_20.gif" width="15">$row[3]\n};
		$list .= qq{<p>$star_str</p>\n};
		$list .= qq{<p>$category_name</p>\n};
		if($diff_flag){
			$list .= qq{<p><img src="/img/E00F_20.gif" width="15">今日のいいね！ <font color="#FF0000">+$like_diff_str</font></p>\n};
		}
		$list .= qq{<p><img src="/img/E00E_20.gif" width="15"> いいね:$like_str</p>\n};
		$list .= qq{<p><img src="/img/E404_20.gif" width="15"> シェア:$talking_about_count</p>\n};
		$list .= qq{<a href="/facebook$row[0]/"><img src="$row[1]" width="200" alt="$row[3]" class="example1" /></a>\n};
		$list .= qq{<br />$exp_str <a href="/facebook$row[0]/">...続きを見る</a></p>\n} if($exp_str);
		$list .= qq{</div>\n};
		$no++;

	}
	$list .= qq{</div>\n};
print "$where: $no\n";

	$list = undef unless($listcnt);

	return $list;
}

sub _make_list2(){
	my $dbh = shift;
	my $where = shift;
	my $startno = shift;
	my $diff_flag = shift;

	my $list_str = qq{/list};

	my $listcnt;
	my $list;
	$list .= qq{<table class="zebra-striped">\n};
	$list .= qq{<tbody>\n};
	$list .= qq{<thead>\n};
	$list .= qq{<tr>\n};
	$list .= qq{<th>順番</th>\n};
	$list .= qq{<th>イメージ</th>\n};
	$list .= qq{<th>facebookページ</th>\n};
	$list .= qq{<th>いいね！数</th>\n};
	$list .= qq{<th>シェア数</th>\n};
	$list .= qq{</tr>\n};
	$list .= qq{</thead>\n};
	
	my $sth = $dbh->prepare(qq{select id, img, url, name, category_id, likecnt, diff_cnt,f_exp,talking_about_count,diff_talking from facebook $where });
	$sth->execute();
	$startno = 1 unless($startno);
	my $no = $startno;
	while(my @row = $sth->fetchrow_array) {
		$listcnt++;
		my $star_str = &_star_img($row[5]);
		my $facebook = qq{<div>};

		$facebook .= qq{</div>};

		my $facebook = qq{<a href="/facebook$row[0]/" target="_blank"><img src="/img/facebook_like.png" width="80"></a>};
		my $twitter;
		my $category_name;

		my $sth2 = $dbh->prepare(qq{select id, name from facebook_category where id = ?});
		$sth2->execute($row[4]);
		while(my @row2 = $sth2->fetchrow_array) {
			$category_name = qq{カテゴリ：<a href="$list_str/category-$row2[0]-1/">$row2[1]のfacebookページ</a>};
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
		$list .= qq{<td><img src="$row[1]" width=100 alt="$row[3]"></td>\n};
		$list .= qq{<td><h3><a href="/facebook$row[0]/">$row[3]</a></h3>};

		$list .= qq{$star_str<br />$category_name<br />\n};
		if($exp_str){
			$list .= qq{<div class="well">$exp_str <a href="/facebook$row[0]/">...続きを見る</a></div></td>\n};
		}else{
			$list .= qq{</td>\n};
		}
		if($diff_flag){
			$list .= qq{<td align="right" width=15%>$like_str<br />(<font color="#FF0000">+$like_diff_str</font>)</td>\n};
		}else{
			$list .= qq{<td align="right" width=15%>$like_str</td>\n};
		}

		$list .= qq{<td align="right" width=15% >$talking_about_count</td>\n};
		$list .= qq{</tr>\n};
		$no++;

	}
	$list .= qq{</tbody>\n};
	$list .= qq{</table>\n};
print "$where: $no\n";

	$list = undef unless($listcnt);
	
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
	
my $file = qq{/var/www/vhosts/goo.to/etc/makehtml/facebook/tmpl/$tmpl};
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

sub _tab_set(){
	my $html = shift;
	my $tmpl = shift;
	my $tabs;

	my $activ_new;
	$activ_new = qq{ class="active"} if($tmpl eq "new.html");
	my $activ_pop;
	$activ_pop = qq{ class="active"} if($tmpl eq "pop.html");
	my $activ_celebrity;
	$activ_celebrity = qq{ class="active"} if($tmpl eq "celebrity.html");
	my $activ_ranking;
	$activ_ranking = qq{ class="active"} if($tmpl eq "ranking.html");
	my $activ_now;
	$activ_now = qq{ class="active"} if($tmpl eq "now.html");
	my $activ_category;
	$activ_category = qq{ class="active"} if($tmpl eq "category.html");
	my $activ_facebooksite;
	$activ_facebooksite = qq{ class="active"} if($tmpl eq "facebooksite.html");

	my $geinou = &html_mojibake_str("geinou");
	my $kyujosho = &html_mojibake_str("kyujosho");
	$tabs .= qq{<div class="container-fluid">\n};
	$tabs .= qq{<ul class="tabs">\n};
	$tabs .= qq{<li$activ_new><a href="<!--LISTSTR-->/new-1/">新着facebook㌻</a></li>\n};
	$tabs .= qq{<li$activ_ranking><a href="<!--LISTSTR-->/ranking-1/">いいね！数ランキング</a></li>\n};
	$tabs .= qq{<li$activ_pop><a href="<!--LISTSTR-->/pop-1/">シェア数ランキング</a></li>\n};
	$tabs .= qq{<li$activ_celebrity><a href="<!--LISTSTR-->/celebrity-1/">有名人/$geinou人facebook㌻</a></li>\n};
	$tabs .= qq{<li$activ_now><a href="<!--LISTSTR-->/now-1/">$kyujosho}.qq{facebook㌻</a></li>\n};
	$tabs .= qq{<li$activ_category><a href="<!--LISTSTR-->/category-0-1/">カテゴリ別facebook㌻</a></li>\n};
	$tabs .= qq{<li$activ_facebooksite><a href="<!--LISTSTR-->/facebooksite.html">facebook総合サイト</a></li>\n};
	$tabs .= qq{</ul>\n};
	$tabs .= qq{</div>\n};

	$html =~s/<!--TABS-->/$tabs/gi;
	return $html;
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
	$str = qq{<img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">};
	if($point >= 100000){
		$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png">};
	}elsif($point >= 80000){
		$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-half.png">};
	}elsif($point >= 50000){
		$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-off.png">};
	}elsif($point >= 30000){
		$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-half.png"><img src="/img/star-off.png">};
	}elsif($point >= 10000){
		$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-off.png"><img src="/img/star-off.png">};
	}elsif($point >= 8000){
		$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-half.png"><img src="/img/star-off.png"><img src="/img/star-off.png">};
	}elsif($point >= 5000){
		$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">};
	}elsif($point >= 3000){
		$str = qq{<img src="/img/star-on.png"><img src="/img/star-half.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">};
	}elsif($point >= 1000){
		$str = qq{<img src="/img/star-on.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">};
	}elsif($point >= 800){
		$str = qq{<img src="/img/star-half.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">};
	}elsif($point >= 500){
		$str = qq{<img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">};
	}
	return $str;
}


