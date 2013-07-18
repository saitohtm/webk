package Waao::Pages::SMFHellowwork;
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

	if($self->{cgi}->param('id')){
		&_detail($self);
	}elsif($self->{cgi}->param('pref')){
		&_pref($self);
	}else{
		&_top($self);
	}

	return;
}

sub _detail(){
	my $self = shift;
	my $id = $self->{cgi}->param('id');

	my ($name,$name2,$zipcode,$pref_cd,$pref_name,$address,$tel,$fax);
	my $sth = $self->{dbi}->prepare(qq{select name,name2,zipcode,pref_cd,pref_name,address,tel,fax from hellowwork where id = ?});
	$sth->execute($id);
	while(my @row = $sth->fetchrow_array) {
		($name,$name2,$zipcode,$pref_cd,$pref_name,$address,$tel,$fax) = @row;
	}


	my $a = "$name($name2) スマフォMAX";
	$self->{html_title} = qq{$a};
	my $b = "$name,ハローワーク,職安,$pref_name,職業安定所,職業,仕事,求人,場所,時間";
	$self->{html_keywords} = qq{$b};
	my $c = "$name($name2) $zipcode $address。スマフォMAX";
	$self->{html_description} = qq{$c};
	&html_header($self);

print << "END_OF_HTML";
<div data-role="header"> 
<h1>$name($name2)</h1> 
</div>
<a href="/">スマフォMAX</a>&gt;<a href="/hellow-work/">ハローワーク検索</a>&gt;<a href="/hellow-work-pref$pref_cd/">$pref_nameのハローワーク</a>&gt:$name($name2)

<div data-role="content">
<ul data-role="listview">
<li data-role="list-divider">$name($name2)</li>
<li>
<font color="red">〒</font>$zipcode<br>
住所:$address<br>
TEL:$tel<br>
FAX:$fax<br>
</li>
</ul>
</div>
<iframe src="http://map.yahoo.co.jp/search?p=$tel&ei=UTF-8&lat=&lon=&prop=maptop" height=300 width=300></iframe>
END_OF_HTML

	&html_footer($self);




	return;
}

sub _pref(){
	my $self = shift;

	my $prefid = $self->{cgi}->param('pref');
	my $pref_name;
	my $sth = $self->{dbi}->prepare(qq{select name from pref where id = ?});
	$sth->execute($prefid);
	while(my @row = $sth->fetchrow_array) {
		$pref_name = $row[0];
	}

	my $liststr;
	my $sth = $self->{dbi}->prepare( qq{select id,name from hellowwork where pref_cd = ? });
	$sth->execute($prefid);
	while(my @row = $sth->fetchrow_array) {
		$liststr .= qq{<li><img src="/img/E231_20.gif" height="20" class="ui-li-icon"><a href="/hellow-work-id$row[0]/">$row[1]</a></li>};
	}

	my $a = "$pref_nameのハローワーク 全国職業安定所で仕事探し スマフォMAX";
	$self->{html_title} = qq{$a};
	my $b = "$pref_name,ハローワーク,職業安定所,就職,仕事,仕事探し";
	$self->{html_keywords} = qq{$b};
	my $c = "$pref_nameのハローワークで仕事探し（全国職業安定所ナビ）。スマフォMAX";
	$self->{html_description} = qq{$c};
	&html_header($self);

print << "END_OF_HTML";
<div data-role="header"> 
<h1>$pref_nameのハローワーク</h1> 
</div>
<a href="/">スマフォMAX</a>&gt;<a href="/hellow-work/">ハローワーク検索</a>&gt;$pref_nameのハローワーク

<div data-role="content">
<ul data-role="listview">
<li data-role="list-divider">$pref_nameのハローワーク</li>
$liststr
</ul>
</div>
END_OF_HTML

	&html_footer($self);

	return;
}


sub _top(){
	my $self = shift;
	
my $arealist;
my $sth = $self->{dbi}->prepare(qq{select id, name from pref });
$sth->execute();
while(my @row = $sth->fetchrow_array) {
	$arealist .= qq{<li><img src="/img/E231_20.gif" height="20" class="ui-li-icon"><a href="/hellow-work-pref$row[0]/">$row[1]</a></li>};
}

	my $a = "ハローワーク 全国職業安定所で仕事探し スマフォMAX";
	$self->{html_title} = qq{$a};
	my $b = "ハローワーク,職業安定所,就職,仕事,仕事探し";
	$self->{html_keywords} = qq{$b};
	my $c = "全国のハローワークで仕事探し（全国職業安定所ナビ）。スマフォMAX";
	$self->{html_description} = qq{$c};
	&html_header($self);

print << "END_OF_HTML";
<a href="/" style="display: block;"><img src="/img/smfhellowwork.jpg" width=100% alt="ハローワーク検索"></a>
<div data-role="header"> 
<h1>ハローワーク検索</h1> 
</div>
<a href="/">スマフォMAX</a>&gt;ハローワーク検索

<div data-role="content">
<ul data-role="listview">
<li data-role="list-divider">ハローワーク検索</li>
$arealist
</ul>
</div>
END_OF_HTML

	&html_footer($self);

	return;
}







1;