package Waao::Twitter::F1;
use strict;
use DBI;
use CGI;

sub dispatch(){
	my $class = shift;
	my $q = new CGI;
	my $id = $q->param('id');

	if(&_mobile_access_check()){
		print qq{Location: http://waao.jp/list-newsdetail/f1/$id/\n\n};
		return;
	}
	
	my $dbh = &_db_connect();
	
	my ($title, $datestr, $bodystr, $geturl);
	my $sth = $dbh->prepare(qq{ select title, datestr, body, geturl from race_rss where id = ? limit 1});
	$sth->execute($id);
	while(my @row = $sth->fetchrow_array) {
		($title, $datestr, $bodystr, $geturl) = @row;
	}

	
	return;
}


sub _db_connect(){
    my $dsn = 'DBI:mysql:waao';
    my $user = 'mysqlweb';
    my $password = 'WaAoqzxe7h6yyHz';

    my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 0, AutoCommit => 1, PrintError => 0});
	
	return $dbh;
}

sub _mobile_access_check(){

    if( $ENV{'REMOTE_HOST'} =~/docomo/i ){
		return 1;
    }elsif( $ENV{'REMOTE_HOST'} =~/ezweb/i ){
		return 1;
    }elsif( $ENV{'REMOTE_HOST'} =~/^J-PHONE|^Vodafone|^SoftBank/i ){
		return 1;
	}

	return 0;
}


1;