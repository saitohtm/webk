package Waao::Pages::SMFSearch;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Html5;
use Waao::Data;
use Waao::Utility;
use Jcode;

sub dispatch(){
	my $self = shift;

	my $keyword = $self->{cgi}->param('q');
	my $keyword_tmp = $keyword;
	$keyword = Jcode->new($keyword, 'utf8')->sjis;
	unless($keyword){
		print qq{Location:http://s.waao.jp/search.htm \n\n};
		return;
	}

	my $a = "$keyword検索 $keywordの動画・画像・ブログマルチ検索";
	$self->{html_title} = qq{$a};
	my $b = "$keyword,画像,動画,プロフィール";
	$self->{html_keywords} = qq{$b};
	my $c = "$keyword:$keywordの検索結果をスマートフォンで最強検索";
	$self->{html_description} = qq{$c};
	&html_header($self);

	my ($datacnt, $keyworddata) = &get_keyword($self, $keyword);
	my ($datacnt, $photodata) = &get_photo($self, $keyworddata->{id});
	my $keyword_encode = &str_encode($keyword);
	my $keyword_tmp_encode = &str_encode($keyword_tmp);

	
print << "END_OF_HTML";
<div data-role="header"> 
<h1>$keyword</h1>
</div>
<a href="/">トップ</a>&gt;<a href="/search/">検索</a>&gt;$keyword

<div data-role="content">
<ul data-role="listview">
END_OF_HTML

if($keyworddata->{id}){
print << "END_OF_HTML";
<center><img src="$photodata->{url}"></center>
<li><img src="/img/E106_20_ani.gif" height="20" class="ui-li-icon"><a href="/photolist$keyworddata->{id}/">$keywordのすべて</a></li>
END_OF_HTML
}

print << "END_OF_HTML";
<a href="#naver"><img src="/img/naver.png" height="25"></a> 
<a href="#google"><img src="/img/google.png" height="25"></a> 
<a href="#yahoo"><img src="/img/yahoo.png" height="25"></a> 
<a name="naver"></a>
<iframe src="http://search.naver.jp/m/?q=$keyword_encode" height=300 width=300></iframe>
<a name="google"></a>
<iframe src="http://www.google.com/m/search?q=$keyword_tmp_encode&pbx=1&gl=jp&hl=ja" height=300 width=300></iframe>
<a name="yahoo"></a>
<iframe src="http://search.yahoo.co.jp/search?ei=UTF-8&p=$keyword_tmp_encode" height=300 width=300></iframe>

</ul>

<h3>$keywordをもっと探す</h3>
みんなのスマフォナビ：$keywordの検索結果<br>
$keywordの検索を他の検索エンジンから検索できます<br>

</div>

END_OF_HTML
	
&html_footer($self);

	return;
}

1;