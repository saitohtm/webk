package Waao::Pages::SMFZip;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Html5;
use Waao::Data;
use Waao::Utility;

# /zip(ID)/
# /zippref()/
# /ziparea()/

sub dispatch(){
	my $self = shift;

	if($self->{cgi}->param('pref') eq 'all'){
		&_prefall($self);
	}elsif($self->{cgi}->param('pref')){
		&_pref($self);
	}elsif($self->{cgi}->param('area')){
		&_area($self);
	}elsif($self->{cgi}->param('keyword')){
		&_keyword($self);
	}elsif($self->{cgi}->param('zip')){
		&_detail($self);
	}	

	return;
}

sub _keyword(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('keyword');

	Encode::from_to($keyword,'utf8','cp932');
	
	$keyword =~s/-//g;

	my $searchlist;
	my $sth = $self->{dbi}->prepare(qq{ select zip, addr1, addr2, addr3,jis from zip where zip like "%}.$keyword.qq{%"});
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$searchlist .= qq{<li><a href="/zip$row[0]/">$row[0]<br>$row[1]$row[2]$row[3]</a></li>};
	}
	
	unless($searchlist){
		my $sth = $self->{dbi}->prepare(qq{ select zip, addr1, addr2, addr3,jis from zip where allstr like "%}.$keyword.qq{%"});
		$sth->execute();
		while(my @row = $sth->fetchrow_array) {
			$searchlist .= qq{<li><a href="/zip$row[0]/"><font color="red">〒</font>$row[0]<br>$row[1]$row[2]$row[3]</a></li>};
		}
	}

	unless($searchlist){
		$searchlist .= qq{該当するデータがありません};
	}
		
	my $a = "$keywordの郵便番号 住所・郵便番号かららくらく検索 ";
	$self->{html_title} = qq{$a};
	my $b = "$keyword,郵便番号,郵便番号検索,住所";
	$self->{html_keywords} = qq{$b};
	my $c = "$keywordの郵便番号 住所・郵便番号かららくらく検索。スマフォMAX";
	$self->{html_description} = qq{$c};
	&html_header($self);
		
print << "END_OF_HTML";
<div data-role="header"> 
<h1>$keywordの郵便番号</h1> 
</div>
<a href="/">スマフォMAX&gt;<a href="/zip.htm">郵便番号</a>&gt;$keywordの郵便番号
<div data-role="content">
<ul data-role="listview">
<li data-role="list-divider">$keywordの郵便番号</li>
$searchlist
</ul>
</div>
END_OF_HTML

	&html_footer($self);

	return;
}

sub _prefall(){
	my $self = shift;
	
my $arealist;
my $sth = $self->{dbi}->prepare(qq{select id, name from pref });
$sth->execute();
while(my @row = $sth->fetchrow_array) {
	$arealist .= qq{<li><img src="/img/E231_20.gif" height="20" class="ui-li-icon"><a href="/zippref$row[0]/">$row[1]</a></li>};
}

	my $a = "郵便番号検索 住所から郵便番号を探す ";
	$self->{html_title} = qq{$a};
	my $b = "郵便番号,郵便番号検索,住所";
	$self->{html_keywords} = qq{$b};
	my $c = "郵便番号 住所から郵便番号をらくらく検索。スマフォMAX";
	$self->{html_description} = qq{$c};
	&html_header($self);

print << "END_OF_HTML";
<div data-role="header"> 
<h1>郵便番号検索</h1> 
</div>
<a href="/">スマフォMAX</a>&gt;<a href="/zip.htm">郵便番号検索</a>&gt;都道府県一覧

<div data-role="content">
<ul data-role="listview">
<li data-role="list-divider">郵便番号検索</li>
$arealist
</ul>
</div>
END_OF_HTML

	&html_footer($self);

	return;
}

sub _pref(){
	my $self = shift;
	
my $pref_name;	
my $sth = $self->{dbi}->prepare(qq{select name from pref where id = ? });
$sth->execute($self->{cgi}->param('pref'));
while(my @row = $sth->fetchrow_array) {
	$pref_name = $row[0];
}

my $arealist;
my $sth = $self->{dbi}->prepare(qq{ select addr2, zip, jis from zip where addr1 = ? group by addr2});
$sth->execute($pref_name);
while(my @row = $sth->fetchrow_array) {
	$arealist .= qq{<li><img src="/img/E231_20.gif" height="20" class="ui-li-icon"><a href="/ziparea$row[1]-$row[2]/">$row[0]</a></li>};
}

	my $a = "$pref_nameの郵便番号 住所・郵便番号かららくらく検索 ";
	$self->{html_title} = qq{$a};
	my $b = "$pref_name,郵便番号,郵便番号検索,住所";
	$self->{html_keywords} = qq{$b};
	my $c = "$pref_nameの郵便番号 住所・郵便番号かららくらく検索。スマフォMAX";
	$self->{html_description} = qq{$c};
	&html_header($self);

print << "END_OF_HTML";
<div data-role="header"> 
<h1>$pref_nameの郵便番号</h1> 
</div>
<a href="/">スマフォMAX</a>&gt;<a href="/zip.htm">郵便番号検索</a>&gt;<a href="/zipprefall/">都道府県一覧</a>&gt;$pref_nameの郵便番号

<div data-role="content">
<ul data-role="listview">
<li data-role="list-divider">$pref_nameの郵便番号</li>
$arealist
</ul>
</div>
END_OF_HTML

	&html_footer($self);

	return;
}

sub _area(){
	my $self = shift;
	
my $addr2;
my $sth = $self->{dbi}->prepare(qq{ select addr2 from zip where zip = ? and jis = ?});
$sth->execute($self->{cgi}->param('area'), $self->{cgi}->param('jis'));
while(my @row = $sth->fetchrow_array) {
	$addr2 = $row[0];
}

my $pref_name;
my $area;
my $arealist;
my $zip;
my $jis;
my $addr3;
my $sth = $self->{dbi}->prepare(qq{ select zip, addr1, addr2, addr3,jis from zip where addr2 = ? });
$sth->execute($addr2);
while(my @row = $sth->fetchrow_array) {
	$zip = qq{$row[0]};
	$pref_name = qq{$row[1]};
	$area = qq{$row[2]$row[3]};
	$addr3 = qq{$row[3]};
	$jis = qq{$row[4]};
	$arealist .= qq{<li><img src="/img/E231_20.gif" height="20" class="ui-li-icon"><a href="/zip$row[0]/">$row[3]</a></li>};
}

my $pref_id;
my $sth = $self->{dbi}->prepare(qq{select id, name from pref where name = ?});
$sth->execute($pref_name);
while(my @row = $sth->fetchrow_array) {
	$pref_id = $row[0];
}

	my $a = "$areaの郵便番号 住所・郵便番号かららくらく検索 ";
	$self->{html_title} = qq{$a};
	my $b = "$area,郵便番号,郵便番号検索,住所";
	$self->{html_keywords} = qq{$b};
	my $c = "$areaの郵便番号 住所・郵便番号かららくらく検索。スマフォMAX";
	$self->{html_description} = qq{$c};
	&html_header($self);

print << "END_OF_HTML";
<div data-role="header"> 
<h1>$areaの郵便番号</h1> 
</div>

<a href="/">スマフォMAX</a>&gt;<a href="/zip.htm">郵便番号検索</a>&gt;<a href="/zipprefall/">都道府県一覧</a>&gt;<a href="/zippref$pref_id/">$pref_name</a>&gt;<a href="/ziparea$zip-$jis/">$addr2</a>&gt;$addr3の郵便番号
<div data-role="content">
<ul data-role="listview">
<li data-role="list-divider">$areaの郵便番号</li>
$arealist
</ul>
</div>
END_OF_HTML

	&html_footer($self);

	return;
}

sub _detail(){
	my $self = shift;

my $pref_name;
my $area;
my $area_name;
my $arealist;
my $zip;
my $jis;
my $sth = $self->{dbi}->prepare(qq{ select zip, addr1, addr2, addr3, jis, addr1_kana, addr2_kana, addr3_kana from zip where zip = ?  });
$sth->execute($self->{cgi}->param('zip'));
while(my @row = $sth->fetchrow_array) {
	$zip = qq{$row[0]};
	$pref_name = qq{$row[1]};
	$area_name = qq{$row[2]};
	$jis = qq{$row[4]};
	$area = qq{$row[1]$row[2]$row[3]};
	$arealist .= qq{<li><font color="red">〒</font>$row[0]<br>$area<br>$row[5] $row[6] $row[7]</li>};
}

my $pref_id;
my $sth = $self->{dbi}->prepare(qq{select id, name from pref where name = ?});
$sth->execute($pref_name);
while(my @row = $sth->fetchrow_array) {
	$pref_id = $row[0];
}

	my $a = "$areaの郵便番号 住所・郵便番号かららくらく検索 ";
	$self->{html_title} = qq{$a};
	my $b = "$area,郵便番号,郵便番号検索,住所,スマフォ";
	$self->{html_keywords} = qq{$b};
	my $c = "$areaの郵便番号 住所・郵便番号かららくらく検索。スマフォMAX";
	$self->{html_description} = qq{$c};
	&html_header($self);

print << "END_OF_HTML";
<div data-role="header"> 
<h1>$areaの郵便番号</h1> 
</div>
<a href="/">スマフォMAX</a>&gt;<a href="/zip.htm">郵便番号検索</a>&gt;<a href="/zipprefall/">都道府県一覧</a>&gt;<a href="/zippref$pref_id/">$pref_name</a>&gt;<a href="/ziparea$zip-$jis/">$area_name</a>&gt;$areaの郵便番号
<div data-role="content">
<ul data-role="listview">
<li data-role="list-divider">$areaの郵便番号</li>
$arealist

<li><img src="/img/E132_20.gif" height="20" class="ui-li-icon">地図で確認する</li>
<iframe src="http://map.yahoo.co.jp/search?p=$zip&ei=UTF-8&lat=&lon=&prop=maptop" height=300 width=300></iframe>
</ul>
</ul>
</div>
END_OF_HTML

	&html_footer($self);

	return;
}

1;