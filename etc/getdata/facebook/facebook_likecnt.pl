#!/usr/bin/perl
# FaceBooklikecntŽæ“¾ˆ—
use lib qw(/var/www/vhosts/goo.to/etc/lib /var/www/vhosts/goo.to/lib/Waao);

use strict;
use Utility;
use DBI;
use Jcode;
use JSON;
use PageAnalyze;
use DataController;

if ($$ != `/usr/bin/pgrep -fo $0`) {
    exit 1 unless($ARGV[0]);
}

my $dbh = &_db_connect();

#“Še
#&_set_urls($dbh);

my $sth;

print $ARGV[0]."\n";

if($ARGV[0]){
#	$sth = $dbh->prepare(qq{select id, url, likecnt,talking_about_count,name from facebook where id = ?} );
#	$sth->execute($ARGV[0]);
	$sth = $dbh->prepare(qq{select id, url, likecnt,talking_about_count,name from facebook where likecnt is null } );
	$sth->execute();
}else{
	$sth = $dbh->prepare(qq{select id, url, likecnt,talking_about_count,name from facebook order by id desc} );
	$sth = $dbh->prepare(qq{select id, url, likecnt,talking_about_count,name from facebook where img ="" } );
	$sth->execute();
}
my $cnt;
while(my @row = $sth->fetchrow_array) {
	$cnt++;
#	next if($cnt <= 100000 );
	my $id = $row[0];
	my $url = $row[1];
	my $likecnt = $row[2];
	my $tcnt = $row[3];
	my $name = $row[4];
print $url."\n";
	unless($url=~/facebook/){
		my $sth = $dbh->prepare(qq{delete from facebook where id = ? limit 1 });
		$sth->execute($id);
		print "DELETE_ID $id \n";
	}else{
		&_get_facebook($dbh,$id,$url,$likecnt,$tcnt,$name);
	}
}

$dbh->disconnect;

exit;

sub _set_urls(){
	my $dbh = shift;
#	my $sth = $dbh->prepare(qq{select url from facebook_tmp_url} );
	my $sth = $dbh->prepare(qq{select url from facebook_tmp_url where del_flag = 0} );
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		&_get_facebook($dbh,"",$row[0],0);
		my $sth2 = $dbh->prepare(qq{update facebook_tmp_url set del_flag = 1 where url = ? limit 1} );
		$sth2->execute($row[0]);
	}
	
	return;
}

sub _get_facebook(){
	my $dbh = shift;
	my $id = shift;
	my $url = shift;
	my $likecnt = shift;
	my $tcnt = shift;
	my $fname = shift;
	my $ins_url = $url;

	my $data;
	$data = &facebook_page($url);

	my $ret_flag;
	$ret_flag = 1 unless($data->{id});
	$ret_flag = 1 unless($data->{img});
	
	if($ret_flag){
		my $sth = $dbh->prepare(qq{delete from facebook where id = ? limit 1 });
		$sth->execute($id);
		print "DELETE_ID $id \n";
		return;
	}
	
	print "INS_DATA $id \n";
	&facebook_data($dbh,$data);
	return;

	my $expl = $data->{public_transit};
	$expl .= $data->{description};
	$expl .= $data->{personal_info};

my $diff_cnt = $data->{like} - $likecnt;
my $t_diff_cnt = $data->{talking_about_count} - $tcnt;

$diff_cnt = 0 if($diff_cnt eq $likecnt);
$t_diff_cnt = 0 if($t_diff_cnt eq $tcnt);
eval{
print "ID $id \n";
foreach my $key ( sort keys( %{$data} ) ) {
    print "$key : $data->{$key}\n ";
}

	if($id){
		my $sth = $dbh->prepare(qq{update facebook set likecnt=?,diff_cnt=?,f_id=?,f_category=?,website=?,f_username=?,name=?,f_exp=?,mission=?,talking_about_count=?,diff_talking=?, img=?, cover_img = ? , datas = ? where id = ? });
		$sth->execute($data->{like},
		              $diff_cnt,
		              $data->{id},
		              $data->{category},
		              $data->{website},
		              $data->{username},
		              $data->{name},
		              $expl,
		              $data->{mission},
		              $data->{talking_about_count},
		              $t_diff_cnt,
		              $data->{img},
		              $data->{cover_img},
		              $data->{datas},
		              $id);
	}else{
		my $sth = $dbh->prepare(qq{insert into facebook (img,likecnt,diff_cnt,f_id,f_category,website,f_username,name,f_exp,mission,url) values(?,?,?,?,?,?,?,?,?,?,?) });
		$sth->execute($data->{img},
		              $data->{like},
		              $diff_cnt,
		              $data->{id},
		              $data->{category},
		              $data->{website},
		              $data->{username},
		              $data->{name},
		              $expl,
		              $data->{mission},
		              $ins_url);
	}
};
if($@){
print $@;
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

