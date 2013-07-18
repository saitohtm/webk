#!/usr/bin/perl
use DBI;
use CGI qw( escape );
use Unicode::Japanese;
use Jcode;

my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
$year = $year + 1900;
$mon = $mon + 1;
my $setdate = sprintf("%d-%02d-%02d",$year,$mon,$mday);

use utf8;
use encoding 'utf8', 
STDIN=>'utf8', STDOUT=>'utf8';

my $dsn = 'DBI:mysql:waao';
my $user = 'mysqlweb';
my $password = 'WaAoqzxe7h6yyHz';

my $cmd = qq{GET -t 5 'http://recochoku.jp/recochoku_ranking/weekly_uta.html' | egrep "false;|artist"};

print $cmd;
my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 1, AutoCommit => 0});

my $ret = `$cmd`;
my @lines = split(/\n/,$ret);

my ($title,$artist);
foreach my $line (@lines){
  if($line =~/(.*)false;\">(.*)<\/a>(.*)/){
    print "title:".$2."\n";
	$title = $2;
  }
  if($line =~/(.*)artist\">(.*)<\/dd>/){
      print "artist:$2\n\n";
	  $artist = $2;
  }
  if($line =~/(.*)artist\">(.*)<\/td>/){
      print "artist:$2\n\n";
	  $artist = $2;
  }
  if($title && $artist){

	my $sth = $dbh->prepare(
        qq{insert into music ( `rankdate`,`artist`,`song`) values (?,?,?)}
		);
	$sth->execute($setdate,$artist,$title);

 	  ($title,$artist) = undef;
  }

}

$dbh->disconnect;
