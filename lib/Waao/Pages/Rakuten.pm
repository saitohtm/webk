package Waao::Pages::Rakuten;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Api;
use Waao::Data;
use Waao::Html;
use Waao::Utility;
use XML::Simple;
use LWP::Simple;
use Jcode;
use CGI qw( escape );


# /rakuten/					topページ
# /keyword/rakuten/			商品検索
# /keyword/rakuten/pageno/	商品検索
# /keyword/rakuten/rakuten/商品ID	商品詳細

# /list-ranking/rakuten/ranking/ 総合ランキング
# /list-ranking/rakuten/ranking/age-sex-genre/ 目的別ランキング

sub dispatch(){
	my $self = shift;
	
	if($self->{cgi}->param('p1') eq 'rakuten'){
		&_detail($self);
	}elsif($self->{cgi}->param('p1') eq 'ranking'){
		&_ranking($self);
	}elsif($self->{cgi}->param('p1') eq 'category'){
		&_category($self);
	}elsif($self->{cgi}->param('p1')){
		&_search($self);
	}elsif($self->{cgi}->param('q')){
		&_search($self);
	}else{
		&_top($self);
	}

	return;
}

sub _top(){
	my $self = shift;

	$self->{html_title} = qq{楽天通販ショッピングプラス -みんなのモバイル-};
	$self->{html_keywords} = qq{楽天,ショッピング,通販,送料無料};
	$self->{html_description} = qq{みんなの楽天通販ショッピングプラス:楽天だけじゃない全てのショッピング検索に連動};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	
if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML
	
}else{# xhmlt chtml

print << "END_OF_HTML";
<center>
<img src="http://img.waao.jp/shopping.gif" width=120 height=28 alt="楽天通販プラス"><font size=1 color="#FF0000">プラス</font>
</center>
<center>
<form action="/rakuten.html" method="POST" ><input type="text" name="q" value="" size="20"><input type="hidden" name="guid" value="ON">
<br />
<input type="submit" value="商品検索プラス"><br />
</form>
</center>
<center>
<font size=1>楽天<font color="#FF0000">マルチ検索</font></font>
</center>
$hr
<a href="/list-ranking/rakuten/ranking/" accesskey=1>楽天商品ランキング</a><br>
<a href="/list-ranking/rakuten/ranking/0-0/" accesskey=2>男性人気商品</a><br>
<a href="/list-ranking/rakuten/ranking/0-1/" accesskey=3>女性人気商品</a><br>
<a href="/list-caterank/rakuten/category/" accesskey=4>カテゴリ別ランキング</a><br>
<a href="/amazon/" accesskey=5>amazonで探す</a><br>
<a href="/yahooshopping/" accesskey=6>Y!ショッピングで探す</a><br>
<!--
<a href="" accesskey=7></a><br>
<a href="" accesskey=8></a><br>
<a href="" accesskey=9></a><br>
-->

$hr
<a href="/" accesskey=0>トップ</a>&gt;<strong>楽天通販ショッピングプラス</strong><br>
<font size=1 color="#AAAAAA">みんなの楽天通販ショッピングプラスは,楽天だけじゃなく全ての情報からお得な通販ショッピング情報と価格比較ができる通販ショッピング検索サイトです。<br>
<a href="http://webservice.rakuten.co.jp/" target="_blank">Supported by 楽天ウェブサービス</a><br>
</font>
END_OF_HTML

}

	&html_footer($self);

	return;
}

sub _search(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('q');

	$self->{html_title} = qq{「$keyword」の売れ筋通販商品専門店 -楽天通販プラス-};
	$self->{html_keywords} = qq{$keyword,楽天,ショッピング,通販,送料無料,売れ筋};
	$self->{html_description} = qq{$keywordの売れ筋通販ランキング情報：楽天のショッピング通販検索に連動};
	
	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);

	&html_header($self);

	&html_table($self, qq{<h1>$keyword</h1><h2><font size=1 color="#FF0000">楽天通販検索</font></h2>}, 1, 0);
print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML


	&_search_rakuten($self);


print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/rakuten/">楽天通販検索プラス</a>&gt;<strong>$keyword</strong>の商品一覧<br>
<font size=1 color="#AAAAAA">$keywordの楽天売れ筋通販ショッピングプラスの㌻は、$keywordの楽天売れ筋通販商品の情報を
楽天の情報から通販取得ができるマルチショッピング通販検索サイトです。<br>
<a href="http://webservice.rakuten.co.jp/" target="_blank">Supported by 楽天ウェブサービス</a><br>
END_OF_HTML


	&html_footer($self);
	
	return;
}

sub _search_rakuten(){
	my $self = shift;
	my $replay = shift;
	my $keyword = $self->{cgi}->param('q');
	my $keyword_encode = &str_encode($keyword);
	my $keyword_utf8 = $keyword;
	Encode::from_to($keyword_utf8,'cp932','utf8');
	$keyword_utf8 = escape ( $keyword_utf8 );
	my $page = 1;
	$page = $self->{cgi}->param('p1') if($self->{cgi}->param('p1'));
	my $next_page = $page+ 1;

	my $rakuten_api_data = &rakuten_api();
	my $DEVELOPER_ID = $rakuten_api_data->{developer_id};
	my $AFFILIATE_ID = $rakuten_api_data->{affiliate_id};
	
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
    "hits"           => "10",
    "page"           => $page,
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
		    my $msg = $rakuten_xml->{'header:Header'}->{'StatusMsg'};
			$msg = Jcode->new($msg, 'utf8')->sjis;
print << "END_OF_HTML";
$msg
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
		my $link_url = qq{/$keyword_encode/rakuten/rakuten/$result->{itemCode}/};
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
			$img_url = $result->{smallImageUrl};
		}else{
			$img_url = qq{};
		}

print << "END_OF_HTML";
<font size=1 color="#FF0000">●</font><font size=1><a href="$link_url">$name</a></font><br>
<a href="$link_url"><img src="$img_url" width=64 height=64 alt="$name" style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"></a><br>
$price$pricedown<br>
$sendfree
<font size=1><a href="$link_url">詳しく見る</a></font><br>
<br clear="all" />
$hr
END_OF_HTML

	}
print << "END_OF_HTML";
<div align=right><a href="/$keyword_encode/rakuten/$next_page/">次の㌻</a></div>
END_OF_HTML

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
	my $itemcode = $self->{cgi}->param('p2');
	my $keyword_encode = &str_encode($keyword);

	my $keyword_utf8 = $keyword;
	Encode::from_to($keyword_utf8,'cp932','utf8');
	$keyword_utf8 = escape ( $keyword_utf8 );
	my $hr = &html_hr($self,1);	

	my $rakuten_api_data = &rakuten_api();
	my $DEVELOPER_ID = $rakuten_api_data->{developer_id};
	my $AFFILIATE_ID = $rakuten_api_data->{affiliate_id};
	
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

			$name = Jcode->new($result->{itemName}, 'utf8')->sjis;
			my $description = Jcode->new($result->{itemCaption}, 'utf8')->sjis;
			$description = substr($description,0,64);
		
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
			$dsp_str .=qq{<center><a href="$link_url"><img src="$img_url" width=128 height=128 alt="$name"></a></center>};
			$dsp_str .=qq{<a href="$link_url">詳しく見る</a><br>};
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
		&html_table($self, qq{<h2><font size=1 color="#FF0000">$name 楽天通販検索</font></h2>}, 1, 0);
	}else{
		&html_table($self, qq{<h1>$keyword</h1><h2><font size=1 color="#FF0000">$name 楽天通販検索</font></h2>}, 1, 0);
	}

print << "END_OF_HTML";
$dsp_str
END_OF_HTML

	&html_shopping_search_plus($self,$name);

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/rakuten/">楽天通販検索プラス</a>&gt;<strong>$name</strong><br>
<font size=1 color="#AAAAAA">$nameの売れ筋通販ショッピングプラスの㌻は、$nameの売れ筋通販商品の情報として、
$nameを検索しました。<br>
楽天の全ての情報から通販取得ができるマルチショッピング通販検索サイトです。<br>
<a href="http://webservice.rakuten.co.jp/" target="_blank">Supported by 楽天ウェブサービス</a><br>
</font>
END_OF_HTML

	&html_footer($self);
	
	return;
}

sub _ranking(){
	my $self = shift;
	my $replay = shift;

	my $sarch_option = &_set_search_option($self);

	$self->{html_title} = qq{楽天売れ筋通販ランキング $sarch_option->{sex_str} $sarch_option->{age_str}};
	$self->{html_keywords} = qq{楽天,ショッピング,通販,送料無料,売れ筋,$sarch_option->{sex_str},$sarch_option->{age_str}};
	$self->{html_description} = qq{$sarch_option->{sex_str}$sarch_option->{age_str}に人気の楽天売れ筋通販ランキング情報：楽天のショッピング通販検索に連動};
	
	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);
	&html_header($self);

	my $ranking = &_get_ranking($self);
	
&html_table($self, qq{偂<font color="#FF0000">$sarch_option->{sex_str}$sarch_option->{age_str} 売れ筋ランキング</font>}, 0, 0);
	
print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
$ranking
END_OF_HTML

&html_table($self, qq{偂<font color="#FF0000">年代・性別ランキング</font>}, 0, 0);

print << "END_OF_HTML";
$hr
<font size=1>
<a href="/list-ranking/rakuten/ranking/10-1/">女性10代</a><br>
<a href="/list-ranking/rakuten/ranking/20-1/">女性20代</a><br>
<a href="/list-ranking/rakuten/ranking/30-1/">女性30代</a><br>
<a href="/list-ranking/rakuten/ranking/40-1/">女性40代</a><br>
<a href="/list-ranking/rakuten/ranking/50-1/">女性50代</a><br>
<a href="/list-ranking/rakuten/ranking/10-0/">男性10代</a><br>
<a href="/list-ranking/rakuten/ranking/20-0/">男性20代</a><br>
<a href="/list-ranking/rakuten/ranking/30-0/">男性30代</a><br>
<a href="/list-ranking/rakuten/ranking/40-0/">男性40代</a><br>
<a href="/list-ranking/rakuten/ranking/50-0/">男性50代</a><br>
</font>
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/rakuten/">楽天通販検索プラス</a><br>
<font size=1 color="#AAAAAA">売れ筋通販ショッピングプラスの㌻は、売れ筋通販商品の情報として、
検索しました。<br>
楽天の全ての情報から通販取得ができるマルチショッピング通販検索サイトです。<br>
<a href="http://webservice.rakuten.co.jp/" target="_blank">Supported by 楽天ウェブサービス</a><br>
</font>
END_OF_HTML

	&html_footer($self);

	return;
}

sub _category(){
	my $self = shift;
	my $replay = shift;

# カテゴリ情報取得
	my $category_str = &_get_category($self);
# ランキング情報取得
	my $ranking = &_get_ranking($self);

	my $sarch_option = &_set_search_option($self);
	my $ad = &html_google_ad($self);

	$self->{html_title} = qq{楽天売れ筋通販ランキング $sarch_option->{sex_str} $sarch_option->{age_str}};
	$self->{html_keywords} = qq{楽天,ショッピング,通販,送料無料,売れ筋,$sarch_option->{sex_str},$sarch_option->{age_str}};
	$self->{html_description} = qq{$sarch_option->{sex_str}$sarch_option->{age_str}に人気の楽天売れ筋通販ランキング情報：楽天のショッピング通販検索に連動};
	
	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $cate_name = $self->{cgi}->param('p3');
	$cate_name = qq{全カテゴリ} unless($cate_name);
&html_table($self, qq{冾<font color="#FF0000">$cate_name</font>}, 0, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
<font size=1>
$category_str
</font>
END_OF_HTML

&html_table($self, qq{<font color="#FF0000">$cate_name</font>の人気商品}, 0, 0);

print << "END_OF_HTML";
$hr
$ranking
END_OF_HTML

print << "END_OF_HTML";
<a href="/" accesskey=0>トップ</a>&gt;<a href="/rakuten/">楽天通販検索プラス</a><br>
<font size=1 color="#AAAAAA">売れ筋通販ショッピングプラスの㌻は、売れ筋通販商品の情報として、
検索しました。<br>
楽天の全ての情報から通販取得ができるマルチショッピング通販検索サイトです。<br>
<a href="http://webservice.rakuten.co.jp/" target="_blank">Supported by 楽天ウェブサービス</a><br>
</font>
END_OF_HTML

	&html_footer($self);

	return;
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

	my $API_BASE_URL   = "http://api.rakuten.co.jp/rws/2.0/rest";
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
		$dsp_str.=qq{<font color="#009525">》</font><a href="/list-ranking/rakuten/category/--$result->{genreId}/$str_encode/">$name</a><br>};
	}

	return $dsp_str;
}

sub _get_ranking(){
	my $self = shift;
	my $replay = shift;

	my $sarch_option = &_set_search_option($self);

	my $rakuten_api_data = &rakuten_api();

	my $DEVELOPER_ID = $rakuten_api_data->{developer_id};
	my $AFFILIATE_ID = $rakuten_api_data->{affiliate_id};

	my $API_BASE_URL   = "http://api.rakuten.co.jp/rws/2.0/rest";
	my $OPERATION      = "ItemRanking";
	my $API_VERSION    = "2009-04-15";
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
	my $hr = &html_hr($self,1);	

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
		foreach my $result (@{$rakuten_xml->{Body}->{"itemRanking:ItemRanking"}->{Item}}) {
			my $link_url = qq{/list-ranking/rakuten/rakuten/$result->{itemCode}/};
			if($self->{real_mobile}){
				$link_url = qq{$result->{affiliateUrl}};
			}
			my $name = Jcode->new($result->{itemName}, 'utf8')->sjis;
			my $price = $result->{itemPrice};
			$price = &price_dsp($price);
			my $sendfree;
			if($result->{postageFlag} ne 1){
				$sendfree = qq{<font color="#FF0000"><strong>送料無料</strong></font>炻<br>};
			}
			my $img_url;
			if($result->{imageFlag}){
				$img_url = $result->{smallImageUrl};
			}else{
				$img_url = qq{};
			}
			$dsp_str .= qq{<font size=1 color="#FF0000">●</font><font size=1><a href="$link_url">$name</a></font><br>};
			$dsp_str .= qq{<a href="$link_url"><img src="$img_url" width=64 height=64 alt="$name" style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"></a><br>};
			$dsp_str .= qq{$price<br>$sendfree};
			$dsp_str .= qq{<br clear="all" />};
			$dsp_str .= qq{$hr};
		}
	}

	return $dsp_str;
}
sub _set_search_option(){
	my $self = shift;

	my $sarch_option;
	my $ptmp = $self->{cgi}->param('p2');
	my @vals = split(/-/,$ptmp);
	
	$sarch_option->{age} = $vals[0];
	$sarch_option->{sex} = $vals[1];
	$sarch_option->{genre_id} = $vals[2];
	
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
1;