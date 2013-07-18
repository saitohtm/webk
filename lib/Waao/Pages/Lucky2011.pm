package Waao::Pages::Lucky2011;
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
	
	if($self->{cgi}->param('prefid')){
		&_area_search($self);
	}elsif($self->{cgi}->param('rrcd')){
		&_area_search($self);
	}elsif($self->{cgi}->param('station')){
		&_detail($self);
	}elsif($self->{cgi}->param('hatsumode')){
		&_hatsumode_detail($self);
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

	$self->{html_title} = qq{初詣神社ナビ2011 -$pref_nameの初詣オススメ神社-};
	$self->{html_keywords} = qq{初詣,$pref_name,$pref_nameの初詣スポット,神社,場所};
	$self->{html_description} = qq{初詣神社ナビ2011 $pref_nameの初詣オススメ神社};

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);

	&html_header($self);


print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">$pref_nameの初詣スポット・神社なら初詣ナビ2011棈</font></marquee>
<center>
<font color="#FF0000">【</font>$pref_nameの初詣スポット<font color="#FF0000">】</font>
</center>
$hr
<center>
$ad
</center>
$hr
オススメ初詣<br>
END_OF_HTML

my $sth = $self->{dbi}->prepare( qq{select id,name,reeki,pref,pref_name,address,station from hatsumoude where pref = ? });
$sth->execute($prefid);
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<font color="#FF8000">》</font><a href="/hatsumode$row[0]/" title="$row[1]">$row[1]</a><br>
END_OF_HTML
}


print << "END_OF_HTML";
$hr
<img src="http://img.waao.jp/ol4_1b.gif" width=40 height=50 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"><font color="#FF8000">沿線を選択</font><br>
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
<font color="#FF8000">》</font><a href="/rrcd$row[2]/" title="$row[3]の初詣スポット">$row[3]の初詣スポット</a><br>
END_OF_HTML
}

print << "END_OF_HTML";
<img src="http://img.waao.jp/lamp1.gif" width=14 height=11><a href="/zippref$prefid/">$pref_nameの住所から探す</a>
$hr
<a href="/" title="一人暮らし.com">初詣ナビ</a>&gt;<a href="/pref$prefid/">$pref_nameの初詣スポット</a><br>
$hr
<font size=1 color="#E9E9E9">$pref_nameの初詣スポットなら初詣ナビ</font>
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
	$station_list .= qq{<font color="#FF8000">》</font><a href="/station$row[5]/" title="$row[6]の初詣ナビ">$row[6]の初詣ナビ</a><br>};
}
my $pref_name;
my $sth = $self->{dbi}->prepare(qq{select name from pref where id = ?});
$sth->execute($prefid);
while(my @row = $sth->fetchrow_array) {
	$pref_name = $row[0];
}

	my $manshon = &html_mojibake_str("manshon");

	$self->{html_title} = qq{初詣ナビ2011 -$line_nameの初詣スポット-};
	$self->{html_keywords} = qq{初詣,$pref_name,$line_name,神社,ご利益,交通};
	$self->{html_description} = qq{$line_nameの初詣スポット・神社のことなら初詣ナビ};

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);

	&html_header($self);
print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">$line_nameの初詣スポットなら初詣ナビ棈</font></marquee>
<center>
<font color="#FF0000">【</font>$line_nameの初詣ナビ<font color="#FF0000">】</font>
</center>
$hr
<center>
$ad
</center>
$hr
<img src="http://img.waao.jp/ol4_1b.gif" width=40 height=50 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"><font color="#FF8000">駅を選択</font><br>
<br clear="all" />
<font size=1>
$station_list
END_OF_HTML

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>初詣ナビ</a>&gt;<a href="/pref$prefid/">$pref_nameの初詣スポット</a>&gt;$line_nameの初詣スポット貸<br>
$hr
<font size=1 color="#E9E9E9">$line_nameの初詣スポットなら初詣ナビ。$line_nameの初詣スポットご利益・交通情報など</font>
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

	$self->{html_title} = qq{初詣ナビ2011 -$station_nameの初詣スポット-};
	$self->{html_keywords} = qq{初詣,$station_name, $line_name, $rr_name,$manshon,スポット,神社};
	$self->{html_description} = qq{$station_nameの初詣スポット・神社情報は初詣ナビ2011};

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);
	&html_header($self);

	my $yicha_link_station = &html_yicha_url($self, "初詣 $station_name", 'p');

print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">$station_nameの初詣スポットなら初詣ナビ棈</font></marquee>
<center>
<font color="#FF0000">【</font>$station_nameの初詣スポット<font color="#FF0000">】</font>
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
<img src="http://img.waao.jp/ol4_1b.gif" width=40 height=50 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"><font color="#FF8000">$station_nameの初詣スポット</font><br>
<br clear="all" />
<font size=1 color="#FF0000">↓$station_nameの初詣スポットはココから</font><br>
<img src="http://img.waao.jp/kaowink02.gif" width=53 height=15><a href="$yicha_link_station">$station_nameの初詣スポット</a><br>
END_OF_HTML


print << "END_OF_HTML";
$hr
<a href="http://town.goo.to/station$station_cd/">$station_nameのタウン情報</a>
$hr
<a href="/" title="初詣ナビ">初詣ナビ</a>&gt;<a href="/pref$prefid/" title="$pref_nameの初詣スポット">$pref_nameの初詣ナビ</a>&gt;<a href="/rrcd$line_cd/" title="$line_nameの初詣ナビ">$line_nameの初詣スポット</a>&gt;$station_nameの初詣スポット<br>
$hr
<font size=1 color="#E9E9E9">$station_nameの初詣スポットなら初詣ナビ。初めての$station_nameの初詣はここ</font>
$hr
END_OF_HTML

	&_footer($self);

	return;
}

sub _top(){
	my $self = shift;

	my $manshon = &html_mojibake_str("manshon");

	$self->{html_title} = qq{初詣ナビ2011 最寄の初詣スポットが検索できます};
	$self->{html_keywords} = qq{初詣,スポット,神社};
	$self->{html_description} = qq{初詣ナビ2011 最寄の駅、住所から初詣スポットが検索できます！};

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);

	&html_header($self);

print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">最寄の初詣スポットを探すなら初詣ナビ棈</font></marquee>
<center>
<img src="http://img.waao.jp/lucky2011logo.gif" width=120 height=28 alt="初詣ナビ"><font size=1 color="#FF0000">β版</font>
</center>
$hr
<center>
$ad
</center>
$hr
<img src="http://img.waao.jp/ol4_1b.gif" width=40 height=50 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"><font color="#FF8000">エリアを選択</font><br>
<br clear="all" />
<font size=1>
END_OF_HTML

my $sth = $self->{dbi}->prepare(qq{select id, name from pref });
$sth->execute();
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<font color="#FF8000">》</font><a href="/pref$row[0]/" title="$row[1]の初詣スポット">$row[1]の初詣スポット</a><br>
END_OF_HTML
}

print << "END_OF_HTML";
</font>
$hr
<a href="/" accesskey=0>初詣ナビ2011</a><br>
$hr
<font size=1 color="#E9E9E9">初詣ナビ2011。最寄の初詣スポットを探すなら初詣ナビ2011</font>
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

	$self->{html_title} = qq{初詣ナビ -$pref_nameの初詣スポット-};
	$self->{html_keywords} = qq{初詣,$pref_name,$manshon,神社};
	$self->{html_description} = qq{$pref_nameの初詣スポットなら初詣ナビ2011};

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);

	&html_header($self);


print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">$pref_nameの初詣スポットなら初詣ナビ棈</font></marquee>
<center>
<font color="#FF0000">【</font>$pref_nameの初詣ナビ<font color="#FF0000">】</font>
</center>
$hr
<center>
$ad
</center>
$hr
<img src="http://img.waao.jp/ol4_1b.gif" width=40 height=50 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"><font color="#FF8000">沿線を選択</font><br>
<br clear="all" />
<font size=1>
END_OF_HTML

my $sth = $self->{dbi}->prepare(qq{ select zip, addr2 from zip where addr1 = ? group by addr2} );
$sth->execute($pref_name);
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<font color="#FF8000">》</font><a href="/zipcity$row[0]/" title="$row[1]の初詣スポット">$row[1]の初詣スポット</a><br>
END_OF_HTML
}

print << "END_OF_HTML";
<img src="http://img.waao.jp/lamp1.gif" width=14 height=11><a href="/pref$prefid/">$pref_nameの駅から探す</a>
$hr
<a href="/" title="初詣ナビ">初詣ナビ</a>&gt;<a href="/zippref$prefid/">$pref_nameの初詣スポット</a><br>
$hr
<font size=1 color="#E9E9E9">$pref_nameの初詣スポットなら初詣ナビ。最寄の初詣スポットが探せます</font>
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

	$self->{html_title} = qq{初詣ナビ $addr2の初詣スポット};
	$self->{html_keywords} = qq{$addr2,初詣,神社};
	$self->{html_description} = qq{$addr2の初詣スポットなら初詣ナビ};

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);

	&html_header($self);


print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">$addr2の初詣スポットなら初詣ナビ棈</font></marquee>
<center>
<font color="#FF0000">【</font>$addr2の初詣スポット<font color="#FF0000">】</font>
</center>
$hr
<center>
$ad
</center>
$hr
<img src="http://img.waao.jp/ol4_1b.gif" width=40 height=50 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"><font color="#FF8000">住所を選択</font><br>
<br clear="all" />
<font size=1>
END_OF_HTML

my $addr3;
my $sth = $self->{dbi}->prepare(qq{ select zip, addr2, addr3 from zip where addr2 = ?} );
$sth->execute($addr2);
while(my @row = $sth->fetchrow_array) {
$addr3 = $row[2];
print << "END_OF_HTML";
<font color="#FF8000">》</font><a href="/zipcode$row[0]/" title="$row[1]$row[2]の初詣スポット">$row[1]$row[2]の初詣スポット</a><br>
END_OF_HTML
}

print << "END_OF_HTML";
$hr
<a href="/" title="初詣ナビ">初詣ナビ</a>&gt;<a href="/zippref$prefid/">$pref_nameの初詣スポット</a>&gt;$addr2$addr3の初詣ナビ<br>
$hr
<font size=1 color="#E9E9E9">$addr2$addr3の初詣スポットなら初詣ナビ。初めての$addr2$addr3の初詣なら</font>
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

	$self->{html_title} = qq{初詣ナビ $addr1$addr2の初詣スポット};
	$self->{html_keywords} = qq{初詣,$addr1, $addr2};
	$self->{html_description} = qq{$addr1$addr2の初詣スポットなら、初詣ナビ};

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);
	&html_header($self);

	my $yicha_link_station = &html_yicha_url($self, "初詣 $addr1$addr2", 'p');

print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">$addr1$addr2の初詣スポットなら初詣ナビ棈</font></marquee>
<center>
<font color="#FF0000">【</font>$addr1$addr2の初詣スポット<font color="#FF0000">】</font>
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
<img src="http://img.waao.jp/ol4_1b.gif" width=40 height=50 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"><font color="#FF8000">$addr1$addr2の初詣スポット</font><br>
<br clear="all" />
<font size=1 color="#FF0000">↓$addr1$addr2の初詣スポットはコチラ</font><br>
<img src="http://img.waao.jp/kaowink02.gif" width=53 height=15><a href="$yicha_link_station">$addr1$addr2の初詣スポット</a><br>
END_OF_HTML

print << "END_OF_HTML";
$hr
<a href="http://town.goo.to/zipcode$zipcode/">$addr1$addr2のタウン情報</a>
$hr
<a href="/" title="初詣ナビ">初詣ナビ</a>&gt;<a href="/zippref$prefid/" title="$pref_nameの初詣スポット">$pref_nameの初詣スポット</a>&gt;<a href="/zipcity$zipcode/" title="$addr1の初詣スポット">$addr1の初詣スポット</a>&gt;$addr1$addr2の初詣スポット<br>
$hr
<font size=1 color="#E9E9E9">$addr1$addr2の初詣スポットなら初詣ナビ。$addr1$addr2の初詣スポットが直ぐに分かる</font>
$hr
END_OF_HTML

	&_footer($self);

	return;
}

sub _hatsumode_detail(){
	my $self = shift;
	
	
my ($name, $reeki, $prefid, $pref_name, $address, $station);
my $sth = $self->{dbi}->prepare( qq{select name,reeki,pref,pref_name,address,station from hatsumoude where id = ? });
$sth->execute($self->{cgi}->param('hatsumode'));
while(my @row = $sth->fetchrow_array) {
	($name, $reeki, $prefid, $pref_name, $address, $station) = @row;
}

	$self->{html_title} = qq{$name 初詣ナビ2011};
	$self->{html_keywords} = qq{初詣,$name, $pref_name,利益,最寄り駅};
	$self->{html_description} = qq{初詣 $name $pref_name $reeki $station};

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);
	&html_header($self);

	my $yicha_link_station = &html_yicha_url($self, "$name", 'p');

print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">$name $reeki $station</font></marquee>
<center>
<font color="#FF0000">【</font>$pref_nameの初詣スポット<font color="#FF0000">】</font>
</center>
$hr
<center>
$ad
</center>
$hr
<table border=0 bgcolor="#000000" width="100%"><tr><td>
<center>
<img src="http://img.waao.jp/kya-.gif" width=15 height=15><font color="#FF0000">$name</font>
</center>
</td></tr></table>
<img src="http://img.waao.jp/ol4_1b.gif" width=40 height=50 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"><font color="#FF8000">ご利益</font><br>
$reeki
<br clear="all" />
<img src="http://img.waao.jp/kaowink02.gif" width=53 height=15><a href="$yicha_link_station">$nameの詳細情報</a><br>
<br>
 :$station<br>
住所:$address<br>

END_OF_HTML


print << "END_OF_HTML";
$hr
<a href="/" title="初詣ナビ">初詣ナビ</a>&gt;<a href="/pref$prefid/" title="$pref_nameの初詣スポット">$pref_nameの初詣ナビ</a>&gt;$name<br>
$hr
<font size=1 color="#E9E9E9">初詣なら$name！$nameへは$station。</font>
$hr
END_OF_HTML

	&_footer($self);

	return;
}

1;
