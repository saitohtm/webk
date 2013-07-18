package Waao::Pages::Town;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Data;
use Waao::Html;
use Waao::Utility;
use Jcode;
use CGI qw( escape );


sub dispatch(){
	my $self = shift;
	
	if($self->{cgi}->param('prefid')){
		&_area_search($self);
	}elsif($self->{cgi}->param('rrcd')){
		&_area_search($self);
	}elsif($self->{cgi}->param('station')){
		&_detail($self);
	}elsif($self->{cgi}->param('zippref')){
		&_zip_pref($self);
	}elsif($self->{cgi}->param('zipcity')){
		&_zip_city($self);
	}elsif($self->{cgi}->param('zipcode')){
		&_zip_detail($self);
	}elsif($self->{cgi}->param('q')){
#		&_search($self);
	}else{
		&_top($self);
	}

	return;
}

sub _area_search(){
	my $self = shift;
	my $pref = $self->{cgi}->param('prefid');
	my $city = $self->{cgi}->param('rrcd');
	my $city2 = $self->{cgi}->param('city2');

	if($city2){
		&_city3_select($self);
	}elsif($city){
		&_city2_select($self);
	}elsif($pref){
		&_city_select($self,$pref);
	}

	return;
}

sub _city_select(){
	my $self = shift;
	my $prefid = shift;

	my $pref_name;
my $sth = $self->{dbi}->prepare(qq{select name from pref where id = ?});
$sth->execute($prefid);
while(my @row = $sth->fetchrow_array) {
	$pref_name = $row[0];
}
	my $manshon = &html_mojibake_str("manshon");

	$self->{html_title} = qq{$pref_nameの町情報 -$pref_nameのタウンページ-};
	$self->{html_keywords} = qq{$pref_name,$pref_name,タウン情報,タウンページ,町};
	$self->{html_description} = qq{$pref_nameのタウン情報、タウン情報しなら$pref_nameのタウンページ};

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);

	&html_header($self);


print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">$pref_nameのタウン情報なら$pref_nameのタウンページ棈住んでる町$pref_nameのタウン情報プラス</font></marquee>
<center>
<font color="#FF0000">【</font>$pref_nameのタウン情報<font color="#FF0000">】</font>
</center>
$hr
<center>
$ad
</center>
$hr
<img src="http://img.waao.jp/ol03s.gif" width=46 height=52 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"><font color="#FF8000">沿線を選択</font><br>
<br clear="all" />
<font size=1>
END_OF_HTML

my $rr_name;
my $sth = $self->{dbi}->prepare(qq{ select rr_cd, rr_name, line_cd, line_name from station where pref_cd = ? group by line_cd} );
$sth->execute($prefid);
while(my @row = $sth->fetchrow_array) {
	if($rr_name ne $row[1]){
		$rr_name = $row[1];
print << "END_OF_HTML";
<font color="#FF8000">■</font>$row[3]<br>
END_OF_HTML
	}
print << "END_OF_HTML";
<font color="#FF8000">》</font><a href="/rrcd$row[2]/" title="$row[3]の賃貸マンション">$row[3]のタウン情報</a><br>
END_OF_HTML
}

print << "END_OF_HTML";
<img src="http://img.waao.jp/lamp1.gif" width=14 height=11><a href="/zippref$prefid/">$pref_nameの住所から探す</a>
$hr
<a href="/" title="タウン情報プラス">タウン情報プラス</a>&gt;<a href="/pref$prefid/">$pref_nameのタウン情報</a><br>
$hr
<font size=1 color="#E9E9E9">$pref_nameのタウン情報なら$pref_nameタウンページプラス。初めての$pref_nameでも安心のタウン情報</font>
$hr
END_OF_HTML

	&_footer($self);

	return;
}

sub _city2_select(){
	my $self = shift;
	my $line_code = $self->{cgi}->param('rrcd');
my $prefid;
my $line_cd;
my $line_name;
my $station_list;
my $sth = $self->{dbi}->prepare(qq{select rr_cd, rr_name, line_cd, line_name, pref_cd, station_cd, station_name from station where line_cd = ? }  );
$sth->execute($line_code);
while(my @row = $sth->fetchrow_array) {
	$prefid = $row[4] unless($prefid);
	$line_cd = $row[2];
	$line_name = $row[3];
	$station_list .= qq{<font color="#FF8000">》</font><a href="/station$row[5]/" title="$row[6]のタウン情報">$row[6]のタウン情報</a><br>};
}
my $pref_name;
my $sth = $self->{dbi}->prepare(qq{select name from pref where id = ?});
$sth->execute($prefid);
while(my @row = $sth->fetchrow_array) {
	$pref_name = $row[0];
}

	my $manshon = &html_mojibake_str("manshon");

	$self->{html_title} = qq{$line_nameのタウン情報 -$line_nameタウンページプラス-};
	$self->{html_keywords} = qq{$pref_name,$line_name,タウン情報,タウンページ,町};
	$self->{html_description} = qq{$line_nameのタウン情報、タウン情報ならタウンページプラス};

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);

	&html_header($self);
print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">$line_nameのタウン情報ならタウンページプラス一人暮らしに最高のタウン情報プラス</font></marquee>
<center>
<font color="#FF0000">【</font>$line_nameのタウン情報<font color="#FF0000">】</font>
</center>
$hr
<center>
$ad
</center>
$hr
<img src="http://img.waao.jp/ol03s.gif" width=46 height=52 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"><font color="#FF8000">駅を選択</font><br>
<br clear="all" />
<font size=1>
$station_list
END_OF_HTML

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>タウン情報プラス</a>&gt;<a href="/pref$prefid/">$pref_nameのタウン情報</a>&gt;$line_nameのタウン情報<br>
$hr
<font size=1 color="#E9E9E9">$line_nameのタウン情報ならタウンページプラス。初めての$line_nameでも安心のタウン情報</font>
$hr
END_OF_HTML

	&_footer($self);

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

	&_footer($self);

	return;
}

sub _detail(){
	my $self = shift;
	
	my $pv = ($self->{date_hour} * 360 + $self->{date_min} * 60);
	$pv = int($pv) + $self->{date_sec};	
	
my ($rr_cd, $rr_name, $line_cd, $line_name, $station_cd, $station_name, $prefid);
my $sth = $self->{dbi}->prepare(qq{select rr_cd, rr_name, line_cd, line_name, station_cd, station_name,pref_cd from station where station_cd = ? limit 1}  );
$sth->execute($self->{cgi}->param('station'));
while(my @row = $sth->fetchrow_array) {
	($rr_cd, $rr_name, $line_cd, $line_name, $station_cd, $station_name, $prefid) = @row;
}
my $pref_name;
my $sth = $self->{dbi}->prepare(qq{select name from pref where id = ?});
$sth->execute($prefid);
while(my @row = $sth->fetchrow_array) {
	$pref_name = $row[0];
}
	my $manshon = &html_mojibake_str("manshon");

	$self->{html_title} = qq{$station_name周辺のタウン情報 -$station_nameタウンページプラス-};
	$self->{html_keywords} = qq{$station_name, $line_name, $rr_name,タウン情報,タウンページ,町情報,周辺};
	$self->{html_description} = qq{$station_name周辺のタウン情報。$station_name周辺のタウン情報ならタウンページプラス};

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);
	&html_header($self);

	my $yicha_link_station = &html_yicha_url($self, $station_name, 'p');
	my $yicha_link_suumo = &html_yicha_url($self, "SUUMO", 'p');
	my $yicha_link_homes = &html_yicha_url($self, "HOMES", 'p');
	my $yicha_link_chintai = &html_yicha_url($self, "CHINTAI", 'p');

print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">$station_nameのタウン情報ならタウン情報プラス$station_name周辺のタウン情報ならタウン情報プラス</font></marquee>
<center>
<font color="#FF0000">【</font>$station_name周辺のタウン情報<font color="#FF0000">】</font>
</center>
$hr
<center>
$ad
</center>
$hr
<table border=0 bgcolor="#000000" width="100%"><tr><td>
<center>
<img src="http://img.waao.jp/kya-.gif" width=15 height=15><font color="#FF0000">本日の閲覧数$pv</font>
</center>
</td></tr></table>
<img src="http://img.waao.jp/ol03s.gif" width=46 height=52 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"><font color="#FF8000">$station_nameのタウン情報</font><br>
<br clear="all" />
<img src="http://img.waao.jp/kaowink02.gif" width=53 height=15><a href="$yicha_link_station">$station_name周辺情報</a><br>
END_OF_HTML

my ($datacnt,$keyworddata) = &get_keyword($self,$station_name);
# wiki
my ($datacnt,$wikipedia) = &get_wiki($self, $keyworddata->{id}, $keyworddata->{wiki_id});
# 画像
my ($datacnt,$photodata) = &get_photo($self, $keyworddata->{id});

my $keyword = $keyworddata->{keyword};
my $keyword_encode = &str_encode($keyworddata->{keyword});

print << "END_OF_HTML";
<img src="$photodata->{url}"  width=125  style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left">
<a href="http://waao.jp/$keyword_encode/photolist/0-1/">画像一覧</a><br>

<br clear="all" />
$hr
$wikipedia->{wikipedia}<br>
$wikipedia->{linklist}<br>
$hr
END_OF_HTML


# Q&A
my $sth = $self->{dbi}->prepare(qq{select id, question, bestanswer, url from qanda where keywordid = ?} );
$sth->execute( $keyworddata->{id} );
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
$row[2]<br>
$row[3]<br>
END_OF_HTML
}

# 掲示板

# サイト
my $sth = $self->{dbi}->prepare(qq{select id, title, url, comment from sitelist where keyword_id = ?} );
$sth->execute( $keyworddata->{id} );
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<a href="$row[2]">$row[1]</a><br>
END_OF_HTML
}


print << "END_OF_HTML";
$hr
<a href="/" title="タウンページプラス">タウンページプラス</a>&gt;<a href="/pref$prefid/" title="$pref_nameのタウンページプラス">$pref_nameのタウン情報</a>&gt;<a href="/rrcd$line_cd/" title="$line_nameのタウン情報">$line_nameのタウン情報</a>&gt;$station_nameのタウン情報<br>
$hr
<font size=1 color="#E9E9E9">$station_nameのタウン情報ならタウンページプラス。初めての$station_nameでも安心のタウン情報</font>
$hr
END_OF_HTML

	&_footer($self);

	return;
}

sub _top(){
	my $self = shift;

	my $manshon = &html_mojibake_str("manshon");

	$self->{html_title} = qq{タウンページプラス 一人暮らしのタウン情報ならココ};
	$self->{html_keywords} = qq{タウンページ,タウン情報,一人暮らし};
	$self->{html_description} = qq{一人暮らしのタウン情報は、タウンページプラス};

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);

	&html_header($self);

print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">一人暮らしのタウン情報ならタウン情報プラス住んでる町のタウン情報をを探そう</font></marquee>
<center>
<img src="http://img.waao.jp/chintai.gif" width=120 height=28 alt="タウンページプラス"><font size=1 color="#FF0000">β版</font>
</center>
$hr
<center>
$ad
</center>
$hr
<img src="http://img.waao.jp/ol03s.gif" width=46 height=52 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"><font color="#FF8000">エリアを選択</font><br>
<br clear="all" />
<font size=1>
END_OF_HTML

my $sth = $self->{dbi}->prepare(qq{select id, name from pref });
$sth->execute();
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<font color="#FF8000">》</font><a href="/pref$row[0]/" title="$row[1]のタウン情報">$row[1]のタウン情報</a><br>
END_OF_HTML
}

print << "END_OF_HTML";
</font>
$hr
<a href="http://chintai.goo.to/" title="賃貸プラス">賃貸プラス</a><br>
<a href="/" accesskey=0>タウンページプラス</a><br>
$hr
<font size=1 color="#E9E9E9">人暮らしのタウン情報ならタウンページプラス。初めての一人暮らしでも安心</font>
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


sub _zip_pref(){
	my $self = shift;
	my $prefid = $self->{cgi}->param('zippref');

	my $pref_name;
my $sth = $self->{dbi}->prepare(qq{select name from pref where id = ?});
$sth->execute($prefid);
while(my @row = $sth->fetchrow_array) {
	$pref_name = $row[0];
}
	my $manshon = &html_mojibake_str("manshon");

	$self->{html_title} = qq{$pref_nameの賃貸$manshon -$pref_name一人暮らし特集-};
	$self->{html_keywords} = qq{$pref_name,$pref_name$manshon,$manshon,賃貸,一人暮らし,部屋探し};
	$self->{html_description} = qq{$pref_nameの一人暮らし用$manshon、お部屋探しなら賃貸プラス};

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);

	&html_header($self);


print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">$pref_nameの一人暮らし賃貸マンションなら賃貸プラス棈一人暮らしに最高の$pref_name賃貸情報は賃貸プラス</font></marquee>
<center>
<font color="#FF0000">【</font>$pref_nameの賃貸マンション<font color="#FF0000">】</font>
</center>
$hr
<center>
$ad
</center>
$hr
<img src="http://img.waao.jp/ol03s.gif" width=46 height=52 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"><font color="#FF8000">住みたい沿線を選択</font><br>
<br clear="all" />
<font size=1>
END_OF_HTML

my $sth = $self->{dbi}->prepare(qq{ select zip, addr2 from zip where addr1 = ? group by addr2} );
$sth->execute($pref_name);
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<font color="#FF8000">》</font><a href="/zipcity$row[0]/" title="$row[1]の賃貸マンション">$row[1]の賃貸マンション</a><br>
END_OF_HTML
}

print << "END_OF_HTML";
<img src="http://img.waao.jp/lamp1.gif" width=14 height=11><a href="/pref$prefid/">$pref_nameの駅から探す</a>
$hr
<a href="/" title="賃貸プラス">賃貸プラス</a>&gt;<a href="/zippref$prefid/">$pref_nameの賃貸マンション</a><br>
$hr
<font size=1 color="#E9E9E9">$pref_nameの人暮らしの賃貸マンションなら賃貸プラス。初めての$pref_nameの部屋探しは賃貸プラス</font>
$hr
END_OF_HTML

	&_footer($self);

	return;
}

sub _zip_city(){
	my $self = shift;
	my $zipcode = $self->{cgi}->param('zipcity');

my ($addr1, $addr2);
my $sth = $self->{dbi}->prepare(qq{select addr1, addr2 from zip where zip = ? limit 1});
$sth->execute($zipcode);
while(my @row = $sth->fetchrow_array) {
	($addr1, $addr2) = @row;
}

my $pref_name = $addr1;
my $prefid;
my $sth = $self->{dbi}->prepare(qq{select id from pref where name= ?});
$sth->execute($pref_name);
while(my @row = $sth->fetchrow_array) {
	$prefid = $row[0];
}
	my $manshon = &html_mojibake_str("manshon");

	$self->{html_title} = qq{$addr2の賃貸$manshon -$addr2一人暮らし特集-};
	$self->{html_keywords} = qq{$addr2,$addr2$manshon,$manshon,賃貸,一人暮らし,部屋探し};
	$self->{html_description} = qq{$addr2の一人暮らし用$manshon、お部屋探しなら賃貸プラス};

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);

	&html_header($self);


print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">$addr2の一人暮らし賃貸マンションなら賃貸プラス棈一人暮らしに最高の$addr2賃貸情報は賃貸プラス</font></marquee>
<center>
<font color="#FF0000">【</font>$addr2の賃貸マンション<font color="#FF0000">】</font>
</center>
$hr
<center>
$ad
</center>
$hr
<img src="http://img.waao.jp/ol03s.gif" width=46 height=52 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"><font color="#FF8000">住みたい住所を選択</font><br>
<br clear="all" />
<font size=1>
END_OF_HTML

my $addr3;
my $sth = $self->{dbi}->prepare(qq{ select zip, addr2, addr3 from zip where addr2 = ?} );
$sth->execute($addr2);
while(my @row = $sth->fetchrow_array) {
$addr3 = $row[2];
print << "END_OF_HTML";
<font color="#FF8000">》</font><a href="/zipcode$row[0]/" title="$row[1]$row[2]の賃貸マンション">$row[1]$row[2]の賃貸マンション</a><br>
END_OF_HTML
}

print << "END_OF_HTML";
$hr
<a href="/" title="賃貸プラス">賃貸プラス</a>&gt;<a href="/zippref$prefid/">$pref_nameの賃貸マンション</a>&gt;$addr2$addr3の賃貸マンション<br>
$hr
<font size=1 color="#E9E9E9">$addr2$addr3の人暮らしの賃貸マンションなら賃貸プラス。初めての$addr2$addr3の部屋探しは賃貸プラス</font>
$hr
END_OF_HTML

	&_footer($self);

	return;
}


sub _zip_detail(){
	my $self = shift;
	my $zipcode = $self->{cgi}->param('zipcode');
	
	my $pv = ($self->{date_hour} * 360 + $self->{date_min} * 60);
	$pv = int($pv) + $self->{date_sec};	

my ($addr1, $addr2);
my $sth = $self->{dbi}->prepare(qq{select addr1, addr2 from zip where zip = ? limit 1});
$sth->execute($zipcode);
while(my @row = $sth->fetchrow_array) {
	($addr1, $addr2) = @row;
}

my $pref_name = $addr1;
my $prefid;
my $sth = $self->{dbi}->prepare(qq{select id from pref where name= ?});
$sth->execute($pref_name);
while(my @row = $sth->fetchrow_array) {
	$prefid = $row[0];
}

	
	my $manshon = &html_mojibake_str("manshon");

	$self->{html_title} = qq{$addr1$addr2の賃貸$manshon -$addr1$addr2一人暮らし特集-};
	$self->{html_keywords} = qq{$addr1, $addr2,$manshon,賃貸,一人暮らし,部屋探し};
	$self->{html_description} = qq{$addr1$addr2の一人暮らし用$manshon、お部屋探しなら賃貸プラス};

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);
	&html_header($self);

	my $yicha_link_station = &html_yicha_url($self, "$addr1$addr2", 'p');
	my $yicha_link_suumo = &html_yicha_url($self, "SUUMO", 'p');
	my $yicha_link_homes = &html_yicha_url($self, "HOMES", 'p');
	my $yicha_link_chintai = &html_yicha_url($self, "CHINTAI", 'p');

print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">$addr1$addr2の一人暮らし賃貸マンションなら賃貸プラス棈一人暮らしに最高の$addr1$addr2賃貸情報は賃貸プラス</font></marquee>
<center>
<font color="#FF0000">【</font>$addr1$addr2の賃貸マンション<font color="#FF0000">】</font>
</center>
$hr
<center>
$ad
</center>
$hr
<table border=0 bgcolor="#000000" width="100%"><tr><td>
<center>
<img src="http://img.waao.jp/kya-.gif" width=15 height=15><font color="#FF0000">本日の閲覧数$pv</font>
</center>
</td></tr></table>
<img src="http://img.waao.jp/ol03s.gif" width=46 height=52 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"><font color="#FF8000">$addr1$addr2の賃貸情報</font><br>
<br clear="all" />
<font size=1 color="#FF0000">$addr1$addr2の賃貸マンション物件が検索できませんでしたm(_ _)m</font><br>
<img src="http://img.waao.jp/kaowink02.gif" width=53 height=15><a href="$yicha_link_station">$addr1$addr2周辺情報</a><br>
END_OF_HTML

if($self->{real_mobile}){

print << "END_OF_HTML";
$hr
<img src="http://img.waao.jp/ol01s.gif" width=38 height=53 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"><font color="#FF8000">▼安心の賃貸ポータルサイト▼</font><br>
<br clear="all" />
$hr
偂<a href="$yicha_link_suumo">スーモ(SUUMO)</a><br>
<img src="http://suumo.jp/edit/rewrite/help/img/logo_suumo_s.gif" width="88" height="31" border="0"><br>
偂<a href="$yicha_link_homes">ホームズ(HOMES)</a><br>
<img src="http://img.waao.jp/homes.gif" width=135 height=40><br>
偂<a href="$yicha_link_chintai">CHINTAI</a><br>
<img src="http://img.waao.jp/chintaibanner.gif" width=135 height=45><br>
$hr
<img src="http://img.waao.jp/m2009.gif" width=48 height=9>アットホーム<br>
<center>
<a href="http://smaf.jp/128480342c84573?guid=ON">オススメ部屋探し<br>☆全国版☆</a>
</center>
$hr
<img src="http://img.waao.jp/m2009.gif" width=48 height=9>アドパーク<br>
<center>
<a href="http://smaf.jp/193253084c113698?guid=ON"><img src="http://img01.smaf.jp/b/667/5768667/m/113698.gif?m=408004" width="192" height="53" border="0"></a>
</center>
$hr
<img src="http://img.waao.jp/m2009.gif" width=48 height=9>ホームメイト<br>
<center>
<a href="http://smart-c.jp/c?i=2IrEjz3v4qvr001a7&guid=ON"><img src="http://image.smart-c.jp/i?i=2IrEjz3v4qvr001a7"></a>
</center>
$hr
<img src="http://img.waao.jp/m2009.gif" width=48 height=9>HOME4U<br>
<center>
<a href="http://smart-c.jp/c?i=0LQlbT2jPlQK001a7&guid=ON"><img src="http://image.smart-c.jp/i?i=0LQlbT2jPlQK001a7"></a>
</center>
$hr
<center>
<a href="http://smart-c.jp/c?i=07mjQ630dAGk001a7&guid=ON"><img src="http://image.smart-c.jp/i?i=07mjQ630dAGk001a7"></a>
</center>
END_OF_HTML

}else{

print << "END_OF_HTML";
現在、$addr1$addr2周辺の賃貸マンション物件・賃貸アパート物件の掲載が終了していますm(_ _)m
END_OF_HTML

}

print << "END_OF_HTML";
$hr
<a href="/" title="賃貸プラス">賃貸プラス</a>&gt;<a href="/zippref$prefid/" title="$pref_nameの賃貸マンション">$pref_nameの賃貸マンション</a>&gt;<a href="/zipcity$zipcode/" title="$addr1の賃貸マンション">$addr1の賃貸マンション</a>&gt;$addr1$addr2の賃貸マンション<br>
$hr
<font size=1 color="#E9E9E9">$addr1$addr2の人暮らしの賃貸マンションなら賃貸プラス。初めての$addr1$addr2の部屋探しは賃貸プラス</font>
$hr
END_OF_HTML

	&_footer($self);

	return;
}

1;