#!/usr/bin/perl
use lib './lib';
use strict;
use DBI;

my $dbh = &_db_connect();

my $sth = $dbh->prepare(qq{ TRUNCATE TABLE text } );
$sth->execute();
print "truncate text \n";
$sth = $dbh->prepare(qq{ TRUNCATE TABLE revision } );
$sth->execute();
print "truncate revision \n";
$sth = $dbh->prepare(qq{ TRUNCATE TABLE page } );
$sth->execute();
print "truncate page \n";

$dbh->disconnect;


# db connect
sub _db_connect(){
    my $dsn = 'DBI:mysql:waao';
    my $user = 'mysqlweb';
    my $password = 'WaAoqzxe7h6yyHz';

    my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 1, AutoCommit => 0});
	
	return $dbh;
}

