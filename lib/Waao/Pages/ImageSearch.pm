package Waao::Pages::ImageSearch;
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

sub dispatch(){
	my $self = shift;

	if($self->{cgi}->param('q')){
		&_photolist($self);
	}else{
		&_top($self);
	}
	return;
}

sub _top(){
	my $self = shift;
	
	$self->{html_title} = qq{無料画像検索 -画像検索プラス-};
	$self->{html_keywords} = qq{画像,写真,検索,画像検索};
	$self->{html_description} = qq{モバイル専用の無料画像検索。画像の量と質ならクラスNo.1};
	
my $hr = &html_hr($self,1);	
&html_header($self);
my $ad = &html_google_ad($self);
	
print << "END_OF_HTML";
<center>
<img src="http://img.waao.jp/imglogo.gif" width=120 height=28 alt="無料画像検索"><font size=1 color="#FF0000">プラス</font>
</center>
<center>
<form action="/imagesearch.html" method="POST" ><input type="text" name="q" value="" size="20"><input type="hidden" name="guid" value="ON">
<br />
<input type="submit" value="画像検索プラス"><br />
</form>
</center>
<center>
<font size=1><font color="#FF0000">マルチ画像検索</font></font>
</center>
$hr
END_OF_HTML


&html_table($self, qq{<h1>今話題の<font color="#FF0000">有名人</font></h1>}, 1, 0);

my $memkey = "trendperson";
my $today_trend;
$today_trend = $self->{mem}->get( $memkey );

if($today_trend){
	my $cnt = 0;
	foreach my $keyword (@{$today_trend->{rank}}){
		$cnt++;
		my $str_encode = &str_encode($keyword);
print << "END_OF_HTML";
<a href="/$str_encode/imagesearch/">$keyword</a><br>
END_OF_HTML
	}
}

print << "END_OF_HTML";
$hr
<a href="/yahooimage/" accesskey=1>Y!Imageで検索</a><br>
<a href="/flickr/" accesskey=2>Flickrで検索</a><br>
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
<center>
$ad
</center>
$hr
<a href="/" accesskey=0>トップ</a>&gt;<strong>無料画像検索</strong><br>
<font size=1 color="#AAAAAA">無料画像検索プラスの㌻は、携帯向けの無料画像検索エンジンです。クチコミによって集めた画像とyahoo!,frickerなどの無料画像APIによる画像検索㌻です。<br>
<a href="http://developer.yahoo.co.jp/about">Webサービス by Yahoo! JAPAN</a><br>
<a href="http://www.flickr.com/services/api/">Flickr</a>
</font>
END_OF_HTML

&html_footer($self);

	return;
}

sub _photolist(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('q');
	my $keyword_encode = &str_encode($keyword);

	my $pageinfo = $self->{cgi}->param('p1'); 
	my ($page, $thumflag) = split(/-/,$pageinfo);
	$thumflag = 1 if($thumflag != 0);

	my $keywordid = $self->{cgi}->param('p2');

	my ($datacnt, $keyworddata) = &get_keyword($self, $keyword, $keywordid);
	# データが検索できない場合
	unless($datacnt){
		&_yahoo_and_frickr($self);
		return;
	}

	$self->{html_title} = qq{$keywordの画像 -無料画像検索プラス-};
	$self->{html_keywords} = qq{$keyword,検索,画像,フォト,壁紙,cm};
	$self->{html_description} = qq{$keywordの画像一覧。ここにしかない$keyword画像を無料で検索できます！};

	my $hr = &html_hr($self,1);	
	&html_header($self);

	my $ad = &html_google_ad($self);

	# ページ制御
$thumflag=1;
	my $limit_s = 0;
	my $limit = 30;
	if( $thumflag ){
		$limit = 3;
	}
	if( $page ){
		$limit_s = $limit * $page;
	}else{
		$page=1;
	}

	$limit = 30 unless($self->{real_mobile});

	my $next_page = $page + 1;
	my $next_str = qq{<img src="http://img.waao.jp/m2028.gif" width=48 height=9 alt="$keyword"><a href="/$keyword_encode/imagesearch/0-1/">最初</a> };
	$next_str .= qq{<a href="/$keyword_encode/imagesearch/$next_page-$thumflag/">$next_page</a> };
	$next_page++;
	$next_str .= qq{<a href="/$keyword_encode/imagesearch/$next_page-$thumflag/">$next_page</a> };
	$next_page++;
	$next_str .= qq{<a href="/$keyword_encode/imagesearch/$next_page-$thumflag/">$next_page</a> };
	$next_page++;
	$next_str .= qq{<a href="/$keyword_encode/imagesearch/$next_page-$thumflag/">$next_page</a> };
	$next_page++;
	$next_str .= qq{<a href="/$keyword_encode/imagesearch/$next_page-$thumflag/">$next_page</a> };

	my $keyword_str;
	my $sth;
	
	if($keywordid){
		$sth = $self->{dbi}->prepare(qq{ select id, keyword, good, url from photo where keywordid = ? order by good desc limit $limit_s, $limit} );
		$sth->execute($keywordid);
	}else{
		$sth = $self->{dbi}->prepare(qq{ select id, keyword, good, url from photo where keyword = ? order by good desc limit $limit_s, $limit} );
		$sth->execute($keyword);
	}

	my $fpage_cnt=0;
	while(my @row = $sth->fetchrow_array) {
		$fpage_cnt++;
		$limit_s++;
		$keyword_str .= qq{<font size=1>};
		if( $thumflag ){
			$keyword_str .= qq{<table border=0 bgcolor="#000000" width="100%"><tr><td><center><a href="/$keyword_encode/photo/$row[0]/"><img src="$row[3]" alt="$row[1]の画像"><br><font size=1>[拡大]</font></a></center></td></tr></table>};
		}
		if( $thumflag ){
			$keyword_str .= qq{<font size=1><strong>$keyword</strong>の評価：<font color="blue">$row[2]</font><font color="red">Good炻</font></font><br>};
			$keyword_str .= qq{<center><form action="/photoeva.html" method="POST">};
			$keyword_str .= qq{<input type="hidden" name="photoid" value="$row[0]">};
			$keyword_str .= qq{<input type="hidden" name="good" value="1">};
			$keyword_str .= qq{<input type="hidden" name="guid" value="on">};
			$keyword_str .= qq{<input type="hidden" name="q" value="$row[1]">};
			$keyword_str .= qq{<input type="submit" value="Good!">};
			$keyword_str .= qq{</form>};
			$keyword_str .= qq{<form action="/photoeva.html" method="POST">};
			$keyword_str .= qq{<input type="hidden" name="photoid" value="$row[0]">};
			$keyword_str .= qq{<input type="hidden" name="bad" value="1">};
			$keyword_str .= qq{<input type="hidden" name="guid" value="on">};
			$keyword_str .= qq{<input type="hidden" name="q" value="$row[1]">};
			$keyword_str .= qq{<input type="submit" value="Bad!"><br>};
			$keyword_str .= qq{</form>};
			$keyword_str .= qq{</center>};
		}else{
			$keyword_str .= qq{<font size=1><a href="/$keyword_encode/photoid/$row[0]/">$keywordの画像</a><div align="right"><font color="blue">$row[2]</font><font color="red">Good炻</font></div></font><br>};
		}
		$keyword_str .= qq{</font>$hr};
	}
	if($fpage_cnt eq 0){
	}elsif($fpage_cnt < 3){
	}



my $simplewiki = &simple_wiki_upd($keyworddata->{simplewiki}, 128) if($keyworddata->{simplewiki});


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

&html_table($self, qq{<h1>$keyword</h1><h2><font size=1>$keyword</font><font size=1 color="#FF0000">画像一覧</font></h2>}, 1, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

print << "END_OF_HTML";
$keyword_str</font>
<br>
$next_str
$hr
END_OF_HTML

&html_keyword_info($self,$keyworddata);


print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/$keyword_encode/search/">$keyword検索</a>&gt;<strong>$keyword</strong>画像一覧<br>
<font size=1 color="#AAAAAA">$keywordの画像検索プラスの㌻は、$keywordの画像情報を口コミによって集めた$keywordの無料画像検索㌻です。<br>
$keywordの画像情報の収集にご協力をお願いします。<br>
</font>
END_OF_HTML

} # xhtml
	
	&html_footer($self);
	
	return;
}

sub _yahoo_and_frickr(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('q');
	my $keyword_encode = &str_encode($keyword);

	$self->{html_title} = qq{$keywordの無料画像検索 -無料画像検索プラス-};
	$self->{html_keywords} = qq{$keyword,無料画像,画像,画像検索};
	$self->{html_description} = qq{$keywordの無料画像検索。};
	
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

warn "AAAAAAAAAAAAAA";
	# Yahoo!
	&_search_yahoo($self);

	# Frickr
	&_search_flickr($self);

	my $page = 1;
	$page = $self->{cgi}->param('p1') if($self->{cgi}->param('p1'));
	my $next_page = $page + 1;

print << "END_OF_HTML";
<div align=right><img src="http://img.waao.jp/m2028.gif" width=48 height=9><a href="/$keyword_encode/imagesearch/$next_page/">次の㌻</a></div>
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/imagesearch/">無料画像検索プラス</a>&gt;<strong>$keywordの無料画像検索</strong><br>
<font size=1 color="#E9E9E9">無料画像検索プラスは,Y!imageAPIとFrickrAPIを利用した$keywordの無料画像検索を行う検索エンジンです。<br>
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
	my $start = 1 + 5 * ($page - 1);
	my $api_url;
	$api_url = qq{http://search.yahooapis.jp/ImageSearchService/V1/imageSearch?appid=goooooto&query=$keyword_utf8&results=3&adult_ok=1&start=$start};

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
print << "END_OF_HTML";
<center>
<a href="/yahooimage.html?guid=ON&url=$urlm&q=$altname_encode"><img src="$url" width=$width height=$height alt="$altname"><br><font size=1>[拡大]</font></a>
</center>
END_OF_HTML
	}

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
	$api_url = qq{http://www.flickr.com/services/rest/?method=flickr.photos.search&format=rest&api_key=fe5c28cda2b5d06c5de2041577f4e49a&per_page=3&license=1,2,3,4,5,6&extras=owner_name&text=$keyword_utf8&page=$page};

    my $response = get($api_url);
	my $xml = new XML::Simple;
	my $flickr_xml = $xml->XMLin($response);

	my $hr = &html_hr($self,1);	
	&html_table($self, qq{寀<font color="#BF0030">Flickr画像検索</font>}, 0, 0);

	foreach my $id (keys %{$flickr_xml->{photos}->{photo}}) {
eval{
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
};
	}

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

1;