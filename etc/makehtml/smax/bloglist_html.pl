#!/usr/bin/perl
use lib qw(/var/www/vhosts/goo.to/etc/lib /var/www/vhosts/goo.to/lib/Waao);

use strict;
use Utility;
use Jcode;
use Seolinks;
use LWP::UserAgent;

# bloglist page
my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-smf/listblog/};
mkdir($dirname, 0755);
for(my $blogid = 1;$blogid<=100;$blogid++){
	for(my $page = 0;$page<=100;$page++){
		&_bloglist($blogid,$page);
	}
}

exit;

sub _bloglist(){
	my $blogid = shift;
	my $page = shift;
	
	my $html;
	my $url = qq{http://smax.tv/blog.html?cate=$blogid&page=$page};
	my $ua = new LWP::UserAgent();
	$ua->timeout(3);
#	$ua->agent("Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_2_1 like Mac OS X; ja-jp) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8C148 Safari/6533.18.5"); 
	my $request = HTTP::Request->new(GET =>"$url");
	my $res = $ua->request($request);
	my $ykey;
	unless ($res->is_success) {
		return;
	}else{
		$html = $res->content;
	}

	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-smf/listblog/$blogid/};
	mkdir($dirname, 0755);

	my $filename = qq{$dirname$page.htm};
	open(OUT,"> $filename") || die('error');
	print OUT "$html";
	close(OUT);
	print $filename."\n";


	return;
}

