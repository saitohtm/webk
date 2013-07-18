package Waao::Pages::SMFMovie;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Html5;
use Waao::Data;
use Waao::Utility;
use Jcode;

sub dispatch(){
	my $self = shift;

	if($self->{cgi}->param('id')){
		&_detail($self);
	}

	return;
}

sub _detail(){
	my $self = shift;
	my $id = $self->{cgi}->param('id');
	my $geinou = &html_mojibake_str("geinou");

	my ($datacnt, $keyworddata) = &get_keyword($self, "", $self->{cgi}->param('id'));
	my $keyword = $keyworddata->{keyword};

my $twitter;
if($keyworddata->{twitterurl}){
	$twitter = qq{<li><img src="/img/twitter.png" height="25" class="ui-li-icon"><a href="/twitid$keyworddata->{id}/">Twitter $keyword</a></li>};
}

	my $a = "$keywordの動画 動画 youtube MAX";
	$self->{html_title} = qq{$a};
	my $b = "$keyword,動画,youtube,ムービー,ビデオ,pv";
	$self->{html_keywords} = qq{$b};
	my $c = "$keywordの動画。$keywordのyoutube動画,pvビデオを見つけるならスマフォ動画MAX";
	$self->{html_description} = qq{$c};
	&html_header($self);
	
    my $keyword_utf8 = Jcode->new($keyword, 'sjis')->utf8;
	my $keyword_encode = &str_encode($keyword_utf8);
	my $youtube = qq{http://m.youtube.com/index?gl=JP#/results?q=$keyword_encode};
#	my $youtube = qq{http://m.youtube.com/index?gl=JP#/results?q=$keyword};
	
	if($keyword=~/(.*)\((.*)\)/){
		$keyword = $1;
#		($datacnt, $keyworddata) = &get_keyword($self, $keyword, "");
	}
	# 画像
my $images;
#my $sth = $self->{dbi}->prepare(qq{ select id, good, url, fullurl from photo where keywordid = ? order by good desc, yahoo limit 4} );
#$sth->execute($keyworddata->{id});
#while(my @row = $sth->fetchrow_array) {
#	$images.=qq{<a href="/photoid$row[0]/"<img src="$row[2]" alt="$keyword画像" width="75"></a>};
#}
	
print << "END_OF_HTML";
<div data-role="header"> 
<h1>$keywordの動画</h1>
</div>
<a href="/">スマフォMAX</a>&gt;<a href="//person$keyworddata->{id}/">$keyword</a>&gt;$keywordの動画

<div data-role="content">
<ul data-role="listview">
<li><img src="/img/E106_20_ani.gif" height="20" class="ui-li-icon"><a href="/person$keyworddata->{id}/">$keywordプロフィール</a></li>
<li><img src="/img/E252_20.gif" height="20" class="ui-li-icon"><a href="$youtube" target="_blank">動画が正常に見れない方はこちら</a></li>
<iframe src="$youtube" height=300 width=300></iframe>
<li><img src="/img/E252_20.gif" height="20" class="ui-li-icon"><a href="$youtube" target="_blank">動画が正常に見れない方はこちら</a></li>
<li><img src="/img/E011_20.gif" height="20" class="ui-li-icon"><a href="/person$keyworddata->{id}/">$keywordプロフィール</a></li>
$twitter
</ul>
</div>

END_OF_HTML
	
&html_footer($self);
	
&cnt_keyword($self, $self->{cgi}->param('id'));

	return;
}

1;