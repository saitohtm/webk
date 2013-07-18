package Waao::Pages::Real;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Data;
use Waao::Html;
use Waao::Utility;

# /keyword/search/
# /keyword/search/keywordid/
# /keyword/search/keywordid/type-cnt/
sub dispatch(){
	my $self = shift;

	if($self->{cgi}->param('q')){
		&_person($self);
	}else{
		&_top($self);
	}
	return;
}

sub _top(){
	my $self = shift;

	$self->{html_title} = qq{みんなの人物名鑑プラス};
	$self->{html_keywords} = qq{名鑑,検索,人物検索};
	$self->{html_description} = qq{最強の人物検索「みんなの人物名鑑プラス」さまざまなジャンルの人物名鑑がシリーズ化};

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
<h2>先読み検索<font size=1 color="#FF0000">プラス</font></h2>
<h2><font size=1>みんなの<font color="#FF0000">人物名鑑</font>プラス</font></h2>
</center>
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

my $memkey = "trendperson";
my $today_trend;
$today_trend = $self->{mem}->get( $memkey );

if($today_trend){
	my $cnt = 0;
	foreach my $keyword (@{$today_trend->{rank}}){
		$cnt++;
		my $str_encode = &str_encode($keyword);
print << "END_OF_HTML";
寀<a href="/$str_encode/real/">$keyword</a><br>
END_OF_HTML
	}
}


print << "END_OF_HTML";
$hr
偂<a href="http://waao.jp/list-in/ranking/14/">みんなのランキング</a><br>
<a href="/" accesskey=0 title="みんなのモバイル">トップ</a>&gt;<strong>先読み検索</strong><br>
先読み検索プラスは、<font color="#FF0000">リンクフリー</font>です。<br>
<textarea>
http://waao.jp/real/
</textarea>
<br>
<font size=1 color="#AAAAAA">ジャンル別人物名鑑シリーズ。人物のプロフィールや画像が検索できます</fonnt>
END_OF_HTML

}
	
	&html_footer($self);

	return;
}


sub _person(){
	my $self = shift;

	my $keyword = $self->{cgi}->param('q');
	my $keywordid = $self->{cgi}->param('p1');
	my $keyword_encode = &str_encode($keyword);
	my $wordinfo = $self->{cgi}->param('p2'); 
	my ($type, $cnt) = split(/-/,$wordinfo);
	
	my ($datacnt, $keyworddata) = &get_keyword($self, $keyword, $keywordid);
	my $word;
	if($type eq 1){
		$word = &_get_word($keyworddata->{yahookeyword},$cnt);
	}elsif($type eq 2){
		$word = &_get_word($keyworddata->{googlekeyword},$cnt);
	}
	# データが検索できない場合
	unless($datacnt){
		$self->{no_keyword} = 1;
		return;
	}
	# photo データ
	my ($datacnt, $photodata) = &get_photo($self, $keyworddata->{id});

	$self->{html_title} = qq{$keywordとは -みんなの検索プラス-};
	$self->{html_keywords} = qq{$keyword,検索,データ,情報,wikipedia,wiki,うわさ,掲示板,プロフィール};
	$self->{html_description} = qq{$keyword最強データベースだから、楽〜に$keyword情報が探せます！};

	# 複数ワード対応
	if($self->{cgi}->param('p1') eq 'words'){
		$self->{html_title} = qq{$keywordの$word -$keyword先読み検索-};
		$self->{html_keywords} = qq{$keyword,$word,検索,データ,情報,wikipedia,wiki,うわさ,掲示板,プロフィール};
		$self->{html_description} = qq{$keywordの$word情報はココをクリック};
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
	if($word){
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
if($word){
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


&html_keyword_plus2($self, $keyworddata);

$keywordid = $keyworddata->{id};
&html_search_plus($self, $keyword);

print << "END_OF_HTML";
$hr
<a href="http://real.waao.jp/$keywordid/" title="$keyword">$keyword焚祝澎爪版</a><br>

<a href="/" accesskey=0>トップ</a>&gt;<a href="/popword/">話題のキーワード</a>&gt;<strong>$keyword</strong><br>
<font size=1 color="#AAAAAA">$keywordプラスの㌻は、$keywordについてのwikipedia情報と独自で集めた口コミ情報をミックスすることによる$keyword情報検索㌻です。<br>
$keywordのクチコミ情報の収集にご協力をお願いします。<br>
</font>
END_OF_HTML

} # xhtml


	
	&html_footer($self);
	
	return;
}

sub _get_word(){
	my $list = shift;
	my $cnt = shift;

	my $word;	
	my $cnt2;
	my @val = split(/\t/,$list);
	foreach my $value (@val){
		next unless($value);
		$cnt2++;
		if($cnt eq $cnt2){
			$word = $value;
			last;
		}
	}
	return $word;
}
1;