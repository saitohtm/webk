#!/usr/bin/perl
use lib qw(/var/www/vhosts/goo.to/etc/lib /var/www/vhosts/goo.to/lib/Waao);

use strict;
use Utility;
use Jcode;
use Seolinks;
use LWP::UserAgent;

# top page
&_top();

exit;

sub _top(){

	my $html;
	my $url = qq{http://smax.tv/index.html};
	my $ua = new LWP::UserAgent();
	$ua->timeout(3);
	$ua->agent("Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_2_1 like Mac OS X; ja-jp) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8C148 Safari/6533.18.5"); 
	my $request = HTTP::Request->new(GET =>"$url");
	my $res = $ua->request($request);
	my $ykey;
	unless ($res->is_success) {
		return;
	}else{
		$html = $res->content;
	}

	my $filename = qq{/var/www/vhosts/goo.to/httpdocs-smf/index.htm};
	open(OUT,"> $filename") || die('error');
	print OUT "$html";
	close(OUT);
	print $filename."\n";


	return;
}

