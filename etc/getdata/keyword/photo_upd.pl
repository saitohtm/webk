#!/usr/bin/perl
use lib qw(/var/www/vhosts/goo.to/etc/lib /var/www/vhosts/goo.to/lib/Waao);
use DBI;
use CGI qw( escape );
use LWP::UserAgent;
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
my $photo_id;
my $sth = $dbh->prepare(qq{SELECT photo_id FROM `photo_upd_chk` WHERE id = 1 limit 1});
$sth->execute();
while(my @row = $sth->fetchrow_array) {
	$photo_id = $row[0];
}

&_upd($dbh,$photo_id);

$dbh->disconnect;

exit;

sub _upd(){
	my $dbh = shift;
	my $start = shift;

	$start++;
	print "start $start \n";
	my $sth = $dbh->prepare(qq{SELECT id, url, good FROM `photo` WHERE id >= ? order by id limit 10000});
	$sth->execute($start);
	while(my @row = $sth->fetchrow_array) {
		my $id = $row[0];
		my $dl_url = $row[1];
		my $good = $row[2];
eval{
		my $sth2 = $dbh->prepare(qq{update photo_upd_chk set photo_id = ? where id = 1 limit 1});
		$sth2->execute($id);
};

		print "\n\n$dl_url\n";
		my $content;
		my $ua = LWP::UserAgent->new;
		$ua->timeout(3);
		my $res;
eval{
		$res = $ua->head($dl_url);
};
#		if($res->{_rc} ne 200){
#			print "ERR".$res->{_rc};
#			next;
#		}
		my $content = $res->headers;
		my $img_size;
		$img_size = $content->content_length;
		if($img_size){
			if($img_size >= 50000){
				if($good > 100){
				}else{
					$good = 100;
				}
			}elsif($img_size >=10000){
				if($good > 100){
					$good = 55;
				}elsif($good > 50){
				}else{
					$good = 50;
				}
			}else{
				$good = 0;
			}
		}else{
			$good = 0;
		}
		print "SIZE::$img_size\n";
		print "GOOD::$good\n";
eval{
		my $sth2 = $dbh->prepare(qq{update photo set good = ? where id = ? limit 1});
		$sth2->execute($good,$id);
};

	}

	return;
}


1;