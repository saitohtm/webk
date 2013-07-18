package Waao::Pages::Station;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Data;
use Waao::Html;
use Waao::Utility;
use Jcode;
use CGI qw( escape );

# /station/		topページ
# /list-area/station/pref-add1-add2/

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

	my ($pref, $city, $city2);
	my @areas = split(/-/,$self->{cgi}->param('p1'));
	($pref, $city, $city2) = @areas;

	if($city2){
		&_city3_select($self);
	}elsif($city){
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

	$self->{html_title} = qq{無料路線沿線検索};
	$self->{html_keywords} = qq{無料,路線沿線,住所,検索};
	$self->{html_description} = qq{無料の路線沿線検索。住所から路線沿線が検索できます。};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);

my $sth = $self->{dbi}->prepare(qq{select * from pref });
$sth->execute();
while(my @row = $sth->fetchrow_array) {
	my $str_encode = &str_encode($row[1]);
print << "END_OF_HTML";
<font color="#009525">》</font><a href="/list-area/station/$row[0]/">$row[1]</a><br>
END_OF_HTML
}

print << "END_OF_HTML";
<a href="/" accesskey=0>トップ</a>&gt;<a href="/zip/">路線沿線検索プラス</a>&gt;<strong>都道府県選択</strong><br>
<font size=1 color="#E9E9E9">路線沿線検索プラスは,住所から路線沿線を検索。無料で利用できます。<br>
END_OF_HTML

	&html_footer($self);

	return;
}

sub _city_select(){
	my $self = shift;

	my ($pref_code, $city, $city2);
	my @areas = split(/-/,$self->{cgi}->param('p1'));
	($pref_code, $city, $city2) = @areas;

	$self->{html_title} = qq{無料路線沿線検索};
	$self->{html_keywords} = qq{無料,路線沿線,住所,検索};
	$self->{html_description} = qq{無料の路線沿線検索。住所から路線沿線が検索できます。};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);

my $sth = $self->{dbi}->prepare(qq{ select rr_cd, rr_name from station where pref_cd = ? group by rr_cd} );
$sth->execute($pref_code);
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<font color="#009525">》</font><a href="/list-area/station/$pref_code-$row[0]/">$row[1]</a><br>
END_OF_HTML
}

print << "END_OF_HTML";
<a href="/" accesskey=0>トップ</a>&gt;<a href="/station/">路線沿線検索プラス</a><br>
<font size=1 color="#E9E9E9">路線沿線検索プラスは,住所から路線沿線を検索。無料で利用できます。<br>
END_OF_HTML

	&html_footer($self);

	return;
}

sub _city2_select(){
	my $self = shift;

	my ($pref_code, $rr_code, $line_code);
	my @areas = split(/-/,$self->{cgi}->param('p1'));
	($pref_code, $rr_code, $line_code) = @areas;

	$self->{html_title} = qq{無料路線沿線検索};
	$self->{html_keywords} = qq{無料,路線沿線,住所,検索};
	$self->{html_description} = qq{無料の路線沿線検索。住所から路線沿線が検索できます。};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);

my $sth = $self->{dbi}->prepare(qq{select rr_cd, rr_name, line_cd, line_name from station where pref_cd = ? and rr_cd = ? group by line_cd }  );
$sth->execute($pref_code, $rr_code);
while(my @row = $sth->fetchrow_array) {
	my $str_encode = &str_encode($row[0]);
print << "END_OF_HTML";
<font color="#009525">》</font><a href="/list-area/station/$pref_code-$row[0]-$row[2]/">$row[3]</a><br>
END_OF_HTML
}

print << "END_OF_HTML";
<a href="/" accesskey=0>トップ</a>&gt;<a href="/station/">路線沿線検索プラス</a>&gt;<br>
<font size=1 color="#E9E9E9">路線沿線検索プラスは,住所から路線沿線を検索。無料で利用できます。<br>
END_OF_HTML

	&html_footer($self);

	return;
}

sub _city3_select(){
	my $self = shift;

	my ($pref_code, $rr_code, $line_code);
	my @areas = split(/-/,$self->{cgi}->param('p1'));
	($pref_code, $rr_code, $line_code) = @areas;

	$self->{html_title} = qq{無料路線沿線検索};
	$self->{html_keywords} = qq{無料,路線沿線,住所,検索};
	$self->{html_description} = qq{無料の路線沿線検索。住所から路線沿線が検索できます。};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);

my $sth = $self->{dbi}->prepare(qq{select rr_cd, rr_name, line_cd, line_name, station_cd, station_name from station where pref_cd = ? and rr_cd = ? and line_cd = ? }  );
$sth->execute($pref_code, $rr_code, $line_code);
while(my @row = $sth->fetchrow_array) {
	my $str_encode = &str_encode($row[0]);
print << "END_OF_HTML";
<font color="#009525">》</font><a href="/list-detail/station/$row[4]/">$row[5]</a><br>
END_OF_HTML
}

print << "END_OF_HTML";
<a href="/" accesskey=0>トップ</a>&gt;<a href="/station/">路線沿線検索プラス</a>&gt;<br>
<font size=1 color="#E9E9E9">路線沿線検索プラスは,住所から路線沿線を検索。無料で利用できます。<br>
END_OF_HTML

	&html_footer($self);

	return;
}

sub _detail(){
	my $self = shift;

	my ($pref_code, $rr_code, $line_code);
	my @areas = split(/-/,$self->{cgi}->param('p1'));
	($pref_code, $rr_code, $line_code) = @areas;

my ($rr_cd, $rr_name, $line_cd, $line_name, $station_cd, $station_name);
my $sth = $self->{dbi}->prepare(qq{select rr_cd, rr_name, line_cd, line_name, station_cd, station_name from station where station_cd = ? }  );
$sth->execute($self->{cgi}->param('p1'));
while(my @row = $sth->fetchrow_array) {
	($rr_cd, $rr_name, $line_cd, $line_name, $station_cd, $station_name) = @row;
}

	$self->{html_title} = qq{$station_name 無料路線沿線検索};
	$self->{html_keywords} = qq{$station_name, $line_name, $rr_name,無料,路線沿線,住所,検索};
	$self->{html_description} = qq{$station_name 無料の路線沿線検索。住所から路線沿線が検索できます。};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);

	&html_table($self, qq{$station_name}, 0, 0);

print << "END_OF_HTML";
$hr
$ad
$hr
$station_name, $line_name, $rr_name
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/station/">路線沿線検索プラス</a>&gt;<strong>$station_name</strong><br>
<font size=1 color="#E9E9E9">路線沿線検索プラスは,住所から路線沿線を検索。無料で利用できます。<br>
END_OF_HTML

	&html_footer($self);

	return;
}

sub _top(){
	my $self = shift;

	$self->{html_title} = qq{沿線検索 路線・沿線一覧};
	$self->{html_keywords} = qq{無料,沿線検索,沿線,路線,検索};
	$self->{html_description} = qq{無料の路線・沿線検索。};

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
<img src="http://img.waao.jp/rosen.gif" width=120 height=28 alt="沿線・路線検索プラス"><font size=1 color="#FF0000">プラス</font>
</center>
$hr
<a href="/list-area/station/" accesskey=1>全国サーチ</a><br>
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
<a href="/" accesskey=0>トップ</a>&gt;<strong>路線・沿線検索プラス</strong><br>
<font size=1 color="#E9E9E9">路線・沿線検索プラスは,路線・沿線検索。無料で利用できます。<br>
END_OF_HTML

}
	&html_footer($self);

	return;
}
1;
