package Waao::Pages::Blog;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Html;
use Waao::Utility;
use Waao::Data;


# /keyword/blog/
# /keyword/blog/id/

sub dispatch(){
	my $self = shift;

	if($self->{cgi}->param('p1') eq 'list'){
	}elsif($self->{cgi}->param('q')){
		&_blog($self);
	}else{
		&_top($self);
	}
	return;
}

sub _blog(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('q');
	my $keyword_encode = &str_encode($keyword);
	my $keywordid = $self->{cgi}->param('p1');

	$self->{html_title} = qq{$keywordの公式オフィシャルブログ -タレント・有名人ブログ検索プラス-};
	$self->{html_keywords} = qq{$keyword,ブログ,ブログ検索,ランキング,有名人,タレント};
	$self->{html_description} = qq{$keywordの公式オフィシャルブログ他、タレント・有名人ブログ検索 最新のブログランキングが検索できる};

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);
	&html_header($self);

&html_table($self, qq{<h1>$keyword</h1><h2><font size=1 color="#00968c">$keyword</font><font size=1 color="#FF0000">公式オフィシャルブログ</font>}, 1, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

my ($datacnt, $keyworddata) = &get_keyword($self, $keyword, $keywordid);
my $blogurl = $keyworddata->{blogurl};

print << "END_OF_HTML";
<br>
<center>
<font color="#00968c">▽▽▽▽▽</font><br>
<blink></blink><a href="$blogurl">$keywordのブログ</a><br>
<font color="#00968c">△△△△△</font><br>
</center>
<br>
$hr
END_OF_HTML

my ($datacnt, $photodata) = &get_photo($self, $keyworddata->{id});

&html_keyword_info($self, $keyworddata, $photodata);

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0 title="みんなのモバイル">トップ</a>&gt;<a href="/blog/" title="ブログ検索">タレント・有名人ブログ検索プラス</a>&gt;<a href="/$keyword_encode/search/">$keyword検索プラス</a>&gt;<strong>$keywordのブログ</strong><br>
<font size=1 color="#E9E9E9">$keywordの公式(オフィシャル)ブログを探すならタレント・有名人ブログ検索プラス。
タレントや有名人のブログをブログランキング形式で検索できます！</font>
END_OF_HTML
	
	&html_footer($self);

	return;
}

sub _top(){
	my $self = shift;

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);

	$self->{html_title} = qq{タレント・有名人ブログ検索プラス};
	$self->{html_keywords} = qq{ブログ,ブログ検索,ランキング,有名人,タレント};
	$self->{html_description} = qq{タレント・有名人ブログ検索 最新のブログランキングが検索できる};

	&html_header($self);

if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML
	
}else{
# xhmlt chtml

&html_table($self, qq{<h1>タレントブログ</h1><h2><font size=1 color="#00968c">タレント・有名人</font><font size=1 color="#FF0000">ブログランキング</font>}, 1, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

&html_table($self, qq{<font color="#00968c">今話題のブログ</font>}, 0, 0);

print << "END_OF_HTML";
<font size=1>
END_OF_HTML

my $rand_id = int(rand(30));
my $start = 20 + $rand_id * 5;
my $sth = $self->{dbi}->prepare(qq{ select keyword, id from keyword where  blogurl is not null order by cnt desc limit $start, 10} );
$sth->execute();
while(my @row = $sth->fetchrow_array) {
	my $str_encode = &str_encode($row[0]);
print << "END_OF_HTML";
<a href="/$str_encode/blog/$row[1]/"><font color="#333333">$row[0]</font></a> 
END_OF_HTML

}

print << "END_OF_HTML";
</font>
END_OF_HTML

&html_table($self, qq{偂<font color="#00968c">人気ブログ</font><font color="red">TOP10</font>}, 0, 0);

print << "END_OF_HTML";
<font size=1>
END_OF_HTML

my $sth = $self->{dbi}->prepare(qq{ select keyword, id from keyword where blogurl is not null order by cnt desc limit 10} );
$sth->execute();
while(my @row = $sth->fetchrow_array) {
	my $str_encode = &str_encode($row[0]);
print << "END_OF_HTML";
<a href="/$str_encode/blog/$row[1]/"><font color="#333333">$row[0]</font></a> 
END_OF_HTML

}
print << "END_OF_HTML";
</font>
END_OF_HTML

&html_table($self, qq{<font color="#333333">灼ル別</font>}, 0, 0);


print << "END_OF_HTML";
<a href="/list-type/blog/1/" accesskey=1>アイドル/タレント</a><br>
哿<a href="/list-type/blog/2/" accesskey=2>塾澎ツ選手</a><br>
<a href="/list-type/blog/3/" accesskey=3>ミ長/政治家/その他</a><br>
<a href="/list-type/blog/4/" accesskey=4>AV女優</a><br>
$hr
偰<a href="http://blog.goo.to/" title="有名人ブログ検索">有名人ブログ検索</a><br>
<a href="/" accesskey=0>トップ</a>&gt;<strong>タレント・有名人ブログ検索プラス</strong><br>
<font size=1 color="#E9E9E9">タレント・有名人ブログ検索プラスは、タレントや有名人のブログが検索できます。
アクセス数に応じたブログランキング形式で表示されるので、話題のタレントや有名人がすぐにわかります。
</font>
END_OF_HTML
}
	
	&html_footer($self);
	
	return;
}

1;