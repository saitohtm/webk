package Waao::Pages::Hatsumode;
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

	$self->{html_title} = qq{初詣2011 オススメ初詣スポット情報};
	$self->{html_keywords} = qq{初詣,神社,ご利益,アクセス};
	$self->{html_description} = qq{全国の初詣スポットが分かる初詣2011};
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
<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">たった1分でわかる2011年初詣オススメスポット棈</font></marquee>
<center>
<h2><img src="http://img.waao.jp/hatsumode2011.gif" width=120 height=28 alt="初詣スポット"><font size=1 color="#FF0000">プラス</font></h2>
<h2><font size=1>2011<font color="#FF0000">初詣</font>オススメスポット</font></h2>
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
<img src="http://img.waao.jp/mb17.gif" width=11 height=12>人気初詣スポット<br>
<a href="/明治神宮/hatsumode/180/" title="明治神宮">明治神宮</a><br>
<a href="/成田山新勝寺/hatsumode/133/" title="成田山新勝寺">成田山新勝寺</a><br>
<a href="/川崎大師/hatsumode/195/" title="川崎大師">川崎大師</a><br>
<a href="/伏見稲荷大社/hatsumode/352/" title="伏見稲荷大社">伏見稲荷大社</a><br>
<a href="/鶴岡八幡宮/hatsumode/198/" title="鶴岡八幡宮">鶴岡八幡宮</a><br>
$hr
END_OF_HTML

my $sth = $self->{dbi}->prepare(qq{select id, name from pref });
$sth->execute();
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<font color="#009525">》</font><a href="/list-$row[0]/hatsumode/">$row[1]</a><br>
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
<a href="/" accesskey=0>トップ</a>&gt;<strong>初詣2011</strong><br>
<font size=1 color="#AAAAAA">初詣2011は、全国のオススメ初詣スポット情報、神社のご利益、最寄り駅が検索できます。<br>
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

	$self->{html_title} = qq{初詣2011 $pref_nameのオススメ初詣スポット情報};
	$self->{html_keywords} = qq{初詣,$pref_name,神社,ご利益,アクセス};
	$self->{html_description} = qq{$pref_nameの初詣スポットが分かる初詣2011};
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
<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">たった1分でわかる2011年$pref_nameの初詣オススメスポット棈</font></marquee>
<center>
<h2><font size=1>$pref_name<font color="#FF0000">初詣</font>オススメスポット</font></h2>
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

my $sth = $self->{dbi}->prepare( qq{select id,name from hatsumoude where pref = ? });
$sth->execute($prefid);
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<font color="#009525">》</font><a href="/$row[1]/hatsumode/$row[0]/" title="$row[1]">$row[1]</a><br>
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
<a href="/" accesskey=0>トップ</a>&gt;<a href="/hatsumode/">初詣2011</a>&gt;<strong>$pref_nameの初詣スポット</strong><br>
<font size=1 color="#AAAAAA">初詣2011は、$pref_nameのオススメ初詣スポット情報、神社のご利益、最寄り駅が検索できます。<br>
</fonnt>
END_OF_HTML

}
	
	&html_footer($self);
	
	return;
}

sub _detail(){
	my $self = shift;
	my $id = $self->{cgi}->param('p1');
	

	my ($name, $reeki, $prefid, $pref_name, $address, $station);
	my $sth = $self->{dbi}->prepare( qq{select name,reeki,pref,pref_name,address,station from hatsumoude where id = ? });
	$sth->execute($id);
	while(my @row = $sth->fetchrow_array) {
		($name, $reeki, $prefid, $pref_name, $address, $station) = @row;
	}

	$self->{html_title} = qq{初詣2011 $name};
	$self->{html_keywords} = qq{初詣,$name,神社,ご利益,アクセス};
	$self->{html_description} = qq{$nameの初詣情報。ご利益やアクセス方法がひと目でわかります};
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
<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">たった1分でわかる2011年$nameの初詣情報</font></marquee>
<center>
<h2><font size=1>初詣<font color="#FF0000">$name</font></font></h2>
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

	my $yicha_link_station = &html_yicha_url($self, "$name", 'p');

print << "END_OF_HTML";
<img src="http://img.waao.jp/ol4_1b.gif" width=40 height=50 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"><font color="#FF8000">ご利益</font><br>
$reeki
<br clear="all" />
<img src="http://img.waao.jp/kaowink02.gif" width=53 height=15><a href="$yicha_link_station">$nameの詳細情報</a><br>
<br>
 :$station<br>
住所:$address<br>
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
<a href="/" accesskey=0>トップ</a>&gt;<a href="/hatsumode/">初詣2011</a>&gt;<strong>$nameの初詣スポット</strong><br>
<font size=1 color="#AAAAAA">初詣2011は、$nameのオススメ初詣スポット情報、神社のご利益、最寄り駅が検索できます。<br>
</fonnt>
END_OF_HTML

}
	
	&html_footer($self);
	
	return;
}
1;