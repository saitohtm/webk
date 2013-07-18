#!/usr/bin/perl
use lib qw(/var/www/vhosts/goo.to/etc/lib /var/www/vhosts/goo.to/lib/Waao);
use DBI;
use CGI qw( escape );
use Apis;


# ‚Qd‹N“®–hŽ~
if ($$ != `/usr/bin/pgrep -fo $0`) {
print "exit \n";
    exit 1;
}
print "start \n";


my $dsn = 'DBI:mysql:waao';
my $user = 'mysqlweb';
my $password = 'WaAoqzxe7h6yyHz';

my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 1, AutoCommit => 0});


my $sth = $dbh->prepare(qq{select keyword,id from keyword_search where delflag = 0 order by id desc limit 100});
$sth->execute();
while(my @row = $sth->fetchrow_array) {
print "\n\n$row[1]\n";
eval{
	my $sth2 = $dbh->prepare(qq{update keyword_search set delflag = 1 where id = ? limit 1 });
	$sth2->execute($row[1]);

	&get_photo($dbh,$row[0]);
	&get_qanda($dbh,$row[0]);
	&get_news($dbh,$row[0]);

};
	sleep 1;
}

print "\n\n keyword_search_id \n\n\n";

my $sth = $dbh->prepare(qq{select keyword,id,keyword_id from keyword_search_id where delflag = 0 order by id desc limit 50});
$sth->execute();
while(my @row = $sth->fetchrow_array) {
print "\n\n$row[1]\n";
eval{
	my $sth2 = $dbh->prepare(qq{update keyword_search_id set delflag = 1 where id = ? limit 1 });
	$sth2->execute($row[1]);

	&get_photo($dbh,$row[0]);
	&get_qanda($dbh,$row[0]);
	&get_news($dbh,$row[0]);

};
	sleep 1;
}

$dbh->disconnect;

1;