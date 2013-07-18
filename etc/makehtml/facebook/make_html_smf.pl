#!/usr/bin/perl
# facebookページ作成処理
use lib qw(/var/www/vhosts/goo.to/etc/lib /var/www/vhosts/goo.to/lib/Waao);

use strict;
use DBI;
use Utility;
use Date::Simple;
use LWP::UserAgent;

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

# top
&_top();

#&_get_page("ranking","ranking");
&_get_page("celebrity","celebrity");
&_get_page("new","new");
&_get_page("now","now");
&_get_page("pop","pop");

&_get_page("category-","category");

&_get_page("person-","person");

exit;

sub _get_page(){
	my $dir = shift;
	my $type = shift;

	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-facebook/smf/list/};
	mkdir($dirname, 0755);

	my $dbh = &_db_connect();

	for(my $i=1;$i<=30;$i++){
		if($type eq "category"){
			my $sth = $dbh->prepare(qq{select id, name from facebook_category});
			$sth->execute();
			while(my @row = $sth->fetchrow_array) {
				&_get_page_detail($dir,$type,$row[0],$i);
				&_get_page_detail($dir,$type,$row[0],$i,1);
			}
		}elsif($type eq "person"){
			for(my $genre=1;$genre<=15;$genre++){
				&_get_page_detail($dir,$type,$genre,$i);
				&_get_page_detail($dir,$type,$genre,$i,1);
			}
		}else{
			&_get_page_detail($dir,$type,"",$i);
			&_get_page_detail($dir,$type,"",$i,1);
		}
	}
	$dbh->disconnect;

	return;
}

sub _get_page_detail(){
	my $dir = shift;
	my $type = shift;
	my $genre = shift;
	my $page = shift;
	my $list = shift;
	
	my $html;
	my $url = qq{http://facebook.webk-vps.com/pagesmf.htm?type=$type&genre=$genre&page=$page&list=$list&batch=1};
print $url."\n";
	my $ua = new LWP::UserAgent();
	$ua->timeout(3);
	$ua->agent("Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_2_1 like Mac OS X; ja-jp) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8C148 Safari/6533.18.5"); 
	my $request = HTTP::Request->new(GET =>"$url");
	my $res = $ua->request($request);
	unless ($res->is_success) {
		return;
	}else{
		$html = $res->content;
	}

	my $filename;
	
	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-facebook/smf/$type/};
	mkdir($dirname, 0755);
	if($type eq "category"){
		my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-facebook/smf/$type/$genre/};
		mkdir($dirname, 0755);
		$filename = qq{/var/www/vhosts/goo.to/httpdocs-facebook/smf/$type/$genre/$page.html};
	}elsif($type eq "person"){
		my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-facebook/smf/$type/$genre/};
		mkdir($dirname, 0755);
		$filename = qq{/var/www/vhosts/goo.to/httpdocs-facebook/smf/$type/$genre/$page.html};
	}else{
		$filename = qq{/var/www/vhosts/goo.to/httpdocs-facebook/smf/$type/$page.html};
	}

	if($list){
		my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-facebook/smf/list/$type/};
		mkdir($dirname, 0755);
		if($type eq "category"){
			my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-facebook/smf/list/$type/$genre/};
			mkdir($dirname, 0755);
			$filename = qq{/var/www/vhosts/goo.to/httpdocs-facebook/smf/list/$type/$genre/$page.html};
		}elsif($type eq "person"){
			my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-facebook/smf/list/$type/$genre/};
			mkdir($dirname, 0755);
			$filename = qq{/var/www/vhosts/goo.to/httpdocs-facebook/smf/list/$type/$genre/$page.html};
		}else{
			$filename = qq{/var/www/vhosts/goo.to/httpdocs-facebook/smf/list/$type/$page.html};
		}
	}

print $filename."\n";

	open(OUT,"> $filename") || die('error');
	print OUT "$html";
	close(OUT);
	print $filename."\n";


	return;
}



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





sub _else_pages(){

my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-facebook/smf/facebookranking/};
mkdir($dirname, 0755);
my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-facebook/smf/privacy/};
mkdir($dirname, 0755);
my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-facebook/smf/manage/};
mkdir($dirname, 0755);
my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-facebook/smf/legal/};
mkdir($dirname, 0755);

	my $html = &_load_tmpl_smf("facebookranking.html");
	$html = &_parts_set($html);
	&_file_output("/var/www/vhosts/goo.to/httpdocs-facebook/smf/facebookranking/index.html",$html);

	my $html = &_load_tmpl_smf("privacy.html");
	$html = &_parts_set($html);
	&_file_output("/var/www/vhosts/goo.to/httpdocs-facebook/smf/privacy/index.html",$html);

	my $html = &_load_tmpl_smf("manage.html");
	$html = &_parts_set($html);
	&_file_output("/var/www/vhosts/goo.to/httpdocs-facebook/smf/manage/index.html",$html);

	my $html = &_load_tmpl_smf("legal.html");
	$html = &_parts_set($html);
	&_file_output("/var/www/vhosts/goo.to/httpdocs-facebook/smf/legal/index.html",$html);

	return;
}

sub _header_make(){
	my $html = &_load_tmpl_smf("header_tmp.html");

	my $dbh = &_db_connect();
	my $sth = $dbh->prepare(qq{select count(*) as total from facebook });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my $total = &price_dsp($row[0]);
		$html =~s/<!--TOTAL-->/$total/g;
	}
	$dbh->disconnect;


	&_file_output("/var/www/vhosts/goo.to/etc/makehtml/facebook/tmpl_smf/header.html",$html);
	return;
}

sub _cate_slide_list(){

	my $dbh = &_db_connect();

	my $list;
	$list .= qq{<div class="well">\n};
	$list .= qq{<h3>カテゴリ</h3>\n};

	my $sth = $dbh->prepare(qq{select id, name from facebook_category where pid = 0 order by id });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$list .= qq{<a href="/category-$row[0]-1/">$row[1]</a><br />\n};
	}
	$list .= qq{</div>\n};

	&_file_output("/var/www/vhosts/goo.to/etc/makehtml/facebook/tmpl_smf/slider_category.html",$list);

	$dbh->disconnect;

	return;
}


sub _category(){
	my $self = shift;

	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-facebook/smf/category/};
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

	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-facebook/smf/category/$category_id/};
	mkdir($dirname, 0755);

	return if($page >= 30000);

	my $html;
#	if($category_id eq 0){
#		$html = &_load_tmpl_smf("category_top.html");
#	}else{
		$html = &_load_tmpl_smf("category.html");
#	}
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
		$category_list .= qq{<li><a href="/smf/category-$row[0]-1/">$row[1]</a></li>};
	}
#	$category_list = qq{<br />▼カテゴリを選択<br />$category_list<br /><br />} if($category_list);
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
		&_file_output("/var/www/vhosts/goo.to/httpdocs-facebook/smf/category/$category_id/$page.html",$html);
		$page++;
		&_category_detaile($dbh,$page,$category_id );
	}else{
		&_file_output("/var/www/vhosts/goo.to/httpdocs-facebook/smf/category/$category_id/$page.html",$html);
	}
	return;
}



sub _celebrity(){
	my $self = shift;

	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-facebook/smf/celebrity/};
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
	
	my $html = &_load_tmpl_smf("celebrity.html");
	$html = &_parts_set($html);
	$html =~s/<!--PAGE-->/$page/g;

	my $pagemax = 50;
	my $start = 0 + ($pagemax * ($page - 1));
	my $list = &_make_list($dbh, " where category_id between 103 and 125 group by name order by likecnt desc limit $start, $pagemax ", $start);
	$html =~s/<!--LIST-->/$list/g;
	my $pager .= &_pager($page,"celebrity");
	$html =~s/<!--PAGER-->/$pager/g;

	if($list){
		&_file_output("/var/www/vhosts/goo.to/httpdocs-facebook/smf/celebrity/$page.html",$html);
		$page++;
		&_celebrity_detaile($dbh,$page);
	}

	return;
}

sub _new(){
	my $self = shift;

	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-facebook/smf/new/};
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
	
	my $html = &_load_tmpl_smf("new.html");
	$html = &_parts_set($html);
	$html =~s/<!--PAGE-->/$page/g;

	my $pagemax = 50;
	my $start = 0 + ($pagemax * ($page - 1));
	my $list = &_make_list($dbh, " group by name order by id desc limit $start, $pagemax ", $start);
	$html =~s/<!--LIST-->/$list/g;
	my $pager .= &_pager($page,"new");
	$html =~s/<!--PAGER-->/$pager/g;

	if($list){
		&_file_output("/var/www/vhosts/goo.to/httpdocs-facebook/smf/new/$page.html",$html);
		$page++;
		&_new_detaile($dbh,$page);
	}

	return;
}


sub _now(){
	my $self = shift;

	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-facebook/smf/now/};
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
	
	my $html = &_load_tmpl_smf("now.html");
	$html = &_parts_set($html);
	$html =~s/<!--PAGE-->/$page/g;

	my $pagemax = 50;
	my $start = 0 + ($pagemax * ($page - 1));
	my $list = &_make_list($dbh, " group by name order by diff_cnt desc limit $start, $pagemax ", $start);
	$html =~s/<!--LIST-->/$list/g;
	my $pager .= &_pager($page,"now");
	$html =~s/<!--PAGER-->/$pager/g;

	if($list){
		&_file_output("/var/www/vhosts/goo.to/httpdocs-facebook/smf/now/$page.html",$html);
		$page++;
		&_now_detaile($dbh,$page);
	}

	return;
}

sub _ranking(){
	my $self = shift;

	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-facebook/smf/ranking/};
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
	
	my $html = &_load_tmpl_smf("ranking.html");
	$html = &_parts_set($html);
	$html =~s/<!--PAGE-->/$page/g;

	my $pagemax = 50;
	my $start = 0 + ($pagemax * ($page - 1));
	my $list = &_make_list($dbh, " group by name order by likecnt desc limit $start, $pagemax ", $start);
	$html =~s/<!--LIST-->/$list/g;
	my $pager .= &_pager($page,"ranking");
	$html =~s/<!--PAGER-->/$pager/g;

	if($list){
		&_file_output("/var/www/vhosts/goo.to/httpdocs-facebook/smf/ranking/$page.html",$html);
		$page++;
		&_ranking_detaile($dbh,$page);
	}

	return;
}

sub _top(){


	my $dbh = &_db_connect();

	# main
	my $html = &_load_tmpl_smf("top.html");
	$html = &_parts_set($html);

	
	# 新着
	my $list;
	$list = &_make_list($dbh, " order by likecnt desc limit 5 ");
	$html =~s/<!--LIST-->/$list/g;
	my $pager .= &_pager(1,"now");
	$html =~s/<!--PAGENATION-->/$pager/g;

	$dbh->disconnect;

	&_file_output("/var/www/vhosts/goo.to/httpdocs-facebook/smf/index.html",$html);
	return;
}

sub _parts_set(){
	my $html = shift;

	my $header = &_load_tmpl_smf("header.html");
	my $ad_header = &_load_tmpl_smf("ad_header.html");
	# footer
	my $footer = &_load_tmpl_smf("footer.html");

	$html =~s/<!--HEADER-->/$header/g;
	$html =~s/<!--AD_HEADER-->/$ad_header/g;
	$html =~s/<!--FOOTER-->/$footer/g;

	return $html;
}

sub _pager(){
	my $page = shift;
	my $type = shift;

	my $pagelist;

	my $next_page = $page + 1;
    $pagelist .= qq{<div aligne=right><a href="/smf/$type-$next_page/" data-role="button" data-inline="true">次へ</a></div>\n};
	return $pagelist;

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
    $pagelist .= qq{<li class="next"><a href="/$type-$pageno/">Next &rarr;</a></li>\n};
    $pagelist .= qq{</ul>\n};
    $pagelist .= qq{</div>\n};

	return $pagelist;
}

sub _make_list(){
	my $dbh = shift;
	my $where = shift;
	my $startno = shift;

	my $list;
	my $sth = $dbh->prepare(qq{select id, img, url, name, category_id, likecnt, diff_cnt,talking_about_count from facebook $where });
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
			$category_name = qq{$row2[1]};
		}

		my $like_str = &price_dsp($row[5]);
		my $like_diff_str = &price_dsp($row[6]);
		my $talking_about_count = &price_dsp($row[7]);

		$list .=qq{<li><a href="/smf/facebook$row[0]/"><img src="$row[1]" alt="$row[3]"><h3>$no.$row[3]</h3><p>$star_str $category_name<br />いいね！：$like_str シェア：$talking_about_count</p></a></li>\n};

		$no++;
	}
print "$where: $no\n";

	
	return $list;
}

sub _file_output(){
	my $filename = shift;
	my $html = shift;
print "$filename\n";	
	open(OUT,"> $filename") || die('error');
	print OUT "$html";
	close(OUT);

	return;
}


sub _load_tmpl_smf(){
	my $tmpl_smf = shift;
	
my $file = qq{/var/www/vhosts/goo.to/etc/makehtml/facebook/tmpl_smf/$tmpl_smf};
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


