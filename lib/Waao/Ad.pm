package Waao::Ad;
use Exporter;
use LWP::UserAgent;
use Time::HiRes qw(gettimeofday time);
use URI::Escape;
use Socket;
use Digest::MD5 qw(md5_hex);
use Time::Local;
use constant TRUE => 1;
use constant FALSE => 0;

@ISA = (Exporter);
@EXPORT = qw(get_google_ad atck get_yicha_url get_amazon_ad);

my %admob_required_params = 
    ('PUBLISHER_ID'	=> 'a14ceaff54c8999', # Required to request ads. To find your Publisher ID, log in to your AdMob account and click on the "Sites & Apps" tab.
     'ANALYTICS_ID'	=> 'your_analytics_site_id', # Required to collect Analytics data. To find your Analytics ID, log in to your Analytics account and click on the "Edit" link next to the name of your site.
     'AD_REQUEST'	=> TRUE,  # To request an ad, set to TRUE.
     'ANALYTICS_REQUEST' => FALSE,  # To enable the collection of analytics data, set to TRUE.
     'TEST_MODE' => FALSE,  # While testing, set to TRUE. When you are ready to make live requests, set to FALSE.
     'SID' => '' # The current session id. Admob uses a MD5 hash of the session id to anonymously identify users. 
    );
my %admob_optional_params = ();

sub get_google_ad {
	my $self = shift;

	return unless( $self->{mobile_access} );

	my $ad;
	# ロボット に表示させる？
	unless($self->{access_type}){
		return $ad;
	}
	# iphone
	if($self->{access_type} eq 4){
		$ad = q{<script type="text/javascript"><!--
window.googleAfmcRequest = {
  client: 'ca-mb-pub-2078370187404934',
  ad_type: 'text_image',
  output: 'html',
  channel: '',
  format: '320x50_mb',
  oe: 'utf8',
  color_border: '336699',
  color_bg: 'FFFFFF',
  color_link: '0000FF',
  color_text: '000000',
  color_url: '008000',
};
//--></script>
<script type="text/javascript" 
   src="http://pagead2.googlesyndication.com/pagead/show_afmc_ads.js"></script>
};
		return $ad;
	}

	# 
	$ad = &_get_google_adsence($self);

	unless($ad){
#		$ad = &admob_request(\%admob_required_params, \%admob_optional_params);
#		if($ad=~/\<a/){
#		}else{
#			$ad = undef;
#		}
	}
	unless($ad){
		$ad = qq{<a href="http://cgi.i-mobile.co.jp/ad_link.aspx?guid=on&asid=22272&pnm=0&asn=1"><img border="0" src="http://cgi.i-mobile.co.jp/ad_img.aspx?guid=on&asid=22272&pnm=0&asn=1&asz=0&atp=3&lnk=6666ff&bg=&txt=000000" alt="i-mobile"></a>
};
	}
	return $ad;
}


sub _get_google_adsence(){
	my $self = shift;

my $ad_str;

my $ret_flag;

if($ENV{'SERVER_NAME'} eq 'goo.goodgirl.jp'){
	$ret_flag = 1;
}elsif($ENV{'SERVER_NAME'} eq 'bookmark.goo.to'){
	$ret_flag = 1;
}elsif($ENV{'SERVER_NAME'} eq 'x.goo.to'){
	$ret_flag = 1;
}elsif($ENV{'SERVER_NAME'} eq 'x.tsukaeru.info'){
	$ret_flag = 1;
}elsif($ENV{'SERVER_NAME'} eq 'x.soteigai.jp'){
	$ret_flag = 1;
}elsif($ENV{'SERVER_NAME'} eq 'x.obei.jp'){
	$ret_flag = 1;
}elsif($ENV{'SERVER_NAME'} eq 'goo.rakusite.com'){
	$ret_flag = 1;
}elsif($ENV{'SERVER_NAME'} eq 'green.soteigai.jp'){
	$ret_flag = 1;
}

my $env_http_host = $ENV{"HTTP_HOST"};

# 確実に出すドメイン
if($ENV{'SERVER_NAME'} eq 'chintai.goo.to'){
	$ret_flag=undef;
}elsif($ENV{'SERVER_NAME'} eq 'town.goo.to'){
	$ret_flag=undef;
}elsif($ENV{'SERVER_NAME'} eq 'job.goo.to'){
	$ret_flag=undef;
}elsif($ret_flag eq 1){
}elsif( $self->{cgi}->param('q') ){
	# 正式なデータかチェック
	$ret_flag=1;
	my $sth = $self->{dbi}->prepare(qq{ select rev_id from wikipedia where keyword = ? limit 1} );
	$sth->execute($self->{cgi}->param('q'));
	while(my @row = $sth->fetchrow_array) {
		$ret_flag=undef;
	}
	$sth = $self->{dbi}->prepare(qq{ select person, av, artist, model, ana from keyword where keyword = ? limit 1} );
	$sth->execute( $self->{cgi}->param('q') );
	while(my @row = $sth->fetchrow_array) {
		$ret_flag=undef if($row[0]);
		$ret_flag=undef if($row[2]);
		$ret_flag=undef if($row[3]);
		$ret_flag=undef if($row[4]);
		$ret_flag=1 if($row[1]);
	}
	$env_http_host = q{ad.tsukaeru.info};
}

return if($ret_flag);

my $env_remote_addr = $ENV{"REMOTE_ADDR"};
my $env_http_referer = $ENV{"HTTP_REFERER"};
my $env_request_uri = $ENV{"REQUEST_URI"};

my $google_dt = sprintf("%.0f", 1000 * gettimeofday());
my $google_scheme = ($ENV{"HTTPS"} eq "on") ? "https://" : "http://";
my $google_host = uri_escape($google_scheme . $env_http_host);
my $google_user_agent = uri_escape($ENV{"HTTP_USER_AGENT"});

my $google_ad_url = "http://pagead2.googlesyndication.com/pagead/ads?" .
  "ad_type=text_image" .
  "&channel=" .
  "&client=ca-mb-pub-2078370187404934" .
  "&color_border=" . google_append_color("555555", $google_dt) .
  "&color_bg=" . google_append_color("EEEEEE", $google_dt) .
  "&color_link=" . google_append_color("FF0000", $google_dt) .
  "&color_text=" . google_append_color("000000", $google_dt) .
  "&color_url=" . google_append_color("008000", $google_dt) .
  "&dt=" . $google_dt .
  "&format=mobile_single" .
  "&ip=" . uri_escape($env_remote_addr) .
  "&markup=chtml" .
  "&oe=sjis" .
  "&output=chtml" .
  "&ref=" . uri_escape($env_http_referer) .
  "&url=" . uri_escape($google_scheme . $env_http_host . $env_request_uri) .
  "&useragent=" . $google_user_agent .
  google_append_screen_res() .
  google_append_muid() .
  google_append_via_and_accept($google_user_agent);

	my $google_ua = LWP::UserAgent->new;
	$google_ua->timeout(3);
	my $google_ad_output = $google_ua->get($google_ad_url);
	if ($google_ad_output->is_success) {
	  $ad_str = $google_ad_output->content;
	}
	
	# 広告が取得できない場合
	unless($ad_str =~/Ads/){
		return;
	}
	
	return $ad_str;
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

sub atck
{
	my $self = shift;
	if($self->{session}->{_session_id} eq "robot"){
		return;
	}

	my $Rows="", $Category="01", $Num="1";
	if(($#_+1)>0){ ($Rows,$Category,$Num) = @_; }
	my $UA = $ENV{HTTP_USER_AGENT};
	my $IP = $ENV{REMOTE_ADDR};
	my $REF= $ENV{HTTP_REFERER};
	my $VER = "1.01";
	my $HOST = "rt.atclk.com";
	my $TO = 2;
	my $Port = getservbyname( 'http', 'tcp' );
	my $HIP = inet_aton($HOST);
	my $SCAddr = pack_sockaddr_in( $Port, $HIP );
	my $An="";
	my $Rin="";
	my $Buf="";
	my %USTR=("DoCoMo"=>0, "J-PHONE"=>1, "Vodafone"=>1, "SoftBank"=>1, "MOT-"=>1, "UP.Browser"=>2 );

	$REF =~ s/(\W)/'%'.unpack("H2", $1)/ego;
	foreach $STR (keys(%USTR)){if($UA=~/$STR/){$An=$USTR{$STR};last;}}
	$Header = "GET /r/r.php?p=1674,4313,$Rows,$Category,$Num,$An&ip=$IP&v=$VER&ref=$REF HTTP/1.0\r\nHost: $HOST\r\n\r\n";
	if(!socket(SC,PF_INET,SOCK_STREAM,0)){return $Buf;}
	if(!connect(SC,$SCAddr)){return $Buf;}
	select(SC);  $|=1; select(STDOUT);
	print SC $Header;
	vec($Rin,fileno(SC),1) = 1;
	while($ret=select($rout=$Rin,undef,undef,$TO)){if(<SC>=~(m/^\r\n$/)){last;}}
	if($ret){while($ret=select($rout=$Rin,undef,undef,$TO)){if($Tmp=<SC>){$Buf.=$Tmp;}else{last;}}}
	else{$Buf=" ";}
	if($Buf=~/<:>/){@Buf=split("<:>",$Buf);return @Buf;}
	
	return $Buf;
}

sub get_yicha_url(){
	my $self = shift;
	my $str  = shift;
	my $type = shift;

	# type
	# p サイト
	# v 動画
	# i 画像
	# m 音楽
	
	$type = 'p' unless($type);

	my $url;
	my $str_encode = &uri_escape($str);

	if( $self->{real_mobile} ){
		$url = qq{http://goo.to/yicha.htm};
	}else{
		# SEO リンクの設置
		$url = &_seo_link($str);
	}

	return $url;
}

sub get_amazon_ad(){
	my $self = shift;
	my $str  = shift;

	my $url;
	my $str_encode = &uri_escape($str);

	if( $self->{real_mobile} ){
		$url = qq{http://www.amazon.co.jp/gp/aw/rd.html?k=$str_encode&uid=NULLGWDOCOMO&at=gooto-22&m=Blended&url=/gp/aw/s.html&lc=mqs&__mk_ja_JP=カタカナ};
	}else{
		# SEO リンクの設置
		$url = &_seo_link($str);
	}
	return $url;
}

# ロボットに表示させるリンク
sub _seo_link(){
	my $str = shift;
	my $url;
	my $str_encode = &uri_escape($str);
	
	return $url;
	
}

sub admob_request {
  our $admob_pixel_sent;
  my %required_params = %{@_[0]};
  my %optional_params = %{@_[1]};
  my $ad_mode = FALSE;
  my $analytics_mode = FALSE;
  my $protocol = 'http';
  
  $ad_mode = TRUE if ($required_params{'AD_REQUEST'} && $required_params{'PUBLISHER_ID'});
  $analytics_mode = TRUE if ($required_params{'ANALYTICS_REQUEST'} && $required_params{'ANALYTICS_ID'} && !$admob_pixel_sent);
  $protocol = 'https' if ($ENV{'HTTPS'} ne '');
  
  my $rt = $ad_mode ? ($analytics_mode ? 2 : 0) : ($analytics_mode ? 1 : -1);
  return '' if ($rt == -1);

  my $page_url = "$protocol://" . $ENV{'HTTP_HOST'} . $ENV{'REQUEST_URI'};
  my %admob_post = ('rt'	=> $rt,
                    'z'	=> time(),
                    'u'	=> $ENV{'HTTP_USER_AGENT'},                   
                    'i'	=> $ENV{'REMOTE_ADDR'}, 
                    'p'	=> $page_url, 
                    'v'	=> '20081105-PERL-260a52ba4ef3535d'
                   );

  $admob_post{'o'} = admob_getcookie() if (admob_getcookie());
  $admob_post{'t'} = md5_hex($required_params{'SID'}) if ($required_params{'SID'});
  $admob_post{'s'} = $required_params{'PUBLISHER_ID'} if ($ad_mode);
  $admob_post{'a'} = $required_params{'ANALYTICS_ID'} if ($analytics_mode);
  $admob_post{'m'} = 'test' if ($required_params{'TEST_MODE'});

  my %admob_ignore = ('HTTP_PRAGMA' => 1, 'HTTP_CACHE_CONTROL' => 1,'HTTP_CONNECTION' => 1, 'HTTP_USER_AGENT' => 1, 'HTTP_COOKIE' => 1);
  foreach my $name (keys(%ENV)) {
    if ($name =~ /^HTTP/ && !exists $admob_ignore{$name}) {
      $admob_post{"h[$name]"} = $ENV{$name};
    }	
  }

  for my $key (keys %optional_params) {
    $admob_post{$key} = $optional_params{$key};
  }
  
  my $admob_timeout = 1;		# 1 second timeout
  my $admob_request = LWP::UserAgent->new;
  $admob_request->timeout($admob_timeout);
  my $start = time();
  my $admob_response = $admob_request->post('http://r.admob.com/ad_source.php', \%admob_post);
  my $stop = time();
  my $admob_contents = $admob_response->content();
  $admob_contents = '' if ($admob_response->is_error());

  if (!$admob_pixel_sent) {
    $admob_pixel_sent = TRUE;
    $admob_contents .= "<img src=\"$protocol://p.admob.com/e0?"
                    . 'rt=' . $rt
                    . '&amp;z=' . $admob_post{'z'}
                    . '&amp;a=' . ($analytics_mode ? $required_params{'ANALYTICS_ID'} : '')
                    . '&amp;s=' . ($ad_mode ? $required_params{'PUBLISHER_ID'} : '')
                    . '&amp;o=' . $admob_post{'o'}
                    . '&amp;lt=' . ($stop-$start)
                    . '&amp;to=' . $admob_timeout
                    . '" alt="" width="1" height="1"/>';
  }   
  return $admob_contents;
}

sub admob_setcookie(;$) {
  our $admob_cookie;
  my $domain;
  if (@_ > 0) {
    $domain = @_[0];
    $domain = ".$domain" if (substr($domain, 0, 1) ne '.');
  }
  if (!admob_getcookie()) {
    $admob_cookie = md5_hex(rand() . $ENV{'REMOTE_ADDR'} . $ENV{'HTTP_USER_AGENT'} . time());
    my $expires = gmtime(timegm(0, 0, 0, 1, 0, 2038)) . " GMT";
    my $new_cookie = "Set-Cookie: admobuu=$admob_cookie; expires=$expires; path=/";
    $new_cookie = "$new_cookie; domain=$domain" if ($domain);
    print "$new_cookie\n";
  }
}

sub admob_getcookie {
  foreach (split(/; /, $ENV{'HTTP_COOKIE'})) {
    my @keyval = split(/=/, $_);
    if ($keyval[0] eq "admobuu") {
      return $keyval[1];
    } 
  }
  return our $admob_cookie;
}


1;