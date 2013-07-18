#!/usr/bin/perl
# http://www.mizuhobank.co.jp/index.html からブログデータを取得するプログラム

#use strict;
use DBI;
use Unicode::Japanese;
use LWP::UserAgent;
use Jcode;

use Date::Simple ('date', 'today');

my $dsn = 'DBI:mysql:waao';
my $user = 'mysqlweb';
my $password = 'WaAoqzxe7h6yyHz';

#当月データ
&_get_loto7_real();
#&_get_loto6_real('201104');

for(my $i=0;$i<=100;$i++){
	my $no = $i * 20 + 1;
	my $page_no = sprintf("%04d",$no);
#	&_get_loto6($page_no);
#last;
}


sub _get_loto7_real(){
	my $page_no = shift;

	my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 1, AutoCommit => 0});
	my $cmd = qq{http://www.mizuhobank.co.jp/takarakuji/loto/backnumber/lt7-$page_no}.qq{.html};
	$cmd = qq{http://www.mizuhobank.co.jp/takarakuji/loto/loto7/index.html} unless($page_no);
	print $cmd."\n";
	my $get_url = `GET $cmd`;

	my $lotono;
	my $lotodate;
	my @lotonos;
	my @pc;
	my @py;
	my @cy;
	my @bonus;
	my $flag;
	my $nodatacnt;
	my @lines = split(/\n/,$get_url);
	foreach my $line (@lines){
#		$line = Jcode->new($line, 'utf8')->sjis;
		if($line=~/<th colspan=\"7\" class=\"center bgf7f7f7\">第(.*)回<\/th>/){
			$lotono = $1;
			$flag = 1;
		}
		if($flag){
			if($line=~/<td colspan=\"7\" class=\"center\">(.*)年(.*)月(.*)日<\/td>/){
				$lotodate = sprintf("%04d-%02d-%02d",$1,$2,$3);
			}elsif($line=~/<td class=\"center\">(.*)<\/td>/){
				push (@lotonos,$1) if($1);
			}elsif($line=~/<td class=\"center green\">\((.*)\)<\/td>/){
				push (@bonus,$1) if($1);
			}elsif($line=~/<td colspan=\"3\" class=\"right\">(.*)口<\/td>/){
				my $pc_str = $1;
				$pc_str =~s/,//g;
				push (@pc,$pc_str);
			}elsif($line=~/<td colspan=\"4\" class=\"right\">(.*)円<\/td>/){
				my $py_str = $1;
				$py_str =~s/,//g;
				push (@py,$py_str) if($py_str >= 0);
			}elsif($line=~/<td colspan=\"4\" class=\"right\">該当なし<\/td>/){
				$nodatacnt++;
				if($nodatacnt %2){
					push (@pc,0);
				}else{
					push (@py,0);
				}
			}elsif($line=~/<td colspan=\"7\" class=\"right\">(.*)円<\/td>/){
				my $cy_str = $1;
				$cy_str =~s/,//g;
				push (@cy,$cy_str) if($cy_str >= 0);
			}
			if($line =~/(.*)end .typeTK(.*)/){

print "$lotono\n";
print "$lotodate\n";
my $lotonos_str;
foreach my $lotodata (@lotonos){
	$lotonos_str .= qq{$lotodata,} if($lotodata >=0);
}
$lotonos_str =~s/^,//;
chop $lotonos_str;
print "$lotonos_str\n";

my $bonus_str;
foreach my $lotodata (@bonus){
	$bonus_str .= qq{$lotodata,} if($lotodata >=0);
}
$bonus_str =~s/^,//;
chop $bonus_str;

print "$bonus_str\n";

my $pc_str;
foreach my $pcdata (@pc){
	$pc_str .= qq{$pcdata,};
}
$pc_str =~s/^,//;
chop $pc_str;
print "$pc_str\n";

my $py_str;
foreach my $pydata (@py){
	$py_str .= qq{$pydata,} if($pydata >=0);
}
$py_str =~s/^,//;
chop $py_str;
print "$py_str\n";

my $cy_str;
foreach my $cydata (@cy){
	$cy_str .= qq{$cydata,} if($cydata >=0);
}
$cy_str =~s/^,//;
chop $cy_str;
print "$cy_str\n";

eval{

my $sth = $dbh->prepare(qq{insert into loto7 ( `id`,`date`,`n1`,`n2`,`n3`,`n4`,`n5`,`n6`,`n7`,`nb`,`nb2`,`pc1`,`pc2`,`pc3`,`pc4`,`pc5`,`pc6`,`py1`,`py2`,`py3`,`py4`,`py5`,`py6`,`am`,`coy`) values (?,?,$lotonos_str,$bonus_str,$pc_str,$py_str,$cy_str)} );
$sth->execute($lotono,$lotodate);
};

				$flag = undef;
				@lotonos = undef;
				@bonus = undef;
				@pc = undef;
				@py = undef;
				@cy = undef;
			}
		}
	}

	$dbh->disconnect;
	return;
}

sub _get_loto6(){
	my $page_no = shift;
	
	my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 1, AutoCommit => 0});
	my $cmd = qq{http://www.mizuhobank.co.jp/takarakuji/loto/backnumber/loto6$page_no}.qq{.html};	
	#print $cmd."\n";
	my $get_url = `GET $cmd`;

	my @lines = split(/\n/,$get_url);

	my $lotono;
	my $lotodate;
	my @lotonos;
	my $bonus;
	my $flag;
	foreach my $line (@lines){
#		$line = Jcode->new($line, 'utf8')->sjis;
		if($line=~/<th class=\"bgf7f7f7\">第(.*)回<\/th>/){
			$lotono = $1;
			$flag = 1;
		}
		if($flag){
			if($line=~/<td class=\"right\">(.*)年(.*)月(.*)日<\/td>/){
				$lotodate = sprintf("%04d-%02d-%02d",$1,$2,$3);
			}elsif($line=~/<td>(.*)<\/td>/){
				push (@lotonos,$1) if($1);
			}
			if($line=~/<td class=\"center green\">(.*)<\/td>/){
				$bonus = $1;
#print "$lotono\n";
#print "$lotodate\n";
my $datastr;
foreach my $lotodata (@lotonos){
#	print "$lotodata\n" if($lotodata);
	$datastr .= qq{$lotodata,} if($lotodata);
}
chop $datastr;
#print "$datastr\n";
#print "$bonus\n";
eval{
my $sth = $dbh->prepare(qq{insert into loto6 ( `id`,`date`,`n1`,`n2`,`n3`,`n4`,`n5`,`n6`,`nb`) values (?,?,$datastr,?)} );
$sth->execute($lotono,$lotodate,$bonus);
};
				$flag = undef;
				@lotonos = undef;
			}
		}
	}
	$dbh->disconnect;
}
exit;