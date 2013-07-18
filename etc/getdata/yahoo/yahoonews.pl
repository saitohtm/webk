#!/usr/bin/perl
# IMG GETæ“¾ƒvƒƒOƒ‰ƒ€

#use strict;
use DBI;
use Cache::Memcached;
use CGI qw( escape );
use Unicode::Japanese;
use LWP::UserAgent;
use Jcode;
use utf8;
use Date::Simple ('date', 'today');

my $dsn = 'DBI:mysql:waao';
my $user = 'mysqlweb';
my $password = 'WaAoqzxe7h6yyHz';

my $keylist;
$keylist->{entertainment} = 1;
$keylist->{sports} = 2;
$keylist->{domestic} = 3;
$keylist->{world} = 4;
$keylist->{economy} = 5;
$keylist->{computer} = 6;
$keylist->{science} = 7;

foreach my $key (keys %{$keylist}){
	&_get_news($key, $keylist->{$key});
}

exit;

sub _get_news(){
my $categorystr = shift;
my $category_id = shift;

my $get_url = qq{http://news.yahooapis.jp/NewsWebService/V2/topics?appid=goooooto&category=$categorystr&midashiflg=1&sort=datetime&order=d};

my $newsdata;
my $ua = LWP::UserAgent->new;
$ua->timeout(3);
my $request = HTTP::Request->new(GET =>"$get_url");
	#print "$get_url\n";
my $res = $ua->request($request);
unless ($res->is_success) {
	#print "ERR";
	next;
}else{
	$newsdata = $res->content;
}
my @lines = split(/\n/,$newsdata);
my ($date, $title, $category, $pv, $keylist, $url);
my $dataflag=0;
my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 1, AutoCommit => 0});
foreach my $line (@lines){
	if( $line=~/<Result>/){
		$dataflag = 1;
	}
	if( $line=~/(.*)<DateTime>(.*)T(.*)<\/DateTime>/){
		$date = $2;
	}
	if( $line=~/(.*)<Title>(.*)<\/Title>/){
		$title = $2;
	}
	if( $line=~/(.*)<Overview>(.*)<\/Overview>/){
		$keylist = $2;
	}
	if( $line=~/(.*)<Url>(.*)<\/Url>/){
		$url = $2;
	}
#print $date."\n";
#print $title."\n";
#print $category."\n";
#print $keylist."\n";
#print $category_id."\n";
	if( $line=~/<\/Result>/){
		# DB “o˜^
		eval{
			my $sth = $dbh->prepare(
		        qq{insert into news ( `datestr`,`title`,`category`,`keylist`,`categoryflag`,`url`) values (?,?,?,?,?,?)}
				);

			$sth->execute($date, $title, $category, $keylist, $category_id, $url);
		};
		
		$dataflag = 0;
		($date, $title, $category, $pv) = undef;
	}
}
$dbh->disconnect;

return;
}

sub _keylist(){
	my $title = shift;
	my $keylist;
	
	my $encodekey = escape ( $title );
	my $get_url = qq{http://api.jlp.yahoo.co.jp/MAService/V1/parse?appid=goooooto&results=uniq&filter=9&sentence=$encodekey};

	my $analist;
	my $ua = LWP::UserAgent->new;
	$ua->timeout(3);
	my $request = HTTP::Request->new(GET =>"$get_url");
	my $res = $ua->request($request);
	unless ($res->is_success) {
		next;
	}else{
		$analist = $res->content;
	}

	$analist =~s/<\/surface>/<\/surface>\n/g;
	# sjis
	my $sjistitle = $title;

	my @lines = split(/\n/,$analist);
	my $keyhash;
	foreach my $line (@lines){
		if( $line=~/(.*)<surface>(.*)<\/surface>/){
			next if(length($2) < 2);
			$keylist .= $2."\t";
		}
	}	
#	chop $keylist;
	#print $sjistitle;
	my $keylist = $keylist;
	#print $keylist;
	return ($sjistitle, $keylist);
}
