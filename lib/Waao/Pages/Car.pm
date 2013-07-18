package Waao::Pages::Car;
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


# /car/		topページ
# /keyword/car/ キーワード検索
# /keyword/car/daummy/pageno/ キーワード検索
# /list-brand/car/<country>-<brand>/ メーカー選択


sub dispatch(){
	my $self = shift;
	
	if($self->{cgi}->param('q') eq 'list-brand'){
		&_brand_search($self);
	}elsif($self->{cgi}->param('q')){
		&_search($self);
	}else{
		&_top($self);
	}

	return;
}

sub _brand_search(){
	my $self = shift;
	my ($country_code, $brand_code);
	my @brand = split(/-/,$self->{cgi}->param('p1'));
	($country_code, $brand_code) = @brand;

	if($brand_code){
		&_model_select($self);
	}elsif($country_code){
		&_brand_select($self);
	}else{
		&_country_select($self);
	}

	return;
}
sub _model_select(){
	my $self = shift;

	my ($country_code, $brand_code);
	my @brand = split(/-/,$self->{cgi}->param('p1'));
	($country_code, $brand_code) = @brand;

	$self->{html_title} = qq{車種別新車・中古車検索プラス メーカー別車種選択};
	$self->{html_keywords} = qq{自動車,国産,車種,相場,値引き};
	$self->{html_description} = qq{車種別新車・中古車検索プラス　};
	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);

&html_table($self, qq{自動車メーカー選択}, 0, 0);
print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

my $sth = $self->{dbi}->prepare( qq{select model from cs_catalog where country_code = ? and brand_code = ? group by model } );
$sth->execute($country_code, $brand_code);
while(my @row = $sth->fetchrow_array) {
	my $model_encode = &str_encode($row[0]);
print << "END_OF_HTML";
<font color="#009525">》</font><a href="/$model_encode/carcatalog/">$row[0]</a><br>
END_OF_HTML
}
	
print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/car/">新車・中古車検索プラス</a>&gt;<a href="/list-brand/car/">国別検索</a>&gt<a href="/list-brand/car/$country_code/">メーカー検索</a>&gt;<strong>車種別検索</strong><br>
<font size=1 color="#E9E9E9">新車・中古車検索プラスは,新車情報と中古車の価格相場などを中心とした自動車総合検索サイトを目指しています。<br>
Powered by <a href="http://webservice.recruit.co.jp/">カーセンサーnet Webサービス</a>
END_OF_HTML

	&html_footer($self);

	return;
}

sub _brand_select(){
	my $self = shift;

	my ($country_code, $brand_code);
	my @brand = split(/-/,$self->{cgi}->param('p1'));
	($country_code, $brand_code) = @brand;

	$self->{html_title} = qq{自動車メーカー別新車・中古車検索プラス メーカー選択};
	$self->{html_keywords} = qq{自動車,国産,メーカー,相場,値引き};
	$self->{html_description} = qq{自動車メーカー別新車・中古車検索プラス　};
	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);

&html_table($self, qq{自動車メーカー選択}, 0, 0);
print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

my $sth = $self->{dbi}->prepare( qq{select code, name, country_code, country_name from cs_brand where country_code = ? order by code } );
$sth->execute($country_code);
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<font color="#009525">》</font><a href="/list-brand/car/$row[2]-$row[0]/">$row[1]</a><br>
END_OF_HTML
}
	
print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/car/">新車・中古車検索プラス</a>&gt;<a href="/list-brand/car/">国別検索</a>&gt;<strong>自動車メーカー選択</strong><br>
<font size=1 color="#E9E9E9">新車・中古車検索プラスは,新車情報と中古車の価格相場などを中心とした自動車総合検索サイトを目指しています。<br>
Powered by <a href="http://webservice.recruit.co.jp/">カーセンサーnet Webサービス</a>
END_OF_HTML

	&html_footer($self);

	return;
}

sub _country_select(){
	my $self = shift;

	$self->{html_title} = qq{国産・輸入車検索プラス 国別検索};
	$self->{html_keywords} = qq{輸入車,国産,中古車,相場,値引き};
	$self->{html_description} = qq{国産・輸入車検索プラス　国産だけじゃない、輸入車の検索もできます！};
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

my $sth = $self->{dbi}->prepare( qq{select code, name from cs_country order by code } );
$sth->execute();
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<font color="#009525">》</font><a href="/list-brand/car/$row[0]-/">$row[1]</a><br>
END_OF_HTML
}
	
print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/car/">新車・中古車検索プラス</a>&gt;<strong>エリア選択</strong><br>
<font size=1 color="#E9E9E9">新車・中古車検索プラスは,新車情報と中古車の価格相場などを中心とした自動車総合検索サイトを目指しています。<br>
Powered by <a href="http://webservice.recruit.co.jp/">カーセンサーnet Webサービス</a>
END_OF_HTML

	&html_footer($self);

	return;
}
sub _search(){
	my $self = shift;
	
	my ($keyword, $keyword_encode, $keyword_utf8);
	unless($self->{cgi}->param('q') =~/list/){
		$keyword = $self->{cgi}->param('q');
		$keyword_encode = &str_encode($keyword);
		$keyword_utf8 = $keyword;
		Encode::from_to($keyword_utf8,'cp932','utf8');
		$keyword_utf8 = escape ( $keyword_utf8 );
	}

	$self->{html_title} = qq{$keyword 新車・中古車検索プラス};
	$self->{html_keywords} = qq{$keyword,新車,中古車,相場,値引き};
	$self->{html_description} = qq{$keyword　の新車・中古車情報。相場や値引き、愛車自慢掲示板など};
	
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

&html_table($self, qq{$keyword 新車カタログ}, 0, 0);
	# 新車情報
	&_catalog_search($self);
	
&html_table($self, qq{坙$keyword 中古車}, 0, 0);
	# 中古車情報
	&_usedcar_search($self);

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
	my $nexturl = qq{/}.&str_encode($self->{cgi}->param('q')).qq{/car/$p2dummy/$nextpage/};

print << "END_OF_HTML";
<div align=right><img src="http://img.waao.jp/m2028.gif" width=48 height=9><a href="$nexturl">次の㌻</a></div>
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/car/">新車・中古車検索プラス</a>&gt;<strong>$keyword</strong><br>
<font size=1 color="#E9E9E9">$keywordの新車情報・中古車情報です。$keywordの最新情報は、ディーラー,店舗にてご確認ください。<br>
Powered by <a href="http://webservice.recruit.co.jp/">カーセンサーnet Webサービス</a>
END_OF_HTML

	&html_footer($self);


	return;
}

sub _catalog_search(){
	my $self = shift;

	my ($keyword, $keyword_encode, $keyword_utf8);
	unless($self->{cgi}->param('q') =~/list/){
		$keyword = $self->{cgi}->param('q');
		$keyword_encode = &str_encode($keyword);
		$keyword_utf8 = $keyword;
		Encode::from_to($keyword_utf8,'cp932','utf8');
		$keyword_utf8 = escape ( $keyword_utf8 );
	}

	my $start;
	if($self->{cgi}->param('p2')){
		$start = 1 + 5 * $self->{cgi}->param('p2');
	}

	my %api_params   = (
    "keyword"     => $keyword_utf8,
	"start"          => $start,
    "count"			 => 5
    
);
	# リクエストURL生成
	my $api_url = qq{http://webservice.recruit.co.jp/carsensor/catalog/v1/?key=9a62bda886ec7031};
	# APIのクエリ生成
	while ( my ( $key, $value ) = each ( %api_params ) ) {
		next unless($value);
        $api_url = sprintf("%s&%s=%s",$api_url, $key, $api_params{$key});
	}
	
	my $response = get($api_url);	
	my $xml = new XML::Simple;
	my $xml_val = $xml->XMLin($response);

	if($xml_val->{results_returned} eq 1){
		&_catalog_dsp($self, $xml_val->{catalog});
	}else{
		foreach my $result (@{$xml_val->{catalog}}) {
			&_catalog_dsp($self, $result);
		}
	}

	return;
}

sub _usedcar_search(){
	my $self = shift;

	my ($keyword, $keyword_encode, $keyword_utf8);
	unless($self->{cgi}->param('q') =~/list/){
		$keyword = $self->{cgi}->param('q');
		$keyword_encode = &str_encode($keyword);
		$keyword_utf8 = $keyword;
		Encode::from_to($keyword_utf8,'cp932','utf8');
		$keyword_utf8 = escape ( $keyword_utf8 );
	}

	my $start;
	if($self->{cgi}->param('p2')){
		$start = 1 + 5 * $self->{cgi}->param('p2');
	}

	my %api_params   = (
    "keyword"     => $keyword_utf8,
	"start"          => $start,
    "count"			 => 5
    
);
	# リクエストURL生成
	my $api_url = qq{http://webservice.recruit.co.jp/carsensor/usedcar/v1/?key=9a62bda886ec7031};
	# APIのクエリ生成
	while ( my ( $key, $value ) = each ( %api_params ) ) {
		next unless($value);
        $api_url = sprintf("%s&%s=%s",$api_url, $key, $api_params{$key});
	}
	
	my $response = get($api_url);	
	my $xml = new XML::Simple;
	my $xml_val = $xml->XMLin($response);
	if($xml_val->{results_returned} eq 1){
#		&_usedcar_dsp($self, $xml_val->{usedcar});
	}else{
		foreach my $carid (keys %{$xml_val->{usedcar}}) {
			next unless($carid);
			&_usedcar_dsp($self, $xml_val->{usedcar}->{$carid},$carid);
		}
	}

	return;
}
sub _usedcar_dsp(){
	my $self = shift;
	my $result = shift;
	my $carid = shift;
	my ($body_code, $body_name,
		$model,$grade,$price,$person,$period,$series,
		$width,$height,$length,
		$photo_main_l,$photo_main_s,
		$photo_1_l,$photo_1_s,
		$photo_2_l,$photo_2_s,
		$photo_3_l,$photo_3_s,
		$photo_4_l,$photo_4_s,
		$photo_5_l,$photo_5_s,
		$shop_url_pc,$shop_url_mobile,$desc
		);
	my ( $inspection, $maintenance, $warranty, $odd, $year, $color);
eval{
	$model = Jcode->new($result->{model}, 'utf8')->sjis;
	$grade = Jcode->new($result->{grade}, 'utf8')->sjis;
	$price = Jcode->new($result->{price}, 'utf8')->sjis;
	$price = &price_dsp($price);
};
eval{
	$body_code = Jcode->new($result->{body}->{code}, 'utf8')->sjis;
	$body_name = Jcode->new($result->{body}->{name}, 'utf8')->sjis;

};
eval{
	$person = Jcode->new($result->{person}, 'utf8')->sjis;
	$period = Jcode->new($result->{period}, 'utf8')->sjis;
	$series = Jcode->new($result->{series}, 'utf8')->sjis;
};
eval{
	$width = Jcode->new($result->{width}, 'utf8')->sjis;
	$height = Jcode->new($result->{height}, 'utf8')->sjis;
	$length = Jcode->new($result->{length}, 'utf8')->sjis;
};

eval{
	$photo_main_l = Jcode->new($result->{photo}->{main}->{l}, 'utf8')->sjis;
	$photo_main_s = Jcode->new($result->{photo}->{main}->{s}, 'utf8')->sjis;
};
eval{
	$photo_1_l = Jcode->new($result->{photo}->{sub}->{l}, 'utf8')->sjis;
	$photo_1_s = Jcode->new($result->{photo}->{sub}->{s}, 'utf8')->sjis;
};

eval{
	$shop_url_pc = Jcode->new($result->{urls}->{pc}, 'utf8')->sjis;
	$shop_url_mobile = Jcode->new($result->{urls}->{mobile}, 'utf8')->sjis;
};
eval{
	$desc = Jcode->new($result->{desc}, 'utf8')->sjis;
};
eval{
	$inspection = Jcode->new($result->{inspection}, 'utf8')->sjis;
	$odd = Jcode->new($result->{odd}, 'utf8')->sjis;
	$year = Jcode->new($result->{year}, 'utf8')->sjis;
	$color = Jcode->new($result->{color}, 'utf8')->sjis;
	$maintenance = Jcode->new($result->{maintenance}, 'utf8')->sjis;
	$warranty = Jcode->new($result->{warranty}, 'utf8')->sjis;
};


my $hr = &html_hr($self,1);	


print << "END_OF_HTML";
<font size=1 color="#FF0000">●</font><font size=1><a href="/list-detail/usedcar/$carid/">$model $grade</a></font><br>
<img src="$photo_main_s" alt="$model" style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left">
<font size=1>
$price円<br>
車検:$inspection<br>
走行距離:$odd<br>
登録年:$year<br>
</font>
<br clear="all" />
$hr
END_OF_HTML
	
	return;
}

sub _catalog_dsp(){
	my $self = shift;
	my $result = shift;
	my ($body_code, $body_name,
		$brand_code, $brand_name,
		$model,$grade,$price,$person,$period,$series,
		$width,$height,$length,
		$photo_frot_l,$photo_frot_s,$photo_frot_caption,
		$photo_rear_l,$photo_rear_s,$photo_rear_caption,
	    $photo_inpane_l,$photo_inpane_s,$photo_inpane_caption,
		$shop_url_pc,$shop_url_mobile,$desc
		);
eval{
	$model = Jcode->new($result->{model}, 'utf8')->sjis;
	$grade = Jcode->new($result->{grade}, 'utf8')->sjis;
	$price = Jcode->new($result->{price}, 'utf8')->sjis;
	$price = &price_dsp($price);
};
eval{
	$brand_code = Jcode->new($result->{brand}->{code}, 'utf8')->sjis;
	$brand_name = Jcode->new($result->{brand}->{name}, 'utf8')->sjis;

};
eval{
	$body_code = Jcode->new($result->{body}->{code}, 'utf8')->sjis;
	$body_name = Jcode->new($result->{body}->{name}, 'utf8')->sjis;

};
eval{
	$person = Jcode->new($result->{person}, 'utf8')->sjis;
	$period = Jcode->new($result->{period}, 'utf8')->sjis;
	$series = Jcode->new($result->{series}, 'utf8')->sjis;
};
eval{
	$width = Jcode->new($result->{width}, 'utf8')->sjis;
	$height = Jcode->new($result->{height}, 'utf8')->sjis;
	$length = Jcode->new($result->{length}, 'utf8')->sjis;
};

eval{
	$photo_frot_l = Jcode->new($result->{photo}->{front}->{l}, 'utf8')->sjis;
	$photo_frot_s = Jcode->new($result->{photo}->{front}->{s}, 'utf8')->sjis;
	$photo_frot_caption = Jcode->new($result->{photo}->{front}->{caption}, 'utf8')->sjis;

	$photo_rear_l = Jcode->new($result->{photo}->{rear}->{l}, 'utf8')->sjis;
	$photo_rear_s = Jcode->new($result->{photo}->{rear}->{s}, 'utf8')->sjis;
	$photo_rear_caption = Jcode->new($result->{photo}->{rear}->{caption}, 'utf8')->sjis;

	$photo_inpane_l = Jcode->new($result->{urls}->{inpane}->{l}, 'utf8')->sjis;
	$photo_inpane_s = Jcode->new($result->{photo}->{inpane}->{s}, 'utf8')->sjis;
	$photo_inpane_caption = Jcode->new($result->{photo}->{inpane}->{caption}, 'utf8')->sjis;
};
eval{
	$shop_url_pc = Jcode->new($result->{urls}->{pc}, 'utf8')->sjis;
	$shop_url_mobile = Jcode->new($result->{urls}->{mobile}, 'utf8')->sjis;
};
eval{
	$desc = Jcode->new($result->{desc}, 'utf8')->sjis;
};


my $hr = &html_hr($self,1);	

# DBと照合する
my $car_id;
my $sth = $self->{dbi}->prepare( qq{select id from cs_catalog where model = ? and  brand_code = ?  and grade = ?} );
$sth->execute($model, $brand_code, $grade);
while(my @row = $sth->fetchrow_array) {
	$car_id = $row[0];
}

print << "END_OF_HTML";
<font size=1 color="#FF0000">●</font><font size=1><a href="/list-detail/carcatalog/$car_id/">$model $grade</a></font><br>
<img src="$photo_frot_s" alt="$model" style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left">
<font size=1>
$price円<br>
定員:$person<br>
幅:$width<br>
高さ:$width<br>
全長:$length<br>
</font>
<br clear="all" />
$hr
END_OF_HTML
	
	return;
}


sub _top(){
	my $self = shift;

	$self->{html_title} = qq{新車・中古車検索プラス 価格相場もわかる！};
	$self->{html_keywords} = qq{新車,中古車,オークション,相場,値引き};
	$self->{html_description} = qq{新車・中古車検索プラス　新車情報・中古車の価格相場やオークション情報が人目でわかる！};

	my $hr = &html_hr($self,1);	
	&html_header($self);

if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML
	
}else{# xhmlt chtml

print << "END_OF_HTML";
<center>
<img src="http://img.waao.jp/car.gif" width=120 height=28 alt="新車・中古車検索プラス"><font size=1 color="#FF0000">プラス</font>
</center>
<center>
<form action="/car.html" method="POST" ><input type="text" name="q" value="" size="20"><input type="hidden" name="guid" value="ON">
<br />
<input type="submit" value="新車・中古車検索プラス"><br />
</form>
</center>
<center>
<font size=1>クチコミ情報満載<font color="#FF0000">マルチ検索</font></font>
</center>
$hr

<a href="/list-brand/car/JPN-/" accesskey=1>国産車検索</a><br>
<a href="/list-brand/car/" accesskey=2>メーカー・車種別検索</a><br>
<!--
<a href="" accesskey=3></a><br>
<a href="" accesskey=4></a><br>
<a href="" accesskey=5></a><br>
<a href="" accesskey=6></a><br>
<a href="" accesskey=7></a><br>
<a href="" accesskey=8></a><br>
<a href="" accesskey=9></a><br>
-->
$hr
<center>
<a href="http://i.vcads.com/servlet/referral?guid=ON&vs=2536243&vp=878987936" ><img src="http://i.vcads.com/servlet/gifbanner?vs=2536243&vp=878987936" height="53" width="192" border="0"></a>
</center>
$hr
偂<a href="http://waao.jp/list-in/ranking/10/">みんなのランキング</a><br>
<a href="/" accesskey=0>トップ</a>&gt;<strong>新車・中古車検索プラス</strong><br>
<font size=1 color="#E9E9E9">新車・中古車検索プラスは,新車情報と中古車の価格相場などを中心とした自動車総合検索サイトを目指しています。<br>
Powered by <a href="http://webservice.recruit.co.jp/">カーセンサーnet Webサービス</a>
END_OF_HTML

}
	&html_footer($self);

	return;
}
# カタログ検索
# /keyword/carcatalog/<p1>/<model>/ カタログ検索
# /list-detail/carcatalog/id/ 
sub dispatch_catalog(){
	my $self = shift;
	if($self->{cgi}->param('q') eq 'list-detail'){
		&_catalog_detail($self);
	}elsif($self->{cgi}->param('q') eq 'list-photo'){
		&_search_photo($self);
	}elsif($self->{cgi}->param('q')){
		&_search_catalog($self);
	}else{
		&_top($self);
	}
	return;
}

sub _search_photo(){
	my $self = shift;
	my $carid = $self->{cgi}->param('p1');
	my $phototype = $self->{cgi}->param('p2');

	my $sth = $self->{dbi}->prepare( qq{select `brand_code`,`brand_name`,`country_code`,`country_name`,`body_code`,`body_name`,
		  `model`,`grade`,`price`,`person`,`period`,`series`,
		  `width`,`height`,`length_val`,
		  `photo_frot_l`,`photo_frot_s`,`photo_frot_caption`,
		  `photo_rear_l`,`photo_rear_s`,`photo_rear_caption`,
		  `photo_inpane_l`,`photo_inpane_s`,`photo_inpane_caption`,
		  `shop_url_pc`,`shop_url_mobile`,`desc` from cs_catalog where id = ? limit 1 } );
	$sth->execute($carid);
	my ($brand_code,$brand_name,$country_code,$country_name,$body_code,$body_name,$model,$grade,$price,$person,$period,$series,$width,$height,$length_val,$photo_frot_l,$photo_frot_s,$photo_frot_caption,$photo_rear_l,$photo_rear_s,$photo_rear_caption,$photo_inpane_l,$photo_inpane_s,$photo_inpane_caption,$shop_url_pc,$shop_url_mobile,$desc);
	while(my @row = $sth->fetchrow_array) {
		($brand_code,$brand_name,$country_code,$country_name,$body_code,$body_name,$model,$grade,$price,$person,$period,$series,$width,$height,$length_val,$photo_frot_l,$photo_frot_s,$photo_frot_caption,$photo_rear_l,$photo_rear_s,$photo_rear_caption,$photo_inpane_l,$photo_inpane_s,$photo_inpane_caption,$shop_url_pc,$shop_url_mobile,$desc) = @row;
	}
	
	$self->{html_title} = qq{$brand_name $model $grade 価格 $price};
	$self->{html_keywords} = qq{$brand_name,$model,$model$grade,値引き};
	$self->{html_description} = qq{$brand_name $model $gradeの最新情報　新車・中古車も検索できる$model検索プラス　};
	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);
	my $model_encode = &str_encode($model);
&html_table($self, qq{$model $grade}, 0, 0);
print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
$price円<br>
<center>
END_OF_HTML

if($phototype eq "front"){
print << "END_OF_HTML";
<img src="$photo_frot_l" alt="$model $grade"><br>
END_OF_HTML
}

if($phototype eq "rear"){
print << "END_OF_HTML";
<img src="$photo_rear_l" alt="$model $grade"><br>
END_OF_HTML
}

if($phototype eq "inpane"){
print << "END_OF_HTML";
<img src="$photo_inpane_l" alt="$model $grade"><br>
END_OF_HTML
}

my $atag_url = &_make_vc_tag($shop_url_mobile,"店舗情報");
print << "END_OF_HTML";
</center>
$desc<br>
定員:$person<br>
幅:$width<br>
高さ:$width<br>
全長:$length_val<br>
$atag_url<br>
<a href="/$model_encode/usedcar/$country_code-$brand_code/">$modelの中古車</a><br>
<font size=1 color="#FF0000">詳細は、店舗へお問い合わせください。<br>
表示されている内容について、一切の責任を負いません。</font>
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/car/">新車・中古車検索プラス</a>&gt;<a href="/list-brand/car/">国別検索</a>&gt<a href="/list-brand/car/$country_code/">メーカー検索</a>&gt;<a href="/list-brand/car/$country_code-$brand_code/">$brand_name車種一覧</a>&gt;<a href="/list-detail/carcatalog/$carid/">$brand_name $model $grade</a><br>
<font size=1 color="#E9E9E9">新車・中古車検索プラスは,新車情報と中古車の価格相場などを中心とした自動車総合検索サイトを目指しています。<br>
Powered by <a href="http://webservice.recruit.co.jp/">カーセンサーnet Webサービス</a>
END_OF_HTML

	&html_footer($self);
	
	# 参照カウントアップ
	
	return;
}


sub _catalog_detail(){
	my $self = shift;
	my $carid = $self->{cgi}->param('p1');

	my $sth = $self->{dbi}->prepare( qq{select `brand_code`,`brand_name`,`country_code`,`country_name`,`body_code`,`body_name`,
		  `model`,`grade`,`price`,`person`,`period`,`series`,
		  `width`,`height`,`length_val`,
		  `photo_frot_l`,`photo_frot_s`,`photo_frot_caption`,
		  `photo_rear_l`,`photo_rear_s`,`photo_rear_caption`,
		  `photo_inpane_l`,`photo_inpane_s`,`photo_inpane_caption`,
		  `shop_url_pc`,`shop_url_mobile`,`desc` from cs_catalog where id = ? limit 1 } );
	$sth->execute($carid);
	my ($brand_code,$brand_name,$country_code,$country_name,$body_code,$body_name,$model,$grade,$price,$person,$period,$series,$width,$height,$length_val,$photo_frot_l,$photo_frot_s,$photo_frot_caption,$photo_rear_l,$photo_rear_s,$photo_rear_caption,$photo_inpane_l,$photo_inpane_s,$photo_inpane_caption,$shop_url_pc,$shop_url_mobile,$desc);
	while(my @row = $sth->fetchrow_array) {
		($brand_code,$brand_name,$country_code,$country_name,$body_code,$body_name,$model,$grade,$price,$person,$period,$series,$width,$height,$length_val,$photo_frot_l,$photo_frot_s,$photo_frot_caption,$photo_rear_l,$photo_rear_s,$photo_rear_caption,$photo_inpane_l,$photo_inpane_s,$photo_inpane_caption,$shop_url_pc,$shop_url_mobile,$desc) = @row;
	}
	
	$self->{html_title} = qq{$brand_name $model $grade 価格 $price};
	$self->{html_keywords} = qq{$brand_name,$model,$model$grade,値引き};
	$self->{html_description} = qq{$brand_name $model $gradeの最新情報　新車・中古車も検索できる$model検索プラス　};
	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);

&html_table($self, qq{$model $grade}, 0, 0);
print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
$price円<br>
<center>
END_OF_HTML

my $atag_url = &_make_vc_tag($shop_url_mobile,"店舗情報");

if($photo_frot_s){
print << "END_OF_HTML";
<a href="/list-photo/carcatalog/$carid/front/"><img src="$photo_frot_s" alt="$model $grade"></a><br>
END_OF_HTML
}

if($photo_rear_s){
print << "END_OF_HTML";
<a href="/list-photo/carcatalog/$carid/rear/"><img src="$photo_rear_s" alt="$model $grade"></a><br>
END_OF_HTML
}

if($photo_inpane_s){
print << "END_OF_HTML";
<a href="/list-photo/carcatalog/$carid/inpane/"><img src="$photo_inpane_s" alt="$model $grade"></a><br>
END_OF_HTML
}
my  $model_encode = &str_encode($model);
print << "END_OF_HTML";
</center>
$desc<br>
定員:$person<br>
幅:$width<br>
高さ:$width<br>
全長:$length_val<br>
$atag_url<br>
<a href="/$model_encode/usedcar/$country_code-$brand_code/">$modelの中古車</a><br>
<font size=1 color="#FF0000">詳細は、店舗へお問い合わせください。<br>
表示されている内容について、一切の責任を負いません。</font>
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/car/">新車・中古車検索プラス</a>&gt;<a href="/list-brand/car/">国別検索</a>&gt<a href="/list-brand/car/$country_code/">メーカー検索</a>&gt;<a href="/list-brand/car/$country_code-$brand_code/">$brand_name車種一覧</a>&gt;<strong>$brand_name $model $grade</strong><br>
<font size=1 color="#E9E9E9">新車・中古車検索プラスは,新車情報と中古車の価格相場などを中心とした自動車総合検索サイトを目指しています。<br>
Powered by <a href="http://webservice.recruit.co.jp/">カーセンサーnet Webサービス</a>
END_OF_HTML

	&html_footer($self);
	
	# 参照カウントアップ
	
	return;
}

sub _search_catalog(){
	my $self = shift;
	
	my ($keyword, $keyword_encode, $keyword_utf8);
	unless($self->{cgi}->param('q') =~/list/){
		$keyword = $self->{cgi}->param('q');
		$keyword_encode = &str_encode($keyword);
		$keyword_utf8 = $keyword;
		Encode::from_to($keyword_utf8,'cp932','utf8');
		$keyword_utf8 = escape ( $keyword_utf8 );
	}

	$self->{html_title} = qq{$keyword 新車・自動車スペック・価格検索プラス};
	$self->{html_keywords} = qq{$keyword,新車,中古車,スペック,価格,値引き};
	$self->{html_description} = qq{$keyword　の新車・中古車情報。相場や値引き、愛車自慢掲示板など};
	
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
	
&html_table($self, qq{$keyword 新車カタログ}, 0, 0);
# 新車情報
&_catalog_search($self);

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
	my $nexturl = qq{/}.&str_encode($self->{cgi}->param('q')).qq{/carcatalog/$p2dummy/$nextpage/};

print << "END_OF_HTML";
<div align=right><img src="http://img.waao.jp/m2028.gif" width=48 height=9><a href="$nexturl">次の㌻</a></div>
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/car/">新車・中古車検索プラス</a>&gt;<strong>$keyword</strong><br>
<font size=1 color="#E9E9E9">$keywordの新車情報・中古車情報です。$keywordの最新情報は、ディーラー,店舗にてご確認ください。<br>
Powered by <a href="http://webservice.recruit.co.jp/">カーセンサーnet Webサービス</a>
END_OF_HTML

	&html_footer($self);


	return;
}
# 中古車
# /keyword/carcatalog/<p1>/<model>/ カタログ検索
# /list-detail/carcatalog/id/ 
sub dispatch_used(){
	my $self = shift;
	if($self->{cgi}->param('q') eq 'list-detail'){
		&_usedcar_detail($self);
	}elsif($self->{cgi}->param('q') eq 'list-photo'){
		&_usedcar_detail_photo($self);
	}elsif($self->{cgi}->param('q')){
		&_search_used($self);
	}else{
		&_top($self);
	}
	return;
}

sub _usedcar_detail_photo(){
	my $self = shift;
	my $carid = $self->{cgi}->param('p1');

	my %api_params   = (
    "id"     => $carid,
    "count"			 => 1
    
);
	# リクエストURL生成
	my $api_url = qq{http://webservice.recruit.co.jp/carsensor/usedcar/v1/?key=9a62bda886ec7031};
	# APIのクエリ生成
	while ( my ( $key, $value ) = each ( %api_params ) ) {
		next unless($value);
        $api_url = sprintf("%s&%s=%s",$api_url, $key, $api_params{$key});
	}
	
	my $response = get($api_url);	
	my $xml = new XML::Simple;
	my $xml_val = $xml->XMLin($response);
	my $result = $xml_val->{usedcar};
	my ($body_code, $body_name,
		$brand_code, $brand_name,
		$model,$grade,$price,$person,$period,$series,
		$width,$height,$length_val,
		$photo_main_l,$photo_main_s,
		$photo_1_l,$photo_1_s,
		$photo_2_l,$photo_2_s,
		$photo_3_l,$photo_3_s,
		$photo_4_l,$photo_4_s,
		$photo_5_l,$photo_5_s,
		$shop_url_pc,$shop_url_mobile,$desc
		);
	my ( $inspection, $maintenance, $warranty, $odd, $year, $color);

eval{
	$model = Jcode->new($result->{model}, 'utf8')->sjis;
	$grade = Jcode->new($result->{grade}, 'utf8')->sjis;
	$price = Jcode->new($result->{price}, 'utf8')->sjis;
	$price = &price_dsp($price);
};
eval{
	$body_code = Jcode->new($result->{body}->{code}, 'utf8')->sjis;
	$body_name = Jcode->new($result->{body}->{name}, 'utf8')->sjis;

};
eval{
	$brand_code = Jcode->new($result->{brand}->{code}, 'utf8')->sjis;
	$brand_name = Jcode->new($result->{brand}->{name}, 'utf8')->sjis;

};
eval{
	$person = Jcode->new($result->{person}, 'utf8')->sjis;
	$period = Jcode->new($result->{period}, 'utf8')->sjis;
	$series = Jcode->new($result->{series}, 'utf8')->sjis;
};
eval{
	$width = Jcode->new($result->{width}, 'utf8')->sjis;
	$height = Jcode->new($result->{height}, 'utf8')->sjis;
	$length_val = Jcode->new($result->{length}, 'utf8')->sjis;
};

eval{
	$photo_main_l = Jcode->new($result->{photo}->{main}->{l}, 'utf8')->sjis;
	$photo_main_s = Jcode->new($result->{photo}->{main}->{s}, 'utf8')->sjis;
};
eval{
	$photo_1_l = Jcode->new($result->{photo}->{sub}->{l}, 'utf8')->sjis;
	$photo_1_s = Jcode->new($result->{photo}->{sub}->{s}, 'utf8')->sjis;
};

eval{
	$shop_url_pc = Jcode->new($result->{urls}->{pc}, 'utf8')->sjis;
	$shop_url_mobile = Jcode->new($result->{urls}->{mobile}, 'utf8')->sjis;
};
eval{
	$desc = Jcode->new($result->{desc}, 'utf8')->sjis;
};
eval{
	$inspection = Jcode->new($result->{inspection}, 'utf8')->sjis;
	$odd = Jcode->new($result->{odd}, 'utf8')->sjis;
	$year = Jcode->new($result->{year}, 'utf8')->sjis;
	$color = Jcode->new($result->{color}, 'utf8')->sjis;
	$maintenance = Jcode->new($result->{maintenance}, 'utf8')->sjis;
	$warranty = Jcode->new($result->{warranty}, 'utf8')->sjis;
};

	
	$self->{html_title} = qq{$brand_name $model $grade 中古価格 $price};
	$self->{html_keywords} = qq{$brand_name,$model,$model$grade,中古};
	$self->{html_description} = qq{$brand_name $model $gradeの中古車情報　新車・中古車も検索できる$model検索プラス　};
	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);

&html_table($self, qq{$model $grade}, 0, 0);
print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
$price円<br>
車検:$inspection<br>
走行距離:$odd<br>
登録年:$year<br>
色:$color<br>
整備:$maintenance<br>
保障:$warranty<br>
<center>
END_OF_HTML

if($self->{cgi}->param('p2') eq 'main'){
print << "END_OF_HTML";
<img src="$photo_main_l" alt="$model $grade"><br>
END_OF_HTML
}

eval{
	my $cnt;
foreach my $photo_url (@{$result->{photo}->{sub}}) {
$cnt++;
if($self->{cgi}->param('p2') eq $cnt){
print << "END_OF_HTML";
<img src="$photo_url" alt="$model $grade"><br>
END_OF_HTML
}
}
};

my $atag_url = &_make_vc_tag($shop_url_mobile,"店舗情報");

my  $model_encode = &str_encode($model);
print << "END_OF_HTML";
</center>
$desc<br>
定員:$person<br>
幅:$width<br>
高さ:$width<br>
全長:$length_val<br>
$atag_url<br>
<a href="/$model_encode/carcatalog/">$modelのスペック</a><br>
<font size=1 color="#FF0000">詳細は、店舗へお問い合わせください。<br>
表示されている内容について、一切の責任を負いません。</font>
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/car/">新車・中古車検索プラス</a>&gt;<a href="/list-brand/car/">国別検索</a>&gt;<a href="/list-detail/usedcar/$carid/">$brand_name $model $grade</a><br>
<font size=1 color="#E9E9E9">新車・中古車検索プラスは,新車情報と中古車の価格相場などを中心とした自動車総合検索サイトを目指しています。<br>
Powered by <a href="http://webservice.recruit.co.jp/">カーセンサーnet Webサービス</a>
END_OF_HTML

	&html_footer($self);
	
	# 参照カウントアップ
	
	return;
}



sub _usedcar_detail(){
	my $self = shift;
	my $carid = $self->{cgi}->param('p1');

	my %api_params   = (
    "id"     => $carid,
    "count"			 => 1
    
);
	# リクエストURL生成
	my $api_url = qq{http://webservice.recruit.co.jp/carsensor/usedcar/v1/?key=9a62bda886ec7031};
	# APIのクエリ生成
	while ( my ( $key, $value ) = each ( %api_params ) ) {
		next unless($value);
        $api_url = sprintf("%s&%s=%s",$api_url, $key, $api_params{$key});
	}
	
	my $response = get($api_url);	
	my $xml = new XML::Simple;
	my $xml_val = $xml->XMLin($response);
	my $result = $xml_val->{usedcar};
	my ($body_code, $body_name,
		$brand_code, $brand_name,
		$model,$grade,$price,$person,$period,$series,
		$width,$height,$length_val,
		$photo_main_l,$photo_main_s,
		$photo_1_l,$photo_1_s,
		$photo_2_l,$photo_2_s,
		$photo_3_l,$photo_3_s,
		$photo_4_l,$photo_4_s,
		$photo_5_l,$photo_5_s,
		$shop_url_pc,$shop_url_mobile,$desc
		);
	my ( $inspection, $maintenance, $warranty, $odd, $year, $color);

eval{
	$model = Jcode->new($result->{model}, 'utf8')->sjis;
	$grade = Jcode->new($result->{grade}, 'utf8')->sjis;
	$price = Jcode->new($result->{price}, 'utf8')->sjis;
	$price = &price_dsp($price);
};
eval{
	$body_code = Jcode->new($result->{body}->{code}, 'utf8')->sjis;
	$body_name = Jcode->new($result->{body}->{name}, 'utf8')->sjis;

};
eval{
	$brand_code = Jcode->new($result->{brand}->{code}, 'utf8')->sjis;
	$brand_name = Jcode->new($result->{brand}->{name}, 'utf8')->sjis;

};
eval{
	$person = Jcode->new($result->{person}, 'utf8')->sjis;
	$period = Jcode->new($result->{period}, 'utf8')->sjis;
	$series = Jcode->new($result->{series}, 'utf8')->sjis;
};
eval{
	$width = Jcode->new($result->{width}, 'utf8')->sjis;
	$height = Jcode->new($result->{height}, 'utf8')->sjis;
	$length_val = Jcode->new($result->{length}, 'utf8')->sjis;
};

eval{
	$photo_main_l = Jcode->new($result->{photo}->{main}->{l}, 'utf8')->sjis;
	$photo_main_s = Jcode->new($result->{photo}->{main}->{s}, 'utf8')->sjis;
};
eval{
	$photo_1_l = Jcode->new($result->{photo}->{sub}->{l}, 'utf8')->sjis;
	$photo_1_s = Jcode->new($result->{photo}->{sub}->{s}, 'utf8')->sjis;
};

eval{
	$shop_url_pc = Jcode->new($result->{urls}->{pc}, 'utf8')->sjis;
	$shop_url_mobile = Jcode->new($result->{urls}->{mobile}, 'utf8')->sjis;
};
eval{
	$desc = Jcode->new($result->{desc}, 'utf8')->sjis;
};
eval{
	$inspection = Jcode->new($result->{inspection}, 'utf8')->sjis;
	$odd = Jcode->new($result->{odd}, 'utf8')->sjis;
	$year = Jcode->new($result->{year}, 'utf8')->sjis;
	$color = Jcode->new($result->{color}, 'utf8')->sjis;
	$maintenance = Jcode->new($result->{maintenance}, 'utf8')->sjis;
	$warranty = Jcode->new($result->{warranty}, 'utf8')->sjis;
};

	
	$self->{html_title} = qq{$brand_name $model $grade 中古価格 $price};
	$self->{html_keywords} = qq{$brand_name,$model,$model$grade,中古};
	$self->{html_description} = qq{$brand_name $model $gradeの中古車情報　新車・中古車も検索できる$model検索プラス　};
	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);

&html_table($self, qq{$model $grade}, 0, 0);
print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
$price円<br>
車検:$inspection<br>
走行距離:$odd<br>
登録年:$year<br>
色:$color<br>
整備:$maintenance<br>
保障:$warranty<br>
<center>
END_OF_HTML

if($photo_main_s){
print << "END_OF_HTML";
<a href="/list-photo/usedcar/$carid/main/"><img src="$photo_main_s" alt="$model $grade"></a><br>
END_OF_HTML
}

eval{
	my $cnt;
foreach my $photo_url (@{$result->{photo}->{sub}}) {
$cnt++;
print << "END_OF_HTML";
<a href="/list-photo/usedcar/$carid/$cnt/">画像$cnt</a><br>
END_OF_HTML

}
};

my $atag_url = &_make_vc_tag($shop_url_mobile,"店舗情報");

my  $model_encode = &str_encode($model);
print << "END_OF_HTML";
</center>
$desc<br>
定員:$person<br>
幅:$width<br>
高さ:$width<br>
全長:$length_val<br>
$atag_url<br>
<a href="/$model_encode/carcatalog/">$modelのスペック</a><br>
<font size=1 color="#FF0000">詳細は、店舗へお問い合わせください。<br>
表示されている内容について、一切の責任を負いません。</font>
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/car/">新車・中古車検索プラス</a>&gt;<a href="/list-brand/car/">国別検索</a>&gt;<strong>$brand_name $model $grade</strong><br>
<font size=1 color="#E9E9E9">新車・中古車検索プラスは,新車情報と中古車の価格相場などを中心とした自動車総合検索サイトを目指しています。<br>
Powered by <a href="http://webservice.recruit.co.jp/">カーセンサーnet Webサービス</a>
END_OF_HTML

	&html_footer($self);
	
	# 参照カウントアップ
	
	return;
}


sub _search_used(){
	my $self = shift;
	
	my ($keyword, $keyword_encode, $keyword_utf8);
	unless($self->{cgi}->param('q') =~/list/){
		$keyword = $self->{cgi}->param('q');
		$keyword_encode = &str_encode($keyword);
		$keyword_utf8 = $keyword;
		Encode::from_to($keyword_utf8,'cp932','utf8');
		$keyword_utf8 = escape ( $keyword_utf8 );
	}

	$self->{html_title} = qq{$keyword 中古車・相場・価格検索プラス};
	$self->{html_keywords} = qq{$keyword,中古車,スペック,相場,価格,値引き};
	$self->{html_description} = qq{$keywordの中古車情報。相場や値引き、愛車自慢掲示板など};
	
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
	
&html_table($self, qq{$keyword 中古車}, 0, 0);
# 新車情報
&_usedcar_search($self);

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
	my $nexturl = qq{/}.&str_encode($self->{cgi}->param('q')).qq{/usedcar/$p2dummy/$nextpage/};

print << "END_OF_HTML";
<div align=right><img src="http://img.waao.jp/m2028.gif" width=48 height=9><a href="$nexturl">次の㌻</a></div>
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/car/">新車・中古車検索プラス</a>&gt;<strong>$keyword</strong><br>
<font size=1 color="#E9E9E9">$keywordの新車情報・中古車情報です。$keywordの最新情報は、ディーラー,店舗にてご確認ください。<br>
Powered by <a href="http://webservice.recruit.co.jp/">カーセンサーnet Webサービス</a>
END_OF_HTML

	&html_footer($self);


	return;
}

sub _make_vc_tag(){
	my $url = shift;
	my $name = shift;

	my $e_url = escape($url);
	my $atag;
	$atag .=qq{<a href="$url">・・</a><br>};
	$atag .=qq{<a href="http://i.vcads.com/servlet/referral?guid=ON&vs=2536243&vp=879000105&vc_url=$e_url" >$name</a>};
	$atag .=qq{<img src="http://i.vcads.com/servlet/gifbanner?vs=2536243&vp=879000105" height="1" width="1" border="0">};
	return $atag;
}
1;
