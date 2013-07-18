package Waao::Pages::Job;
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
	}elsif($self->{cgi}->param('zippref')){
		&_zip_pref($self);
	}elsif($self->{cgi}->param('zipcity')){
		&_zip_city($self);
	}elsif($self->{cgi}->param('zipcode')){
		&_zip_detail($self);
	}elsif($self->{cgi}->param('hellowwork')){
		&_hellowork_top($self);
	}elsif($self->{cgi}->param('hprefid')){
		&_hellowork_pref($self);
	}elsif($self->{cgi}->param('hid')){
		&_hellowork($self);
	}elsif($self->{cgi}->param('school')){
		&_school_top($self);
	}elsif($self->{cgi}->param('sprefid')){
		&_school_pref($self);
	}elsif($self->{cgi}->param('sid')){
		&_school($self);
	}elsif($self->{cgi}->param('salary')){
		&_salary_top($self);
	}elsif($self->{cgi}->param('category')){
		&_salary_category($self);
	}elsif($self->{cgi}->param('cid')){
		&_salary($self);
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

	$self->{html_title} = qq{$pref_nameのバイト・仕事探し $pref_nameの高時給・高年収求人};
	$self->{html_keywords} = qq{$pref_name,バイト,アルバイト,仕事,時給,正社員,求人,年収,短期バイト};
	$self->{html_description} = qq{$pref_nameのバイト・転職情報。最新の求人情報、高時給・高年収・短期バイトの仕事情報};

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);

	&html_header($self);


print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">$pref_nameのバイト・転職情報ならジョブプラス棈高時給・高年収・短期バイトの求人情報</font></marquee>
<center>
<font color="#FF0000">【</font>$pref_nameのバイト・求人<font color="#FF0000">】</font>
</center>
$hr
<center>
$ad
</center>
$hr


<img src="http://img.waao.jp/ol03s.gif" width=46 height=52 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"><font color="#FF8000">求人先の沿線を選択</font><br>
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
<font color="#FF8000">》</font><a href="/rrcd$row[2]/" title="$row[3]のバイト・求人">$row[3]のバイト・求人</a><br>
END_OF_HTML
}

print << "END_OF_HTML";
<img src="http://img.waao.jp/lamp1.gif" width=14 height=11><a href="/zippref$prefid/">$pref_nameの住所からバイト・求人を探す</a>
$hr
<a href="/" title="ジョブプラス">ジョブプラス</a>&gt;<a href="/pref$prefid/">$pref_nameのバイト・求人</a><br>
$hr
<font size=1 color="#E9E9E9">$pref_nameのバイト・求人情報ならジョブプラス。$pref_nameの高時給・高年収・短期バイトの求人情報</font>
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
	$station_list .= qq{<font color="#FF8000">》</font><a href="/station$row[5]/" title="$row[6]のバイト・求人">$row[6]のバイト・求人</a><br>};
}
my $pref_name;
my $sth = $self->{dbi}->prepare(qq{select name from pref where id = ?});
$sth->execute($prefid);
while(my @row = $sth->fetchrow_array) {
	$pref_name = $row[0];
}

	my $manshon = &html_mojibake_str("manshon");

	$self->{html_title} = qq{$line_nameのバイト・仕事探し -$line_nameの高時給・高年収求人-};
	$self->{html_keywords} = qq{$pref_name,$line_name,バイト,アルバイト,仕事,時給,正社員,求人,年収,短期バイト};
	$self->{html_description} = qq{$line_nameのバイト・転職情報。最新の求人情報、高時給・高年収・短期バイトの仕事情報};

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);

	&html_header($self);
print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">$line_nameのバイト・転職情報ならジョブプラス棈高時給・高年収・短期バイトの求人情報</font></marquee>
<center>
<font color="#FF0000">【</font>$line_nameのバイト・求人<font color="#FF0000">】</font>
</center>
$hr
<center>
$ad
</center>
$hr
<img src="http://img.waao.jp/ol03s.gif" width=46 height=52 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"><font color="#FF8000">求人を探す駅を選択</font><br>
<br clear="all" />
<font size=1>
$station_list
END_OF_HTML

print << "END_OF_HTML";
$hr
<a href="/" title="ジョブプラス">ジョブプラス</a>&gt;<a href="/pref$prefid/">$pref_nameのバイト・求人</a>&gt;$line_nameのバイト・求人<br>
$hr
<font size=1 color="#E9E9E9">$line_nameのバイト・求人情報ならジョブプラス。$line_nameの高時給・高年収・短期バイトの求人情報</font>
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

	$self->{html_title} = qq{$station_nameのバイト・仕事探し -$station_nameの高時給・高年収求人-};
	$self->{html_keywords} = qq{$station_name, $line_name, $rr_name,バイト,アルバイト,仕事,時給,正社員,求人,年収,短期バイト};
	$self->{html_description} = qq{$station_nameのバイト・転職情報。最新の求人情報、高時給・高年収・短期バイトの仕事情報};

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);
	&html_header($self);

	my $yicha_link_station1 = &html_yicha_url($self, "$station_nameのバイト", 'p');
	my $yicha_link_station2 = &html_yicha_url($self, "$station_nameの求人", 'p');
	my $yicha_link_req = &html_yicha_url($self, "リクナビ", 'p');
	my $yicha_link_byte = &html_yicha_url($self, "バイトル", 'p');
	my $yicha_link_an = &html_yicha_url($self, "エンジャパン", 'p');

print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">$station_nameのバイト・転職情報ならジョブプラス棈高時給・高年収・短期バイトの求人情報</font></marquee>
<center>
<font color="#FF0000">【</font>$station_nameのバイト・求人<font color="#FF0000">】</font>
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
<img src="http://img.waao.jp/ol03s.gif" width=46 height=52 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"><font color="#FF8000">$station_nameのバイト・求人</font><br>
<br clear="all" />
<font size=1 color="#FF0000">$station_nameのバイト・求人が検索できませんでしたm(_ _)m</font><br>
<img src="http://img.waao.jp/kaowink02.gif" width=53 height=15><a href="$yicha_link_station1">$station_nameのバイト</a><br>
<img src="http://img.waao.jp/kaowink02.gif" width=53 height=15><a href="$yicha_link_station2">$station_nameの求人</a><br>
END_OF_HTML

if($self->{real_mobile}){

print << "END_OF_HTML";
$hr
<img src="http://img.waao.jp/ol01s.gif" width=38 height=53 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"><font color="#FF8000">▼安心のバイト・求人サイト▼</font><br>
<br clear="all" />
$hr
偂<a href="$yicha_link_req">リクナビ</a><br>
<img src="http://suumo.jp/edit/rewrite/help/img/logo_suumo_s.gif" width="88" height="31" border="0"><br>
偂<a href="$yicha_link_byte">バイトル.com</a><br>
<img src="http://img.waao.jp/homes.gif" width=135 height=40><br>
偂<a href="$yicha_link_an">エンジャパン</a><br>
<img src="http://img.waao.jp/chintaibanner.gif" width=135 height=45><br>
$hr
<img src="http://img.waao.jp/m2009.gif" width=48 height=9>リゾバ.com<br>
<center>
<a href="http://smart-c.jp/c?i=0t4jJT2lBsl9001a7&guid=ON"><img src="http://image.smart-c.jp/i?i=0t4jJT2lBsl9001a7"></a>
</center>
$hr
<img src="http://img.waao.jp/m2009.gif" width=48 height=9>派遣ワーク<br>
<center>
<a href="http://smart-c.jp/c?i=10LixA0jzZgE001a7&guid=ON"><img src="http://image.smart-c.jp/i?i=10LixA0jzZgE001a7"></a>
</center>
$hr
<img src="http://img.waao.jp/m2009.gif" width=48 height=9>anレギュラー<br>
<center>
<a href="http://smart-c.jp/c?i=2bOusX17IFpm001a7&guid=ON"><img src="http://image.smart-c.jp/i?i=2bOusX17IFpm001a7"></a>
</center>
$hr
<img src="http://img.waao.jp/m2009.gif" width=48 height=9>デジバイト.com<br>
<center>
<a href="http://smart-c.jp/c?i=4BLTp94p0erb001a7&guid=ON"><img src="http://image.smart-c.jp/i?i=4BLTp94p0erb001a7"></a>
</center>
$hr
<img src="http://img.waao.jp/m2009.gif" width=48 height=9>ジョビー<br>
<center>
<a href="http://smart-c.jp/c?i=2OOrR64jiYl4001a7&guid=ON"><img src="http://image.smart-c.jp/i?i=2OOrR64jiYl4001a7"></a>
</center>
$hr
<img src="http://img.waao.jp/m2009.gif" width=48 height=9>介護師リクルート<br>
<center>
<a href="http://smart-c.jp/c?i=4vCx324iCHt7001a7&guid=ON"><img src="http://image.smart-c.jp/i?i=4vCx324iCHt7001a7"></a>
</center>
$hr
<img src="http://img.waao.jp/m2009.gif" width=48 height=9>介護師専門サイト<br>
<center>
<a href="http://smart-c.jp/c?i=4cwGzi2NVynu001a7&guid=ON"><img src="http://image.smart-c.jp/i?i=4cwGzi2NVynu001a7"></a>
</center>
END_OF_HTML

}else{

print << "END_OF_HTML";
現在、$station_nameのバイト・転職情報が見つかりませんm(_ _)m
END_OF_HTML

}

print << "END_OF_HTML";
$hr
<a href="http://town.goo.to/station$station_cd/">$station_nameのバイト・求人</a>
$hr
<a href="/" title="ジョブプラス">ジョブプラス</a>&gt;<a href="/pref$prefid/" title="$pref_nameのバイト・求人">$pref_nameのバイト・求人</a>&gt;<a href="/rrcd$line_cd/" title="$line_nameのバイト・求人">$line_nameのバイト・求人</a>&gt;$station_nameのバイト・求人<br>
$hr
<font size=1 color="#E9E9E9">$station_nameのバイト・求人情報ならジョブプラス。$station_nameの高時給・高年収・短期バイトの求人情報</font>
$hr
END_OF_HTML

	&_footer($self);

	return;
}

sub _top(){
	my $self = shift;

	my $manshon = &html_mojibake_str("manshon");

	$self->{html_title} = qq{バイト・仕事探すなら、まずは高時給・高年収求人が豊富なジョブプラス};
	$self->{html_keywords} = qq{バイト,仕事,求人,時給,年収,アルバイト,転職};
	$self->{html_description} = qq{バイト・転職情報。最新の求人情報、高時給・高年収・短期バイトの仕事情報};

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);

	&html_header($self);

print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">バイト・転職情報ならジョブプラス棈高時給・高年収・短期バイトの求人情報</font></marquee>
<center>
<img src="http://img.waao.jp/job.gif" width=120 height=28 alt="ジョブプラス"><font size=1 color="#FF0000">β版</font>
</center>
$hr
<center>
$ad
</center>

$hr
<img src="http://img.waao.jp/ol03s.gif" width=46 height=52 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"><font color="#FF8000">求人を探すエリアを選択</font><br>
<br clear="all" />
<font size=1>
END_OF_HTML

my $sth = $self->{dbi}->prepare(qq{select id, name from pref });
$sth->execute();
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<font color="#FF8000">》</font><a href="/pref$row[0]/" title="$row[1]のバイト・求人">$row[1]のバイト・求人</a><br>
END_OF_HTML
}

print << "END_OF_HTML";
</font>
$hr
<a href="/hellowwork/" title="弁移宛筑粟抑綾">弁移宛筑粟抑綾</a><br>
夋<a href="/school/" title="専門学校データベース">専門学校データベース</a><br>
<a href="/salary/" title="企業別年収ランキング">企業別年収ランキング</a><br>
<a href="/" accesskey=0 title="ジョブプラス">ジョブプラス</a><br>
$hr
<img src="http://img.waao.jp/kaowink02.gif" width=53 height=15>働く町の役立ち情報<br>
<a href="http://chintai.goo.to/" title="賃貸プラス">一人暮らし賃貸情報</a><br>
<a href="http://town.goo.to/" title="タウンページプラス">携帯タウン情報</a><br>
$hr
<font size=1 color="#E9E9E9">バイト・求人情報ならジョブプラス。高時給・高年収・短期バイトの求人情報</font>
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

	$self->{html_title} = qq{$pref_nameのバイト・仕事探し $pref_nameの高時給・高年収求人};
	$self->{html_keywords} = qq{$pref_name,バイト,アルバイト,仕事,時給,正社員,求人,年収,短期バイト};
	$self->{html_description} = qq{$pref_nameのバイト・転職情報。最新の求人情報、高時給・高年収・短期バイトの仕事情報};

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);

	&html_header($self);


print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">$pref_nameのバイト・転職情報ならジョブプラス棈高時給・高年収・短期バイトの求人情報</font></marquee>
<center>
<font color="#FF0000">【</font>$pref_nameのバイト・求人<font color="#FF0000">】</font>
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

my $sth = $self->{dbi}->prepare(qq{ select zip, addr2 from zip where addr1 = ? group by addr2} );
$sth->execute($pref_name);
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<font color="#FF8000">》</font><a href="/zipcity$row[0]/" title="$row[1]のバイト・求人">$row[1]のバイト・求人</a><br>
END_OF_HTML
}

print << "END_OF_HTML";
<img src="http://img.waao.jp/lamp1.gif" width=14 height=11><a href="/pref$prefid/">$pref_nameの駅から探す</a>
$hr
<a href="/" title="ジョブプラス">ジョブプラス</a>&gt;<a href="/zippref$prefid/">$pref_nameのバイト・求人</a><br>
$hr
<font size=1 color="#E9E9E9">$pref_nameのバイト・求人情報ならジョブプラス。$pref_nameの高時給・高年収・短期バイトの求人情報</font>
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

	$self->{html_title} = qq{$addr2のバイト・仕事探し $addr2の高時給・高年収求人};
	$self->{html_keywords} = qq{$addr2,バイト,アルバイト,仕事,時給,正社員,求人,年収,短期バイト};
	$self->{html_description} = qq{$addr2のバイト・転職情報。最新の求人情報、高時給・高年収・短期バイトの仕事情報};

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);

	&html_header($self);


print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">$addr2のバイト・転職情報ならジョブプラス棈高時給・高年収・短期バイトの求人情報</font></marquee>
<center>
<font color="#FF0000">【</font>$addr2のバイト・求人<font color="#FF0000">】</font>
</center>
$hr
<center>
$ad
</center>
$hr
<img src="http://img.waao.jp/ol03s.gif" width=46 height=52 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"><font color="#FF8000">住所を選択</font><br>
<br clear="all" />
<font size=1>
END_OF_HTML

my $addr3;
my $sth = $self->{dbi}->prepare(qq{ select zip, addr2, addr3 from zip where addr2 = ?} );
$sth->execute($addr2);
while(my @row = $sth->fetchrow_array) {
$addr3 = $row[2];
print << "END_OF_HTML";
<font color="#FF8000">》</font><a href="/zipcode$row[0]/" title="$row[1]$row[2]のバイト・求人">$row[1]$row[2]のバイト・求人</a><br>
END_OF_HTML
}

print << "END_OF_HTML";
$hr
<a href="/" title="ジョブプラス">ジョブプラス</a>&gt;<a href="/zippref$prefid/">$pref_nameのバイト・求人</a>&gt;$addr2$addr3のバイト・求人<br>
$hr
<font size=1 color="#E9E9E9">$addr2$addr3のバイト・求人情報ならジョブプラス。$addr2$addr3の高時給・高年収・短期バイトの求人情報</font>
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

	$self->{html_title} = qq{$addr1$addr2のバイト・仕事探し -$addr1$addr2の高時給・高年収求人-};
	$self->{html_keywords} = qq{$addr1, $addr2,バイト,アルバイト,仕事,時給,正社員,求人,年収,短期バイト};
	$self->{html_description} = qq{$addr1$addr2のバイト・転職情報。最新の求人情報、高時給・高年収・短期バイトの仕事情報};

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);
	&html_header($self);

	my $yicha_link_station1 = &html_yicha_url($self, "$addr1$addr2のバイト", 'p');
	my $yicha_link_station2 = &html_yicha_url($self, "$addr1$addr2の求人", 'p');
	my $yicha_link_req = &html_yicha_url($self, "リクナビ", 'p');
	my $yicha_link_byte = &html_yicha_url($self, "バイトル", 'p');
	my $yicha_link_an = &html_yicha_url($self, "エンジャパン", 'p');

print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">$addr1$addr2のバイト・転職情報ならジョブプラス棈高時給・高年収・短期バイトの求人情報</font></marquee>
<center>
<font color="#FF0000">【</font>$addr1$addr2のバイト・求人<font color="#FF0000">】</font>
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
<img src="http://img.waao.jp/ol03s.gif" width=46 height=52 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"><font color="#FF8000">$addr1$addr2のバイト・求人</font><br>
<br clear="all" />
<font size=1 color="#FF0000">$addr1$addr2のバイト・求人が検索できませんでしたm(_ _)m</font><br>
<img src="http://img.waao.jp/kaowink02.gif" width=53 height=15><a href="$yicha_link_station1">$addr1$addr2のバイト</a><br>
<img src="http://img.waao.jp/kaowink02.gif" width=53 height=15><a href="$yicha_link_station2">$addr1$addr2の求人</a><br>
END_OF_HTML

if($self->{real_mobile}){

print << "END_OF_HTML";
$hr
<img src="http://img.waao.jp/ol01s.gif" width=38 height=53 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"><font color="#FF8000">▼安心のバイト・求人サイト▼</font><br>
<br clear="all" />
$hr
偂<a href="$yicha_link_req">リクナビ</a><br>
<img src="http://suumo.jp/edit/rewrite/help/img/logo_suumo_s.gif" width="88" height="31" border="0"><br>
偂<a href="$yicha_link_byte">バイトル.com</a><br>
<img src="http://img.waao.jp/homes.gif" width=135 height=40><br>
偂<a href="$yicha_link_an">エンジャパン</a><br>
<img src="http://img.waao.jp/chintaibanner.gif" width=135 height=45><br>
$hr
<img src="http://img.waao.jp/m2009.gif" width=48 height=9>リゾバ.com<br>
<center>
<a href="http://smart-c.jp/c?i=0t4jJT2lBsl9001a7&guid=ON"><img src="http://image.smart-c.jp/i?i=0t4jJT2lBsl9001a7"></a>
</center>
$hr
<img src="http://img.waao.jp/m2009.gif" width=48 height=9>派遣ワーク<br>
<center>
<a href="http://smart-c.jp/c?i=10LixA0jzZgE001a7&guid=ON"><img src="http://image.smart-c.jp/i?i=10LixA0jzZgE001a7"></a>
</center>
$hr
<img src="http://img.waao.jp/m2009.gif" width=48 height=9>anレギュラー<br>
<center>
<a href="http://smart-c.jp/c?i=2bOusX17IFpm001a7&guid=ON"><img src="http://image.smart-c.jp/i?i=2bOusX17IFpm001a7"></a>
</center>
$hr
<img src="http://img.waao.jp/m2009.gif" width=48 height=9>デジバイト.com<br>
<center>
<a href="http://smart-c.jp/c?i=4BLTp94p0erb001a7&guid=ON"><img src="http://image.smart-c.jp/i?i=4BLTp94p0erb001a7"></a>
</center>
$hr
<img src="http://img.waao.jp/m2009.gif" width=48 height=9>ジョビー<br>
<center>
<a href="http://smart-c.jp/c?i=2OOrR64jiYl4001a7&guid=ON"><img src="http://image.smart-c.jp/i?i=2OOrR64jiYl4001a7"></a>
</center>
$hr
<img src="http://img.waao.jp/m2009.gif" width=48 height=9>介護師リクルート<br>
<center>
<a href="http://smart-c.jp/c?i=4vCx324iCHt7001a7&guid=ON"><img src="http://image.smart-c.jp/i?i=4vCx324iCHt7001a7"></a>
</center>
$hr
<img src="http://img.waao.jp/m2009.gif" width=48 height=9>介護師専門サイト<br>
<center>
<a href="http://smart-c.jp/c?i=4cwGzi2NVynu001a7&guid=ON"><img src="http://image.smart-c.jp/i?i=4cwGzi2NVynu001a7"></a>
</center>
END_OF_HTML

}else{

print << "END_OF_HTML";
現在、$addr1$addr2のバイト・転職情報が見つかりませんm(_ _)m
END_OF_HTML

}

print << "END_OF_HTML";
$hr
<a href="http://town.goo.to/zipcode$zipcode/">$addr1$addr2のバイト・求人</a>
$hr
<a href="/" title="ジョブプラス">ジョブプラス</a>&gt;<a href="/zippref$prefid/" title="$pref_nameのバイト・求人">$pref_nameのバイト・求人</a>&gt;<a href="/zipcity$zipcode/" title="$addr1のバイト・求人">$addr1のバイト・求人</a>&gt;$addr1$addr2のバイト・求人<br>
$hr
<font size=1 color="#E9E9E9">$addr1$addr2のバイト・求人情報ならジョブプラス。$addr1$addr2の高時給・高年収・短期バイトの求人情報</font>
$hr
END_OF_HTML

	&_footer($self);

	return;
}

sub _hellowork_top(){
	my $self = shift;

	$self->{html_title} = qq{ハローワーク（職安）のことなら、全国ハローワークデータベース};
	$self->{html_keywords} = qq{ハローワーク,職安,職業安定所,職業,仕事,求人,場所,時間};
	$self->{html_description} = qq{全国ハローワークデータベースは、全国のハローワーク(職安)の場所や時間などの情報が検索できます	};

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);
	&html_header($self);
print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">地域の求人情報なら全国ハローワークデータベース棈今すぐ求人情報が見つかる</font></marquee>
<center>
ハローワーク データベース
</center>
$hr
<center>
$ad
</center>
$hr
<img src="http://img.waao.jp/ol03s.gif" width=46 height=52 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"><font color="#FF8000">エリア別ハローワーク</font><br>
<br clear="all" />
<font size=1>
END_OF_HTML

my $sth = $self->{dbi}->prepare(qq{select id, name from pref });
$sth->execute();
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<font color="#FF8000">》</font><a href="/hpref$row[0]/" title="$row[1]のハローワーク">$row[1]のハローワーク</a><br>
END_OF_HTML
}

print << "END_OF_HTML";
</font>
$hr
<a href="/" accesskey=0 title="ジョブプラス">ジョブプラス</a>&gt;ハローワークデータベース<br>
$hr
<img src="http://img.waao.jp/kaowink02.gif" width=53 height=15>働く町の役立ち情報<br>
<a href="http://chintai.goo.to/" title="賃貸プラス">一人暮らし賃貸情報</a><br>
<a href="http://town.goo.to/" title="タウンページプラス">携帯タウン情報</a><br>
$hr
<font size=1 color="#E9E9E9">ハローワークデータベースは、独自で集めた情報を公開しています。<br>
公開しているハローワークの情報が最新である保証はしておりません。<br>
全国ハローワークデータベースは、全国のハローワーク(職安)の場所や時間などの情報が検索できます</font>
$hr
END_OF_HTML

	&_footer($self);

	return;
}

sub _hellowork_pref(){
	my $self = shift;
	
	my $prefid = $self->{cgi}->param('hprefid');
	
	my $pref_name;
	my $sth = $self->{dbi}->prepare(qq{select name from pref where id = ?});
	$sth->execute($prefid);
	while(my @row = $sth->fetchrow_array) {
		$pref_name = $row[0];
	}

	$self->{html_title} = qq{$pref_nameのハローワーク一覧（職安）};
	$self->{html_keywords} = qq{ハローワーク,職安,$pref_name,職業安定所,職業,仕事,求人,場所,時間};
	$self->{html_description} = qq{$pref_nameのハローワーク一覧：$pref_nameのハローワーク(職安)の場所や時間などの情報が検索できます	};

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);
	&html_header($self);
	
print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">求人情報なら全国ハローワークデータベース棈今すぐ求人情報が見つかる</font></marquee>
<center>
<font color="#FF0000">【</font>$pref_nameのハローワーク一覧<font color="#FF0000">】</font>
</center>
$hr
<center>
$ad
</center>
$hr
<font size=1>
END_OF_HTML
	
my $sth = $self->{dbi}->prepare(qq{select id,name,name2 from hellowwork where pref_cd = ?});
$sth->execute($prefid);
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<font color="#FF8000">》</font><a href="/hid$row[0]/" title="$row[1]($row[2])">$row[1]($row[2])</a><br>
END_OF_HTML
}

	
print << "END_OF_HTML";
</font>
$hr
<a href="/" accesskey=0 title="ジョブプラス">ジョブプラス</a>&gt;<a href="/hellowwork/" title="ハローワークデータベース">ハローワークデータベース</a>&gt;$pref_nameのハローワーク<br>
$hr
<img src="http://img.waao.jp/kaowink02.gif" width=53 height=15>働く町の役立ち情報<br>
<a href="http://chintai.goo.to/" title="賃貸プラス">一人暮らし賃貸情報</a><br>
<a href="http://town.goo.to/" title="タウンページプラス">携帯タウン情報</a><br>
$hr
<font size=1 color="#E9E9E9">ハローワークデータベースは、独自で集めた情報を公開しています。<br>
公開しているハローワークの情報が最新である保証はしておりません。<br>
$pref_nameのハローワークデータベースは、$pref_nameのハローワーク(職安)の場所や時間などの情報が検索できます</font>
$hr
END_OF_HTML

	&_footer($self);
	return;
}

sub _hellowork(){
	my $self = shift;
	
	my $hid = $self->{cgi}->param('hid');

my ($name,$name2,$zipcode,$pref_cd,$pref_name,$address,$tel,$fax);
my $sth = $self->{dbi}->prepare(qq{select name,name2,zipcode,pref_cd,pref_name,address,tel,fax from hellowwork where id = ?});
$sth->execute($hid);
while(my @row = $sth->fetchrow_array) {
	($name,$name2,$zipcode,$pref_cd,$pref_name,$address,$tel,$fax) = @row;
}

	$self->{html_title} = qq{$name($name2)};
	$self->{html_keywords} = qq{$name,ハローワーク,職安,$pref_name,職業安定所,職業,仕事,求人,場所,時間};
	$self->{html_description} = qq{$name($name2) $zipcode $address};

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);
	&html_header($self);

	my $yicha_link_hellowwork = &html_yicha_url($self, "$name2", 'p');
	
print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">求人情報なら全国ハローワークデータベース棈今すぐ求人情報が見つかる</font></marquee>
<center>
<font color="#FF0000">【</font>$name($name2)<font color="#FF0000">】</font>
</center>
$hr
<center>
$ad
</center>
$hr
<font size=1>
〒$zipcode<br>
住所:$address<br>
TEL:$tel<br>
FAX:$fax<br>
<img src="http://img.waao.jp/right06.gif" width=10 height=10><a href="$yicha_link_hellowwork">詳しく見る</a>
</font>
$hr
<a href="/" accesskey=0 title="ジョブプラス">ジョブプラス</a>&gt;<a href="/hellowwork/" title="ハローワークデータベース">ハローワークデータベース</a>&gt;<a href="/hpref$pref_cd/">$pref_nameのハローワーク</a>&gt;$name($name2)<br>
$hr
<img src="http://img.waao.jp/kaowink02.gif" width=53 height=15>働く町の役立ち情報<br>
<a href="http://chintai.goo.to/" title="賃貸プラス">一人暮らし賃貸情報</a><br>
<a href="http://town.goo.to/" title="タウンページプラス">携帯タウン情報</a><br>
$hr
<font size=1 color="#E9E9E9">ハローワークデータベースは、独自で集めた情報を公開しています。<br>
公開しているハローワークの情報が最新である保証はしておりません。<br>
$name($name2) $zipcode $address</font>
$hr
END_OF_HTML

	&_footer($self);
	return;
}
sub _school_top(){
	my $self = shift;

	$self->{html_title} = qq{専門学校（資格取得）なら、全国専門職ナビ};
	$self->{html_keywords} = qq{専門学校,資格,職業,能力,学校,仕事,求人,入試};
	$self->{html_description} = qq{全国専門職ナビは、全国の専門学校の情報が検索できます};

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);
	&html_header($self);
print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">資格取得なら全国専門職ナビ棈今すぐ専門職が身につく学校が見つかる</font></marquee>
<center>
専門学校 データベース
</center>
$hr
<center>
$ad
</center>
$hr
<img src="http://img.waao.jp/ol03s.gif" width=46 height=52 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"><font color="#FF8000">エリア別専門学校</font><br>
<br clear="all" />
<font size=1>
END_OF_HTML

my $sth = $self->{dbi}->prepare(qq{select id, name from pref });
$sth->execute();
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<font color="#FF8000">》</font><a href="/spref$row[0]/" title="$row[1]の専門学校">$row[1]の専門学校</a><br>
END_OF_HTML
}

print << "END_OF_HTML";
</font>
$hr
<a href="/" accesskey=0 title="ジョブプラス">ジョブプラス</a>&gt;専門学校データベース<br>
$hr
<img src="http://img.waao.jp/kaowink02.gif" width=53 height=15>働く町の役立ち情報<br>
<a href="http://chintai.goo.to/" title="賃貸プラス">一人暮らし賃貸情報</a><br>
<a href="http://town.goo.to/" title="タウンページプラス">携帯タウン情報</a><br>
$hr
<font size=1 color="#E9E9E9">専門学校データベースは、独自で集めた情報を公開しています。<br>
公開している専門学校の情報が最新である保証はしておりません。<br>
全国専門学校データベースは、全国の専門学校(資格取得)の情報が検索できます</font>
$hr
END_OF_HTML

	&_footer($self);

	return;
}

sub _school_pref(){
	my $self = shift;
	
	my $prefid = $self->{cgi}->param('sprefid');
	
	my $pref_name;
	my $sth = $self->{dbi}->prepare(qq{select name from pref where id = ?});
	$sth->execute($prefid);
	while(my @row = $sth->fetchrow_array) {
		$pref_name = $row[0];
	}

	$self->{html_title} = qq{$pref_nameの専門学校一覧（専門資格取得）};
	$self->{html_keywords} = qq{専門学校,資格,$pref_name,入試,職業,仕事,求人,場所};
	$self->{html_description} = qq{$pref_nameの専門学校一覧：$pref_nameの専門学校(資格取得)の情報が検索できます};

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);
	&html_header($self);
	
print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">資格とるなら全国専門学校データベース棈今すぐ入試情報が見つかる</font></marquee>
<center>
<font color="#FF0000">【</font>$pref_nameの専門学校一覧<font color="#FF0000">】</font>
</center>
$hr
<center>
$ad
</center>
$hr
<font size=1>
END_OF_HTML
	
my $sth = $self->{dbi}->prepare(qq{select id,name from jobschool where pref_cd = ?});
$sth->execute($prefid);
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<font color="#FF8000">》</font><a href="/sid$row[0]/" title="$row[1]">$row[1]</a><br>
END_OF_HTML
}

	
print << "END_OF_HTML";
</font>
$hr
<a href="/" accesskey=0 title="ジョブプラス">ジョブプラス</a>&gt;<a href="/school/" title="専門学校データベース">専門学校データベース</a>&gt;$pref_nameの専門学校<br>
$hr
<img src="http://img.waao.jp/kaowink02.gif" width=53 height=15>働く町の役立ち情報<br>
<a href="http://chintai.goo.to/" title="賃貸プラス">一人暮らし賃貸情報</a><br>
<a href="http://town.goo.to/" title="タウンページプラス">携帯タウン情報</a><br>
$hr
<font size=1 color="#E9E9E9">専門学校データベースは、独自で集めた情報を公開しています。<br>
公開している専門学校の情報が最新である保証はしておりません。<br>
$pref_nameの専門学校データベースは、$pref_nameの専門学校(資格取得)の情報が検索できます</font>
$hr
END_OF_HTML

	&_footer($self);
	return;
}

sub _school(){
	my $self = shift;
	
	my $hid = $self->{cgi}->param('sid');

my ($name,$hojin,$zipcode,$pref_cd,$pref_name,$address,$tel,$url);
my $sth = $self->{dbi}->prepare(qq{select name,hojin,zipcode,pref_cd,pref_name,address,tel,url from jobschool where id = ?});
$sth->execute($hid);
while(my @row = $sth->fetchrow_array) {
	($name,$hojin,$zipcode,$pref_cd,$pref_name,$address,$tel,$url) = @row;
}

	$self->{html_title} = qq{$name};
	$self->{html_keywords} = qq{$name,専門学校,資格,$pref_name,学校,職業,仕事,求人,場所};
	$self->{html_description} = qq{$hojin$name $zipcode $address};

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);
	&html_header($self);

	my $yicha_link_hellowwork = &html_yicha_url($self, "$name", 'p');
	
print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">資格取得なら全国専門学校データベース棈近くの専門学校情報が見つかる</font></marquee>
<center>
<font color="#FF0000">【</font>$name<font color="#FF0000">】</font>
</center>
$hr
<center>
$ad
</center>
$hr
<font size=1>
〒$zipcode<br>
住所:$address<br>
TEL:$tel<br>
URL:<a href="$url">$url</a><br>
<img src="http://img.waao.jp/right06.gif" width=10 height=10><a href="$yicha_link_hellowwork">詳しく見る</a>
</font>
$hr
<a href="/" accesskey=0 title="ジョブプラス">ジョブプラス</a>&gt;<a href="/school/" title="専門学校データベース">専門学校データベース</a>&gt;<a href="/spref$pref_cd/">$pref_nameの専門学校</a>&gt;$name<br>
$hr
<img src="http://img.waao.jp/kaowink02.gif" width=53 height=15>働く町の役立ち情報<br>
<a href="http://chintai.goo.to/" title="賃貸プラス">一人暮らし賃貸情報</a><br>
<a href="http://town.goo.to/" title="タウンページプラス">携帯タウン情報</a><br>
$hr
<font size=1 color="#E9E9E9">専門学校データベースは、独自で集めた情報を公開しています。<br>
公開している専門学校の情報が最新である保証はしておりません。<br>
$name $zipcode $address</font>
$hr
END_OF_HTML

	&_footer($self);
	return;
}
sub _salary_top(){
	my $self = shift;

	$self->{html_title} = qq{企業別年収ランキング　転職支援ナビ};
	$self->{html_keywords} = qq{年収,企業,ランキング,転職,就職,仕事,求人,給料};
	$self->{html_description} = qq{転職支援ナビは、企業別の平均年収が検索できます。転職の参考に};

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);
	&html_header($self);
print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">転職支援ナビは、企業別の平均年収が分かる転職の参考に</font></marquee>
<center>
企業別年収ランキング
</center>
$hr
<center>
$ad
</center>
$hr
<img src="http://img.waao.jp/ol03s.gif" width=46 height=52 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"><font color="#FF8000">職種別年収ランキング</font><br>
<br clear="all" />
<font size=1>
END_OF_HTML

my $sth = $self->{dbi}->prepare(qq{select id, name from job_category });
$sth->execute();
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<font color="#FF8000">》</font><a href="/category$row[0]/" title="$row[1]の年収">$row[1]の年収</a><br>
END_OF_HTML
}

print << "END_OF_HTML";
</font>
$hr
<a href="/" accesskey=0 title="ジョブプラス">ジョブプラス</a>&gt;企業別年収ランキング<br>
$hr
<img src="http://img.waao.jp/kaowink02.gif" width=53 height=15>働く町の役立ち情報<br>
<a href="http://chintai.goo.to/" title="賃貸プラス">一人暮らし賃貸情報</a><br>
<a href="http://town.goo.to/" title="タウンページプラス">携帯タウン情報</a><br>
$hr
<font size=1 color="#E9E9E9">企業別年収ランキングは、独自で集めた情報を公開しています。<br>
公開している企業別年収の情報が最新である保証はしておりません。<br>
企業別年収ランキングは、企業別平均年収の情報が検索できます。転職の参考にどうぞ</font>
$hr
END_OF_HTML

	&_footer($self);

	return;
}

sub _salary_category(){
	my $self = shift;
	
	my $cid = $self->{cgi}->param('category');
	
	my $category_name;
	my $sth = $self->{dbi}->prepare(qq{select name from job_category where id = ?});
	$sth->execute($cid);
	while(my @row = $sth->fetchrow_array) {
		$category_name = $row[0];
	}

	$self->{html_title} = qq{$category_nameの企業年収ランキング 転職ナビ};
	$self->{html_keywords} = qq{年収,給料,$category_name,職業,仕事,求人};
	$self->{html_description} = qq{$category_nameの企業年収ランキング：$category_nameの平均年収の情報が検索できます};

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);
	&html_header($self);
	
print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">$category_nameの企業年収ランキング棈転職するならまず給料をチェック</font></marquee>
<center>
<font color="#FF0000">【</font>企業年収ランキング<font color="#FF0000">】</font>
</center>
$hr
<center>
$ad
</center>
$hr
<font size=1>
END_OF_HTML
	
my $sth = $self->{dbi}->prepare(qq{select id,name,money from job_company where job_category_id = ? order by money desc});
$sth->execute($cid);
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<font color="#FF8000">》</font><a href="/cid$row[0]/" title="$row[1]">$row[1]</a>($row[2])<br>
END_OF_HTML
}

	
print << "END_OF_HTML";
</font>
$hr
<a href="/" accesskey=0 title="ジョブプラス">ジョブプラス</a>&gt;<a href="/salary/" title="年収ランキング">年収ランキング</a>&gt;$category_nameの企業年収ランキング<br>
$hr
<img src="http://img.waao.jp/kaowink02.gif" width=53 height=15>働く町の役立ち情報<br>
<a href="http://chintai.goo.to/" title="賃貸プラス">一人暮らし賃貸情報</a><br>
<a href="http://town.goo.to/" title="タウンページプラス">携帯タウン情報</a><br>
$hr
<font size=1 color="#E9E9E9">企業別年収ランキングは、独自で集めた情報を公開しています。<br>
公開している企業別年収の情報が最新である保証はしておりません。<br>
$category_nameの企業別年収ランキングは、$category_nameの平均年収の情報が検索できます</font>
$hr
END_OF_HTML

	&_footer($self);
	return;
}

sub _salary(){
	my $self = shift;
	
	my $cid = $self->{cgi}->param('cid');

my ($name,$job_category,$money,$member,$aveage,$avejob,$opdate);
my $sth = $self->{dbi}->prepare(qq{select name,job_category,money,member,aveage,avejob,opdate from job_company where id = ?});
$sth->execute($cid);
while(my @row = $sth->fetchrow_array) {
	($name,$job_category,$money,$member,$aveage,$avejob,$opdate) = @row;
}

	$self->{html_title} = qq{$nameの平均年収は、$money};
	$self->{html_keywords} = qq{$name,年収,給与,給料,職業,仕事,求人,場所};
	$self->{html_description} = qq{$nameの平均年収は、$money};

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);
	&html_header($self);

	my $yicha_link_hellowwork = &html_yicha_url($self, "$name", 'p');
	
print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">企業年収ランキング棈転職するならまず給料をチェック</font></marquee>
<center>
<font color="#FF0000">【</font>$nameの平均年収<font color="#FF0000">】</font>
</center>
$hr
<center>
$ad
</center>
$hr
<font size=1>
職種：$job_category<br>
平均年収:$money<br>
社員数:$member<br>
平均年齢:$aveage<br>
平均勤務年数:$avejob<br>
更新日:$opdate<br>

<img src="http://img.waao.jp/right06.gif" width=10 height=10><a href="$yicha_link_hellowwork">詳しく見る</a>
</font>
$hr
<a href="/" accesskey=0 title="ジョブプラス">ジョブプラス</a>&gt;<a href="/salary/" title="年収ランキング">年収ランキング</a>&gt;$job_categoryの企業年収ランキング<br>
$hr
<img src="http://img.waao.jp/kaowink02.gif" width=53 height=15>働く町の役立ち情報<br>
<a href="http://chintai.goo.to/" title="賃貸プラス">一人暮らし賃貸情報</a><br>
<a href="http://town.goo.to/" title="タウンページプラス">携帯タウン情報</a><br>
$hr
<font size=1 color="#E9E9E9">企業別年収ランキングは、独自で集めた情報を公開しています。<br>
公開している企業別年収の情報が最新である保証はしておりません。<br>
$nameの平均年収は、$money</font>
$hr
END_OF_HTML

	&_footer($self);
	return;
}

1;
