package Waao::Pages::Photo;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Data;
use Waao::Html;
use Waao::Utility;

# /keyword/photo/
# /keyword/photo/photoid/
# /keyword/photo/photoid/keywordid/
sub dispatch(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('q');
	my $keyword_encode = &str_encode($keyword);
	my $photoid = $self->{cgi}->param('p1'); 
	my $keywordid = $self->{cgi}->param('p2');

	my ($datacnt, $keyworddata) = &get_keyword($self, $keyword, $keywordid);
	# データが検索できない場合
	unless($datacnt){
		$self->{no_keyword} = 1;
		return;
	}

	my ($photodatacnt, $photodata) = &get_photo($self, $keyworddata->{id}, $photoid);

	$self->{html_title} = qq{$keywordの画像 -みんなの画像検索プラス-};
	$self->{html_keywords} = qq{$keyword,検索,画像,フォト,壁紙,cm,プロフィール};
	$self->{html_description} = qq{$keywordの画像を楽〜に検索。ここにしかない$keyword画像もプラス！};

	my $hr = &html_hr($self,1);	
	&html_header($self);

	my $ad = &html_google_ad($self);

	my $simplewiki = &simple_wiki_upd($keyworddata->{simplewiki}, 128) if($keyworddata->{simplewiki});


# 画像はリアルモバイルのみ
$photodata->{url} = qq{http://img.waao.jp/noimage95.gif} unless( $self->{real_mobile} );


if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML
	
}else{# xhmlt chtml

if($simplewiki){

print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FF9900">$simplewiki </font></marquee>
END_OF_HTML

}

&html_table($self, qq{<h1>$keyword</h1><h2><font size=1>$keyword</font><font size=1 color="#FF0000">画像</font></h2>}, 1, 0);

print << "END_OF_HTML";
$hr
<center>$ad</center>
$hr
END_OF_HTML

print << "END_OF_HTML";
<table border=0 bgcolor="#000000" width="100%">
<tr><td>
<center>
<img src="$photodata->{url}" alt="$keywordの画像">
</center>
</td></tr>
</table>
<font size=1><strong>$keyword</strong>の評価：<font color="blue">$photodata->{good}</font><font color="red">Good！</font></font><br>
<center><form action="/photoeva.html" method="POST">
<input type="hidden" name="photoid" value="$photodata->{id}">
<input type="hidden" name="good" value="1">
<input type="hidden" name="guid" value="on">
<input type="hidden" name="q" value="$keyword">
<input type="submit" value="Good!">
</form>
<form action="/photoeva.html" method="POST">
<input type="hidden" name="photoid" value="$photodata->{id}">
<input type="hidden" name="bad" value="1">
<input type="hidden" name="guid" value="on">
<input type="hidden" name="q" value="$keyword">
<input type="submit" value="Bad!"><br>
</form>
</center>
$hr
END_OF_HTML

&html_keyword_info($self,$keyworddata);
&html_shopping_plus($self);
print << "END_OF_HTML";
$hr
<a href="/" access_key=0>トップ</a>&gt;<a href="/$keyword_encode/search/">$keyword検索</a>&gt;<a href="/$keyword_encode/photolist/0-1/">$keyword画像一覧</a>&gt;<strong>$keyword</strong>画像<br>
<font size=1 color="#E9E9E9">$keywordの画像検索プラスの㌻は、$keywordの画像情報を口コミによって集めた$keywordの画像検索㌻です。<br>
$keywordの画像情報の収集にご協力をお願いします。<br>
画像検索プラスは、yahoo!画像検索APIの情報を利用しています。<br>
</font>
$hr
<font size=1 color="#E9E9E9">
元画像情報<br>
$photodata->{url}
$photodata->{backurl}
<br>
使用している画像は、皆様からのクチコミで投稿された画像です。<br>
不適切な内容の画像を発見された場合は、ご連絡ください。<br>
</font>
END_OF_HTML

} # xhtml


	
	&html_footer($self);
	
	return;
}

1;