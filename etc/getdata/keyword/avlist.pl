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

my @list = ("a","i","u","e","o");
my @list2 = ("","k","s","t","n","h","m","y","r","w");


my $dsn = 'DBI:mysql:waao';
my $user = 'mysqlweb';
my $password = 'WaAoqzxe7h6yyHz';

my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 1, AutoCommit => 0});

foreach my $ini (@list){
foreach my $ini2 (@list2){
	my $url = qq{http://www.dmm.co.jp/digital/videoa/-/actress/=/keyword=$ini2$ini/};
	print $url."\n";
	my $initial = "$ini2$ini";
	my $get_url = `GET $url`;
	my @lines = split(/\n/,$get_url);
	foreach my $line (@lines){
	 	if($line=~/(.*)article=actress(.*)<br>(.*)<\/a>(.*)/){
			my $name = $3;
			if($name =~/(.*)（(.*)）/){
				$name = $1;
			}
			print $name."\n";
			&_keyword_ins($dbh,$name,$initial);
	 	}
	}
}
}

exit;


$dbh->disconnect;

sub _keyword_ins(){
	my $dbh = shift;
	my $keyword = shift;
	my $initial = shift;
	my $keyword_id;

eval{
	my $sth = $dbh->prepare(qq{insert into keyword (`keyword`) values(?)});
	$sth->execute($keyword);
};

	my $sth = $dbh->prepare(qq{select id from keyword where keyword = ? limit 1});
	$sth->execute($keyword);
	while(my @row = $sth->fetchrow_array) {
		$keyword_id = $row[0];
	}

eval{
	my $sth = $dbh->prepare(qq{insert into keyword_search (`keyword`) values(?)});
	$sth->execute($keyword);
};

eval{
	my $sth = $dbh->prepare(qq{update keyword set sex = 2 and av = 1 and inital = ? and person = 1 and cnt = cnt + 30 where id = ? limit 1});
	$sth->execute($initial,$keyword_id);
};



	return $keyword_id;
}
1;