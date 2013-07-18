package Waao::JobGooto;
use strict;
use DBI;
use CGI;
use Waao::Html5;
use Waao::Data;
use Waao::Utility;
use Date::Simple;
use Cache::Memcached::Fast;
use Jcode;

sub dispatch(){
	my $self = shift;

	my $readcookie = $self->{cgi}->cookie("kyujin");
	$self->{mem_id} = $readcookie;
	# memcashed 
	my $key = &_memcashe_key();
	my $html = $self->{mem}->get($key);
	if(0){
#	if($html){
		unless($self->{cgi}->param('clear')){
		return;
		}
	}
	
	if($self->{cgi}->param('search')){
	}elsif($self->{cgi}->param('site')){
		&_site_entry($self);
	}elsif($self->{cgi}->param('l')){
		&_login($self);
	}elsif($self->{cgi}->param('entry')){
		&_entry($self);
	}elsif($self->{cgi}->param('entry_company')){
		&_entry_company($self);
	}elsif($self->{cgi}->param('entry_job')){
		&_entry_job_type($self);
	}elsif($self->{cgi}->param('id')){
		&_job($self);
	}else{
		&_top($self);
	}
	
	return;
}

sub _site_entry(){
	my $self = shift;
	my $html;

print $self->{cgi}->header(-type=>"text/html", -charset=>"UTF-8");
print $self->{cgi}->html( "aaaa" );

	if($self->{cgi}->param('url')){
		$html = &_load_tmpl("site_check.html",$self);

#		my ($keywords,$description,$title) = &_get_site_info($self->{cgi}->param('url'));
		my ($keywords,$description,$title);
		$html =~s/<!--KEYWORDS-->/$keywords/g;
		$html =~s/<!--DESCRIPTION-->/$description/g;
		$html =~s/<!--TITLE-->/$title/g;
		my $url = $self->{cgi}->param('url');
		$html =~s/<!--URL-->/$url/g;
		my $genre = $self->{cgi}->param('genre');
		$html =~s/<!--GENRE-->/$genre/g;

	}else{
		$html = &_load_tmpl("site_entry.html",$self);
	}
	
	$html = &_parts_set($html,$self);

	&_output($self,$html);
	return;
}

sub _get_site_info(){
	my $url = shift;


	my $get_url = `GET "$url"`;
	
	my @lines = split(/\n/,$get_url);
	my $charset;
	my $title;
	my $description;
	my $keywords;
	foreach my $line (@lines){
		if($line=~/(.*)charset=(.*)>/i){
			$charset = $2;
		}
		if($line=~/(.*)charset=(.*)\">/i){
			$charset = $2;
		}
		if($line=~/<title>(.*)<\/title>/i){
			$title = $1;
		}
		if($line=~/<meta name=\"keywords\" content=\"(.*)\">/i){
			$keywords = $1;
		}
		if($line=~/<meta name=keywords content=\"(.*)\">/i){
			$keywords = $1;
		}
		if($line=~/<meta name=\"description\" content=\"(.*)\">/i){
			$description = $1;
		}
		if($line=~/<meta name=description content=\"(.*)\">/i){
			$description = $1;
		}
	}
#print "$charset\n";
$title = Jcode->new($title, $charset)->utf8;
$description = Jcode->new($description, $charset)->utf8;
$keywords = Jcode->new($keywords, $charset)->utf8;
#print "$title\n";
#print "$description\n";
#print "$keywords\n";

	return ($keywords,$description,$title);
}

sub _login(){
	my $self = shift;

	if($self->{cgi}->param('email')){
		&_regist_user($self);
		return;
	}
	
 	my $html;
	$html = &_load_tmpl("login.html",$self);
	$html = &_parts_set($html,$self);

	&_output($self,$html);
	return;
}

sub _regist_user(){
	my $self = shift;

	my $err_msg;
	if(&mailcheck($self->{cgi}->param('email'))){
		$err_msg.=qq{メールアドレスが間違っています<br>};
	}
	if(&lengthcheck($self->{cgi}->param('pass'),4,35)){
		$err_msg.=qq{パスワードは4文字以上<br>};
	}
	my $user_id;
	my $sth = $self->{dbi}->prepare(qq{select id, pass from kyujin_user where email = ?});
	$sth->execute($self->{cgi}->param('email'));
	while(my @row = $sth->fetchrow_array) {
		if($self->{cgi}->param('pass') ne $row[1]){
			$err_msg.=qq{パスワードが間違っています<br>};
		}
		$user_id = $row[0];
	}

	if($err_msg){
		my $html = &_load_tmpl("err.html",$self);
		$html = &_parts_set($html,$self);
		$html =~s/<!--ERROR-->/$err_msg/g;
		&_output($self,$html);
	}else{
		# DB 登録
		unless($user_id){
eval{
			my $sth = $self->{dbi}->prepare(qq{insert into kyujin_user (`email`,`pass`) values(?,?)});
			$sth->execute($self->{cgi}->param('email'),$self->{cgi}->param('pass'));
};
		}
		# Cookei 登録
		my $text = qq{$user_id};
 
		my $cookie = $self->{cgi}->cookie(-name    => "kyujin",
	                         -value   => $text,
    	                     -expires => "+1y");
 		$cookie = &cookie_path_fix($cookie);

print $self->{cgi}->header(-cookie=>$cookie );
		
		&_top($self);
	}
    
	return;
}

sub cookie_path_fix {
    my $a = shift;
    $a =~ s/path\s*=\s*[^;]*;//i;
    return $a;
}		

sub _entry(){
	my $self = shift;

 	my $html;
	$html = &_load_tmpl("entry.html",$self);
	$html = &_parts_set($html,$self);

	&_output($self,$html);
	return;
}

sub _entry_company(){
	my $self = shift;

 	my $html;
	$html = &_load_tmpl("entry_jobtype.html",$self);
	$html = &_parts_set($html,$self);

	&_output($self,$html);
	return;
}

sub _entry_job_type(){
	my $self = shift;

 	my $html;
	$html = &_load_tmpl("entry_job.html",$self);
	$html = &_parts_set($html,$self);

	&_output($self,$html);
	return;
}


sub _job(){
	my $self = shift;

 	my $html;
	$html = &_load_tmpl("job.html",$self);
	$html = &_parts_set($html,$self);

	&_output($self,$html);
	return;
}


sub _top(){
	my $self = shift;

 	my $html;
	$html = &_load_tmpl("top.html",$self);
	$html = &_parts_set($html,$self);

	my $list;

	$html =~s/<!--GRID-->/$list/g;

	&_output($self,$html);

	return;
}

sub _load_tmpl(){
	my $tmpl = shift;
	my $self = shift;

	my $file;
	my $accesstype = &access_check();
	if($accesstype eq 3){
		$file = qq{/var/www/vhosts/goo.to/etc/makehtml/goo/job_tmpl/$tmpl};
	}else{
		$file = qq{/var/www/vhosts/goo.to/etc/makehtml/goo/job_tmpl/$tmpl};
#		$file = qq{/var/www/vhosts/goo.to/etc/makehtml/goo/job_pc_tmpl/$tmpl};
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

sub _output(){
	my $self = shift;
	my $html = shift;
	
	my $accesstype = &access_check();
	my $key = &_memcashe_key();
	my $flag=1;
	if($self->{cgi}->param('photoid')){
		$flag=undef;
	}
	if($self->{cgi}->param('search')){
		$flag=undef;
	}
	if($flag){
		$self->{mem}->set($key, $html, 60 * 60 * 2);
	}
print $self->{cgi}->header(-type=>"text/html", -charset=>"UTF-8");
print $self->{cgi}->html( $html );

	return;
}

sub _parts_set(){
	my $html = shift;
	my $self = shift;

	# meta
	my $meta = &_load_tmpl("meta.html", $self);
	$html =~s/<!--META-->/$meta/g;
	# header
	my $header = &_load_tmpl("header.html", $self);
	$html =~s/<!--HEADER-->/$header/g;
	# header
	my $top_html = &_load_tmpl("top_html.html", $self);
	$html =~s/<!--TOP_HTML-->/$top_html/g;
	my $thtml = &_load_tmpl("html.html", $self);
	$html =~s/<!--HTML-->/$thtml/g;
	# footer
	my $footer = &_load_tmpl("footer.html", $self);
	$html =~s/<!--FOOTER-->/$footer/g;

	my $mem_id = $self->{mem_id};
	$html =~s/<!--MEMID-->/$mem_id/g;
	
	# ad
	my $ad_header;
	my $ad_imobile;
	
	my $accesstype = &access_check();
	if($accesstype eq 3){
		$ad_header = &_load_tmpl("adlantice.html", $self);
		$ad_imobile = &_load_tmpl("imobile.html", $self);
	}else{
		$ad_header = &_load_tmpl("imobilepc.html", $self);
		$ad_imobile = &_load_tmpl("imobilepc.html", $self);
	}
	$html =~s/<!--AD_HEADER-->/$ad_header/g;
	$html =~s/<!--AD_IMOBILE-->/$ad_imobile/g;


	if($self->{cgi}->param('page')){
		my $pre_page = $self->{cgi}->param('page') - 1;
		my $next_page = $self->{cgi}->param('page') + 1;
		$html =~s/<!--PRE_PAGE-->/$pre_page/g;
		$html =~s/<!--NEXT_PAGE-->/$next_page/g;
	}

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

	my $memd = new Cache::Memcached::Fast {
    'servers' => [ "localhost:11211" ],
    'compress_threshold' => 10_000,
	};

	return $memd;
}
sub _memcashe_key(){
	my $accesstype = &access_check();
	my $key = qq{jobgooto}.$accesstype.$ENV{REQUEST_URI};
	return $key;
}

# db connect
sub _db_connect(){
    my $dsn = 'DBI:mysql:waao';
    my $user = 'mysqlweb';
    my $password = 'WaAoqzxe7h6yyHz';

    my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 0, AutoCommit => 1, PrintError => 0});
	
	return $dbh;
}

sub _star_img(){
	my $point = shift;
	
	my $str;
	if($point >= 100){
		$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png">};
	}elsif($point >= 90){
		$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-half.png">};
	}elsif($point >= 80){
		$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-off.png">};
	}elsif($point >= 70){
		$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-half.png"><img src="/img/star-off.png">};
	}elsif($point >= 60){
		$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-off.png"><img src="/img/star-off.png">};
	}elsif($point >= 50){
		$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-half.png"><img src="/img/star-off.png"><img src="/img/star-off.png">};
	}elsif($point >= 40){
		$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">};
	}elsif($point >= 30){
		$str = qq{<img src="/img/star-on.png"><img src="/img/star-half.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">};
	}elsif($point >= 20){
		$str = qq{<img src="/img/star-on.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">};
	}elsif($point >= 10){
		$str = qq{<img src="/img/star-half.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">};
	}else{
		$str = qq{<img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">};
	}
	return $str;
}

1;