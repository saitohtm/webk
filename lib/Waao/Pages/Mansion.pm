package Waao::Pages::Mansion;
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


# /smatch/		topページ
# /keyword/mansion/ キーワード検索
# /keyword/mansion/pageno/ キーワード検索
# /list-area/mansion/	エリア選択
# /list-pref/mansion/areacode	
# /list-city/mansion/prefcode	


sub dispatch(){
	my $self = shift;
	
	if($self->{cgi}->param('q') eq 'list-area'){
		&_area_search($self);
	}elsif($self->{cgi}->param('q') eq 'list-line'){
		&_line_search($self);
	}elsif($self->{cgi}->param('q') eq 'list-detail'){
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

	$self->{html_title} = qq{マンション購入のためのマンション検索プラス};
	$self->{html_keywords} = qq{マンション,購入,探す,掲示板};
	$self->{html_description} = qq{マンション購入を検討するなら、クチコミ掲示板付のマンション検索プラス！};

	my $hr = &html_hr($self,1);	
	&html_header($self);

if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML
	
}else{# xhmlt chtml

print << "END_OF_HTML";
<center>
<img src="http://img.waao.jp/mansionlogo.gif" width=120 height=28 alt="マンション購入プラス"><font size=1 color="#FF0000">プラス</font>
</center>
<center>
<form action="/mansion.html" method="POST" ><input type="text" name="q" value="" size="20"><input type="hidden" name="guid" value="ON">
<br />
<input type="submit" value="マンション検索プラス"><br />
</form>
</center>
<center>
<font size=1>クチコミ情報満載<font color="#FF0000">マルチ検索</font></font>
</center>
$hr

<a href="/list-area/mansion/" accesskey=1>エリア別検索</a><br>
<a href="/list-line/mansion/" accesskey=2>路線検索</a><br>
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
偂<a href="http://waao.jp/list-in/ranking/9/">みんなのランキング</a><br>
<a href="/" accesskey=0>トップ</a>&gt;<strong>マンション購入検索プラス</strong><br>
<font size=1 color="#E9E9E9">マンション購入検索プラスは,マンションの購入をお考えの方向けにコミュニティ掲示板を中心としたマンション購入検討情報が検索できる携帯サイトです。<br>
Powered by <a href="http://webservice.recruit.co.jp/">スマッチ！ Webサービス</a>
END_OF_HTML

}
	&html_footer($self);

	return;
}

sub _search(){
	my $self = shift;
	
	# キーワード検索
	my ($keyword, $keyword_encode, $keyword_utf8);
	unless($self->{cgi}->param('q') =~/list/){
		$keyword = $self->{cgi}->param('q');
		$keyword_encode = &str_encode($keyword);
		$keyword_utf8 = $keyword;
		Encode::from_to($keyword_utf8,'cp932','utf8');
		$keyword_utf8 = escape ( $keyword_utf8 );
	}
	
	my ($area, $pref, $city, $line_area, $line, $station);
	my ($area_name, $pref_name, $city_name, $line_area_name, $line_name, $station_name);
	if($self->{cgi}->param('q') eq 'list-area'){
		my @areas = split(/-/,$self->{cgi}->param('p1'));
		($area, $pref, $city) = @areas;
		my $sth = $self->{dbi}->prepare( qq{select area_name, pref_name, name from smc_city where code = ? } );
		$sth->execute($city);
		while(my @row = $sth->fetchrow_array) {
			($area_name, $pref_name, $city_name) = @row;
		}
		$self->{html_title} = qq{$city_nameのマンション情報(新築・中古)：マンション購入のためのマンション検索プラス};
		$self->{html_keywords} = qq{$city_name,マンション,購入,探す,掲示板,新築,中古};
		$self->{html_description} = qq{$city_nameの新築・中古マンション購入を検討中なら、まずは、クチコミ掲示板付のマンション検索プラス！};
	}elsif($self->{cgi}->param('q') eq 'list-line'){
		my @lines = split(/-/,$self->{cgi}->param('p1'));
		($line_area, $line, $station) = @lines;
		my $sth = $self->{dbi}->prepare( qq{select line_area_name, line_name, name from smc_city where code = ? } );
		$sth->execute($station);
		while(my @row = $sth->fetchrow_array) {
			($line_area_name, $line_name, $station_name) = @row;
		}
		$self->{html_title} = qq{$station_name駅周辺のマンション情報(新築・中古)：マンション購入のためのマンション検索プラス};
		$self->{html_keywords} = qq{$station_name,$line_name,最寄り駅,マンション,購入,探す,掲示板,新築,中古};
		$self->{html_description} = qq{$line_name $station_name駅周辺の新築・中古マンション購入を検討中なら、まずは、クチコミ掲示板付のマンション検索プラス！};
	}else{
		$self->{html_title} = qq{$keyword マンション情報(新築・中古)：マンション購入のためのマンション検索プラス};
		$self->{html_keywords} = qq{$keyword,最寄り駅,マンション,購入,探す,掲示板,新築,中古};
		$self->{html_description} = qq{$keyword の新築・中古マンション購入を検討中なら、まずは、クチコミ掲示板付のマンション検索プラス！};
	}

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);

	if($self->{cgi}->param('q') eq 'list-area'){
		&html_table($self, qq{<strong>$city_nameのマンション</strong>}, 0, 0);
	}elsif($self->{cgi}->param('q') eq 'list-line'){
		&html_table($self, qq{<strong>$station_name 駅周辺のマンション</strong>}, 0, 0);
	}else{
		&html_table($self, qq{<strong>$keyword</strong>の検索結果}, 0, 0);
	}
	
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
	my $nexturl = qq{/}.&str_encode($self->{cgi}->param('q')).qq{/mansion/$p2dummy/$nextpage/};

	my %api_params   = (
    "keyword"        => $keyword_utf8,
    "area"           => $area,
    "pref"           => $pref,
    "city"           => $city,
    "line_area"      => $line_area,
    "line"           => $line,
    "station"        => $station,
#    "apartment"      => $self->{cgi}->param('apartment'),
#    "apartment_type" => $self->{cgi}->param('apartment_type'),
#    "price_mitei"    => $self->{cgi}->param('price_mitei'),
#    "price_min"      => $self->{cgi}->param('price_min'),
#    "price_max"      => $self->{cgi}->param('price_max'),
#    "madori"         => $self->{cgi}->param('madori'),
#    "access"         => $self->{cgi}->param('access'),
#    "year_built"     => $self->{cgi}->param('year_built'),
#    "newly"          => $self->{cgi}->param('newly'),
#    "order"          => $self->{cgi}->param('order'),
	"start"          => $start,
    "count"			 => 5
    
);
	# リクエストURL生成
	my $api_url = qq{http://api.smatch.jp/apartment/?key=9a62bda886ec7031};
	# APIのクエリ生成
	while ( my ( $key, $value ) = each ( %api_params ) ) {
		next unless($value);
        $api_url = sprintf("%s&%s=%s",$api_url, $key, $api_params{$key});
	}

	
	my $response = get($api_url);	
	my $xml = new XML::Simple;
	my $xml_val = $xml->XMLin($response);
	foreach my $name (keys %{$xml_val->{apartment}}) {


	my ($id,$img, $address, $toho, $price, $year_built, $shubetu, $pref_link, $city_link, $line_link, $station_link, $title);
	
eval{
		$title = Jcode->new($name, 'utf8')->sjis;
		$id = $xml_val->{apartment}->{$name}->{id};
		$img = $xml_val->{apartment}->{$name}->{simple_image};
		$address = Jcode->new($xml_val->{apartment}->{$name}->{address}, 'utf8')->sjis;
		$toho = Jcode->new($xml_val->{apartment}->{$name}->{toho}, 'utf8')->sjis;
		$price = Jcode->new($xml_val->{apartment}->{$name}->{price}, 'utf8')->sjis;
		$year_built = Jcode->new($xml_val->{apartment}->{$name}->{year_built}, 'utf8')->sjis;
		$shubetu = Jcode->new($xml_val->{apartment}->{$name}->{shubetu}, 'utf8')->sjis;

		# エリア情報+リンク
		my $area_code = $xml_val->{apartment}->{$name}->{area}->{code};
		my $area_name = Jcode->new($xml_val->{apartment}->{$name}->{area}->{name}, 'utf8')->sjis;
		my $area_link = qq{<a href="/list-area/mansion/$area_code--/">$area_name</a>};
		my $pref_code = $xml_val->{apartment}->{$name}->{pref}->{code};
		my $pref_name = Jcode->new($xml_val->{apartment}->{$name}->{pref}->{name}, 'utf8')->sjis;
		$pref_link = qq{<a href="/list-area/mansion/$area_code-$pref_code-/">$pref_name</a>};
		my $city_code = $xml_val->{apartment}->{$name}->{city}->{code};
		my $city_name = Jcode->new($xml_val->{apartment}->{$name}->{city}->{name}, 'utf8')->sjis;
		$city_link = qq{<a href="/list-area/mansion/$area_code-$pref_code-$city_code/">$city_name</a>};
		
		# 駅情報+リンク
		my $line_area_code = $xml_val->{apartment}->{$name}->{line_area}->{code};
		my $line_area_name = Jcode->new($xml_val->{apartment}->{$name}->{line_area}->{name}, 'utf8')->sjis;
		my $line_area_link = qq{<a href="/list-line/mansion/$line_area_code--/">$line_area_name</a>};
		my $line_code = $xml_val->{apartment}->{$name}->{line}->{code};
		my $line_name = Jcode->new($xml_val->{apartment}->{$name}->{line}->{name}, 'utf8')->sjis;
		$line_link = qq{<a href="/list-line/mansion/$line_area_code-$line_code-/">$line_name</a>};
		my $station_code = $xml_val->{apartment}->{$name}->{station}->{code};
		my $station_name = Jcode->new($xml_val->{apartment}->{$name}->{station}->{name}, 'utf8')->sjis;
		$station_link = qq{<a href="/list-line/mansion/$line_area_code-$line_code-$station_code/">$station_name</a>};
		$name = Jcode->new($name, 'utf8')->sjis;
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

print << "END_OF_HTML";
<font size=1 color="#FF0000">●</font><font size=1><a href="/list-detail/mansion/$id/">$title </a></font><br>
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
$hr
END_OF_HTML
	}

print << "END_OF_HTML";
<div align=right><img src="http://img.waao.jp/m2028.gif" width=48 height=9><a href="$nexturl">の㌻</a></div>
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/mansion/">マンション購入検索プラス</a>&gt;<strong>$city_name$station_name新築・中古マンション</strong><br>
<font size=1 color="#E9E9E9">マンション購入検索プラスは,$city_name$station_nameの新築・中古マンションの購入をお考えの方向けにコミュニティ掲示板を中心としたマンション購入検討情報が検索できる携帯サイトです。<br>
Powered by <a href="http://webservice.recruit.co.jp/">スマッチ！ Webサービス</a>
END_OF_HTML
	&html_footer($self);

	
	return;
}

sub _line_search(){
	my $self = shift;
	
	my ($line_area, $line, $station);
	my @lines = split(/-/,$self->{cgi}->param('p1'));
	($line_area, $line, $station) = @lines;

	if($station){
		&_search($self);
	}elsif($line){
		&_station_select($self);
	}elsif($line_area){
		&_line_select($self);
	}else{
		&_line_area_select($self);
	}
	
	return;
}

sub _station_select(){
	my $self = shift;

	my @lines = split(/-/,$self->{cgi}->param('p1'));
	my ($line_area, $line, $station) = @lines;

	$self->{html_title} = qq{最寄り駅選択：マンション購入のためのマンション検索プラス};
	$self->{html_keywords} = qq{最寄り駅選択,マンション,購入,探す,掲示板};
	$self->{html_description} = qq{マンション購入を検討するなら、まずは、最寄駅からクチコミ掲示板付のマンション検索プラス！};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);

&html_table($self, qq{最寄り駅選択}, 0, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

my $sth = $self->{dbi}->prepare( qq{select code, name,  area_code, area_name, line_code, line_name from smc_station where line_code = ? } );
$sth->execute($line);
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<font color="#009525">》</font><a href="/list-line/mansion/$line_area-$line-$row[0]/">$row[1]</a><br>
END_OF_HTML
}
	
print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/mansion/">マンション購入検索プラス</a>&gt;<a href="/list-line/mansion/$line_area--/">沿線エリア選択</a>&gt;<a href="/list-line/mansion/$line_area-$line-/">沿線選択</a>&gt;<strong>最寄り駅選択</strong><br>
<font size=1 color="#E9E9E9">マンション購入検索プラスは,マンションの購入をお考えの方向けにコミュニティ掲示板を中心としたマンション購入検討情報が検索できる携帯サイトです。<br>
Powered by <a href="http://webservice.recruit.co.jp/">スマッチ！ Webサービス</a>
END_OF_HTML

	&html_footer($self);

	return;
}


sub _line_select(){
	my $self = shift;

	my @lines = split(/-/,$self->{cgi}->param('p1'));
	my ($line_area, $line, $station) = @lines;

	$self->{html_title} = qq{沿線選択：マンション購入のためのマンション検索プラス};
	$self->{html_keywords} = qq{沿線選択,マンション,購入,探す,掲示板};
	$self->{html_description} = qq{マンション購入を検討するなら、まずは、沿線からクチコミ掲示板付のマンション検索プラス！};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);

&html_table($self, qq{沿線選択}, 0, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

my $sth = $self->{dbi}->prepare( qq{select code, name,  area_code, area_name, line_area_code, line_area_name from smc_line where line_area_code = ? } );
$sth->execute($line_area);
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<font color="#009525">》</font><a href="/list-line/mansion/$row[4]-$row[0]-/">$row[1]</a><br>
END_OF_HTML
}
	
print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/mansion/">マンション購入検索プラス</a>&gt;<a href="/list-line/mansion/$line_area--/">沿線選択</a>&gt;<strong>沿線選択</strong><br>
<font size=1 color="#E9E9E9">マンション購入検索プラスは,マンションの購入をお考えの方向けにコミュニティ掲示板を中心としたマンション購入検討情報が検索できる携帯サイトです。<br>
Powered by <a href="http://webservice.recruit.co.jp/">スマッチ！ Webサービス</a>
END_OF_HTML

	&html_footer($self);

	return;
}

sub _line_area_select(){
	my $self = shift;

	my @lines = split(/-/,$self->{cgi}->param('p1'));
	my ($line_area, $line, $station) = @lines;

	$self->{html_title} = qq{沿線選択：マンション購入のためのマンション検索プラス};
	$self->{html_keywords} = qq{沿線選択,マンション,購入,探す,掲示板};
	$self->{html_description} = qq{マンション購入を検討するなら、まずは、沿線からクチコミ掲示板付のマンション検索プラス！};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);

&html_table($self, qq{沿線選択}, 0, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

my $sth = $self->{dbi}->prepare( qq{select code, name,  area_code, area_name, link_mobile from smc_line_area } );
$sth->execute();
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<font color="#009525">》</font><a href="/list-line/mansion/$row[0]--/">$row[1]</a><br>
END_OF_HTML
}
	
print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/mansion/">マンション購入検索プラス</a>&gt;<strong>沿線選択</strong><br>
<font size=1 color="#E9E9E9">マンション購入検索プラスは,マンションの購入をお考えの方向けにコミュニティ掲示板を中心としたマンション購入検討情報が検索できる携帯サイトです。<br>
Powered by <a href="http://webservice.recruit.co.jp/">スマッチ！ Webサービス</a>
END_OF_HTML

	&html_footer($self);

	return;
}

sub _area_search(){
	my $self = shift;
	
	my ($area, $pref, $city);
	my @areas = split(/-/,$self->{cgi}->param('p1'));
	($area, $pref, $city) = @areas;

	if($city){
		&_search($self);
	}elsif($pref){
		&_city_select($self);
	}elsif($area){
		&_pref_select($self);
	}else{
		&_area_select($self);
	}
	
	return;
}

sub _city_select(){
	my $self = shift;
	my @areas = split(/-/,$self->{cgi}->param('p1'));
	my ($area, $pref, $city) = @areas;

	$self->{html_title} = qq{市区町村選択：マンション購入のためのマンション検索プラス};
	$self->{html_keywords} = qq{市区町村選択,マンション,購入,探す,掲示板};
	$self->{html_description} = qq{マンション購入を検討するなら、まずは、場所からクチコミ掲示板付のマンション検索プラス！};

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

my $sth = $self->{dbi}->prepare( qq{select code, name,  area_code, area_name, pref_code, pref_name from smc_city where area_code = ? and pref_code = ?} );
$sth->execute($area, $pref);
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<font color="#009525">》</font><a href="/list-area/mansion/$row[2]-$row[4]-$row[0]/">$row[1]</a><br>
END_OF_HTML
}
	
print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/mansion/">マンション購入検索プラス</a>&gt;<a href="/list-area/mansion/">エリア選択</a>&gt;<a href="/list-area/mansion/$area--/">都道府県選択</a>&gt;<strong>市区町村選択</strong><br>
<font size=1 color="#E9E9E9">マンション購入検索プラスは,マンションの購入をお考えの方向けにコミュニティ掲示板を中心としたマンション購入検討情報が検索できる携帯サイトです。<br>
Powered by <a href="http://webservice.recruit.co.jp/">スマッチ！ Webサービス</a>
END_OF_HTML

	&html_footer($self);

	return;
}


sub _pref_select(){
	my $self = shift;
	my @areas = split(/-/,$self->{cgi}->param('p1'));
	my ($area, $pref, $city) = @areas;

	$self->{html_title} = qq{エリア選択：マンション購入のためのマンション検索プラス};
	$self->{html_keywords} = qq{エリア選択,マンション,購入,探す,掲示板};
	$self->{html_description} = qq{マンション購入を検討するなら、まずは、場所からクチコミ掲示板付のマンション検索プラス！};

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

my $sth = $self->{dbi}->prepare( qq{select code, name,  area_code, area_name, link_mobile from smc_pref where area_code = ? } );
$sth->execute($area);
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<font color="#009525">》</font><a href="/list-area/mansion/$row[2]-$row[0]-/">$row[1]</a><br>
END_OF_HTML
}
	
print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/mansion/">マンション購入検索プラス</a>&gt;<a href="/list-area/mansion/">エリア選択</a>&gt;<strong>都道府県選択</strong><br>
<font size=1 color="#E9E9E9">マンション購入検索プラスは,マンションの購入をお考えの方向けにコミュニティ掲示板を中心としたマンション購入検討情報が検索できる携帯サイトです。<br>
Powered by <a href="http://webservice.recruit.co.jp/">スマッチ！ Webサービス</a>
END_OF_HTML

	&html_footer($self);

	return;
}

sub _area_select(){
	my $self = shift;
	my @areas = split(/-/,$self->{cgi}->param('p1'));
	my ($area, $pref, $city) = @areas;

	$self->{html_title} = qq{エリア選択：マンション購入のためのマンション検索プラス};
	$self->{html_keywords} = qq{エリア選択,マンション,購入,探す,掲示板};
	$self->{html_description} = qq{マンション購入を検討するなら、まずは、場所からクチコミ掲示板付のマンション検索プラス！};

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

	my $url= qq{http://api.smatch.jp/area/?key=9a62bda886ec7031};
	my $response = get($url);	
	my $xml = new XML::Simple;
	my $xml_val = $xml->XMLin($response);
	foreach my $name (keys %{$xml_val->{area}}) {
		my $code = $xml_val->{area}->{$name}->{code};
		my $name = Jcode->new($name, 'utf8')->sjis;
print << "END_OF_HTML";
<font color="#009525">》</font><a href="/list-area/mansion/$code--/">$name</a><br>
END_OF_HTML
	}
	
print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/mansion/">マンション購入検索プラス</a>&gt;<strong>エリア選択</strong><br>
<font size=1 color="#E9E9E9">マンション購入検索プラスは,マンションの購入をお考えの方向けにコミュニティ掲示板を中心としたマンション購入検討情報が検索できる携帯サイトです。<br>
Powered by <a href="http://webservice.recruit.co.jp/">スマッチ！ Webサービス</a>
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
