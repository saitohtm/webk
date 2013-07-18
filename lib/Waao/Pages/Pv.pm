package Waao::Pages::Pv;
use strict;
use base qw(Waao::Pages::Base);
use Waao::Data;
use Waao::Html;
use Waao::Utility;

sub dispatch(){
	my $self = shift;
	
	$self->{html_title} = qq{みんなのモバイル　公開ページビュー};
	$self->{html_keywords} = qq{みんなのモバイル,ページビュー};

	my $hr = &html_hr($self,1);	
	&html_header($self);

	my $ad = &html_google_ad($self);

	&html_table($self, qq{みんなのモバイル　公開ページビュー}, 0, 0);

my $daystr;
my $weekly_pv;
my $weekly_pv_i;
my $weekly_pv_ez;
my $weekly_pv_sb;
my $weekly_pv_robot;
my $weekly_pv_pc;

	my 	$sth = $self->{dbi}->prepare(qq{ select id, pv, pv_i, pv_ez, pv_sb, pv_robot, pv_pc, pv from pv where id >= ADDDATE(CURRENT_DATE,INTERVAL -30 DAY)} );
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$daystr .= substr($row[0],8).",";
		$weekly_pv .= $row[1].",";
		$weekly_pv_i .= $row[2].",";
		$weekly_pv_ez .= $row[3].",";
		$weekly_pv_sb .= $row[4].",";
		$weekly_pv_robot .= $row[5].",";
		$weekly_pv_pc .= $row[6].",";
	}
	chop $daystr;
	chop $weekly_pv;
	chop $weekly_pv_i;
	chop $weekly_pv_ez;
	chop $weekly_pv_sb;
	chop $weekly_pv_robot;
	chop $weekly_pv_pc;

print << "END_OF_HTML";
■デェイリーページビュー<br>
<script type="text/javascript" charset="utf-8" src="http://www.jschart.jp/t/?gt=2&amp;gd[dayly pv]=$weekly_pv&amp;w=400&amp;h=350&amp;xl=$daystr"></script>
<a href="http://www.jschart.jp/" title="Powered by JSChart">Powered by JSChart</a>
<br>

■デェイリーページビュー（i-mode）<br>
<script type="text/javascript" charset="utf-8" src="http://www.jschart.jp/t/?gt=2&amp;gd[dayly pv]=$weekly_pv_i&amp;w=400&amp;h=350&amp;xl=$daystr"></script>
<a href="http://www.jschart.jp/" title="Powered by JSChart">Powered by JSChart</a>
<br>

■デェイリーページビュー（ezweb）<br>
<script type="text/javascript" charset="utf-8" src="http://www.jschart.jp/t/?gt=2&amp;gd[dayly pv]=$weekly_pv_ez&amp;w=400&amp;h=350&amp;xl=$daystr"></script>
<a href="http://www.jschart.jp/" title="Powered by JSChart">Powered by JSChart</a>
<br>

■デェイリーページビュー（softbank）<br>
<script type="text/javascript" charset="utf-8" src="http://www.jschart.jp/t/?gt=2&amp;gd[dayly pv]=$weekly_pv_sb&amp;w=400&amp;h=350&amp;xl=$daystr"></script>
<a href="http://www.jschart.jp/" title="Powered by JSChart">Powered by JSChart</a>
<br>

■デェイリーページビュー（ロボット）<br>
<script type="text/javascript" charset="utf-8" src="http://www.jschart.jp/t/?gt=2&amp;gd[dayly pv]=$weekly_pv_robot&amp;w=400&amp;h=350&amp;xl=$daystr"></script>
<a href="http://www.jschart.jp/" title="Powered by JSChart">Powered by JSChart</a>
<br>

■デェイリーページビュー（PC）<br>
<script type="text/javascript" charset="utf-8" src="http://www.jschart.jp/t/?gt=2&amp;gd[dayly pv]=$weekly_pv_pc&amp;w=400&amp;h=350&amp;xl=$daystr"></script>
<a href="http://www.jschart.jp/" title="Powered by JSChart">Powered by JSChart</a>
<br>

END_OF_HTML
	
	
#サイト別	
	my $cntstr;
	my $sitestr;
	my $sitelist;
	my $sitelist2;
	my $sitename;
	my $sth = $self->{dbi}->prepare( qq{select sum(cnt) as tcnt, site from pv_site where date >= ADDDATE(CURRENT_DATE,INTERVAL -14 DAY) group by site order by tcnt desc} );
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$sitelist2 .= qq{$row[1]}."::".$row[0]."<br>";
		next if($row[0] <= 1000);
		$cntstr .= $row[0].",";
		$sitestr .= $row[1].",";
		$sitename = $row[1];
		$sitelist .= qq{$row[1]}."::".$row[0]."<br>";

	my $cntstr2;
	my $sitestr2;
	my $sth = $self->{dbi}->prepare( qq{select cnt, DAYOFMONTH(date) from pv_site where site = ? and date >= ADDDATE(CURRENT_DATE,INTERVAL -14 DAY)  } );
	$sth->execute($sitename);
	while(my @row = $sth->fetchrow_array) {
		$cntstr2 .= $row[0].",";
		$sitestr2 .= $row[1].",";
	}
	chop $cntstr2;
	chop $sitestr2;
print << "END_OF_HTML";
■サイト別<br>
<script type="text/javascript" charset="utf-8" src="http://www.jschart.jp/t/?gt=2&amp;gd[ $sitename ]=$cntstr2&amp;w=400&amp;h=350&amp;xl=$sitestr2"></script>
<a href="http://www.jschart.jp/" title="Powered by JSChart">Powered by JSChart</a>
<br>
END_OF_HTML


	}
	chop $cntstr;
	chop $sitestr;


print << "END_OF_HTML";
<img src="/img/i/F9A0.gif">検索<br>
<script type="text/javascript" charset="utf-8" src="http://www.jschart.jp/t/?gt=2&amp;gd[google bot]=$cntstr&amp;w=400&amp;h=350&amp;xl=$sitestr"></script>
<a href="http://www.jschart.jp/" title="Powered by JSChart">Powered by JSChart</a>
<br>
$sitelist
<br>
<br>
$sitelist2
END_OF_HTML


	
	&html_footer($self);
	
	return;
}
	
1;