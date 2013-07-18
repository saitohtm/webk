package Waao::Pages::Zip;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Data;
use Waao::Html;
use Waao::Utility;
use Jcode;
use CGI qw( escape );

# /zip/		topページ
# /zip.html?zipcode=	search
# /list-area/zip/pref-add1-add2/
# /list-detail/zip/zipid/

sub dispatch(){
	my $self = shift;
	
	if($self->{cgi}->param('q') eq 'list-area'){
		&_area_search($self);
	}elsif($self->{cgi}->param('q') eq 'list-detail'){
		&_detail($self);
	}elsif($self->{cgi}->param('q')){
#		&_search($self);
	}else{
		&_top($self);
	}

	return;
}

sub _area_search(){
	my $self = shift;

	my ($pref, $city);
	my @areas = split(/-/,$self->{cgi}->param('p1'));
	($pref, $city) = @areas;

	if($city){
		&_city2_select($self);
	}elsif($pref){
		&_city_select($self);
	}else{
		&_pref_select($self);
	}

	return;
}

sub _pref_select(){
	my $self = shift;

	$self->{html_title} = qq{郵便番号検索};
	$self->{html_keywords} = qq{郵便番号,住所,検索};
	$self->{html_description} = qq{郵便番号検索。住所から郵便番号が検索できます。};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);

print << "END_OF_HTML";
<center>
郵便番号検索
</center>
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

my $sth = $self->{dbi}->prepare(qq{select * from pref });
$sth->execute();
while(my @row = $sth->fetchrow_array) {
	my $str_encode = &str_encode($row[1]);
print << "END_OF_HTML";
<font color="#009525">》</font><a href="/list-area/zip/$str_encode--/">$row[1]</a><br>
END_OF_HTML
}

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/zip/" title="郵便番号検索">郵便番号検索プラス</a>&gt;<strong>都道府県選択</strong><br>
<font size=1 color="#E9E9E9">郵便番号検索プラスは,住所から郵便番号を検索。無料で利用できます。<br>
END_OF_HTML

	&html_footer($self);

	return;
}

sub _city_select(){
	my $self = shift;

	my ($pref, $city, $city2);
	my @areas = split(/-/,$self->{cgi}->param('p1'));
	($pref, $city, $city2) = @areas;

	$self->{html_title} = qq{郵便番号検索 - $pref };
	$self->{html_keywords} = qq{$pref,郵便番号,住所,検索};
	$self->{html_description} = qq{$prefの郵便番号検索。住所から郵便番号が検索できます。};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);

print << "END_OF_HTML";
<center>
$prefの郵便番号
</center>
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

my $sth = $self->{dbi}->prepare(qq{ select addr2 from zip where addr1 = ? group by addr2},  );
$sth->execute($pref);
while(my @row = $sth->fetchrow_array) {
	my $str_encode = &str_encode($row[0]);
	my $pref_encode = &str_encode($pref);
print << "END_OF_HTML";
<font color="#009525">》</font><a href="/list-area/zip/$pref_encode-$str_encode-/">$row[0]</a><br>
END_OF_HTML
}

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/zip/" title="郵便番号検索">郵便番号検索プラス</a>&gt;<strong>$pref</strong><br>
<font size=1 color="#E9E9E9">郵便番号検索プラスは,住所から郵便番号を検索。無料で利用できます。<br>
END_OF_HTML

	&html_footer($self);

	return;
}

sub _city2_select(){
	my $self = shift;

	my ($pref, $city, $city2);
	my @areas = split(/-/,$self->{cgi}->param('p1'));
	($pref, $city, $city2) = @areas;

	$self->{html_title} = qq{$pref$city 郵便番号検索};
	$self->{html_keywords} = qq{$pref,$city,無料,郵便番号,住所,検索};
	$self->{html_description} = qq{$pref$cityの郵便番号検索。住所から郵便番号が検索できます。};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);

print << "END_OF_HTML";
<center>
$pref$cityの郵便番号
</center>
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

	my $pref_encode = &str_encode($pref);
	my $city_encode = &str_encode($city);
my $sth = $self->{dbi}->prepare(qq{ select addr3,zip from zip where addr1 = ? and addr2 = ? },  );
$sth->execute($pref, $city);
while(my @row = $sth->fetchrow_array) {
	my $str_encode = &str_encode($row[0]);
print << "END_OF_HTML";
<font color="#009525">》</font><a href="/list-detail/zip/$row[1]/">$row[0]</a><br>
END_OF_HTML
}

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/zip/" title="郵便番号検索">郵便番号検索プラス</a>&gt;<a href="/list-area/zip/$pref_encode-$city_encode-/">$pref$city</a>&gt;<strong>$pref$city</strong><br>
<font size=1 color="#E9E9E9">郵便番号検索プラスは,住所から郵便番号を検索。無料で利用できます。<br>
END_OF_HTML

	&html_footer($self);

	return;
}

sub _detail(){
	my $self = shift;

	my ($zip, $addr1, $addr2, $addr3);
	my $sth = $self->{dbi}->prepare( qq{select zip, addr1, addr2, addr3 from zip where zip = ? });
	$sth->execute($self->{cgi}->param('p1'));
	while(my @row = $sth->fetchrow_array) {
		($zip, $addr1, $addr2, $addr3) = @row;
	}
	my $encodeword = &str_encode("$addr1$addr2$addr3");

	my $seokey;
	$seokey .= $addr1;
	$seokey .= $addr2;
	$seokey .= $addr3;

	$self->{html_title} = qq{郵便番号検索 $seokey};
	$self->{html_keywords} = qq{$zip, $addr1, $addr2, $addr3,無料,郵便番号,住所,検索};
	$self->{html_description} = qq{$seokey 無料の郵便番号検索。住所から郵便番号が検索できます。};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);

	&html_table($self, qq{$seokey}, 0, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
$zip<br>
$addr1$addr2$addr3<br>
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/zip/" title="郵便番号検索">郵便番号検索プラス</a>&gt;<strong>都道府県選択</strong><br>
<font size=1 color="#E9E9E9">郵便番号検索プラスは,住所から郵便番号を検索。無料で利用できます。<br>
END_OF_HTML

	&html_footer($self);

	return;
}

sub _top(){
	my $self = shift;

	$self->{html_title} = qq{郵便番号検索 住所・郵便番号から検索できます};
	$self->{html_keywords} = qq{無料,郵便番号,住所,検索};
	$self->{html_description} = qq{郵便番号検索[無料]。住所から郵便番号が検索できます。};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);

if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML
	
}else{# xhmlt chtml

print << "END_OF_HTML";
<center>
<img src="http://img.waao.jp/yuubin.gif" width=120 height=28 alt="郵便番号検索プラス"><font size=1 color="#FF0000">プラス</font>
</center>


<center>
<font color="red">〒</font>郵便番号から探す<BR>
<form action="/zip.html" method="POST" >
<input type="text" name="p1" value="" size="7">
<input type="hidden" name="q" value="list-detail">
<input type="hidden" name="guid" value="ON">
<br>
<font size=1>ex)9999999(-なし)</font><br>
<input type="submit" value="郵便番号検索プラス"><br />
</form>
</center>

<center>
<font size=1>住所から<font color="#FF0000">マルチ検索</font></font>
</center>
$hr
<center>
$ad
</center>
$hr
<form name="form" action="zip.html" method="post" >
住所から探す<BR>
<SELECT NAME="p1">
END_OF_HTML

my $sth = $self->{dbi}->prepare(qq{select * from pref });
$sth->execute();
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<OPTION VALUE="$row[1]">$row[1]
END_OF_HTML
}
	
print << "END_OF_HTML";
</SELECT><br>
<font size=1>市区町村</font><br>
<input type="text" name="address" maxlength="8" size="8"><BR>
<input type="submit" value=" 検索 ">
</form>
$hr
<a href="/list-area/zip/" accesskey=1>郵便番号サーチ</a><br>
<!--
<a href="/coupon_mac/" accesskey=2>マクドナルドクーポン</a><br>
<a href="/list-genre/mansion/" accesskey=3>ジャンル別検索</a><br>
<a href="/list-special/mansion/" accesskey=4>オススメ特集</a><br>
<a href="" accesskey=5></a><br>
<a href="" accesskey=6></a><br>
<a href="" accesskey=7></a><br>
<a href="" accesskey=8></a><br>
<a href="" accesskey=9></a><br>
-->
$hr
<a href="/" accesskey=0>トップ</a>&gt;<strong>郵便番号検索プラス</strong><br>
<font size=1 color="#E9E9E9">郵便番号検索プラスは,住所から郵便番号を検索。無料で利用できます。<br>
END_OF_HTML

}
	&html_footer($self);

	return;
}
1;
