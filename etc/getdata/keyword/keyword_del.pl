#!/usr/bin/perl
use lib qw(/var/www/vhosts/goo.to/etc/lib /var/www/vhosts/goo.to/lib/Waao);
use DBI;
use CGI qw( escape );
use Apis;


# ２重起動防止
if ($$ != `/usr/bin/pgrep -fo $0`) {
print "exit \n";
    exit 1;
}
print "start \n";


my $dsn = 'DBI:mysql:waao';
my $user = 'mysqlweb';
my $password = 'WaAoqzxe7h6yyHz';

my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 1, AutoCommit => 0});

my $sth = $dbh->prepare(qq{SELECT keyword, COUNT( * ) FROM  `keyword` GROUP BY keyword HAVING COUNT( * ) > 1 });
$sth->execute();
while(my @row = $sth->fetchrow_array) {
	print "$row[0] $row[1]\n";
	my $sth2 = $dbh->prepare(qq{SELECT id  FROM  `keyword` where keyword = ? order by id });
	$sth2->execute($row[0]);
	my $cnt;
	while(my @row2 = $sth2->fetchrow_array) {
		$cnt++;
		next if($cnt == 1);
		print "delete $row[0] \n";
		my $sth3 = $dbh->prepare(qq{delete from keyword where id = ? limit 1 });
		$sth3->execute($row2[0]);
	}
}

$dbh->disconnect;

exit;
1;