package Waao::Pages::Shopping;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Data;
use Waao::Html;
use Waao::Utility;
use Waao::Api;
use XML::Simple;
use LWP::Simple;
use Net::Amazon;
use Cache::File;
use Jcode;
use CGI qw( escape );


# /shopping/			topページ
# /keyword/shopping/	商品検索
# /keyword/shopping/yahoo|amazon|rakuten/商品ID	商品詳細
sub dispatch(){
	my $self = shift;
	
	if($self->{cgi}->param('p1') eq 'list'){
		&_list($self);
	}elsif($self->{cgi}->param('p1')){
		&_detail($self);
	}elsif($self->{cgi}->param('q')){
		&_search($self);
	}else{
		&_top($self);
	}

	return;
}

sub _top(){
	my $self = shift;

	$self->{html_title} = qq{みんなの通販ショッピングプラス -みんなのモバイル-};
	$self->{html_keywords} = qq{楽天,ヤフー,amazon,アマゾン,ショッピング,通販,送料無料};
	$self->{html_description} = qq{みんなの通販ショッピングプラス:楽天・amazon・yahoo!のショッピング検索に連動};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad_amazon = &html_amazon_url($self);
	
if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML
	
}else{# xhmlt chtml

print << "END_OF_HTML";
<center>
<img src="http://img.waao.jp/shopping.gif" width=120 height=28 alt="みんなの通販プラス"><font size=1 color="#FF0000">プラス</font>
</center>
<center>
<form action="/shopping.html" method="POST" ><input type="text" name="q" value="" size="20"><input type="hidden" name="guid" value="ON">
<br />
<input type="submit" value="商品検索プラス"><br />
</form>
</center>
<center>
<font size=1>楽天・アマゾン・ヤフー・・・<font color="#FF0000">マルチ検索</font></font>
</center>
$hr
<a href="/rakuten/" accesskey=1>楽天で探す</a><br>
<a href="/amazon/" accesskey=2>アマゾンで探す</a><br>
<a href="/yahooshopping/" accesskey=3>Y!ショッピングで探す</a><br>
<a href="http://rtag.smart-c.jp?media_id=4471&preference_id=10969" accesskey=4>ショッピングサイト</a><br>
<a href="/kakakucom/" accesskey=5>最安値(カカクコム)を探す</a><br>
<!--
<a href="" accesskey=6></a><br>
<a href="" accesskey=7></a><br>
<a href="" accesskey=8></a><br>
<a href="" accesskey=9></a><br>
-->
$hr
<center>
<a href="http://i.vcads.com/servlet/referral?guid=ON&vs=2536243&vp=879000238" ><img src="http://i.vcads.com/servlet/gifbanner?vs=2536243&vp=879000238" height="53" width="192" border="0"></a>
</center>
$hr
END_OF_HTML

&html_table($self, qq{妤人気<font color="#FF0000">検索キーワード</font>}, 0, 0);

my @words = ("財布","香水","コンタクト","ロールケーキ","クロックス","Tシャツ","サプリ","パワーストーン","コエンザイム");
print << "END_OF_HTML";
<font size=1>
END_OF_HTML

foreach my $word (@words){
	my $encode_word = &str_encode($word);
print << "END_OF_HTML";
<a href="/$encode_word/shopping/">$word</a> 
END_OF_HTML
}

print << "END_OF_HTML";
</font>
<center>
<a href="http://i.vcads.com/servlet/referral?guid=ON&vs=2536243&vp=879000256" >キャッシング一括審査</a><img src="http://i.vcads.com/servlet/gifbanner?vs=2536243&vp=879000256" height="1" width="1" border="0">
</center>
END_OF_HTML

&html_table($self, qq{女性人気<font color="#FF0000">検索ワード</font>}, 0, 0);

my @words = ("ダイエット","スイーツ","ランジェリー","ケーキ","化粧水","妊娠検査","美白","小顔","スキンケア");
print << "END_OF_HTML";
<font size=1>
END_OF_HTML

foreach my $word (@words){
	my $encode_word = &str_encode($word);
print << "END_OF_HTML";
<a href="/$encode_word/shopping/">$word</a> 
END_OF_HTML
}

print << "END_OF_HTML";
</font>
<center>
<a href="http://i.vcads.com/servlet/referral?guid=ON&vs=2536243&vp=879000250" ><img src="http://i.vcads.com/servlet/gifbanner?vs=2536243&vp=879000250" height="53" width="192" border="0"></a>
</center>
END_OF_HTML

&html_table($self, qq{男性人気<font color="#FF0000">検索ワード</font>}, 0, 0);

my @words = ("Tシャツ","パンツ","育毛","コンドーム","バイブ","時計");
print << "END_OF_HTML";
<font size=1>
END_OF_HTML

foreach my $word (@words){
	my $encode_word = &str_encode($word);
print << "END_OF_HTML";
<a href="/$encode_word/shopping/">$word</a> 
END_OF_HTML
}

print << "END_OF_HTML";
</font>
<center>
<a href="http://i.vcads.com/servlet/referral?guid=ON&vs=2536243&vp=879000259" ><img src="http://i.vcads.com/servlet/gifbanner?vs=2536243&vp=879000259" height="53" width="192" border="0"></a>
</center>
END_OF_HTML

print << "END_OF_HTML";
$hr
偂<a href="http://waao.jp/list-in/ranking/5/">みんなのランキング</a><br>
<a href="/" accesskey=0>トップ</a>&gt;<strong>みんなの通販ショッピングプラス</strong><br>
<font size=1 color="#AAAAAA">みんなの通販ショッピングプラスは,楽天・amazon(アマゾン)・ヤフーショッピングの全ての情報からお得な通販ショッピング情報と価格比較ができる通販ショッピング検索サイトです。<br>
<a href="http://webservice.rakuten.co.jp/" target="_blank">Supported by 楽天ウェブサービス</a><br>
<a href="$ad_amazon">amazon</a><br>
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
	my $keyword_encode = &str_encode($keyword);

	$self->{html_title} = qq{$keyword専門店 -売れ筋通販商品ランキング-};
	$self->{html_keywords} = qq{$keyword,楽天,ヤフー,amazon,アマゾン,ショッピング,通販,送料無料,売れ筋};
	$self->{html_description} = qq{$keyword専門店:$keywordの商品点数 No.1! $keywordの売れ筋通販商品をマルチ検索！};
	
	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);

	&html_header($self);

	&html_table($self, qq{<h1>$keyword</h1><h2><font size=1 color="#FF0000">$keyword売れ筋商品検索</font></h2>}, 1, 0);
print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML


	&_search_yahoo($self);

	&_search_amazon($self);

	&_search_rakukten($self);

	my $ad_amazon = &html_amazon_url($self);

print << "END_OF_HTML";
$hr
END_OF_HTML

	&html_table($self, qq{<a href="/$keyword_encode/search/">$keyword</a>検索<font color="#FF0000">プラス</font>}, 0, 0);

	my ($datacnt, $keyworddata) = &get_keyword($self, $keyword);
	&html_keyword_info($self,$keyworddata);

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/shopping/">通販検索プラス</a>&gt;<a href="/$keyword_encode/search/">$keyword</aの商品一覧<br>
<font size=1 color="#AAAAAA">$keyword専門店の㌻は、$keywordの売れ筋通販商品の情報を
楽天・amazon(アマゾン)・ヤフーショッピングの全ての情報から通販取得ができるマルチショッピング通販検索サイトです。<br>
<a href="http://webservice.rakuten.co.jp/" target="_blank">Supported by 楽天ウェブサービス</a><br>
<a href="$ad_amazon">amazon</a><br>
<a href="http://developer.yahoo.co.jp/about">Webサービス by Yahoo! JAPAN</a><br>
</font>
END_OF_HTML

	&html_footer($self);
	
	return;
}

# サンプル
# http://shopping.yahooapis.jp/ShoppingWebService/V1/itemSearch?appid=goooooto&affiliate_type=yid&affiliate_id=ETEGckfa4duxNnHCXO6Y3ycq4QQ-&query=vaio

sub _search_yahoo(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('q');
	my $keyword_encode = &str_encode($keyword);

	my $keyword_utf8 = $keyword;
	Encode::from_to($keyword_utf8,'cp932','utf8');
	$keyword_utf8 = escape ( $keyword_utf8 );
	my $hr = &html_hr($self,1);	

#binmode(STDOUT, ":utf8");
	
	my $url = "http://shopping.yahooapis.jp/ShoppingWebService/V1/itemSearch?appid=goooooto&affiliate_type=yid&affiliate_id=ETEGckfa4duxNnHCXO6Y3ycq4QQ-&query=$keyword_utf8&hits=5&availability=1";

my ($response, $xml, $yahoo_xml);
eval{
	$response = get($url);
	$xml = new XML::Simple;
	$yahoo_xml = $xml->XMLin($response);
};

	&html_table($self, qq{寀<font color="#FF0000">Yahoo!汐ヷ烟五</font>}, 0, 0);

	# 該当がない場合
	if( $yahoo_xml->{totalResultsReturned} < 1){
print << "END_OF_HTML";
<font size=1><storong>$keyword</strong>に該当する商品は見つかりませんでした。</font><br>
END_OF_HTML
		return;
	}
	foreach my $result (@{$yahoo_xml->{Result}->{Hit}}) {
eval{
		# real_mobileは、直リンク
		# /keyword/shopping/yahoo|amazon|rakuten/<ID>
		my $link_url = qq{/$keyword_encode/shopping/yahoo/$result->{ProductId}/} if($result->{ProductId});
		if($self->{real_mobile}){
			$link_url = qq{$result->{Url}};
		}
		my $name = Jcode->new($result->{Name}, 'utf8')->sjis if($result->{Name});
		my $headline = Jcode->new($result->{Headline}, 'utf8')->sjis if($result->{Headline});
		$headline = substr($headline,0,64);
		# プライスダウン：
		my $price = $result->{Price}->{content};
		my $fixedprice = $result->{PriceLabel}->{FixedPrice} if($result->{PriceLabel}); 
		my $pricedown;
		if( int($fixedprice) ){
			my $diff_price = $fixedprice - $price;
			if($diff_price <= 100000){
				$pricedown = qq{<font size = 1 color="#003AEA">値引き-}.&price_dsp($diff_price).qq{円</font><br>};
			}
		}
		# sendfree：送料無料
		my $sendfree;
		if($result->{Shipping}){
			if( ($result->{Shipping}->{Code} eq 2) || ($result->{Shipping}->{Code} eq 3) ){
				$sendfree = qq{<font color="#FF0000"><strong>送料無料</strong></font>炻<br>};
			}
		}
		$price = &price_dsp($price);
		
		# 画像処理
		my $img_url;
		my $img_width;
		my $img_height;
		if($result->{Image}){
			if($result->{Image}->{Small}){
				$img_url = $result->{Image}->{Small};
				$img_width = 76;
				$img_height = 76;
			}else{
				$img_url = qq{http://img.waao.jp/noimage75.gif};
				$img_width = 75;
				$img_height = 75;
			}
		}

print << "END_OF_HTML";
<font size=1 color="#FF0000">●</font><font size=1><a href="$link_url">$name</a></font><br>
<a href="$link_url"><img src="$img_url" width=$img_width height=$img_height alt="$name" style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"></a>
$price円<br>
$pricedown
$sendfree
<br clear="all" />
$hr
END_OF_HTML
}; # eval

	}

print << "END_OF_HTML";
<div align=right><a href="/$keyword_encode/yahooshopping/">Yahoo!でもっと探す</a></div>
END_OF_HTML

	return;
}

# サンプル
# 
sub _search_rakukten(){
	my $self = shift;
	my $replay = shift;
	my $keyword = $self->{cgi}->param('q');
	my $keyword_encode = &str_encode($keyword);
	my $keyword_utf8 = $keyword;
	Encode::from_to($keyword_utf8,'cp932','utf8');
	$keyword_utf8 = escape ( $keyword_utf8 );

	my $DEVELOPER_ID = "5e39057439ff0a07c0f92c9aa10dbdb9";
	my $AFFILIATE_ID = "0af1be70.3c43452f.0af1be71.7199b32d";
	
	my $API_BASE_URL   = "http://api.rakuten.co.jp/rws/2.0/rest";
	my $OPERATION      = "ItemSearch";
	# APIのバージョン
	my $API_VERSION    = "2009-04-15";

	my $carrier = 0;
	$carrier = 1 if($self->{real_mobile});

	# APIへのパラメタの連想配列
	my %api_params   = (
    "keyword"        => $keyword_utf8,
    "version"        => $API_VERSION,
    "shopCode"       => "",
    "genreId"        => "",
    "catalogCode"    => "",
    "hits"           => "5",
    "page"           => "",
    "sort"           => "",
    "minPrice"       => "",
    "maxPrice"       => "",
    "availability"   => "1",
    "field"          => "",
    "carrier"        => $carrier,
    "imageFlag"      => ""
);
	# リクエストURL生成
	my $api_url = sprintf("%s?developerId=%s&affiliateId=%s&operation=%s",$API_BASE_URL,$DEVELOPER_ID,$AFFILIATE_ID,$OPERATION);

	# APIのクエリ生成
	while ( my ( $key, $value ) = each ( %api_params ) ) {
		next unless($value);
        $api_url = sprintf("%s&%s=%s",$api_url, $key, $api_params{$key});
	}
    my $response = get($api_url);	
	my $xml = new XML::Simple;
	my $rakuten_xml = $xml->XMLin($response);

	my $hr = &html_hr($self,1);	
	&html_table($self, qq{寀<font color="#BF0030">楽天ショッピング</font>}, 0, 0);

	# エラー処理
	if($rakuten_xml->{'header:Header'}->{'Status'} =~ /(NotFound|ServerError|ClientError|Maintenance|AccessForbidden)/i){
		if($replay >=2 ){
print << "END_OF_HTML";
<font size=1><storong>$keyword</strong>に該当する商品は見つかりませんでした。</font><br>
END_OF_HTML
			return;
		}else{
			$replay++;
			&_search_rakuten($self,$replay);
			return;
		}
	}

	# 該当がない場合
	if( $rakuten_xml->{Body}->{"itemSearch:ItemSearch"}->{count} < 1){
print << "END_OF_HTML";
<font size=1><storong>$keyword</strong>に該当する商品は見つかりませんでした。</font><br>
END_OF_HTML
		return;
	}


	foreach my $result (@{$rakuten_xml->{Body}->{"itemSearch:ItemSearch"}->{Items}->{Item}}) {
		my $link_url = qq{/$keyword_encode/shopping/rakuten/$result->{itemCode}/};
		if($self->{real_mobile}){
			$link_url = qq{$result->{affiliateUrl}};
		}

		my $name = Jcode->new($result->{itemName}, 'utf8')->sjis;
		my $description = Jcode->new($result->{itemCaption}, 'utf8')->sjis;
		$description = substr($description,0,64);
		
		my $price = $result->{itemPrice};
		my $pricedown;
		$price = &price_dsp($price);
		my $sendfree;
		if($result->{postageFlag} ne 1){
			$sendfree = qq{<font color="#FF0000"><strong>送料無料</strong></font>炻<br>};
		}
		
		# 画像処理
		my $img_url;
		my $img_width;
		my $img_height;
		if($result->{imageFlag}){
			$img_url = $result->{smallImageUrl};
			$img_width = 64;
			$img_height = 64;
		}else{
			$img_url = qq{http://img.waao.jp/noimage75.gif};
			$img_width = 75;
			$img_height = 75;
		}

print << "END_OF_HTML";
<font size=1 color="#FF0000">●</font><font size=1><a href="$link_url">$name</a></font><br>
<a href="$link_url"><img src="$img_url" width=$img_width height=$img_height alt="$name" style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"></a><br>
$price円$pricedown<br>
$sendfree
<br clear="all" />
$hr
END_OF_HTML

	}
print << "END_OF_HTML";
<div align=right><a href="/$keyword_encode/rakuten/">楽天でもっと探す</a></div>
END_OF_HTML

	return;
}

sub _search_amazon(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('q');
	my $keyword_encode = &str_encode($keyword);
	my $keyword_utf8 = $keyword;
	Encode::from_to($keyword_utf8,'cp932','utf8');
#	$keyword_utf8 = escape ( $keyword_utf8 );

	my $cache = Cache::File->new( 
	    cache_root        => '/tmp/',
	    default_expires   => '30 min',
	);
	my $amazon_api = &amazon_api();
	my $ua = Net::Amazon->new(
		token      => $amazon_api->{token},
		secret_key => $amazon_api->{secret_key},
		cache       => $cache,
		max_pages => 1,
		locale => 'jp'
	);

	my $response = $ua->search(
		keyword => $keyword_utf8,
		AssociateTag => $amazon_api->{associatetag},
	);

	my $hr = &html_hr($self,1);	
	&html_table($self, qq{寀amazon}, 0, 0);

	if (not $response->is_success()) {
print << "END_OF_HTML";
<storong>$keyword</strong>に該当する商品は見つかりませんでした。<br>
END_OF_HTML
	    return;
	}
	my $forcnt;
	foreach my $result ($response->properties){
		$forcnt++;
		last if($forcnt > 5);
		
		my $name = Jcode->new($result->{Title}, 'utf8')->sjis;
		my $link_url = qq{/$keyword_encode/shopping/amazon/$result->{ASIN}/};
		if($self->{real_mobile}){
			$link_url = qq{$result->{DetailPageURL}};
		}
		
		# 画像処理
		my $img_url;
		my $img_width;
		my $img_height;
		if($result->{SmallImageUrl}){
			$img_url = $result->{SmallImageUrl};
			$img_width = $result->{SmallImageWidth};
			$img_height = $result->{SmallImageHeight};
		}else{
			$img_url = qq{http://img.waao.jp/noimage75.gif};
			$img_width = 75;
			$img_height = 75;
		}
		my $price = &price_dsp($result->{RawListPrice});
		my $pricedown;
		my $sendfree;
#		my $headline = Jcode->new($result->{ProductDescription}, 'utf8')->sjis;

print << "END_OF_HTML";
<font size=1 color="#FF0000">●</font><font size=1><a href="$link_url">$name</a></font><br>
<a href="$link_url"><img src="$img_url" width="$img_width" height="$img_height" alt="$name" style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"></a>
$price円$pricedown<br>
$sendfree
<br clear="all" />
$hr
END_OF_HTML
	}

print << "END_OF_HTML";
<div align=right><a href="/$keyword_encode/amazon/">amazonでもっと探す</a></div>
END_OF_HTML

	return;
}

sub _detail(){
	my $self = shift;
	
	if($self->{cgi}->param('p1') eq 'yahoo'){
		&_detail_yahoo($self);
	}elsif($self->{cgi}->param('p1') eq 'rakuten'){
		&_detail_rakuten($self);
	}elsif($self->{cgi}->param('p1') eq 'amazon'){
		&_detail_amazon($self);

	}

	return;
}

sub _detail_yahoo(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('q');
	my $product_id = $self->{cgi}->param('p2');
	my $keyword_encode = &str_encode($keyword);

	my $keyword_utf8 = $keyword;
	Encode::from_to($keyword_utf8,'cp932','utf8');
	$keyword_utf8 = escape ( $keyword_utf8 );
	my $hr = &html_hr($self,1);	

#binmode(STDOUT, ":utf8");
	
	my $url = "http://shopping.yahooapis.jp/ShoppingWebService/V1/itemSearch?appid=goooooto&affiliate_type=yid&affiliate_id=ETEGckfa4duxNnHCXO6Y3ycq4QQ-&product_id=$product_id";
	my ($response, $xml, $yahoo_xml);
eval{
	$response = get($url);
	$xml = new XML::Simple;
	$yahoo_xml = $xml->XMLin($response);
};

	my $dsp_str;
	my ($name,$price,$sendfree);
	# 該当がない場合
	if( $yahoo_xml->{totalResultsReturned} < 1){
		if($self->{real_mobile}){
			&_search($self);
			return;
		}
		$dsp_str = qq{<storong>$keyword</strong>に該当する商品は見つかりませんでした。<br>};
	}else{
		foreach my $result (@{$yahoo_xml->{Result}->{Hit}}) {
eval{
			# real_mobileは、直リンク
			# /keyword/shopping/yahoo|amazon|rakuten/<ID>
			my $link_url = qq{/$keyword_encode/shopping/yahoo/$result->{Code}/};
			if($self->{real_mobile}){
				$link_url = qq{$result->{Url}};
			}
			$name = Jcode->new($result->{Name}, 'utf8')->sjis if($result->{Name});
			my $headline = Jcode->new($result->{Headline}, 'utf8')->sjis if($result->{Headline});
			my $description = Jcode->new($result->{Description}, 'utf8')->sjis if($result->{Description});
			# プライスダウン：
			$price = $result->{Price}->{content};
			my $fixedprice = $result->{PriceLabel}->{FixedPrice} if($result->{PriceLabel}); 
			my $pricedown;
			if($fixedprice - $price){
				my $diff_price = $fixedprice - $price;
				$pricedown = qq{<font size = 1 color="#003AEA">値引き-}.&price_dsp($diff_price).qq{円</font><br>};
			}
			# sendfree：送料無料
			$sendfree;
			if($result->{Shipping}){
				if( ($result->{Shipping}->{Code} eq 2) || ($result->{Shipping}->{Code} eq 3) ){
					$sendfree = qq{<font color="#FF0000"><strong>送料無料</strong></font>炻<br>};
				}
			}
			$price = &price_dsp($price);
		
			# 画像処理
			my $img_url;
			if($result->{Image}){
				if($result->{Image}->{Medium}){
					$img_url = $result->{Image}->{Medium};
				}else{
					$img_url = qq{};
				}
			}
			$dsp_str .=qq{$price円<br>$pricedown};
			$dsp_str .=qq{$sendfree<br>};
			$dsp_str .=qq{<center><a href="$link_url"><img src="$img_url" width=146 height=146 alt="$name"></a></center>};
			$dsp_str .=qq{<a href="$link_url">詳しく見る</a><br>};
			$dsp_str .=qq{$headline<br>};
			$dsp_str .=qq{$description<br>};
			$dsp_str .=qq{<a href="$link_url">詳しく見る</a><br>};
			$dsp_str .=qq{$hr};
}; # eval

		} # foreach
	} # else


	$self->{html_title} = qq{$name $price $sendfree -$keyword ヤフー通販検索-};
	$self->{html_keywords} = qq{ヤフー,$keyword,通販};
	$self->{html_description} = qq{$keyword  ヤフー通販ショッピングプラスは、ヤフーで通販できるお得な$keyword通販情報です。 };

	&html_header($self);

	if($name){
		&html_table($self, qq{<h1>$name</h1>}, 0, 0);
		&html_table($self, qq{<h2><font size=1 color="#FF0000">$keyword ヤフー通販検索</font></h2>}, 1, 0);
	}else{
		&html_table($self, qq{<h1>$keyword</h1><h2><font size=1 color="#FF0000">$keyword ヤフー通販検索</font></h2>}, 1, 0);
	}

print << "END_OF_HTML";
$dsp_str
END_OF_HTML

	&html_shopping_search_plus($self,$keyword);
	my $ad_amazon = &html_amazon_url($self);

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/shopping/">通販検索プラス</a>&gt;<a href="/$keyword_encode/shopping/">$keywordの商品一覧</a>&gt;<strong>$name</strong><br>
<font size=1 color="#AAAAAA">$keywordの売れ筋通販ショッピングプラスの㌻は、$keywordの売れ筋通販商品の情報として、
$nameを検索しました。<br>
ヤフーショッピングの全ての情報から通販取得ができるマルチショッピング通販検索サイトです。<br>
<a href="http://developer.yahoo.co.jp/about">Webサービス by Yahoo! JAPAN</a><br>
</font>
END_OF_HTML

	&html_footer($self);
	
	return;
}

sub _detail_amazon(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('q');
	my $asin = $self->{cgi}->param('p2');
	my $keyword_encode = &str_encode($keyword);

	my $keyword_utf8 = $keyword;
	Encode::from_to($keyword_utf8,'cp932','utf8');
	$keyword_utf8 = escape ( $keyword_utf8 );
	my $hr = &html_hr($self,1);	

#binmode(STDOUT, ":utf8");
	my $cache = Cache::File->new( 
	    cache_root        => '/tmp/',
	    default_expires   => '30 min',
	);

	my $ua = Net::Amazon->new(
		token      => 'AKIAIRGWPLJPBTAAZKBQ',
		secret_key => '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',
		cache       => $cache,
		max_pages => 1,
		locale => 'jp',
	);
	my $response = $ua->search(
		AssociateTag => 'gooto-22',
		asin => $asin,
	);
	
	my $dsp_str;
	my ($name,$price,$sendfree);
	# 該当がない場合
	if (not $response->is_success()) {
		$dsp_str = qq{<font size=1><storong>$keyword</strong>に該当する商品は見つかりませんでした。</font><br>};
	}else{
		foreach my $result ($response->properties){
eval{
			# real_mobileは、直リンク
			# /keyword/shopping/yahoo|amazon|rakuten/<ID>
			my $link_url = qq{/$keyword_encode/shopping/amazon/$result->{ASIN}/};
			if($self->{real_mobile}){
				$link_url = qq{$result->{DetailPageURL}};
			}
			$name = Jcode->new($result->{Title}, 'utf8')->sjis if($result->{Title});
#			my $headline = Jcode->new($result->{Headline}, 'utf8')->sjis if($result->{Headline});
#			my $description = Jcode->new($result->{Description}, 'utf8')->sjis if($result->{Description});
			# プライスダウン：
			$price = &price_dsp($result->{RawListPrice});
			# 画像処理
			my $img_url;
			if($result->{MediumImageUrl}){
				$img_url = $result->{MediumImageUrl};
			}else{
				$img_url = qq{};
			}
			$dsp_str .=qq{$price円<br>};
			$dsp_str .=qq{<center><a href="$link_url"><img src="$img_url" width=146 height=146 alt="$name"></a></center>};
			$dsp_str .=qq{<a href="$link_url">オく見る</a><br>};
#			$dsp_str .=qq{$headline<br>};
#			$dsp_str .=qq{$description<br>};
			foreach my $simmilar ($response->SimilarProducts->{SimilarProducts}){
				$dsp_str .=qq{$simmilar->{Title}};
			}
			$dsp_str .=qq{$hr};
}; # eval

		} # foreach
	} # else


	$self->{html_title} = qq{$name $price-$keyword amazon(アマゾン)通販検索-};
	$self->{html_keywords} = qq{amazon,アマゾン,$keyword,通販};
	$self->{html_description} = qq{$keyword  amazon(アマゾン)通販ショッピングプラスは、amazon(アマゾン)で通販できるお得な$keyword通販情報です。 };

	&html_header($self);

	if($name){
		&html_table($self, qq{<h1>$name</h1>}, 0, 0);
		&html_table($self, qq{<h2><font size=1 color="#FF0000">$keyword amazon(アマゾン)通販検索</font></h2>}, 1, 0);
	}else{
		&html_table($self, qq{<h1>$keyword</h1><h2><font size=1 color="#FF0000">$keyword amazon(アマゾン)通販検索</font></h2>}, 1, 0);
	}

print << "END_OF_HTML";
$dsp_str
END_OF_HTML
	&html_shopping_search_plus($self,$keyword);
	my $ad_amazon = &html_amazon_url($self);

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/shopping/">通販検索プラス</a>&gt;<a href="/$keyword_encode/shopping/">$keywordの商品一覧</a>&gt;<strong>$name</strong><br>
<font size=1 color="#AAAAAA">$keywordの売れ筋通販ショッピングプラスの㌻は、$keywordの売れ筋通販商品の情報として、
$nameを検索しました。<br>
amazon(アマゾン)の全ての情報から通販取得ができるマルチショッピング通販検索サイトです。<br>
<a href="$ad_amazon">amazon</a><br>
</font>
END_OF_HTML

	&html_footer($self);
	
	return;
}

sub _detail_rakuten(){
	my $self = shift;
	my $replay = shift;
	my $keyword = $self->{cgi}->param('q');
	my $itemcode = $self->{cgi}->param('p2');
	my $keyword_encode = &str_encode($keyword);

	my $keyword_utf8 = $keyword;
	Encode::from_to($keyword_utf8,'cp932','utf8');
	$keyword_utf8 = escape ( $keyword_utf8 );
	my $hr = &html_hr($self,1);	

	my $DEVELOPER_ID = "5e39057439ff0a07c0f92c9aa10dbdb9";
	my $AFFILIATE_ID = "0af1be70.3c43452f.0af1be71.7199b32d";
	
	my $API_BASE_URL   = "http://api.rakuten.co.jp/rws/2.0/rest";
	my $OPERATION      = "ItemCodeSearch";
	# APIのバージョン
	my $API_VERSION    = "2007-04-11";

	my $carrier = 0;
	$carrier = 1 if($self->{real_mobile});

	# APIへのパラメタの連想配列
	my %api_params   = (
    "keyword"        => $keyword_utf8,
    "version"        => $API_VERSION,
    "itemCode"       => $itemcode,
    "carrier"        => $carrier
);
	# リクエストURL生成
	my $api_url = sprintf("%s?developerId=%s&affiliateId=%s&operation=%s",$API_BASE_URL,$DEVELOPER_ID,$AFFILIATE_ID,$OPERATION);
	# APIのクエリ生成
	while ( my ( $key, $value ) = each ( %api_params ) ) {
		next unless($value);
        $api_url = sprintf("%s&%s=%s",$api_url, $key, $api_params{$key});
	}

    my $response = get($api_url);	
	my $xml = new XML::Simple;
	my $rakuten_xml = $xml->XMLin($response);

	my $dsp_str;
	my ($name,$price,$sendfree);
	if($rakuten_xml->{'header:Header'}->{'Status'} =~ /(NotFound|ServerError|ClientError|Maintenance|AccessForbidden)/i){
		if($replay >=2 ){
		    my $msg = $rakuten_xml->{'header:Header'}->{'StatusMsg'};
			$msg = Jcode->new($msg, 'utf8')->sjis;
			$dsp_str = qq{$msg};
		}else{
			$replay++;
			&_detail_rakuten($self,$replay);
			return;
		}
	}else{
		my $result = $rakuten_xml->{Body}->{"itemCodeSearch:ItemCodeSearch"}->{Item};
eval{
			my $link_url = qq{/$keyword_encode/shopping/rakuten/$result->{itemCode}/};
			if($self->{real_mobile}){
				$link_url = qq{$result->{affiliateUrl}};
			}

			my $name = Jcode->new($result->{itemName}, 'utf8')->sjis;
			my $description = Jcode->new($result->{itemCaption}, 'utf8')->sjis;
			$description = substr($description,0,64);
		
			my $price = $result->{itemPrice};
			my $pricedown;
			$price = &price_dsp($price);
			my $sendfree;
			if($result->{postageFlag} ne 1){
				$sendfree = qq{<font color="#FF0000"><strong>送料無料</strong></font>炻<br>};
			}
		
			# 画像処理
			my $img_url;
			if($result->{imageFlag}){
				$img_url = $result->{mediumImageUrl};
			}else{
				$img_url = qq{};
			}
			$dsp_str .=qq{$price円<br>};
			$dsp_str .=qq{<center><a href="$link_url"><img src="$img_url" width=128 height=128 alt="$name"></a></center>};
			$dsp_str .=qq{<a href="$link_url">オく見る</a><br>};
#			$dsp_str .=qq{$headline<br>};
			$dsp_str .=qq{$description<br>};
			foreach my $simmilar ($response->SimilarProducts->{SimilarProducts}){
				$dsp_str .=qq{$simmilar->{Title}};
			}
			$dsp_str .=qq{$hr};
}; # eval

	} # else


	$self->{html_title} = qq{$name $price-$keyword 楽天通販検索-};
	$self->{html_keywords} = qq{楽天,$keyword,通販};
	$self->{html_description} = qq{$keyword  楽天通販ショッピングプラスは、楽天で通販できるお得な$keyword通販情報です。 };

	&html_header($self);

	if($name){
		&html_table($self, qq{<h1>$name</h1>}, 0, 0);
		&html_table($self, qq{<h2><font size=1 color="#FF0000">$keyword 楽天通販検索</font></h2>}, 1, 0);
	}else{
		&html_table($self, qq{<h1>$keyword</h1><h2><font size=1 color="#FF0000">$keyword 楽天通販検索</font></h2>}, 1, 0);
	}

print << "END_OF_HTML";
$dsp_str
END_OF_HTML

	&html_shopping_search_plus($self,$keyword);

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/shopping/">通販検索プラス</a>&gt;<a href="/$keyword_encode/shopping/">$keywordの商品一覧</a>&gt;<strong>$name</strong><br>
<font size=1 color="#AAAAAA">$keywordの売れ筋通販ショッピングプラスの㌻は、$keywordの売れ筋通販商品の情報として、
$nameを検索しました。<br>
楽天の全ての情報から通販取得ができるマルチショッピング通販検索サイトです。<br>
<a href="http://webservice.rakuten.co.jp/" target="_blank">Supported by 楽天ウェブサービス</a><br>
</font>
END_OF_HTML

	&html_footer($self);
	
	return;
}

1;