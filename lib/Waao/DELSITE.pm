package Waao::DELSITE;

use DBI;
use CGI;
#use HTTP::MobileAgent;
use Cache::Memcached;
use Waao::Api;
use XML::Simple;
use LWP::Simple;
use Jcode;
use CGI qw( escape );

use LWP::UserAgent;
use Time::HiRes qw(gettimeofday);
use URI::Escape;


sub dispatch(){
	my $self = shift;

	# PC/mobile/SMF判定
	$self =&_mobile_access_check($self);

	my $pagedsp;
	$pagedsp = 1 if( $ENV{'HTTP_HOST'} eq 'accessup.goo.to' );
	$pagedsp = 1 if( $ENV{'HTTP_HOST'} eq 'search.goo.to' );
	$pagedsp = 1 if( $ENV{'HTTP_HOST'} eq 'bookmark.goo.to' );
	$pagedsp = 1 if( $ENV{'HTTP_HOST'} eq 'keyword.goo.to' );
	$pagedsp = 1 if( $ENV{'HTTP_HOST'} eq 'ranking.goo.to' );
	$pagedsp = 1 if( $ENV{'HTTP_HOST'} eq 'x.goo.to' );
	$pagedsp = 1 if( $ENV{'HTTP_HOST'} eq 'x.obei.jp' );
	$pagedsp = 1 if( $ENV{'HTTP_HOST'} eq 'x.goodgirl.jp' );
	$pagedsp = 1 if( $ENV{'HTTP_HOST'} eq 'x.tsukaeru.net' );
	$pagedsp = 1 if( $ENV{'HTTP_HOST'} eq 'x.soteigai.jp' );
	$pagedsp = 1 if( $ENV{'HTTP_HOST'} eq 'x.bonyari.jp' );
	$pagedsp = 1 if( $ENV{'HTTP_HOST'} eq 'x.gokigen.com' );
	$pagedsp = 1 if( $ENV{'HTTP_HOST'} eq 'x.rakusite.com' );
	$pagedsp = 1 if( $ENV{'HTTP_HOST'} eq 'x.tsukaeru.info' );
	
	if($pagedsp){

		my $tmpl=qq{pc.html};
		if($self->{access_type} eq 4){
			$tmpl = qq{smf.html};
		}elsif($self->{mobile_access}){
			$tmpl = qq{mobile.html};
		}else{
			$tmpl = qq{pc.html};
		}
		my $html = &_load_tmpl($tmpl);
		if($self->{mobile_access}){
			my $google_ad = &_get_google();
			$html =~s/<!--AD-->/$google_ad/g;
		}
print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

		return;
	}

	if($self->{access_type} eq 4){
		print "Location: http://smax.tv/\n\n";
	}elsif($self->{mobile_access}){
		print "Location: http://waao.jp/\n\n";
	}else{
		print "Location: http://waao.jp/\n\n";
	}

	return;
}

sub _get_google(){
	my $google_dt = sprintf("%.0f", 1000 * gettimeofday());
	my $google_scheme = ($ENV{"HTTPS"} eq "on") ? "https://" : "http://";
	my $google_user_agent = uri_escape($ENV{"HTTP_USER_AGENT"});

	my $google_ad_url = "http://pagead2.googlesyndication.com/pagead/ads?" .
  "client=ca-mb-pub-5986324515643074" .
  "&dt=" . $google_dt .
  "&ip=" . uri_escape($ENV{"REMOTE_ADDR"}) .
  "&markup=chtml" .
  "&output=chtml" .
  "&ref=" . uri_escape($ENV{"HTTP_REFERER"}) .
  "&slotname=8148094692" .
  "&url=" . uri_escape($google_scheme . $ENV{"HTTP_HOST"} . $ENV{"REQUEST_URI"}) .
  "&useragent=" . $google_user_agent .
  google_append_screen_res() .
  google_append_muid() .
  google_append_via_and_accept($google_user_agent);

	my $google_ua = LWP::UserAgent->new;
	my $google_ad_output = $google_ua->get($google_ad_url);
	if ($google_ad_output->is_success) {
	  return $google_ad_output->content;
	}
	return;
}

# access_check
# sid 取得
sub _mobile_access_check(){
	my $self = shift;

    if( $ENV{'REMOTE_HOST'} =~/docomo/i ){
    	$self->{mobile_access} =1;
    	$self->{access_type} =1;
    	$self->{real_mobile} =1;
    }elsif( $ENV{'REMOTE_HOST'} =~/ezweb/i ){
    	$self->{mobile_access} =1;
    	$self->{access_type} =2;
    	$self->{real_mobile} =1;
    }elsif( $ENV{'REMOTE_HOST'} =~/^J-PHONE|^Vodafone|^SoftBank/i ){
    	$self->{mobile_access} =1;
    	$self->{access_type} =3;
    	$self->{real_mobile} =1;
    }elsif( $ENV{'REMOTE_HOST'} =~/panda-world\.ne\.jp/i ){
    	$self->{mobile_access} =1;
    	$self->{access_type} =4;
    	$self->{real_mobile} =1;
	}elsif( $ENV{'HTTP_USER_AGENT'} =~/iPhone|iPod|Android|dream|CUPCAKE|blackberry|webOS|incognito|webmate/i ){
    	$self->{mobile_access} =1;
    	$self->{access_type} =4;
    	$self->{real_mobile} =1;
	}elsif( $ENV{'HTTP_USER_AGENT'} =~/Google-Site/i ){
    	$self->{mobile_access} =1;
	}elsif( $ENV{'HTTP_USER_AGENT'} =~/www\.valuecommerce\.ne\.jp/i ){
    	$self->{mobile_access} =1;
    }elsif( $ENV{'REMOTE_HOST'} =~/hinocatv/i ){
    	$self->{mobile_access} =1;
    	$self->{access_type} =9;
    }
	return $self;
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
	
my $file = qq{/var/www/vhosts/waao.jp/httpdocs-r-rakushite/$tmpl};


my $fh;
my $filedata;
open( $fh, "<", $file );
while( my $line = readline $fh ){ 
	$filedata .= $line;
}
close ( $fh );

	return $filedata;
}

sub google_append_color {
  my @color_array = split(/,/, $_[0]);
  return $color_array[$_[1] % @color_array];
}

sub google_append_screen_res {
  my $screen_res = $ENV{"HTTP_UA_PIXELS"};
  if ($screen_res == "") {
    $screen_res = $ENV{"HTTP_X_UP_DEVCAP_SCREENPIXELS"};
  }
  if ($screen_res == "") {
    $screen_res = $ENV{"HTTP_X_JPHONE_DISPLAY"};
  }
  my @res_array = split("[x,*]", $screen_res);
  if (@res_array == 2) {
    return "&u_w=" . $res_array[0] . "&u_h=" . $res_array[1];
  }
}

sub google_append_muid {
  my $muid = $ENV{"HTTP_X_DCMGUID"};
  if ($muid) {
    return "&muid=" . $muid;
  }
  my $muid = $ENV{"HTTP_X_UP_SUBNO"};
  if ($muid) {
    return "&muid=" . $muid;
  }
  my $muid = $ENV{"HTTP_X_JPHONE_UID"};
  if ($muid) {
    return "&muid=" . $muid;
  }
  my $muid = $ENV{"HTTP_X_EM_UID"};
  if ($muid) {
    return "&muid=" . $muid;
  }
}

sub google_append_via_and_accept {
  if ($_[0] eq "") {
    my $via_and_accept;
    my $via = uri_escape($ENV{"HTTP_VIA"});
    if ($via) {
      $via_and_accept = "&via=" . $via;
    }
    my $accept = uri_escape($ENV{"HTTP_ACCEPT"});
    if ($accept) {
      $via_and_accept = $via_and_accept . "&accept=" . $accept;
    }
    if ($via_and_accept) {
      return $via_and_accept;
    }
  }
}

1;