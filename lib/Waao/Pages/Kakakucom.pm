package Waao::Pages::Kakakucom;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Data;
use Waao::Api;
use Waao::Html;
use Waao::Utility;
use XML::Simple;
use LWP::Simple;
use Jcode;
use CGI qw( escape );


# /kakakucom/					topページ
# /keyword/kakakucom/			商品検索
# /keyword/kakakucom/pageno/	商品検索
# /keyword/kakakucom/kakakucomid/商品ID	商品詳細

sub dispatch(){
	my $self = shift;

	
	if($self->{cgi}->param('p1') eq 'kakakucomid'){
		&_detail($self);
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

	$self->{html_title} = qq{最安値価格検索プラス -みんなのモバイル-};
	$self->{html_keywords} = qq{価格,カカクコム,比較,最安値};
	$self->{html_description} = qq{価格コムプラスは、商品価格の最安値や価格比較を見ることができる商品検索サイトです。};

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
<h2><font size=1>最安値価格検索</font><font size=1color="#FF0000">プラス</font></h2>
</center>
<center>
<form action="/kakakucom.html" method="POST" ><input type="text" name="q" value="" size="20"><input type="hidden" name="guid" value="ON">
<br />
<select name="category">
<option value="All">すべて</option>
<option value="Kaden">家電</option>
<option value="Pc">パソコン関連</option>
<option value="Camera">カメラ</option>
<option value="Game">ゲーム</option>
<option value="Gakki">楽器</option>
<option value="Kuruma">自動車・バイク</option>
<option value="Sports">スポーツ・レジャー</option>
<option value="Brand">ブランド・腕時計</option>
<option value="Baby">ベビー・キッズ</option>
<option value="Pet">ペット</option>
<option value="Beauty_Health">ビューティー・ヘルス</option>
</select>
<input type="submit" value="最安値検索プラス"><br />
</form>
</center>
<center>
<font size=1><font color="#FF0000">マルチ検索</font></font>
</center>
$hr
<a href="/yahooshopping/" accesskey=1>Yahoo!ショッピングで探す</a><br>
<a href="/rakuten/" accesskey=2>楽天で探す</a><br>
<a href="/amazon/" accesskey=3>amazonで探す</a><br>
<!--<a href="/list-caterank/yahooshopping/category/" accesskey=3>カテゴリ別ランキング</a><br>
<a href="/rakuten/" accesskey=4></a><br>
<a href="/amazon/" accesskey=5>amazonで探す</a><br>
<a href="" accesskey=6></a><br>
<a href="" accesskey=7></a><br>
<a href="" accesskey=8></a><br>
<a href="" accesskey=9></a><br>
-->
$hr
<a href="/" accesskey=0>トップ</a>&gt;<strong>最安値検索プラス</strong><br>
<font size=1 color="#AAAAAA">最安値検索プラスは,価格.comの情報を元に最安値情報と価格比較ができる通販ショッピング検索サイトです。<br>
<a href="http://apiblog.kakaku.com/">WEB Services by 価格.com
</a>
</font>
END_OF_HTML

}

	&html_footer($self);

	return;
}

sub _search(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('q');

	$self->{html_title} = qq{「$keyword」の最安値 -最安値検索プラス-};
	$self->{html_keywords} = qq{$keyword,最安値,価格,カカクコム,比較,売れ筋};
	$self->{html_description} = qq{$keywordの最安値情報。売れ筋通販価格比較情報};
	
	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);

	&html_header($self);

	&html_table($self, qq{<h1>$keyword</h1><h2><font size=1 color="#FF0000">最安値検索</font></h2>}, 1, 0);
print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

	&_search_kakakucom($self);

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/kakakucom/">商品最安値検索プラス</a>&gt;<strong>$keyword</strong>の最安値<br>
<font size=1 color="#AAAAAA">$keywordの最安値を価格比較しています。$keywordの売れ筋通販商品の情報を通販取得ができるマルチショッピング通販検索サイトです。<br>
<a href="http://apiblog.kakaku.com/">WEB Services by 価格.com
END_OF_HTML

	&html_footer($self);
	
	return;
}


sub _search_kakakucom(){
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
 	my $category = $self->{cgi}->param('category');
 	$category = $self->{cgi}->param('p2') unless($self->{cgi}->param('p2'));
	my $kakakucom_api_data = &kakakucom_api();
	my $appid=$kakakucom_api_data->{apiaccesskey};
	my $api_url = "http://api.kakaku.com/WebAPI/ItemSearch/Ver1.0/ItemSearch.aspx?ApiKey=$appid";

	my %api_params   = (
    "keyword"        => $keyword_utf8,
    "CategoryGroup"  => $category,
    "SortOrder"      => "pricerank",
    "PageNum"           => $page
    );
	# APIのクエリ生成
	while ( my ( $key, $value ) = each ( %api_params ) ) {
		next unless($value);
        $api_url = sprintf("%s&%s=%s",$api_url, $key, $api_params{$key});
	}

my ($response, $xml, $kakakucom_xml);
eval{
	$response = get($api_url);
	$xml = new XML::Simple;
	$kakakucom_xml = $xml->XMLin($response);
};


	&html_table($self, qq{寀<font color="#FF0000">i最安値検索</font>}, 0, 0);

	# 該当がない場合
	if( $kakakucom_xml->{NumOfResult} eq "ItemNotFound"){
print << "END_OF_HTML";
<font size=1><storong>$keyword</strong>に該当する商品は見つかりませんでした。</font><br>
END_OF_HTML
		return;
	}
	foreach my $result (@{$kakakucom_xml->{Item}}) {
		my ($link_url,$name,$makername,$saledate,$comment,$totalscoreave,$imageurl,$lowestprice);
		# real_mobileは、直リンク
eval{
		$link_url = qq{/$keyword_encode/kakakucom/kakakucomid/$result->{ProductID}/} if($result->{ProductID});
		if($self->{real_mobile}){
			$link_url = qq{$result->{ItemPageUrl}};
		}
};
eval{
		$name = Jcode->new($result->{ProductName}, 'utf8')->sjis if($result->{ProductName});
};
eval{
		$makername = Jcode->new($result->{MakerName}, 'utf8')->sjis if($result->{MakerName});
		$saledate = Jcode->new($result->{SaleDate}, 'utf8')->sjis if($result->{SaleDate});
};
eval{
		$comment = Jcode->new($result->{Comment}, 'utf8')->sjis if($result->{Comment});
};
eval{
		$lowestprice = Jcode->new($result->{LowestPrice}, 'utf8')->sjis if($result->{LowestPrice});
		$lowestprice = &price_dsp($lowestprice);
		$totalscoreave = Jcode->new($result->{TotalScoreAve}, 'utf8')->sjis if($result->{TotalScoreAve});
};
eval{
		$imageurl = Jcode->new($result->{ImageUrl}, 'utf8')->sjis if($result->{ImageUrl});
		$imageurl = qq{http://img.kakaku.com/images/productimage/m/nowprinting.gif} unless($imageurl);
};

print << "END_OF_HTML";
<font size=1 color="#FF0000">●</font><font size=1><a href="$link_url">$name</a></font><br>
<a href="$link_url"><img src="$imageurl" alt="$name" style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"></a>
$lowestprice<br>
$makername<br>
$saledate<br>
$comment
満足度:$totalscoreave<br>
<font size=1><a href="$link_url">詳しく見る</a></font><br>
<br clear="all" />
$hr
END_OF_HTML

	}

print << "END_OF_HTML";
<div align=right><a href="/$keyword_encode/kakakucom/$next_page/$category/">次の㌻</a></div>
END_OF_HTML

	return;
}

sub _detail(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('q');
	my $product_id = $self->{cgi}->param('p2');
	my $keyword_encode = &str_encode($keyword);

	my $keyword_utf8 = $keyword;
	Encode::from_to($keyword_utf8,'cp932','utf8');
	$keyword_utf8 = escape ( $keyword_utf8 );
	my $hr = &html_hr($self,1);	

	my $kakakucom_api_data = &kakakucom_api();
	my $appid=$kakakucom_api_data->{apiaccesskey};
	my $api_url = "http://api.kakaku.com/WebAPI/ItemInfo/Ver1.0/ItemInfo.ashx?ApiKey=$appid&ProductID=$product_id&ResultSet=medium";


	my ($response, $xml, $kakakucom_xml);
eval{
	$response = get($api_url);
	$xml = new XML::Simple;
	$kakakucom_xml = $xml->XMLin($response);
};


	my $dsp_str;
	my ($link_url,$name,$makername,$saledate,$comment,$totalscoreave,$imageurl,$lowestprice);
	# 該当がない場合
	if( $kakakucom_xml->{NumOfResult} eq "ItemNotFound"){
		$dsp_str = qq{<font size=1><storong>$keyword</strong>に該当する商品は見つかりませんでした。</font><br>};
	}else{
		my $result = $kakakucom_xml->{Item};
		$dsp_str .=qq{$hr};
eval{
		$link_url = qq{$result->{ItemPageUrl}};
};
eval{
		$name = Jcode->new($result->{ProductName}, 'utf8')->sjis if($result->{ProductName});
};
eval{
		$makername = Jcode->new($result->{MakerName}, 'utf8')->sjis if($result->{MakerName});
		$saledate = Jcode->new($result->{SaleDate}, 'utf8')->sjis if($result->{SaleDate});
};
eval{
		$comment = Jcode->new($result->{Comment}, 'utf8')->sjis if($result->{Comment});
};
eval{
		$lowestprice = Jcode->new($result->{LowestPrice}, 'utf8')->sjis if($result->{LowestPrice});
		$lowestprice = &price_dsp($lowestprice);
		$totalscoreave = Jcode->new($result->{TotalScoreAve}, 'utf8')->sjis if($result->{TotalScoreAve});
};
eval{
		$imageurl = Jcode->new($result->{ImageUrl}, 'utf8')->sjis if($result->{ImageUrl});
		$imageurl = qq{http://img.kakaku.com/images/productimage/m/nowprinting.gif} unless($imageurl);
};
$dsp_str .=qq{<font size=1 color="#FF0000">●</font><font size=1><a href="$link_url">$name</a></font><br>};
$dsp_str .=qq{<a href="$link_url"><img src="$imageurl" alt="$name" style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"></a>};
$dsp_str .=qq{$lowestprice<br>};
$dsp_str .=qq{$makername<br>};
$dsp_str .=qq{$saledate<br>};
$dsp_str .=qq{$comment};
$dsp_str .=qq{満足度:$totalscoreave<br>};
$dsp_str .=qq{<font size=1><a href="$link_url">詳しく見る</a></font><br>};

	} # else


	$self->{html_title} = qq{$name の最安値 $lowestprice };
	$self->{html_keywords} = qq{$name,最安値};
	$self->{html_description} = qq{$name の最安値 $lowestprice };

	&html_header($self);

	if($name){
		&html_table($self, qq{<h1>$name</h1>}, 0, 0);
		&html_table($self, qq{<h2><font size=1 color="#FF0000">$keyword 最安値検索</font></h2>}, 1, 0);
	}else{
		&html_table($self, qq{<h1>$keyword</h1><h2><font size=1 color="#FF0000">$keyword 最安値検索</font></h2>}, 1, 0);
	}

print << "END_OF_HTML";
$dsp_str
END_OF_HTML

	&html_shopping_search_plus($self);
	my $ad_amazon = &html_amazon_url($self,$keyword);

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/kakakucom/">商品最安値検索プラス</a>&gt;<strong>$keyword</strong>の最安値<br>
<font size=1 color="#AAAAAA">$keywordの最安値を価格比較しています。$keywordの売れ筋通販商品の情報を通販取得ができるマルチショッピング通販検索サイトです。<br>
<a href="http://apiblog.kakaku.com/">WEB Services by 価格.com
END_OF_HTML

	&html_footer($self);
	
	return;
}

1;