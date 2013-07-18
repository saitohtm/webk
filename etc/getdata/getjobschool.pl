#!/usr/bin/perl
# 専門学校　取得プログラム

#use strict;
use DBI;
use CGI qw( escape );
use Unicode::Japanese;
use LWP::UserAgent;
use Jcode;
use XML::Simple;
use LWP::Simple;
use URI::Escape;

my $dsn = 'DBI:mysql:waao';
my $user = 'mysqlweb';
my $password = 'WaAoqzxe7h6yyHz';

my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 1, AutoCommit => 0});

for (my $i=100;$i<3200;$i++){
	my $url = qq{http://www.aaaaaa.co.jp/job/school/id$i.html};
#	my $url = qq{http://www.aaaaaa.co.jp/job/school/id664.html};
    my $response = get($url);
	my @lines = split(/\n/,$response);
	my ($hojin,$name,$zipcode,$pref,$address,$tel,$url);
	my $flag;
	my $line_cnt;
	foreach my $line (@lines){
		if($line =~/\"main\"/){
			$flag = 1;
		}
		if($flag){
			$line_cnt++;
		}
		if($line_cnt eq 3){
			if($line=~/(.*)\<td\>(.*)\<\/td\>/){
				$hojin = $2;
				$hojin = Jcode->new($hojin, 'utf8')->sjis;
			}
		}elsif($line_cnt eq 7){
			if($line=~/(.*)\<td\>(.*)\<\/td\>(.*)/){
				$name = $2;
				$name = Jcode->new($name, 'utf8')->sjis;
			}
		}elsif($line_cnt eq 11){
			$line = Jcode->new($line, 'utf8')->sjis;
			if($line=~/(.*)\<td\>(.*)　(.*)\<\/td\>/){
				$zipcode = $2;
				$address = $3;
				$zipcode =substr($zipcode,2);
				$zipcode =~s/-//g;
			}
		}elsif($line_cnt eq 15){
			if($line=~/(.*)\<td\>(.*)/){
				$tel = $2;
			}
		}elsif($line_cnt eq 21){
			if($line=~/(.*)\<td\>(.*)\<\/td\>(.*)/){
				$url = $2;
			}
		}elsif($line_cnt > 22){
			last;
		}
	}
	next unless($name);
eval{
	my $sth = $dbh->prepare( qq{insert into jobschool ( `hojin`,`name`,`zipcode`,`address`,`tel`,`url` ) values (?,?,?,?,?,?)});
	$sth->execute($hojin,$name,$zipcode,$address,$tel,$url);
};
print $hojin."\n";	
print $name."\n";	
print $zipcode."\n";	
print $pref."\n";	
print $address."\n";	
print $tel."\n";	
print $url."\n";	
print "\n";	


}

my $sth = $dbh->prepare( qq{select id, name from pref} );
$sth->execute();
while(my @row = $sth->fetchrow_array) {
	my $sth2 = $dbh->prepare( qq{update jobschool set pref_cd = ?, pref_name = ? where address like "}.$row[1].qq{%"});
	$sth2->execute($row[0],$row[1]);
}


$dbh->disconnect;

exit;


