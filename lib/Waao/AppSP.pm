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

	my $html;

	my $device_type;
	if($self->{cgi}->param('type') eq 'iphone'){
		$device_type = 1;
		$html = &_load_tmpl("app_clip_detail_iphone.html",$self);
	}else{
		$device_type = 2;
		$html = &_load_tmpl("app_clip_detail_android.html",$self);
	}

	my $sth = $self->{dbi}->prepare(qq{select title,memo from app_clip where id = ?});
	$sth->execute($clipid);
	while(my @row = $sth->fetchrow_array) {
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
		my $sth2 = $self->{dbi}->prepare(qq{select name, url, img100, eva, evacount,formattedPrice,id,genres,genre_id,description from app_iphone where id = ? });
		$sth2->execute($app_id);
		while(my @row2 = $sth2->fetchrow_array) {
			my $shotimgs;
			my $sth3 = $self->{dbi}->prepare(qq{select type,img1,img2,img3,img4,img5 from app_iphone_img where app_id = ? limit 1});
			$sth3->execute($row2[6]);
			while(my @row3 = $sth3->fetchrow_array) {
				my ($type,$img1,$img2,$img3,$img4,$img5) = @row3;
				$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img1" alt="$row2[0]" /><img src="$img1" alt="$row2[0]" class="preview" /></a></li>} if($img1);
				$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img2" alt="$row2[0]" /><img src="$img2" alt="$row2[0]" class="preview" /></a></li>} if($img2);
				$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img3" alt="$row2[0]" /><img src="$img3" alt="$row2[0]" class="preview" /></a></li>} if($img3);
				$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img4" alt="$row2[0]" /><img src="$img4" alt="$row2[0]" class="preview" /></a></li>} if($img4);
				$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img5" alt="$row2[0]" /><img src="$img5" alt="$row2[0]" class="preview" /></a></li>} if($img5);
			}

			my $img200 = $row2[2];
			$img200=~s/\.jpg/\.200x200-75\.jpg/ig;
			$img200=~s/\.png/\.200x200-75\.png/ig;
			my $eva = $row2[3];
			$eva=0 unless($eva);
			my $star_str = &_star_img($eva);
			my $price_str = &_price_str($row2[5]);
			my $genrestr = substr($row2[7],0,30);
			$genrestr.=qq{...};
			my $ex_str = substr($row2[9],0,400);
			$ex_str.=qq{...};
			$row2[4] = 0 unless($row2[4]);

			$list .= qq{<tr>};
			$list .= qq{<td width="200" bgcolor="#000000">};
			$list .= qq{<font color="#FFFFFF">};
			$list .= qq{<span class="rounded-img" style="background: url($img200) no-repeat center center; width: 200px; height: 200px;"><a href="/iphoneapp-$row2[6]/" target="_blank" rel="nofollow"><img src="$img200" style="opacity: 0;" alt="$row2[0]" /></a></span>};
			$list .= qq{<br />};
			$list .=qq{<p><img src="/img/E20D_20.gif" width="15">$row2[0]</p>};
			$list .=qq{<a href="/category$row[8]-iphone-app-1/">$genrestr</a><br />};
			if($sale_flag){
				if($row2[11] > 0 ){
					$list .= qq{<p>¥$row2[10] → ¥$row2[11]<br />};
				}else{
					$list .= qq{<p>¥$row2[10] → <img src="/img/Free.gif" height=15> 無料<br />};
				}
			}else{
				$list .= qq{<p>	$star_str ($row2[4])<br />$price_str<br />};
			}
			$list .= qq{<form action="$row2[1]"><button class="btn primary" type="submit">アプリをインストール</button></form>};
			$list .= qq{</font>};
			$list .= qq{</p>};
			$list .= qq{</td>};
			$list .= qq{<td>};
			$list .= qq{$row[2]<br /><br />};
			$list .= qq{<ul class="hoverbox">};
			$list .= qq{$shotimgs};
			$list .= qq{</ul>};
			$list .= qq{<br />$ex_str};
			$list .= qq{</td>};
			$list .= qq{</tr>};
		}
	}

	if($list){
		$list = qq{<table><tbody>}.$list.qq{</tbody></table>};
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
if($self->{cgi}->param('type') eq 'iphone'){
	$file = qq{/var/www/vhosts/goo.to/etc/makehtml/app/tmpl/$tmpl};
}else{
	$file = qq{/var/www/vhosts/goo.to/etc/makehtml/app/tmpl_android/$tmpl};
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
	
my $file = qq{/var/www/vhosts/goo.to/etc/makehtml/app/tmpl_teiban$tmpl};
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

sub _price_str(){
	my $price = shift;
	my $price_str;
    $price =~s/\?/¥/g;

	if($price eq 0){
		$price_str = qq{<img src="/img/Free.gif" alt="無料アプリ">};
	}elsif($price eq "無料"){
		$price_str = qq{<img src="/img/Free.gif" alt="無料アプリ">};
	}else{
		$price_str = qq{<img src="/img/E12F_20.gif" height=15> $price};
	}

	return $price_str;
}


1;