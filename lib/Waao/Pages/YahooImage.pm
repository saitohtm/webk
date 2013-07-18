package Waao::Pages::YahooImage;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Data;
use Waao::Html;
use Waao::Utility;
use Waao::Api;
use XML::Simple;
use LWP::Simple;
use Jcode;
use CGI qw( escape );


# /yahooimage/		topページ
# /keyword/yahooimage/	キーワード検索
sub dispatch(){
	my $self = shift;
	
	if($self->{cgi}->param('url')){
		&_fit_image($self);
	}elsif($self->{cgi}->param('q')){
		&_search($self);
	}else{
		&_top($self);
	}

	return;
}

sub _top(){
	my $self = shift;

	$self->{html_title} = qq{無料画像検索 -みんなの画像検索プラス-};
	$self->{html_keywords} = qq{無料画像,画像,画像検索,待ち受け,壁紙,yahoo,ヤフー};
	$self->{html_description} = qq{無料画像検索 ：無料で待ち受けや壁紙画像検索！};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	
if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML
	
}else{# xhmlt chtml

print << "END_OF_HTML";
<center>
<img src="http://img.waao.jp/imglogo.gif" width=120 height=28 alt="無料画像検索"><font size=1 color="#FF0000">プラス</font>
</center>
<center>
<form action="/yahooimage.html" method="POST" ><input type="text" name="q" value="" size="20"><input type="hidden" name="guid" value="ON">
<br />
<input type="submit" value="画像検索プラス"><br />
</form>
</center>
<center>
<font size=1>ヤフー<font color="#FF0000">マルチ画像検索</font></font>
</center>
$hr
<a href="/flickr/" accesskey=1>Flickrで検索</a><br>
<a href="/imagesearch/" accesskey=2>総合無料画像検索</a><br>
<a href="/list-rank/popword/1/" accesskey=3>検索ランキング</a><br>
<!--
<a href="" accesskey=4></a><br>
<a href="" accesskey=5></a><br>
<a href="" accesskey=6></a><br>
<a href="" accesskey=7></a><br>
<a href="" accesskey=8></a><br>
<a href="" accesskey=9></a><br>
-->
$hr
偂<a href="http://waao.jp/list-in/ranking/3/">みんなのランキング</a><br>
<a href="/" accesskey=0>トップ</a>&gt;<strong>みんなの無料画像検索プラス</strong><br>
<font size=1 color="#AAAAAA">みんなの無料画像検索プラスは,ヤフー画像検索の全ての情報から無料で待ち受けや壁紙になる画像をマルチに検索できる無料画像検索検索サイトです。<br>
<a href="http://developer.yahoo.co.jp/about">Webサービス by Yahoo! JAPAN</a><br>
</font>
END_OF_HTML

}

	&html_footer($self);

	return;
}

sub _search(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('q');

	$self->{html_title} = qq{$keyword 無料画像検索情報};
	$self->{html_keywords} = qq{$keyword,無料画像,画像,画像検索};
	$self->{html_description} = qq{$keywordの無料画像。};
	
	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);

	&html_header($self);

	&html_table($self, qq{<h1>$keyword</h1><h2><font size=1 color="#FF0000">無料画像検索</font></h2>}, 1, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

	# Yahoo!
	&_search_yahoo($self);

	# Yahoo!

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/yahooimage/">無料画像検索プラス</a>&gt;<strong>$keywordの無料画像</strong><br>
<font size=1 color="#E9E9E9">みんなの無料画像検索プラスは,ヤフー画像検索の全ての情報から無料で待ち受けや壁紙になる画像をマルチに検索できる無料画像検索検索サイトです。<br>
<a href="http://developer.yahoo.co.jp/about">Webサービス by Yahoo! JAPAN</a><br>
</font>
END_OF_HTML

	&html_footer($self);

	return;
}

sub _search_yahoo(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('q');
	my $keyword_encode = &str_encode($keyword);
	my $keyword_utf8 = $keyword;
	Encode::from_to($keyword_utf8,'cp932','utf8');
	$keyword_utf8 = escape ( $keyword_utf8 );
	my $page = 1;
	$page = $self->{cgi}->param('p1') if($self->{cgi}->param('p1'));
	my $next_page = $page + 1;
	my $resultcnt = 5;
	$resultcnt = 30 if($self->{access_type} eq 4);
	my $start = 1 + $resultcnt * ($page - 1);
	my $api_url;
	$api_url = qq{http://search.yahooapis.jp/ImageSearchService/V1/imageSearch?appid=goooooto&query=$keyword_utf8&results=$resultcnt&adult_ok=1&start=$start};

    my $response = get($api_url);
	my $xml = new XML::Simple;
	my $yahoo_xml = $xml->XMLin($response);

	my $hr = &html_hr($self,1);	
	&html_table($self, qq{寀<font color="#BF0030">毀ー画像検索</font>}, 0, 0);

	foreach my $result (@{$yahoo_xml->{Result}}) {

		my ($url,$width,$height,$urlm,$altname,$altname_encode);
eval{
		$url = $result->{Thumbnail}->{Url};
		$width = $result->{Thumbnail}->{Width};
		$height = $result->{Thumbnail}->{Height};
		$urlm = $result->{Url};
		$altname = Jcode->new($result->{Title}, 'utf8')->sjis;
		$altname_encode = &str_encode($altname);
};
if($self->{access_type} eq 4){
print << "END_OF_HTML";
<center>
<a href="/yahooimage.html?guid=ON&url=$urlm&q=$altname_encode"><img src="$urlm" width=300 alt="$altname"><br><font size=1>[拡大]</font></a>
</center>
END_OF_HTML
}else{
print << "END_OF_HTML";
<center>
<a href="/yahooimage.html?guid=ON&url=$urlm&q=$altname_encode"><img src="$url" width=$width height=$height alt="$altname"><br><font size=1>[拡大]</font></a>
</center>
END_OF_HTML
}
	}
print << "END_OF_HTML";
<div align=right><img src="http://img.waao.jp/m2028.gif" width=48 height=9><a href="/$keyword_encode/yahooimage/$next_page/">次の㌻</a></div>
END_OF_HTML

	return;
}

sub _fit_image(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('q');
	my $keyword_encode = &str_encode($keyword);
	my $url = $self->{cgi}->param('url');

	$self->{html_title} = qq{$keyword 無料画像検索情報};
	$self->{html_keywords} = qq{$keyword,無料画像,画像,画像検索};
	$self->{html_description} = qq{$keywordの無料画像。};
	
	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);

	&html_header($self);

	&html_table($self, qq{<h1>$keyword</h1><h2><font size=1 color="#FF0000">無料画像検索</font></h2>}, 1, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
<center>
<img src="$url" alt="$keyword">
</center>
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/yahooimage/">無料画像検索プラス</a>&gt;<a href="/$keyword_encode/yahooimage/">$keywordの画像一覧</a>&gt;<strong>$keywordの無料画像</strong><br>
<font size=1 color="#E9E9E9">みんなの無料画像検索プラスは,ヤフー画像検索の全ての情報から無料で待ち受けや壁紙になる画像をマルチに検索できる無料画像検索検索サイトです。<br>
<a href="http://developer.yahoo.co.jp/about">Webサービス by Yahoo! JAPAN</a><br>
</font>
END_OF_HTML

	&html_footer($self);

	return;
}
1;