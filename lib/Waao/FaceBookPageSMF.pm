package Waao::FaceBookPageSMF;

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
	}elsif($page <= 30){
		&_page($self);
	}else{
		&_page_make($self);
	}
		
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
			$file = qq{/var/www/vhosts/goo.to/httpdocs-facebook/smf/list/$type/$genre/$page}.qq{.html};
		}else{
			$file = qq{/var/www/vhosts/goo.to/httpdocs-facebook/smf/list/$type/$page}.qq{.html};
		}
	}elsif($genre){
		$file = qq{/var/www/vhosts/goo.to/httpdocs-facebook/smf/$type/$genre/$page}.qq{.html};
	}else{
		$file = qq{/var/www/vhosts/goo.to/httpdocs-facebook/smf/$type/$page}.qq{.html};
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

END_OF_HTML

print $html;

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

	my $list;
	my $sth = $self->{dbi}->prepare(qq{select id, img, url, name, category_id, likecnt, diff_cnt,talking_about_count from facebook $where });
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

		my $sth2 = $self->{dbi}->prepare(qq{select id, name from facebook_category where id = ?});
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

sub _make_list2(){
	my $self = shift;
	my $where = shift;
	my $startno = shift;

	my $list;
	my $sth = $self->{dbi}->prepare(qq{select id, img, url, name, category_id, likecnt, diff_cnt,talking_about_count from facebook $where });
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

		my $sth2 = $self->{dbi}->prepare(qq{select id, name from facebook_category where id = ?});
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

sub _parts_set(){
	my $html = shift;
	my $flag = shift;

	my $header = &_load_tmpl("header.html");
	my $ad_header = &_load_tmpl("ad_header.html");
	# footer
	my $footer = &_load_tmpl("footer.html");

	$html =~s/<!--HEADER-->/$header/g;
	$html =~s/<!--AD_HEADER-->/$ad_header/g;
	$html =~s/<!--FOOTER-->/$footer/g;

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

my $file = qq{/var/www/vhosts/goo.to/etc/makehtml/facebook/tmpl_smf/$tmpl};
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