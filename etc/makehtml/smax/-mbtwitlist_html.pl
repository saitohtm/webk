#!/usr/bin/perl
use lib qw(/var/www/vhosts/goo.to/etc/lib /var/www/vhosts/goo.to/lib/Waao);

use strict;
use Utility;
use Jcode;
use Seolinks;
use LWP::UserAgent;

# twit_top
&_twit_top();

# twit_list
&_twit();

exit;

sub _twit(){

my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-twitmax/listtwit/};
mkdir($dirname, 0755);
for(my $twitid = 0;$twitid<=20;$twitid++){
	for(my $page = 0;$page<=100;$page++){
		&_twitlist($twitid,$page);
	}
}

}

sub _twitlist(){
	my $twitid = shift;
	my $page = shift;
	
	my $geinou = &html_mojibake_str("geinou");

	my $html;
	my $url = qq{http://twitter.tsukaeru.info/index.html?cate=$twitid&page=$page};
	print $url."\n";
	my $ua = new LWP::UserAgent();
	$ua->timeout(3);
	$ua->agent("Googlebot-Mobile"); 
	my $request = HTTP::Request->new(GET =>"$url");
	my $res = $ua->request($request);
	my $ykey;
	unless ($res->is_success) {
		return;
	}else{
		$html = $res->content;
	}

	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-twitmax/listtwit/$twitid/};
	mkdir($dirname, 0755);

#	$html = Jcode->new($html, 'sjis')->utf8;
		
	my $filename = qq{$dirname$page.htm};
	open(OUT,"> $filename") || die('error');
	print OUT "$html";
	close(OUT);
	print $filename."\n";


	return;
}

sub _twit_top(){

#	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-smf/listtwit/};

	my $html;
	my $url = qq{http://twitter.tsukaeru.info/index.html};
	my $ua = new LWP::UserAgent();
	$ua->timeout(3);
	$ua->agent("Googlebot-Mobile"); 
	my $request = HTTP::Request->new(GET =>"$url");
	my $res = $ua->request($request);
	my $ykey;
	unless ($res->is_success) {
		return;
	}else{
		$html = $res->content;
	}

	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-twitmax/};
#	mkdir($dirname, 0755);

#	$html = Jcode->new($html, 'sjis')->utf8;
		
	my $filename = $dirname.qq{index.htm};
	open(OUT,"> $filename") || die('error');
	print OUT "$html";
	close(OUT);
	print $filename."\n";
	
	return;
}
