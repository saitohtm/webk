#!/usr/bin/perl
# FaceBookカテゴリ作成処理
use lib qw(/var/www/vhosts/goo.to/etc/lib /var/www/vhosts/goo.to/lib/Waao);

use strict;
use Utility;
use DBI;
use Jcode;
use PageAnalyze;
use DataController;

my $dbh = &_db_connect();

my $sth = $dbh->prepare(qq{select category,id from facebook_category where category is not null } );
$sth->execute();
while(my @row = $sth->fetchrow_array) {
print $row[0]."\n";
eval{
#	my $sth2 = $dbh->prepare(qq{update facebook set category_id=? where f_category = ? } );
#	$sth2->execute($row[1],$row[0]);
}
}
for(my $i=0;$i<500;$i++){
	my $cnt = (200 * $i) + 1;
	&_get_facebook($dbh,$cnt);
}

$dbh->disconnect;

exit;

sub _get_facebook(){
	my $dbh = shift;
	my $page_param = shift;

	my $cmd = qq{http://fbrank.main.jp/?PT=$page_param};
#	print "$cmd _get_facebook\n";
	sleep 1;
	my $get_url = `GET "$cmd"`;
my $category_id;
	$get_url=~s/\n//g;
	$get_url=~s/<div/\n<div/g;
	$get_url=~s/<td/\n<td/g;
	my @lines = split(/\n/,$get_url);
	my $fb_cnt;
	my $fb_diff;
	my $fb_img;
	my $fb_url;
	my $fb_category;
	my $fb_title;
	my $total_cnt;
	my $data_flag;
	foreach my $line (@lines){
#		$line = Jcode->new($line, 'utf8')->sjis;
#		print $line."\n\n";

		if($line=~/<td align=\"right\"><b>(.*)<br><span style=\"color:\#F00;\">\+(.*)<\/span><\/b><\/td>/){
			$fb_cnt = $1;
			$fb_diff = $2;
		}
		
		
		if($line=~/<td><a href=\"(.*)\" target=\"_blank\"><img src=\"(.*)\" height=\"75\" border=\"0\" align=\"right\" style=\"margin-left:5px;\" onload=\"rz\(this\)\"><\/a><span style=\"font-size:10px\">(.*)\((.*)\)<\/span><br><a href=\"(.*)\" target=\"_blank\">(.*)<\/a>(.*)/){
			$fb_url = $1;
			$fb_img = $2;
			$fb_category = $3;
			$fb_title = $6;
			$data_flag = 1;
		}

		if($line=~/<td><small><a href=\"(.*)\" target=\"_blank\"><img src=\"(.*)\" height=\"75\" border=\"0\" align=\"right\" style=\"margin-left:5px;\" onload=\"rz\(this\)\"><\/a><span style=\"font-size:10px\">(.*)\((.*)\)<\/span><br><a href=\"(.*)\" target=\"_blank\">(.*)<\/a>(.*)/){
			$fb_url = $1;
			$fb_img = $2;
			$fb_category = $3;
			$fb_title = $6;
			$data_flag = 1;
		}

		if($line=~/<td><a href=\"(.*)\" target=\"_blank\"><img src=\"(.*)\" height=\"75\" border=\"0\" align=\"right\" style=\"margin-left:5px;\" onload=\"rz\(this\)\"><\/a><span style=\"font-size:10px\">(.*)<\/span><br><a href=\"(.*)\" target=\"_blank\">(.*)<\/a>(.*)/){
			$fb_url = $1;
			$fb_img = $2;
			$fb_category = $3;
			$fb_title = $5;
			$data_flag = 1;
		}
		if($line=~/<td><small><a href=\"(.*)\" target=\"_blank\"><img src=\"(.*)\" height=\"75\" border=\"0\" align=\"right\" style=\"margin-left:5px;\" onload=\"rz\(this\)\"><\/a><span style=\"font-size:10px\">(.*)<\/span><br><a href=\"(.*)\" target=\"_blank\">(.*)<\/a>(.*)/){
			$fb_url = $1;
			$fb_img = $2;
			$fb_category = $3;
			$fb_title = $5;
			$data_flag = 1;
		}

		if($data_flag){
my $data = &facebook_page($fb_url);
foreach my $key ( sort keys( %{$data} ) ) {
    print "$key:$data->{$key}\n ";
}

&facebook_data($dbh,$data);

#print "$fb_cnt\n";
#print "$fb_diff\n";
print "$fb_url\n";
#print "$fb_img\n";
#print "$fb_category\n";
print "$fb_title\n\n";
			# DB insert
if(0){
eval{
			my $sth = $dbh->prepare(qq{select id from facebook where url = ? } );
			$sth->execute($fb_url);
			my $ins_flag;
			while(my @row = $sth->fetchrow_array) {
print " $total_cnt UPD \n";
				my $sth2 = $dbh->prepare(qq{update facebook set likecnt=?,diff_cnt=?,url=?,img=?,f_category=?,name=? where id = ? limit 1} );
#				$sth2->execute($fb_cnt,$fb_diff,$fb_url,$fb_img,$fb_category,$fb_title,$row[0]);
				$ins_flag = 1;
			}
			unless($ins_flag){
print " $total_cnt INS \n";
				my $sth2 = $dbh->prepare(qq{insert into facebook (`img`,`url`,`name`,`f_category`,`likecnt`,`diff_cnt`) values (?,?,?,?,?,?)} );
#				$sth2->execute($fb_img,$fb_url,$fb_title,$fb_category,$fb_cnt,$fb_diff);
			}
};
}#if(0)
			($fb_img,$fb_url,$fb_title,$fb_category,$fb_cnt,$fb_diff) = undef;
			$total_cnt++;
			$data_flag = undef;

		}
	}
	exit unless($total_cnt);
	return;
}


sub _db_connect(){

	my $dsn = 'DBI:mysql:waao';
	my $user = 'mysqlweb';
	my $password = 'WaAoqzxe7h6yyHz';
	my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 1, AutoCommit => 0});

	return $dbh;
}

