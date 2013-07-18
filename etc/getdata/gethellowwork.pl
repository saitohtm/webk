#!/usr/bin/perl
# hellowwork　取得プログラム

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

for (my $i=100;$i<1000;$i++){
	my $url = qq{http://www.aaaaaa.co.jp/job/hellowork/id$i.html};
    my $response = get($url);
	my @lines = split(/\n/,$response);
	my ($name,$subname,$zipcode,$pref,$address,$tel,$fax);
	my $flag;
	my $line_cnt;
	foreach my $line (@lines){
		if($line =~/hw_d_table/){
			$flag = 1;
		}
		if($flag){
			$line_cnt++;
		}
		if($line_cnt eq 4){
			$name = $line;
			$name = Jcode->new($name, 'utf8')->sjis;
			$name =~s/\<h2\>//g;
			$name =~s/\s//g;
		}elsif($line_cnt eq 5){
			$subname = $line;
			$subname = Jcode->new($subname, 'utf8')->sjis;
			$subname =~s/\<\/h2\>//g;
			$subname =~s/\s//g;
			$subname =~s/（//g;
			$subname =~s/）//g;
		}elsif($line_cnt eq 11){
			$zipcode = $line;
			$zipcode =~s/\<br \/\>//g;
			$zipcode =~s/\s//g;
			$zipcode =~s/-//g;
			$zipcode =substr($zipcode,1);;
		}elsif($line_cnt eq 12){
			$pref = $line;
			$pref = Jcode->new($pref, 'utf8')->sjis;
			$pref =~s/\s//g;
		}elsif($line_cnt eq 13){
			$address = $line;
			$address = Jcode->new($address, 'utf8')->sjis;
			$address =~s/\s//g;
		}elsif($line_cnt eq 32){
			$tel = $line;
			$tel =~s/TEL://g;
			$tel =~s/\<br \/\>//g;
			$tel =~s/\s//g;
		}elsif($line_cnt eq 33){
			$fax = $line;
			$fax =~s/FAX://g;
			$fax =~s/\s//g;
		}elsif($line_cnt > 34){
			last;
		}
	}
	next unless($name);
eval{
	my $sth = $dbh->prepare( qq{select id from pref where name = ?} );
	$sth->execute($pref);
	my $pref_cd;
	while(my @row = $sth->fetchrow_array) {
		$pref_cd = $row[0];
	}

	my $sth = $dbh->prepare( qq{insert into hellowwork ( `name`,`name2`,`zipcode`,`pref_cd`,`pref_name`,`address`,`tel`,`fax` ) values (?,?,?,?,?,?,?,?)});
	$sth->execute($name,$subname,$zipcode,$pref_cd,$pref,$address,$tel,$fax);
};
print $name."\n";	
print $subname."\n";	
print $zipcode."\n";	
print $pref."\n";	
print $address."\n";	
print $tel."\n";	
print $fax."\n";	
print "\n";	

}
#	$description = Jcode->new($result->{description}, 'utf8')->sjis;

$dbh->disconnect;

exit;


