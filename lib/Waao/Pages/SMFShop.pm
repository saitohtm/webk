package Waao::Pages::SMFShop;
use strict;
use base qw(Waao::Pages::Base);
use Waao::Html5;
use Waao::Data;
use Waao::Utility;
use Waao::Api;
use XML::Simple;
use LWP::Simple;
use Jcode;
use CGI qw( escape );

sub dispatch(){
	my $self = shift;

	if($self->{cgi}->param('cate') eq 'all'){
		&_category($self);
	}elsif($self->{cgi}->param('cate')){
		&_category_detail($self);
	}elsif($self->{cgi}->param('id')){
		&_detail($self);
	}else{
		&_top($self);
	}	

	return;
}
sub _detail(){
	my $self = shift;

	&_detail_rakuten($self);

	return;
}


sub _detail_rakuten(){
	my $self = shift;
	my $replay = shift;
	my $keyword = $self->{cgi}->param('q');
	my $itemcode = $self->{cgi}->param('id');
	my $keyword_encode = &str_encode($keyword);

	my $keyword_utf8 = $keyword;
	Encode::from_to($keyword_utf8,'cp932','utf8');
	$keyword_utf8 = escape ( $keyword_utf8 );

	my $rakuten_api_data = &rakuten_api();
	my $DEVELOPER_ID = $rakuten_api_data->{developer_id};
	my $AFFILIATE_ID = $rakuten_api_data->{affiliate_id};
	
	my $API_BASE_URL   = "http://api.rakuten.co.jp/rws/3.0/rest";
	my $OPERATION      = "ItemCodeSearch";
	# APIのバージョン
	my $API_VERSION    = "2010-08-05";

	my $carrier = 0;
#	$carrier = 1 if($self->{real_mobile});

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
#			if($self->{real_mobile}){
				$link_url = qq{$result->{affiliateUrl}};
#			}

			$name = Jcode->new($result->{itemName}, 'utf8')->sjis;
			my $description = Jcode->new($result->{itemCaption}, 'utf8')->sjis;
		
			$price = $result->{itemPrice};
			my $pricedown;
			$price = &price_dsp($price);
			$sendfree;
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
			$dsp_str .=qq{$price<br>};
			$dsp_str .=qq{<center><a href="$link_url"><img src="$img_url" ></a></center>};
			$dsp_str .=qq{<a href="$link_url">詳しく見る</a><br>};
			$dsp_str .=qq{$description <br>};
#			foreach my $simmilar ($response->SimilarProducts->{SimilarProducts}){
#				$dsp_str .=qq{$simmilar->{Title}};
#			}
}; # eval

	} # else


	my $a = "人気商品ランキング ショッピング通販MAX(amazon/ヤフー/楽天複合検索) -通販MAX-";
	$self->{html_title} = qq{$a};
	my $b = "通販,ショッピング,amazon,楽天,ヤフー,価格";
	$self->{html_keywords} = qq{$b};
	my $c = "人気商品ランキング amazon/ヤフーショッピング/楽天の３代ショッピングサイトを複合検索できるショッピング通販MAX";
	$self->{html_description} = qq{$c};
	&html_header($self);

print << "END_OF_HTML";
<div data-role="header"> 
<h1>ショッピング通販MAX</h1>
</div>
<a href="/">スマフォMAX</a>&gt;<a href="/shop_rank.htm">ショッピングMAX</a>&gt;カテゴリ一覧
<div data-role="content">
<ul data-role="listview">
<li data-role="list-divider">カテゴリ別人気商品</li>
</ul>
<ul data-role="listview">
</ul>
<p>
$dsp_str
</p>
</div>
END_OF_HTML

	&html_footer($self);

	return;
}

sub _category_detail(){
	my $self = shift;
	my $replay = shift;

	# カテゴリ情報取得
	my $category_str = &_get_category($self);

	my $a = "人気商品ランキング ショッピング通販MAX(amazon/ヤフー/楽天複合検索) -通販MAX-";
	$self->{html_title} = qq{$a};
	my $b = "通販,ショッピング,amazon,楽天,ヤフー,価格";
	$self->{html_keywords} = qq{$b};
	my $c = "人気商品ランキング amazon/ヤフーショッピング/楽天の３代ショッピングサイトを複合検索できるショッピング通販MAX";
	$self->{html_description} = qq{$c};
	&html_header($self);

# 売れ筋ランキング

my $ranking_list = &_get_rakuten_ranking($self);
my $catestr = $self->{cgi}->param('cate');

print << "END_OF_HTML";
<a href="/" style="display: block;"><img src="/img/smfshopping.jpg" width=100% alt="ショッピング通販MAX"></a>
<div data-role="header"> 
<h1>ショッピング通販MAX</h1>
</div>
<a href="/">スマフォMAX</a>&gt;<a href="/shop_rank.htm">ショッピングMAX</a>&gt;<a href="/shopcate-all/">カテゴリ</a>&gt;ランキング
<div data-role="content">

<ul data-role="listview">
<li data-role="list-divider">売れ筋人気商品</li>
</ul>
<br>
$ranking_list
<br>
<ul data-role="listview">
<li data-role="list-divider">カテゴリで絞り込む</li>
$category_str
</ul>
<br>
<form action="/shop.html" method="get">
<fieldset>
<div data-role="fieldcontain">
<input type="search" name="q" id="search" value=""  />
<center>
	<button type="submit" data-theme="a">マルチ検索</button>
</center>
</div>
</fieldset>
</form>
</div>

END_OF_HTML

	&html_footer($self);

	return;
}

sub _category(){
	my $self = shift;
	my $replay = shift;

	# カテゴリ情報取得
	my $category_str = &_get_category($self);

	my $a = "ショッピング通販MAX(amazon/ヤフー/楽天複合検索) -スマフォMAX-";
	$self->{html_title} = qq{$a};
	my $b = "通販,ショッピング,amazon,楽天,ヤフー,価格";
	$self->{html_keywords} = qq{$b};
	my $c = "amazon/ヤフーショッピング/楽天の３代ショッピングサイトを複合検索できるショッピング通販MAX";
	$self->{html_description} = qq{$c};
	&html_header($self);

print << "END_OF_HTML";
<div data-role="header"> 
<h1>ショッピング通販MAX</h1>
</div>
<a href="/">スマフォMAX</a>&gt;<a href="/shop_rank.htm">ショッピングMAX</a>&gt;カテゴリ一覧
<div data-role="content">
<ul data-role="listview">
<li data-role="list-divider">カテゴリ別人気商品</li>
</ul>
<ul data-role="listview">
$category_str
</ul>
</div>
END_OF_HTML

	&html_footer($self);

	return;
}

sub _top(){
	my $self = shift;

	my $a = "ショッピング通販MAX(amazon/ヤフー/楽天複合検索) -スマフォMAX-";
	$self->{html_title} = qq{$a};
	my $b = "通販,ショッピング,amazon,楽天,ヤフー,価格";
	$self->{html_keywords} = qq{$b};
	my $c = "amazon/ヤフーショッピング/楽天の３代ショッピングサイトを複合検索できるショッピング通販MAX";
	$self->{html_description} = qq{$c};
	&html_header($self);

# 売れ筋ランキング

my $ranking_list = &_get_rakuten_ranking($self);

print << "END_OF_HTML";
<a href="/" style="display: block;"><img src="/img/smfshopping.jpg" width=100% alt="ショッピング通販MAX"></a>
<div data-role="header"> 
<h1>ショッピング通販MAX</h1>
</div>
<a href="/">スマフォMAX</a>&gt;ショッピングMAX
<div data-role="content">

<form action="/shop.html" method="get">
<fieldset>
<div data-role="fieldcontain">
<input type="search" name="q" id="search" value=""  />
<center>
	<button type="submit" data-theme="a">マルチ検索</button>
</center>
</div>
</fieldset>
</form>
<br>

<ul data-role="listview">
<li data-role="list-divider">売れ筋人気商品</li>
$ranking_list
</ul>
</div>
<div data-role="footer" data-position="fixed" data-id="persist">
  	<div data-role="navbar">
  		<ul>
  	  		<li><a href="#photo1" data-role="button" data-theme="a">アマゾン</a></li>
  	  		<li><a href="#photo1" data-role="button" data-theme="a">アマゾン</a></li>
  	  		<li><a href="#photo2" data-role="button" data-theme="a">楽天</a></li>
  	  		<li><a href="#photo3" data-role="button" data-theme="a">Y!ショピ</a></li>
  			<li><a href="#photo4" data-role="button" data-theme="a">カカクコム</a></li>
  		</ul>
  	</div>
</div>

END_OF_HTML

	&html_footer($self);

	return;
}

sub _get_rakuten_ranking(){
	my $self = shift;
	my $replay = shift;

	my $sarch_option = &_set_search_option($self);
	my $rakuten_api_data = &rakuten_api();

	my $DEVELOPER_ID = $rakuten_api_data->{developer_id};
	my $AFFILIATE_ID = $rakuten_api_data->{affiliate_id};

	my $API_BASE_URL   = "http://api.rakuten.co.jp/rws/3.0/rest";
	my $OPERATION      = "ItemRanking";
	my $API_VERSION    = "2010-08-05";
	my $carrier = 0;
	$carrier = 1 if($self->{real_mobile});
	my %api_params   = (
    "version"        => $API_VERSION,
    "genreId"        => $sarch_option->{genre_id},
    "age"            => $sarch_option->{age},
    "sex"            => $sarch_option->{sex},
    "carrier"        => $carrier
);

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

	if($rakuten_xml->{'header:Header'}->{'Status'} =~ /(NotFound|ServerError|ClientError|Maintenance|AccessForbidden)/i){
		if($replay >=2 ){
		    my $msg = $rakuten_xml->{'header:Header'}->{'StatusMsg'};
			$msg = Jcode->new($msg, 'utf8')->sjis;
			$dsp_str = qq{$msg};
		}else{
			$replay++;
			&_get_ranking($self,$replay);
			return;
		}
	}else{
		my $cnt;
		foreach my $result (@{$rakuten_xml->{Body}->{"itemRanking:ItemRanking"}->{Item}}) {
			$cnt++;
			my $link_url = qq{$result->{affiliateUrl}};
			my $name = Jcode->new($result->{itemName}, 'utf8')->sjis;
			my $price = $result->{itemPrice};
			$price = &price_dsp($price);
			my $itemcode = $result->{itemCode};
			
			my $sendfree;
			if($result->{postageFlag} ne 1){
				$sendfree = qq{<font color="#FF0000"><strong>送料無料</strong></font>};
			}
			my $img_url;
			if($result->{imageFlag}){
				$img_url = $result->{smallImageUrl};
			}else{
				$img_url = qq{};
			}

			$dsp_str.=qq{<img src="/img/no1.png" height="50">} if($cnt eq 1);
			$dsp_str.=qq{<img src="/img/no2.png" height="50">} if($cnt eq 2);
			$dsp_str.=qq{<img src="/img/no3.png" height="50">} if($cnt eq 3);
			$dsp_str.=qq{<ul data-role="listview" data-inset="true">};
			$dsp_str.=qq{<li>$name</li>};
			if($self->{crawler}){
				$dsp_str.=qq{<li><a href="/shopid$itemcode/"><img src="$img_url" width=115 alt="$name"><h3>$price円</h3><p>$sendfree</p></a></li>};
			}else{
				$dsp_str.=qq{<li><a href="/shopid$itemcode/"><img src="$img_url" width=115 alt="$name"><h3>$price円</h3><p>$sendfree</p></a></li>};
#				$dsp_str.=qq{<li><a href="$link_url"><img src="$img_url" width=115 alt="$name"><h3>$price円</h3><p>$sendfree</p></a></li>};
			}
			$dsp_str.=qq{</ul>};


		}
	}

	return $dsp_str;
}

sub _set_search_option(){
	my $self = shift;

	my $sarch_option;
	my $ptmp = $self->{cgi}->param('p2');
	my @vals = split(/-/,$ptmp);
	
	$sarch_option->{age} = $self->{cgi}->param('age');
	$sarch_option->{sex} = $self->{cgi}->param('sex');
	$sarch_option->{genre_id} = $self->{cgi}->param('cate') if($self->{cgi}->param('cate') ne "all");
	
	if($vals[0] eq 10){
		$sarch_option->{age_str} = qq{10代};
	}elsif($vals[0] eq 20){
		$sarch_option->{age_str} = qq{20代};
	}elsif($vals[0] eq 30){
		$sarch_option->{age_str} = qq{30代};
	}elsif($vals[0] eq 40){
		$sarch_option->{age_str} = qq{40代};
	}elsif($vals[0] eq 50){
		$sarch_option->{age_str} = qq{50代};
	}else{
		$sarch_option->{age_str} = qq{全年代};
	}
	
	if($vals[1] eq 0){
		$sarch_option->{sex_str} = qq{男性};
	}elsif($vals[1] eq 1){
		$sarch_option->{sex_str} = qq{女性};
	}else{
		$sarch_option->{sex_str} = qq{男女};
	}
	return $sarch_option;
}

sub _get_category(){
	my $self = shift;
	my $replay = shift;

	my $sarch_option = &_set_search_option($self);

	my $rakuten_api_data = &rakuten_api();
	my $genre_id =0;
	$genre_id = $sarch_option->{genre_id} if($sarch_option->{genre_id});
	my $DEVELOPER_ID = $rakuten_api_data->{developer_id};
	my $AFFILIATE_ID = $rakuten_api_data->{affiliate_id};

	my $API_BASE_URL   = "http://api.rakuten.co.jp/rws/3.0/rest";
	my $OPERATION      = "GenreSearch";
	my $API_VERSION    = "2007-04-11";
	my $carrier = 0;
	$carrier = 1 if($self->{real_mobile});
	my %api_params   = (
    "version"        => $API_VERSION,
    "genreId"        => "$genre_id"
);

	my $api_url = sprintf("%s?developerId=%s&affiliateId=%s&operation=%s",$API_BASE_URL,$DEVELOPER_ID,$AFFILIATE_ID,$OPERATION);
	# APIのクエリ生成
	while ( my ( $key, $value ) = each ( %api_params ) ) {
		next unless( defined($value));
        $api_url = sprintf("%s&%s=%s",$api_url, $key, $api_params{$key});
	}

    my $response = get($api_url);	
	my $xml = new XML::Simple;
	my $rakuten_xml = $xml->XMLin($response);
	my $dsp_str;

	if($rakuten_xml->{'header:Header'}->{'Status'} =~ /(NotFound|ServerError|ClientError|Maintenance|AccessForbidden)/i){
		if($replay >=2 ){
		    my $msg = $rakuten_xml->{'header:Header'}->{'StatusMsg'};
			$msg = Jcode->new($msg, 'utf8')->sjis;
			$dsp_str = qq{$msg};
		}else{
			# リトライ処理
			$replay++;
			&_get_category($self,$replay);
			return;
		}
	}
	#ジャンル取得
	foreach my $result (@{$rakuten_xml->{Body}->{"genreSearch:GenreSearch"}->{child}}) {
		my $name = Jcode->new($result->{genreName}, 'utf8')->sjis;
		my $str_encode= &str_encode($name);
		$dsp_str.=qq{<li><img src="/img/E231_20.gif" height="20" class="ui-li-icon"><a href="/shopcate-$result->{genreId}/">$name</a></li>};
	}

	return $dsp_str;
}

1;