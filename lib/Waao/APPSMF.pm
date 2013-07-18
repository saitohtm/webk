package Waao::APPSMF;

use DBI;
use CGI;
use Cache::Memcached;
use Waao::Api;
use XML::Simple;
use LWP::Simple;
use Jcode;
use CGI qw( escape );
use Date::Simple;


sub dispatch(){
	my $self = shift;
	my $appid = $self->{cgi}->param('id');

	# item
	my ($img, $dl_url, $appname, $ex_str, $device, $category, $developer, $price, $sale, $cnt, $lang_flag, $rdate, $eva, $review, $dl_mini, $dl_max, $rank, $saledate);
	my $sth = $self->{dbi}->prepare(qq{select img, dl_url, appname, ex_str, device, category, developer, price, sale, cnt, lang_flag, rdate, eva, review, dl_mini, dl_max, rank, saledate from app where id = ? limit 1});
	$sth->execute($appid);
	while(my @row = $sth->fetchrow_array) {
		($img, $dl_url, $appname, $ex_str, $device, $category, $developer, $price, $sale, $cnt, $lang_flag, $rdate, $eva, $review, $dl_mini, $dl_max, $rank, $saledate) = @row;
	}

	# カテゴリ(iphone/android)
	my ($c_name, $c_category, $c_cnt, $c_flag, $c_game, $c_key_value, $c_img);
	my $sth = $self->{dbi}->prepare(qq{select name, category, cnt, flag, game, key_value, img from app_category where id = ? limit 1});
	$sth->execute($category);
	while(my @row = $sth->fetchrow_array) {
		($c_name, $c_category, $c_cnt, $c_flag, $c_game, $c_key_value, $c_img) = @row;
	}

	# アプリ本体
	my ($sshot1, $sshot2, $sshot3, $sshot4, $sshot5,$exp_long);
	my $sth = $self->{dbi}->prepare(qq{select sshot1,sshot2,sshot3,sshot4,sshot5,exp from app_info where app_id = ? limit 1});
	$sth->execute($appid);
	while(my @row = $sth->fetchrow_array) {
		($sshot1, $sshot2, $sshot3, $sshot4, $sshot5,$exp_long) = @row;
	}

	my $html;
	if($device < 4){
		$html = &_load_tmpl("app_iphone.html");
	}else{
		$html = &_load_tmpl("app_android.html");
	}


	# 画面ショット
	my $shotimgs;
	$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$sshot1" alt="$appname" /><img src="$sshot1" alt="$appname" class="preview" /></a></li>} if($sshot1);
	$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$sshot2" alt="$appname" /><img src="$sshot2" alt="$appname" class="preview" /></a></li>} if($sshot2);
	$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$sshot3" alt="$appname" /><img src="$sshot3" alt="$appname" class="preview" /></a></li>} if($sshot3);
	$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$sshot4" alt="$appname" /><img src="$sshot4" alt="$appname" class="preview" /></a></li>} if($sshot4);
	$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$sshot5" alt="$appname" /><img src="$sshot5" alt="$appname" class="preview" /></a></li>} if($sshot5);
	$html =~s/<!--SHOTIMGS-->/$shotimgs/g;

	my $shotimgs_full;
	$shotimgs_full .= qq{<img src="$sshot1" alt="$appname"> } if($sshot1);
	$shotimgs_full .= qq{<img src="$sshot2" alt="$appname"><br /> } if($sshot2);
	$shotimgs_full .= qq{<img src="$sshot3" alt="$appname"> } if($sshot3);
	$shotimgs_full .= qq{<img src="$sshot4" alt="$appname"><br /> } if($sshot4);
	$shotimgs_full .= qq{<img src="$sshot5" alt="$appname"> } if($sshot5);
	$html =~s/<!--SHOTIMGS_FULL-->/$shotimgs_full/g;


	$html = &_parts_set($html);

	$ex_str = substr($ex_str,0,300);

	$html =~s/<!--IMG-->/$img/g;
	$html =~s/<!--C_NAME-->/$c_name/g;
	$html =~s/<!--DL_URL-->/$dl_url/g;
	$html =~s/<!--APPNAME-->/$appname/g;
	$html =~s/<!--EX_STR-->/$ex_str/g;
	$html =~s/<!--EXP_LONG-->/$exp_long/g;
	$html =~s/<!--DEVELOPER-->/$developer/g;

	# 価格
	if($sale == 0){
		$price=qq{<S>$price</S> → <font color="#FF0000">無料</font>};
	}if($sale > 0){
		$price=qq{<S>$price</S> → <font color="#FF0000">$sale</font>};
	}else{
		$price=qq{<font color="#FF0000">$price</font>};
	}

	my $eva_str = &_star_img($eva);

	$html =~s/<!--PRICE-->/$price/g;
	$html =~s/<!--RDATE-->/$rdate/g;
	$html =~s/<!--EVA-->/$eva/g;
	$html =~s/<!--REVIEW-->/$review/g;
	$html =~s/<!--DL_MINI-->/$dl_mini/g;
	$html =~s/<!--DL_MAX->/$dl_max/g;
	$html =~s/<!--RANK->/$rank/g;

	$html =~s/<!--EVA_STR-->/$eva_str/g;

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}

sub _parts_set(){
	my $html = shift;

	# header
	my $header = &_load_tmpl("smf_header.html");
	# footer
	my $footer = &_load_tmpl("smf_footer.html");
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
	
my $file = qq{/var/www/vhosts/waao.jp/etc/app/tmpl_smf/$tmpl};
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

sub _date_set(){
	my $html = shift;
	my $date = Date::Simple->new();
	my $ymd = $date->format('%Y/%m/%d');
	$html =~s/<!--DATE-->/$ymd/ig;
	return $html;
}

sub price_dsp(){
	my $price = shift;

	1 while $price =~ s/(.*\d)(\d\d\d)/$1,$2/;	

	return $price;
}


sub _star_img(){
	my $point = shift;
	
	my $str;
	$str = qq{<img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif">};
	$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif">} if($point eq "5");
	$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star_half.gif">} if($point eq "4.5");
	$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star_off.gif">} if($point eq "4");
	$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star_half.gif"><img src="/img/review_all_star_off.gif">} if($point eq "3.5");
	$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif">} if($point eq "3");
	$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star_half.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif">} if($point eq "2.5");
	$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif">} if($point eq "2");
	$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star_half.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif">} if($point eq "1.5");
	$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif">} if($point eq "1");
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