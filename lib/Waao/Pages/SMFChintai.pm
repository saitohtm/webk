package Waao::Pages::SMFChintai;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Html5;
use Waao::Data;
use Waao::Utility;

sub dispatch(){
	my $self = shift;
	
	if($self->{cgi}->param('stationid')){
		&_station_detail($self);
	}elsif($self->{cgi}->param('rrcd')){
		&_station_rrcd($self);
	}elsif($self->{cgi}->param('station') eq 'all'){
		&_station_top($self);
	}elsif($self->{cgi}->param('station')){
		&_station($self);
	}elsif($self->{cgi}->param('zip')){
		&_zip($self);
	}elsif($self->{cgi}->param('pref') eq 'all'){
		&_pref_top($self);
	}elsif($self->{cgi}->param('pref')){
		&_pref($self);
	}else{
		&_top($self);
	}
	
	return;
}

sub _station_detail(){
	my $self = shift;
	my $manshon = &html_mojibake_str("manshon");
	my $station_cd = $self->{cgi}->param('stationid');

my ($rr_cd, $rr_name, $line_cd, $line_name, $station_name, $prefid);
my $sth = $self->{dbi}->prepare(qq{select rr_cd, rr_name, line_cd, line_name, station_cd, station_name,pref_cd from station where station_cd = ? limit 1}  );
$sth->execute($station_cd);
while(my @row = $sth->fetchrow_array) {
	($rr_cd, $rr_name, $line_cd, $line_name, $station_cd, $station_name, $prefid) = @row;
}
my $pref_name;
my $sth = $self->{dbi}->prepare(qq{select name from pref where id = ?});
$sth->execute($prefid);
while(my @row = $sth->fetchrow_array) {
	$pref_name = $row[0];
}
	my $keyword_encode = &str_encode("$station_name 賃貸マンション");

	my $a = "$station_nameの賃貸$manshon $station_nameの賃貸を探すなら賃貸MAXお部屋探しは敷金・礼金なしの賃貸MAX";
	$self->{html_title} = qq{$a};
	my $b = "$station_name,住所検索,賃貸,一人暮らし,$manshon,部屋探し,検索,敷金,礼金";
	$self->{html_keywords} = qq{$b};
	my $c = "$station_nameの賃貸$manshon 住所検索 一人暮らしのお部屋探しは、賃貸。敷金・礼金なし賃貸がおすすめ";
	$self->{html_description} = qq{$c};

	&html_header($self);

print << "END_OF_HTML";
<div data-role="header"> 
<h1>$station_nameの賃貸$manshon</h1> 
</div>
<a href="/">スマフォMAX</a>&gt;<a href="/chintai/">賃貸$manshon</a>&gt;<a href="/chintaistation/">都道府県選択</a>&gt;<a href="/chintaistation-$prefid/">$pref_name</a>&gt;<a href="/chintairrcd-$line_cd/">$line_name</a>&gt;$station_nameの賃貸$manshon
<div data-role="content">
<iframe frameborder="0" allowtransparency="true" height="60" width="234" marginheight="0" scrolling="no" src="http://ad.jp.ap.valuecommerce.com/servlet/htmlbanner?sid=2780819&pid=880134877" marginwidth="0"><script language="javascript" src="http://ad.jp.ap.valuecommerce.com/servlet/jsbanner?sid=2780819&pid=880134877"></script><noscript><a href="http://ck.jp.ap.valuecommerce.com/servlet/referral?sid=2780819&pid=880134877" target="_blank" ><img src="http://ad.jp.ap.valuecommerce.com/servlet/gifbanner?sid=2780819&pid=880134877" height="60" width="234" border="0"></a></noscript></iframe>
<br>
<br>
<ul data-role="listview">
<li data-role="list-divider">$station_nameの賃貸$manshon</li>
</ul>
</div>
<iframe src="http://search.naver.jp/m/?q=$keyword_encode" height=300 width=300></iframe>
<img src="/img/E022_20.gif" height="20">賃貸MAXは、オシャレな賃貸$manshonが探せる賃貸検索サービスです。<img src="/img/E00F_20.gif" height="20">一人暮らしのお部屋探しは、賃貸。敷金・礼金なし賃貸がおすすめ<br>

END_OF_HTML
	
&html_footer($self);
	
	return;
}

sub _station_rrcd(){
	my $self = shift;

	my $line_code = $self->{cgi}->param('rrcd');
	my $manshon = &html_mojibake_str("manshon");
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
	$station_list .= qq{<li><a href="/chintaistationid-$row[5]/" title="$row[6]の賃貸マンション">$row[6]の賃貸$manshon</a></li>};
}
my $pref_name;
my $sth = $self->{dbi}->prepare(qq{select name from pref where id = ?});
$sth->execute($prefid);
while(my @row = $sth->fetchrow_array) {
	$pref_name = $row[0];
}

	my $a = "$line_nameの賃貸$manshon $pref_nameの賃貸を探すなら賃貸MAXお部屋探しは敷金・礼金なしの賃貸MAX";
	$self->{html_title} = qq{$a};
	my $b = "$line_name,住所検索,賃貸,一人暮らし,$manshon,部屋探し,検索,敷金,礼金";
	$self->{html_keywords} = qq{$b};
	my $c = "$line_nameの賃貸$manshon 住所検索 一人暮らしのお部屋探しは、賃貸。敷金・礼金なし賃貸がおすすめ";
	$self->{html_description} = qq{$c};

	&html_header($self);

print << "END_OF_HTML";
<div data-role="header"> 
<h1>$pref_nameの賃貸$manshon</h1> 
</div>
<a href="/">スマフォMAX</a>&gt;<a href="/chintai/">賃貸$manshon</a>&gt;<a href="/chintaistation/">都道府県選択</a>&gt;<a href="/chintaistation-$prefid/">$pref_name</a>&gt;$line_nameの賃貸$manshon
<div data-role="content">
<iframe frameborder="0" allowtransparency="true" height="60" width="234" marginheight="0" scrolling="no" src="http://ad.jp.ap.valuecommerce.com/servlet/htmlbanner?sid=2780819&pid=880134877" marginwidth="0"><script language="javascript" src="http://ad.jp.ap.valuecommerce.com/servlet/jsbanner?sid=2780819&pid=880134877"></script><noscript><a href="http://ck.jp.ap.valuecommerce.com/servlet/referral?sid=2780819&pid=880134877" target="_blank" ><img src="http://ad.jp.ap.valuecommerce.com/servlet/gifbanner?sid=2780819&pid=880134877" height="60" width="234" border="0"></a></noscript></iframe>
<br>
<br>
<ul data-role="listview">
<li data-role="list-divider">$line_nameの賃貸$manshon</li>
$station_list
</ul>
</div>
<img src="/img/E022_20.gif" height="20">賃貸MAXは、オシャレな賃貸$manshonが探せる賃貸検索サービスです。<img src="/img/E00F_20.gif" height="20">一人暮らしのお部屋探しは、賃貸。敷金・礼金なし賃貸がおすすめ<br>

END_OF_HTML
	
&html_footer($self);
	
	return;
}

sub _station(){
	my $self = shift;

my $pref_name;
my $sth = $self->{dbi}->prepare(qq{select id, name from pref where id = ? });
$sth->execute($self->{cgi}->param('station'));
while(my @row = $sth->fetchrow_array) {
	$pref_name = $row[1];
}
	
	my $manshon = &html_mojibake_str("manshon");

	my $a = "$pref_nameの賃貸$manshon $pref_nameの賃貸を探すなら賃貸MAXお部屋探しは敷金・礼金なしの賃貸MAX";
	$self->{html_title} = qq{$a};
	my $b = "$pref_name,住所検索,賃貸,一人暮らし,$manshon,部屋探し,検索,敷金,礼金";
	$self->{html_keywords} = qq{$b};
	my $c = "$pref_nameの賃貸$manshon 住所検索 一人暮らしのお部屋探しは、賃貸。敷金・礼金なし賃貸がおすすめ";
	$self->{html_description} = qq{$c};

	&html_header($self);

print << "END_OF_HTML";
<div data-role="header"> 
<h1>$pref_nameの賃貸$manshon</h1> 
</div>
<a href="/">スマフォMAX</a>&gt;<a href="/chintai/">賃貸$manshon</a>&gt;<a href="/chintaipref/">都道府県選択</a>&gt;$pref_nameの賃貸$manshon
<div data-role="content">
<iframe frameborder="0" allowtransparency="true" height="60" width="234" marginheight="0" scrolling="no" src="http://ad.jp.ap.valuecommerce.com/servlet/htmlbanner?sid=2780819&pid=880134877" marginwidth="0"><script language="javascript" src="http://ad.jp.ap.valuecommerce.com/servlet/jsbanner?sid=2780819&pid=880134877"></script><noscript><a href="http://ck.jp.ap.valuecommerce.com/servlet/referral?sid=2780819&pid=880134877" target="_blank" ><img src="http://ad.jp.ap.valuecommerce.com/servlet/gifbanner?sid=2780819&pid=880134877" height="60" width="234" border="0"></a></noscript></iframe>
<br>
<br>
<ul data-role="listview">
<li data-role="list-divider">$pref_nameの賃貸$manshon</li>
END_OF_HTML

my $rr_name;
my $sth = $self->{dbi}->prepare(qq{ select rr_cd, rr_name, line_cd, line_name from station where pref_cd = ? group by line_cd} );
$sth->execute($self->{cgi}->param('station'));
while(my @row = $sth->fetchrow_array) {
	if($rr_name ne $row[1]){
		$rr_name = $row[1];
print << "END_OF_HTML";
<li data-role="list-divider">$row[3]</li>
END_OF_HTML
	}
print << "END_OF_HTML";
<li><img src="/img/E231_20.gif" height="20" class="ui-li-icon"><a href="/chintairrcd-$row[2]/" title="$row[3]の賃貸$manshon">$row[3]の賃貸$manshon</a></li>
END_OF_HTML
}

print << "END_OF_HTML";
</ul>
</div>
<img src="/img/E022_20.gif" height="20">賃貸MAXは、オシャレな賃貸$manshonが探せる賃貸検索サービスです。<img src="/img/E00F_20.gif" height="20">一人暮らしのお部屋探しは、賃貸。敷金・礼金なし賃貸がおすすめ<br>

END_OF_HTML
	
&html_footer($self);
	
	return;
}

sub _station_top(){
	my $self = shift;
	
	my $manshon = &html_mojibake_str("manshon");

	my $a = "駅名検索 賃貸MAXは、賃貸$manshon検索サイトです。 一人暮らしのお部屋探しは敷金・礼金なしの賃貸MAX";
	$self->{html_title} = qq{$a};
	my $b = "駅名検索,賃貸,一人暮らし,$manshon,部屋探し,検索,敷金,礼金";
	$self->{html_keywords} = qq{$b};
	my $c = "駅名検索 一人暮らしのお部屋探しは、賃貸。敷金・礼金なし賃貸がおすすめ";
	$self->{html_description} = qq{$c};
	&html_header($self);

print << "END_OF_HTML";
<div data-role="header"> 
<h1>賃貸$manshon</h1> 
</div>
<a href="/">スマフォMAX</a>&gt;<a href="/chintai/">賃貸$manshon</a>&gt;都道府県選択
<div data-role="content">
<iframe frameborder="0" allowtransparency="true" height="60" width="234" marginheight="0" scrolling="no" src="http://ad.jp.ap.valuecommerce.com/servlet/htmlbanner?sid=2780819&pid=880134877" marginwidth="0"><script language="javascript" src="http://ad.jp.ap.valuecommerce.com/servlet/jsbanner?sid=2780819&pid=880134877"></script><noscript><a href="http://ck.jp.ap.valuecommerce.com/servlet/referral?sid=2780819&pid=880134877" target="_blank" ><img src="http://ad.jp.ap.valuecommerce.com/servlet/gifbanner?sid=2780819&pid=880134877" height="60" width="234" border="0"></a></noscript></iframe>
<br>
<br>
<ul data-role="listview">
<li data-role="list-divider">賃貸$manshon</li>
END_OF_HTML


my $sth = $self->{dbi}->prepare(qq{select id, name from pref });
$sth->execute();
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<li><img src="/img/E231_20.gif" height="20" class="ui-li-icon"><a href="/chintaistation-$row[0]/" title="$row[1]の賃貸$manshon">$row[1]の賃貸$manshon</a></li>
END_OF_HTML
}

print << "END_OF_HTML";
</ul>
</div>
<img src="/img/E022_20.gif" height="20">賃貸MAXは、オシャレな賃貸$manshonが探せる賃貸検索サービスです。<img src="/img/E00F_20.gif" height="20">一人暮らしのお部屋探しは、賃貸。敷金・礼金なし賃貸がおすすめ<br>

END_OF_HTML
	
&html_footer($self);
	
	return;
}

sub _zip(){
	my $self = shift;
	my $zipcode = $self->{cgi}->param('zip');

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
	my $keyword_encode = &str_encode("$addr2 賃貸マンション");


	my $manshon = &html_mojibake_str("manshon");

	my $a = "$addr2の賃貸$manshon $addr2の賃貸を探すなら賃貸MAXお部屋探しは敷金・礼金なしの賃貸MAX";
	$self->{html_title} = qq{$a};
	my $b = "$addr2,住所検索,賃貸,一人暮らし,$manshon,部屋探し,検索,敷金,礼金";
	$self->{html_keywords} = qq{$b};
	my $c = "$addr2の賃貸$manshon 住所検索 一人暮らしのお部屋探しは、賃貸。敷金・礼金なし賃貸がおすすめ";
	$self->{html_description} = qq{$c};
	&html_header($self);

print << "END_OF_HTML";
<div data-role="header"> 
<h1>$addr2の賃貸$manshon</h1> 
</div>
<a href="/">スマフォMAX</a>&gt;<a href="/chintai/">賃貸$manshon</a>&gt;<a href="/chintaipref/">都道府県選択</a>&gt;<a href="/chintaipref-$prefid/">$pref_nameの賃貸</a>&gt;$addr2の賃貸$manshon
<div data-role="content">
<iframe frameborder="0" allowtransparency="true" height="60" width="234" marginheight="0" scrolling="no" src="http://ad.jp.ap.valuecommerce.com/servlet/htmlbanner?sid=2780819&pid=880134877" marginwidth="0"><script language="javascript" src="http://ad.jp.ap.valuecommerce.com/servlet/jsbanner?sid=2780819&pid=880134877"></script><noscript><a href="http://ck.jp.ap.valuecommerce.com/servlet/referral?sid=2780819&pid=880134877" target="_blank" ><img src="http://ad.jp.ap.valuecommerce.com/servlet/gifbanner?sid=2780819&pid=880134877" height="60" width="234" border="0"></a></noscript></iframe>
<br>
<br>
<ul data-role="listview">
<li data-role="list-divider">$addr2の賃貸$manshon</li>
END_OF_HTML


print << "END_OF_HTML";
</ul>
</div>
<iframe src="http://search.naver.jp/m/?q=$keyword_encode" height=300 width=300></iframe>

<img src="/img/E022_20.gif" height="20">賃貸MAXは、オシャレな賃貸$manshonが探せる賃貸検索サービスです。<img src="/img/E00F_20.gif" height="20">一人暮らしのお部屋探しは、賃貸。敷金・礼金なし賃貸がおすすめ<br>

END_OF_HTML
	
&html_footer($self);
	
	return;
}


sub _pref(){
	my $self = shift;

my $pref_name;
my $sth = $self->{dbi}->prepare(qq{select id, name from pref where id = ? });
$sth->execute($self->{cgi}->param('pref'));
while(my @row = $sth->fetchrow_array) {
	$pref_name = $row[1];
}
	
	my $manshon = &html_mojibake_str("manshon");

	my $a = "$pref_nameの賃貸$manshon $pref_nameの賃貸を探すなら賃貸MAXお部屋探しは敷金・礼金なしの賃貸MAX";
	$self->{html_title} = qq{$a};
	my $b = "$pref_name,住所検索,賃貸,一人暮らし,$manshon,部屋探し,検索,敷金,礼金";
	$self->{html_keywords} = qq{$b};
	my $c = "$pref_nameの賃貸$manshon 住所検索 一人暮らしのお部屋探しは、賃貸。敷金・礼金なし賃貸がおすすめ";
	$self->{html_description} = qq{$c};
	&html_header($self);

print << "END_OF_HTML";
<div data-role="header"> 
<h1>$pref_nameの賃貸$manshon</h1> 
</div>
<a href="/">スマフォMAX</a>&gt;<a href="/chintai/">賃貸$manshon</a>&gt;<a href="/chintaipref/">都道府県選択</a>&gt;$pref_nameの賃貸$manshon
<div data-role="content">
<iframe frameborder="0" allowtransparency="true" height="60" width="234" marginheight="0" scrolling="no" src="http://ad.jp.ap.valuecommerce.com/servlet/htmlbanner?sid=2780819&pid=880134877" marginwidth="0"><script language="javascript" src="http://ad.jp.ap.valuecommerce.com/servlet/jsbanner?sid=2780819&pid=880134877"></script><noscript><a href="http://ck.jp.ap.valuecommerce.com/servlet/referral?sid=2780819&pid=880134877" target="_blank" ><img src="http://ad.jp.ap.valuecommerce.com/servlet/gifbanner?sid=2780819&pid=880134877" height="60" width="234" border="0"></a></noscript></iframe>
<br>
<br>
<ul data-role="listview">
<li data-role="list-divider">$pref_nameの賃貸$manshon</li>
END_OF_HTML

my $sth = $self->{dbi}->prepare(qq{ select zip, addr2 from zip where addr1 = ? group by addr2} );
$sth->execute($pref_name);
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<li><img src="/img/E231_20.gif" height="20" class="ui-li-icon"><a href="/chintaizip-$row[0]/" title="$row[1]の賃貸$manshon">$row[1]の賃貸$manshon</a></li>
END_OF_HTML
}

print << "END_OF_HTML";
</ul>
</div>
<img src="/img/E022_20.gif" height="20">賃貸MAXは、オシャレな賃貸$manshonが探せる賃貸検索サービスです。<img src="/img/E00F_20.gif" height="20">一人暮らしのお部屋探しは、賃貸。敷金・礼金なし賃貸がおすすめ<br>

END_OF_HTML
	
&html_footer($self);
	
	return;
}

sub _pref_top(){
	my $self = shift;
	
	my $manshon = &html_mojibake_str("manshon");

	my $a = "住所検索 賃貸MAXは、賃貸$manshon検索サイトです。 一人暮らしのお部屋探しは敷金・礼金なしの賃貸MAX";
	$self->{html_title} = qq{$a};
	my $b = "住所検索,賃貸,一人暮らし,$manshon,部屋探し,検索,敷金,礼金";
	$self->{html_keywords} = qq{$b};
	my $c = "住所検索 一人暮らしのお部屋探しは、賃貸。敷金・礼金なし賃貸がおすすめ";
	$self->{html_description} = qq{$c};
	&html_header($self);

print << "END_OF_HTML";
<div data-role="header"> 
<h1>賃貸$manshon</h1> 
</div>
<a href="/">スマフォMAX</a>&gt;<a href="/chintai/">賃貸$manshon</a>&gt;都道府県選択
<div data-role="content">
<iframe frameborder="0" allowtransparency="true" height="60" width="234" marginheight="0" scrolling="no" src="http://ad.jp.ap.valuecommerce.com/servlet/htmlbanner?sid=2780819&pid=880134877" marginwidth="0"><script language="javascript" src="http://ad.jp.ap.valuecommerce.com/servlet/jsbanner?sid=2780819&pid=880134877"></script><noscript><a href="http://ck.jp.ap.valuecommerce.com/servlet/referral?sid=2780819&pid=880134877" target="_blank" ><img src="http://ad.jp.ap.valuecommerce.com/servlet/gifbanner?sid=2780819&pid=880134877" height="60" width="234" border="0"></a></noscript></iframe>
<br>
<br>
<ul data-role="listview">
<li data-role="list-divider">賃貸$manshon</li>
END_OF_HTML


my $sth = $self->{dbi}->prepare(qq{select id, name from pref });
$sth->execute();
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<li><img src="/img/E231_20.gif" height="20" class="ui-li-icon"><a href="/chintaipref-$row[0]/" title="$row[1]の賃貸$manshon">$row[1]の賃貸$manshon</a></li>
END_OF_HTML
}

print << "END_OF_HTML";
</ul>
</div>
<img src="/img/E022_20.gif" height="20">賃貸MAXは、オシャレな賃貸$manshonが探せる賃貸検索サービスです。<img src="/img/E00F_20.gif" height="20">一人暮らしのお部屋探しは、賃貸。敷金・礼金なし賃貸がおすすめ<br>

END_OF_HTML
	
&html_footer($self);
	
	return;
}

sub _top(){
	my $self = shift;

	my $manshon = &html_mojibake_str("manshon");

	my $a = "賃貸MAXは、賃貸$manshon検索サイトです。 一人暮らしのお部屋探しは敷金・礼金なしの賃貸MAX";
	$self->{html_title} = qq{$a};
	my $b = "賃貸,一人暮らし,$manshon,部屋探し,検索,敷金,礼金";
	$self->{html_keywords} = qq{$b};
	my $c = "一人暮らしのお部屋探しは、賃貸。敷金・礼金なし賃貸がおすすめ";
	$self->{html_description} = qq{$c};
	&html_header($self);

print << "END_OF_HTML";
<div data-role="header"> 
<h1>賃貸$manshon</h1> 
</div>
<a href="/">スマフォMAX</a>&gt;賃貸$manshon
<div data-role="content">
<iframe frameborder="0" allowtransparency="true" height="60" width="234" marginheight="0" scrolling="no" src="http://ad.jp.ap.valuecommerce.com/servlet/htmlbanner?sid=2780819&pid=880134877" marginwidth="0"><script language="javascript" src="http://ad.jp.ap.valuecommerce.com/servlet/jsbanner?sid=2780819&pid=880134877"></script><noscript><a href="http://ck.jp.ap.valuecommerce.com/servlet/referral?sid=2780819&pid=880134877" target="_blank" ><img src="http://ad.jp.ap.valuecommerce.com/servlet/gifbanner?sid=2780819&pid=880134877" height="60" width="234" border="0"></a></noscript></iframe>
<br>
<br>
<ul data-role="listview">
<li data-role="list-divider">賃貸$manshon</li>
<li><img src="/img/E110_20.gif" height="20" class="ui-li-icon"><a href="/chintaipref/">住所から探す</a></li>
<li><img src="/img/E01E_20.gif" height="20" class="ui-li-icon"><a href="/chintaistation/">駅から探す</a></li>
</ul>
</div>
<img src="/img/E022_20.gif" height="20">賃貸MAXは、オシャレな賃貸$manshonが探せる賃貸検索サービスです。<img src="/img/E00F_20.gif" height="20">一人暮らしのお部屋探しは、賃貸。敷金・礼金なし賃貸がおすすめ<br>

END_OF_HTML
	
&html_footer($self);

	return;
}


1;