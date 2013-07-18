package Waao::Pages::Search;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Data;
use Waao::Html;
use Waao::Utility;

# /keyword/search/
# /keyword/search/keywordid/
# /keyword/search/words/word/
sub dispatch(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('q');
	my $keywordid = $self->{cgi}->param('p1');
	my $keyword_encode = &str_encode($keyword);
	my $word = $self->{cgi}->param('p2');
	
	# 複数ワード対応
	if($self->{cgi}->param('p1') eq 'words'){
		$keywordid = undef;
	}

	my ($datacnt, $keyworddata) = &get_keyword($self, $keyword, $keywordid);
	# データが検索できない場合
	unless($datacnt){
		$self->{no_keyword} = 1;
		return;
	}
	# photo データ
	my ($datacnt, $photodata) = &get_photo($self, $keyworddata->{id});

	$self->{html_title} = qq{$keyword -みんなの$keyword検索プラス-};
	$self->{html_keywords} = qq{$keyword,検索,データ,情報,wikipedia,wiki,うわさ,掲示板,プロフィール};
	$self->{html_description} = qq{$keywordについて知りたいならココしかない！};

	# 複数ワード対応
	if($self->{cgi}->param('p1') eq 'words'){
		$self->{html_title} = qq{$keyword $wordとは -みんなの$keyword$word検索プラス-};
		$self->{html_keywords} = qq{$keyword,$word,検索,データ,情報,wikipedia,wiki,うわさ,掲示板,プロフィール};
		$self->{html_description} = qq{$keyword$wordについて知りたいならココしかない！};
	}

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
	# 複数ワード対応
	if($self->{cgi}->param('p1') eq 'words'){
		$prof_str = qq{$word};
	}

if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
$hr
<a href="/"></a>&gt;<strong>$keyword</strong>
$hr

END_OF_HTML
	
}else{# xhmlt chtml

if($simplewiki){
print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FF9900">$simplewiki </font></marquee>
END_OF_HTML
}

&html_table($self, qq{<h1>$keyword</h1><h2><font size=1>$keyword</font><font size=1 color="#FF0000">$prof_str</font></h2>}, 1, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

# 複数ワード対応
if($self->{cgi}->param('p1') eq 'words'){
	my $yicha_link = &html_yicha_url($self, "$keyword $word", 'p');
print << "END_OF_HTML";
<br>
<center>
<br>
<font color="#00968c">▽▽▽▽▽</font><br>
<a href="$yicha_link">$keyword<font color="#FF0000">$word</font></a><br>
<font color="#00968c">△△△△△</font><br>
</center>
<br>
$hr
END_OF_HTML
}

&html_keyword_info($self, $keyworddata, $photodata);

print << "END_OF_HTML";
$hr
END_OF_HTML


&html_keyword_plus($self, $keyworddata);


&html_search_plus($self, $keyword);

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/popword/">話題のキーワード</a>&gt;<strong>$keyword</strong><br>
<font size=1 color="#AAAAAA">$keywordプラスの㌻は、$keywordについてのwikipedia情報と独自で集めた口コミ情報をミックスすることによる$keyword情報検索㌻です。<br>
$keywordのクチコミ情報の収集にご協力をお願いします。<br>
</font>
END_OF_HTML

} # xhtml


	
	&html_footer($self);
	
	return;
}

1;