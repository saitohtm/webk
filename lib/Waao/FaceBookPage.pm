package Waao::FaceBookPage;

use lib qw(/var/www/vhosts/goo.to/etc/lib /var/www/vhosts/goo.to/lib/Waao);
use DBI;
use CGI;
use Utility;
use Cache::Memcached;
use Date::Simple;

sub dispatch(){
	my $self = shift;

	my $page = $self->{cgi}->param('page');
	if($self->{cgi}->param('batch')){
		&_page_make($self);
		return;
	}
	if($page <= 30){
		&_page($self);
		return;
	}
	&_page_make($self);
	
	return;
}

sub _page(){
	my $self = shift;

	my $page = $self->{cgi}->param('page');
	my $type = $self->{cgi}->param('type');
	my $genre = $self->{cgi}->param('genre');
	my $list = $self->{cgi}->param('list');

	my $file;
	if($list){
		if($genre){
			$file = qq{/var/www/vhosts/goo.to/httpdocs-facebook/list/$type/$genre/$page}.qq{.html};
		}else{
			$file = qq{/var/www/vhosts/goo.to/httpdocs-facebook/list/$type/$page}.qq{.html};
		}
	}elsif($genre){
		$file = qq{/var/www/vhosts/goo.to/httpdocs-facebook/$type/$genre/$page}.qq{.html};
	}else{
		$file = qq{/var/www/vhosts/goo.to/httpdocs-facebook/$type/$page}.qq{.html};
	}
	
my $fh;
my $filedata;
open( $fh, "<", $file );
while( my $line = readline $fh ){ 
	$filedata .= $line;
}
close ( $fh );


print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$filedata
END_OF_HTML
	
	return;
}

sub _page_make(){
	my $self = shift;

	my $page = $self->{cgi}->param('page');
	my $type = $self->{cgi}->param('type');
	my $genre = $self->{cgi}->param('genre');
	my $list = $self->{cgi}->param('list');
	
	my $tmpl = qq{$type}.qq{.html};

	my $html = &_load_tmpl($tmpl);
	$html =~s/<!--PAGE-->/$page/g;
	$html = &_parts_set($html);
	
	my $pagemax = 15;
	my $start =  0 + ($pagemax * ($page - 1));

	my $list;
	
	if($type eq "new"){
		$list = &_make_list_juge($self, qq{ group by name order by id desc limit $start, $pagemax } ,$start);
	}elsif($type eq "person"){
		my ($meikanname, $sql_str) = &_meikan_name($genre);
		$html =~s/<!--MAIKANNAME-->/$meikanname/g;
		$html =~s/<!--MEIKAN-->/$meikantype/g;

		$list = &_make_list_juge($self, qq{ where person_type = $meikantype order by likecnt desc limit $start, $pagemax } ,$start);
	}elsif($type eq "celebrity"){
		$list = &_make_list_juge($self, qq{  where category_id between 103 and 125 group by name order by likecnt desc limit $start, $pagemax } ,$start);
	}elsif($type eq "category"){
		$list = &_make_list_juge($self, qq{  where category_id = $genre group by name order by likecnt desc limit $start, $pagemax } ,$start);
	}elsif($type eq "now"){
		$list = &_make_list_juge($self, qq{  group by name order by diff_cnt desc limit $start, $pagemax } ,$start);
	}elsif($type eq "pop"){
		$list = &_make_list_juge($self, qq{  group by name order by talking_about_count desc limit $start, $pagemax } ,$start);
	}elsif($type eq "ranking"){
		$list = &_make_list_juge($self, qq{  group by name order by likecnt desc limit $start, $pagemax } ,$start);
	}

	$html =~s/<!--LIST-->/$list/g;

	my $pager .= &_pager($page,"$type");
	$html =~s/<!--PAGER-->/$pager/g;

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

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

sub _pager(){
	my $page = shift;
	my $type = shift;
	my $listflag = shift;
	my $pagelist;

	my $liststr;
	$liststr = qq{-list} if($listflag);

	$pagelist .= qq{<div class="pagination">\n};
	$pagelist .= qq{<ul>\n};
	if($page == 1){
	   	$pagelist .= qq{<li class="prev disabled"><a href="/$type/1$liststr/">&larr; Previous</a></li>\n};
	}else{
		my $preno = $page - 1;
	   	$pagelist .= qq{<li class="prev"><a href="/$type/$preno$liststr/">&larr; Previous</a></li>\n};
	}
	my $pageno;
	for(my $i=0; $i<10; $i++){
		$pageno = $page + $i;
		if($page eq $pageno){
		    $pagelist .= qq{<li class="active"><a href="/$type/$pageno$liststr/">$pageno</a></li>\n};
		}else{
		    $pagelist .= qq{<li><a href="/$type/$pageno$liststr/">$pageno</a></li>\n};
		}
	}
	$pageno++;
	my $page_next = $page + 1;
    $pagelist .= qq{<li class="next"><a href="/$type/$page_next$liststr/">Next &rarr;</a></li>\n};
    $pagelist .= qq{</ul>\n};
    $pagelist .= qq{</div>\n};

	return $pagelist;
}

sub _make_list_juge(){
	my $self = shift;
	my $where = shift;
	my $startno = shift;
	my $diff_flag = shift;

	my $list;
	if($self->{cgi}->param('list')){
		$list = &_make_list2($self, $where ,$startno);
	}else{
		$list = &_make_list($self, $where ,$startno);
	}

	return $list;
}

sub _make_list(){
	my $self = shift;
	my $where = shift;
	my $startno = shift;
	my $diff_flag = shift;

	my $page = $self->{cgi}->param('page');
	my $type = $self->{cgi}->param('type');
	my $genre = $self->{cgi}->param('genre');
	my $list = $self->{cgi}->param('list');

	my $base_dir;
	if($list){
		$base_dir .= qq{/$type/$page/facebook-};
	}else{
		$base_dir .= qq{/$type/$page}.qq{-list/facebook-};
	}
	my $dbh = $self->{dbi};
	
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
		my $facebook = qq{<a href="$base_dir$row[0]/" target="_blank"><img src="/img/facebook_like.png" width="80"></a>};
		my $twitter;
		my $category_name;

		my $sth2 = $dbh->prepare(qq{select id, name from facebook_category where id = ?});
		$sth2->execute($row[4]);
		while(my @row2 = $sth2->fetchrow_array) {
			$category_name = qq{カテゴリ：<a href="/category-$row2[0]/1/">$row2[1]</a>};
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
		$list .= qq{<a href="$base_dir$row[0]/"><img src="$row[1]" width="200" alt="$row[3]" class="example1" /></a>\n};
		$list .= qq{<br />$exp_str <a href="$base_dir$row[0]/">...続きを見る</a></p>\n} if($exp_str);
		$list .= qq{</div>\n};
		$no++;

	}
	$list .= qq{</div>\n};

	$list = undef unless($listcnt);

	return $list;
}

sub _make_list2(){
	my $self = shift;
	my $where = shift;
	my $startno = shift;
	my $diff_flag = shift;

	my $page = $self->{cgi}->param('page');
	my $type = $self->{cgi}->param('type');
	my $genre = $self->{cgi}->param('genre');
	my $list = $self->{cgi}->param('list');

	my $base_dir;
	if($list){
		$base_dir .= qq{/$type/$page/facebook-};
	}else{
		$base_dir .= qq{/$type/$page}.qq{-list/facebook-};
	}
	my $dbh = $self->{dbi};


	my $list_str = qq{-list};

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

		my $facebook = qq{<a href="$base_dir$row[0]/" target="_blank"><img src="/img/facebook_like.png" width="80"></a>};
		my $twitter;
		my $category_name;

		my $sth2 = $dbh->prepare(qq{select id, name from facebook_category where id = ?});
		$sth2->execute($row[4]);
		while(my @row2 = $sth2->fetchrow_array) {
			$category_name = qq{カテゴリ：<a href="/category-$row2[0]/1$list_str/">$row2[1]のfacebookページ</a>};
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
		$list .= qq{<td><h3><a href="$base_dir$row[0]/">$row[3]</a></h3>};

		$list .= qq{$star_str<br />$category_name<br />\n};
		if($exp_str){
			$list .= qq{<div class="well">$exp_str <a href="$base_dir$row[0]/">...続きを見る</a></div></td>\n};
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

	$list = undef unless($listcnt);
	
	return $list;
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
		my $list_str = qq{-list};
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

sub new(){
	my $class = shift;
	my $q = new CGI;

	my $self={
			'mem' => &_mem_connect(),
			'dbi' => &_db_connect(),
			'cgi' => $q
			};
	
	return bless $self, $class;
}

# memcached connect
sub _mem_connect(){

	my $memd = new Cache::Memcached {
    'servers' => [ "localhost:11211" ],
    'debug' => 0,
    'compress_threshold' => 1_000,
	};

	return $memd;
}

# db connect
sub _db_connect(){
    my $dsn = 'DBI:mysql:waao';
    my $user = 'mysqlweb';
    my $password = 'WaAoqzxe7h6yyHz';

    my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 0, AutoCommit => 1, PrintError => 0});
	
	return $dbh;
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

sub price_dsp(){
	my $price = shift;

	1 while $price =~ s/(.*\d)(\d\d\d)/$1,$2/;	

	return $price;
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
	$tabs .= qq{<li$activ_new><a href="/new/1<!--LISTSTR-->/">新着facebook㌻</a></li>\n};
	$tabs .= qq{<li$activ_ranking><a href="/ranking/1<!--LISTSTR-->/">いいね！数ランキング</a></li>\n};
	$tabs .= qq{<li$activ_pop><a href="/pop/1<!--LISTSTR-->/">シェア数ランキング</a></li>\n};
	$tabs .= qq{<li$activ_celebrity><a href="/celebrity/1<!--LISTSTR-->/">有名人/$geinou人facebook㌻</a></li>\n};
	$tabs .= qq{<li$activ_now><a href="/now/1<!--LISTSTR-->/">$kyujosho}.qq{facebook㌻</a></li>\n};
	$tabs .= qq{<li$activ_category><a href="/category-0/1<!--LISTSTR-->/">カテゴリ別facebook㌻</a></li>\n};
	$tabs .= qq{<li$activ_facebooksite><a href="/facebooksite.html">facebook総合サイト</a></li>\n};
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

sub DESTROY{
	my $self = shift;

	$self->{db}->disconnect if($self->{db});

	return;
}


1;