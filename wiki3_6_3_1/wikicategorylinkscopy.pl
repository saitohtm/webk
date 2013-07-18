#!/usr/bin/perl
use lib './lib';
use strict;
use Jcode;
use DBI;

my $dbh = &_db_connect();
my $dbh2 = &_db_connect2();

# カテゴリ category

my ($cl_from,$cl_to,$cl_sortkey,$cl_timestamp);
my $sth = $dbh->prepare(qq{ select cl_from,cl_to,cl_sortkey,cl_timestamp from categorylinks} );
$sth->execute();
while(my @row = $sth->fetchrow_array) {
	print "$cl_from\n";
	($cl_from,$cl_to,$cl_sortkey,$cl_timestamp) = @row;

	$cl_to = Jcode->new($cl_to, 'utf8')->sjis;
	$cl_sortkey = Jcode->new($cl_sortkey, 'utf8')->sjis;

	# データ更新
eval{
	my $sth1 = $dbh2->prepare(qq{ select cl_from from categorylinks where cl_from = ? and cl_to=?} );
	$sth1->execute( $cl_from,$cl_to );
	my $datachkflg;
	while(my @row = $sth1->fetchrow_array) {
		$datachkflg = 1;
	}

	if( $datachkflg ){
		# update
		my $sth1 = $dbh2->prepare(qq{ update categorylinks set cl_sortkey=? where cl_from = ? and cl_to=? limit 1} );
		$sth1->execute($cl_sortkey,$cl_from,$cl_to);
	}else{
		# insert
		my $sth1 = $dbh2->prepare(qq{insert into categorylinks ( `cl_from`,`cl_to`,`cl_sortkey`) values (?,?,?)} );
		$sth1->execute($cl_from,$cl_to,$cl_sortkey);
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
