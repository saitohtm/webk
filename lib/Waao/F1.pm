package Waao::F1;

use DBI;
use CGI;
use Jcode;
use Cache::Memcached;
use CGI qw( escape );
use Date::Simple;

sub dispatch_smf(){
	my $self = shift;

	if($self->{cgi}->param('newsid')){
		&_news($self);
	}elsif($self->{cgi}->param('driversid')){
		&_driver($self);
	}

	return;
}

sub _driver(){
	my $self = shift;

	my $driversid = $self->{cgi}->param('driversid');

	my ($name, $team, $point);
	
	my $sth = $self->{dbi}->prepare(qq{ select name, team, point from race_driver where id = ? });
	$sth->execute($driversid);
	while(my @row = $sth->fetchrow_array) {
		($name, $team, $point) = @row;
	}

	my $html = &_load_tmpl("/tmpl_smf/driver.html");
	$html = &_parts_set($html);

	$html =~s/<!--NAME-->/$name/g;
	$html =~s/<!--TEAM-->/$team/g;
	$html =~s/<!--DRIVER-->/$driver/g;

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}

sub _news(){
	my $self = shift;

	my $newsid = $self->{cgi}->param('newsid');
	
	my ($title, $datestr, $bodystr, $geturl, $category, $body);
	my $sth = $self->{dbi}->prepare(qq{ select title, datestr, body, geturl, category, body from race_rss where id = ? limit 1});
	$sth->execute($self->{cgi}->param('newsid'));
	while(my @row = $sth->fetchrow_array) {
		($title, $datestr, $bodystr, $geturl, $category, $body) = @row;
	}

	my $newstopics;
	$sth = $self->{dbi}->prepare(qq{ select title, id from race_rss where id < ? order by id desc limit 5});
	$sth->execute($self->{cgi}->param('newsid'));
	while(my @row = $sth->fetchrow_array) {
		$newstopics .= qq{<li><a href="/f1-news/$row[1]/">$row[0]</a></li>};
	}
	
	my $html = &_load_tmpl("/tmpl_smf/news.html");
	$html = &_parts_set($html);
	
	$html =~s/<!--TITLE-->/$title/g;
	$html =~s/<!--DATESTR-->/$datestr/g;
	$html =~s/<!--NEWS-->/$body/g;
	$html =~s/<!--URL-->/$geturl/g;
	
	$html =~s/<!--NEWSTOPICS-->/$newstopics/g;

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}

sub _parts_set(){
	my $html = shift;

	my $menu = &_load_tmpl("/tmpl_smf/menu.html");
	$html =~s/<!--F1MENU-->/$menu/g;

	my $footer = &_load_tmpl("/tmpl_smf/footer.html");
	$html =~s/<!--FOOTER-->/$footer/g;

	# meta
#	my $meta = &_load_tmpl("meta.html");
	# header
#	my $header = &_load_tmpl("header.html");
	# footer
#	my $footer = &_load_tmpl("footer.html");
	# slider
#	my $side_free = &_load_tmpl("side_free.html");
#	$html =~s/<!--SIDE_FREE-->/$side_free/g;
#	my $catelist = &_load_tmpl("cate_list.html");
#	$html =~s/<!--CATELIST-->/$catelist/g;

#	$html =~s/<!--META-->/$meta/g;
#	$html =~s/<!--HEADER-->/$header/g;
#	$html =~s/<!--FOOTER-->/$footer/g;

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
	
my $file = qq{/var/www/vhosts/waao.jp/etc/motorsports/$tmpl};
my $fh;
my $filedata;
open( $fh, "<", $file );
while( my $line = readline $fh ){ 
	$filedata .= $line;
}
close ( $fh );

	return $filedata;
}

sub price_dsp(){
	my $price = shift;

	1 while $price =~ s/(.*\d)(\d\d\d)/$1,$2/;	

	return $price;
}


sub _star_img(){
	my $point = shift;
	
	my $str;
	$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif">} if($point eq "5.0");
	$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star_half.gif">} if($point eq "4.5");
	$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star_off.gif">} if($point eq "4.0");
	$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star_half.gif"><img src="/img/review_all_star_off.gif">} if($point eq "3.5");
	$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif">} if($point eq "3.0");
	$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star_half.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif">} if($point eq "2.5");
	$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif">} if($point eq "2.0");
	$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star_half.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif">} if($point eq "1.5");
	$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif">} if($point eq "1.0");
	$str = qq{<img src="/img/review_all_star_half.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif">} if($point eq "0.5");
	$str = qq{<img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif">} if($point eq "0");

	return $str;
}

sub DESTROY{
	my $self = shift;

	$self->{db}->disconnect if($self->{db});

	return;
}

sub dispatch_fmfm_regist(){
	my $self = shift;

	if($self->{cgi}->param('url')){
		&_fmfm_check($self);
	}elsif($self->{cgi}->param('title')){
		&_fmfm_regist($self);
	}else{
		&_fmfm_regist_top($self);
	}

	return;
}

sub _fmfm_check(){
	my $self = shift;
	my $html;
	$html = &_load_tmpl("fmfm_regist_check.html");
	$html = &_parts_set($html);
	
	my $url = $self->{cgi}->param('url');

	my $get_url = `GET "$url"`;
	my @lines = split(/\n/,$get_url);
my $title;
	my $ut8;
	foreach my $line (@lines){
		if($line=~/utf-8/i){
			$utf=1;
		}
		if($line=~/utf8/i){
			$utf=1;
		}
		if($line=~/(.*)title>(.*)<\/title(.*)/i){
			$title = $2;
			if($utf){
				$title = Jcode->new($title, 'utf8')->sjis;
			}
		}
	}
	$html =~s/<!--URL-->/$url/g;
	$html =~s/<!--TITLE-->/$title/g;

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}

sub _fmfm_regist(){
	my $self = shift;

	my $html;
	$html = &_load_tmpl("fmfm_regist_end.html");
	$html = &_parts_set($html);
	
	my $date = Date::Simple->new();
	my $ymd = $date->format('%Y/%m/%d');

eval{
	my $sth = $self->{dbi}->prepare(qq{insert into fmfm (`url`,`title`,`type`,`date`,`moto`) values(?,?,?,?,?)});
	$sth->execute($self->{cgi}->param('tmp_url'),$self->{cgi}->param('title'),$self->{cgi}->param('newstype'),$ymd,$self->{cgi}->param('moto'));
};
	
print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}

sub _fmfm_regist_top(){
	my $self = shift;

	my $html;
	$html = &_load_tmpl("fmfm_regist.html");
	$html = &_parts_set($html);

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}

sub dispatch_rd(){
	my $self = shift;

	my $id = $self->{cgi}->param('id');

	my $sth = $self->{dbi}->prepare(qq{select `url` from fmfm where id = ? });	 
	$sth->execute($id);
	my $url;
	while(my @row = $sth->fetchrow_array) {
		$url = $row[0];
	}
eval{
	my $sth = $self->{dbi}->prepare(qq{update fmfm set cnt = cnt + 1 where id = ? limit 1 });	 
	$sth->execute($id);
};	
	print qq{Location: $url\n\n};
	return;
}

sub _socialnews_date(){
	my $self = shift;
	my $date = $self->{cgi}->param('date');
	my $html;
	$html = &_load_tmpl("socialnews_date.html");
	$html = &_parts_set($html);

	my $sth = $self->{dbi}->prepare(qq{select id,url,title,type,date,cnt from fmfm where type >= 5 and type < 10 and date = ? order by id desc });	 
	$sth->execute($date);
	my $list;
	while(my @row = $sth->fetchrow_array) {
		my $typename;
		if($type eq 5){
			$typename = qq{アプリ関連};
		}elsif($type eq 6){
			$typename = qq{ソーシャルゲーム関連};
		}else{
			$typename = qq{値下げセール関連};
		}
		$list .= qq{<tr>};
		$list .= qq{<td>$row[2] <br /><a href="$row[1]" target="_blank" ref="nofollow">情報を見る</a></td>};
		$list .= qq{<td>$typename</td>};
		$list .= qq{<td>$row[4]</td>};
		$list .= qq{<td>$row[5]</td>};
		$list .= qq{</tr>};
	}
	$html =~s/<!--DATE-->/$date/g;
	$html =~s/<!--LIST-->/$list/g;

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}

sub _socialnews_list(){
	my $self = shift;

	my $html;
	$html = &_load_tmpl("socialnews.html");
	$html = &_parts_set($html);
	my $page = 0;
	$page = $self->{cgi}->param('page');
	$page = 0 if($page <=0);
	my $pagemax = 50;
	my $start = 0 + ($pagemax * ($page - 1));

	my $sth = $self->{dbi}->prepare(qq{select id,url,title,type,date,cnt from fmfm where type >= 5 and type < 10  order by id desc limit $start,$pagemax});	 
	$sth->execute();
	my $list;
	while(my @row = $sth->fetchrow_array) {
		my $typename;
		if($type eq 5){
			$typename = qq{アプリ関連};
		}elsif($type eq 6){
			$typename = qq{ソーシャルゲーム関連};
		}else{
			$typename = qq{値下げセール関連};
		}
		$list .= qq{<tr>};
		$list .= qq{<td>$row[2] <br /><a href="$row[1]" target="_blank" ref="nofollow">情報を見る</a></td>};
		$list .= qq{<td>$typename</td>};
		my $date = $row[4];
		$list .= qq{<td><a href="/app-topics$date/">$row[4]</a></td>};
		$list .= qq{<td>$row[5]</td>};
		$list .= qq{</tr>};
	}
	my $pager = &_pager($page,"apptopics");
	$html =~s/<!--LIST-->/$list/g;
	$html =~s/<!--PAGER-->/$pager/g;

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}

sub dispatch_socialnews(){
	my $self = shift;

	if($self->{cgi}->param('date')){
		&_socialnews_date($self);
	}else{
		&_socialnews_list($self);
	}

	return;
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

sub dispatch_review_regist(){
	my $self = shift;

	if($self->{cgi}->param('id')){
		&_review_top($self);
	}elsif($self->{cgi}->param('who')){
		&_review($self);
	}else{
	}

	return;
}

sub _review(){
	my $self = shift;

	my $html;
	$html = &_load_tmpl("review_regist_end.html");
	$html = &_parts_set($html);
	my $date = Date::Simple->new();
	my $ymd = $date->format('%Y/%m/%d');


eval{

	my $sth = $self->{dbi}->prepare(qq{insert into app_review (`a_id`,`who`,`mainbody`,`good`,`nickname`,`linkurl`) values(?,?,?,?,?,?)});
	$sth->execute($self->{cgi}->param('a_id'),
	              $self->{cgi}->param('who'),
	              $self->{cgi}->param('mainbody'),
	              $self->{cgi}->param('good'),
	              $self->{cgi}->param('nickname'),
	              $self->{cgi}->param('linkurl')
	              );
};


if($self->{cgi}->param('url')){

eval{
	my $sth = $self->{dbi}->prepare(qq{insert into app_tmp_url (`url`) values(?)});
	$sth->execute($self->{cgi}->param('url'));
};

}	


print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}

sub _review_top(){
	my $self = shift;

	my $html;
	$html = &_load_tmpl("review_regist_check.html");
	$html = &_parts_set($html);

	my $list = qq{<table>};
	my $sth = $self->{dbi}->prepare(qq{select id, img, dl_url, appname, ex_str, device, category, developer, price, sale, rdate, eva, review, rank, saledate from app where id = ? });
	$sth->execute($self->{cgi}->param('id'));
	my $no = $startno;
	while(my @row = $sth->fetchrow_array) {
		$list .= qq{<tr>\n};
		$list .= qq{<td width=10%><span class="rounded-img" style="background: url($row[1]) no-repeat center center; width: 100px; height: 100px;"><a href="/app-$row[0]/" target="_blank"><img src="$row[1]" style="opacity: 0;" alt="無料アプリ $row[2]" /></span></td>\n};
		$list .= qq{<td width=20%><a href="/app-$row[0]/">$row[3]</a><br />$row[10]</td>\n};
		$list .= qq{<td><div class="well">$exp_short</div></td>\n};
		$list .= qq{</tr>\n};
	}
	$list .= qq{</table>};

	$html =~s/<!--LIST-->/$list/g;
    my $id = $self->{cgi}->param('id');
	$html =~s/<!--ID-->/$id/g;

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}


1;