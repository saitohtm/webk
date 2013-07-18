package Waao::Photos;

use DBI;
use CGI;
use Cache::Memcached;
use Jcode;
use CGI qw( escape );
use Date::Simple;
use Waao::Utility;

sub dispatch_travel_photo(){
	my $self = shift;
	
	$self->{funcname}="travel";
	&_index($self);

	return;
}

sub dispatch_fanny_photo(){
	my $self = shift;
	
	$self->{funcname}="fanny";
	&_index($self);

	return;
}

sub dispatch_celeblities_photo(){
	my $self = shift;
	
	$self->{funcname}="celebrities";
	&_index($self);

	return;
}

sub dispatch_animal_photo(){
	my $self = shift;
	
	$self->{funcname}="animal";
	&_index($self);

	return;
}

sub _index(){
	my $self = shift;

	if($self->{cgi}->param('dsp')){
		&_photo_dsp($self);
	}elsif($self->{cgi}->param('page')){
		&_photo_list($self);
	}elsif($self->{cgi}->param('cate_top')){
		&_photo_cate_top($self);
	}elsif($self->{cgi}->param('cate_ins')){
		&_photo_cate_ins($self);
	}elsif($self->{cgi}->param('photo_site_ins')){
		&_photo_ins($self);
	}else{
		&_photo_top($self);
	}

	return;
}

sub _photo_list(){
	my $self = shift;

	my $funcname = $self->{funcname};

	my $html;
	$html = &_load_tmpl($funcname."_photo_list.html",$self);
	$html = &_parts_set($html,$self);

	my $page  = $self->{cgi}->param('page');
	my $start = ($page - 1) * 50;

	my $list;
	my $sth = $self->{dbi}->prepare(qq{select id, photo, site_id, url, regist_date from $funcname}.qq{_photo order by id desc limit $start,50 });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my ($id, $photo,$site_id,$url,$date) = @row;
		$list.=qq{<div><img src="$photo"><br><a href="$url">取得元</a> $date </div>};
	}	
	$html =~s/<!--LIST-->/$list/g;

	my $tmp = $funcname.qq{-photo};

	my $pager = &_pager($page,$tmp);
	$html =~s/<!--PAGER-->/$pager/g;

	&_output($html);

	return;
}

sub _photo_cate_top(){
	my $self = shift;

	my $funcname = $self->{funcname};

	$html = &_load_tmpl($funcname."_photo_cate_top.html",$self);
	$html = &_parts_set($html,$self);

	&_output($html);

	return;
}

sub _photo_cate_ins(){
	my $self = shift;

	my $funcname = $self->{funcname};

eval{
	my $sth = $self->{dbi}->prepare(qq{insert into $funcname}.qq{_photo_category (name) values(?)});
	$sth->execute($self->{cgi}->param('name'));
};
	&_photo_top($self);

	return;
}

sub _photo_ins(){
	my $self = shift;

	my $funcname = $self->{funcname};

	$html = &_load_tmpl($funcname."_photo_ins.html",$self);
	$html = &_parts_set($html,$self);

eval{
	my $sth = $self->{dbi}->prepare(qq{insert into $funcname}.qq{_photo_site (url,photo_category_id,keyword) values(?,?,?)});
	$sth->execute($self->{cgi}->param('car_url'),$self->{cgi}->param('car_photo_category'),$self->{cgi}->param('car_keyword'));
};

if($self->{cgi}->param('car_keyword')){
eval{
	my $sth = $self->{dbi}->prepare(qq{insert into $funcname}.qq{_keyword (name) values(?)});
	$sth->execute($self->{cgi}->param('car_keyword'));
};
}

	&_output($html);

	return;
}

sub _photo_top(){
	my $self = shift;
	
	my $funcname = $self->{funcname};

	$html = &_load_tmpl($funcname."_photo_top.html",$self);
	$html = &_parts_set($html,$self);

	my $category_list;
	my $sth = $self->{dbi}->prepare(qq{select id,name from $funcname}.qq{_photo_category});
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$category_list.=qq{<option value="$row[0]">$row[1]</option>};
	}
	$html =~s/<!--CATEGORY_LIST-->/$category_list/g;

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
	my $metatop = &_load_tmpl("metatop.html", $self);
	# header
	my $header = &_load_tmpl("header.html", $self);
	# footer
	my $footer = &_load_tmpl("footer.html", $self);
	# slider
	my $side_free = &_load_tmpl("side_free.html", $self);
	$html =~s/<!--SIDE_FREE-->/$side_free/g;

	$html =~s/<!--META-->/$meta/g;
	$html =~s/<!--METATOP-->/$metatop/g;
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
$file = qq{/var/www/vhosts/goo.to/etc/makehtml/car/tmpl/$tmpl};

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