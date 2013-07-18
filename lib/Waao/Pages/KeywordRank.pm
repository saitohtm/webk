package Waao::Pages::KeywordRank;
use strict;
use base qw(Waao::Pages::Base);
use Waao::Html;
use Waao::Data;
use Waao::Utility;

# /keywordranking/
# /list-date/keywordranking/
# /q/keywordranking/

sub dispatch(){
	my $self = shift;

	#ドメイン設定
	if($self->{cgi}->param('q') =~/list-/){
		&_page($self);
	}elsif($self->{cgi}->param('q')){
		# 詳細ページ
		&_person($self);
	}else{
		&_top($self);
	}
	
	return;
}

sub _top(){
	my $self = shift;

	$self->{html_title} = qq{検索キーワードランキング};
	$self->{html_keywords} = qq{検索,キーワード,情報};
	$self->{html_description} = qq{毎日更新検索キーワードランキング};
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time - 86400);
$year = $year + 1900;
$mon = $mon + 1;
my $yyyymmdd = sprintf("%d-%02d-%02d",$year,$mon,$mday);

	my $hr = &html_hr($self,1);	
	&html_header($self);

	my $ad = &html_google_ad($self);

if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML
	
}else{
# xhmlt chtml

print << "END_OF_HTML";
<center>
<h1><img src="http://img.waao.jp/keywordranking.gif" width=120 height=28 alt="検索キーワード"></h1>
<h2><font size=1 color="#FF0000">検索キーワードランキング</font></h2>
</center>
$hr
<center>
$ad
</center>
$hr
偂$yyyymmddの検索キーワードランキング<br>

END_OF_HTML

my $sth = $self->{dbi}->prepare(qq{ select id, keyword,rank from keyword_rank where date = ? order by rank limit 20} );
$sth->execute($yyyymmdd);
while(my @row = $sth->fetchrow_array) {
	my $str_encode = &str_encode($row[1]);
print << "END_OF_HTML";
<font color="#009525">$row[2]位》</font><a href="/$str_encode/keywordranking/$row[0]/" title="$row[1]">$row[1]</a><br>
END_OF_HTML
}

print << "END_OF_HTML";
<img src="http://img.waao.jp/m2028.gif" width=48 height=9><a href="http://waao.jp/list-page/keywordranking/0/$yyyymmdd/">次へ</a><br>
$hr
偂<a href="http://waao.jp/list-in/ranking/14/">みんなのランキング</a><br>
<a href="/" accesskey=0 title="みんなのモバイル">トップ</a>&gt;<strong>検索キーワードランキング</strong><br>
検索キーワードランキングは、日々更新される検索ワードをランキングした検索キーワードランキングサイトです。<font color="#FF0000">リンクフリー</font>です。<br>
<textarea>
http://waao.jp/keywordranking/
</textarea>
<br>$yyyymmdd更新<br>
END_OF_HTML

}
	
	&html_footer($self);

	return;
}

sub _page(){
	my $self = shift;
	my $pageno = $self->{cgi}->param('p1');
	my $yyyymmdd = $self->{cgi}->param('p2');
	my $pagestr = $pageno + 1;
	unless($yyyymmdd){
		my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time - 86400);
		$year = $year + 1900;
		$mon = $mon + 1;
		$yyyymmdd = sprintf("%d-%02d-%02d",$year,$mon,$mday);
	}
	
	$self->{html_title} = qq{検索キーワードランキング$pagestrページ -$yyyymmdd更新-};
	$self->{html_keywords} = qq{検索キーワード,ランキング,話題,検索};
	$self->{html_description} = qq{検索キーワードランキングで分かる$yyyymmddの人気検索ワード};

	my $hr = &html_hr($self,1);	
	&html_header($self);

	my $ad = &html_google_ad($self);

if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML
	
}else{
# xhmlt chtml

print << "END_OF_HTML";
<center>
<h2><font size=1 color="#FF0000">検索キーワードランキング$pagestr㌻</font></h2>
</center>
$hr
<center>
$ad
</center>
$hr
偂$yyyymmddの検索キーワードランキング<br>
END_OF_HTML

my $listcnt;
my $start = $pageno * 100;
my $sth = $self->{dbi}->prepare(qq{ select id, keyword, rank, cnt from keyword_rank where date = ? order by rank limit $start,100} );
$sth->execute($yyyymmdd);
while(my @row = $sth->fetchrow_array) {
	$listcnt++;
	my $str_encode = &str_encode($row[1]);
print << "END_OF_HTML";
<font color="#009525">$row[2]》</font><a href="/$str_encode/keywordranking/$row[0]/" title="$row[1]">$row[1]</a>($row[3])<br>
END_OF_HTML
}

unless($listcnt){
	for(my $i=2;$i<=10;$i++){
		my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time - (86400 * $i));
		$year = $year + 1900;
		$mon = $mon + 1;
		my $ymd = sprintf("%d-%02d-%02d",$year,$mon,$mday);
print << "END_OF_HTML";
<a href="http://waao.jp/list-page/keywordranking/0/$ymd/">$ymd</a><br>
END_OF_HTML
	}
}

$pageno++;
print << "END_OF_HTML";
<img src="http://img.waao.jp/m2028.gif" width=48 height=9><a href="http://waao.jp/list-page/keywordranking/$pageno/$yyyymmdd/">次へ</a><br>
$hr
偂<a href="http://waao.jp/list-in/ranking/14/">みんなのランキング</a><br>
<a href="/" accesskey=0 title="みんなのモバイル">トップ</a>&gt;<a href="/keywordranking/">検索キーワードランキング</a>&gt;<strong>検索キーワードランキング</strong><br>
検索キーワードランキングは、<font color="#FF0000">リンクフリー</font>です。<br>
<textarea>
http://waao.jp/keywordranking/
</textarea>
<br>
END_OF_HTML

}
	
	&html_footer($self);

	return;
}
sub _person(){
	my $self = shift;

	my $keyword = $self->{cgi}->param('q');
	my $rankid = $self->{cgi}->param('p1');
	my $keyword_encode = &str_encode($keyword);
	
	my ($keywordid, $rank,$date,$cnt,$info);
my $sth = $self->{dbi}->prepare(qq{ select keyword,keyword_id,rank,date,cnt,info from keyword_rank where id = ? limit 1} );
$sth->execute($rankid);
while(my @row = $sth->fetchrow_array) {
	($keyword,$keywordid,$rank,$date,$cnt,$info) = @row;
}

	my ($datacnt, $keyworddata) = &get_keyword($self, $keyword, $keywordid);
	# データが検索できない場合
	unless($datacnt){
		$self->{no_keyword} = 1;
		return;
	}
	# photo データ
	my ($datacnt, $photodata) = &get_photo($self, $keyworddata->{id});

	$self->{html_title} = qq{$keyword -$dateの検索キーワード$rank位-};
	$self->{html_keywords} = qq{$keyword,検索,データ,情報,wikipedia,wiki,うわさ,掲示板,プロフィール};
	$self->{html_description} = qq{$keyword $keywordは、$dateの検索キーワードランキング$rank位};

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);

	&html_header($self);
	
	my $simplewiki = $keyworddata->{simplewiki};
	$simplewiki = &simple_wiki_upd($simplewiki, 128) if($simplewiki);
# 画像はリアルモバイルのみ
#$photodata->{url} = qq{http://waao.jp/puri.gif} unless( $self->{real_mobile} );

	my $prof_str;
	if($keyworddata->{person}){
		$prof_str = qq{プロフィール};
	}else{
		$prof_str = qq{データベース};
	}

if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
$hr
<a href="/"></a>&gt;<strong>$keyword</strong>
$hr

END_OF_HTML
	
}else{# xhmlt chtml

print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FF9900">$keywordは、$dateの検索キーワードランキング$rank位です。参照回数$cnt </font></marquee>
END_OF_HTML

&html_table($self, qq{<h1>$keyword</h1><h2><font size=1>$keyword</font><font size=1 color="#FF0000">$prof_str</font></h2>}, 1, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

&html_keyword_info($self, $keyworddata, $photodata);

print << "END_OF_HTML";
$hr
END_OF_HTML


&html_keyword_plus($self, $keyworddata);


&html_search_plus($self, $keyword);

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/keywordranking/">話題のキーワード</a>&gt;<strong>$keyword</strong><br>
<font size=1 color="#AAAAAA">$keywordプラスの㌻は、$keywordについてのwikipedia情報と独自で集めた口コミ情報をミックスすることによる$keyword情報検索㌻です。<br>
$keywordのクチコミ情報の収集にご協力をお願いします。<br>
$keywordは、$dateの検索キーワードランキング$rank位です。参照回数$cnt<br>
</font>
END_OF_HTML

} # xhtml

	
	&html_footer($self);
	

	return;
}


1;