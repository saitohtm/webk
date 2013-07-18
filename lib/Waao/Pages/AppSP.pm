package Waao::AppSP;

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
	my $clipid = $self->{cgi}->param('id');
	my $type = $self->{cgi}->param('type');
	my $page = 0;
	$page = $self->{cgi}->param('page') if($self->{cgi}->param('page'));

	# PV 更新
	my $sth = $self->{dbi}->prepare(qq{update app_clip set pv = pv + 1 where id = ? });
	$sth->execute($clipid);
	
	my $html;

	my $device_type;
	if($self->{cgi}->param('type') eq 'iphone'){
		$device_type = 1;
		$html = &_load_tmpl("app_clip_detail.html",$self);
	}else{
		$device_type = 2;
		$html = &_load_tmpl("app_clip_detail_android.html",$self);
	}

	my $sth = $self->{dbi}->prepare(qq{select title,memo from app_clip where id = ? });
	$sth->execute($clipid);
print "$clipid aaaa";
	while(my @row = $sth->fetchrow_array) {
print "$clipid aaaa";
		$html =~s/<!--TITLE-->/$row[0]/g;
		$html =~s/<!--MEMO-->/$row[1]/g;
	}

	# item
	my $sth = $self->{dbi}->prepare(qq{select * from app_clip_app where clip_id = ? });
	$sth->execute($clipid);
	my $list;
	my $no;
	while(my @row = $sth->fetchrow_array) {
		$no;
		my ($app_id,$memo) = @row;
		my $sth2 = $self->{dbi}->prepare(qq{select img, dl_url, appname, ex_str, device, category, developer, price, sale, rdate, eva, review, rank, saledate from app where id = ? });
		$sth2->execute($app_id);
		while(my @row2 = $sth2->fetchrow_array) {
			my ($img, $dl_url, $appname, $ex_str, $device, $category, $developer, $price, $sale, $rdate, $eva, $review, $rank, $saledate) = @row2;
			$img =~s/175x175/100x100/g;

			$list .= qq{<tr>\n};
			$list .= qq{<td><b>$no</b></td>\n};
			$list .= qq{<td width=10%><span class="rounded-img" style="background: url($img) no-repeat center center; width: 100px; height: 100px;"><a href="/app-$app_id/" target="_blank"><img src="$img" style="opacity: 0;" alt="無料アプリ $appname" /></span></td>\n};
			my $star_str = &_star_img($eva);
			$review = qq{未評価} unless($review);

			my $facebook = qq{<a href="/app-$app_id/" target="_blank"><img src="/img/facebook_like.png" width="80"></a>};

		$list .= qq{<td width=20%><a href="/app-$app_id/">$appname</a><br />$star_str（$review）<br />$price</td>\n};
		my $exp_short = substr($ex_str,0, 200);

		$list .= qq{<td><div class="well">$exp_short</div></td>\n};
		$list .= qq{<td>$facebook</td>\n};
		$list .= qq{</tr>\n};

		}
	}

	$html =~s/<!--LIST-->/$list/g;
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


	my $device_type;
	if($self->{cgi}->param('type') eq 'iphone'){
		$device_type = 1;
		$html = &_load_tmpl("app_teiban.html",$self);
	}else{
		$device_type = 2;
		$html = &_load_tmpl("app_teiban_android.html",$self);
	}

	# item
	my $sth = $self->{dbi}->prepare(qq{select * from app_clip where type = ? order by id desc limit $page, 20});
	$sth->execute($device_type);
	my $list;
	$startno = $page * 20;
	my $no = $startno;
	while(my @row = $sth->fetchrow_array) {
		my ($id, $title, $memo, $pv, $regist) = @row;
		$list .= qq{<tr>\n};
		if($self->{cgi}->param('type') eq 'iphone'){
			$list .= qq{<td colspan=2><h2><a href="/iphone/appsp-$id/">$title</a></h2></td>\n};
		}else{
			$list .= qq{<td colspan=2><h2><a href="/android/appsp-$id/">$title</a></h2></td>\n};
		}
		$list .= qq{</tr>\n};
		$list .= qq{<tr>\n};
		$list .= qq{<td>$regist<br />\n};
		if($self->{cgi}->param('type') eq 'iphone'){
			$list .= qq{<div class="well">$memo<br /><a href="/iphone/appsp-$id/">続きを読む≫</a></div></td>\n};
		}else{
			$list .= qq{<div class="well">$memo<br /><a href="/android/appsp-$id/">続きを読む≫</a></div></td>\n};
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
	
my $file = qq{/var/www/vhosts/waao.jp/etc/app/tmpl_teiban$tmpl};
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