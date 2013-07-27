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

my $sth = $dbh->prepare(qq{select id, url,good,title,keywordid,keyword from photo limit $start,60 });
$sth->execute();
while(my @row = $sth->fetchrow_array) {
	$max_id = $row[0];
}

#my $sth = $dbh->prepare(qq{select keyword,id from keyword where person > 0 and id > ? order by id  });
#$sth->execute($max_id);
my $sth = $dbh->prepare(qq{select keyword,id from keyword where person in (3,4,6,7,8) order by id  });
$sth->execute();
while(my @row = $sth->fetchrow_array) {
print "\n\n$row[0]\n";
eval{
	&get_photo($dbh,$row[0]);
	&get_qanda($dbh,$row[0]);
	&get_news($dbh,$row[0]);

	my $sth2 = $dbh->prepare(qq{insert into keyword_check (`id`) values (?)});
	$sth2->execute($row[1]);

};
	sleep 1;
}

$dbh->disconnect;

1;