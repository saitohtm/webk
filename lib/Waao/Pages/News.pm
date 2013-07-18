package Waao::Pages::News;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Html;
use Waao::Utility;
use XML::Simple;
use LWP::Simple;
use Jcode;
use CGI qw( escape );

sub dispatch(){
	my $self = shift;
	my $newsid = $self->{cgi}->param('p1'); 

	if($newsid){
		&_newsdetail($self, $newsid);
		return;
	}
	if($self->{cgi}->param('q')){
		&_yahoo_news_search($self);
		return;
	}
	$self->{html_title} = qq{$self->{date_yyyy_mm_dd} ニュース速報プラス -みんなのモバイル-};
	$self->{html_keywords} = qq{ニュース,速報,エンタメ};
	$self->{html_description} = qq{ニュース速報 Plus。ニュース情報 プラス 独自で集めたゴシップ情報満載のニュース検索サイト};
   
	my $hr = &html_hr($self,1);	
	&html_header($self);

	my $ad = &html_google_ad($self);

	# 最新 News
	my $news = $self->{mem}->get( 'news' );
	my $mnews = $self->{mem}->get( 'mnews' );
	my $geinounews = $self->{mem}->get( 'geinounews' );

if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML
	
}else{
# xhmlt chtml

&html_table($self, qq{$self->{date_yyyy_mm_dd}の<font color="#FF0000">ニュース速報</font>}, 0, 0);
print << "END_OF_HTML";
$hr
<center>$ad</center>
$hr
END_OF_HTML

&html_table($self, qq{<font color="#00968c">エンタメニュース速報</font>}, 0, 0);

print << "END_OF_HTML";
<font size=1>
$geinounews
<div align=right><img src="http://img.waao.jp/right07.gif" widht=10 height=10><a href="/list-ent/">全てのエンタメニュースを見る</a></div>
</font>
END_OF_HTML

&html_table($self, qq{<font color="#00968c">一般ニュース速報</font>}, 0, 0);
print << "END_OF_HTML";
<font size=1>
$news
<div align=right><img src="http://img.waao.jp/right07.gif" widht=10 height=10><a href="/list-news/">全てのニュースを見る</a></div>
</font>
$hr
END_OF_HTML

&melmaga_link($self);

print << "END_OF_HTML";
$hr
END_OF_HTML

&html_table($self, qq{<font color="#00968c">ニュース速報</font><font color="#FF0000">プラス</font>}, 0, 0);

print << "END_OF_HTML";
<font size=1>
オススメ<strong>ニュース速報</strong>サイト<br>
<a href="http://bookmark.goo.to/siteinfo.html?&bid=21876">Yahoo!騰綾</a><br>
<a href="http://bookmark.goo.to/siteinfo.html?&bid=93">NewsCafe</a><br>
<a href="http://bookmark.goo.to/siteinfo.html?&bid=18869">痛いニュース(ノ∀`) </a><br>
<a href="http://bookmark.goo.to/siteinfo.html?&bid=6723">はてなブックマーク</a><br>
<a href="http://bookmark.goo.to/siteinfo.html?&bid=21868">ALL About Japan</a><br>
<a href="http://bookmark.goo.to/siteinfo.html?&bid=21877">叛りか</a><br>
</font>
$hr
偂<a href="http://waao.jp/list-in/ranking/4/">みんなのランキング</a><br>
<a href="/" accesskey=0>トップ</a>&gt;<strong>ニュース速報プラス</strong><br>
<font size=1 color="#E9E9E9">この㌻は、最新のニュース速報と独自エンタメ情報をプラスしたニュース速報㌻です。<br>
みんなのモバイルで独自に収集したニュースのクチコミ情報をプラスしてニュース情報を検索できるニュース速報データベースです。<br>
ニュース速報情報の収集にご協力をお願いします。<br>
ニュース速報㌻は、yahoo!トピックスAPIを利用しています。<br>
<a href="http://developer.yahoo.co.jp/about">Webサービス by Yahoo! JAPAN</a>
</font>
END_OF_HTML

}

&html_footer($self);
	
	return;
}

# /list-ent/list-ent/date/
sub dispatch_list_ent(){
	my $self = shift;
	my $date = $self->{cgi}->param('p1'); 
	
   $self->{html_title} = qq{エンタメニュース速報プラス -ニュース速報プラス-};
   $self->{html_keywords} = qq{ニュース,速報,エンタメ};
   $self->{html_description} = qq{ニュース速報プラス。ニュース情報 プラス 独自で集めたゴシップ情報満載のニュース検索サイト};

	my $hr = &html_hr($self,1);	
	&html_header($self);

	my $ad = &html_google_ad($self);

	unless($date){
		my $sth = $self->{dbi}->prepare(qq{ select max(insdate) as max from topics limit 1});
		$sth->execute();
		while(my @row = $sth->fetchrow_array) {
			$date = $row[0];
		}
	}
	my $nextid;
	my $newslist;
	my $sth = $self->{dbi}->prepare(qq{ select id, titlestr, news, keywords from topics where insdate = ? });
	$sth->execute($date);
	while(my @row = $sth->fetchrow_array) {
		$nextid = ($row[0] - 1) unless($nextid);
		my $titlestr = &_makelinks($row[1]);
		my $newsstr = $row[2];
		$newsstr =~ s/<.*?>//g;
		$newsstr =~s/://g;
		my $mininews = substr($newsstr,0,128);
		$mininews =~s/\n/\<br\>/g;
		$mininews .= qq{...};
		$newslist .=qq{<font color="blue">};
		$newslist .=qq{$titlestr<br>};
		$newslist .=qq{</font>};
		$newslist .=qq{<font size=1 color="#555555">$mininews<br>};
		$newslist .=qq{<div align=right><font color="#FF0000">⇒</font><a href="/list-ent/entnews/$row[0]/">もっと詳しく見る</a></div></font>};
		$newslist .=qq{$hr};
	}



if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML
	
}else{
	
&html_table($self, qq{<font color="#FF0000">$dateの最新ニュース</font>}, 0, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
$newslist
<img src="http://img.waao.jp/m2028.gif" width=48 height=9><a href="/list-news/entnews/$nextid/">次のエンタメニュースを見る</a>
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/news/">ニュース速報プラス</a>&gt;<strong>$dateの最新ニュース</strong><br>
<font size=1 color="#E9E9E9">この㌻は、最新ののニュース速報と独自エンタメ情報をプラスしたニュース速報㌻です。<br>
みんなのモバイルで独自に収集したニュースのクチコミ情報をプラスしてニュース情報を検索できるニュース速報データベースです。<br>
ニュース速報情報の収集にご協力をお願いします。<br>
</font>
END_OF_HTML

}

&html_footer($self);

	return;
}

# /list-ent/entnews/newsid/
sub dispatch_entnews(){
	my $self = shift;
	my $newsid = $self->{cgi}->param('p1'); 
	my $nextid = $newsid - 1;

	my $hr = &html_hr($self,1);	

	my $newsdata;
	my ($titlestr, $keywords, $title, $date);
	my $sth = $self->{dbi}->prepare(qq{ select id, titlestr, news, keywords, insdate from topics where id = ? limit 1});
	$sth->execute($newsid);
	while(my @row = $sth->fetchrow_array) {
		$title = $row[1];
		$title =~s/://g;
		$keywords = $row[3];
		$date = $row[4];
		$titlestr = &_makelinks($row[1]);
		my $newsstr = &_makelinks($row[2]);
		$newsstr =~s/\n/\<br\>/g;
		$newsdata .=qq{<table border=0 bgcolor="#DFFFBF" width="100%"><tr><td>};
		$newsdata .=qq{<font color="blue">};
		$newsdata .=qq{$titlestr<br>};
		$newsdata .=qq{</font>};
		$newsdata .=qq{</td></tr></table>};
		$newsdata .=qq{$newsstr<br>};
		$newsdata .=qq{$hr};
	}

   $self->{html_title} = qq{$title -丸籍速報プラス-};
   $self->{html_keywords} = qq{$keywords};
   $self->{html_description} = qq{$title $dateのエンタメ速報プラス。};

	&html_header($self);

	my $ad = &html_google_ad($self);

if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML
	
}else{
print << "END_OF_HTML";
<font size=1>
<font color="#FF0000">$dateの最新ニュース</font><br>
</font>
$hr
<center>
$ad
</center>
$hr
$newsdata
<img src="http://img.waao.jp/m2028.gif" width=48 height=9><a href="/list-news/entnews/$nextid/">次のエンタメニュースを見る</a>
$hr
END_OF_HTML

&melmaga_link($self);

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/list-ent/list-ent/$date/">$dateのエンタメニュース</a>&gt;<strong>$title</strong><br>
<font size=1 color="#E9E9E9">$titleの㌻は、ゴシップネタなど、他では手に入らないエンタメ情報をクチコミを元に収集してお届けしています。<br>
エンタメ速報でお届けする情報については、クチコミ情報を元に提供しているため、内容については、一切の保証をしておりませんので、ご了承ください。<br>
不適切な内容がある場合は、ご連絡くださいますよう、ご協力をお願いします。<br>
</font>
END_OF_HTML

}

&html_footer($self);

	return;
}


sub dispatch_list_news(){
	my $self = shift;
	my $date = $self->{cgi}->param('p1'); 
	
   $self->{html_title} = qq{ニュース速報プラス -ニュース速報プラス-};
   $self->{html_keywords} = qq{ニュース,速報};
   $self->{html_description} = qq{ニュース速報プラス。ニュース情報 プラス 独自で集めたゴシップ情報満載のニュース検索サイト};

	my $hr = &html_hr($self,1);	
	&html_header($self);

	my $ad = &html_google_ad($self);

	unless($date){
		my $sth = $self->{dbi}->prepare(qq{ select max(datestr) as max from news limit 1});
		$sth->execute();
		while(my @row = $sth->fetchrow_array) {
			$date = $row[0];
		}
	}
	my $nextid;
	my $newslist;
	my $sth = $self->{dbi}->prepare(qq{ select id, title, keylist from news where datestr = ? order by id });
	$sth->execute($date);
	while(my @row = $sth->fetchrow_array) {
		$nextid = ($row[0] - 1) unless($nextid);
		my $titlestr = $row[1];
		$newslist .=qq{<a href="/list-ent/news/$row[0]/">$titlestr </a><br>};
		$newslist .=qq{$hr};
	}



if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML
	
}else{
	
&html_table($self, qq{<font color="#FF0000">$dateの最新ニュース</font>}, 0, 1);

print << "END_OF_HTML";
<center>
$ad
</center>
$newslist
<img src="http://img.waao.jp/m2028.gif" width=48 height=9><a href="/list-news/news/$nextid/">次へ</a>
$hr
<a href="/" accesskey=0>トップ</a>&gt;<strong>ニュース速報プラス</strong><br>
<font size=1 color="#E9E9E9">この㌻は、最新ののニュース速報と独自エンタメ情報をプラスしたニュース速報㌻です。<br>
みんなのモバイルで独自に収集したニュースのクチコミ情報をプラスしてニュース情報を検索できるニュース速報データベースです。<br>
ニュース速報情報の収集にご協力をお願いします。<br>
ニュース速報㌻は、yahoo!トピックスAPIを利用しています。<br>
</font>
END_OF_HTML

}

&html_footer($self);


	return;
}

sub _newsdetail(){
	my $self = shift;
	my $newsid =shift;
	my $nextid = $newsid - 1;

	my $hr = &html_hr($self,1);	

	my $newsdata;
	my ($date, $title, $keylist, $url);
	my $sth = $self->{dbi}->prepare(qq{ select datestr, title, keylist, url from news where id = ? limit 1} );
	$sth->execute($newsid);
	while(my @row = $sth->fetchrow_array) {
		($date, $title, $keylist, $url) = @row;
	}
	
   $self->{html_title} = qq{$title -ニュース速報プラス-};
   $self->{html_description} = qq{$title $dateのニュース速報プラス。};

	&html_header($self);

	my $ad = &html_google_ad($self);
	my $pc_url = &html_pc_2_mb($url);

if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML
	
}else{
print << "END_OF_HTML";
<font size=1>
<font color="#FF0000">$dateの最新ニュース</font><br>
</font>
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

&html_table($self, qq{<font color="#FF0000">$title</font>}, 0, 0);

print << "END_OF_HTML";
$keylist
<br>
<img src="http://img.waao.jp/mb129.gif" width=11 height=11><a href="$pc_url">もっと詳しく見る</a><br>
<img src="http://img.waao.jp/m2028.gif" width=48 height=9><a href="/list-news/news/$nextid/">次のニュースを見る</a>
$hr
END_OF_HTML

&melmaga_link($self);

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/news/">ニュース速報プラス</a>&gt;<a href="/list-ent/list-news/$date/">$dateのニュース</a>&gt;<strong>$title</strong><br>
<font size=1 color="#E9E9E9">この㌻は、最新ののニュース速報と独自エンタメ情報をプラスしたニュース速報㌻です。<br>
みんなのモバイルで独自に収集したニュースのクチコミ情報をプラスしてニュース情報を検索できるニュース速報データベースです。<br>
ニュース速報情報の収集にご協力をお願いします。<br>
ニュース速報㌻は、yahoo!トピックスAPIを利用しています。<br>
</font>
END_OF_HTML

}

&html_footer($self);

	$sth = $self->{dbi}->prepare(qq{ update news set pv = pv + 1 where id = ? limit 1} );
	$sth->execute($self->{cgi}->param('id'));

	return;
}

sub _makelinks(){
	my $str = shift;
	
	my $makestr;
	my @vals = split(/:::/, $str);
	foreach my $val (@vals) {
		if($val=~/^:/){
			$val =~s/^://;
			my $str_encode = &str_encode($val);
			$makestr .= qq{<a href="/$str_encode/search/">$val</a>};
		}else{
			$makestr .= $val;
		}
	}
	
	return $makestr;
}

sub _yahoo_news_search(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('q');
	my $keyword_encode = &str_encode($keyword);
	my $keyword_utf8 = $keyword;
	Encode::from_to($keyword_utf8,'cp932','utf8');
	$keyword_utf8 = escape ( $keyword_utf8 );
	
	$self->{html_title} = qq{$keywordのニュース検索情報};
	$self->{html_keywords} = qq{$keyword,ニュース,速報,検索};
	$self->{html_description} = qq{$keywordの過去のニュースとニュース速報};
	
	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);

	&html_header($self);

	&html_table($self, qq{<h1>$keyword</h1><h2><font size=1 color="#FF0000">関連ニュース検索</font></h2>}, 1, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

	my $page = 1;
	$page = $self->{cgi}->param('p1') if($self->{cgi}->param('p1'));
	my $next_page = $page + 1;
	my $start = 1 + 5 * ($page - 1);
	my $api_url;
	$api_url = qq{http://news.yahooapis.jp/NewsWebService/V2/topics?appid=goooooto&query=$keyword_utf8&results=5&start=$start};

    my $response = get($api_url);
	my $xml = new XML::Simple;
	my $yahoo_xml = $xml->XMLin($response);
	foreach my $result (@{$yahoo_xml->{Result}}) {
		my ($url,$title,$word,$datetime);
eval{
		$url = $result->{Url};
		$datetime= $result->{DateTime};
		$title = Jcode->new($result->{TopicName}, 'utf8')->sjis;
		$word = Jcode->new($result->{Overview}, 'utf8')->sjis;
};
	my $pc_url = &html_pc_2_mb($url);
print << "END_OF_HTML";
<a href="$pc_url">$title</a><br>
<font size=1>$datetime</font><br>
$word<br>
$hr
END_OF_HTML

	}

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/news/">みんなのニュース検索プラス</a>&gt;<a href="/$keyword_encode/search/">$keyword検索プラス</a>&gt;<strong>$keywordの関連ニュース</strong><br>
<font size=1 color="#E9E9E9">みんなの関連ニュース検索プラスは,ヤフーニュース検索APIを利用して$keywordのニュース情報をマルチに検索できる無料ニュース検索サイトです。<br>
<a href="http://developer.yahoo.co.jp/about">Webサービス by Yahoo! JAPAN</a><br>
</font>
END_OF_HTML

	&html_footer($self);



	return;
}

1;