package Waao::Pages::Woman;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Html;
use Waao::Utility;
use Waao::Data;
use Waao::Api;
use XML::Simple;
use LWP::Simple;
use Net::Amazon;
use Cache::File;
use Jcode;
use CGI qw( escape );

sub dispatch(){
	my $self = shift;
	
   $self->{html_title} = qq{女性のための究極の女性向けサイト};
   $self->{html_keywords} = qq{女性,サイト,アプリ,生理日予測,妊娠診断,ダイエット};
   $self->{html_description} = qq{女性のための究極の女性向けサイト};
   my $hr = &html_hr($self,1);	
   &html_header($self);
	my $geinou = &html_mojibake_str("geinou");

	# 日付情報
	my $wayear = $self->{date_y} - 1988;
	my $datestr = $self->{date_yyyy_mm_dd}."(平成".$wayear."年)";
	my $rokuyou = $self->{mem}->get( 'rokuyou' );

print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">たった1分でわかる女性のための今日の$geinouニュース棈</font></marquee>
<center><img src="http://img.waao.jp/woman.gif" width=120 height=28 alt="究極の女性サイト"><font color="#0040FF" size=1>β版</font></center>
$hr
END_OF_HTML

&html_table($self, qq{<img src="http://img.waao.jp/kaobye03.gif" width=35 height=15><font color="red">上昇中キーワード</font>}, 0, 1);
&_get_rss_data($self,2);

&html_table($self, qq{<img src="http://img.waao.jp/kaow02.gif" width=56 height=12><font color="red">人名検索数ランキング</font>}, 0, 1);
&_get_rss_data($self,6);

&html_table($self, qq{<img src="http://img.waao.jp/mb129.gif" width=11 height=11><font color="red">テレビ・ドラマ</font>}, 0, 1);
&_get_rss_data($self,7);

print << "END_OF_HTML";
$hr
<img src="http://img.waao.jp/lamp1.gif" width=14 height=11><a href="http://waao.jp/kiyaku/">免責事項・利用規約</a><br>
<img src="http://img.waao.jp/lamp1.gif" width=14 height=11><a href="http://waao.jp/privacy/">プライバシーポリシー</a><br>
<img src="http://img.waao.jp/lamp1.gif" width=14 height=11><a href="http://waao.jp/sp-policy/">サイト健全化</a><br>
$hr
<img src="http://img.waao.jp/kaobye02.gif" width=35 height=15><a href="/diet.html" title="女性向けダイエット情報">女性向けダイエット情報</a>
$hr
<font size=1>
みんなのモバイル<font color="#FF0000">プラス</font>は、女性向け情報をマルチに検索することのできる携帯最強の女性向け携帯検索エンジンです。
</font>
END_OF_HTML

&_footer($self);
	
	return;
}

sub dispatch_diet(){
	my $self = shift;
	
   $self->{html_title} = qq{女性のための効果的ダイエット情報サイト};
   $self->{html_keywords} = qq{ダイエット,効果,女性};
   $self->{html_description} = qq{女性のための究極の女性向けサイト};
   my $hr = &html_hr($self,1);	
   &html_header($self);
	my $geinou = &html_mojibake_str("geinou");

	# 日付情報
	my $wayear = $self->{date_y} - 1988;
	my $datestr = $self->{date_yyyy_mm_dd}."(平成".$wayear."年)";
	my $rokuyou = $self->{mem}->get( 'rokuyou' );

print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">女性のためのダイエット情報</font></marquee>
<center><img src="http://img.waao.jp/womandiet.gif" width=120 height=28 alt="女性向けダイエット情報"><font color="#0040FF" size=1>β版</font></center>
$hr
END_OF_HTML

&html_table($self, qq{<img src="http://img.waao.jp/kaobye03.gif" width=35 height=15><font color="red">ダイエット情報</font>}, 0, 1);
	&_search_yahoo($self);

	&_search_amazon($self);

	&_search_rakukten($self);

print << "END_OF_HTML";
$hr
<img src="http://img.waao.jp/lamp1.gif" width=14 height=11><a href="http://waao.jp/kiyaku/">免責事項・利用規約</a><br>
<img src="http://img.waao.jp/lamp1.gif" width=14 height=11><a href="http://waao.jp/privacy/">プライバシーポリシー</a><br>
<img src="http://img.waao.jp/lamp1.gif" width=14 height=11><a href="http://waao.jp/sp-policy/">サイト健全化</a><br>
$hr
<img src="http://img.waao.jp/kaobye02.gif" width=35 height=15><a href="/" title="女性向け情報">女性向け情報</a>
$hr
END_OF_HTML

&_footer($self);

	return;
}

sub _footer(){
	my $self = shift;
	
print << "END_OF_HTML";
<center><img src="http://img.waao.jp/logo.jpg" alt="waao.jp"></center>
<a href="/">http://waao.jp/</a>
</body>
</html>
END_OF_HTML

	return;
}

sub _get_rss_data(){
	my $self = shift;
	my $type = shift;

	my $str;
	$str.=qq{<font size=1>} unless($self->{access_type} eq 4);
	my 	$sth = $self->{dbi}->prepare(qq{ select id, title, bodystr, datestr, type, geturl, ext from rssdata where type = ? and datestr >= ADDDATE(CURRENT_DATE,INTERVAL -1 DAY) order by datestr desc,id limit 10} );
	$sth->execute($type);
	my $cnt;
	while(my @row = $sth->fetchrow_array) {
		$cnt++;
 #		my $url = &html_pc_2_mb($row[);
		$str.=qq{<font color="#009525">■</font><a href="http://waao.jp/list-kizasi/kizasi/$row[0]/" title="$row[1]">$row[1]</a><br>};
		next if($type eq 1);
		next if($row[2] eq "utf8");
		$row[2] =~s/border=\"0\" align=\"left\" hspace=\"5\"\>/\>\<br>/;
		$str.=qq{$row[2]<br>};
#		$str.=qq{$row[3]<br>};
	}
	unless($cnt){
		my $limitcnt = 10;
		$limitcnt = 3 if($type == 13);
		my 	$sth = $self->{dbi}->prepare(qq{ select id, title, bodystr, datestr, type, geturl, ext from rssdata where type = ? order by datestr desc,id limit $limitcnt} );
		$sth->execute($type);
		my $cnt;
		while(my @row = $sth->fetchrow_array) {
			$str.=qq{<font color="#009525">■</font><a href="http://waao.jp/list-kizasi/kizasi/$row[0]/" title="$row[1]">$row[1]</a><br>};
			next if($type eq 1);
			next if($row[2] eq "utf8");
			$row[2] =~s/border=\"0\" align=\"left\" hspace=\"5\"\>/\>\<br>/;
			$str.=qq{$row[2]<br>};
		}
	}
	$str.=qq{<div align=right>⇒<a href="http://waao.jp/list-type/kizasi/$type/">全て見る</a></div>};
	$str.=qq{</font>} unless($self->{access_type} eq 4);
print << "END_OF_HTML";
$str
END_OF_HTML

	return;
}
sub _search_yahoo(){
	my $self = shift;
	my $keyword = qq{ダイエット};
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
<div align=right><a href="http://waao.jp/$keyword_encode/yahooshopping/">Yahoo!でもっと探す</a></div>
END_OF_HTML

	return;
}

# サンプル
# 
sub _search_rakukten(){
	my $self = shift;
	my $replay = shift;
	my $keyword = qq{ダイエット};
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
<div align=right><a href="http://waao.jp/$keyword_encode/rakuten/">楽天でもっと探す</a></div>
END_OF_HTML

	return;
}

sub _search_amazon(){
	my $self = shift;
	my $keyword = qq{ダイエット};
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
<div align=right><a href="http://waao.jp/$keyword_encode/amazon/">amazonでもっと探す</a></div>
END_OF_HTML

	return;
}

1;