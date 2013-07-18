#!/usr/bin/perl
use lib './lib';
use strict;
use Jcode;
use DBI;

my $dbh = &_db_connect();
my $dbh2 = &_db_connect2();

# カテゴリ category

my ($rd_from,$rd_namespace,$rd_title);
my $sth = $dbh->prepare(qq{ select rd_from,rd_namespace,rd_title from redirect} );
$sth->execute();
while(my @row = $sth->fetchrow_array) {
	($rd_from,$rd_namespace,$rd_title) = @row;

	print "$rd_title\n";
	$rd_title = Jcode->new($rd_title, 'utf8')->sjis;
	print "$rd_title\n";

	# データ更新
eval{
	my $sth1 = $dbh2->prepare(qq{ select rd_namespace,rd_title from redirect where rd_from = ?} );
	$sth1->execute( $rd_from );
	my $datachkflg;
	while(my @row = $sth1->fetchrow_array) {
		$datachkflg = 1;
	}

	if( $datachkflg ){
		# update
		my $sth1 = $dbh2->prepare(qq{ update redirect set rd_namespace=?, rd_title=? where rd_from = ? limit 1} );
		$sth1->execute($rd_namespace,$rd_title,$rd_from );
	}else{
		# insert
		my $sth1 = $dbh2->prepare(qq{insert into redirect ( `rd_from`,`rd_namespace`,`rd_title`) values (?,?,?)} );
		$sth1->execute($rd_from,$rd_namespace,$rd_title);
	}
};
if($@){
#	print "$@ $rev_id \n";
}
}

$dbh2->disconnect;
$dbh->disconnect;

# db connect
sub _db_connect(){
    my $dsn = 'DBI:mysql:corpus';
    my $user = 'mysqlweb';
    my $password = 'WaAoqzxe7h6yyHz';

    my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 1, AutoCommit => 0});
	
	return $dbh;
}

sub _db_connect2(){
    my $dsn = 'DBI:mysql:waao';
    my $user = 'mysqlweb';
    my $password = 'WaAoqzxe7h6yyHz';

    my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 1, AutoCommit => 0});
	
	return $dbh;
}
sub _str_encode(){
	my $str = shift;

	$str =~ s/([^0-9A-Za-z_ ])/'%'.unpack('H2',$1)/ge;
	$str =~ s/ /%20/g;

	return $str;
}
