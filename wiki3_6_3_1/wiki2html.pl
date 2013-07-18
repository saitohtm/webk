#!/usr/bin/perl
use lib '/var/www/vhosts/waao.jp/wiki3_6_3_1/lib';
use strict;
use Wiki;
use Util;
use Jcode;
use DBI;

#AV これやんないと
#http://www.use-api.com/adult/av_list.php

my $wiki = Wiki->new('/var/www/vhosts/waao.jp/wiki3_6_3_1/setup.dat');

my $dbh = &_db_connect();
my $dbh2 = &_db_connect2();

# １５日前
my $start_time;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time - 1296000);
$year = $year + 1900;
$mon = $mon + 1;
$start_time = sprintf("%d%02d%02d%02d%02d%02d",$year,$mon,$mday,$hour,$min,$sec);
$start_time = 0;

my $max_cnt;
my $sth = $dbh->prepare(qq{ select max(rev_id)  from revision } );
$sth->execute();
while(my @row = $sth->fetchrow_array) {
	$max_cnt = $row[0];
}
print $max_cnt."\n";
$max_cnt = int($max_cnt/1000) + 1;
print $max_cnt."\n";

# revision 
# rev_timestamp で無駄なデータの更新が不要になる 20040430144600(yyyymmddhhmmss)
# http://www.mediawiki.org/wiki/Revision_table/ja

for(my $i=0;$i<=$max_cnt;$i++){ #for
my $def_cnt = 1000;
my $start_id = 2168855 + $i * $def_cnt;
my $end_id = $start_id + $def_cnt;

my $rev_id;
my $rev_page;
my $rev_text_id;
print "revision::::::::: $i / 27712  $start_id - $end_id \n";
my $sth = $dbh->prepare(qq{ select rev_id, rev_page, rev_text_id  from revision where rev_id between ? and ? and rev_timestamp >= ? limit $def_cnt} );
$sth->execute($start_id, $end_id, $start_time);
##my $sth = $dbh->prepare(qq{ select rev_id, rev_page, rev_text_id  from revision where rev_id = ? limit 1} );
##$sth->execute(29999810);
while(my @row = $sth->fetchrow_array) {
	$rev_id  = $row[0];
	$rev_page  = $row[1];
	$rev_text_id  = $row[2];

	my ($wiki_title,$wiki_text,,$person,$sex,$birthday,$singer,$blood,$birth_name,$linklist,$page_namespace);

	# page
	# page_namespace = 0 がメイン
	# http://www.mediawiki.org/wiki/Page_table/ja

	my $sth2 = $dbh->prepare(qq{ select page_title, page_namespace from page where page_id = ? limit 1} );
	$sth2->execute($rev_page);

	while(my @row = $sth2->fetchrow_array) {
		($wiki_title,$person,$sex,$birthday,$singer,$blood,$birth_name,$linklist) = &_process_wiki($wiki, $row[0]);
		$wiki_title =~s/\n//g;
		$page_namespace = $row[1];
	}

	# text
	# http://www.mediawiki.org/wiki/Text_table/ja
	my $sth3 = $dbh->prepare(qq{ select old_text from text where old_id = ? limit 1 } );
	$sth3->execute($rev_text_id);
	while(my @row = $sth3->fetchrow_array) {
		($wiki_text,$person,$sex,$birthday,$singer,$blood,$birth_name,$linklist) = &_process_wiki($wiki, $row[0]);
		$wiki_text = Jcode->new($wiki_text, 'utf8')->sjis;
	}
	
	# データ更新
	my $sth4 = $dbh2->prepare(qq{ select rev_id from wikipedia where rev_id = ? } );
	$sth4->execute($rev_id);
	my $datachkflg;
	while(my @row = $sth4->fetchrow_array) {
		$datachkflg = 1;
	}
eval{
	if( $datachkflg ){
		# update
		my $sth4 = $dbh2->prepare(qq{ update wikipedia set keyword=?, wikipedia=? where rev_id=? limit 1} );
		$sth4->execute( $wiki_title, $wiki_text, $rev_id );
#		my $sth4 = $dbh2->prepare(qq{ update wikipedia set keyword=?, wikipedia=?,person=?,sex=?,birthday=?,singer=?,blood=?,birth_name=?,linklist=?,page_namespace=? where rev_id=? limit 1} );
#		$sth4->execute( $wiki_title, $wiki_text, $person,$sex,$birthday,$singer,$blood,$birth_name,$linklist,$page_namespace, $rev_id );
	}else{
		# insert
		my $sth4 = $dbh2->prepare(qq{insert into wikipedia ( `rev_id`,`keyword`,`wikipedia`,`person`,`sex`,`birthday`,`singer`,`blood`,`birth_name`,`linklist`,`page_namespace`) values (?,?,?,?,?,?,?,?,?,?,?)} );
		$sth4->execute($rev_id, $wiki_title, $wiki_text,$person,$sex,$birthday,$singer,$blood,$birth_name,$linklist,$page_namespace);
	}
};
if($@){
	print "$@ $rev_id \n";
}
}
#print "::::::::: $start_id $end_id end ::::::::::::::: \n";
}#for

$dbh2->disconnect;
$dbh->disconnect;

sub _process_wiki(){
	my $wiki = shift;
	my $wikitext =shift;
	
	# 1行単位で wiki -> html
	my @vals = split(/\n/,$wikitext);
	$wikitext = undef;
	my ($person,$sex,$birthday,$singer,$blood,$birth_name, $linklist, $linkcnt);			
	my $chkstr = q{{{半保護}}};
	$chkstr = Jcode->new($chkstr, 'sjis')->utf8;
	my $chkstr2 = Jcode->new('。', 'sjis')->utf8;
	my $mark = Jcode->new('■', 'sjis')->utf8;
	my $likestr = Jcode->new('混同', 'sjis')->utf8;
	my $bloodstr = Jcode->new('血液型', 'sjis')->utf8;
	my $birth_namestr = Jcode->new('本名', 'sjis')->utf8;
	my $yearstr = Jcode->new('生年', 'sjis')->utf8;
	my $monthstr = Jcode->new('生月', 'sjis')->utf8;
	my $daystr = Jcode->new('生日', 'sjis')->utf8;
	my $namestr = Jcode->new('別名', 'sjis')->utf8;

	my $preflag;
	foreach my $valstr (@vals){
#print $valstr."\n";
		next if($valstr =~/$likestr/);
		next if($valstr =~/$chkstr/);
		next if($valstr =~/infobox/i);
		next if($valstr =~/vertical-align/i);
		next if($valstr =~/ActorActress/i);
		next if($valstr =~/"wikitable"/i);
		next if($valstr =~/\|thumb\|/i);
		 
		$valstr =~s/$chkstr2/$chkstr2\<br\>\n/g;
#print $valstr."\n";
		
		# 歌手かどうか
		$singer = 1 if($valstr =~/singer/i);
		# 血液型
		if($valstr =~/Blood/i){
			my @bloodval = split(/=/,$valstr);			
			$blood = $bloodval[1];
			$blood =~s/ //g;
			$blood = Jcode->new($blood, 'utf8')->sjis;
		}elsif($valstr =~/$bloodstr/i){
			my $astr = Jcode->new('A型', 'sjis')->utf8;
			my $bstr = Jcode->new('B型', 'sjis')->utf8;
			my $ostr = Jcode->new('O型', 'sjis')->utf8;
			my $abstr = Jcode->new('AB型', 'sjis')->utf8;
			if($valstr =~/$astr/i){
				$blood = qq{A型};
			}elsif($valstr =~/$bstr/i){
				$blood = qq{B型};
			}elsif($valstr =~/$ostr/i){
				$blood = qq{O型};
			}elsif($valstr =~/$abstr/i){
				$blood = qq{AB型};
			}
		}
		# 本名
		if( ($valstr =~/Birth_name/i) || ($valstr =~/$birth_namestr/i) ){
			my @birth_nameval = split(/=/,$valstr);			
			$birth_name = $birth_nameval[1];
			$birth_name =~s/ //g;
			$birth_name = Jcode->new($birth_name, 'utf8')->sjis;
		}
		# 誕生日
		if($valstr =~/Born/i){
			my @birthdayval = split(/=/,$valstr);			
			my @bdayval = split(/\|/,$birthdayval[1]);			
			$birthday = $bdayval[1]."-".$bdayval[2]."-".$bdayval[3];
		}
		if($valstr =~/$yearstr/i){
			my @birthdayval = split(/=/,$valstr);			
			my $year = $birthdayval[1];
			$year =~s/ //g;
			$birthday .= $year."-";
		}
		if($valstr =~/$monthstr/i){
			my @birthdayval = split(/=/,$valstr);			
			my $month = $birthdayval[1];
			$month =~s/ //g;
			$birthday .= $month."-";
		}
		if($valstr =~/$daystr/i){
			my @birthdayval = split(/=/,$valstr);			
			my $day = $birthdayval[1];
			$day =~s/ //g;
			$birthday .= $day;
		}
		
		# 人名
		if($birth_name|$birthday){
			$person = 1;
		}
		# リンク調査
		if($valstr =~/^==/i){
			$linkcnt++;
			my $tmpval = $valstr;
			$tmpval=~s/=//g;
			$tmpval=~s/ //g;
			$tmpval = Jcode->new($tmpval, 'utf8')->sjis;
			$linklist .= qq{<a href="#links_$linkcnt">$tmpval</a><br>\n};
#print "#################################".$valstr."\n";
			$valstr = qq{<a name=links_$linkcnt></a>$valstr\n}; 
#print "##########".$valstr."\n";
#			$valstr .= qq{<a name="links_$linkcnt"></a>\n}; 
#			my $tmpstr = $valstr;
#			$valstr = qq{<a name="links_$linkcnt"></a>\n}.$tmpstr; 
		}
		next if($valstr =~/^\| /);

		$valstr =~s/{{//g;
		$valstr =~s/}}//g;
		$valstr =~s/^\*\*/<br>/g;
		$valstr =~s/^\*/<br>/g;
		$valstr =~s/^\!/\|/g;
		$valstr =~s/\|-/<br>/g;
		$valstr =~s/^;/<br>$mark/g;
		$valstr =~s/^\[\[Category/<br>\[\[Category/g;
		$valstr =~s/^Link FA/<br>Link FA/g;

		my $val = $wiki->process_wiki($valstr);

		if($val =~/\<\/pre\>/){
			$preflag=undef;
		}
		if($val =~/\<pre\>/){
			$preflag=1;
		}
		if($preflag){
			unless($val =~/\<br\>/){
				$val.=qq{<br>\n};
			}
		}
		$val =~s/\<pre\>//g;
		$val =~s/\<\/pre\>//g;
		$val =~s/\<p\>//g;
		$val =~s/\<\/p\>//g;
		$val =~s/&lt;/\</g;
		$val =~s/&gt;/\>/g;

		# モバイルで必要ないタグの除去 or 組み換え
		$val =~s/\<li\>//g;
		$val =~s/\<\/li\>//g;
		$val =~s/\<ul\>//g;
		$val =~s/\<\/ul\>//g;
		$val =~s/\<dl\>//g;
		$val =~s/\<\/dl\>//g;
		$val =~s/\<dd\>//g;
		$val =~s/\<\/dd\>//g;
		$val =~s/&amp;amp;/&amp;/g;
		$val =~s/&amp;bnsp;/&bnsp;/g;
		$val =~s/\'\'\'//g;
		
		# a タグの制御(start) <span class="nopage">xxxxx</span><a href="">?</a> <span class="nopage">xxxxx</span><a href="">?</a>
		if($val=~/\?\<\/a\>/){
			$val =~s/\?\<\/a\>/\?\<\/a\>\n/g;
			my @atags = split(/\n/,$val);			
			$val = undef;
			# atag 除去
			foreach my $atag (@atags){
				if($atag =~/(.*)\<span class\=\"nopage\"\>(.*)\<\/span\>\<a href(.*)\>\?\<\/a\>(.*)/){
					my $val1 = $1;
					my $val2 = $2;
					my $keystr = $2;
					$keystr =~s/ /\_/g;
					my $str_sjis = Jcode->new($keystr, 'utf8')->sjis;
					my $str_encode = &_str_encode($str_sjis);
					$val .= $val1.qq{<a href="/$str_encode/wiki/">$val2</a>}.$4."\n";
				}else{
					$val .= $atag."\n";
				}
			}
		}# a タグの制御(end)

		# del タグの制御(start)
		if($val =~/(.*)\<del\>(.*)\<\/del\>(.*)/){
#print "######".$val."\n";
			$val = qq{$1\n<h2>}.$2.qq{</h2>\n};
			my $tmpstr = $3;
			$tmpstr =~s/&quot;/\"/g;
			$val .= qq{$tmpstr\n};
#print "###".$val."\n";
		} #del タグの制御(end)
		
		next if($val =~/\|\}/i);
#print $val."\n\n";
		$wikitext .= $val."\n";
	}
	return ($wikitext,$person,$sex,$birthday,$singer,$blood,$birth_name,$linklist);
}

# db connect
sub _db_connect(){
    my $dsn = 'DBI:mysql:corpus';
    my $user = 'mysqlweb';
    my $password = 'WaAoqzxe7h6yyHz';

    my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 1, AutoCommit => 0});
	
	return $dbh;
}

sub _db_connect2(){
    my $dsn = 'DBI:mysql:waao';
    my $user = 'mysqlweb';
    my $password = 'WaAoqzxe7h6yyHz';

    my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 1, AutoCommit => 0});
	
	return $dbh;
}
sub _str_encode(){
	my $str = shift;

	$str =~ s/([^0-9A-Za-z_ ])/'%'.unpack('H2',$1)/ge;
	$str =~ s/ /%20/g;

	return $str;
}
