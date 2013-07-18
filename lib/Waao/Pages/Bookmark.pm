package Waao::Pages::Bookmark;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Data;
use Waao::Html;
use Waao::Utility;

# /keyword/bookmark/
# /keyword/bookmark/keywordid/
sub dispatch(){
	my $self = shift;

	if($self->{cgi}->param('p1')){
		&_site_detail($self);
	}elsif($self->{cgi}->param('q')){
		&_site($self);
	}else{
		&_top($self);
	}
	return;
}

sub _top(){
	my $self = shift;

	$self->{html_title} = qq{携帯人気サイト検索 -みんなのブクマプラス-};
	$self->{html_keywords} = qq{携帯,人気,サイト,ブックマーク,ブクマ,検索};
	$self->{html_description} = qq{携帯人気サイト検索「みんなのブクマプラス」は、人力で人気のある携帯サイトを探すことができるソーシャルブックマークサービスです};

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
<center>
<h2>みんなのブクマ<font size=1 color="#FF0000">プラス</font></h2>
<h2><font size=1>人気の<font color="#FF0000">携帯サイト</font>プラス</font></h2>
</center>
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

my $memkey = "trendperson";
my $today_trend;
$today_trend = $self->{mem}->get( $memkey );

if($today_trend){
	my $cnt = 0;
	foreach my $keyword (@{$today_trend->{rank}}){
		$cnt++;
		my $str_encode = &str_encode($keyword);
		my ($datacnt, $keyworddata) = &get_keyword($self, $keyword);
		&html_sitelist($self, $keyword, $keyworddata->{id},3);
	}
}


print << "END_OF_HTML";
$hr
偂<a href="http://waao.jp/list-in/ranking/14/" title="みんなのランキング">みんなのランキング</a><br>
<a href="http://bookmark.goo.to/" title="みんなのお気に入りサイト">みんなのお気に入りサイト</a><br>
<a href="/" accesskey=0 title="みんなのモバイル">トップ</a>&gt;<strong>みんなのブクマ</strong><br>
みんなのブクマプラスは、<font color="#FF0000">リンクフリー</font>です。<br>
<textarea>
http://waao.jp/bookmark/
</textarea>
<br>
<font size=1 color="#AAAAAA">みんなのブクマは、キーワード毎のオススメ携帯サイトが検索できる無料サービスです</fonnt>
END_OF_HTML

}
	
	&html_footer($self);

	return;
}


sub _site(){
	my $self = shift;

	my $keyword = $self->{cgi}->param('q');
	my $keyword_encode = &str_encode($keyword);
	
	my ($datacnt, $keyworddata) = &get_keyword($self, $keyword);
	# データが検索できない場合
	unless($datacnt){
		$self->{no_keyword} = 1;
		return;
	}
	# photo データ
	my ($datacnt, $photodata) = &get_photo($self, $keyworddata->{id});

	$self->{html_title} = qq{$keywordのオススメ携帯サイト -$keywordブックマーク-};
	$self->{html_keywords} = qq{$keyword,サイト,ブックマーク,無料,人気};
	$self->{html_description} = qq{$keywordブックマークは、$keywordに関する携帯サイトのソーシャルブックマークサービスです};

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);

	&html_header($self);
	
	my $simplewiki = $keyworddata->{simplewiki};
	$simplewiki = &simple_wiki_upd($simplewiki, 128) if($simplewiki);

	my $prof_str;
	if($keyworddata->{person}){
		$prof_str = qq{プロフィール};
	}else{
		$prof_str = qq{データベース};
	}

if($self->{xhtml}){
	# xhtml用ドキュメント
	
}else{# xhmlt chtml

if($simplewiki){
print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FF9900">$simplewiki </font></marquee>
END_OF_HTML
}

&html_table($self, qq{<h1>$keyword</h1><h2><font size=1>$keyword</font><font size=1 color="#FF0000">オススメ携帯サイト</font></h2>}, 1, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

&html_table($self, qq{<img src="http://img.waao.jp/mb17.gif" width=15 height=15><font color="#00968c">$keyword</font><font color="#FF0000">人気サイト</font>}, 0, 0);
	my $str_encode = &str_encode($keyword);

	my $sth = $self->{dbi}->prepare(qq{ select id,title,url,comment from sitelist where keyword_id = ? order by cnt desc limit 100} );
	$sth->execute($keyworddata->{id});
	while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<a href="/$str_encode/bookmark/$row[0]/">$row[1]</a><br>
END_OF_HTML
	}

print << "END_OF_HTML";
$hr
END_OF_HTML
&html_keyword_info($self, $keyworddata, $photodata);

print << "END_OF_HTML";
$hr
END_OF_HTML


&html_keyword_plus2($self, $keyworddata);

my $keywordid = $keyworddata->{id};
&html_search_plus($self, $keyword);
my $link_path = &_make_file_path($keywordid);

print << "END_OF_HTML";
$hr
<a href="http://b.goo.to$link_path" title="$keyword">$keyword焚祝澎爪版</a><br>

<a href="/" accesskey=0>トップ</a>&gt;<a href="/bookmark/">みんなのブクマ</a>&gt;<strong>$keyword</strong><br>
<font size=1 color="#AAAAAA">$keywordのブックマークは、$keywordのモバイルサイトをみんなの人気投票によりランキング化した$keywordの人気サイト検索です。<br>
$keywordのクチコミ情報の収集にご協力をお願いします。<br>
</font>
END_OF_HTML

} # xhtml

	
	&html_footer($self);
	
	return;
}

sub _site_detail(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('q');
	my $keyword_encode = &str_encode($keyword);
	my $siteid = $self->{cgi}->param('p1');
	# サイト情報
	my ($keywordid, $title, $url, $comment);
	my $sth = $self->{dbi}->prepare(qq{ select keyword_id, title,url,comment from sitelist where id = ? limit 1} );
	$sth->execute($siteid);
	while(my @row = $sth->fetchrow_array) {
		($keywordid, $title, $url, $comment) = @row;
	}

	my ($datacnt, $keyworddata) = &get_keyword($self, $keyword, $keywordid);
	# photo データ
	my ($datacnt, $photodata) = &get_photo($self, $keywordid);

	$self->{html_title} = qq{$title -$keywordブックマーク-};
	$self->{html_keywords} = qq{$keyword,$title,サイト,ブックマーク,無料,人気};
	$self->{html_description} = qq{$title:$comment};

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);

	&html_header($self);
	
	my $simplewiki = $keyworddata->{simplewiki};
	$simplewiki = &simple_wiki_upd($simplewiki, 128) if($simplewiki);

	my $prof_str;
	if($keyworddata->{person}){
		$prof_str = qq{プロフィール};
	}else{
		$prof_str = qq{データベース};
	}

if($self->{xhtml}){
	# xhtml用ドキュメント
	
}else{# xhmlt chtml

if($simplewiki){
print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FF9900">$simplewiki </font></marquee>
END_OF_HTML
}

&html_table($self, qq{<h1>$title</h1><h2><font size=1>$keyword</font><font size=1 color="#FF0000">オススメ携帯サイト</font></h2>}, 1, 0);
my $url2 = &_url_decode($url);
print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
<br>
<center><a href="$url2"><font color="#FF0000">$title</font></a></center>
<br>
$comment
$hr
END_OF_HTML

&html_table($self, qq{<img src="http://img.waao.jp/mb17.gif" width=15 height=15><font color="#00968c">$keyword</font><font color="#FF0000">人気サイト</font>}, 0, 0);
	my $str_encode = &str_encode($keyword);

	my $sth = $self->{dbi}->prepare(qq{ select id,title,url,comment from sitelist where keyword_id = ? order by cnt desc limit 100} );
	$sth->execute($keywordid);
	while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<a href="/$str_encode/bookmark/$row[0]/">$row[1]</a><br>
END_OF_HTML
	}

print << "END_OF_HTML";
$hr
END_OF_HTML

&html_keyword_info($self, $keyworddata, $photodata);

print << "END_OF_HTML";
$hr
END_OF_HTML


&html_keyword_plus2($self, $keyworddata);

$keywordid = $keyworddata->{id};
&html_search_plus($self, $keyword);
my $link_path = &_make_file_path($keywordid);

print << "END_OF_HTML";
$hr
<a href="http://b.goo.to$link_path$siteid/" title="$keyword">$keyword焚祝澎爪版</a><br>

<a href="/" accesskey=0>トップ</a>&gt;<a href="/bookmark/">みんなのブクマ</a>&gt;<a href="/$keyword_encode/bookmark/">$keywordのブクマ</a>&gt;<strong>$title</strong><br>
<font size=1 color="#AAAAAA">$keywordのブックマーク、$title $comment<br>
$keywordのクチコミ情報の収集にご協力をお願いします。<br>
</font>
END_OF_HTML

} # xhtml

	
	&html_footer($self);
	return;
}

sub _make_file_path(){
	my $keyword_id = shift;

	my $dir = int($keyword_id / 1000);
	my $file = $keyword_id % 1000;
		
	my $filepath = qq{/$dir/$keyword_id/};
	
	return $filepath;
}

sub _url_decode() {
  my $str = shift;
	
$str =~ tr/+/ /;
$str =~ s/%25([a-fA-F0-9][a-fA-F0-9])/pack('H2', $1)/eg;


  return $str;
}
1;