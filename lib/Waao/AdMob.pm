package Waao::AdMob;
use Exporter;
@ISA = (Exporter);
@EXPORT = qw(admob_ad);

 # AdMob Publisher Code
# Language: Perl
# Version: 20081105
# Copyright AdMob, Inc., All Rights Reserved
# Documentation at http://developer.admob.com/wiki/Main_Page

use LWP::UserAgent;
use Digest::MD5 qw(md5_hex);
use Time::HiRes qw(time); # standard in perl 5.10.0, or download from cpan, or comment this line out
use Time::Local;
use constant TRUE => 1;
use constant FALSE => 0;

sub admob_ad(){

# Parameters needed to make an AdMob request
my %admob_required_params = 
    ('PUBLISHER_ID'	=> 'a14de0bffb8fe0c', # Required to request ads. To find your Publisher ID, log in to your AdMob account and click on the "Sites & Apps" tab.
     'ANALYTICS_ID'	=> 'your_analytics_site_id', # Required to collect Analytics data. To find your Analytics ID, log in to your Analytics account and click on the "Edit" link next to the name of your site.
     'AD_REQUEST'	=> TRUE,  # To request an ad, set to TRUE.
     'ANALYTICS_REQUEST' => FALSE,  # To enable the collection of analytics data, set to TRUE.
     'TEST_MODE' => FALSE,  # While testing, set to TRUE. When you are ready to make live requests, set to FALSE.
     'SID' => '' # The current session id. Admob uses a MD5 hash of the session id to anonymously identify users. 
    );

# Additional optional parameters are available at: http://developer.admob.com/wiki/AdCodeDocumentation
my %admob_optional_params = ();

# Optional parameters for AdMob Analytics (http://analytics.admob.com)
#$admob_optional_params{'title'} = 'Insert Page Title Here';	# Analytics allows you to track site usage based on custom page titles. Enter custom title in this parameter.
#$admob_optional_params{'event'} = 'Insert Event Name Here';  # To learn more about events, log in to your Analytics account and visit this page: http://analytics.admob.com/reports/events/add

# This code supports the ability for your website to set a cookie on behalf of AdMob
# To set an AdMob cookie, simply call admob_setcookie() on any page that you call admob_request()
# The call to admob_setcookie() must occur before the HTTP headers have been sent
# If your mobile site uses multiple subdomains (e.g. "a.example.com" and "b.example.com"), pass the root domain (e.g. "example.com") as a parameter to admob_setcookie() to make the AdMob cookie visible across subdomains.
#admob_setcookie("example.com");

# AdMob strongly recommends using cookies as it allows us to better uniquely identify users on your website.
# This benefits your mobile site by providing:
#    - Improved ad targeting = higher click through rates = more revenue!
#    - More accurate analytics data (analytics.admob.com)

# Send request to AdMob. To make additional ad requests per page, copy and paste this function call elsewhere on your page.

print admob_request(\%admob_required_params, \%admob_optional_params);
}
###############################
# Do not edit below this line #
###############################

# This section defines AdMob functions and should be used AS IS.
# We recommend placing the following code in a separate file that is included where needed. 

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