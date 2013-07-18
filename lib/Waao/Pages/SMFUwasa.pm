package Waao::Pages::SMFUwasa;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Html5;
use Waao::Data;
use Waao::Utility;

sub dispatch(){
	my $self = shift;
	
	if($self->{cgi}->param('good')){
		&eva_uwasa($self,$self->{cgi}->param('id'),1,"");
	}elsif($self->{cgi}->param('bad')){
		&eva_uwasa($self,$self->{cgi}->param('id'),"",1);
	}

	if($self->{cgi}->param('id')){
		&_uwasa($self);
	}elsif($self->{cgi}->param('keywordid')){
		&_uwasalist($self);
	}
	
	return;
}

sub _uwasa(){
	my $self = shift;

	my $uwasaid=$self->{cgi}->param('id');

my $keywordid;
my $uwasalist;
my $uwasatitlestr;
my $uwasatitlestr2;
my $titlestr;
my $sth = $self->{dbi}->prepare(qq{ select id, keywordid, keyword, keypersonid, keyperson, type, point
                                  from keyword_recomend  where  id = ?});
$sth->execute($self->{cgi}->param('id'));
while(my @row = $sth->fetchrow_array) {

	
	
	$keywordid = $row[1];
	$uwasalist.=qq{<li>};
	$uwasalist.=qq{<img src="/img/kao-a08.gif" width=15 height=15 class="ui-li-icon">};

	# personだったら
	my ($datacnt, $keyworddata) = &get_keyword($self, $row[4]);
	if($keyworddata->{id}){
		$uwasalist.=qq{<font size=1><a href="/person$keyworddata->{id}/">$row[4]</a><div align=left>};
	}else{
		$uwasalist.=qq{<font size=1>$row[4]<div align=left>};
	}
	
	my $str;
	$str.=qq{と恋人} if($row[5] eq 1);
	$str.=qq{と元恋人} if($row[5] eq 2);
	$str.=qq{と夫婦} if($row[5] eq 3);
	$str.=qq{と友人} if($row[5] eq 4);
	$str.=qq{が好き} if($row[5] eq 5);
	$str.=qq{が嫌い} if($row[5] eq 6);
	$str.=qq{とメル友} if($row[5] eq 7);
	$str.=qq{と親子} if($row[5] eq 8);
	$str.=qq{と兄弟/姉妹} if($row[5] eq 9);
	$str.=qq{と共演者} if($row[5] eq 10);
	$str.=qq{と同郷} if($row[5] eq 11);
	$str.=qq{と同じ事務所} if($row[5] eq 12);
	$str.=qq{と元夫婦} if($row[5] eq 13);
	$str.=qq{とライバル} if($row[5] eq 14);
	$str.=qq{と同年代} if($row[5] eq 15);
	
	$titlestr = qq{$row[4]$str};
	$uwasatitlestr .= qq{<li>$row[4]$str</li><center>うわさ度 <font color="red">$row[6]</font><br>};
	$uwasatitlestr .= qq{<a href="/gooduwasa$row[0]/" data-role="button" data-inline="true">ホント</a>};
	$uwasatitlestr .= qq{<a href="/baduwasa$row[0]/" data-role="button" data-inline="true">うそ</a>};
	$uwasatitlestr .= qq{</center><br>};
	my ($photodatacnt, $photodata) = &get_photo($self, $row[3]);
	my $photo = $photodata->{url};
	$uwasatitlestr2.=qq{<li><a href="/person$row[3]/"><img src="$photo" title="$row[4]の画像" width=115><h3>$row[4]</h3></a></li>};

}
	
	my ($datacnt, $keyworddata) = &get_keyword($self, "", $keywordid);
	my $keyword = $keyworddata->{keyword};
	my $keyword_encode = &str_encode($keyword);

	my $goodstr;
	if($self->{cgi}->param('good')){
		$goodstr = "良いうわさ";
	}elsif($self->{cgi}->param('bad')){
		$goodstr = "悪いうわさ";
	}

	my $a = "$keywordのうわさ:$keywordは、$titlestr $goodstr $uwasaid";
	$self->{html_title} = qq{$a};
	my $b = "$keyword,うわさ,$titlestr";
	$self->{html_keywords} = qq{$b};
	my $c = "$keywordは、$titlestr $keywordのうわさは、他のサイトでは探せないくちこみ情報です。$goodstr $uwasaid";
	$self->{html_description} = qq{$c};
	&html_header($self);

print << "END_OF_HTML";
<div data-role="header"> 
<h1>$keywordのうわさ</h1> 
</div>
<a href="/">スマフォMAX</a>&gt;<a href="/person$keywordid/">$keyword</a>&gt;<a href="/uwasalist$keywordid/">$keywordのうわさ一覧</a>&gt;<strong>$keywordのうわさ</strong>

<div data-role="content">
<ul data-role="listview">
<li data-role="list-divider">$keywordのうわさ</li>
$uwasatitlestr
</ul>
<ul data-role="listview">
$uwasatitlestr2
</ul>
<ul data-role="listview">
<li><img src="/img/kya-.gif" height="25" class="ui-li-icon"><a href="/uwasaregist$keyworddata->{id}/">うわさを投稿</a></li>
<li><a href="/uwasalist$keyworddata->{id}/">$keywordのうわさ一覧</a></li>
<li data-role="list-divider">NAVER トピック検索</li>
<iframe src="http://search.naver.jp/m/topics?q=$keyword_encode" height=300 width=300></iframe>
<li data-role="list-divider">Yahoo! ニュース検索</li>
<iframe src="http://news.search.yahoo.co.jp/search?ei=UTF-8&p=$keyword_encode" height=300 width=300></iframe>
</ul>
</div>
$keywordのうわさ。クチコミによって集めた$keywordのうわさ情報です。<br>

END_OF_HTML

	
&html_footer($self);

	return;
}

sub _uwasalist(){
	my $self = shift;
	my $keywordid = $self->{cgi}->param('keywordid');
	
	my ($datacnt, $keyworddata) = &get_keyword($self, "", $self->{cgi}->param('keywordid'));
	my $keyword = $keyworddata->{keyword};
	my $keyword_encode = &str_encode($keyword);

my $uwasalist;

my $sth = $self->{dbi}->prepare(qq{ select id, keywordid, keyword, keypersonid, keyperson, type, point
                                  from keyword_recomend  where  keywordid = ? and point >= -100 order by point desc });
$sth->execute($keywordid);
while(my @row = $sth->fetchrow_array) {
	my ($photodatacnt, $photodata) = &get_photo($self, $row[3]);
	my $photo = $photodata->{url};

	$uwasalist.=qq{<li>};
	$uwasalist.=qq{<a href="/uwasa$row[0]/"><img src="$photo" title="$row[4]の画像" width=115>};
	$uwasalist.=qq{<h3>$row[4]</h3><p>};
	$uwasalist.=qq{と恋人} if($row[5] eq 1);
	$uwasalist.=qq{と元恋人} if($row[5] eq 2);
	$uwasalist.=qq{と夫婦} if($row[5] eq 3);
	$uwasalist.=qq{と友人} if($row[5] eq 4);
	$uwasalist.=qq{が好き} if($row[5] eq 5);
	$uwasalist.=qq{が嫌い} if($row[5] eq 6);
	$uwasalist.=qq{とメル友} if($row[5] eq 7);
	$uwasalist.=qq{と親子} if($row[5] eq 8);
	$uwasalist.=qq{と兄弟/姉妹} if($row[5] eq 9);
	$uwasalist.=qq{と共演者} if($row[5] eq 10);
	$uwasalist.=qq{と同郷} if($row[5] eq 11);
	$uwasalist.=qq{と同じ事務所} if($row[5] eq 12);
	$uwasalist.=qq{と元夫婦} if($row[5] eq 13);
	$uwasalist.=qq{とライバル} if($row[5] eq 14);
	$uwasalist.=qq{と同年代} if($row[5] eq 15);
	$uwasalist.=qq{ うわさ度 <font color="red">$row[6]</font></p></a>};
	$uwasalist.=qq{</li>};
}



	my $photolist;
	my $cnt;
	my $sth = $self->{dbi}->prepare(qq{ select id, good, url, fullurl from photo where keywordid = ? order by good desc} );
	$sth->execute($self->{cgi}->param('keywordid'));
	while(my @row = $sth->fetchrow_array) {
		$cnt++;
		$photolist .= qq{<a href="/photoid$row[0]/"><img src="$row[2]" width="75" alt="$keyword画像"></a>};
		$photolist .= qq{<br>} unless($cnt % 4);
	}

	my $a = "$keywordのうわさ一覧(うわさでわかる恋愛関係(彼氏・彼女・結婚・離婚)人間関係検索)	";
	$self->{html_title} = qq{$a};
	my $b = "$keyword,うわさ,恋愛,熱愛,彼氏,彼女,結婚,離婚";
	$self->{html_keywords} = qq{$b};
	my $c = "$keywordのうわさ一覧は、$keywordの恋愛・人間関係（彼氏・彼女・結婚・離婚）をクチコミであつめたうわさ検索です";
	$self->{html_description} = qq{$c};
	&html_header($self);

print << "END_OF_HTML";
<div data-role="header"> 
<h1>$keywordのうわさ</h1> 
</div>
<a href="/">スマフォMAX</a>&gt;<a href="/person$keywordid/">$keyword</a>&gt;<strong>$keywordのうわさ一覧</strong>

<div data-role="content">
<ul data-role="listview">
<li data-role="list-divider">$keywordうわさ一覧</li>
<li><img src="/img/kya-.gif" height="25" class="ui-li-icon"><a href="/uwasaregist$keyworddata->{id}/">うわさを投稿</a></li>
$uwasalist
<li><a href="/person$keywordid/"><font size=1>$keywordとは</font></a></li>
<li data-role="list-divider">NAVER トピック検索</li>
<iframe src="http://search.naver.jp/m/topics?q=$keyword_encode" height=300 width=300></iframe>
<li data-role="list-divider">Yahoo! ニュース検索</li>
<iframe src="http://news.search.yahoo.co.jp/search?ei=UTF-8&p=$keyword_encode" height=300 width=300></iframe>
</ul>
</div>
$keywordのうわさ。クチコミによって集めた$keywordのうわさ情報です。<br>
END_OF_HTML
	
&html_footer($self);

	return;
}

1;