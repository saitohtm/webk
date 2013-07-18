#!/usr/bin/perl

#use strict;
use DBI;
use Cache::Memcached;
use CGI qw( escape );
use Unicode::Japanese;
use XML::FeedPP;
use XML::Simple;
use LWP::Simple;
use URI::Escape;
use Data::Dumper;
use Date::Simple ('date', 'today');

my $dsn = 'DBI:mysql:waao';
my $user = 'mysqlweb';
my $password = 'WaAoqzxe7h6yyHz';
my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 1, AutoCommit => 0});

my $sth = $dbh->prepare(qq{select id,name,rss_url from car_site});
$sth->execute();
while(my @row = $sth->fetchrow_array) {
	next unless($row[2]);
	&_get_rss($dbh,$row[0],$row[2]);
}

$dbh->disconnect;

exit;

sub _get_rss(){
my $dbh = shift;
my $site_id = shift;
my $source = shift;

$source=~s/\s//g;
print $source."\n";
my $feed;
eval{
   $feed = XML::FeedPP->new( $source );
};
return unless($feed);

foreach my $item ( $feed->get_item() ) {
    my $date = $item->pubDate();
#    my $date = substr($item->pubDate(),0,10);
#eval{
#    $date = substr($item->date(),0,10) unless($date);
#};
unless($date){
    $date = today();
}	
	my $title = $item->title();
	my $description = $item->description();
eval{
	unless($description){
		$description = $item->content();
	}
};
	my $img;
eval{
    my $sth = $dbh->prepare( qq{insert into car_topics ( `title`,`body`,`img`,`date`,`site_id`,`url`) values (?,?,?,?,?,?)});
    $sth->execute($title, $description,$item->{enclosure}->{-url}, $date,$site_id,$item->link());
};
print $@;
}


return;
}

