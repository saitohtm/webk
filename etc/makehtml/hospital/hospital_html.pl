#!/usr/bin/perl
use lib qw(/var/www/vhosts/goo.to/etc/lib /var/www/vhosts/goo.to/lib/Waao);

use strict;
use Utility;
use DBI;
use Jcode;
use Seolinks;
use LWP::UserAgent;
use Date::Simple;
use LWP::Simple;

# dir
# hospital
# hospital/pref/
# hospital/prefID/CITYID/GENREID/
# hospital/ID/

# ピアス 病院
# 腰痛　病院
# 不妊治療 病院
# 頭痛 病院
# めまい　病院
# 健康診断

my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-smf/hospital/};
mkdir($dirname, 0755);

my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-smf/hospital/pref/};
mkdir($dirname, 0755);



my $dbh = &_db_connect();
my $sth = $dbh->prepare(qq{select id,name from pref } );
$sth->execute();
while(my @row = $sth->fetchrow_array) {
#	mkdir($dirname, 0755);
}
$dbh->disconnect;

# top
&_top();

# pref
&_pref();

exit;

sub _pref(){
	my $dbh = &_db_connect();

	my $html = &_load_tmpl("pref.html","tmpl_smf");

	my $list;
	my $sth = $dbh->prepare(qq{select id,name from pref } );
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$list.=qq{<li><a href="/<!--DIR-->/pref/$row[0]/"><img src="/img/E23C_20.gif" height="20" alt="病院検索" class="ui-li-icon">$row[1]</a></li>};
		# 都道府県トップ
		&_pref_top($row[0]);
	}

	$html =~s/<!--LIST-->/$list/g;
	$html = &_parts_set($html);
	&_file_output("/var/www/vhosts/goo.to/httpdocs-smf/hospital/pref/index.htm",$html);
	
	$dbh->disconnect;

	return;
}

sub _pref_top(){
	my $pref_id = shift;
	my $dbh = &_db_connect();

	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-smf/hospital/pref/$pref_id/};
	mkdir($dirname, 0755);

	my $html = &_load_tmpl("pref_top.html","tmpl_smf");

	my $list;
	my $cnt;
	my $sth = $dbh->prepare(qq{select city_name,count(*) as cnt from hospital where pref_id = ? group by city_name order by id } );
	$sth->execute($pref_id);
	while(my @row = $sth->fetchrow_array) {
print "$pref_id $row[0] \n";
		$cnt++;
		$list.=qq{<li><a href="/<!--DIR-->/pref/$pref_id-$cnt/"><img src="/img/E23C_20.gif" height="20" alt="病院検索" class="ui-li-icon">$row[0]($row[1])</a></li>};
		
#		my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-smf/hospital/pref/$pref_id/};
#		mkdir($dirname, 0755);
		# citytop
		&_city_top($pref_id,$cnt,$row[0]);
	}

	$sth = $dbh->prepare(qq{select name from pref where id = ? } );
	$sth->execute($pref_id);
	while(my @row = $sth->fetchrow_array) {
		$html =~s/<!--PREF-->/$row[0]/g;
	}

	$html =~s/<!--LIST-->/$list/g;
	$html = &_parts_set($html);
	&_file_output("/var/www/vhosts/goo.to/httpdocs-smf/hospital/pref/$pref_id/index.htm",$html);
	
	$dbh->disconnect;

	return;
}

sub _city_top(){
	my $pref_id = shift;
	my $cnt = shift;
	my $city_name = shift;
	my $dbh = &_db_connect();

	my $html = &_load_tmpl("city_top.html","tmpl_smf");

	my $kamoku;
	my $list;
	my $pref;
	my $sth = $dbh->prepare(qq{select kamoku,pref_name from hospital where pref_id = ? and city_name = ?  } );
	$sth->execute($pref_id,$city_name);
	while(my @row = $sth->fetchrow_array) {
print "$pref_id $city_name $row[0] \n";
		$pref = $row[1];
		my $tmp = $row[0];
		my @vals = split(/･/,$tmp);
		foreach my $vals (@vals){
			if($kamoku->{$vals}){
				$kamoku->{$vals}=$kamoku->{$vals} + 1;
			}else{
				$kamoku->{$vals} = 1;
			}
		}
	}

	$sth = $dbh->prepare(qq{select id, name, type from hospital_genre order by id } );
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		if($kamoku->{$row[1]}){
			$list .= qq{<li><a href="/<!--DIR-->/pref/$pref_id-$cnt-$row[0]/">$row[1]($kamoku->{$row[1]})</a></li>};
			&_city_genre_list($pref_id,$cnt,$city_name,$row[0],$row[1]);
		}else{
#			$list .= qq{<li>$row[1]</li>};
		}
	}

	$html =~s/<!--LIST-->/$list/g;
	$html =~s/<!--CITY-->/$city_name/g;
	$html =~s/<!--PREF_ID-->/$pref_id/g;
	$html =~s/<!--PREF-->/$pref/g;
	$html = &_parts_set($html);
	&_file_output("/var/www/vhosts/goo.to/httpdocs-smf/hospital/pref/$pref_id/$cnt.htm",$html);
	
	$dbh->disconnect;

	return;

}

sub _city_genre_list(){
	my $pref_id = shift;
	my $cnt = shift;
	my $city_name = shift;
	my $genre_id = shift;
	my $genre_name = shift;

	my $dbh = &_db_connect();

	my $html = &_load_tmpl("city_genre_list.html","tmpl_smf");

	my $list;
	my $pref_name;
	my $sth = $dbh->prepare(qq{select id,hpname,holiday,hpaddress,hpzip,keyword,pref_name from hospital where pref_id = ? and city_name = ? and kamoku like "%$genre_name%" } );
	$sth->execute($pref_id,$city_name);
	while(my @row = $sth->fetchrow_array) {
print "$pref_id $city_name $row[0] \n";
	$pref_name = $row[6];
	$list .= qq{<ul data-role="listview" data-inset="true"><li data-role="list-divider"><a href="/<!--DIR-->/pref/$pref_id/hospital$row[0].htm">$row[1]</a></li><li>$row[4] $row[3] $row[2]</li></ul>};
		&_detail($pref_id,$cnt,$city_name,$genre_id,$genre_name,$row[0]);
	}

	$html =~s/<!--LIST-->/$list/g;
	$html =~s/<!--CITY-->/$city_name/g;
	$html =~s/<!--GENRE-->/$genre_name/g;
	$html =~s/<!--GENRE_ID-->/$genre_id/g;
	$html =~s/<!--PREF-->/$pref_name/g;
	$html =~s/<!--PREF_ID-->/$pref_id/g;
	$html =~s/<!--CITY_ID-->/$cnt/g;
	$html = &_parts_set($html);
	&_file_output("/var/www/vhosts/goo.to/httpdocs-smf/hospital/pref/$pref_id/$cnt-$genre_id.htm",$html);
	
	$dbh->disconnect;

	return;
}

sub _detail(){
	my $pref_id = shift;
	my $cnt = shift;
	my $city_name = shift;
	my $genre_id = shift;
	my $genre_name = shift;
	my $id = shift;

	my $dbh = &_db_connect();

	my $html = &_load_tmpl("detail.html","tmpl_smf");

	my $sth = $dbh->prepare(qq{select * from hospital where id = ? } );
	$sth->execute($id);
	while(my @row = $sth->fetchrow_array) {
print "detail $row[6] \n";
		$html =~s/<!--CITY_NAME-->/$row[1]/g;
		$html =~s/<!--CITY_KANA-->/$row[2]/g;
		$html =~s/<!--HOLIDAY-->/$row[3]/g;
		if($row[4]){
			my $homepage = qq{<a href="$row[4]">ホームページ</a>};
			$html =~s/<!--HOMEPAGE-->/$homepage/g;
		}
		$html =~s/<!--HPADDRESS-->/$row[5]/g;
		$html =~s/<!--HPNAME-->/$row[6]/g;
		$html =~s/<!--HPNAME_KANA-->/$row[7]/g;
		$html =~s/<!--HPTEL-->/$row[8]/g;
		$html =~s/<!--HPZIP-->/$row[9]/g;
		$html =~s/<!--KAMOKU-->/$row[10]/g;
		$html =~s/<!--KEYWORD-->/$row[11]/g;
		$html =~s/<!--PREF_NAME-->/$row[13]/g;
		$html =~s/<!--TRAFIC-->/$row[14]/g;
	}

	$html =~s/<!--CITY-->/$city_name/g;
	$html =~s/<!--GENRE-->/$genre_name/g;
	$html =~s/<!--PREF_ID-->/$pref_id/g;

	$html = &_parts_set($html);
	&_file_output("/var/www/vhosts/goo.to/httpdocs-smf/hospital/pref/$pref_id/hospital$id.htm",$html);
	
	$dbh->disconnect;

	return;
}

sub _top(){

	my $dbh = &_db_connect();

	my $html = &_load_tmpl("top.html","tmpl_smf");
	$html = &_parts_set($html);

	&_file_output("/var/www/vhosts/goo.to/httpdocs-smf/hospital/index.htm",$html);

	$dbh->disconnect;

	return;
}



sub _parts_set(){
	my $html = shift;

	# meta
	my $header = &_load_tmpl("header.html","tmpl_smf");
	$html =~s/<!--HEADER-->/$header/g;
	my $footer = &_load_tmpl("footer.html","tmpl_smf");
	$html =~s/<!--FOOTER-->/$footer/g;

	my $adsence = &_load_tmpl("adsence.html","tmpl_smf");
	$html =~s/<!--ADSENCE-->/$adsence/g;


	my $dir = qq{hospital};
	$html =~s/<!--DIR-->/$dir/g;

	return $html;
}

sub _load_tmpl(){
	my $tmpl = shift;
	my $base_dir = shift;

	$base_dir = qq{tmpl} unless($base_dir);
	
my $file = qq{/var/www/vhosts/goo.to/etc/makehtml/hospital/$base_dir/$tmpl};
my $fh;
my $filedata;
open( $fh, "<", $file );
while( my $line = readline $fh ){ 
	$filedata .= $line;
}
close ( $fh );
	$filedata = &_date_set($filedata);

	return $filedata;
}

sub _date_set(){
	my $html = shift;
	my $date = Date::Simple->new();
	my $ymd = $date->format('%Y/%m/%d');
	$html =~s/<!--DATE-->/$ymd/gi;
	return $html;
}

sub _file_output(){
	my $filename = shift;
	my $html = shift;

	open(OUT,"> $filename") || die('error');
	print OUT "$html";
	close(OUT);

	return;
}

sub _db_connect(){
	my $dsn = 'DBI:mysql:waao';
	my $user = 'mysqlweb';
	my $password = 'WaAoqzxe7h6yyHz';

	my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 1, AutoCommit => 0});

	return $dbh;
}


sub price_dsp(){
	my $price = shift;

	1 while $price =~ s/(.*\d)(\d\d\d)/$1,$2/;	

	return $price;
}

