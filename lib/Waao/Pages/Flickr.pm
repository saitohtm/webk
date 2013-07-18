package Waao::Pages::Flickr;
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


# /flickr/		topページ
# /keyword/flickr/	キーワード検索
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
	$self->{html_keywords} = qq{無料画像,画像,画像検索,待ち受け,壁紙};
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
<h2><img src="http://img.waao.jp/imglogo.gif" width=120 height=28 alt="無料画像検索"><font size=1 color="#FF0000">プラス</font></h2>
</center>
<center>
<form action="/flickr.html" method="POST" ><input type="text" name="q" value="" size="20"><input type="hidden" name="guid" value="ON">
<br />
<input type="submit" value="画像検索プラス"><br />
</form>
</center>
<center>
<font size=1>Flickr<font color="#FF0000">マルチ検索</font></font>
</center>
$hr

<a href="/yahooimage/" accesskey=1>Yahoo!画像検索で探す</a><br>
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
偂<a href="http://waao.jp/list-in/ranking/2/">みんなのランキング</a><br>
<a href="/" accesskey=0>トップ</a>&gt;<strong>みんなの無料画像検索プラス</strong><br>
<font size=1 color="#AAAAAA">みんなの無料画像検索プラスは,Flickrの全ての情報から無料で待ち受けや壁紙になる画像をマルチに検索できる無料画像検索検索サイトです。<br>
<a href="http://www.flickr.com/services/api/">Flickr</a>
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

	# Flicker
	&_search_flickr($self);

	# Yahoo!

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/flickr/">無料画像検索プラス</a>&gt;<strong>$keywordの無料画像</strong><br>
<font size=1 color="#E9E9E9">みんなの無料画像検索プラスは,Flickrの全ての情報から無料で待ち受けや壁紙になる画像をマルチに検索できる無料画像検索検索サイトです。<br>
<a href="http://www.flickr.com/services/api/">Flickr</a>
</font>
END_OF_HTML

	&html_footer($self);

	return;
}

sub _search_flickr(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('q');
	my $keyword_encode = &str_encode($keyword);
	my $keyword_utf8 = $keyword;
	Encode::from_to($keyword_utf8,'cp932','utf8');
	$keyword_utf8 = escape ( $keyword_utf8 );
	my $page = 1;
	$page = $self->{cgi}->param('p1') if($self->{cgi}->param('p1'));
	my $next_page = $page+ 1;
	my $api_url;
	$api_url = qq{http://www.flickr.com/services/rest/?method=flickr.photos.search&format=rest&api_key=fe5c28cda2b5d06c5de2041577f4e49a&per_page=5&license=1,2,3,4,5,6&extras=owner_name&text=$keyword_utf8&page=$page};

    my $response = get($api_url);
	my $xml = new XML::Simple;
	my $flickr_xml = $xml->XMLin($response);

	my $hr = &html_hr($self,1);	
	&html_table($self, qq{寀<font color="#BF0030">Flickr画像検索</font>}, 0, 0);

	foreach my $id (keys %{$flickr_xml->{photos}->{photo}}) {
		my $url = &_flickr_img_url($id, $flickr_xml->{photos}->{photo}->{$id}, "s");
		my $urlm = &_flickr_img_url($id, $flickr_xml->{photos}->{photo}->{$id}, "m");
		$urlm = &str_encode($urlm);
		my $altname = Jcode->new($flickr_xml->{photos}->{photo}->{$id}->{title}, 'utf8')->sjis;
		my $altname_encode = &str_encode($altname);

print << "END_OF_HTML";
<center>
<a href="/flickr.html?guid=ON&url=$urlm&q=$altname_encode"><img src="$url->{photo}" width=75 height=75 alt="$altname"><br><font size=1>[拡大]</font></a>
</center>
END_OF_HTML
	}
print << "END_OF_HTML";
<div align=right><img src="http://img.waao.jp/m2028.gif" width=48 height=9><a href="/$keyword_encode/flickr/$next_page/">次の㌻</a></div>
END_OF_HTML

	return;
}
sub _flickr_img_url(){
	my $id = shift;
	my $val = shift;
	my $size = shift;

	my $farm_id = $val->{"farm"};
	my $server_id = $val->{"server"};
	my $secret = $val->{"secret"};
	my $user_id = $val->{"owner"};
	
	my $url;
	$url->{photo} = qq{http://farm}.$farm_id.qq{.static.flickr.com/}.$server_id.qq{/}.$id.qq{_}.$secret.qq{_}.$size.qq{.jpg};
##	$url->{link} = qq{http://www.flickr.com/people/}.$user_id.qq{/};

	return $url;
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
<a href="/" accesskey=0>トップ</a>&gt;<a href="/flickr/">無料画像検索プラス</a>&gt;<a href="/$keyword_encode/flickr/">$keywordの画像一覧</a>&gt;<strong>$keywordの無料画像</strong><br>
<font size=1 color="#E9E9E9">みんなの無料画像検索プラスは,Flickrの全ての情報から無料で待ち受けや壁紙になる画像をマルチに検索できる無料画像検索検索サイトです。<br>
<a href="http://www.flickr.com/services/api/">Flickr</a>
</font>
END_OF_HTML

	&html_footer($self);

	return;
}
1;