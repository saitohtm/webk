#!/usr/bin/perl
use lib qw(/var/www/vhosts/goo.to/etc/lib /var/www/vhosts/goo.to/lib/Waao);

# googleplay
# http://d.hatena.ne.jp/tamiyant/20120414/1334390962

#use strict;
use DBI;
use Unicode::Japanese;
use LWP::UserAgent;
use Jcode;
use XML::Simple;
use LWP::Simple;
use PageAnalyze;
use DataController;

use Date::Simple;

my $dbh = &_db_connect();

my $url = qq{http://www.appannie.com/top/android/japan/};

&_install($dbh,$url,1);
&_install($dbh,$url,2);


my $sth = $dbh->prepare(qq{SELECT id,key_value,game FROM app_category where id < 6000 order by id desc });
$sth->execute();
while(my @row = $sth->fetchrow_array) {
	my $genre = $row[1];
	$genre =~ tr/A-Z/a-z/;
	$genre =~s/_/-/g;
	my $url;
	if($row[2]){
		$url = qq{http://www.appannie.com/top/android/japan/game/$genre/};
	}else{
		$url = qq{http://www.appannie.com/top/android/japan/application/$genre/};
	}
	&_install($dbh,$url,1);
	&_install($dbh,$url,2);
}

#http://www.appannie.com/top/android/japan/application/books-and-reference/


#http://www.appannie.com/top/android/japan/game/arcade/

$dbh->disconnect;
exit;

sub _install(){
	my $dbh = shift;
	my $url = shift;
	my $retu = shift;

print "INS $url \n";

my $ua = LWP::UserAgent->new(
	agent		=> "Mozilla/5.0",
	timeout		=> 10,
);
	my $request  = $ua->get("$url");

	my $get_url = $request->content;
	my @lines = split(/>/,$get_url);

	my $rankno;
	my $ranking;
	foreach my $line (@lines){
		if($line =~/(.*)app\/android\/(.*)\/\"/){
			my $id = $2;
			$rankno++;
			if(($rankno % 5) == $retu){
				$ranking++;
				my $data = &googleplay_page($id);
#foreach my $key ( sort keys( %{$data} ) ) {
#    print "$key : $data->{$key} \n "
#}

				&app_android_data($dbh,$data);
				print "$ranking $id \n";
			}
		}
	}

	return;
}


sub _db_connect(){

    my $dsn = 'DBI:mysql:waao';
    my $user = 'mysqlweb';
    my $password = 'WaAoqzxe7h6yyHz';
    my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 1, AutoCommit => 0});

    return $dbh;
}

1;
