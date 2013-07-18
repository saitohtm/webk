#!/usr/bin/perl
use lib './lib';
use strict;
use Jcode;
use DBI;

my $dbh = &_db_connect();

# カテゴリ category

my ($wiki_id, $keyword, $birthday, $blood, $birth_name);
my $sth = $dbh->prepare(qq{ select rev_id, keyword, birthday, blood, birth_name from wikipedia where person = 1 and page_namespace = 0} );
$sth->execute();
while(my @row = $sth->fetchrow_array) {
	($wiki_id, $keyword, $birthday, $blood, $birth_name) = @row;
	print "$keyword\n";
	# データ更新
eval{
	my $keyword_id;
	my $sth1 = $dbh->prepare(qq{ select id from keyword where keyword = ?} );
	$sth1->execute( $keyword );
	my $datachkflg;
	while(my @row = $sth1->fetchrow_array) {
		$datachkflg = 1;
		$keyword_id = $row[0];
	}

	if( $datachkflg ){
		# update
		my $sth1 = $dbh->prepare(qq{ update keyword set wiki_id=?, birthday=?, blood=?, birth_name=? where id = ? limit 1} );
		$sth1->execute($wiki_id,$birthday,$blood,$birth_name,$keyword_id);
	}else{
		# insert
		my $sth1 = $dbh->prepare(qq{insert into keyword ( `wiki_id`,`keyword`,`birthday`,`blood`,`birth_name`,`cnt`) values (?,?,?,?,?,?)} );
		$sth1->execute($wiki_id,$keyword,$birthday,$blood,$birth_name,0);
	}
};
if($@){
#	print "$@ $rev_id \n";
}
}

$dbh->disconnect;

sub _db_connect(){
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
