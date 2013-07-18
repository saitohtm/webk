package Waao::Pages::HotPepper;
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


# /hotpepper/		topページ
# /keyword/hotpepper/shop|food/	キーワード検索
# /keyword/hotpepper/shop|food/pageno/	ページ

# /list-area/hotpepper/<エリアコード>/pageno/

# /list-food/hotpepper/

# /list-genre/hotpepper/

# /list-special/hotpepper/

#/list-shop-search/hotpepper/id/
#/list-area-search/hotpepper/areacode-/
sub dispatch(){
	my $self = shift;
	
	if($self->{cgi}->param('q') eq 'list-area'){
		&_area_select($self);
	}elsif( $self->{cgi}->param('q') eq 'list-food' ){
		&_food_select($self);
	}elsif( $self->{cgi}->param('q') eq 'list-genre' ){
		&_genre_select($self);
	}elsif( $self->{cgi}->param('q') eq 'list-shop-search' ){
		&_shop_search($self);
	}elsif( $self->{cgi}->param('q') eq 'list-area-search' ){
		&_area_search($self);
	}elsif( $self->{cgi}->param('q') eq 'list-special-search' ){
		&_special_search($self);
	}elsif( $self->{cgi}->param('q') eq 'list-special' ){
		&_special($self);
	}elsif($self->{cgi}->param('q')){
		&_key_search($self);
	}else{
		&_top($self);
	}

	return;
}

sub _top(){
	my $self = shift;

	$self->{html_title} = qq{クーポン付居酒屋グルメなび -食べめぐるなびプラス-};
	$self->{html_keywords} = qq{グルメ,居酒屋,ホットペッパー,ぐるなび};
	$self->{html_description} = qq{おいしいグルメ検索：居酒屋〜ラーメンまで、マルチにグルメ情報を無料で検索できます。};

	my $hr = &html_hr($self,1);	
	&html_header($self);

if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML
	
}else{# xhmlt chtml

print << "END_OF_HTML";
<center>
<img src="http://img.waao.jp/foodlogo.gif" width=120 height=28 alt="食べめぐるなび"><font size=1 color="#FF0000">プラス</font>
</center>
<center>
<form action="/hotpepper.html" method="POST" ><input type="text" name="q" value="" size="20"><input type="hidden" name="guid" value="ON">
<br />
<input type="submit" value="グルメ検索プラス"><br />
</form>
</center>
<center>
<font size=1>ホットペッパー<font color="#FF0000">マルチ検索</font></font>
</center>
$hr

<a href="/list-area/hotpepper/" accesskey=1>エリア別検索</a><br>
<a href="/list-food/hotpepper/" accesskey=2>料理別検索</a><br>
<a href="/list-genre/hotpepper/" accesskey=3>ジャンル別検索</a><br>
<a href="/list-special/hotpepper/" accesskey=4>オススメ特集</a><br>
<!--<a href="" accesskey=5></a><br>
<a href="" accesskey=6></a><br>
<a href="" accesskey=7></a><br>
<a href="" accesskey=8></a><br>
<a href="" accesskey=9></a><br>
-->
$hr
偂<a href="http://waao.jp/list-in/ranking/8/">みんなのランキング</a><br>
<a href="/" accesskey=0>トップ</a>&gt;<strong>食べめぐるなびプラス</strong><br>
<font size=1 color="#E9E9E9">食べめぐるなびは,ホットペッパーの情報からグルメ情報や割引クーポン情報をマルチに検索できるぐるめ検索サイトです。<br>
Powered by <a href="http://webservice.recruit.co.jp/">ホットペッパー Webサービス</a></font>
END_OF_HTML

}
	&html_footer($self);

	return;
}

sub _special(){
	my $self = shift;
	if( $self->{cgi}->param('p1') ){
		&_special_list($self);
	}else{
		&_special_category($self);
	}

	return;
}

sub _special_category(){
	my $self = shift;

	$self->{html_title} = qq{グルメ特集 -食べめぐるなびプラス-};
	$self->{html_keywords} = qq{グルメ,居酒屋,ホットペッパー,ぐるなび};
	$self->{html_description} = qq{おいしいグルメ特集：居酒屋〜ラーメンまで、マルチにグルメ情報を無料で検索できます。};

	my $hr = &html_hr($self,1);	
	&html_header($self);

	my $ad = &html_google_ad($self);

	&html_table($self, qq{<h1>グルメ特集</h1><h2><font size=1 color="#FF0000">食べめぐるなびプラス</font></h2>}, 1, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

	my $sth = $self->{dbi}->prepare(qq{ select code, name from hpp_special_category  } );
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<font color="#009525">◆</font><a href="/list-special/hotpepper/$row[0]/">$row[1]</a><br>
END_OF_HTML
	}

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/hotpepper/">食べめぐるなび</a>&gt;<strong>グルメ特集</strong><br>
<font size=1 color="#E9E9E9">食べめぐるなびは,ホットペッパーの情報からグルメ情報や割引クーポン情報をマルチに検索できるぐるめ検索サイトです。<br>
Powered by <a href="http://webservice.recruit.co.jp/">ホットペッパー Webサービス</a></font>
END_OF_HTML

	&html_footer($self);

	return;
}

sub _special_list(){
	my $self = shift;
	my $category_id = $self->{cgi}->param('p1');

	my $dsp_str;
	my $category_name;
	my $sth = $self->{dbi}->prepare(qq{ select code, name, category_name from hpp_special where category_code = ? } );
	$sth->execute( $self->{cgi}->param('p1'));
	while(my @row = $sth->fetchrow_array) {
		$category_name = $row[2];
		$dsp_str .= qq{<font color="#009525">◆</font><a href="/list-special-search/hotpepper/$row[0]/">$row[1]</a><br>};
	}

	my $hr = &html_hr($self,1);	
	&html_header($self);

	my $ad = &html_google_ad($self);

	$self->{html_title} = qq{グルメ特集:$category_name -食べめぐるなびプラス-};
	$self->{html_keywords} = qq{グルメ,居酒屋,ホットペッパー,ぐるなび};
	$self->{html_description} = qq{おいしいグルメ特集：$category_name 居酒屋〜ラーメンまで、マルチにグルメ情報を無料で検索できます。};

	&html_table($self, qq{<h1>$category_name</h1><h2><font size=1 color="#FF0000">食べめぐるなびプラス</font></h2>}, 0, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
$dsp_str
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/hotpepper/">食べめぐるなび</a>&gt;<a href="/list-special/hotpepper/">グルメ特集</a>&gt;<strong>$category_name </strong><br>
<font size=1 color="#E9E9E9">食べめぐるなびは,ホットペッパーの情報からグルメ情報や割引クーポン情報・$category_nameをマルチに検索できるぐるめ検索サイトです。<br>
Powered by <a href="http://webservice.recruit.co.jp/">ホットペッパー Webサービス</a></font>
END_OF_HTML

	&html_footer($self);

	return;
}

sub _special_search(){
	my $self = shift;

	# 特集名取得
	my ($special_name, $category_code, $category_name);
	my $sth = $self->{dbi}->prepare(qq{ select name, category_code, category_name from hpp_special where code = ? } );
	$sth->execute( $self->{cgi}->param('p1'));
	while(my @row = $sth->fetchrow_array) {
		$special_name = $row[0];
		$category_code = $row[1]; 
		$category_name = $row[2];
	}
	
	$self->{html_title} = qq{$special_name特集 -食べめぐるなびプラス-};
	$self->{html_keywords} = qq{グルメ,居酒屋,ホットペッパー,ぐるなび};
	$self->{html_description} = qq{おいしいグルメ特集：$special_name};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);
	&html_table($self, qq{<h2><font size=1 color="#FF0000">$special_name</font></h2>}, 1, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

	my $page = 1;
	my $next_page = $page + $self->{cgi}->param('p2');
	$page = 1 + 10 * $self->{cgi}->param('p2') if($self->{cgi}->param('p2'));
	my $api_params;
	$api_params->{special} = $self->{cgi}->param('p1');
	$api_params->{start} = $page;
	my $ret_xml = &_search_api_url($self,$api_params);

	foreach my $key (keys %{$ret_xml->{shop}}) {
		my $name = Jcode->new($key, 'utf8')->sjis;
		$key = $ret_xml->{shop}->{$key};
		my $url = qq{/list-shop-search/hotpepper/}.$key->{id}.qq{/};
		if($self->{real_mobile}){
			$url = $key->{urls}->{mobile};
		}
		my ($photo,$station,$address,$coupon,$genre_name,$food_name,$average_price,$catch);
eval{		
		$photo = $key->{photo}->{mobile}->{s};
		$station = Jcode->new($key->{station_name}, 'utf8')->sjis;
		$address = Jcode->new($key->{address}, 'utf8')->sjis;
		$coupon = qq{<font color="#FF0000">クーポンあり</font><br>} if($key->{ktai_coupon});
		$genre_name = Jcode->new($key->{genre}->{name}, 'utf8')->sjis;
		$food_name = Jcode->new($key->{food}->{name}, 'utf8')->sjis;
		$average_price = Jcode->new($key->{budget}->{average}, 'utf8')->sjis;
		$catch = Jcode->new($key->{catch}, 'utf8')->sjis;
};
print << "END_OF_HTML";
<font size=1 color="#FF0000">●</font><font size=1><a href="$url">$name </a></font><br>
<img src="$photo" width=100 height=75 alt="$name" style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left">
<font size=1>
平均巐$average_price<br>
$coupon
$food_name($genre_name) <br>
$station <br>
$address<br>
$catch
</font>
<br clear="all" />
$hr
END_OF_HTML
	}

print << "END_OF_HTML";
<div align=right><img src="http://img.waao.jp/m2028.gif" width=48 height=9><a href="/list-special-search/hotpepper/$next_page/">の㌻</a></div>
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/list-special/hotpepper/">特集一覧</a>&gt;<a href="/list-special/hotpepper/$category_code/">$category_name</a>&gt;<strong>$special_name</strong><br>
<font size=1 color="#E9E9E9">食べめぐるなびは,ホットペッパーの情報からグルメ情報や割引クーポン情報をマルチに検索できるぐるめ検索サイトです。<br>
Powered by <a href="http://webservice.recruit.co.jp/">ホットペッパー Webサービス</a></font>
END_OF_HTML

	&html_footer($self);
	
	return;
}

sub _search_api_url(){
	my $self = shift;
	my $api_params = shift;
	
	my $url = qq{http://webservice.recruit.co.jp/hotpepper/gourmet/v1/?key=9a62bda886ec7031};
	while ( my ( $key, $value ) = each ( %{$api_params} ) ) {
		next unless($value);
        $url = sprintf("%s&%s=%s",$url, $key, $api_params->{$key});
	}

    my $response = get($url);	
	my $xml = new XML::Simple;
	my $ret_xml = $xml->XMLin($response);

	return $ret_xml;
}

sub _shop_search(){
	my $self = shift;

	my $api_params;
	$api_params->{id} = $self->{cgi}->param('p1');
	my $ret_xml = &_search_api_url($self,$api_params);
	my ($name, $url, $photo,$station,$address,$coupon,$genre_name,$food_name,$average_price,$catch);
	my $xmlval = $ret_xml->{shop};
	$name = Jcode->new($xmlval->{name}, 'utf8')->sjis;
	if($self->{real_mobile}){
		$url = $xmlval->{urls}->{mobile};
	}else{
		$url = $xmlval->{urls}->{pc};
	}
eval{		
	$photo = $xmlval->{photo}->{mobile}->{s};
	$station = Jcode->new($xmlval->{station_name}, 'utf8')->sjis;
	$address = Jcode->new($xmlval->{address}, 'utf8')->sjis;
	$coupon = qq{<font color="#FF0000">クーポンあり</font><br>} if($xmlval->{ktai_coupon});
	$genre_name = Jcode->new($xmlval->{genre}->{name}, 'utf8')->sjis;
	$food_name = Jcode->new($xmlval->{food}->{name}, 'utf8')->sjis;
	$average_price = Jcode->new($xmlval->{budget}->{average}, 'utf8')->sjis;
	$catch = Jcode->new($xmlval->{catch}, 'utf8')->sjis;
};
	my $large_service_area_code = $xmlval->{large_service_area}->{code};
	my $service_area_code = $xmlval->{service_area}->{code};
	my $large_area_code = $xmlval->{large_area}->{code};
	my $middle_area_code = $xmlval->{middle_area}->{code};
	my $small_area_code = $xmlval->{small_area}->{code};
	my $small_area_name = Jcode->new($xmlval->{small_area}->{name}, 'utf8')->sjis;
	my $opentime = Jcode->new($xmlval->{open}, 'utf8')->sjis;
	my $closetime = Jcode->new($xmlval->{close}, 'utf8')->sjis;

	$self->{html_title} = qq{$name -食べめぐるなびプラス-};
	$self->{html_keywords} = qq{$name,グルメ,居酒屋,ホットペッパー,ぐるなび};
	$self->{html_description} = qq{おいしいグルメ特集：$name};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);
	&html_table($self, qq{<h1>$name</h1><h2><font size=1 color="#FF0000">食べめぐるなびプラス</font></h2>}, 1, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
<font size=1 color="#FF0000">●</font><font size=1><a href="$url">$name </a></font><br>
<font size=1>$opentime 〜 $closetime</font><br>
<img src="$photo" width=100 height=75 alt="$name" style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left">
<font size=1>
平均巐$average_price<br>
$coupon
$food_name($genre_name) <br>
$station <br>
$address<br>
$catch
</font>
<br clear="all" />
$hr
<a href="/list-area-search/hotpepper/$service_area_code-$service_area_code-$large_area_code-$middle_area_code-$small_area_code/">$small_area_name近くの店を探す</a>
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/hotpepper/">食べめぐるなび</a>&gt;<strong>$name</strong><br>
<font size=1 color="#E9E9E9">食べめぐるなびは,ホットペッパーの情報からグルメ情報や割引クーポン情報をマルチに検索できるぐるめ検索サイトです。<br>
Powered by <a href="http://webservice.recruit.co.jp/">ホットペッパー Webサービス</a></font>
END_OF_HTML

	&html_footer($self);
	
	
	return;
}

sub _shop_api_url(){
	my $self = shift;
	my $api_params = shift;
	
	my $url = qq{http://webservice.recruit.co.jp/hotpepper/shop/v1/?key=9a62bda886ec7031};
	while ( my ( $key, $value ) = each ( %{$api_params} ) ) {
		next unless($value);
        $url = sprintf("%s&%s=%s",$url, $key, $api_params->{$key});
	}

    my $response = get($url);	
	my $xml = new XML::Simple;
	my $ret_xml = $xml->XMLin($response);

	return $ret_xml;
}

sub _area_search(){
	my $self = shift;
	my @areas = split(/-/,$self->{cgi}->param('p1'));

	# エリア情報取得
	my $area_name;
	if($areas[4]){
		my $sth = $self->{dbi}->prepare(qq{ select name from hpp_small_area where code = ? } );
		$sth->execute( $areas[4] );
		while(my @row = $sth->fetchrow_array) {
			$area_name = $row[0];
		}
	}elsif($areas[3]){
		my $sth = $self->{dbi}->prepare(qq{ select name from hpp_middle_area where code = ? } );
		$sth->execute( $areas[3] );
		while(my @row = $sth->fetchrow_array) {
			$area_name = $row[0];
		}
	}elsif($areas[2]){
		my $sth = $self->{dbi}->prepare(qq{ select name from hpp_large_area where code = ? } );
		$sth->execute( $areas[2] );
		while(my @row = $sth->fetchrow_array) {
			$area_name = $row[0];
		}
	}
	$self->{html_title} = qq{$area_name -食べめぐるなびプラス-};
	$self->{html_keywords} = qq{$area_name,グルメ,居酒屋,ホットペッパー,ぐるなび};
	$self->{html_description} = qq{おいしいグルメ特集：$area_name のお店検索};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);
	&html_table($self, qq{<h2><font size=1 color="#FF0000">$area_name</font></h2>}, 1, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

	my $page = 1;
	my $next_page = $page + $self->{cgi}->param('p2');
	$page = 1 + 10 * $self->{cgi}->param('p2') if($self->{cgi}->param('p2'));
	my $api_params;
	
	if($areas[4]){
		$api_params->{small_area} = $areas[4];
	}elsif($areas[3]){
		$api_params->{middle_area} = $areas[3];
	}elsif($areas[2]){
		$api_params->{large_area} = $areas[2];
	}
	$api_params->{start} = $page;
	my $ret_xml = &_search_api_url($self,$api_params);

	foreach my $key (keys %{$ret_xml->{shop}}) {
		my $name = Jcode->new($key, 'utf8')->sjis;
		$key = $ret_xml->{shop}->{$key};
		my $url = qq{/list-shop-search/hotpepper/}.$key->{id}.qq{/};
		if($self->{real_mobile}){
			$url = $key->{urls}->{mobile};
		}
		my ($photo,$station,$address,$coupon,$genre_name,$food_name,$average_price,$catch);
eval{		
		$photo = $key->{photo}->{mobile}->{s};
		$station = Jcode->new($key->{station_name}, 'utf8')->sjis;
		$address = Jcode->new($key->{address}, 'utf8')->sjis;
		$coupon = qq{<font color="#FF0000">クーポンあり</font><br>} if($key->{ktai_coupon});
		$genre_name = Jcode->new($key->{genre}->{name}, 'utf8')->sjis;
		$food_name = Jcode->new($key->{food}->{name}, 'utf8')->sjis;
		$average_price = Jcode->new($key->{budget}->{average}, 'utf8')->sjis;
		$catch = Jcode->new($key->{catch}, 'utf8')->sjis;
};
print << "END_OF_HTML";
<font size=1 color="#FF0000">●</font><font size=1><a href="$url">$name </a></font><br>
<img src="$photo" width=100 height=75 alt="$name" style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left">
<font size=1>
平均巐$average_price<br>
$coupon
$food_name($genre_name) <br>
$station <br>
$address<br>
$catch
</font>
<br clear="all" />
$hr
END_OF_HTML
	}
my $param = $self->{cgi}->param('p1');

print << "END_OF_HTML";
<div align=right><img src="http://img.waao.jp/m2028.gif" width=48 height=9><a href="/list-area/hotpepper/$param/$next_page/">の㌻</a></div>
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/hotpepper/">食べめぐるなび</a>&gt;<strong>$area_name</strong><br>
<font size=1 color="#E9E9E9">食べめぐるなびは,ホットペッパーの情報からグルメ情報や割引クーポン情報をマルチに検索できるぐるめ検索サイトです。<br>
Powered by <a href="http://webservice.recruit.co.jp/">ホットペッパー Webサービス</a></font>
END_OF_HTML

	&html_footer($self);
	
	return;
}

sub _area_select(){
	my $self = shift;
	
	my @areas = split(/-/,$self->{cgi}->param('p1'));
	my $hr = &html_hr($self,1);	

	my $list;
	if($areas[4]){
	}elsif($areas[3]){
		my $sth = $self->{dbi}->prepare(qq{ select code, name from hpp_small_area where middle_code = ? } );
		$sth->execute( $areas[3] );
		while(my @row = $sth->fetchrow_array) {
			$list.=qq{<font color="#009525">》</font><a href="/list-area/hotpepper/--$areas[2]-$areas[3]-$row[0]/">$row[1]</a><br>}
		}
		$list.=qq{$hr};
	}elsif($areas[2]){
		my $sth = $self->{dbi}->prepare(qq{ select code, name from hpp_middle_area where large_code = ? } );
		$sth->execute( $areas[2] );
		while(my @row = $sth->fetchrow_array) {
			$list.=qq{<font color="#009525">》</font><a href="/list-area/hotpepper/--$areas[2]-$row[0]-/">$row[1]</a><br>}
		}
		$list.=qq{$hr};
	}elsif(!$areas[2]){
		my $sth = $self->{dbi}->prepare(qq{ select code, name from hpp_large_area order by large_service_code, code } );
		$sth->execute();
		while(my @row = $sth->fetchrow_array) {
			$list.=qq{<font color="#009525">》</font><a href="/list-area/hotpepper/--$row[0]--/">$row[1]</a><br>}
		}
		$list.=qq{$hr};
	}

	# エリア情報取得
	my $area_name;
	if($areas[4]){
		my $sth = $self->{dbi}->prepare(qq{ select name from hpp_small_area where code = ? } );
		$sth->execute( $areas[4] );
		while(my @row = $sth->fetchrow_array) {
			$area_name = $row[0];
		}
	}elsif($areas[3]){
		my $sth = $self->{dbi}->prepare(qq{ select name from hpp_middle_area where code = ? } );
		$sth->execute( $areas[3] );
		while(my @row = $sth->fetchrow_array) {
			$area_name = $row[0];
		}
	}elsif($areas[2]){
		my $sth = $self->{dbi}->prepare(qq{ select name from hpp_large_area where code = ? } );
		$sth->execute( $areas[2] );
		while(my @row = $sth->fetchrow_array) {
			$area_name = $row[0];
		}
	}
	$self->{html_title} = qq{$area_name -食べめぐるなびプラス-};
	$self->{html_keywords} = qq{$area_name,グルメ,居酒屋,ホットペッパー,ぐるなび};
	$self->{html_description} = qq{おいしいグルメ特集：$area_name のお店検索};

	&html_header($self);
	my $ad = &html_google_ad($self);
	&html_table($self, qq{<h2><font size=1 color="#FF0000">$area_name</font></h2>}, 1, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
$list
END_OF_HTML

	my $page = 1;
	my $next_page = $page + $self->{cgi}->param('p2');
	$page = 1 + 10 * $self->{cgi}->param('p2') if($self->{cgi}->param('p2'));
	my $api_params;
	
	if($areas[4]){
		$api_params->{small_area} = $areas[4];
	}elsif($areas[3]){
		$api_params->{middle_area} = $areas[3];
	}elsif($areas[2]){
		$api_params->{large_area} = $areas[2];
	}
	$api_params->{start} = $page;
	my $ret_xml = &_search_api_url($self,$api_params);

	foreach my $key (keys %{$ret_xml->{shop}}) {
		my $name = Jcode->new($key, 'utf8')->sjis;
		$key = $ret_xml->{shop}->{$key};
		my $url = qq{/list-shop-search/hotpepper/}.$key->{id}.qq{/};
		if($self->{real_mobile}){
			$url = $key->{urls}->{mobile};
		}
		my ($photo,$station,$address,$coupon,$genre_name,$food_name,$average_price,$catch);
eval{		
		$photo = $key->{photo}->{mobile}->{s};
		$station = Jcode->new($key->{station_name}, 'utf8')->sjis;
		$address = Jcode->new($key->{address}, 'utf8')->sjis;
		$coupon = qq{<font color="#FF0000">クーポンあり</font><br>} if($key->{ktai_coupon});
		$genre_name = Jcode->new($key->{genre}->{name}, 'utf8')->sjis;
		$food_name = Jcode->new($key->{food}->{name}, 'utf8')->sjis;
		$average_price = Jcode->new($key->{budget}->{average}, 'utf8')->sjis;
		$catch = Jcode->new($key->{catch}, 'utf8')->sjis;
};
print << "END_OF_HTML";
<font size=1 color="#FF0000">●</font><font size=1><a href="$url">$name </a></font><br>
<img src="$photo" width=100 height=75 alt="$name" style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left">
<font size=1>
平均巐$average_price<br>
$coupon
$food_name($genre_name) <br>
$station <br>
$address<br>
$catch
</font>
<br clear="all" />
$hr
END_OF_HTML
	}

my $param = $self->{cgi}->param('p1');
print << "END_OF_HTML";
<div align=right><img src="http://img.waao.jp/m2028.gif" width=48 height=9><a href="/list-area/hotpepper/$param/$next_page/">の㌻</a></div>
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/hotpepper/">食べめぐるなび</a>&gt;<strong>$area_name</strong><br>
<font size=1 color="#E9E9E9">食べめぐるなびは,ホットペッパーの情報からグルメ情報や割引クーポン情報をマルチに検索できるぐるめ検索サイトです。<br>
Powered by <a href="http://webservice.recruit.co.jp/">ホットペッパー Webサービス</a></font>
END_OF_HTML

	&html_footer($self);



	
	return;
}

sub _food_select(){
	my $self = shift;
	
	if($self->{cgi}->param('p1')){
		&_food_search($self);
	}else{
		&_food_select_top($self);
	}

	return;
}

sub _food_select_top(){
	my $self = shift;
	
	$self->{html_title} = qq{料理別グルメなび -食べめぐるなびプラス-};
	$self->{html_keywords} = qq{料理,グルメ,居酒屋,ホットペッパー,ぐるなび};
	$self->{html_description} = qq{おいしいグルメ検索：居酒屋〜ラーメンまで、マルチにグルメ情報を無料で検索できます。};
	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);

	&html_header($self);

	my $list;
	my $sth = $self->{dbi}->prepare(qq{ select code, name from hpp_food } );
	$sth->execute( );
	while(my @row = $sth->fetchrow_array) {
		$list.=qq{<font color="#009525">》</font><a href="/list-food/hotpepper/$row[0]/">$row[1]</a><br>}
	}

	&html_table($self, qq{<h2><font size=1 color="#FF0000">料理別検索</font></h2>}, 1, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
$list
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/hotpepper/">食べめぐるなびプラス</a>&gt;<strong>料理別検索</strong><br>
<font size=1 color="#E9E9E9">食べめぐるなびは,ホットペッパーの情報からグルメ情報や割引クーポン情報をマルチに検索できるぐるめ検索サイトです。<br>
Powered by <a href="http://webservice.recruit.co.jp/">ホットペッパー Webサービス</a></font>
END_OF_HTML

	return;
}

sub _food_search(){
	my $self = shift;
	my $foodcode = $self->{cgi}->param('p1');

	my $food_name;
	my $sth = $self->{dbi}->prepare(qq{ select name from hpp_food where code = ? } );
	$sth->execute( $foodcode );
	while(my @row = $sth->fetchrow_array) {
		$food_name = $row[0];
	}
	$self->{html_title} = qq{$food_name -食べめぐるなびプラス-};
	$self->{html_keywords} = qq{$food_name,グルメ,居酒屋,ホットペッパー,ぐるなび};
	$self->{html_description} = qq{おいしいグルメ特集：$food_name のお店検索};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);
	&html_table($self, qq{<h2><font size=1 color="#FF0000">$food_name</font></h2>}, 1, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

	my $page = 1;
	my $next_page = $page + $self->{cgi}->param('p2');
	$page = 1 + 10 * $self->{cgi}->param('p2') if($self->{cgi}->param('p2'));
	my $api_params;
	
	$api_params->{food} = $foodcode;
	$api_params->{start} = $page;
	my $ret_xml = &_search_api_url($self,$api_params);

	foreach my $key (keys %{$ret_xml->{shop}}) {
		my $name = Jcode->new($key, 'utf8')->sjis;
		$key = $ret_xml->{shop}->{$key};
		my $url = qq{/list-shop-search/hotpepper/}.$key->{id}.qq{/};
		if($self->{real_mobile}){
			$url = $key->{urls}->{mobile};
		}
		my ($photo,$station,$address,$coupon,$genre_name,$food_name,$average_price,$catch);
eval{		
		$photo = $key->{photo}->{mobile}->{s};
		$station = Jcode->new($key->{station_name}, 'utf8')->sjis;
		$address = Jcode->new($key->{address}, 'utf8')->sjis;
		$coupon = qq{<font color="#FF0000">クーポンあり</font><br>} if($key->{ktai_coupon});
		$genre_name = Jcode->new($key->{genre}->{name}, 'utf8')->sjis;
		$food_name = Jcode->new($key->{food}->{name}, 'utf8')->sjis;
		$average_price = Jcode->new($key->{budget}->{average}, 'utf8')->sjis;
		$catch = Jcode->new($key->{catch}, 'utf8')->sjis;
};
print << "END_OF_HTML";
<font size=1 color="#FF0000">●</font><font size=1><a href="$url">$name </a></font><br>
<img src="$photo" width=100 height=75 alt="$name" style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left">
<font size=1>
平均巐$average_price<br>
$coupon
$food_name($genre_name) <br>
$station <br>
$address<br>
$catch
</font>
<br clear="all" />
$hr
END_OF_HTML
	}

print << "END_OF_HTML";
<div align=right><img src="http://img.waao.jp/m2028.gif" width=48 height=9><a href="/list-food/hotpepper/$foodcode/$next_page/">の㌻</a></div>
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/hotpepper/">食べめぐるなび</a>&gt;<a href="/list-food/hotpepper/">料理別検索</a>&gt;<strong>$food_name</strong><br>
<font size=1 color="#E9E9E9">食べめぐるなびは,ホットペッパーの情報からグルメ情報や割引クーポン情報をマルチに検索できるぐるめ検索サイトです。<br>
Powered by <a href="http://webservice.recruit.co.jp/">ホットペッパー Webサービス</a></font>
END_OF_HTML

	&html_footer($self);
	
	return;
}
sub _genre_select(){
	my $self = shift;
	
	if($self->{cgi}->param('p1')){
		&_genre_search($self);
	}else{
		&_genre_select_top($self);
	}

	return;
}

sub _genre_select_top(){
	my $self = shift;
	
	$self->{html_title} = qq{ジャンル別グルメなび -食べめぐるなびプラス-};
	$self->{html_keywords} = qq{料理,グルメ,居酒屋,ホットペッパー,ぐるなび};
	$self->{html_description} = qq{おいしいグルメ検索：居酒屋〜ラーメンまで、マルチにグルメ情報を無料で検索できます。};
	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);

	&html_header($self);

	my $list;
	my $sth = $self->{dbi}->prepare(qq{ select code, name from hpp_genre } );
	$sth->execute( );
	while(my @row = $sth->fetchrow_array) {
		$list.=qq{<font color="#009525">》</font><a href="/list-genre/hotpepper/$row[0]/">$row[1]</a><br>}
	}

	&html_table($self, qq{<h2><font size=1 color="#FF0000">ジャンル別検索</font></h2>}, 1, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
$list
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/hotpepper/">食べめぐるなびプラス</a>&gt;<strong>ジャンル別検索</strong><br>
<font size=1 color="#E9E9E9">食べめぐるなびは,ホットペッパーの情報からグルメ情報や割引クーポン情報をマルチに検索できるぐるめ検索サイトです。<br>
Powered by <a href="http://webservice.recruit.co.jp/">ホットペッパー Webサービス</a></font>
END_OF_HTML

	return;
}

sub _genre_search(){
	my $self = shift;
	my $genrecode = $self->{cgi}->param('p1');

	my $genre_name;
	my $sth = $self->{dbi}->prepare(qq{ select name from hpp_genre where code = ? } );
	$sth->execute( $genrecode );
	while(my @row = $sth->fetchrow_array) {
		$genre_name = $row[0];
	}
	$self->{html_title} = qq{$genre_name -食べめぐるなびプラス-};
	$self->{html_keywords} = qq{$genre_name,グルメ,居酒屋,ホットペッパー,ぐるなび};
	$self->{html_description} = qq{おいしいグルメ特集：$genre_name のお店検索};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);
	&html_table($self, qq{<h2><font size=1 color="#FF0000">$genre_name</font></h2>}, 1, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

	my $page = 1;
	my $next_page = $page + $self->{cgi}->param('p2');
	$page = 1 + 10 * $self->{cgi}->param('p2') if($self->{cgi}->param('p2'));
	my $api_params;
	
	$api_params->{genre} = $genrecode;
	$api_params->{start} = $page;
	my $ret_xml = &_search_api_url($self,$api_params);

	foreach my $key (keys %{$ret_xml->{shop}}) {
		my $name = Jcode->new($key, 'utf8')->sjis;
		$key = $ret_xml->{shop}->{$key};
		my $url = qq{/list-shop-search/hotpepper/}.$key->{id}.qq{/};
		if($self->{real_mobile}){
			$url = $key->{urls}->{mobile};
		}
		my ($photo,$station,$address,$coupon,$genre_name,$genre_name,$average_price,$catch);
eval{		
		$photo = $key->{photo}->{mobile}->{s};
		$station = Jcode->new($key->{station_name}, 'utf8')->sjis;
		$address = Jcode->new($key->{address}, 'utf8')->sjis;
		$coupon = qq{<font color="#FF0000">クーポンあり</font><br>} if($key->{ktai_coupon});
		$genre_name = Jcode->new($key->{genre}->{name}, 'utf8')->sjis;
		$genre_name = Jcode->new($key->{genre}->{name}, 'utf8')->sjis;
		$average_price = Jcode->new($key->{budget}->{average}, 'utf8')->sjis;
		$catch = Jcode->new($key->{catch}, 'utf8')->sjis;
};
print << "END_OF_HTML";
<font size=1 color="#FF0000">●</font><font size=1><a href="$url">$name </a></font><br>
<img src="$photo" width=100 height=75 alt="$name" style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left">
<font size=1>
平均巐$average_price<br>
$coupon
$genre_name($genre_name) <br>
$station <br>
$address<br>
$catch
</font>
<br clear="all" />
$hr
END_OF_HTML
	}

print << "END_OF_HTML";
<div align=right><img src="http://img.waao.jp/m2028.gif" width=48 height=9><a href="/list-genre/hotpepper/$genrecode/$next_page/">の㌻</a></div>
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/hotpepper/">食べめぐるなび</a>&gt;<a href="/list-genre/hotpepper/">ジャンル別検索</a>&gt;<strong>$genre_name</strong><br>
<font size=1 color="#E9E9E9">食べめぐるなびは,ホットペッパーの情報からグルメ情報や割引クーポン情報をマルチに検索できるぐるめ検索サイトです。<br>
Powered by <a href="http://webservice.recruit.co.jp/">ホットペッパー Webサービス</a></font>
END_OF_HTML

	&html_footer($self);
	
	return;
}


1;
