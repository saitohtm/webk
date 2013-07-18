#!/usr/bin/perl
# http://i.starblog.jp/ からブログデータを取得するプログラム

#use strict;
use DBI;
use Unicode::Japanese;
use LWP::UserAgent;
use Jcode;

use Date::Simple ('date', 'today');

my $dsn = 'DBI:mysql:waao';
my $user = 'mysqlweb';
my $password = 'WaAoqzxe7h6yyHz';

&_get_url('idol.php','1');
&_get_url('talent.php','2');
&_get_url('model.php','3');
&_get_url('actress.php','4');
&_get_url('actor.php','5');
&_get_url('owarai.php','6');
&_get_url('gravure.php','7');
&_get_url('musicianw.php','8');
&_get_url('musicianm.php','9');
&_get_url('ana.php','10');


&_get_url('sports.php','21');
&_get_url('baseball.php','22');
&_get_url('soccer.php','23');
&_get_url('fighter.php','24');
&_get_url('golfer.php','25');
&_get_url('prowrestling.php','26');
&_get_url('sumo.php','27');
&_get_url('dancer.php','28');


&_get_url('ainori.php','41');
&_get_url('av.php','42');
&_get_url('voiceactor.php','43');
&_get_url('shogi.php','44');
&_get_url('politician.php','45');
&_get_url('lawyer.php','46');
&_get_url('reader.php','47');
&_get_url('cooking.php','48');

&_get_url('ceo.php','61');
&_get_url('author.php','62');
&_get_url('journalist.php','63');
&_get_url('writer.php','64');
&_get_url('houso.php','65');
&_get_url('movie.php','66');
&_get_url('photographer.php','67');
&_get_url('manga.php','68');
&_get_url('scholar.php','69');
&_get_url('artist.php','70');


sub _get_url(){
	my $php = shift;
	my $genre = shift;
	
	my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 1, AutoCommit => 0});
	for(my $i=1;$i<=50;$i++){
		my $cmd = qq{http://i.starblog.jp/$php?p=$i};	
		print $cmd."\n";
		my $get_url = `GET $cmd`;
		$get_url =~s/<\/a>/<\/a>\n/g;
		my @lines = split(/\n/,$get_url);
#		sleep 2;
		my $cnt=0;
		my $chkflag;
		my $blogname;
		my $blogname2;
		my $blogurl;
		foreach my $line (@lines){
			$line = Jcode->new($line, 'sjis')->utf8;
#			print $line."\n\n";
			if($line=~/(.*)\. (.*)<br>(.*)/){
				$blogname = $2;
				$blogname2 = " $2";
				print $blogname.":\n";
				$chkflag = 1;
			}
			next unless($chkflag);
			if($line=~/(.*)\<a href=\"(.*)\">(.*)<\/a>(.*)/){
				$cnt++;
				$blogurl = $2;
				if($blogurl =~/http:\/\/www.miremasu.com\/index.php\?_ucb_u=(.*)/){
					$blogurl = $1;
				}
				print $blogurl.":\n";
				eval{
				# select 
				# insert
				my $sth = $dbh->prepare(qq{ select id, blogurl from keyword where keyword = ? } );
				$sth->execute($blogname);
				my $id;
				my $blogurl_tmp;
				while(my @row = $sth->fetchrow_array) {
					$id = $row[0];
					$blogurl_tmp = $row[1];
				}
				print "ID".$id.":\n";
				if( $id ){
					unless($blogurl_tmp){
						my $sth = $dbh->prepare(qq{ update keyword set blogurl=?, genre=?, blogflag=1 where id = ? } );
						$sth->execute($blogurl, $genre, $id);
					}
				}else{
					my $sth = $dbh->prepare(qq{insert into keyword ( `keyword`,`cnt`,`blogurl`,`genre`,`blogflag`) values (?,?,?,?,1)} );
					$sth->execute($blogname, 1, $blogurl, $genre);
				}
				if($genre eq 42){
					my $sth = $dbh->prepare(qq{ update keyword set av=1 where id = ? } );
					$sth->execute($id);
				}
#				my $sth = $dbh->prepare(qq{delete from keyword where keyword = ? and blogflag=1 limit 1} );
#				$sth->execute($blogname2);
				
				};
				$chkflag = undef;
			}
		}
		last if($cnt<=0);
	}
	$dbh->disconnect;
}
exit;