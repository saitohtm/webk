package Waao::Pages::Travel;
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


# /travel/			topページ
# /keyword/travel/	キーワード検索
# /keyword/travel/list/pageno/	リスト
sub dispatch(){
	my $self = shift;
	
	if($self->{cgi}->param('p1') eq 'rakuten'){
		&_rakuten_detail($self);
	}elsif($self->{cgi}->param('q')){
		&_search($self);
	}else{
		&_top($self);
	}

	return;
}

sub _top(){
	my $self = shift;

	$self->{html_title} = qq{格安旅行ツアー検索 -みんなのトラベルプラス-};
	$self->{html_keywords} = qq{格安,旅行,ツアー,激安ツアー};
	$self->{html_description} = qq{格安ツアーや激安ツアーを一度に検索できる旅行検索エンジン。};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	
if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML
	
}else{# xhmlt chtml

print << "END_OF_HTML";
<center>
<img src="http://img.waao.jp/travellogo.gif" width=120 height=28 alt="格安旅行検索"><font size=1 color="#FF0000">プラス</font>
</center>
<center>
<form action="/travel.html" method="POST" ><input type="text" name="q" value="" size="20"><input type="hidden" name="guid" value="ON">
<br />
<input type="submit" value="旅行検索プラス"><br />
</form>
</center>
<center>
<font size=1>楽天・じゃらん・・・<font color="#FF0000">マルチ検索</font></font>
</center>
$hr
<a href="/rakutentravel/" accesskey=1>楽天で探す</a><br>
END_OF_HTML

&html_table($self, qq{人気<font color="#FF0000">旅行先</font>}, 0, 0);

my @words = ("箱根","ディズニー","大阪","名古屋","札幌");
print << "END_OF_HTML";
<font size=1>
END_OF_HTML

foreach my $word (@words){
	my $encode_word = &str_encode($word);
print << "END_OF_HTML";
<a href="/$encode_word/travel/">$word</a> 
END_OF_HTML
}

print << "END_OF_HTML";
</font>
END_OF_HTML


print << "END_OF_HTML";
<!--
<a href="/amazon/" accesskey=2>アマゾンで探す</a><br>
<a href="/yahooshopping/" accesskey=3>Y!ショッピングで探す</a><br>
<a href="" accesskey=4></a><br>
<a href="" accesskey=5></a><br>
<a href="" accesskey=6></a><br>
<a href="" accesskey=7></a><br>
<a href="" accesskey=8></a><br>
<a href="" accesskey=9></a><br>
-->
$hr
偂<a href="http://waao.jp/list-in/ranking/7/">みんなのランキング</a><br>
<a href="/" accesskey=0>トップ</a>&gt;<strong>みんなの格安旅行検索プラス</strong><br>
<font size=1 color="#E9E9E9">みんなの格安旅行検索プラスは,楽天・じゃらんの全ての情報から格安な旅行ツアー情報をマルチに検索できる旅行検索サイトです。<br>
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

	$self->{html_title} = qq{$keyword 格安旅行ツアー情報};
	$self->{html_keywords} = qq{$keyword,旅行,格安,ツアー};
	$self->{html_description} = qq{$keywordのトラベル情報。格安旅行ツアー情報も満載。};
	
	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);

	&html_header($self);

	&html_table($self, qq{<h1>$keyword</h1><h2><font size=1 color="#FF0000">格安旅行ツアー検索</font></h2>}, 1, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

	# 楽天
	&_search_rakuten($self);

	# じゃらん

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/travel/">格安旅行ツアー検索プラス</a>&gt;<strong>$keyword</strong>の格安旅行ツアー<br>
<font size=1 color="#AAAAAA">$keywordの格安旅行ツアー検索プラスの㌻は、$keywordの旅行情報をマルチに検索できるトラベル検索サイトです。<br>
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
	
	my $API_BASE_URL   = "http://api.rakuten.co.jp/rws/3.0/rest";
	my $OPERATION      = "KeywordHotelSearch";

	# APIのバージョン
	my $API_VERSION    = "2009-10-20";

	my $carrier = 0;
	$carrier = 1 if($self->{real_mobile});

	# APIへのパラメタの連想配列
	my %api_params   = (
    "keyword"        => $keyword_utf8,
    "version"        => $API_VERSION,
    "hits"           => "10",
    "page"           => $page,
    "datumType"      => "",
    "searchField"    => "",
#    "responseType"	 => "large",
    "carrier"        => $carrier
);
	# リクエストURL生成
	my $api_url = sprintf("%s?developerId=%s&affiliateId=%s&operation=%s",$API_BASE_URL,$DEVELOPER_ID,$AFFILIATE_ID,$OPERATION);

	# APIのクエリ生成
	while ( my ( $key, $value ) = each ( %api_params ) ) {
		next unless($value);
        $api_url = sprintf("%s&%s=%s",$api_url, $key, $api_params{$key});
	}

#&debug_dumper($api_url);
    my $response = get($api_url);	
	my $xml = new XML::Simple;
	my $rakuten_xml = $xml->XMLin($response);

#&debug_dumper($rakuten_xml);
	my $hr = &html_hr($self,1);	
	&html_table($self, qq{寀<font color="#BF0030">楽天トラベル</font>}, 0, 0);

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
	if( $rakuten_xml->{Body}->{"KeywordHotelSearch:KeywordHotelSearch"}->{pagingInfo}->{recordCount} < 1){
print << "END_OF_HTML";
<font size=1><storong>$keyword </strong>に該当する商品は見つかりませんでした。</font><br>
END_OF_HTML
		return;
	}

	foreach my $result (@{$rakuten_xml->{Body}->{"KeywordHotelSearch:KeywordHotelSearch"}->{hotel}}) {
		my $link_url = qq{/$keyword_encode/travel/rakuten/$result->{hotelBasicInfo}->{hotelNo}/};
		my $review_url = qq{/$keyword_encode/travel/rakuten/$result->{hotelBasicInfo}->{hotelNo}/};
		my $plan_url = qq{/$keyword_encode/travel/rakuten/$result->{hotelBasicInfo}->{hotelNo}/};
		if($self->{real_mobile}){
			$link_url = $result->{hotelBasicInfo}->{hotelInformationUrl};
			$review_url = $result->{hotelBasicInfo}->{reviewUrl};
			$plan_url = $result->{hotelBasicInfo}->{planListUrl};
		}
		my $name = Jcode->new($result->{hotelBasicInfo}->{hotelName}, 'utf8')->sjis;
		my $price = &price_dsp($result->{hotelBasicInfo}->{hotelMinCharge});
		my $hotelspecial = Jcode->new($result->{hotelBasicInfo}->{hotelSpecial}, 'utf8')->sjis;
		my $station = Jcode->new($result->{hotelBasicInfo}->{nearestStation}, 'utf8')->sjis;
		my $imgurl = $result->{hotelBasicInfo}->{hotelThumbnailUrl};

print << "END_OF_HTML";
<font size=1 color="#FF0000">●</font><font size=1><a href="$link_url">$name </a></font><br>
<img src="$imgurl" width=90 height=90 alt="$name" style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left">
<font size=1>
$price 〜<br>
<a href="tel:$result->{hotelBasicInfo}->{telephoneNo}">$result->{hotelBasicInfo}->{telephoneNo}</a><br>
$station <br>
$hotelspecial
</font>
<br clear="all" />
$hr
END_OF_HTML

	}
print << "END_OF_HTML";
<div align=right><img src="http://img.waao.jp/m2028.gif" width=48 height=9><a href="/$keyword_encode/travel/$next_page/">の㌻</a></div>
END_OF_HTML

	
	
	return;
}

sub _rakuten_detail(){
	my $self = shift;
	my $replay = shift;
	my $hotelno = $self->{cgi}->param('p2');
		
	my $rakuten_api_data = &rakuten_api();
	my $DEVELOPER_ID = $rakuten_api_data->{developer_id};
	my $AFFILIATE_ID = $rakuten_api_data->{affiliate_id};
	
	my $API_BASE_URL   = "http://api.rakuten.co.jp/rws/3.0/rest";
	my $OPERATION      = "HotelDetailSearch";

	# APIのバージョン
	my $API_VERSION    = "2009-09-09";

	my $carrier = 0;
	$carrier = 1 if($self->{real_mobile});

	# APIへのパラメタの連想配列
	my %api_params   = (
    "version"        => $API_VERSION,
    "hits"           => "10",
    "hotelNo"        => $hotelno,
    "searchField"    => "",
    "responseType"	 => "large",
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
	if($rakuten_xml->{'header:Header'}->{'Status'} =~ /(NotFound|ServerError|ClientError|Maintenance|AccessForbidden)/i){
		if($replay >=2 ){
		    my $msg = $rakuten_xml->{'header:Header'}->{'StatusMsg'};
			$msg = Jcode->new($msg, 'utf8')->sjis;
			$dsp_str = qq{<font size=1>該当するホテル・旅館は見つかりませんでした。</font><br>};
		}else{
			$replay++;
			&_detail($self,$replay);
			return;
		}
	}
	
my $basicinfo;
my $otherinfo;
my $ratinginfo;
my $facilitiesinfo;
my $policyinfo;
my $detailinfo;
my ($link_url,$review_url,$plan_url,$name,$price,$hotelspecial,$station,$access,$parkingInformation,$userReview,$address1,$address2,$privilege,$otherInformation);
eval{
	$basicinfo = $rakuten_xml->{Body}->{"hotelDetailSearch:HotelDetailSearch"}->{hotel}->{hotelBasicInfo};
	$otherinfo = $rakuten_xml->{Body}->{"hotelDetailSearch:HotelDetailSearch"}->{hotel}->{hotelOtherInfo};
	$ratinginfo = $rakuten_xml->{Body}->{"hotelDetailSearch:HotelDetailSearch"}->{hotel}->{hotelRatingInfo};
	$facilitiesinfo = $rakuten_xml->{Body}->{"hotelDetailSearch:HotelDetailSearch"}->{hotel}->{hotelFacilitiesInfo};
	$policyinfo = $rakuten_xml->{Body}->{"hotelDetailSearch:HotelDetailSearch"}->{hotel}->{hotelPolicyInfo};
	$detailinfo = $rakuten_xml->{Body}->{"hotelDetailSearch:HotelDetailSearch"}->{hotel}->{hotelDetailInfo};
	$link_url = $basicinfo->{hotelInformationUrl} if($basicinfo->{hotelInformationUrl});
	$review_url = $basicinfo->{reviewUrl} if($basicinfo->{reviewUrl});
	$plan_url = $basicinfo->{planListUrl} if($basicinfo->{planListUrl});
	$name = Jcode->new($basicinfo->{hotelName}, 'utf8')->sjis if($basicinfo->{hotelName});
	$price = &price_dsp($basicinfo->{hotelMinCharge}) if($basicinfo->{hotelMinCharge});
	$hotelspecial = Jcode->new($basicinfo->{hotelSpecial}, 'utf8')->sjis if($basicinfo->{hotelSpecial});
	$station = Jcode->new($basicinfo->{nearestStation}, 'utf8')->sjis if($basicinfo->{nearestStation});
	$access = Jcode->new($basicinfo->{access}, 'utf8')->sjis if($basicinfo->{access});
	$parkingInformation = Jcode->new($basicinfo->{parkingInformation}, 'utf8')->sjis if($basicinfo->{parkingInformation});
	$userReview = Jcode->new($basicinfo->{userReview}, 'utf8')->sjis if($basicinfo->{userReview});
	$address1 = Jcode->new($basicinfo->{address1}, 'utf8')->sjis if($basicinfo->{address1});
	$address2 = Jcode->new($basicinfo->{address2}, 'utf8')->sjis if($basicinfo->{address2});
	$privilege = Jcode->new($otherinfo->{privilege}, 'utf8')->sjis if($otherinfo->{privilege});
	$otherInformation = Jcode->new($otherinfo->{otherInformation}, 'utf8')->sjis if($otherinfo->{otherInformation});
	if($userReview =~/(.*)\<a href(.*)/){
		$userReview = $1;
	}
};

	$self->{html_title} = qq{$name 格安宿泊プラン};
	$self->{html_keywords} = qq{$name,旅行,格安,ツアー,宿泊プラン,電話番号,料金};
	$self->{html_description} = qq{$name 宿泊プラン。料金は$price〜};

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);

	&html_header($self);
	&html_table($self, qq{<h1>$name<h1><h2><font size=1 color="#FF0000">格安宿泊プラン検索</font></h2>}, 1, 0);
print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
<font color="#FF0000">●</font><a href="$link_url">$name </a><br>
<center>
<img src="$basicinfo->{hotelThumbnailUrl}" width=90 height=90 alt="$name">
<img src="$basicinfo->{roomThumbnailUrl}" width=90 height=90 alt="$name">
</center>
<font color="#00968c">★</font><a href="$plan_url">宿泊プラン($price〜)</a><br>
<font size=1>
<font color="#00968c">★</font>施設特色<br>
$hotelspecial <br>
チェックイン時刻<br>
$detailinfo->{checkinTime}<br>
チェックアウト時刻<br>
$detailinfo->{checkoutTime}<br>
<font color="#00968c">★</font>特典<br>
$privilege <br>
<font color="#00968c">★</font>その他情報<br>
$otherInformation <br>
</font>
$hr
<font size=1>
〒$basicinfo->{postalCode}<br>
住所<br>
$address1 $address2<br>
TEL<a href="tel:$basicinfo->{telephoneNo}">$basicinfo->{telephoneNo}</a><br>
FAX$basicinfo->{faxNo}<br>
施設へのアクセス<br>
$access <br>
駐車場情報<br>
$parkingInformation <br>
最寄り駅<br>
$station <br>
</font>

END_OF_HTML

&html_table($self, qq{<font color="#00968c">ユーザレビュー</font>}, 0, 0);


print << "END_OF_HTML";
<font color="#00968c">★</font><a href="$review_url">ユーザレビュー</a><br>
<font size=1>
$userReview<br>
</font>
END_OF_HTML

&html_table($self, qq{<font color="#00968c">別の検索方法で探す</font>}, 0, 0);

print << "END_OF_HTML";
areaName
middleClassCode
smallClassCode
hotelClassCode
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/travel/">格安旅行ツアー検索プラス</a>&gt;$name<br>
<font size=1 color="#AAAAAA">$nameの格安旅行ツアー検索プラスの㌻は、の旅行情報をマルチに検索できるトラベル検索サイトです。<br>
<a href="http://webservice.rakuten.co.jp/" target="_blank">Supported by 楽天ウェブサービス</a><br>
END_OF_HTML

	&html_footer($self);

	return;
}

1;