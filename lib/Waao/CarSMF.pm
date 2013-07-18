package Waao::CarSMF;

use DBI;
use CGI;
use Cache::Memcached;
use Jcode;
use CGI qw( escape );
use Date::Simple;

sub dispatch(){
	my $self = shift;

	if($self->{cgi}->param('photo_id')){
		&_photo($self);
	}elsif($self->{cgi}->param('news_id')){
		&_news($self);
	}elsif($self->{cgi}->param('car')){
		&_car_list($self);
	}elsif($self->{cgi}->param('news')){
		&_news_list($self);
	}else{
		&_top($self);
	}

	return;
}

sub _news(){
	my $self = shift;

	return;
}

sub _photo(){
	my $self = shift;
	my $tablename = "car";

	my $html;
	$html = &_load_tmpl("photo.html",$self);

	$html = &_parts_set($html,$self);

	# 画像表示
	if($self->{cgi}->param('good')){
		my $sth = $self->{dbi}->prepare(qq{update $tablename}.qq{_photo set eva = eva + 1 where id = ? limit 1 });
		$sth->execute($self->{cgi}->param('photo_id'));
	}
	if($self->{cgi}->param('bad')){
		my $sth = $self->{dbi}->prepare(qq{update $tablename}.qq{_photo set eva = eva - 1 where id = ? limit 1 });
		$sth->execute($self->{cgi}->param('photo_id'));
	}
	my $list;
	my $sth = $self->{dbi}->prepare(qq{select id,photo,site_id,regist_date,url,eva from $tablename}.qq{_photo where id = ? limit 1 });
	$sth->execute($self->{cgi}->param('photo_id'));
	while(my @row = $sth->fetchrow_array) {
		my ($id,$photo,$site_id,$regist_date,$url,$eva) = @row;

			$html =~s/<!--ID-->/$id/g;
			$html =~s/<!--PHOTO-->/$photo/g;
			$html =~s/<!--SITEID-->/$site_id/g;
			$html =~s/<!--REGISTDATE-->/$regist_date/g;
			$html =~s/<!--URL-->/$url/g;

			my $preid = $id +1;
			my $nextid = $id -1;
			$html =~s/<!--PREID-->/$preid/g;
			$html =~s/<!--NEXTID-->/$nextid/g;
			$eva = 0 if($eva < 1);
			$html =~s/<!--POINT-->/$eva/g;

			$list .= qq{<img src="$photo" width=100%  />};
	}	

	$html =~s/<!--LIST-->/$list/g;

	if($self->{cgi}->param('description')){
		my $sth = $self->{dbi}->prepare(qq{insert into $tablename}.qq{_photo_bbs (photo_id,answer) values(?,?) });
		$sth->execute($self->{cgi}->param('photo_id'),$self->{cgi}->param('description'));
	}
	my $list;
	my $sth = $self->{dbi}->prepare(qq{select answer from $tablename}.qq{_photo_bbs where photo_id = ? limit 1 });
	$sth->execute($self->{cgi}->param('photo_id'));
	while(my @row = $sth->fetchrow_array) {
		$list.=qq{$row[0]<br />};
	}

	$html =~s/<!--COMMENT-->/$list/g;

	&_output($html);
	my $sth = $self->{dbi}->prepare(qq{update $tablename}.qq{_photo set  order by date desc limit 1 });
	$sth->execute($self->{cgi}->param('photo_id'));

	return;
}

sub _news_list(){
	my $self = shift;
	my $html;
	$html = &_load_tmpl("newslist.html",$self);
	$html = &_parts_set($html,$self);

	my $max_cnt = 30;
	my $page = $self->{cgi}->param('page');
	my $start = ($page - 1) * $max_cnt;

	my $newslist;
	my $sth = $self->{dbi}->prepare(qq{select B.id, B.title,B.body,B.url,B.date,B.img,A.name from car_site A, car_topics B where A.id = B.site_id order by B.date desc limit $start,$max_cnt });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my ($id, $title,$body,$url,$date,$img,$name) = @row;
		$newslist.=qq{<li><a href="/smf/news_id=$id">\n};
		$newslist.=qq{<h3><font color="#C0C0C0">$name</font></h3>\n};
		$newslist.=qq{<p><strong>$title</strong></p>\n};
		$newslist.=qq{<p>$body</p>\n};
		$newslist.=qq{<p class="ui-li-aside">$date</p>\n};
		$newslist.=qq{</a></li>\n};
	}	
	$html =~s/<!--NEWSLIST-->/$newslist/g;

	my $nextpage=$page + 1;
	$html =~s/<!--NEXTPAGE-->/$nextpage/g;
	&_output($html);
	return;
}

sub _car_list(){
	my $self = shift;
	my $html;
	$html = &_load_tmpl("photolist.html",$self);
	$html = &_parts_set($html,$self);

	my $max_cnt = 30;
	my $page = $self->{cgi}->param('page');
	my $start = ($page - 1) * $max_cnt;
	# 画像表示
	my $list;
	my $sth = $self->{dbi}->prepare(qq{select id,photo,site_id,regist_date,url from car_photo order by id desc limit $start,$max_cnt });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my ($id,$photo,$site_id,$regist_date,$url) = @row;
			$list .= qq{<div>};
			$list .= qq{<a href="/smf/?photo_id=$id" data-ajax="false"><img src="$photo" width=90 alt="スーパーカー画像" /></a>};
			$list .= qq{</div>};

	}
	$html =~s/<!--LIST-->/$list/g;
	my $nextpage=$page + 1;
	$html =~s/<!--NEXTPAGE-->/$nextpage/g;
	&_output($html);
	return;
}

sub _top(){
	my $self = shift;

	my $html;
	$html = &_load_tmpl("top.html",$self);

	$html = &_parts_set($html,$self);

	# 画像表示
	my $list;
	my $sth = $self->{dbi}->prepare(qq{select id,photo,site_id,regist_date,url from car_photo order by id desc limit 6 });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my ($id,$photo,$site_id,$regist_date,$url) = @row;
			$list .= qq{<div>};
			$list .= qq{<img src="$photo" width=90 alt="スーパーカー画像" />};
			$list .= qq{</div>};

	}
	$html =~s/<!--LIST-->/$list/g;

	# 今日の件数
	my $sth = $self->{dbi}->prepare(qq{select date,cnt,totalcnt from car_photo_log order by date desc limit 1 });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$html =~s/<!--TODAY_P_CNT-->/$row[2]/g;
	}

	# ニュース
	my $datestr;
	my $newslist;
	my $sth = $self->{dbi}->prepare(qq{select B.id, B.title,B.body,B.url,B.date,B.img,A.name from car_site A, car_topics B where A.id = B.site_id order by B.date desc limit 30 });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my ($id, $title,$body,$url,$date,$img,$name) = @row;
		$datestr = $date;
		$newslist.=qq{<li><a href="/smf/?news_id=$id">\n};
		$newslist.=qq{<h3><font color="#C0C0C0">$name</font></h3>\n};
		$newslist.=qq{<p><strong>$title</strong></p>\n};
		$newslist.=qq{<p>$body</p>\n};
		$newslist.=qq{<p class="ui-li-aside">$date</p>\n};
		$newslist.=qq{</a></li>\n};
	}	
	$html =~s/<!--NEWSLIST-->/$newslist/g;

	# 今日の件数
	my $sth = $self->{dbi}->prepare(qq{select date,cnt,totalcnt from $tablename}.qq{_photo_log order by date desc limit 1 });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$html =~s/<!--TODAY_N_CNT-->/$row[1]/g;
	}

	&_output($html);

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

sub _parts_set(){
	my $html = shift;
	my $self = shift;

	# meta
	my $meta = &_load_tmpl("meta.html", $self);
	# header
	my $header = &_load_tmpl("header.html", $self);
	# footer
	my $footer = &_load_tmpl("footer.html", $self);
	# slider
	my $side_free = &_load_tmpl("side_free.html", $self);
	$html =~s/<!--SIDE_FREE-->/$side_free/g;

	$html =~s/<!--META-->/$meta/g;
	$html =~s/<!--HEADER-->/$header/g;
	$html =~s/<!--FOOTER-->/$footer/g;

	# slider
	my $social_tag = &_load_tmpl("social_tag.html", $self);
	$html =~s/<!--SOCIAL_TAG-->/$social_tag/g;

	# ad
	my $ad_header = &_load_tmpl("ad_header.html", $self);
	$html =~s/<!--AD_HEADER-->/$ad_header/g;

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
	my $self = shift;
my $file;
$file = qq{/var/www/vhosts/goo.to/etc/makehtml/car/tmpl_smf/$tmpl};

my $fh;
my $filedata;
open( $fh, "<", $file );
while( my $line = readline $fh ){ 
	$filedata .= $line;
}
close ( $fh );

	return $filedata;
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

sub _output(){
	my $html = shift;
	
print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}
1;