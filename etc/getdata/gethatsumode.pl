#!/usr/bin/perl
# ‰Œw@Žæ“¾ƒvƒƒOƒ‰ƒ€

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

for (my $i=1;$i<=10;$i++){
	my $url = qq{http://hatsumoudeg.jp/area/0$i/};
    my $response = get($url);
	my @lines = split(/\n/,$response);
	foreach my $line (@lines){
		if($line=~/(.*)detail\/(.*)\/"\>/){
			my $detailurl = qq{http://hatsumoudeg.jp/detail/$2/};
		    my $detail = get($detailurl);
			my @detaillines = split(/\n/,$detail);
			my ($name, $reeki, $pref, $pref_name, $address, $station);
			my $flag;
			my $line_cnt;
			foreach my $detailline (@detaillines){
				if($detailline=~/hatsumoude_unit/){
					$flag = 1;
				}
				$line_cnt++ if($flag);
				if($line_cnt == 7){
					if($detailline=~/(.*)\>(.*)\<\/td\>/){
						$name = $2;
					}
				}elsif($line_cnt == 11){
					if($detailline=~/(.*)\>(.*)\<\/td\>/){
						$reeki = $2;
					}
				}elsif($line_cnt == 19){
					if($detailline=~/(.*)c2\"\>(.*)\<\/td\>/){
						$pref_name = $2;
					}
				}elsif($line_cnt == 20){
					if($detailline=~/(.*)c2\"\>(.*)\&(.*)/){
						$address = $2;
					}
				}elsif($line_cnt == 23){
					if($detailline=~/(.*)\>(.*)\<\/a\>(.*)\<br \/\>/){
						$station = $2.$3;
					}
				}
			}
			print $name."\n";
			print $reeki."\n";
			print $pref_name."\n";
			print $address."\n";
			print $station."\n";
			$name = Jcode->new($name, 'utf8')->sjis;
			$reeki = Jcode->new($reeki, 'utf8')->sjis;
			$pref_name = Jcode->new($pref_name, 'utf8')->sjis;
			$address = Jcode->new($address, 'utf8')->sjis;
			$station = Jcode->new($station, 'utf8')->sjis;
eval{
	my $sth = $dbh->prepare( qq{select id from pref where name = ? });
	$sth->execute($pref_name);
	while(my @row = $sth->fetchrow_array) {
		$pref = $row[0];
	}
	my $sth = $dbh->prepare( qq{insert into  hatsumoude ( `name`,`reeki`,`pref`,`pref_name`,`address`,`station` ) values (?,?,?,?,?,?)});
	$sth->execute($name,$reeki,$pref,$pref_name,$address,$station);
};

		}
	}
}


$dbh->disconnect;

exit;


