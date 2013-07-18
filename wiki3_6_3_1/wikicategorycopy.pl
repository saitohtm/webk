#!/usr/bin/perl
use lib './lib';
use strict;
use Jcode;
use DBI;

my $dbh = &_db_connect();
my $dbh2 = &_db_connect2();

# カテゴリ category

my ($cat_id,$cat_title,$cat_pages,$cat_subcats,$cat_files,$cat_hidden);
my $sth = $dbh->prepare(qq{ select cat_id,cat_title,cat_pages,cat_subcats,cat_files,cat_hidden from category} );
$sth->execute();
while(my @row = $sth->fetchrow_array) {
	print "$cat_id\n";
	($cat_id,$cat_title,$cat_pages,$cat_subcats,$cat_files,$cat_hidden) = @row;

	$cat_title = Jcode->new($cat_title, 'utf8')->sjis;

	# データ更新
	my $sth1 = $dbh2->prepare(qq{ select cat_id from category where cat_id = ?} );
	$sth1->execute( $cat_id );
	my $datachkflg;
	while(my @row = $sth1->fetchrow_array) {
		$datachkflg = 1;
	}

	if( $datachkflg ){
		# update
		my $sth1 = $dbh2->prepare(qq{ update category set cat_title=?, cat_pages=?, cat_subcats=?, cat_files=?, cat_hidden=? where rev_id=? limit 1} );
		$sth1->execute($cat_title,$cat_pages,$cat_subcats,$cat_files,$cat_hidden,$cat_id);
	}else{
		# insert
eval{
		my $sth1 = $dbh2->prepare(qq{insert into category ( `rev_id`,`cat_title`,`cat_pages`,`cat_subcats`,`cat_files`,`cat_hidden`) values (?,?,?,?,?,?)} );
		$sth1->execute($cat_id,$cat_title,$cat_pages,$cat_subcats,$cat_files,$cat_hidden);
};
if($@){
#	print "$@ $rev_id \n";
}
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
