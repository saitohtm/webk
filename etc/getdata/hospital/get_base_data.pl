#!/usr/bin/perl

#use strict;
use URI::Escape;
use DBI;
use LWP::Simple;
use Jcode;

my $dsn = 'DBI:mysql:waao';
my $user = 'mysqlweb';
my $password = 'WaAoqzxe7h6yyHz';

my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 0, AutoCommit => 0});

my $genredata;
my $sth = $dbh->prepare( qq{select id,name from hospital_genre });
$sth->execute();
while(my @row = $sth->fetchrow_array) {
	$genredata->{$row[1]}=$row[0];
}


my $sth = $dbh->prepare( qq{select id,homepage from hospital });
$sth->execute();
while(my @row = $sth->fetchrow_array) {
	my $sth2 = $dbh->prepare( qq{select id,homepage from hospital where homepage = ? });
	$sth2->execute($row[1]);
	while(my @row2 = $sth2->fetchrow_array) {
		next if($row[0] eq $row2[0]);
		my $sth3 = $dbh->prepare(qq{update hospital set homepage=NULL where id = ? });
		$sth3->execute($row2[0]);
	}
}

$dbh->disconnect;

exit;


# “s“¹•{Œ§
my $prefdata;
my $sth = $dbh->prepare( qq{select id,name from pref });
$sth->execute();
while(my @row = $sth->fetchrow_array) {
	$prefdata->{$row[1]}=$row[0];
}

my $hdata;
my $get_url = get( "http://www.hospiclinic.com/todofuken/" );
$get_url =~s/<\/a>/<\/a>\n/g;
my @lines = split(/\n/,$get_url);
foreach my $line (@lines){
	$line = Jcode->new($line, 'utf8')->sjis;
	if($line =~/(.*)<a href=(.*)find(.*)\" title(.*)\"> (.*)<\/a>(.*)/){
		$hdata->{pref_name} = $5;
		$hdata->{pref_id} = $prefdata->{$5};
		next if($hdata->{pref_id} <= 26);
		&_pref($dbh,$3,$hdata);
	}
}

$dbh->disconnect;

exit;

sub _pref(){
	my $dbh = shift;
	my $url = shift;
	my $hdata = shift;
	
	my $get_url = get( "http://www.hospiclinic.com/find$url" );
	$get_url =~s/<\/a>/<\/a>\n/g;
	my @lines = split(/\n/,$get_url);
	my $city;
	my $city_kana;
	foreach my $line (@lines){
		$line = Jcode->new($line, 'utf8')->sjis;
		if($line =~/(.*)<a href=(.*)find(.*)\" title(.*)\">(.*)<\/a>(.*)/){
			my $url = $3;
			my $str = $5;
			if($str =~/span/){
				$city_kana = $str;
				$city_kana =~s/<\/span>//g;
			}else{
				$city = $str;
			}
			if($city_kana){
				$hdata->{city_name} = $city;
				$hdata->{city_kana} = $city_kana;
				&_choice($dbh,$url,$hdata);
				$city = undef;
				$city_kana = undef;
print "$hdata->{pref_name} $hdata->{city_name}\n";
#sleep 1;
			}
		}
	}	

	return;
}

sub _choice(){
	my $dbh = shift;
	my $url = shift;
	my $hdata = shift;
	
my $genredata;
my $sth = $dbh->prepare( qq{select id,name from hospital_genre });
$sth->execute();
while(my @row = $sth->fetchrow_array) {
	$genredata->{$row[1]}=$row[0];
}


	my $get_url = get( "http://www.hospiclinic.com/find$url" );
	$get_url =~s/<\/td>/<\/td>\n/g;
	my @lines = split(/\n/,$get_url);
	my $genre;
	foreach my $line (@lines){
		$line = Jcode->new($line, 'utf8')->sjis;
		my $url;
		if($line =~/(.*)find(.*)\" title(.*)\">(.*)<\/a><span class=\"count\">(.*)<\/span>(.*)/){
			$genre = $4;
			next if($genre =~/‘S‚Ä/);
			$url = $2;
			$htada->{genre_name} = $genre;
			$htada->{genre_id} = $genredata->{$genre};
			# 1ƒy[ƒW 15Œ
			my $cnt = $5;
			$cnt=~s/\(//g;
			$cnt=~s/\)//g;
			my $pagecnt = int($cnt/15) + 1;
			for($i=1;$i<=$pagecnt;$i++){
				&_list($dbh,$url,$i,$hdata);
				#sleep 1;
			}
		}elsif($line =~/(.*)<td>(.*)<span class=\"count\">(.*)/){
			$genre = $2;
		}
		if($genre =~/‘S‚Ä/){
		}elsif($genre){
#eval{
#			my $sth = $dbh->prepare(qq{insert into hospital_genre (`name`) values (?)} );
#			$sth->execute($genre);
#};
#			print $genre."\n";
			$genre = undef;
		}
	}	

	return;
}

sub _list(){
	my $dbh = shift;
	my $url = shift;
	my $page = shift;
	my $hdata = shift;

	my $get_url = get( "http://www.hospiclinic.com/find$url$page" );
	$get_url =~s/<\/a>/<\/a>\n/g;
	my @lines = split(/\n/,$get_url);
	foreach my $line (@lines){
		$line = Jcode->new($line, 'utf8')->sjis;
		if($line =~/(.*)find(.*)\" title(.*)\">(.*)<\/a>(.*)/){
			my $url = $2;
			if($url =~/img/){
			}else{
				&_detail($dbh,$url,$hdata);
			}
		}
	}	

	return;
}

sub _detail(){
	my $dbh = shift;
	my $url = shift;
	my $hdata = shift;
	my $flag_addr;
	my $flag_kamoku;
	my $flag_keyword;
	my $flag_holi;

	my $get_url = get( "http://www.hospiclinic.com/find$url" );
	$get_url =~s/<\/a>/<\/a>\n/g;
	my @lines = split(/\n/,$get_url);
	foreach my $line (@lines){
		$line = Jcode->new($line, 'utf8')->sjis;
		if($line =~/(.*)hp_name(.*)find(.*)\">(.*)<\/a>(.*)/){
			$hdata->{hpname}=$4;
		}elsif($line =~/(.*)koumoku_link(.*)find(.*)\">(.*)<\/a>(.*)/){
			$hdata->{hpname_kana}=$4;
		}elsif($line =~/<td colspan=\"2\">(.*)-(.*)-(.*)<\/td>/){
			$hdata->{hptel}=qq{$1-$2-$3};
		}elsif($line =~/<td colspan=\"2\">(.*)-(.*)<\/td>/){
			$hdata->{hpzip}=qq{$1-$2};
		}elsif($line =~/(.*)<strong><a href=\"(.*)\" target(.*)/){
			$hdata->{homepage}=$2;
		}elsif($line =~/<td>(.*)@<form a(.*)/){
			$hdata->{trafic}=$1;
		}

		my $tmpstr=q{Šİ’n};
		if($line =~/$tmpstr/){
			$flag_addr = 1;
		}
		if($flag_addr){
			if($line =~/(.*)<\/strong>(.*)/){
				$hdata->{hpaddress}=$2;
				$flag_addr = undef;
			}
		}

		
		my $tmpstr=q{f—Ã‰È–Ú};
		if($line =~/$tmpstr/){
			$flag_kamoku = 1;
		}
		if($flag_kamoku){
			if($line =~/<td>(.*)<\/td>/){
				$hdata->{kamoku}=$1;
				$flag_kamoku = undef;
			}
		}
		if($line =~/(.*)ƒL(.*)ƒ(.*)ƒh/){
			$flag_keyword = 1;
		}
		if($flag_keyword){
			if($line =~/<td>(.*)<\/td>/){
				$hdata->{keyword}=$1;
				$flag_keyword = undef;
			}
		}

		my $tmpstr=q{f—ÃŠÔ};
		if($line =~/$tmpstr/){
			$flag_holi++;
		}
		if($flag_holi){
			if($flag_holi eq 4){
				$hdata->{holiday}=$line;
			}
			$flag_holi++;
		}

	}	

# HASH‚Ì’†g
foreach my $key ( sort keys( %{$hdata} ) ) {
	if($key eq "holiday"){
		my $tmp=$hdata->{$key};
		$tmp=~s/\?/`/g;
		$hdata->{$key}=$tmp;
	}
#    print "$key : $hdata->{$key} \n "
}
#print "\n\n";
eval{
	my $sth = $dbh->prepare(qq{insert into hospital (`city_name`,`city_kana`,`holiday`,`homepage`,`hpaddress`,`hpname`,`hpname_kana`,`hptel`,`hpzip`,`kamoku`,`keyword`,`pref_id`,`pref_name`,`trafic`) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?)} );
	$sth->execute($hdata->{city_name},$hdata->{city_kana},$hdata->{holiday},$hdata->{homepage},$hdata->{hpaddress},$hdata->{hpname},$hdata->{hpname_kana},$hdata->{hptel},$hdata->{hpzip},$hdata->{kamoku},$hdata->{keyword},$hdata->{pref_id},$hdata->{pref_name},$hdata->{trafic});
};

	return;
}