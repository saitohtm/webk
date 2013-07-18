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

for(my $i=0; $i<20; $i++){
my $start = $i * 20000;
print "start $start \n";
my $sth = $dbh->prepare(qq{SELECT A.id, A.keyword, max(B.good) FROM  `keyword` as A,`photo` as B WHERE A.id = B.keywordid group by B.keywordid limit $start, 20000});
$sth->execute();
while(my @row = $sth->fetchrow_array) {
	next if( $row[2] >= 50 );
	print "$row[0] $row[1] $row[2]\n";

	my $sth2 = $dbh->prepare(qq{insert into keyword_search_id (`keyword`,`keyword_id`) values(?,?)});
	$sth2->execute($row[1],$row[0]);

}

}#for

$dbh->disconnect;

exit;
1;