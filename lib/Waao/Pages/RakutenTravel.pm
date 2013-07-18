package Waao::Pages::RakutenTravel;
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


# /rakutentravel/		topページ
# /keyword/rakutentravel/	キーワード検索
# /keyword/rakutentravel/list/pageno/	リスト
# /keyword/rakutentravel/id/	詳細
# /list-rank/rakutentravel/	ランキング
# /list-rank/rakutentravel/genre/	ジャンル
# /list-area/rakutentravel/l-m-s/	
# /list-area/rakutentravel/l-m-s/pageno/	
#/list-middle/rakutentravel/code/
#/list-small/rakutentravel/code/
sub dispatch(){
	my $self = shift;
	
	if($self->{cgi}->param('p1') eq 'rakuten'){
	}elsif($self->{cgi}->param('q') eq 'list-middle'){
		&_area_middle($self);
	}elsif($self->{cgi}->param('q') eq 'list-small'){
		&_area_small($self);
	}elsif($self->{cgi}->param('q') eq 'list-rank'){
		&_ranking($self);
	}elsif($self->{cgi}->param('q') eq 'list-area'){
		&_area_search($self);
	}elsif($self->{cgi}->param('p1')){
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

	$self->{html_title} = qq{格安旅行ツアー検索 -みんなの楽天トラベルプラス-};
	$self->{html_keywords} = qq{格安,旅行,ツアー,激安ツアー,楽天トラベル};
	$self->{html_description} = qq{格安ツアーや激安ツアーを楽天トラベルの情報から検索できる携帯旅行検索エンジン。};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	
if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML
	
}else{# xhmlt chtml

print << "END_OF_HTML";
<center>
<h2><font size=1>楽天格安旅行検索</font><font size=1 color="#FF0000">プラス</font></h2>
</center>
<center>
<form action="/travel.html" method="POST" ><input type="text" name="q" value="" size="20"><input type="hidden" name="guid" value="ON">
<br />
<input type="submit" value="旅行検索プラス"><br />
</form>
</center>
<center>
<font size=1>楽天トラベル<font color="#FF0000">マルチ検索</font></font>
</center>
$hr

<a href="/list-rank/rakutentravel/" accesskey=1>オススメランキング</a><br>
<a href="/list-rank/rakutentravel/onsen/" accesskey=2>温泉ランキング</a><br>
<a href="/list-rank/rakutentravel/premium/" accesskey=3>高級ホテルランキング</a><br>
<a href="/list-middle/rakutentravel/" accesskey=4>エリア検索</a><br>
<!--<a href="" accesskey=5></a><br>
<a href="" accesskey=6></a><br>
<a href="" accesskey=7></a><br>
<a href="" accesskey=8></a><br>
<a href="" accesskey=9></a><br>
-->
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/travel/">みんなの格安旅行検索プラス</a>&gt;<strong>格安旅行検索プラス</strong><br>
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

    my $response = get($api_url);	
	my $xml = new XML::Simple;
	my $rakuten_xml = $xml->XMLin($response);

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
	my $hotelno = $self->{cgi}->param('p1');

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
#&debug_dumper($api_url);
#&debug_dumper($rakuten_xml);
	my $dsp_str;
	if($rakuten_xml->{'header:Header'}->{'Status'} =~ /(NotFound|ServerError|ClientError|Maintenance|AccessForbidden)/i){
		if($replay >=2 ){
		    my $msg = $rakuten_xml->{'header:Header'}->{'StatusMsg'};
			$msg = Jcode->new($msg, 'utf8')->sjis;
			$dsp_str = qq{<font size=1>該当するホテル・旅館は見つかりませんでした。</font><br>};
		}else{
			$replay++;
			&_rakuten_detail($self,$replay);
			return;
		}
	}
my $basicinfo;
my $otherinfo;
my $ratinginfo;
my $facilitiesinfo;
my $policyinfo;
my $detailinfo;
my ($link_url,$review_url,$plan_url,$name,$price,$hotelspecial,$station,$access,$parkingInformation,$userReview,$address1,$address2,$privilege,$otherInformation,$areaname);
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
	$areaname = Jcode->new($detailinfo->{areaName}, 'utf8')->sjis if($detailinfo->{areaName});
	$otherInformation = Jcode->new($otherinfo->{otherInformation}, 'utf8')->sjis if($otherinfo->{otherInformation});
	if($userReview =~/(.*)\<a href(.*)/){
		$userReview = $1;
	}
	$privilege = Jcode->new($otherinfo->{privilege}, 'utf8')->sjis if($otherinfo->{privilege});
};
	$self->{html_title} = qq{$name 格安宿泊プラン -楽天トラベルプラス-};
	$self->{html_keywords} = qq{$name,旅行,格安,ツアー,宿泊プラン,電話番号,料金,楽天};
	$self->{html_description} = qq{$name 宿泊プラン。料金は$price〜 楽天トラベルプラス};

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

&html_table($self, qq{<font color="#00968c">別のホテルを探す</font>}, 0, 0);

print << "END_OF_HTML";
<a href="/list-area/rakutentravel/-$detailinfo->{middleClassCode}-$detailinfo->{smallClassCode}/">$areaname付近の旅行プラン</a><br>
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/rakutentravel/">楽天トラベルプラス</a>&gt;$name<br>
<font size=1 color="#AAAAAA">$nameの格安旅行ツアー検索プラスの㌻は、の旅行情報をマルチに検索できるトラベル検索サイトです。<br>
<a href="http://webservice.rakuten.co.jp/" target="_blank">Supported by 楽天ウェブサービス</a><br>
END_OF_HTML

	&html_footer($self);

	return;
}

sub _ranking(){
	my $self = shift;
	my $replay = shift;
	my $genre = $self->{cgi}->param('p1');

	my $rakuten_api_data = &rakuten_api();
	my $DEVELOPER_ID = $rakuten_api_data->{developer_id};
	my $AFFILIATE_ID = $rakuten_api_data->{affiliate_id};
	
	my $API_BASE_URL   = "http://api.rakuten.co.jp/rws/2.0/rest";
	my $OPERATION      = "HotelRanking";

	# APIのバージョン
	my $API_VERSION    = "2009-06-25";

	my $carrier = 0;
	$carrier = 1 if($self->{real_mobile});

	# APIへのパラメタの連想配列
	my %api_params   = (
    "version"        => $API_VERSION,
    "genre"        => $genre,
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
	my $hr = &html_hr($self,1);	

	# エラー処理
	my $msg_dsp;
	if($rakuten_xml->{'header:Header'}->{'Status'} =~ /(NotFound|ServerError|ClientError|Maintenance|AccessForbidden)/i){
		if($replay >=2 ){
		    my $msg = $rakuten_xml->{'header:Header'}->{'StatusMsg'};
			$msg = Jcode->new($msg, 'utf8')->sjis;
			$msg_dsp = $msg;
			return;
		}else{
			$replay++;
			&_ranking($self,$replay);
			return;
		}		
	}

	foreach my $result (@{$rakuten_xml->{Body}->{"hotelRanking:HotelRanking"}->{ranking}->{hotelRankInfo}}) {
		my $link_url = qq{/list-travel/rakutentravel/$result->{hotelNo}/};
		my $review_url = qq{/list-travel/rakutentravel/$result->{hotelNo}/};
		my $plan_url = qq{/list-travel/rakutentravel/$result->{hotelNo}/};
		if($self->{real_mobile}){
			$link_url = $result->{hotelInformationUrl} if($result->{hotelInformationUrl});
			$review_url = $result->{reviewUrl} if($result->{reviewUrl});
			$plan_url = $result->{planListUrl} if($result->{planListUrl});
		}
		my $name = Jcode->new($result->{hotelName}, 'utf8')->sjis if($result->{hotelName});
		my $userreview = Jcode->new($result->{userReview}, 'utf8')->sjis if($result->{userReview});
		if($userreview =~/(.*)\<a href(.*)/){
			$userreview = $1;
		}
		my $imgurl = $result->{hotelImageUrl};

		$msg_dsp .=qq{<font size=1 color="#FF0000">●</font><font size=1><a href="$link_url">$name </a></font><br>};
		$msg_dsp .=qq{<img src="$imgurl" width=90 height=90 alt="$name" style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left">};
		$msg_dsp .=qq{<font size=1>$userreview </font><br clear="all" />};
		$msg_dsp .=qq{$hr};
	}

	if($genre eq 'onsen'){
		$self->{html_title} = qq{格安温泉ツアーランキング -みんなの楽天トラベルプラス-};
		$self->{html_keywords} = qq{温泉,人気,ランキング,格安,旅行,ツアー,激安ツアー,楽天トラベル};
		$self->{html_description} = qq{人気温泉格安ツアーや激安ツアーを楽天トラベルの情報から検索できる携帯旅行検索エンジン。};
	}elsif($genre eq 'premium'){
		$self->{html_title} = qq{高級ホテル格安宿泊プランランキング -みんなの楽天トラベルプラス-};
		$self->{html_keywords} = qq{高級ホテル,宿泊,人気,ランキング,格安,楽天トラベル};
		$self->{html_description} = qq{高級ホテル格安宿泊プランランキングを楽天トラベルの情報から検索できる携帯旅行検索エンジン。};
	}else{
		$self->{html_title} = qq{格安旅行ツアーランキング -みんなの楽天トラベルプラス-};
		$self->{html_keywords} = qq{人気,ランキング,格安,旅行,ツアー,激安ツアー,楽天トラベル};
		$self->{html_description} = qq{格安ツアーや激安ツアーを楽天トラベルの情報から検索できる携帯旅行検索エンジン。};
	}

	&html_header($self);
	
	&html_table($self, qq{寀<font color="#BF0030">楽天トラベルランキング</font>}, 0, 0);
print << "END_OF_HTML";
$msg_dsp
END_OF_HTML

print << "END_OF_HTML";
<a href="/" accesskey=0>トップ</a>&gt;<a href="/rakutentravel/">楽天トラベルプラス</a>&gt;<strong>みんなの格安旅行ランキング</strong><br>
<font size=1 color="#E9E9E9">みんなの格安旅行ランキングは,楽天の情報から格安な旅行ツアー情報をマルチに検索できる旅行検索サイトです。<br>
<a href="http://webservice.rakuten.co.jp/" target="_blank">Supported by 楽天ウェブサービス</a><br>
</font>
END_OF_HTML

	return;
}

sub _area_search(){
	my $self = shift;
	my $replay = shift;
	my $areaparam = $self->{cgi}->param('p1');
	my @areas = split(/-/,$self->{cgi}->param('p1'));
	my $detailClassCode;

	my $page = 1;
	$page = $self->{cgi}->param('p2') if($self->{cgi}->param('p2'));
	my $next_page = $page+ 1;

	my $rakuten_api_data = &rakuten_api();
	my $DEVELOPER_ID = $rakuten_api_data->{developer_id};
	my $AFFILIATE_ID = $rakuten_api_data->{affiliate_id};
	
	my $API_BASE_URL   = "http://api.rakuten.co.jp/rws/3.0/rest";
	my $OPERATION      = "SimpleHotelSearch";

	# APIのバージョン
	my $API_VERSION    = "2009-10-20";

	my $carrier = 0;
	$carrier = 1 if($self->{real_mobile});

	# APIへのパラメタの連想配列
	my %api_params   = (
    "version"        => $API_VERSION,
    "hits"           => "10",
    "page"           => $page,
    "largeClassCode"  => "japan",
    "middleClassCode" => $areas[1],
    "smallClassCode"  => $areas[2],
    "detailClassCode" => $detailClassCode,
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

	my $hr = &html_hr($self,1);	

	my $dsp_str;
	if($rakuten_xml->{'header:Header'}->{'Status'} =~ /(NotFound|ServerError|ClientError|Maintenance|AccessForbidden)/i){
		if($replay >=2 ){
		    my $msg = $rakuten_xml->{'header:Header'}->{'StatusMsg'};
			$msg = Jcode->new($msg, 'utf8')->sjis;
			$dsp_str = qq{<font size=1>該当するホテル・旅館は見つかりませんでした。</font><br>};
		}else{
			$replay++;
			&_area_search($self,$replay);
			return;
		}
	}

	foreach my $result (@{$rakuten_xml->{Body}->{"SimpleHotelSearch:SimpleHotelSearch"}->{hotel}}) {
		my $link_url = qq{/list-travel/rakutentravel/$result->{hotelBasicInfo}->{hotelNo}/};
		my $review_url = qq{/list-travel/rakutentravel/$result->{hotelBasicInfo}->{hotelNo}/};
		my $plan_url = qq{/list-travel/rakutentravel/$result->{hotelBasicInfo}->{hotelNo}/};
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

		$dsp_str .=qq{<font size=1 color="#FF0000">●</font><font size=1><a href="$link_url">$name </a></font><br>};
		$dsp_str .=qq{<img src="$imgurl" width=90 height=90 alt="$name" style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left">};
		$dsp_str .=qq{<font size=1>};
		$dsp_str .=qq{$price 〜<br>};
		$dsp_str .=qq{<a href="tel:$result->{hotelBasicInfo}->{telephoneNo}">$result->{hotelBasicInfo}->{telephoneNo}</a><br>};
		$dsp_str .=qq{$station <br>};
		$dsp_str .=qq{$hotelspecial};
		$dsp_str .=qq{</font>};
		$dsp_str .=qq{<br clear="all" />};
		$dsp_str .=qq{$hr};
	}

	my $ad = &html_google_ad($self);

	$self->{html_title} = qq{格安旅行ツアーエリア検索 -みんなの楽天トラベルプラス-};
	$self->{html_keywords} = qq{格安,旅行,ツアー,激安ツアー,楽天トラベル};
	$self->{html_description} = qq{格安ツアーや激安ツアーを楽天トラベルの情報からエリア検索できる携帯旅行検索エンジン。};

	&html_header($self);

	&html_table($self, qq{<h2><font size=1 color="#FF0000">格安旅行ツアー検索</font></h2>}, 1, 0);

print << "END_OF_HTML";
$dsp_str
<div align=right><img src="http://img.waao.jp/m2028.gif" width=48 height=9><a href="/list-area/rakutentravel/$areaparam/$next_page/">次の㌻</a></div>
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/rakutentravel/">楽天トラベルプラス</a>&gt;<a href="/list-middle/rakutentravel/">全国</a>&gt;格安旅行ツアー<br>
<font size=1 color="#AAAAAA">格安旅行ツアー検索プラスの㌻は、旅行情報をマルチに検索できるトラベル検索サイトです。<br>
<a href="http://webservice.rakuten.co.jp/" target="_blank">Supported by 楽天ウェブサービス</a><br>
END_OF_HTML

	&html_footer($self);

	return;
}

sub _area_middle(){
	my $self = shift;

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);

	my $dsp_str;
	my $sth;
	$sth = $self->{dbi}->prepare(qq{ select middle, middlename from rakutenarea group by middle order by id  } );
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$dsp_str .= qq{<font color="#009525">》</font><a href="/list-small/rakutentravel/$row[0]/">$row[1]</a><br>};
	}

	$self->{html_title} = qq{格安旅行ツアーエリア検索 -みんなの楽天トラベルプラス-};
	$self->{html_keywords} = qq{格安,旅行,ツアー,激安ツアー,楽天トラベル};
	$self->{html_description} = qq{格安ツアーや激安ツアーを楽天トラベルの情報からエリア検索できる携帯旅行検索エンジン。};

	&html_header($self);

	&html_table($self, qq{<h2><font size=1 color="#FF0000">格安旅行ツアー検索</font></h2>}, 1, 0);

print << "END_OF_HTML";
$dsp_str
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/rakutentravel/">楽天トラベルプラス</a>&gt;<strong>エリア検索</strong><br>
<font size=1 color="#AAAAAA">格安旅行ツアー検索プラスの㌻は、旅行情報をマルチに検索できるトラベル検索サイトです。<br>
<a href="http://webservice.rakuten.co.jp/" target="_blank">Supported by 楽天ウェブサービス</a><br>
END_OF_HTML

	&html_footer($self);

	return;
}


sub _area_small(){
	my $self = shift;
	my $middlecode = $self->{cgi}->param('p1');

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);

	my $dsp_str;
	my $sth;
	my $middlename;
	$sth = $self->{dbi}->prepare(qq{ select middle, middlename, small, smallname from rakutenarea where  middle = ? } );
	$sth->execute($middlecode);
	while(my @row = $sth->fetchrow_array) {
		$middlename = $row[1];
		$dsp_str .= qq{<font color="#009525">》</font><a href="/list-area/rakutentravel/-$row[0]-$row[2]/">$row[3]</a><br>};
	}

	$self->{html_title} = qq{$middlenameの格安旅行ツアーエリア検索 -みんなの楽天トラベルプラス-};
	$self->{html_keywords} = qq{格安,旅行,ツアー,激安ツアー,楽天トラベル,$middlename};
	$self->{html_description} = qq{格安ツアーや激安ツアーを楽天トラベルの情報からエリア検索できる携帯旅行検索エンジン。};

	&html_header($self);

	&html_table($self, qq{<h1>$middlename</h1><h2><font size=1 color="#FF0000">格安旅行ツアー検索</font></h2>}, 1, 0);

print << "END_OF_HTML";
$dsp_str
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/rakutentravel/">楽天トラベルプラス</a>&gt;<a href="/list-middle/rakutentravel/">全国</a>&gt;<strong>$middlename</strong><br>
<font size=1 color="#AAAAAA">$middlenameの格安旅行ツアー検索プラスの㌻は、旅行情報をマルチに検索できるトラベル検索サイトです。<br>
<a href="http://webservice.rakuten.co.jp/" target="_blank">Supported by 楽天ウェブサービス</a><br>
END_OF_HTML

	&html_footer($self);

	return;
}

1;