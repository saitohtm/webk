package Waao::PhotoUI;

use DBI;
use CGI;
use Cache::Memcached;
use Jcode;
use CGI qw( escape );
use Date::Simple;

sub dispatch(){
	my $self = shift;
	
	#テーブル名
	if($ENV{'HTTP_HOST'} eq 'supercar.goo.to'){
		$self->{tablename} = 'car';
		$self->{url} = 'super-car';
		$self->{tmplname} = '';
	}elsif($ENV{'HTTP_HOST'} eq 'animal.goo.to'){
		$self->{tablename} = 'animal';
		$self->{url} = $self->{tablename};
		$self->{tmplname} = 'animal/';
	}elsif($ENV{'HTTP_HOST'} eq 'travel.goo.to'){
		$self->{tablename} = 'travel';
		$self->{url} = $self->{tablename};
		$self->{tmplname} = 'travel/';
	}elsif($ENV{'HTTP_HOST'} eq 'sexy.goo.to'){
		$self->{tablename} = 'celebrities';
		$self->{url} = "sexy";
		$self->{tmplname} = 'celebrities/';
	}else{
		$self->{tablename} = 'car';
		$self->{url} = 'super-car';
	}
	$self->{url} = $self->{url}.'-photo';
	
	if( $ENV{'HTTP_USER_AGENT'} =~/iPhone|iPod|Android|dream|CUPCAKE|blackberry|webOS|incognito|webmate/i ){
		$self->{smf} = 1;
	}

	if($self->{cgi}->param('id')){
		&_detail($self);
	}elsif($self->{cgi}->param('page')){
		&_list($self);
	}elsif($self->{cgi}->param('privacy')){
		&_tmp_output($self,"privacy.html");
	}elsif($self->{cgi}->param('menseki')){
		&_tmp_output($self,"menseki.html");
	}else{
		&_top($self);
	}

	return;
}

sub _list(){
	my $self = shift;
	my $tablename = $self->{tablename};
	my $urlname = $self->{url};
	my $html;
	$html = &_load_tmpl("photolist.html",$self);

	$html = &_parts_set($html,$self);
	my $page  = $self->{cgi}->param('page');
	my $start = ($page - 1) * 60;
	$html =~s/<!--PAGE-->/$page/g;

	# 画像表示
	my $list;
	my $sth = $self->{dbi}->prepare(qq{select id,photo,site_id,regist_date,url from $tablename}.qq{_photo order by id desc limit $start, 60 });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my ($id,$photo,$site_id,$regist_date,$url) = @row;
			$list .= qq{<div>};

if( $self->{smf} ){
			$list .= qq{<a href="/$urlname/$id/"><img src="$photo" width=90  /></a>};
}else{
			$list .= qq{<a href="/$urlname/$id/"><img src="$photo" width=360  /></a>};
}
			$list .= qq{</div>};

	}	

	$html =~s/<!--LIST-->/$list/g;

	my $prepage = $page -1;
	my $nextpage = $page +1;
	$html =~s/<!--PREPAGE-->/$prepage/g;
	$html =~s/<!--NEXTPAGE-->/$nextpage/g;

	&_output($html);

	return;
}

sub _detail(){
	my $self = shift;
	my $tablename = $self->{tablename};

	my $html;
	$html = &_load_tmpl("photo.html",$self);

	$html = &_parts_set($html,$self);

	# 画像表示
	if($self->{cgi}->param('good')){
		my $sth = $self->{dbi}->prepare(qq{update $tablename}.qq{_photo set eva = eva + 1 where id = ? limit 1 });
		$sth->execute($self->{cgi}->param('id'));
	}
	if($self->{cgi}->param('bad')){
		my $sth = $self->{dbi}->prepare(qq{update $tablename}.qq{_photo set eva = eva - 1 where id = ? limit 1 });
		$sth->execute($self->{cgi}->param('id'));
	}
	my $list;
	my $sth = $self->{dbi}->prepare(qq{select id,photo,site_id,regist_date,url,eva from $tablename}.qq{_photo where id = ? limit 1 });
	$sth->execute($self->{cgi}->param('id'));
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

if( $self->{smf} ){
			$list .= qq{<a href="$photo" target="_blank" ref=nofollow><img src="$photo" width=100%  /></a>};
}else{
			$list .= qq{<center><a href="/}.$self->{url}.qq{/$nextid/"><img src="$photo" height=80%></a></center>};
}
	}	

	$html =~s/<!--LIST-->/$list/g;

	if($self->{cgi}->param('description')){
		my $sth = $self->{dbi}->prepare(qq{insert into $tablename}.qq{_photo_bbs (photo_id,answer) values(?,?) });
		$sth->execute($self->{cgi}->param('id'),$self->{cgi}->param('description'));
	}
	my $list;
	my $sth = $self->{dbi}->prepare(qq{select answer from $tablename}.qq{_photo_bbs where photo_id = ? limit 1 });
	$sth->execute($self->{cgi}->param('id'));
	while(my @row = $sth->fetchrow_array) {
		$list.=qq{$row[0]<br />};
	}

	$html =~s/<!--COMMENT-->/$list/g;

	&_output($html);
	my $sth = $self->{dbi}->prepare(qq{update $tablename}.qq{_photo set  order by date desc limit 1 });
	$sth->execute($self->{cgi}->param('id'));

	
	return;
}

sub _tmp_output(){
	my $self = shift;
	my $tmpl = shift;
	my $html;
	$html = &_load_tmpl($tmpl,$self);
	$html = &_parts_set($html,$self);

	&_output($html);
	return;
}

sub _top(){
	my $self = shift;
	my $tablename = $self->{tablename};
	my $urlname = $self->{url};

	my $html;
	$html = &_load_tmpl("top.html",$self);

	$html = &_parts_set($html,$self);

	# 画像表示
	my $list;
	my $sth = $self->{dbi}->prepare(qq{select id,photo,site_id,regist_date,url from $tablename}.qq{_photo order by id desc limit 30 });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my ($id,$photo,$site_id,$regist_date,$url) = @row;
			$list .= qq{<div>};

if( $self->{smf} ){
			$list .= qq{<a href="/$urlname/$id/"><img src="$photo" width=90  /></a>};
}else{
			$list .= qq{<a href="/$urlname/$id/"><img src="$photo" width=360  /></a>};
}
			$list .= qq{</div>};

	}	

	$html =~s/<!--LIST-->/$list/g;

	my $sth = $self->{dbi}->prepare(qq{select date,cnt,totalcnt from $tablename}.qq{_photo_log order by date desc limit 1 });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$html =~s/<!--CNT-->/$row[1]/g;
		$html =~s/<!--TOTALCNT-->/$row[2]/g;
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
	my $tmplname = $self->{tmplname};

my $file;

my $en_str;
my @acceptLanguage = split(/,/, $ENV{'HTTP_ACCEPT_LANGUAGE'});
if ($acceptLanguage[0] =~ m/ja/) {
} else {
	$en_str = qq{_en};
}

# スマフォ判定
my $smf_str;
if( $self->{smf} ){
	$smf_str = qq{_smf};
}else{
}

$file = qq{/var/www/vhosts/goo.to/etc/makehtml/supercar/tmpl$smf_str$en_str/$tmplname$tmpl};

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