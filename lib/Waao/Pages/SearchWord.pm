package Waao::Pages::SearchWord;
use strict;
use base qw(Waao::Pages::Base);
use Waao::Data;
use Waao::Html;
use Waao::Utility;

sub dispatch(){
	my $self = shift;
	
	$self->{html_title} = qq{検索キーワードランキング};
	$self->{html_keywords} = qq{検索ワード,キーワード,検索};

	my $hr = &html_hr($self,1);	
	&html_header($self);

	my $ad = &html_google_ad($self);

	&html_table($self, qq{偂検索キーワードランキング}, 0, 0);
print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

	my $page = $self->{cgi}->param('p1');
	my $start = 0;
	if($page){
		$start = 50 * $page;
	}
	my $sth = $self->{dbi}->prepare( qq{select keyword,startindex,adpage,mode,updated,yahoo,url from robot_search where keyword is not null order by updated desc limit $start, 100} );
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
	my @wordstr = split(/&/, $row[0]);	
	my $yahoo;
	$yahoo = q{<font color="red">Y!</font>} if($row[5]);
print << "END_OF_HTML";
$yahoo<a href="$row[6]"><font color="blue">$wordstr[0]</font></a><br><font size=1>$row[6]</font><br>
END_OF_HTML

	}

$page++;
print << "END_OF_HTML";
<div align=right><img src="http://img.waao.jp/m2028.gif" width=48 height=9><a href="/list-rank/searchword/$page/">次の㌻</a></div>
</font>
END_OF_HTML




print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<strong>検索キーワードランキング</strong><br>
END_OF_HTML
	
	&html_footer($self);
	
	return;
}
	
1;