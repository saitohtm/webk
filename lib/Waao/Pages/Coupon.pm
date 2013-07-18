package Waao::Pages::Coupon;
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


# /coupon/		topページ
# /keyword/coupon/ キーワード検索
# /keyword/coupon/pageno/ キーワード検索
# /list-area/coupon/	エリア選択
# /list-pref/coupon/areacode	
# /list-city/coupon/prefcode	


sub dispatch(){
	my $self = shift;
	
	if($self->{cgi}->param('q') eq 'list-area'){
		&_area_search($self);
	}elsif($self->{cgi}->param('q') eq 'list-detail'){
		&_detail($self);
	}elsif($self->{cgi}->param('q') eq 'list-coupon'){
		&_search_coupon($self);
	}elsif($self->{cgi}->param('q') eq 'list-store'){
		&_search_store($self);
	}elsif($self->{cgi}->param('q')){
		&_search_store2($self);
	}else{
		&_top($self);
	}

	return;
}

sub _top(){
	my $self = shift;

	$self->{html_title} = qq{クーポン検索プラス お得な割引クーポン検索};
	$self->{html_keywords} = qq{クーポン,割引,検索,広告};
	$self->{html_description} = qq{クーポン検索プラス！携帯クーポンを探すならクーポン検索プラス};

	my $hr = &html_hr($self,1);	
	&html_header($self);

if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML
	
}else{# xhmlt chtml

print << "END_OF_HTML";
<center>
<img src="http://img.waao.jp/coupon.gif" width=120 height=28 alt="クーポン検索プラス"><font size=1 color="#FF0000">プラス</font>
</center>
<center>
<form action="/coupon.html" method="POST" ><input type="text" name="q" value="" size="20"><input type="hidden" name="guid" value="ON">
<br />
<input type="submit" value="クーポン検索プラス"><br />
</form>
</center>
<center>
<font size=1>クチコミ情報満載<font color="#FF0000">マルチ検索</font></font>
</center>
$hr

<a href="/list-area/coupon/" accesskey=1>エリア別検索</a><br>
<a href="/coupon_mac/" accesskey=2>マクドナルドクーポン</a><br>
<!--
<a href="/list-genre/mansion/" accesskey=3>ジャンル別検索</a><br>
<a href="/list-special/mansion/" accesskey=4>オススメ特集</a><br>
<a href="" accesskey=5></a><br>
<a href="" accesskey=6></a><br>
<a href="" accesskey=7></a><br>
<a href="" accesskey=8></a><br>
<a href="" accesskey=9></a><br>
-->
$hr
偂<a href="http://waao.jp/list-in/ranking/11/">みんなのランキング</a><br>
<a href="/" accesskey=0>トップ</a>&gt;<strong>クーポン検索プラス</strong><br>
<font size=1 color="#E9E9E9">クーポン検索プラスは,お得な割引クーポン情報を中心とした情報が検索できる携帯サイトです。<br>
Powered by <a href="http://webservice.recruit.co.jp/">タウンマーケット Webサービス</a>
END_OF_HTML

}
	&html_footer($self);

	return;
}
sub _search_store2(){
	my $self = shift;
	
	my ($keyword, $keyword_encode, $keyword_utf8);
	unless($self->{cgi}->param('q') =~/list/){
		$keyword = $self->{cgi}->param('q');
		$keyword_encode = &str_encode($keyword);
		$keyword_utf8 = $keyword;
		Encode::from_to($keyword_utf8,'cp932','utf8');
		$keyword_utf8 = escape ( $keyword_utf8 );
	}
	my ($store, $business_type, $start);
	my ($area, $pref, $city);
	my @areas = split(/-/,$self->{cgi}->param('p1'));
	($pref, $city) = @areas;

	$self->{html_title} = qq{$keyword クーポン検索プラス：お得な割引クーポン検索プラス};
	$self->{html_keywords} = qq{$keyword,市区町村選択,クーポン,割引,探す,掲示板};
	$self->{html_description} = qq{お得な割引クーポンを検討するなら、まずは、場所からクチコミ掲示板付のマンション検索プラス！};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);
	
print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

	# スタート
	my $start;
	if($self->{cgi}->param('p2')){
		$start = 1 + 5 * $self->{cgi}->param('p2');
	}
	my $nextpage = 1;
	if($self->{cgi}->param('p2')){
		$nextpage = $self->{cgi}->param('p2') + 1;
	}
	my $p2dummy = qq{aa};
	$p2dummy = $self->{cgi}->param('p1') if($self->{cgi}->param('p1'));
	my $nexturl = qq{/}.&str_encode($self->{cgi}->param('q')).qq{/coupon/$p2dummy/$nextpage/};

	my %api_params   = (
    "keyword"     => $keyword_utf8,
	"start"          => $start,
    "count"			 => 5
    
);
	# リクエストURL生成
	my $api_url = qq{http://webservice.recruit.co.jp/townmarket/store/v1/?key=9a62bda886ec7031};
	# APIのクエリ生成
	while ( my ( $key, $value ) = each ( %api_params ) ) {
		next unless($value);
        $api_url = sprintf("%s&%s=%s",$api_url, $key, $api_params{$key});
	}
	
	my $response = get($api_url);	
	my $xml = new XML::Simple;
	my $xml_val = $xml->XMLin($response);

	foreach my $name (%{$xml_val->{store}}) {
		my $result = $xml_val->{store}->{$name};
		my ($storeid, $storename, $zip, $address, $closed, $store_hours);
	
eval{
	
		# 店舗情報
		$storeid = $result->{code};
		$storename = Jcode->new($name, 'utf8')->sjis;
		$zip = $result->{zip};
		$address = Jcode->new($result->{address}, 'utf8')->sjis;
		$store_hours = Jcode->new($result->{store_hours}, 'utf8')->sjis;
		$closed = Jcode->new($result->{closed}, 'utf8')->sjis;

};
next unless($storeid);
print << "END_OF_HTML";
<a href="/list-store/coupon/$storeid/">$storename</a><br>
$zip<br>
$address<br>
$closed<br>
営業時間:$store_hours<br>
$hr
END_OF_HTML
	}

print << "END_OF_HTML";
<div align=right><img src="http://img.waao.jp/m2028.gif" width=48 height=9><a href="$nexturl">次の㌻</a></div>
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/coupon/">クーポン検索プラス</a>&gt;<strong>$keyword</strong><br>
<font size=1 color="#E9E9E9">クーポン検索プラスは,お得な割引クーポン情報を中心とした情報が検索できる携帯サイトです。<br>
Powered by <a href="http://webservice.recruit.co.jp/">タウンマーケット Webサービス</a>
END_OF_HTML
	&html_footer($self);

	
	return;
}

sub _search_store(){
	my $self = shift;
	
	my $store_id = $self->{cgi}->param('p1');

	my $hr = &html_hr($self,1);	

	# スタート
	my $start;
	if($self->{cgi}->param('p2')){
		$start = 1 + 5 * $self->{cgi}->param('p2');
	}
	my $nextpage = 1;
	if($self->{cgi}->param('p2')){
		$nextpage = $self->{cgi}->param('p2') + 1;
	}
	my $p2dummy = qq{aa};
	$p2dummy = $self->{cgi}->param('p1') if($self->{cgi}->param('p1'));
	my $nexturl = qq{/}.&str_encode($self->{cgi}->param('q')).qq{/coupon/$p2dummy/$nextpage/};

	my %api_params   = (
    "code"        => $store_id,
	"start"          => $start,
    "count"			 => 5
    
);
	# リクエストURL生成
	my $api_url = qq{http://webservice.recruit.co.jp/townmarket/store/v1/?key=9a62bda886ec7031};
	# APIのクエリ生成
	while ( my ( $key, $value ) = each ( %api_params ) ) {
		next unless($value);
        $api_url = sprintf("%s&%s=%s",$api_url, $key, $api_params{$key});
	}
	
	my $response = get($api_url);	
	my $xml = new XML::Simple;
	my $xml_val = $xml->XMLin($response);

	my $result = $xml_val->{store};
	my ($id, $name, $start_date, $end_date, $catch_copy, $img);
	my ($storeid, $storename, $zip, $address, $closed, $store_hours);
	
eval{
		# 店舗情報
		$storename = Jcode->new($result->{name}, 'utf8')->sjis;
		$zip = $result->{store}->{zip};
		$address = Jcode->new($result->{address}, 'utf8')->sjis;
		$store_hours = Jcode->new($result->{store_hours}, 'utf8')->sjis;
		$closed = Jcode->new($result->{closed}, 'utf8')->sjis;
		

};

if($img=~/HASH/){
	$img = qq{http://img.waao.jp/noimage75.gif};
}

	$self->{html_title} = qq{$storename：お得な割引クーポン検索プラス};
	$self->{html_keywords} = qq{$storename,市区町村選択,クーポン,割引,探す,掲示板};
	$self->{html_description} = qq{お得な割引クーポンを検討するなら、まずは、場所からクチコミ掲示板付のクーポン検索プラス！};

	&html_header($self);
	my $ad = &html_google_ad($self);
	
print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

print << "END_OF_HTML";
$storename<br>
$zip<br>
$address<br>
$closed<br>
営業時間:$store_hours<br>
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/coupon/">クーポン検索プラス</a>&gt;<strong>$storename</strong><br>
<font size=1 color="#E9E9E9">クーポン検索プラスは,お得な割引クーポン情報を中心とした情報が検索できる携帯サイトです。<br>
Powered by <a href="http://webservice.recruit.co.jp/">タウンマーケット Webサービス</a>
END_OF_HTML
	&html_footer($self);

	
	return;
}


sub _search_coupon(){
	my $self = shift;
	
	my ($store, $business_type, $start);
	my ($area, $pref, $city);
	my @areas = split(/-/,$self->{cgi}->param('p1'));
	($pref, $city) = @areas;

	$self->{html_title} = qq{クーポン検索プラス：お得な割引クーポン検索プラス};
	$self->{html_keywords} = qq{市区町村選択,クーポン,割引,探す,掲示板};
	$self->{html_description} = qq{お得な割引クーポンを検討するなら、まずは、場所からクチコミ掲示板付のマンション検索プラス！};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);
	
print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

	# スタート
	my $start;
	if($self->{cgi}->param('p2')){
		$start = 1 + 5 * $self->{cgi}->param('p2');
	}
	my $nextpage = 1;
	if($self->{cgi}->param('p2')){
		$nextpage = $self->{cgi}->param('p2') + 1;
	}
	my $p2dummy = qq{aa};
	$p2dummy = $self->{cgi}->param('p1') if($self->{cgi}->param('p1'));
	my $nexturl = qq{/}.&str_encode($self->{cgi}->param('q')).qq{/coupon/$p2dummy/$nextpage/};

	my %api_params   = (
    "store"        => $store,
    "city"           => $city,
    "business_type"  => $business_type,
	"start"          => $start,
    "count"			 => 5
    
);
	# リクエストURL生成
	my $api_url = qq{http://webservice.recruit.co.jp/townmarket/insertion/v1/?key=9a62bda886ec7031};
	# APIのクエリ生成
	while ( my ( $key, $value ) = each ( %api_params ) ) {
		next unless($value);
        $api_url = sprintf("%s&%s=%s",$api_url, $key, $api_params{$key});
	}
	
	my $response = get($api_url);	
	my $xml = new XML::Simple;
	my $xml_val = $xml->XMLin($response);

	foreach my $result (@{$xml_val->{insertion}}) {

	my ($id, $name, $start_date, $end_date, $catch_copy, $img);
	my ($storeid, $storename, $zip, $address, $closed, $store_hours);
	
eval{
		$id = $result->{code};
		$start_date = $result->{start_date};
		$end_date = $result->{end_date};
		$catch_copy = Jcode->new($result->{catch_copy}, 'utf8')->sjis;
		$img = $result->{preview_url};
		
		# 店舗情報
		$storeid = $result->{store}->{code};
		$storename = Jcode->new($result->{store}->{name}, 'utf8')->sjis;
		$zip = $result->{store}->{zip};
		$address = Jcode->new($result->{store}->{address}, 'utf8')->sjis;
		$store_hours = Jcode->new($result->{store}->{store_hours}, 'utf8')->sjis;
		$closed = Jcode->new($result->{store}->{closed}, 'utf8')->sjis;
		

};

if($img=~/HASH/){
	$img = qq{http://img.waao.jp/noimage75.gif};
}

print << "END_OF_HTML";
<font size=1 color="#FF0000">●</font><font size=1><a href="/list-detail/coupon/$id/">$catch_copy </a></font><br>
<img src="$img" alt="$catch_copy" style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left">
<font size=1>
期間:$start_date〜$end_date<br>
<a href="/list-store/coupon/$storeid/">$storename</a><br>
$zip<br>
$address<br>
$closed<br>
営業時間:$store_hours<br>
</font>
<br clear="all" />
$hr
END_OF_HTML
	}

print << "END_OF_HTML";
<div align=right><img src="http://img.waao.jp/m2028.gif" width=48 height=9><a href="$nexturl">次の㌻</a></div>
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/coupon/">クーポン検索プラス</a>&gt;<strong>エリア選択</strong><br>
<font size=1 color="#E9E9E9">クーポン検索プラスは,お得な割引クーポン情報を中心とした情報が検索できる携帯サイトです。<br>
Powered by <a href="http://webservice.recruit.co.jp/">タウンマーケット Webサービス</a>
END_OF_HTML
	&html_footer($self);

	
	return;
}

sub _area_search(){
	my $self = shift;
	
	my ($area, $pref, $city);
	my @areas = split(/-/,$self->{cgi}->param('p1'));
	($pref, $city) = @areas;

	if($city){
		&_search($self);
	}elsif($pref){
		&_city_select($self);
	}else{
		&_pref_select($self);
	}
	
	return;
}

sub _city_select(){
	my $self = shift;
	my @areas = split(/-/,$self->{cgi}->param('p1'));
	my ($pref, $city) = @areas;

	$self->{html_title} = qq{市区町村選択：お得な割引クーポン検索プラス};
	$self->{html_keywords} = qq{市区町村選択,クーポン,割引,探す,掲示板};
	$self->{html_description} = qq{お得な割引クーポンを検討するなら、まずは、場所からクチコミ掲示板付のマンション検索プラス！};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);

&html_table($self, qq{市区町村選択}, 0, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

my $sth = $self->{dbi}->prepare( qq{select code, name, pref_code, pref_name from tmk_city where pref_code = ? } );
$sth->execute($pref);
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<font color="#009525">》</font><a href="/list-coupon/coupon/$row[2]-$row[0]/">$row[1]</a><br>
END_OF_HTML
}
	
print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/coupon/">クーポン検索プラス</a>&gt;<strong>エリア選択</strong><br>
<font size=1 color="#E9E9E9">クーポン検索プラスは,お得な割引クーポン情報を中心とした情報が検索できる携帯サイトです。<br>
Powered by <a href="http://webservice.recruit.co.jp/">タウンマーケット Webサービス</a>
END_OF_HTML

	&html_footer($self);

	return;
}


sub _pref_select(){
	my $self = shift;
	my @areas = split(/-/,$self->{cgi}->param('p1'));
	my ($pref, $city) = @areas;

	$self->{html_title} = qq{エリア選択：割引お得なクーポン検索プラス};
	$self->{html_keywords} = qq{エリア選択,クーポン,広告,割引,掲示板};
	$self->{html_description} = qq{割引お得なクーポンを探すなら、まずは、場所から！};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);

&html_table($self, qq{エリア選択}, 0, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

my $sth = $self->{dbi}->prepare( qq{select code, name from tmk_pref } );
$sth->execute();
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<font color="#009525">》</font><a href="/list-area/coupon/$row[0]-/">$row[1]</a><br>
END_OF_HTML
}
	
print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/coupon/">クーポン検索プラス</a>&gt;<strong>エリア選択</strong><br>
<font size=1 color="#E9E9E9">クーポン検索プラスは,お得な割引クーポン情報を中心とした情報が検索できる携帯サイトです。<br>
Powered by <a href="http://webservice.recruit.co.jp/">タウンマーケット Webサービス</a>
END_OF_HTML

	&html_footer($self);

	return;
}


sub _detail(){
	my $self = shift;
	my $mansionid = $self->{cgi}->param('p1');

	my %api_params   = (
    "apartment"      => $self->{cgi}->param('p1'),
#    "apartment_type" => $self->{cgi}->param('apartment_type'),
#    "price_mitei"    => $self->{cgi}->param('price_mitei'),
#    "price_min"      => $self->{cgi}->param('price_min'),
#    "price_max"      => $self->{cgi}->param('price_max'),
#    "madori"         => $self->{cgi}->param('madori'),
#    "access"         => $self->{cgi}->param('access'),
#    "year_built"     => $self->{cgi}->param('year_built'),
#    "newly"          => $self->{cgi}->param('newly'),
#    "order"          => $self->{cgi}->param('order'),
	"start"          => 1,
    "count"			 => 1
    
);
	# リクエストURL生成
	my $api_url = qq{http://api.smatch.jp/apartment/?key=9a62bda886ec7031};
	# APIのクエリ生成
	while ( my ( $key, $value ) = each ( %api_params ) ) {
		next unless($value);
        $api_url = sprintf("%s&%s=%s",$api_url, $key, $api_params{$key});
	}

	my ($id,$img, $address, $toho, $price, $year_built, $shubetu, $pref_link, $city_link, $line_link, $station_link, $title);
	my ($madori, $urinushi, $sokosu, $room_size, $link_mobile, $name);
	my $hr = &html_hr($self,1);	

	my $response = get($api_url);	
	my $xml = new XML::Simple;
	my $xml_val = $xml->XMLin($response);

	
eval{
		$name = Jcode->new($xml_val->{apartment}->{name}, 'utf8')->sjis;
		$title = $name;
		$id = $xml_val->{apartment}->{id};
		$img = $xml_val->{apartment}->{simple_image};
		$address = Jcode->new($xml_val->{apartment}->{address}, 'utf8')->sjis;
		$toho = Jcode->new($xml_val->{apartment}->{toho}, 'utf8')->sjis;
		$price = Jcode->new($xml_val->{apartment}->{price}, 'utf8')->sjis;
		$year_built = Jcode->new($xml_val->{apartment}->{year_built}, 'utf8')->sjis;
		$shubetu = Jcode->new($xml_val->{apartment}->{shubetu}, 'utf8')->sjis;
		$madori = Jcode->new($xml_val->{apartment}->{madori}, 'utf8')->sjis;
		$urinushi = Jcode->new($xml_val->{apartment}->{urinushi}->{name}, 'utf8')->sjis;
		$sokosu = Jcode->new($xml_val->{apartment}->{sokosu}, 'utf8')->sjis;
		$room_size = Jcode->new($xml_val->{apartment}->{room_size}, 'utf8')->sjis;
		$link_mobile = $xml_val->{apartment}->{link_mobile};
		# エリア情報+リンク
		my $area_code = $xml_val->{apartment}->{area}->{code};
		my $area_name = Jcode->new($xml_val->{apartment}->{area}->{name}, 'utf8')->sjis;
		my $area_link = qq{<a href="/list-area/mansion/$area_code--/">$area_name</a>};
		my $pref_code = $xml_val->{apartment}->{pref}->{code};
		my $pref_name = Jcode->new($xml_val->{apartment}->{pref}->{name}, 'utf8')->sjis;
		$pref_link = qq{<a href="/list-area/mansion/$area_code-$pref_code-/">$pref_name</a>};
		my $city_code = $xml_val->{apartment}->{city}->{code};
		my $city_name = Jcode->new($xml_val->{apartment}->{city}->{name}, 'utf8')->sjis;
		$city_link = qq{<a href="/list-area/mansion/$area_code-$pref_code-$city_code/">$city_name</a>};
		
		# 駅情報+リンク
		my $line_area_code = $xml_val->{apartment}->{line_area}->{code};
		my $line_area_name = Jcode->new($xml_val->{apartment}->{line_area}->{name}, 'utf8')->sjis;
		my $line_area_link = qq{<a href="/list-line/mansion/$line_area_code--/">$line_area_name</a>};
		my $line_code = $xml_val->{apartment}->{line}->{code};
		my $line_name = Jcode->new($xml_val->{apartment}->{line}->{name}, 'utf8')->sjis;
		$line_link = qq{<a href="/list-line/mansion/$line_area_code-$line_code-/">$line_name</a>};
		my $station_code = $xml_val->{apartment}->{station}->{code};
		my $station_name = Jcode->new($xml_val->{apartment}->{station}->{name}, 'utf8')->sjis;
		$station_link = qq{<a href="/list-line/mansion/$line_area_code-$line_code-$station_code/">$station_name</a>};
};

my $pricestr;
if($price){
	$pricestr = qq{巐$price<br>};
}else{
	$pricestr = qq{};
}
my $stationstr;
if($station_link){
	$stationstr = qq{$line_link $station_link<br>};
}else{
	$stationstr = qq{};
}
if($img=~/HASH/){
	$img = qq{http://img.waao.jp/noimage75.gif};
}

	# キーワード検索
	$self->{html_title} = qq{$name $address マンション情報(新築・中古)};
	$self->{html_keywords} = qq{$name,マンション,購入,探す,掲示板,新築,中古};
	$self->{html_description} = qq{$name($address)の新築・中古マンション購入を検討中なら、まずは、クチコミ掲示板付のマンション検索プラス！};

	&html_header($self);
	my $ad = &html_google_ad($self);
	&html_table($self, qq{$name}, 0, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

print << "END_OF_HTML";
<font size=1 color="#FF0000">●</font><font size=1><a href="$link_mobile">$title </a></font><br>
<img src="$img" alt="$title" style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left">
<font size=1>
$shubetu($year_built)<br>
$pricestr
$address<br>
$toho<br>
$stationstr
$pref_link $city_link<br>
</font>
<br clear="all" />
間取り：$madori <br>
売主:$urinushi <br>
総個数:$sokosu <br>
床面積:$room_size <br>
<a href="$link_mobile">詳細を見る</a>
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/mansion/">マンション購入検索プラス</a>&gt;<strong>$name</strong><br>
<font size=1 color="#E9E9E9">マンション購入検索プラスは,$nameマンションの購入をお考えの方向けにコミュニティ掲示板を中心としたマンション購入検討情報が検索できる携帯サイトです。<br>
Powered by <a href="http://webservice.recruit.co.jp/">スマッチ！ Webサービス</a>
END_OF_HTML
	&html_footer($self);

	
	return;
}

1;
