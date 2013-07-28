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


my $dsn = 'DBI:mysql:waao';
my $user = 'mysqlweb';
my $password = 'WaAoqzxe7h6yyHz';

my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 1, AutoCommit => 0});


#for(my $i=1;$i<36814;$i++){
for(my $i=16170;$i<36814;$i++){
	my $url = qq{http://www.tv-ranking.com/detail/$i.php};
	my $get_url = `GET $url`;
print "$url\n";
	my $keyword;
	my $keyword_id;
	my $job;
	my $kana;
	my $category;
	my $pref;
	my $birthday;
	my $group;
	my $tag;
	my $keywords;
	my $family;
	$get_url =~s/<\/tr>/<\/tr>\n/g;
	my @lines = split(/\n/,$get_url);
	foreach my $line (@lines){
#		print $line."\n";
		if($line =~/<h1>(.*)<span class=\"font-s\">（(.*)）<\/span><\/h1>/){
			$keyword = $1;
			$job = $2;
			$keyword_id = &_keyword_ins($dbh,$keyword);
#			&_jobs($dbh,$keyword_id,$job);

		}elsif($line =~/<h1>(.*)<\/h1>/){
			$keyword = $1;
#			$keyword_id = &_keyword_ins($dbh,$keyword);
		}
		if($line =~/<tr><th>かな<\/th><td>(.*)<\/td><\/tr>/){
			$kana = $1;
#			&_kana($dbh,$keyword_id,$kana);
		}
		if($line =~/<tr><th>出身<\/th><td><a(.*)>(.*)<\/a><\/td><\/tr>/){
			$pref = $2;
#			&_pref($dbh,$keyword_id,$pref);
		}
		if($line =~/<tr><th>生年月日<\/th><td><a href=\"(.*)\">(.*)年<\/a> <a href=\"(.*)\">(.*)月(.*)日<\/a>(.*)<\/td><\/tr>/){
			my $y = $2;
			my $m = $4;
			my $d = $5;
			$birthday = sprintf("%04d/%02d/%02d",$y,$m,$d);			
			&_birth($dbh,$keyword_id,$y,$m,$d,$birthday);
		}
		if($line =~/<tr><th>カテゴリ<\/th><td>(.*)<\/td><\/tr>/){
			my $category_list = $1;
			if($category_list=~/俳優/){
				$category = qq{ genre = 5 };
#				&_genre($dbh,$keyword_id,5);
			}
			if($category_list=~/声優/){
				$category = qq{ genre = 43 };
#				&_genre($dbh,$keyword_id,43);
			}
			if($category_list=~/タレント/){
				$category = qq{ genre = 2 };
#				&_genre($dbh,$keyword_id,2);
			}
			if($category_list=~/芸人/){
				$category = qq{ person = 4 and genre = 6 };
#				&_person($dbh,$keyword_id,4);
#				&_genre($dbh,$keyword_id,6);
			}
			if($category_list=~/歌手/){
				$category = qq{ artist = 1 };
#				&_artist($dbh,$keyword_id,1);
			}
			if($category_list=~/アイドル/){
				$category = qq{ genre = 1 };
#				&_genre($dbh,$keyword_id,1);
			}
			if($category_list=~/スポーツ/){
				$category = qq{ genre = 21 };
#				&_genre($dbh,$keyword_id,21);
			}
			if($category_list=~/アナウンサー/){
				$category = qq{ ana = 1 };
#				&_ana($dbh,$keyword_id,1);
			}
			if($category_list=~/モデル/){
				$category = qq{ model = 1 };
#				&_model($dbh,$keyword_id,1);
			}
		}
		if($line =~/(.*)<p class=\"portrait\"><a href=(.*)><img src=(.*)alt=\"(.*)\" wi(.*)/){
#			&_family($dbh,$keyword,$keyword_id,$4,10);
			$keywords.=$4;
		}
		if($line =~/<tr><th>所属グループ<\/th><td class=\"group\"><li>(.*)<\/li>/){
			my $tmpdata = $1;
			my @tmps = split(/、/,$tmpdata);
			foreach my $tmp (@tmps){
				if($line =~/<a href(.*)>(.*)<\/a>/){
#					&_group($dbh,$keyword_id,$2);
					$group .= $2;
				}
			}
		}
		if($line =~/<tr><th>タグ<\/th><td><a href(.*)>(.*)<\/a><\/td><\/tr>/){
			$tag = $2;
#			&_tag($dbh,$keyword_id,$tag);
		}
		if($line =~/<tr><th>家族・親族<\/th><td class=\"family\">(.*)<a href=\"(.*)\">(.*)<\/a><\/li>/){
			$family = $3;
#			&_family($dbh,$keyword,$keyword_id,$family,3);
		}

	}

#	print "$url\n";
	print "keyword : $keyword\n";
#	print "keyword_id : $keyword_id\n";
#	print "job : $job\n";
#	print "kana : $kana\n";
#	print "pref : $pref\n";
	print "birthday : $birthday\n";
#	print "category : $category\n";
#	print "keywords : $keywords\n";
#	print "group : $group\n";
#	print "tag : $tag\n";
#	print "family : $family\n";

}

$dbh->disconnect;

sub _keyword_ins(){
	my $dbh = shift;
	my $keyword = shift;
	
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

	return $keyword_id;
}

sub _family(){
	my $dbh = shift;
	my $keyword = shift;
	my $keyword_id = shift;
	my $family = shift;
	my $type = shift;
	my $family_id;

eval{
	my $sth = $dbh->prepare(qq{insert into keyword (`keyword`) values(?)});
	$sth->execute($family);
};

	my $sth = $dbh->prepare(qq{select id from keyword where keyword = ? limit 1});
	$sth->execute($family);
	while(my @row = $sth->fetchrow_array) {
		$family_id = $row[0];
	}

eval{
	my $sth = $dbh->prepare(qq{insert into keyword_recomend (`keywordid`,`keyword`,`keypersonid`,`keyperson`,`type`,`point`) values(?,?,?,?,?,?)});
	$sth->execute($keyword_id,$keyword,$family_id,$family,$type,100);
};

	return;
}

sub _group(){
	my $dbh = shift;
	my $keyword_id = shift;
	my $group = shift;

	my $group_id;
eval{
	my $sth = $dbh->prepare(qq{insert into keyword_group_list (`name`) values(?)});
	$sth->execute($group);
};

	my $sth = $dbh->prepare(qq{select id from keyword_group_list where name = ? limit 1});
	$sth->execute($group);
	while(my @row = $sth->fetchrow_array) {
		$group_id = $row[0];
	}

eval{
	my $sth = $dbh->prepare(qq{insert into keyword_group (`keyword_id`,`group_id`) values(?,?)});
	$sth->execute($keyword_id,$group_id);
};
	
	return;
}

sub _birth(){
	my $dbh = shift;
	my $keyword_id = shift;
	my $y = shift;
	my $m = shift;
	my $d = shift;
	my $birth = shift;
	
	print "birthday $birth $y $m $d $keyword_id \n";

eval{
	my $sth = $dbh->prepare(qq{update keyword set birthday = ?,b_year=?,b_mon=?,b_day=? where id = ? limit 1});
	$sth->execute($birth,$y,$m,$d,$keyword_id);
};
if($@){
	print "$@\n";
}
	
	return;
}

sub _pref(){
	my $dbh = shift;
	my $keyword_id = shift;
	my $pref = shift;

	my $pref_id;
	my $sth = $dbh->prepare(qq{select id from pref where name = ? limit 1});
	$sth->execute($pref);
	while(my @row = $sth->fetchrow_array) {
		$pref_id = $row[0];
	}

eval{
	my $sth = $dbh->prepare(qq{update keyword set pref_id = ? where id = ? limit 1});
	$sth->execute($pref_id,$keyword_id);
};
	
	return;
}


sub _jobs(){
	my $dbh = shift;
	my $keyword_id = shift;
	my $jobs = shift;

eval{
	my $sth = $dbh->prepare(qq{update keyword set jobs = ? where id = ? limit 1});
	$sth->execute($jobs,$keyword_id);
};
	
	return;
}

sub _genre(){
	my $dbh = shift;
	my $keyword_id = shift;
	my $genre = shift;

eval{
	my $sth = $dbh->prepare(qq{update keyword set genre = ? where id = ? limit 1});
	$sth->execute($genre,$keyword_id);
};
	
	return;
}

sub _model(){
	my $dbh = shift;
	my $keyword_id = shift;
	my $model = shift;

eval{
	my $sth = $dbh->prepare(qq{update keyword set model = ? where id = ? limit 1});
	$sth->execute($model,$keyword_id);
};
	
	return;
}

sub _ana(){
	my $dbh = shift;
	my $keyword_id = shift;
	my $ana = shift;

eval{
	my $sth = $dbh->prepare(qq{update keyword set ana = ? where id = ? limit 1});
	$sth->execute($ana,$keyword_id);
};
	
	return;
}

sub _artist(){
	my $dbh = shift;
	my $keyword_id = shift;
	my $artist = shift;

eval{
	my $sth = $dbh->prepare(qq{update keyword set artist = ? where id = ? limit 1});
	$sth->execute($artist,$keyword_id);
};
	
	return;
}

sub _tag(){
	my $dbh = shift;
	my $keyword_id = shift;
	my $tag = shift;

eval{
	my $sth = $dbh->prepare(qq{update keyword set tag = ? where id = ? limit 1});
	$sth->execute($tag,$keyword_id);
};
	
	return;
}

sub _person(){
	my $dbh = shift;
	my $keyword_id = shift;
	my $person = shift;

eval{
	my $sth = $dbh->prepare(qq{update keyword set person = ? where id = ? limit 1});
	$sth->execute($person,$keyword_id);
};
	
	return;
}


sub _kana(){
	my $dbh = shift;
	my $keyword_id = shift;
	my $kana = shift;

eval{
	my $sth = $dbh->prepare(qq{update keyword set kana = ? where id = ? limit 1});
	$sth->execute($kana,$keyword_id);
};
	
	return;
}
1;