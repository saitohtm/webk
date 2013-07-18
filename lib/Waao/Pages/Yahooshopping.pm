package Waao::Pages::Yahooshopping;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Data;
use Waao::Html;
use Waao::Utility;
use XML::Simple;
use LWP::Simple;
use Jcode;
use CGI qw( escape );


# /yahooshopping/					topページ
# /keyword/yahooshopping/			商品検索
# /keyword/yahooshopping/pageno/	商品検索
# /keyword/yahooshopping/yahooshopping/商品ID	商品詳細

#/list-ranking/yahooshopping/keywordrank/
#/list-ranking/yahooshopping/keywordrank/pageno/

#/list-upranking/yahooshopping/keywordrank/
#/list-upranking/yahooshopping/keywordrank/pageno/

#/list-caterank/yahooshopping/category/
#/list-caterank/yahooshopping/category/categoryID/

sub dispatch(){
	my $self = shift;

	
	if($self->{cgi}->param('p1') eq 'yahooshopping'){
		&_detail($self);
	}elsif($self->{cgi}->param('p1') eq 'keywordrank'){
		&_keyword_rank($self);
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

	$self->{html_title} = qq{ヤフー通販ショッピングプラス -みんなのモバイル-};
	$self->{html_keywords} = qq{ヤフー,ショッピング,通販,送料無料};
	$self->{html_description} = qq{みんなのヤフー通販ショッピングプラス:ヤフーだけじゃない全てのショッピング検索に連動};

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
<img src="http://img.waao.jp/shopping.gif" width=120 height=28 alt="ヤフー通販プラス"><font size=1 color="#FF0000">プラス</font>
</center>
<center>
<form action="/yahooshopping.html" method="POST" ><input type="text" name="q" value="" size="20"><input type="hidden" name="guid" value="ON">
<br />
<input type="submit" value="商品検索プラス"><br />
</form>
</center>
<center>
<font size=1>ヤフー<font color="#FF0000">マルチ検索</font></font>
</center>
$hr
<a href="/list-caterank/yahooshopping/category/" accesskey=1>カテゴリ別ランキング</a><br>
<a href="/list-ranking/yahooshopping/keywordrank/" accesskey=2>キーワードランキング</a><br>
<a href="/list-upranking/yahooshopping/keywordrank/" accesskey=3>急上昇キーワード</a><br>
<a href="/list-caterank/yahooshopping/category/" accesskey=3>カテゴリ別ランキング</a><br>
<a href="/rakuten/" accesskey=4>楽天で探す</a><br>
<a href="/amazon/" accesskey=5>amazonで探す</a><br>
<!--<a href="" accesskey=6></a><br>
<a href="" accesskey=7></a><br>
<a href="" accesskey=8></a><br>
<a href="" accesskey=9></a><br>
-->
$hr
<a href="/" accesskey=0>トップ</a>&gt;<strong>ヤフー通販ショッピングプラス</strong><br>
<font size=1 color="#AAAAAA">みんなのヤフー通販ショッピングプラスは,ヤフーだけじゃなく全ての情報からお得な通販ショッピング情報と価格比較ができる通販ショッピング検索サイトです。<br>
<a href="$ad_amazon">amazon</a><br>
</font>
END_OF_HTML

}

	&html_footer($self);

	return;
}

sub _search(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('q');

	$self->{html_title} = qq{「$keyword」の売れ筋通販商品専門店 -ヤフー通販プラス-};
	$self->{html_keywords} = qq{$keyword,ヤフー,ショッピング,通販,送料無料,売れ筋};
	$self->{html_description} = qq{$keywordの売れ筋通販ランキング情報：ヤフーのショッピング通販検索に連動};
	
	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);

	&html_header($self);

	&html_table($self, qq{<h1>$keyword</h1><h2><font size=1 color="#FF0000">ヤフー通販検索</font></h2>}, 1, 0);
print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML


	&_search_yahoo($self);

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/yahooshopping/">ヤフー通販検索プラス</a>&gt;<strong>$keyword</strong>の商品一覧<br>
<font size=1 color="#AAAAAA">$keywordのヤフー売れ筋通販ショッピングプラスの㌻は、$keywordのヤフー売れ筋通販商品の情報を
ヤフーの情報から通販取得ができるマルチショッピング通販検索サイトです。<br>
<a href="http://developer.yahoo.co.jp/about">Webサービス by Yahoo! JAPAN</a><br>
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
	my $hr = &html_hr($self,1);	

	my $page = 1;
	$page = $self->{cgi}->param('p1') if($self->{cgi}->param('p1'));
	my $next_page = $page+ 1;
	my $pre_page_max = ($page -1) * 10; 

#binmode(STDOUT, ":utf8");
	
	my $url = "http://shopping.yahooapis.jp/ShoppingWebService/V1/itemSearch?appid=goooooto&affiliate_type=yid&affiliate_id=ETEGckfa4duxNnHCXO6Y3ycq4QQ-&query=$keyword_utf8&hits=10&availability=1&offset=$pre_page_max";

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
		if($fixedprice - $price){
			my $diff_price = $fixedprice - $price;
			$pricedown = qq{<br><font size = 1 color="#003AEA">値引き-}.&price_dsp($diff_price).qq{</font><br>};
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
		if($result->{Image}){
			if($result->{Image}->{Small}){
				$img_url = $result->{Image}->{Small};
			}else{
				$img_url = qq{};
			}
		}

print << "END_OF_HTML";
<font size=1 color="#FF0000">●</font><font size=1><a href="$link_url">$name</a></font><br>
<a href="$link_url"><img src="$img_url" width=76 height=76 alt="$name" style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"></a>
$price$pricedown<br>
$sendfree
<font size=1><a href="$link_url">詳しく見る</a></font><br>
<br clear="all" />
$hr
END_OF_HTML
}; # eval

	}

print << "END_OF_HTML";
<div align=right><a href="/$keyword_encode/yahooshopping/$next_page/">次の㌻</a></div>
END_OF_HTML

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
		$dsp_str = qq{<font size=1><storong>$keyword</strong>に該当する商品は見つかりませんでした。</font><br>};
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
				$pricedown = qq{<br><font size = 1 color="#003AEA">値引き-}.&price_dsp($diff_price).qq{</font><br>};
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
			$dsp_str .=qq{$price$pricedown<br>};
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

	&html_shopping_search_plus($self);
	my $ad_amazon = &html_amazon_url($self,$keyword);

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/yahooshopping/">通販検索プラス</a>&gt;<a href="/$keyword_encode/yahooshopping/">$keywordの商品一覧</a>&gt;<strong>$name</strong><br>
<font size=1 color="#AAAAAA">$keywordの売れ筋通販ショッピングプラスの㌻は、$keywordの売れ筋通販商品の情報として、
$nameを検索しました。<br>
ヤフーショッピングの全ての情報から通販取得ができるマルチショッピング通販検索サイトです。<br>
<a href="http://developer.yahoo.co.jp/about">Webサービス by Yahoo! JAPAN</a><br>
</font>
END_OF_HTML

	&html_footer($self);
	
	return;
}

sub _keyword_rank(){
	my $self = shift;
	

	my $page = 1;
	$page = $self->{cgi}->param('p2') if($self->{cgi}->param('p2'));
	my $next_page = $page+1;
	my $pre_page_max = ($page -1) * 10; 
	my $rankingtype;
	if($self->{cgi}->param('q') eq 'list-upranking'){
		$rankingtype = qq{up};
		$self->{html_title} = qq{ヤフー キーワード:通販ショッピングプラス }.$self->{date_yyyy_mm_dd};
		$self->{html_keywords} = qq{ヤフー,ショッピング,キーワード,売れ筋};
		$self->{html_description} = qq{ヤフー キーワード:売れ筋通販商品や激安商品ランキング};
	}else{
		$rankingtype = qq{ranking};
		$self->{html_title} = qq{ヤフー売れ筋人気商品キーワードランキング }.$self->{date_yyyy_mm_dd};
		$self->{html_keywords} = qq{ヤフー,ショッピング,キーワード,売れ筋,人気商品};
		$self->{html_description} = qq{ヤフー売れ筋人気商品ランキング:売れ筋通販商品や激安商品がランキングで分かる};
	}
	
	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);

	&html_header($self);

	my $url = "http://shopping.yahooapis.jp/ShoppingWebService/V1/queryRanking?appid=goooooto&affiliate_type=yid&affiliate_id=ETEGckfa4duxNnHCXO6Y3ycq4QQ-&hits=10&offset=$pre_page_max&type=$rankingtype";
	
my ($response, $xml, $yahoo_xml);
eval{
	$response = get($url);
	$xml = new XML::Simple;
	$yahoo_xml = $xml->XMLin($response);
};
	# 該当がない場合
	if( $yahoo_xml->{totalResultsReturned} < 1){
print << "END_OF_HTML";
<font size=1>人気商品ランキングは現在集計中です。</font><br>
END_OF_HTML
	}

	if($self->{cgi}->param('q') eq 'list-upranking'){
		&html_table($self, qq{寀<font color="#FF0000">毀ー人気商品</font>}, 0, 0);
	}else{
		&html_table($self, qq{寀<font color="#FF0000">毀ー売れ筋人気商品ランキング</font>}, 0, 0);
	}
	
	foreach my $result (@{$yahoo_xml->{Result}->{QueryRankingData}}) {
		my $mark = qq{ };
		$mark = qq{<font color="#FF0000">↑</font>} if($result->{vector} eq 'up');
		$mark = qq{<font color="#0040FF">↓</font>} if($result->{vector} eq 'down');
		my $keyword = Jcode->new($result->{Query}, 'utf8')->sjis;
		my $keyword_encode = &str_encode($keyword);
print << "END_OF_HTML";
$result->{rank} $mark <a href="/$keyword_encode/yahooshopping/">$keyword</a><br>
$hr
END_OF_HTML
	}

print << "END_OF_HTML";
<a href="/" accesskey=0>トップ</a>&gt;<a href="/yahooshopping/">ヤフー通販検索プラス</a>&gt;<strong>人気商品ランキング</strong><br>
<font size=1 color="#AAAAAA">ヤフーショッピングで人気の売れ筋商品や激安通販ショッピング情報を検索できるマルチショッピング通販検索サイトです。<br>
<a href="http://developer.yahoo.co.jp/about">Webサービス by Yahoo! JAPAN</a><br>
END_OF_HTML

	&html_footer($self);

	return;
}

sub _category(){
	my $self = shift;
	if($self->{cgi}->param('p2')){
		&_category_rank($self);
	}else{
		&_category_list($self);
	}
	
	return;
}

sub _category_list(){
	my $self = shift;

	$self->{html_title} = qq{ヤフー通販カテゴリ別売れ筋ランキング -通販ショッピングプラス-};
	$self->{html_keywords} = qq{ヤフー,ショッピング,通販,カテゴリ};
	$self->{html_description} = qq{みんなのヤフー通販ショッピングプラス};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);

	my $url = "http://shopping.yahooapis.jp/ShoppingWebService/V1/categorySearch?appid=goooooto&category_id=1";

my ($response, $xml, $yahoo_xml);
eval{
	$response = get($url);
	$xml = new XML::Simple;
	$yahoo_xml = $xml->XMLin($response);
};

	&html_table($self, qq{寀<font color="#FF0000">驚剤リ別ランキング</font>}, 0, 0);
print << "END_OF_HTML";
<center>
$ad
</center>
<font size=1>
END_OF_HTML

	foreach my $result (@{$yahoo_xml->{Result}->{Categories}->{Children}->{Child}}) {
		my $categoryname = Jcode->new($result->{Title}->{Short}, 'utf8')->sjis;
print << "END_OF_HTML";
<font color="#009525">》</font><a href="/list-caterank/yahooshopping/category/$result->{Id}/">$categoryname</a><br>
END_OF_HTML
	}
	
print << "END_OF_HTML";
</font>
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/yahooshopping/">ヤフー通販検索プラス</a>&gt;<strong>カテゴリ別人気商品ランキング</strong><br>
<font size=1 color="#AAAAAA">ヤフーショッピングで人気の売れ筋商品や激安通販ショッピング情報を検索できるマルチショッピング通販検索サイトです。<br>
<a href="http://developer.yahoo.co.jp/about">Webサービス by Yahoo! JAPAN</a><br>
END_OF_HTML

	&html_footer($self);

	return;
}

sub _category_rank(){
	my $self = shift;
	my $category_id  = $self->{cgi}->param('p2');

	# カテゴリ情報取得
	my $child_category;

	my $url = "http://shopping.yahooapis.jp/ShoppingWebService/V1/categorySearch?appid=goooooto&category_id=$category_id";

my ($response, $xml, $yahoo_xml);
eval{
	$response = get($url);
	$xml = new XML::Simple;
	$yahoo_xml = $xml->XMLin($response);
};
	foreach my $result (@{$yahoo_xml->{Result}->{Categories}->{Children}->{Child}}) {
		my $categoryname = Jcode->new($result->{Title}->{Short}, 'utf8')->sjis;
		$child_category .= qq{<font color="#009525">》</font><a href="/list-caterank/yahooshopping/category/$result->{Id}/">$categoryname</a><br>};
	}
	my $category_name = Jcode->new($yahoo_xml->{Result}->{Categories}->{Current}->{Title}->{Short}, 'utf8')->sjis;


	$self->{html_title} = qq{ヤフー通販 $category_name 売れ筋ランキング -通販ショッピングプラス-};
	$self->{html_keywords} = qq{$category_name,ヤフー,ショッピング,通販,カテゴリ};
	$self->{html_description} = qq{$category_name 売れ筋人気商品ランキング みんなのヤフー通販ショッピングプラス};

	my $hr = &html_hr($self,1);	
	&html_header($self);

	#ランキング情報取得

	my $url = "http://shopping.yahooapis.jp/ShoppingWebService/V1/categoryRanking?appid=goooooto&affiliate_type=yid&affiliate_id=ETEGckfa4duxNnHCXO6Y3ycq4QQ-&category_id=$category_id";

my ($response, $xml, $yahoo_xml);
eval{
	$response = get($url);
	$xml = new XML::Simple;
	$yahoo_xml = $xml->XMLin($response);
};

	if( $yahoo_xml->{totalResultsReturned} < 1){
print << "END_OF_HTML";
<font size=1>人気商品ランキングは現在集計中です。</font><br>
END_OF_HTML
	}
	&html_table($self, qq{寀<font color="#FF0000">驚剤リ別ランキング</font>}, 0, 0) if($child_category);

print << "END_OF_HTML";
<font size=1>
$child_category
</font>
$hr
END_OF_HTML

	&html_table($self, qq{寀<font color="#FF0000">$category_name 人気商品</font>}, 0, 0);

	foreach my $result (@{$yahoo_xml->{Result}->{RankingData}}) {
		my $name = Jcode->new($result->{Name}, 'utf8')->sjis if($result->{Name});
		my $link_url;
		if($self->{real_mobile}){
			$link_url = qq{$result->{Url}};
		}
		my $img_url;
		if($result->{Image}){
			if($result->{Image}->{Small}){
				$img_url = $result->{Image}->{Small};
			}else{
				$img_url = qq{};
			}
		}

print << "END_OF_HTML";
<font size=1 color="#FF0000">●</font><font size=1><a href="$link_url">$name</a></font><br>
<a href="$link_url"><img src="$img_url" width=76 height=76 alt="$name" style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"></a>
<font size=1><a href="$link_url">詳しく見る</a></font><br>
<br clear="all" />
$hr
END_OF_HTML
	}
	

print << "END_OF_HTML";
<a href="/" accesskey=0>トップ</a>&gt;<a href="/yahooshopping/">ヤフー通販検索プラス</a>&gt;<strong>$category_name 人気商品ランキング</strong><br>
<font size=1 color="#AAAAAA">ヤフーショッピング「$category_name」カテゴリで人気の売れ筋商品や激安通販ショッピング情報を検索できるマルチショッピング通販検索サイトです。<br>
<a href="http://developer.yahoo.co.jp/about">Webサービス by Yahoo! JAPAN</a><br>
END_OF_HTML

	&html_footer($self);

	return;
}

1;