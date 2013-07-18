package Waao::CospaAdmin;
use lib qw(/var/www/vhosts/waao.jp/etc/lib /var/www/vhosts/waao.jp/lib/Waao);
use PageAnalyze;

use DBI;
use CGI;
use Cache::Memcached;
use Waao::Api;
use XML::Simple;
use LWP::Simple;
use Jcode;
use CGI qw( escape );
use Date::Simple;

sub dispatch_clip(){
	my $self = shift;

	if($self->{cgi}->param('title')){
		&_regist($self);
	}else{
		&_regist_top($self);
	}

	return;
}

sub _regist(){
	my $self = shift;


	my $html;
	$html = &_load_tmpl("admin_regist_end.html");
	$html = &_parts_set($html);
	
	my $date = Date::Simple->new();
	my $ymd = $date->format('%Y/%m/%d');

	my $title = $self->{cgi}->param('title');
	my $mainbody = $self->{cgi}->param('mainbody');
	my $keyword = $self->{cgi}->param('keyword');

eval{
	my $sth = $self->{dbi}->prepare(qq{insert into cospa_clip (`title`,`memo`,`registdate`,`keyword`) values(?,?,?,?)});
	$sth->execute($title,$mainbody,$date,$keyword);
};


	my $maxid;
	my $sth = $self->{dbi}->prepare(qq{select max(id) from cospa_clip});
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$maxid = $row[0];
	}

	for(my $i=1;$i<=10;$i++){
		my $url = $self->{cgi}->param("url$i");
		my $sitename = $self->{cgi}->param("sitename$i");
		my $sitebody = $self->{cgi}->param("sitebody$i");
		if($url){
eval{
			my $sth = $self->{dbi}->prepare(qq{insert into cospa_site (`name`,`clip_id`,`memo`,`url`,`rank`) values(?,?,?,?,?)});
			$sth->execute($sitename,$maxid,$sitebody,$url,$i);
};			
		}
	}

	
print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}


sub _regist_top(){
	my $self = shift;

	my $html;
	$html = &_load_tmpl("admin_regist.html");
	$html = &_parts_set($html);

my $list;

for(my $i=1;$i<=10;$i++){

$list .= qq{<font color="#002595">■</font>サイト$i<br />};
$list .= qq{<input name="sitename$i"type="text">};
$list .= qq{<br />};
$list .= qq{<font color="#002595">■</font>サイト$i URL<br />};
$list .= qq{<input name="url$i"type="text">};
$list .= qq{<br />};
$list .= qq{<font color="#002595">■</font>site$iまとめ説明文<br />};
$list .= qq{<textarea class="xxlarge" id="sitebody$i" name="sitebody$i" rows="15" cols="600"></textarea>};
$list .= qq{<br /><br />};

}

$html =~s/<!--LIST-->/$list/g;

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}

sub _parts_set(){
	my $html = shift;

	# meta
	my $meta = &_load_tmpl("meta.html");
	# header
	my $header = &_load_tmpl("header.html");
	# footer
	my $footer = &_load_tmpl("footer.html");
	# slider
	my $side_free = &_load_tmpl("side_free.html");
	$html =~s/<!--SIDE_FREE-->/$side_free/g;
	my $catelist = &_load_tmpl("cate_list.html");
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
	
my $file = qq{/var/www/vhosts/waao.jp/etc/cospa/tmpl/$tmpl};
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