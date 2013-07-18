package Waao::MotoGP;

use DBI;
use CGI;
use Jcode;
use Cache::Memcached;
use CGI qw( escape );
use Date::Simple;

sub dispatch(){
	my $self = shift;

	if($self->{cgi}->param('newsid')){
		&_news($self);
	}elsif($self->{cgi}->param('page')){
		&_news_page($self);
	}elsif($self->{cgi}->param('raceid')){
#		&_race($self);
	}elsif($self->{cgi}->param('driversid')){
#		&_driver($self);
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

	my $html = &_load_tmpl("rider.html","tmpl_motogp");
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

sub _news_page(){
	my $self = shift;

	my $page = $self->{cgi}->param('page');
	my $start = ($page - 1 ) * 25;
	
	my $sth = $self->{dbi}->prepare(qq{ select title, datestr, id from race_rss where type=2 order by datestr desc limit $start, 25});
	$sth->execute();
	my $newstopics;
	while(my @row = $sth->fetchrow_array) {
		$newstopics .= qq{<tr><td><i class=" icon-star-empty"></i><a href="/motogp/news/$row[2]/">$row[0]</a></td><td>$row[1]</td></tr>};
	}

	$html =~s/<!--NEWSTOPICS-->/$newstopics/g;
	
	my $html = &_load_tmpl("news_page.html","tmpl_motogp");
	$html = &_parts_set($html);
	
	$html =~s/<!--PAGE-->/$page/g;
	
	$html =~s/<!--NEWSTOPICS-->/$newstopics/g;

	my $pager .= &_pager($page);
	$html =~s/<!--PAGER-->/$pager/g;

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}

sub _pager(){
	my $page = shift;
	my $type = shift;
	my $pagelist;

	$pagelist .= qq{<div class="pagination">\n};
	$pagelist .= qq{<ul>\n};
	if($page == 1){
	   	$pagelist .= qq{<li class="prev disabled"><a href="/motogp/news-1/">&larr; Previous</a></li>\n};
	}else{
		my $preno = $page - 1;
	   	$pagelist .= qq{<li class="prev"><a href="/motogp/news-$preno/">&larr; Previous</a></li>\n};
	}
	my $pageno;
	for(my $i=0; $i<10; $i++){
		$pageno = $page + $i;
		if($page eq $pageno){
		    $pagelist .= qq{<li class="active"><a href="/motogp/news-$pageno/">$pageno</a></li>\n};
		}else{
		    $pagelist .= qq{<li><a href="/motogp/news-$pageno/">$pageno</a></li>\n};
		}
	}
	$pageno++;
    $pagelist .= qq{<li class="next"><a href="/motogp/news-$pageno/">Next &rarr;</a></li>\n};
    $pagelist .= qq{</ul>\n};
    $pagelist .= qq{</div>\n};

	return $pagelist;
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
	$sth = $self->{dbi}->prepare(qq{ select title, datestr, id from race_rss where  type=2 and id < ? order by id desc limit 20});
	$sth->execute($self->{cgi}->param('newsid'));
	while(my @row = $sth->fetchrow_array) {
		$newstopics .= qq{<tr><td><i class=" icon-star-empty"></i><a href="/motogp/news/$row[2]/">$row[0]</a></td><td>$row[1]</td></tr>};
	}
	
	my $html = &_load_tmpl("news.html","tmpl_motogp");
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

	# meta
	my $meta = &_load_tmpl("meta.html","tmpl_motogp");
	# header
	my $header = &_load_tmpl("header.html","tmpl_motogp");
	# footer
	my $footer = &_load_tmpl("motogp_footer.html","tmpl_motogp");
	# slide_ad
	my $slide_ad = &_load_tmpl("slide_ad.html","tmpl_motogp");
	# slide
	my $slide = &_load_tmpl("side.html","tmpl_motogp");
	# navibar
	my $navibar = &_load_tmpl("motogp_navibar.html","tmpl_motogp");

	$html =~s/<!--META-->/$meta/g;
	$html =~s/<!--HEADER-->/$header/g;
	$html =~s/<!--NAVIBAR-->/$navibar/g;
	$html =~s/<!--SLIDE_AD-->/$slide_ad/g;
	$html =~s/<!--SLIDE-->/$slide/g;
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
	my $base_dir = shift;
	
my $file = qq{/var/www/vhosts/waao.jp/etc/motorsports/$base_dir/$tmpl};
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