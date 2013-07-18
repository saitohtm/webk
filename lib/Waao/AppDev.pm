package Waao::AppDev;

use lib qw(/var/www/vhosts/goo.to/etc/lib /var/www/vhosts/goo.to/lib/Waao);
use PageAnalyze;
use DataController;
use AppDevDataController;
use Utility;

use DBI;
use CGI;
use Cache::Memcached;
use Waao::Api;
use XML::Simple;
use LWP::Simple;
use Jcode;
use CGI qw( escape );
use Date::Simple;
use Encode;
use utf8;
use Mail::Sendmail;
use Crypt::Blowfish;

sub dispatch(){
	my $self = shift;

	if($self->{cgi}->param('clickid')){
	}elsif($self->{cgi}->param('app_order')){
		&_app_order($self);
	}elsif($self->{cgi}->param('app_entry')){
		&_regist_email($self);
	}elsif($self->{cgi}->param('email')){
		&_regist_email($self);
	}elsif($self->{cgi}->param('regist')){
		&_regist($self);
	}else{
		&_top($self);
	}

	return;
}

sub _app_order(){
	my $self = shift;

 	my $html;
	$html = &_load_tmpl("app_order.html",$self);
	$html = &_parts_set($html,$self);

	# OS
	my $os;
	my $sth = $self->{dbi}->prepare(qq{SELECT id, name FROM app_dev_os order by id });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$os.=qq{<option value="$row[0]">$row[1]</option>};
	}
	$html =~s/<!--OSLIST-->/$os/g;

	# ジャンル
	my $genre;
	my $sth = $self->{dbi}->prepare(qq{SELECT id, name FROM app_dev_genre order by id });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$genre.=qq{<label class="checkbox inline">};
		$genre.=qq{<input type="checkbox" name="s_genre_$row[0]" value="1"> $row[1]};
		$genre.=qq{</label>};
	}
	$html =~s/<!--GENRELIST-->/$genre/g;

	# 依頼範囲
	my $orderlist;
	my $sth = $self->{dbi}->prepare(qq{SELECT id, name FROM app_dev_order order by id });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$orderlist.=qq{<label class="checkbox inline">};
		$orderlist.=qq{<input type="checkbox" name="s_order_$row[0]" value="1"> $row[1]};
		$orderlist.=qq{</label>};
	}
	$html =~s/<!--ORDERLIST-->/$orderlist/g;
	
	# 開発予算(上限)
	my $yosan;
	my $sth = $self->{dbi}->prepare(qq{SELECT id, yosan FROM app_dev_yosan order by id });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$yosan.=qq{<option value="$row[0]">$row[1]</option>};
	}
	$html =~s/<!--YOSANLIST-->/$yosan/g;

	# 納期
	my $limit;
	my $sth = $self->{dbi}->prepare(qq{SELECT id, name FROM app_dev_limit order by id });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$limit.=qq{<option value="$row[0]">$row[1]</option>};
	}
	$html =~s/<!--LIMITLIST-->/$limit/g;

	# 機能
	my $kinou;
	my $sth = $self->{dbi}->prepare(qq{SELECT id, name FROM app_dev_kinou order by id });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$kinou.=qq{<label class="checkbox inline">};
		$kinou.=qq{<input type="checkbox" name="s_kinou_$row[0]" value="1"> $row[1]};
		$kinou.=qq{</label>};
	}
	$html =~s/<!--KINOULIST-->/$kinou/g;

	# 想定画面数
	my $gamen;
	my $sth = $self->{dbi}->prepare(qq{SELECT id, name FROM app_dev_gamen order by id });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$gamen.=qq{<option value="$row[0]">$row[1]</option>};
	}
	$html =~s/<!--GAMENLIST-->/$gamen/g;

	# 都道府県
	my $pref;
	my $sth = $self->{dbi}->prepare(qq{SELECT id, name FROM pref order by id });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$pref.=qq{<option value="$row[0]">$row[1]</option>};
	}
	$html =~s/<!--PREFLIST-->/$pref/g;

	# 検討度合い(任意)
	my $doai;
	my $sth = $self->{dbi}->prepare(qq{SELECT id, name FROM app_dev_doai order by id });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$doai.=qq{<option value="$row[0]">$row[1]</option>};
	}
	$html =~s/<!--DOAILIST-->/$doai/g;



	&_output($self,$html);

	return;
}

sub _regist_email(){
	my $self = shift;

 	my $html;
	$html = &_load_tmpl("regist_email.html",$self);
	$html = &_parts_set($html,$self);
	
	my $data;

	my $key = qq{developerapplease};

	my $cipher = new Crypt::Blowfish $key; 


	$data->{pass} = $self->{cgi}->param('email');
	my $ciphertext = $cipher->encrypt($pass);
  	my $plaintext  = $cipher->decrypt($ciphertext);

	$data->{company_type} = $self->{cgi}->param('company_type');
	$data->{company} = $self->{cgi}->param('company');
	$data->{tanto} = $self->{cgi}->param('tanto');
	$data->{s_pref} = $self->{cgi}->param('s_pref');
	$data->{email} = $self->{cgi}->param('email');
	$data->{comment} = $self->{cgi}->param('comment');

	&app_dev_company_data($self->{dbi},$data);
	
	&_output($self,$html);

	# sendmail
	my $from = 'info@xxxxxxxxxxxxxxxxxxxxxxxxx.jp';
#	&mailto($from, $to, 'テストﾃｽﾄtest', 'テストﾃｽﾄtest'); # メール送信

	return;
}

sub _regist(){
	my $self = shift;

 	my $html;
	$html = &_load_tmpl("regist_top.html",$self);
	$html = &_parts_set($html,$self);

	# 都道府県
	my $pref;
	my $sth = $self->{dbi}->prepare(qq{SELECT id, name FROM pref order by id });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$pref.=qq{<option value="$row[0]">$row[1]</option>};
	}
	$html =~s/<!--PREFLIST-->/$pref/g;

	&_output($self,$html);

	return;
}

sub _top(){
	my $self = shift;

 	my $html;
	$html = &_load_tmpl("top.html",$self);
	$html = &_parts_set($html,$self);

	&_output($self,$html);

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

	# ad
	my $ad_header = &_load_tmpl("ad_header.html");
	$html =~s/<!--AD_HEADER-->/$ad_header/g;

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
	
my $file = qq{/var/www/vhosts/goo.to/etc/makehtml/app_developer/tmpl/$tmpl};
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

sub price_dsp(){
	my $price = shift;

	1 while $price =~ s/(.*\d)(\d\d\d)/$1,$2/;	

	return $price;
}


sub _star_img(){
	my $point = shift;
	$point=~s/ //g;

	my $str;
	$str = qq{<img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">};
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png">} if($point eq "5");
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png">} if($point eq "5.0");
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-half.png">} if($point eq "4.5");
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-off.png">} if($point eq "4");
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-off.png">} if($point eq "4.0");
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-half.png"><img src="/img/star-off.png">} if($point eq "3.5");
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-off.png"><img src="/img/star-off.png">} if($point eq "3");
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-off.png"><img src="/img/star-off.png">} if($point eq "3.0");
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-half.png"><img src="/img/star-off.png"><img src="/img/star-off.png">} if($point eq "2.5");
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">} if($point eq "2");
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">} if($point eq "2.0");
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-half.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">} if($point eq "1.5");
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">} if($point eq "1");
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">} if($point eq "1.0");
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

	if($price <= 0){
		$price_str = qq{<img src="/img/Free.gif" alt="無料アプリ">};
	}elsif($price eq "無料"){
		$price_str = qq{<img src="/img/Free.gif" alt="無料アプリ">};
	}else{
		$price_str = qq{<img src="/img/E12F_20.gif" height=15> $price};
	}

	return $price_str;
}

sub _date_set(){
	my $html = shift;
	my $date = Date::Simple->new();
	my $ymd = $date->format('%Y/%m/%d');
	$html =~s/<!--DATE-->/$ymd/ig;
	return $html;
}

sub _output(){
	my $self = shift;
	my $html = shift;

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}

sub mailto{

my ($from, $to, $subject, $body) = @_; 

$subject = encode('MIME-Header-ISO_2022_JP', $subject);
$body = encode('iso-2022-jp', $body);
my %mail;
$mail{'Content-Type'} = 'text/plain; charset="iso-2022-jp"';
$mail{'From'} = $from;
$mail{'To'} = $to;
$mail{'Subject'} = $subject;
$mail{'message'} = $body."\n";
#sendmail %mail;

sendmail(%mail) or die $Mail::Sendmail::error;

print "OK. Log says:\n", $Mail::Sendmail::log;

}

1;