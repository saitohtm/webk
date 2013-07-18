#!/usr/bin/perl
use lib qw(/var/www/vhosts/goo.to/etc/lib /var/www/vhosts/goo.to/lib/Waao);
use DBI;
use CGI qw( escape );
use Apis;

my $dsn = 'DBI:mysql:waao';
my $user = 'mysqlweb';
my $password = 'WaAoqzxe7h6yyHz';
# ‚Qd‹N“®–hŽ~
if ($$ != `/usr/bin/pgrep -fo $0`) {
print "exit \n";
    exit 1;
}
print "start \n";

my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 1, AutoCommit => 0});

&_get_rssdata($dbh,1);
&_get_rssdata($dbh,4);
&_get_rssdata($dbh,6);


&_get_rssdata_goo($dbh,88);
&_get_rssdata_goo($dbh,58);
&_get_rssdata_goo($dbh,57);

$dbh->disconnect;

sub _get_rssdata(){
	my $dbh = shift;
	my $type = shift;

my $sth = $dbh->prepare(qq{select title,datestr from rssdata where type = ? order by datestr desc limit 30});
$sth->execute($type);
while(my @row = $sth->fetchrow_array) {

print "type $type\n";
print "title $row[0]\n";
print "datestr $row[1]\n";

	&get_photo($dbh,$row[0]);
	&get_qanda($dbh,$row[0]);
	&get_news($dbh,$row[0]);
}


	return;
}

sub _get_rssdata_goo(){
	my $dbh = shift;
	my $type = shift;


my $sth = $dbh->prepare(qq{select title,datestr from rssdata_goo where type =? order by datestr desc limit 30});
$sth->execute($type);
while(my @row = $sth->fetchrow_array) {
print "type $type\n";
print "title $row[0]\n";
print "datestr $row[1]\n";
	&get_photo($dbh,$row[0]);
	&get_qanda($dbh,$row[0]);
	&get_news($dbh,$row[0]);
}

	return;
}
