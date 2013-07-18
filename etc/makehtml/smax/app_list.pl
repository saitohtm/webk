#!/usr/bin/perl
use lib qw(/var/www/vhosts/goo.to/etc/lib /var/www/vhosts/goo.to/lib/Waao);

use strict;
use Utility;
use DBI;
use Jcode;
use Seolinks;
use LWP::UserAgent;

my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-smf/app/iphone/};
mkdir($dirname, 0755);
my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-smf/app/android/};
mkdir($dirname, 0755);

# top
&_top();
# list
&_list("iphone");
&_list("android");


exit;

sub _top(){

	my $html;
	my $url = qq{http://smax.tv/takarakuji.html};
	my $ua = new LWP::UserAgent();
	$ua->timeout(3);
	$ua->agent("Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_2_1 like Mac OS X; ja-jp) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8C148 Safari/6533.18.5"); 
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

sub _miniloto(){

	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-smf/loto/miniloto/};
	mkdir($dirname, 0755);

	my $dbh = &_db_connect();

	my $cnt;
	my $sth = $dbh->prepare(qq{select id from miniloto });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$cnt++;

		my $html;
		my $url = qq{http://smax.tv/takarakuji.html?minilotoid=$row[0]};
		my $ua = new LWP::UserAgent();
		$ua->timeout(3);
		$ua->agent("Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_2_1 like Mac OS X; ja-jp) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8C148 Safari/6533.18.5"); 
		my $request = HTTP::Request->new(GET =>"$url");
		my $res = $ua->request($request);
		unless ($res->is_success) {
			next;
		}else{
			$html = $res->content;
		}

		my $filename = qq{$dirname}.qq{$row[0].htm};
		open(OUT,"> $filename") || die('error');
		print OUT "$html";
		close(OUT);
		print $filename."\n";
		
	}
	$dbh->disconnect;

	my $maxcnt = int(($cnt / 30)) + 1;

	for(my $i=1; $i<$maxcnt; $i++){
		my $html;
		my $url = qq{http://smax.tv/takarakuji.html?miniloto=1&page=$i};
		my $ua = new LWP::UserAgent();
		$ua->timeout(3);
		$ua->agent("Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_2_1 like Mac OS X; ja-jp) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8C148 Safari/6533.18.5"); 
		my $request = HTTP::Request->new(GET =>"$url");
		my $res = $ua->request($request);
		unless ($res->is_success) {
			next;
		}else{
			$html = $res->content;
		}

		my $filename = qq{/var/www/vhosts/goo.to/httpdocs-smf/loto/}.qq{miniloto-$i.htm};
		open(OUT,"> $filename") || die('error');
		print OUT "$html";
		close(OUT);
		print $filename."\n";
	}

	return;
}

sub _loto6(){

	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-smf/loto/loto6/};
	mkdir($dirname, 0755);

	my $dbh = &_db_connect();

	my $cnt;
	my $sth = $dbh->prepare(qq{select id from loto6 });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$cnt++;

		my $html;
		my $url = qq{http://smax.tv/takarakuji.html?loto6id=$row[0]};
		my $ua = new LWP::UserAgent();
		$ua->timeout(3);
		$ua->agent("Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_2_1 like Mac OS X; ja-jp) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8C148 Safari/6533.18.5"); 
		my $request = HTTP::Request->new(GET =>"$url");
		my $res = $ua->request($request);
		unless ($res->is_success) {
			next;
		}else{
			$html = $res->content;
		}

		my $filename = qq{$dirname}.qq{$row[0].htm};
		open(OUT,"> $filename") || die('error');
		print OUT "$html";
		close(OUT);
		print $filename."\n";
		
	}
	$dbh->disconnect;

	my $maxcnt = int(($cnt / 30)) + 1;

	for(my $i=1; $i<$maxcnt; $i++){
		my $html;
		my $url = qq{http://smax.tv/takarakuji.html?loto6=1&page=$i};
		my $ua = new LWP::UserAgent();
		$ua->timeout(3);
		$ua->agent("Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_2_1 like Mac OS X; ja-jp) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8C148 Safari/6533.18.5"); 
		my $request = HTTP::Request->new(GET =>"$url");
		my $res = $ua->request($request);
		unless ($res->is_success) {
			next;
		}else{
			$html = $res->content;
		}

		my $filename = qq{/var/www/vhosts/goo.to/httpdocs-smf/loto/}.qq{loto6-$i.htm};
		open(OUT,"> $filename") || die('error');
		print OUT "$html";
		close(OUT);
		print $filename."\n";
	}

	return;
}

sub _db_connect(){
	my $dsn = 'DBI:mysql:waao';
	my $user = 'mysqlweb';
	my $password = 'WaAoqzxe7h6yyHz';

	my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 1, AutoCommit => 0});

	return $dbh;
}
