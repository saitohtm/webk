#!/usr/bin/perl
# IMG GETŽæ“¾ƒvƒƒOƒ‰ƒ€

#use strict;
use DBI;
use Cache::Memcached;
use CGI qw( escape );
use Unicode::Japanese;
use XML::Simple;
use LWP::Simple;
use URI::Escape;
use Data::Dumper;
use Jcode;
use utf8;
use encoding 'utf8', 
STDIN=>'utf8', STDOUT=>'utf8';
use Date::Simple ('date', 'today');

my $dsn = 'DBI:mysql:waao';
my $user = 'mysqlweb';
my $password = 'WaAoqzxe7h6yyHz';

&_get_news(qq{http://f1.gpupdate.net/ja/xml/rss/ja.xml});

&_get_news2(qq{http://f1-gate.com/rss2.xml});

exit;

sub _get_news2(){
my $get_url = shift;

my $response = get($get_url);
my $xml = new XML::Simple;
my $ret_xml = $xml->XMLin($response);

my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
$year = $year + 1900;
$mon = $mon + 1;
my $date_yyyy_mm_dd = sprintf("%d-%02d-%02d",$year,$mon,$mday);

my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 1, AutoCommit => 0});

foreach my $result (@{$ret_xml->{channel}->{item}}) {
	my ($link, $title, $description, $pubDate, $category);
eval{
	$title = $result->{title};
	$description = $result->{description};
	$category = $result->{category};
	$pubDate = $result->{pubDate};
	$link = $result->{link}; 
    my $sth = $dbh->prepare( qq{insert into race_rss ( `type`,`title`,`body`,`geturl`,`datestr`,`category`) values (?,?,?,?,?,?)});
    $sth->execute(1, $title, $description, $link, $date_yyyy_mm_dd, $category);
};
}

$dbh->disconnect;

return;
}

sub _get_news(){
my $get_url = shift;

my $response = get($get_url);
my $xml = new XML::Simple;
my $ret_xml = $xml->XMLin($response);

my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
$year = $year + 1900;
$mon = $mon + 1;
my $date_yyyy_mm_dd = sprintf("%d-%02d-%02d",$year,$mon,$mday);

my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 1, AutoCommit => 0});

foreach my $result (@{$ret_xml->{channel}->{item}}) {
	my ($link, $title, $description, $pubDate);
eval{
	$title = $result->{title};
	$description = $result->{description};
	$pubDate = $result->{pubDate};
	$link = $result->{link}; 
    my $sth = $dbh->prepare( qq{insert into race_rss ( `type`,`title`,`body`,`geturl`,`datestr`) values (?,?,?,?,?)});
    $sth->execute(1, $title, $description, $link, $date_yyyy_mm_dd);
};
}

$dbh->disconnect;

return;
}

