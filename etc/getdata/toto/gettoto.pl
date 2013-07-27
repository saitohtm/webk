#!/usr/bin/perl
# cron 設定
# etc/cron/getdata/daily.sh
# http://www.toto-dream.com/big/schedule/index.html からデータを取得するプログラム

# http://www.toto-dream.com/dc/SK5150.do?holdcnt=0244

#use strict;
use DBI;
use Unicode::Japanese;
use LWP::UserAgent;
use Jcode;

use Date::Simple ('date', 'today');

# ２重起動防止
if ($$ != `/usr/bin/pgrep -fo $0`) {
print "exit \n";
    exit 1;
}
print "start \n";


my $dsn = 'DBI:mysql:waao';
my $user = 'mysqlweb';
my $password = 'WaAoqzxe7h6yyHz';

my $maxid=244;

my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 1, AutoCommit => 0});
my $sth = $dbh->prepare( qq{select id  from toto where flag = 1 order by id desc limit 1} );
$sth->execute();
while(my @row = $sth->fetchrow_array) {
	$maxid = $row[0];
}
$dbh->disconnect;

my $max_i = $maxid + 20;
for(my $i=$maxid; $i<=$max_i; $i++){
	my $id = sprintf("%04d",$i);
	&_get_real($id);
	# スケジュール取得
#	&_get_schedule($id);
sleep 1;
}

exit;

sub _get_schedule(){
	my $id = shift;
	my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 1, AutoCommit => 0});
	
	my $url = qq{http://www.toto-dream.com/dci/I/IPB/IPB02.do?op=lnkHoldCntLotResultLstBIG&holdCntId=$id};
	my $get_url = `GET $url`;
print "$url\n";
	my $type;
	my @dates;
	my $date_str;
	my $flag;
	my @lines = split(/\n/,$get_url);
	foreach my $line (@lines){
		$line = Jcode->new($line, 'sjis')->utf8;
		if($line=~/<td width=\"450\" class=\"list_border list_title_gray fontstyle\" style=\"text-align: left;\"> 第(.*)回 BIG (.*)<\/td>/){
			$type = 1;
		}elsif($line=~/<td width=\"450\" class=\"list_border list_title_gray fontstyle\" style=\"text-align: left;\"> 第(.*)回 BIG1000 (.*)<\/td>/){
			$type = 2;
		}elsif($line=~/<td width=\"450\" class=\"list_border list_title_gray fontstyle\" style=\"text-align: left;\"> 第(.*)回 mini BIG (.*)<\/td>/){
			$type = 3;
		}
	
		if($line=~/<td class=\"list_sale_fontstyle\">(.*)年(.*)月(.*)日\((.*)\)<\/td>/){
			my $date = $1.qq{-}.$2.qq{-}.$3;
			$date = substr($date,0,10);
			push (@dates,$date) if($date);
			$date_str.=qq{$date,};
			$flag = 1;
		}	
		if($line=~/(.*)年(.*)月(.*)日((.*))<br>/){
			my $date = $1.qq{-}.$2.qq{-}.$3;
			$date=~s/ //g;
			$date=~s/\s//g;
			$date = substr($date,0,10);
			push (@dates,$date) if($date);
			$date_str.=qq{$date,};
			$flag = 1;
		}	
		if($flag){
			if($line=~/<\/table>/){
				print "type::$type \n";
				print "dates::@dates \n";
				print "dates::$date_str \n";
				my @dates = split(/,/,$date_str);

eval{
my $sth = $dbh->prepare(qq{insert into toto ( `id`,`type`,`start_date`,`end_date`,`opne_date`) values (?,?,?,?,?)});
$sth->execute($id,$type,$dates[0],$dates[1],$dates[2]);
};

				print "dates1::$dates[0] \n";
				print "dates2::$dates[1] \n";
				print "dates3::$dates[2] \n";
				print "dates4::$dates[3] \n";
				@dates = undef;
				$date_str = undef;
				$flag = undef;
			}
		}
	}

	$dbh->disconnect;
		
	return;
}

sub _get_real(){
	my $id = shift;

	my $url = qq{http://www.toto-dream.com/dci/I/IPB/IPB02.do?op=lnkHoldCntLotResultLstBIG&holdCntId=$id};
	my $get_url = `GET $url`;
print "$url\n";
	my @lines = split(/\n/,$get_url);
	my ($big_flag,$big1000_flag,$minibig);
	my $no_flag;
	my @nos;
	my $prize_flag;
	my @prizes;

	my $game_flag;
	my @games;

	my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 1, AutoCommit => 0});
	my $type;
	my $db_flag = 1;
	foreach my $line (@lines){
		$line = Jcode->new($line, 'sjis')->utf8;
		if($line=~/<td width=\"450\" class=\"list_border list_title_gray fontstyle\" style=\"text-align: left;\">(.*)回 BIG (.*)<\/td>/){
				$type = 1;
				$big_flag = 1;
				$big1000_flag = undef;
				$minibig = undef;
		}
		if($line=~/<td width=\"450\" class=\"list_border list_title_gray fontstyle\" style=\"text-align: left;\">(.*)回 BIG1000 (.*)<\/td>/){
				$type = 2;
				$big_flag = undef;
				$big1000_flag = 1;
				$minibig = undef;
		}
		if($line=~/<td width=\"450\" class=\"list_border list_title_gray fontstyle\" style=\"text-align: left;\">(.*)回 mini BIG (.*)<\/td>/){
				$type = 3;
				$big_flag = undef;
				$big1000_flag = undef;
				$minibig = 1;
		}

if($db_flag && $type){
eval{
my $sth = $dbh->prepare(qq{insert into toto ( `id`,`type`,`flag`) values (?,?,1)});
$sth->execute($id,$type);
};
	$db_flag = undef;
}
		# 当選番号
		if($line=~/<td class=\"list_lotrslt_fontstyle width_disp_lotrst list_lotrslt_odd\">/){
			$no_flag = 1;
		}elsif($line=~/<td class=\"list_lotrslt_fontstyle width_disp_lotrst list_lotrslt_even\">/){
			$no_flag = 1;
		}elsif($line=~/<td class=\"list_lotrslt_fontstyle  list_lotrslt_odd\">/){
			$no_flag = 1;
		}
		if($no_flag){
			if($line=~/0/){
				push(@nos,0);
			}elsif($line=~/1/){
				push(@nos,1);
			}elsif($line=~/2/){
				push(@nos,2);
			}
		}
		if($no_flag){
			if($line=~/<\/table>/){
				print "no::$id \n";
				print "flag:: $big_flag :: $big1000_flag :: $minibig \n";

				print "nos:: @nos \n";
				@nos = undef;
				$no_flag = undef;
			}
		}
		
		# 当選内容
		if($line=~/<table class=\"width_prize\" border=\"0\" cellpadding=\"0\" cellspacing=\"1\">/){
			$prize_flag = 1;
		}
		if($prize_flag){
			if($line=~/<td class=(.*)>(.*)等<\/td>/){
				@prizes = undef;
#				push(@prizes,$2);
				$prize_flag = 2;
			}
			if($prize_flag eq 2){
				if($line=~/<td class=(.*)>(.*)<\/td>/){
					print "prizesval:: $2 \n";
					push(@prizes,$2);
				}
				if($prizes[4]){
					#print "prize:: @prizes \n";

eval{
my $sth = $dbh->prepare(qq{insert into toto_prize ( `toto_id`,`type`,`prize`,`price`,`cnt`,`cov`) values (?,?,?,?,?,?)});
$sth->execute($id,$type,$prizes[1],$prizes[2],$prizes[3],$prizes[4]);
};

# 0はなし
					print "prize0:: $prizes[0] \n";
					print "prize1:: $prizes[1] \n";
					print "prize2:: $prizes[2] \n";
					print "prize3:: $prizes[3] \n";
					print "prize4:: $prizes[4] \n";
					@prizes = undef;
				}
			}
			if($line=~/<\/table>/){
				$prize_flag = undef;
			}
		}

		# 試合結果
		if($line=~/<table border=\"0\" cellpadding=\"0\" cellspacing=\"1\" class=\"width_disp\">/){
			$game_flag = 1;
		}
		if($game_flag){
			if($line=~/<td class=\"list_border list_fontstyle list_title_game\">(.*)<\/td>/){
				@games = undef;
				$game_flag = 2;
			}
			if($game_flag eq 2){
				if($line=~/<td class=\"list_border list_fontstyle(.*)>(.*)<\/td>/){
#					print "gameval:: $2 \n";
					push(@games,$2);
				}
				if($games[5]){
					#print "game:: @games \n";

eval{
my $sth = $dbh->prepare(qq{insert into toto_game ( `toto_id`,`type`,`no`,`team1`,`vs_result`,`team2`,`no_result`) values (?,?,?,?,?,?,?)});
$sth->execute($id,$type,$games[1],$games[2],$games[3],$games[4],$games[5]);
};

# 0はなし
					print "game0:: $games[0] ::\n";
					print "game1:: $games[1] ::\n";
					print "game2:: $games[2] ::\n";
					print "game3:: $games[3] ::\n";
					print "game4:: $games[4] ::\n";
					print "game5:: $games[5] ::\n";
					@games = undef;
				}
			}
			if($line=~/<\/table>/){
				$game_flag = undef;
			}
		}
	}

	$dbh->disconnect;

	return;
}

exit;