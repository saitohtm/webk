package Waao::Pages::HellowWork;
use strict;
use base qw(Waao::Pages::Base);
use Waao::Html;
use Waao::Data;
use Waao::Utility;

# 人気ワードを表示するページ
# /kizasi/
# /list-detail/kizasi/

sub dispatch(){
	my $self = shift;

	if($self->{cgi}->param('p1')){
		&_detail($self);
	}elsif($self->{cgi}->param('q')){
		&_pref($self);
	}else{
		&_top($self);
	}
	return;
}
sub _top(){
	my $self = shift;

	$self->{html_title} = qq{ハローワーク 全国ハローワークナビ};
	$self->{html_keywords} = qq{ハローワーク,アクセス,場所,営業時間};
	$self->{html_description} = qq{全国のハローワークが探せます。ハローワークの場所や営業時間};
	my $geinou = &html_mojibake_str("geinou");

	my $hr = &html_hr($self,1);	
	&html_header($self);

	my $ad = &html_google_ad($self);

if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML
	
}else{
# xhmlt chtml

print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">たった1分でわかる全国のハローワーク棈</font></marquee>
<center>
<h2><img src="http://img.waao.jp/hellowwork.gif" width=120 height=28 alt="ハローワーク"><font size=1 color="#FF0000">プラス</font></h2>
<h2><font size=1>全国<font color="#FF0000">ハローワーク</font></font></h2>
</center>
$hr
<center>
$ad
</center>
$hr
<center>
<a href="/meikan/">
25万人褜棈<br>
<font color="#FF0000">無料</font>タレント名鑑
</a>
</center>
$hr
<img src="http://img.waao.jp/mb17.gif" width=11 height=12>ハローワーク検索<br>
END_OF_HTML

my $sth = $self->{dbi}->prepare(qq{select id, name from pref });
$sth->execute();
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<font color="#009525">》</font><a href="/list-$row[0]/hellowwork/">$row[1]</a><br>
END_OF_HTML
}

print << "END_OF_HTML";
$hr
<font color="#FF0000">ブックマーク</font>を利用すると便利です。<br>
$hr
<center>
<a href="/meikan/">
画像付棈完全無料<br>
<font color="#FF0000">無料</font>タレント名鑑
</a>
</center>
$hr
偂<a href="http://waao.jp/ranking/" title="みんなのランキング">みんなのランキング</a><br>
<a href="/" accesskey=0>トップ</a>&gt;<strong>ハローワーク検索</strong><br>
<font size=1 color="#AAAAAA">ハローワークナビは、全国のハローワーク情報が検索できます。<br>
</fonnt>
END_OF_HTML

}
	
	&html_footer($self);
	
	return;
}

sub _pref(){
	my $self = shift;
	my $prefid = $self->{cgi}->param('q');
	$prefid =~s/list-//g;
	
	my $pref_name;
	my $sth = $self->{dbi}->prepare(qq{select name from pref where id = ?});
	$sth->execute($prefid);
	while(my @row = $sth->fetchrow_array) {
		$pref_name = $row[0];
	}

	$self->{html_title} = qq{ハローワーク $pref_nameのハローワーク情報};
	$self->{html_keywords} = qq{ハローワーク,$pref_name,アクセス};
	$self->{html_description} = qq{$pref_nameのハローワークが分かるハローワークナビ};
	my $geinou = &html_mojibake_str("geinou");

	my $hr = &html_hr($self,1);	
	&html_header($self);

	my $ad = &html_google_ad($self);

if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML
	
}else{
# xhmlt chtml

print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">たった1分でわかる$pref_nameのハローワーク棈</font></marquee>
<center>
<h2><font size=1>$pref_name<font color="#FF0000">ハローワーク</font></font></h2>
</center>
$hr
<center>
$ad
</center>
$hr
<center>
<a href="/meikan/">
25万人褜棈<br>
<font color="#FF0000">無料</font>タレント名鑑
</a>
</center>
$hr
END_OF_HTML

my $sth = $self->{dbi}->prepare( qq{select id,name from hellowwork where pref_cd = ? });
$sth->execute($prefid);
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<font color="#009525">》</font><a href="/$row[1]/hellowwork/$row[0]/" title="$row[1]">$row[1]</a><br>
END_OF_HTML
}


print << "END_OF_HTML";
$hr
<font color="#FF0000">ブックマーク</font>を利用すると便利です。<br>
$hr
<center>
<a href="/meikan/">
画像付棈完全無料<br>
<font color="#FF0000">無料</font>タレント名鑑
</a>
</center>
$hr
偂<a href="http://waao.jp/ranking/" title="みんなのランキング">みんなのランキング</a><br>
<a href="/" accesskey=0>トップ</a>&gt;<a href="/hellowwork/">ハローワーク</a>&gt;<strong>$pref_nameのハローワーク</strong><br>
<font size=1 color="#AAAAAA">ハローワークは、$pref_nameのハローワークが検索できます。<br>
</fonnt>
END_OF_HTML

}
	
	&html_footer($self);
	
	return;
}

sub _detail(){
	my $self = shift;
	my $id = $self->{cgi}->param('p1');
	

	my ($name,$name2,$zipcode,$pref_cd,$pref_name,$address,$tel,$fax);
	my $sth = $self->{dbi}->prepare(qq{select name,name2,zipcode,pref_cd,pref_name,address,tel,fax from hellowwork where id = ?});
	$sth->execute($id);
	while(my @row = $sth->fetchrow_array) {
		($name,$name2,$zipcode,$pref_cd,$pref_name,$address,$tel,$fax) = @row;
	}

	$self->{html_title} = qq{$name($name2)};
	$self->{html_keywords} = qq{$name,ハローワーク,職安,$pref_name,職業安定所,職業,仕事,求人,場所,時間};
	$self->{html_description} = qq{$name($name2) $zipcode $address};
	my $geinou = &html_mojibake_str("geinou");

	my $hr = &html_hr($self,1);	
	&html_header($self);

	my $ad = &html_google_ad($self);
	my $yicha_link_hellowwork = &html_yicha_url($self, "$name2", 'p');

if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML
	
}else{
# xhmlt chtml

print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">求人情報なら全国ハローワークデータベース棈今すぐ求人情報が見つかる</font></marquee>
<center>
<h2><font size=1>$name<font color="#FF0000">($name2)</font></font></h2>
</center>
$hr
<center>
$ad
</center>
$hr

<center>
<a href="/meikan/">
25万人褜棈<br>
<font color="#FF0000">無料</font>タレント名鑑
</a>
</center>
$hr
END_OF_HTML


print << "END_OF_HTML";
<img src="http://img.waao.jp/ol4_1b.gif" width=40 height=50 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"><font color="#FF8000">ハローワーク情報</font><br>
<br clear="all" />
<font size=1>
〒$zipcode<br>
住所:$address<br>
TEL:$tel<br>
FAX:$fax<br>
<img src="http://img.waao.jp/right06.gif" width=10 height=10><a href="$yicha_link_hellowwork">詳しく見る</a>
</font>
$hr
$hr
<font color="#FF0000">ブックマーク</font>を利用すると便利です。<br>
$hr
<center>
<a href="/meikan/">
画像付棈完全無料<br>
<font color="#FF0000">無料</font>タレント名鑑
</a>
</center>
$hr
偂<a href="http://waao.jp/ranking/" title="みんなのランキング">みんなのランキング</a><br>
<a href="/" accesskey=0>トップ</a>&gt;<a href="/hellowwork/">ハローワーク</a>&gt;<strong>$nameのハローワーク</strong><br>

<font size=1 color="#AAAAAA">ハローワークデータベースは、独自で集めた情報を公開しています。<br>
公開しているハローワークの情報が最新である保証はしておりません。<br>
$name($name2) $zipcode $address</font>
END_OF_HTML

}
	
	&html_footer($self);
	
	return;
}
1;