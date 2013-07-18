package Waao::Pages::2010rank;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Data;
use Waao::Html;
use Waao::Utility;
use Jcode;
use CGI qw( escape );

# /zip/		topページ
# /zip.html?zipcode=	search
# /list-area/zip/pref-add1-add2/
# /list-detail/zip/zipid/

sub dispatch(){
	my $self = shift;
	
	if($self->{cgi}->param('q') eq 'list-rank'){
		&_list($self);
	}elsif($self->{cgi}->param('q') eq 'list-word'){
		&_detail($self);
	}else{
		&_top($self);
	}

	return;
}

sub _detail(){
	my $self = shift;

	my $keywordid = $self->{cgi}->param('p1');
	my ($datacnt, $keyworddata) = &get_keyword($self, "", $keywordid);
	my $keyword = $keyworddata->{keyword};
	# photo データ
	my ($datacnt, $photodata) = &get_photo($self, $keyworddata->{id});
	
	$self->{html_title} = qq{$keyword -2010検索ワードランキング-};
	$self->{html_keywords} = qq{$keyword,検索,データ,情報,wikipedia,wiki,うわさ,掲示板,プロフィール};
	$self->{html_description} = qq{$keywordについて知りたいならココしかない！};
	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);

	&html_header($self);
	
	my $simplewiki = $keyworddata->{simplewiki};
	$simplewiki = &simple_wiki_upd($simplewiki, 128) if($simplewiki);

if($simplewiki){
print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FF9900">$simplewiki </font></marquee>
END_OF_HTML
}
&html_table($self, qq{<h1>$keyword</h1><h2><font size=1>$keyword</font></h2>}, 1, 0);

&html_keyword_info($self, $keyworddata, $photodata);

print << "END_OF_HTML";
$hr
END_OF_HTML


&html_keyword_plus($self, $keyworddata);


&html_search_plus($self, $keyword);

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/2010rank/">2010検索ワードランキング</a>&gt;<strong>$keyword</strong><br>
<font size=1 color="#E9E9E9">$keywordは、2010年もっとも検索された人気検索キーワード100に入っています<br>
END_OF_HTML

	return;
}

sub _list(){
	my $self = shift;

	my $type = $self->{cgi}->param('p1');

	$self->{html_title} = qq{2010検索ワードランキング};
	$self->{html_keywords} = qq{検索,ランキング,流行};
	$self->{html_description} = qq{2010検索ワードランキング 2010年の流行検索ワードが分かる};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);
	
print << "END_OF_HTML";
<center>
<img src="http://img.waao.jp/2010top100.gif" width=120 height=28 alt="2010検索キーワードランキング"><font size=1 color="#FF0000">プラス</font>
</center>
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

my $sth = $self->{dbi}->prepare(qq{select keyword,keyword_id from keyword_best where type = ? and yyyy = ? });
$sth->execute($type,2010);
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<font color="#FF8000">》</font><a href="/list-word/2010rank/$row[1]/" title="$row[0]">$row[0]</a><br>
END_OF_HTML
}

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/2010rank/">2010検索ワードランキング</a>&gt;<strong>2010検索ワードランキングリスト</strong><br>
<font size=1 color="#E9E9E9">2010年もっとも検索された人気検索キーワード<br>
END_OF_HTML

	return;
}

sub _top(){
	my $self = shift;

	$self->{html_title} = qq{2010検索ワードランキング };
	$self->{html_keywords} = qq{検索,ランキング,流行};
	$self->{html_description} = qq{2010検索ワードランキング 2010年の流行検索ワードが分かる};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);

if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML
	
}else{# xhmlt chtml

print << "END_OF_HTML";
<center>
<img src="http://img.waao.jp/2010top100.gif" width=120 height=28 alt="2010検索キーワードランキング"><font size=1 color="#FF0000">プラス</font>
</center>
$hr
<center>
$ad
</center>
$hr
<font color="#009525">■</font><a href="/list-rank/2010rank/2/" title="検索ランキング">検索ランキング(PC)</a><br>
<font color="#009525">■</font><a href="/list-rank/2010rank/1/" title="検索ランキング">検索ランキング(モバイル)</a><br>
<font color="#009525">■</font><a href="/list-rank/2010rank/3/" title="検索ランキング">人名ランキング</a><br>
$hr
<a href="/" accesskey=0>トップ</a>&gt;<strong>2010検索ワードランキング</strong><br>
<font size=1 color="#E9E9E9">2010年もっとも検索された人気検索キーワード<br>
END_OF_HTML

}
	&html_footer($self);

	return;
}
1;
