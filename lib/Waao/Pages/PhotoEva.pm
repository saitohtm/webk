package Waao::Pages::PhotoEva;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Data;
use Waao::Html;
use Waao::Utility;

sub dispatch(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('q');
	my $keyword_encode = &str_encode($keyword);

	my $photoid = $self->{cgi}->param('photoid');
	my $good = $self->{cgi}->param('good');
	my $bad = $self->{cgi}->param('bad');

	unless($photoid){
		$self->{no_keyword} = 1;
		return;
	}
	my ($datacnt, $keyworddata) = &get_keyword($self, $keyword);
	# データが検索できない場合
	unless($datacnt){
		$self->{no_keyword} = 1;
		return;
	}

	$self->{html_title} = qq{$keyword:$keywordのくちこみっ評価 -みんなの口コミ評価プラス- };
	$self->{html_keywords} = qq{$keyword,評価,くちこみっ,口コミ};
	$self->{html_description} = qq{$keywordのくちこみっ…$keywordの口コミ評価情報。誰でも$keywordの評価できるヨ};
	my $hr = &html_hr($self,1);	

	my $ad = &html_google_ad($self);

	&html_header($self);

#	my ($photodatacnt, $photodata) = &get_photo($self, $keyworddata->{id}, $photoid);


if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML
	
}else{# xhmlt chtml

&html_table($self, qq{<h2><font size=1 color="#00968c">$keywordのくちこみっ評価</font></h2>}, 1, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
<br>
<img src="http://img.waao.jp/gr_domo.gif" width=26 height=47 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left">
<font size=1>$keywordの評価にご協力いただき、ありがとうございました。</font><br>
<br clear="all" />
<br>
$hr
END_OF_HTML

&html_shopping_plus($self);
&html_keyword_info($self,$keyworddata);

print << "END_OF_HTML";
$hr
<a href="/" access_key=0>トップ</a>&gt;<a href="/$keyword_encode/search/">$keyword検索</a>&gt;<a href="/$keyword_encode/photolist/0-1/">$keyword画像一覧</a>&gt;<strong>$keyword</strong>画像の評価<br>
<font size=1 color="#E9E9E9">$keywordの画像<br>
$keywordの画像情報の収集にご協力をお願いします。<br>
</font>
END_OF_HTML

}
	
	&html_footer($self);
	
	&eva_photo($self,$photoid,$good,$bad);

	return;
}

1;