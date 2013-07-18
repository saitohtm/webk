package Waao::Pages::SMFPerson;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Html5;
use Waao::Data;
use Waao::Utility;

sub dispatch(){
	my $self = shift;
	
	if($self->{cgi}->param('id')){
		&_person($self);
		&cnt_keyword($self, $self->{cgi}->param('id'));
	}
	
	return;
}

sub _person(){
	my $self = shift;
	
	my ($datacnt, $keyworddata) = &get_keyword($self, "", $self->{cgi}->param('id'));
	my $keyword = $keyworddata->{keyword};

	if($keyword=~/(.*)\((.*)\)/){
		my ($datacnt_tmp, $keyworddata_tmp) = &get_keyword($self, $1, "");
		if($keyworddata_tmp->{id}){
			$datacnt = $datacnt_tmp;
			$keyworddata = $keyworddata_tmp;
		}
	}
	my $a = "$keyword MAX $keywordのプロフィール/画像/動画検索 スマフォMAX";
	$self->{html_title} = qq{$a};
	my $b = "$keyword,プロフィール,画像,動画,検索,スマフォ";
	$self->{html_keywords} = qq{$b};
	my $c = "$keywordのスマフォサイト。$keyword MAX は、$keywordのプロフィール/画像/動画検索サイトです";
	$self->{html_description} = qq{$c};
	&html_header($self);
	
my $images;
my $sth = $self->{dbi}->prepare(qq{ select id, good, url, fullurl from photo where keywordid = ? order by good desc, yahoo limit 4} );
$sth->execute($keyworddata->{id});
while(my @row = $sth->fetchrow_array) {
	$images.=qq{<a href="/photoid$row[0]/"<img src="$row[2]" alt="$keyword画像" width="75"></a>};
}

my $uwasalist;

my $sth = $self->{dbi}->prepare(qq{ select id, keywordid, keyword, keypersonid, keyperson, type, point
                                  from keyword_recomend  where  keywordid = ? and point >= -100 order by point desc limit 5});
$sth->execute($keyworddata->{id});
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

my $qandalist;
my $sth = $self->{dbi}->prepare(qq{select id, question, bestanswer, url from qanda where keywordid = ? order by id desc limit 5 } );
$sth->execute( $keyworddata->{id} );
while(my @row = $sth->fetchrow_array) {
my $answer = substr($row[2], 0, 64);
	$qandalist.=qq{<ul data-role="listview" data-inset="true">};
	$qandalist.=qq{<li><font color="#555555" size=1><font color="#0035D5">■質問</font>:$row[1] </font></li>};
	$qandalist.=qq{<li><a href="/qanda$row[0]/"><font color="#555555" size=1><font color="#FF0000">■回答</font>:$answer ...</font></a></li>};
	$qandalist.=qq{</ul>};
}

my $blog;
my $twitter;
if($keyworddata->{blogurl}){
	$blog = qq{<li><img src="/img/blog.jpg" height="25" class="ui-li-icon"><a href="/blogid$keyworddata->{id}/">ブログ $keyword</a></li>};
}

if($keyworddata->{twitterurl}){
	$twitter = qq{<li><img src="/img/twitter.png" height="25" class="ui-li-icon"><a href="/twitid$keyworddata->{id}/">Twitter $keyword</a></li>};
}

print << "END_OF_HTML";
<div data-role="header"> 
<h1>$keyword</h1> 
</div>
<a href="/">スマフォMAX</a>&gt;$keyword -人物名鑑-

<div data-role="content">
<ul data-role="listview">
<li data-role="list-divider">$keywordイメージ</li>
$images
<li><img src="/img/E022_20.gif" height="20" class="ui-li-icon"><a href="http://person.smax.tv/keyword-$keyworddata->{id}/">$keyword PERSONS</a></li>
<li><img src="/img/E008_20.gif" height="20" class="ui-li-icon"><a href="/photolist$keyworddata->{id}/">$keywordの画像一覧</a></li>
<li><img src="/img/E507_20.gif" height="20" class="ui-li-icon"><a href="/movielist$keyworddata->{id}/">$keywordの動画一覧</a></li>
$blog
$twitter
</ul>
</div>
END_OF_HTML


if($keyworddata->{simplewiki}){
print << "END_OF_HTML";
<div data-role="content">
<ul data-role="listview">
<li data-role="list-divider">$keywordとは</li>
$keyworddata->{simplewiki} ...
<li><img src="/img/E301_20.gif" height="20" class="ui-li-icon"><a href="/wiki$keyworddata->{wiki_id}/">$keywordとは</a></li>
</ul>
</div>
END_OF_HTML
}

if($uwasalist){
print << "END_OF_HTML";
<div data-role="content">
<ul data-role="listview">
<li data-role="list-divider">$keywordのうわさ</li>
$uwasalist
<li><img src="/img/E106_20_ani.gif" height="20" class="ui-li-icon"><a href="/uwasalist$keyworddata->{id}/">$keywordのうわさ一覧</a></li>
</ul>
</div>
END_OF_HTML
}else{
print << "END_OF_HTML";
<div data-role="content">
<ul data-role="listview">
<li data-role="list-divider">$keywordのうわさ</li>
<li><img src="/img/kya-.gif" height="25" class="ui-li-icon"><a href="/uwasaregist$keyworddata->{id}/"><font size=1>うわさを投稿</font></a></li>
</ul>
</div>
END_OF_HTML
}

if($qandalist){
print << "END_OF_HTML";
<div data-role="content">
<ul data-role="listview">
<li data-role="list-divider">$keywordのQ&A</li>
</ul>
<br>
$qandalist
<br>
<ul data-role="listview">
<li><img src="/img/E020_20.gif" height="20" class="ui-li-icon"><a href="/qandalist$keyworddata->{id}/">$keywordの質問一覧</a></li>
</ul>
</div>
<img src="/img/E426_20.gif" height="20">$keywordのファン必見の$keywordサイトは、リンクフリーです<img src="/img/E425_20.gif" height="20"><br>

END_OF_HTML
}
	
&html_footer($self);

	return;
}

1;