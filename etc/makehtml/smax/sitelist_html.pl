#!/usr/bin/perl
use lib qw(/var/www/vhosts/goo.to/etc/lib /var/www/vhosts/goo.to/lib/Waao);

use strict;
use Utility;
use DBI;
use Jcode;
use Seolinks;
use LWP::UserAgent;

my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-smf/smfsite/};
mkdir($dirname, 0755);

# top
&_top();
&_sitelist();

exit;

sub _top(){
	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-smf/smfsite/};

	my $html;
	my $url = qq{http://smax.tv/sitelist.html};
	my $ua = new LWP::UserAgent();
	print $url."\n";
	$ua->timeout(3);
#	$ua->agent("Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_2_1 like Mac OS X; ja-jp) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8C148 Safari/6533.18.5"); 
	my $request = HTTP::Request->new(GET =>"$url");
	my $res = $ua->request($request);
	unless ($res->is_success) {
		return;
	}else{
		$html = $res->content;
	}

	my $filename = qq{$dirname}.qq{index.htm};
	open(OUT,"> $filename") || die('error');
	print OUT "$html";
	close(OUT);
	print $filename."\n";

	return;
}

sub _sitelist(){

	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-smf/smfsite/};

	for(my $sitecate=1;$sitecate<=35;$sitecate++){
		for(my $page=0;$page<=30;$page++){
			my $html;
			my $url = qq{http://smax.tv/sitelist.html?type=$sitecate&page=$page};
			my $ua = new LWP::UserAgent();
			print $url."\n";
			$ua->timeout(3);
#			$ua->agent("Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_2_1 like Mac OS X; ja-jp) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8C148 Safari/6533.18.5"); 
			my $request = HTTP::Request->new(GET =>"$url");
			my $res = $ua->request($request);
			unless ($res->is_success) {
				next;
			}else{
				$html = $res->content;
			}

			my $filename = qq{$dirname}.qq{$sitecate-$page.htm};
			open(OUT,"> $filename") || die('error');
			print OUT "$html";
			close(OUT);
			print $filename."\n";

		}
	}

	return;
}

