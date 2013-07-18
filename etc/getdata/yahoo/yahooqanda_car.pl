#!/usr/bin/perl
# Q&A取得
# 上限50000／日
#use strict;

use DBI;
use CGI qw( escape );
use Unicode::Japanese;
use LWP::UserAgent;
use Jcode;
use utf8;
use encoding 'utf8', 
STDIN=>'utf8', STDOUT=>'utf8';

my $dsn = 'DBI:mysql:waao';
my $user = 'mysqlweb';
my $password = 'WaAoqzxe7h6yyHz';
my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 1, AutoCommit => 0});

	# yahoo! Q&A
	&_yahoo_qand_a($row[0],$row[1]);

$dbh->disconnect;

exit;

sub _yahoo_qand_a(){
	my $keyword = shift;
	my $keywordid = shift;
	my $keyword_sjis = $keyword;
	Encode::from_to($keyword,'cp932','utf8');
	$keyword = escape ( $keyword );
	
	my $url = qq{http://chiebukuro.yahooapis.jp/Chiebukuro/V1/questionSearch?appid=goooooto&query=$keyword};

	my $ua = LWP::UserAgent->new;
	$ua->timeout(3);
	my $request = HTTP::Request->new(GET =>"$url");
	my $res = $ua->request($request);
	my $ykey;
	unless ($res->is_success) {
		return;
	}else{
		$ykey = $res->content;
	}
	my @lines = split(/\n/,$ykey);
	my $qandadata;
	foreach my $line (@lines){
		if( $line=~/(.*)<Id>(.*)<\/Id>(.*)/){
			my $target = $2;
			$qandadata->{id} = Jcode->new($target, 'utf8')->sjis;
		}
		if( $line=~/(.*)<Condition>solved<\/Condition>(.*)/){
			$qandadata->{condition} = 1;
			&_ind_data($keyword_sjis,$keywordid,$qandadata);
		}
		if( $line=~/(.*)<Url>(.*)<\/Url>(.*)/){
			$qandadata->{url} = $2;
		}
		if( $line=~/(.*)<Content><\!\[CDATA\[(.*)\]\]><\/Content>(.*)/){
			my $target = $2;
			$qandadata->{question} = Jcode->new($target, 'utf8')->sjis;
		}
		if( $line=~/(.*)<BestAnswer><\!\[CDATA\[(.*)\]\]><\/BestAnswer>(.*)/){
			my $target = $2;
			$qandadata->{bestanswer} = Jcode->new($target, 'utf8')->sjis;
		}
	}

	return $qandadata;
}

sub _ind_data(){
	my $keyword  = shift;
	my $keywordid  = shift;
	my $qandadata = shift;
eval{
	my $sth2 = $dbh->prepare( qq{ select id from qanda where question_id = ? limit 1} );
	$sth2->execute($qandadata->{id});
	
	my $qandaid;
	while(my @row2 = $sth2->fetchrow_array) {
		$qandaid = $row2[0];
	}
	if($qandaid){
#		my $sth3 = $dbh->prepare( qq{update qanda set bestanswer=?, condition=? where id = ? limit 1} );
#		$sth3->execute($qandadata->{bestanswer}, $qandadata->{condition}, $qandaid);
	}else{
		my $sth3 = $dbh->prepare( qq{ insert into qanda (`keywordid`,`question`,`bestanswer`,`condition`,`url`,`question_id`,`keyword`) values(?,?,?,?,?,?,?)} );
		$sth3->execute($keywordid,$qandadata->{question},$qandadata->{bestanswer}, $qandadata->{condition}, $qandadata->{url}, $qandadata->{id}, $keyword);
	}
};

	return;
}
# サンプル　沖縄
# http://www.google.co.jp/complete/search?output=toolbar&q=%e6%b2%96%e7%b8%84
# http://search.yahooapis.jp/AssistSearchService/V1/webunitSearch?appid=goooooto&query=%e6%b2%96%e7%b8%84

