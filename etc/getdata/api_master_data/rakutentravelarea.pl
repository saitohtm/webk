#!/usr/bin/perl
# IMG GET取得プログラム

#use strict;
use DBI;
use XML::Simple;
use LWP::Simple;
use Jcode;
use CGI qw( escape );

my $dsn = 'DBI:mysql:waao';
my $user = 'mysqlweb';
my $password = 'WaAoqzxe7h6yyHz';

my $url= qq{http://api.rakuten.co.jp/rws/2.0/rest?developerId=5e39057439ff0a07c0f92c9aa10dbdb9&operation=GetAreaClass&version=2009-03-26};
my $response = get($url);	
my $xml = new XML::Simple;
my $rakuten_xml = $xml->XMLin($response);

my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 1, AutoCommit => 0});

my $large = $rakuten_xml->{Body}->{"getAreaClass:GetAreaClass"}->{largeClass};
	my $largecode = $large->{largeClassCode};
	my $largename = $large->{largeClassName};
	foreach my $middle (@{$large->{middleClass}}) {
		my $middlecode = $middle->{middleClassCode};
		my $middlename = $middle->{middleClassName};
		foreach my $small (@{$middle->{smallClass}}) {
			my $smallcode = $small->{smallClassCode};
			my $smallname = $small->{smallClassName};
eval{
			my $sth = $dbh->prepare( qq{insert into rakutenarea ( `large`,`largename`,`middle`,`middlename`,`small`,`smallname`) values (?,?,?,?,?,?)} );
			$sth->execute($largecode, $largename, $middlecode, $middlename, $smallcode, $smallname);
};
		}
	}

$dbh->disconnect;


exit;
