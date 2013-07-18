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
# sinior
# sinior/pref/

my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-smf/senior/};
mkdir($dirname, 0755);

my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-smf/senior/pref/};
mkdir($dirname, 0755);

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
		$list.=qq{<li><a href="/<!--DIR-->/pref/$row[0]/"><img src="/img/E23C_20.gif" height="20" alt="老人ホーム検索" class="ui-li-icon">$row[1]</a></li>};
		# 都道府県トップ
		&_pref_top($row[0]);
	}

	$html =~s/<!--LIST-->/$list/g;
	$html = &_parts_set($html);
	&_file_output("/var/www/vhosts/goo.to/httpdocs-smf/senior/pref/index.htm",$html);
	
	$dbh->disconnect;

	return;
}

sub _pref_top(){
	my $pref_id = shift;
	my $dbh = &_db_connect();

	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-smf/senior/pref/$pref_id/};
	mkdir($dirname, 0755);

	my $html = &_load_tmpl("pref_top.html","tmpl_smf");

	my $list;
	my $cnt;
	my $sth = $dbh->prepare(qq{select * from sinior_home where pref_id = ? order by id } );
	$sth->execute($pref_id);
	while(my @row = $sth->fetchrow_array) {
print "$pref_id $row[0] \n";
		$cnt++;
		$list .= qq{<ul data-role="listview" data-inset="true"><li data-role="list-divider"><a href="/<!--DIR-->/pref/$pref_id/tokuyo$row[0].htm">$row[1]</a></li><li>$row[4] $row[5]</li></ul>};
		
		&_detail($pref_id,$row[0]);
		$html =~s/<!--PREF-->/$row[2]/g;
	}

	$html =~s/<!--LIST-->/$list/g;
	$html =~s/<!--PREF_ID-->/$pref_id/g;
	$html = &_parts_set($html);
	&_file_output("/var/www/vhosts/goo.to/httpdocs-smf/senior/pref/$pref_id/index.htm",$html);
	
	$dbh->disconnect;

	return;
}

sub _detail(){
	my $pref_id = shift;
	my $id = shift;

	my $dbh = &_db_connect();

	my $html = &_load_tmpl("detail.html","tmpl_smf");

	my $sth = $dbh->prepare(qq{select * from sinior_home where id = ? } );
	$sth->execute($id);
	while(my @row = $sth->fetchrow_array) {
		$html =~s/<!--NAME-->/$row[1]/g;
		$html =~s/<!--PREF_NAME-->/$row[2]/g;
		$html =~s/<!--ADDRESS-->/$row[4]/g;
		$html =~s/<!--TEL-->/$row[5]/g;
		$html =~s/<!--HOMEPAGE-->/$row[6]/g;
	}

	$html =~s/<!--PREF_ID-->/$pref_id/g;

	$html = &_parts_set($html);
	&_file_output("/var/www/vhosts/goo.to/httpdocs-smf/senior/pref/$pref_id/tokuyo$id.htm",$html);
	
	$dbh->disconnect;

	return;
}

sub _top(){

	my $dbh = &_db_connect();

	my $html = &_load_tmpl("top.html","tmpl_smf");
	$html = &_parts_set($html);

	&_file_output("/var/www/vhosts/goo.to/httpdocs-smf/senior/index.htm",$html);

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


	my $dir = qq{senior};
	$html =~s/<!--DIR-->/$dir/g;

	return $html;
}

sub _load_tmpl(){
	my $tmpl = shift;
	my $base_dir = shift;

	$base_dir = qq{tmpl} unless($base_dir);
	
my $file = qq{/var/www/vhosts/goo.to/etc/makehtml/sinior_home/$base_dir/$tmpl};
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

print "$filename \n";
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

