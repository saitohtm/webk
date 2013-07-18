package Waao::AppNews;

use DBI;
use CGI;
use Cache::Memcached;
use Waao::Api;
use XML::Simple;
use LWP::Simple;
use Jcode;
use CGI qw( escape );


sub dispatch(){
	my $self = shift;

	if($self->{cgi}->param('id')){
		&_detail($self);
	}else{
		&_list($self);
	}

	return;
}

sub _detail(){
	my $self = shift;
	my $newsid = $self->{cgi}->param('id');

	my $html;

	if($self->{cgi}->param('type') eq 'iphone'){
		$html = &_load_tmpl("news_detail_iphone.html",$self);
	}else{
		$html = &_load_tmpl("news_detail_android.html",$self);
	}

	# item
	my ($id, $newsdate, $title, $description, $genre, $keywords, $filepath, $img);
	my $sth = $self->{dbi}->prepare(qq{select id, newsdate, title, description, genre, keywords, filepath, img from app_news where id = ? });
	$sth->execute($newsid);
	my $list;
	while(my @row = $sth->fetchrow_array) {
		($id, $newsdate, $title, $description, $genre, $keywords, $filepath, $img) = @row;
	}

	$html =~s/<!--DESCRIPTION-->/$description/g;
	$html =~s/<!--KEYWORAD-->/$keywords/g;
	$html =~s/<!--TITLE-->/$title/g;
	$html =~s/<!--NEWSDATE-->/$newsdate/g;
	my $newsstr = &_load_tmpl_news($filepath);
	$html =~s/<!--NEWSSTR-->/$newsstr/g;
	$html = &_parts_set($html,$self);

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}



sub _list(){
	my $self = shift;
	my $type = $self->{cgi}->param('type');
	my $page = 0;
	$page = $self->{cgi}->param('page') if($self->{cgi}->param('page'));

	my $html;

	if($self->{cgi}->param('type') eq 'iphone'){
		$html = &_load_tmpl("news_iphone.html",$self);
	}else{
		$html = &_load_tmpl("news_android.html",$self);
	}

	# item
	my ($id, $newsdate, $title, $description, $genre, $keywords, $filepath, $img);
	my $sth = $self->{dbi}->prepare(qq{select id, newsdate, title, description, genre, keywords, filepath, img from app_news order by id desc limit $page, 20});
	$sth->execute();
	my $list;
	$startno = $page * 20;
	my $no = $startno;
	while(my @row = $sth->fetchrow_array) {
		($id, $newsdate, $title, $description, $genre, $keywords, $filepath, $img) = @row;
		$description =~s/\n/<br \/>/g;
		$no++;
		$img = qq{/img/News.png} unless($img);
		$list .= qq{<tr>\n};
		if($self->{cgi}->param('type') eq 'iphone'){
			$list .= qq{<td colspan=2><h2><a href="/iphone/newsid-$id/">$title</a></h2></td>\n};
		}else{
			$list .= qq{<td colspan=2><h2><a href="/android/newsid-$id/">$title</a></h2></td>\n};
		}
		$list .= qq{</tr>\n};
		$list .= qq{<tr>\n};
		$list .= qq{<td width=120><img src="$img" width=120 ></td>\n};
		$list .= qq{<td>$newsdate<br />\n};
		if($self->{cgi}->param('type') eq 'iphone'){
			$list .= qq{<div class="well">$description<br /><a href="/iphone/newsid-$id/">続きを読む≫</a></div></td>\n};
		}else{
			$list .= qq{<div class="well">$description<br /><a href="/android/newsid-$id/">続きを読む≫</a></div></td>\n};
		}
		$list .= qq{</tr>\n};

	}

	$html =~s/<!--LIST-->/$list/g;
	$html = &_parts_set($html,$self);

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}

sub _parts_set(){
	my $html = shift;
	my $self = shift;

	# meta
	my $meta = &_load_tmpl("meta.html",$self);
	# header
	my $header = &_load_tmpl("header.html",$self);
	# footer
	my $footer = &_load_tmpl("footer.html",$self);
	# slider
	my $side_free = &_load_tmpl("side_free.html",$self);
	$html =~s/<!--SIDE_FREE-->/$side_free/g;
	my $catelist = &_load_tmpl("cate_list.html",$self);
	$html =~s/<!--CATELIST-->/$catelist/g;

	$html =~s/<!--META-->/$meta/g;
	$html =~s/<!--HEADER-->/$header/g;
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
	my $self = shift;
my $file;
if($self->{cgi}->param('type') eq 'iphone'){
	$file = qq{/var/www/vhosts/waao.jp/etc/app/tmpl/$tmpl};
}else{
	$file = qq{/var/www/vhosts/waao.jp/etc/app/tmpl_android/$tmpl};
}

my $fh;
my $filedata;
open( $fh, "<", $file );
while( my $line = readline $fh ){ 
	$filedata .= $line;
}
close ( $fh );

	return $filedata;
}

sub _load_tmpl_news(){
	my $tmpl = shift;
	
my $file = qq{/var/www/vhosts/waao.jp/etc/app/tmpl_news/$tmpl};
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
1;