package Waao::Pages::Top;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Html;
use Waao::Utility;

sub dispatch(){
	my $self = shift;
	
#   $self->{html_title} = qq{みんなのモバイル};
   $self->{html_keywords} = qq{携帯,検索エンジン,トレンド,検索,みんなのモバイル};
   $self->{html_description} = qq{携帯検索エンジン。みんなのクチコミ情報を元に、最新トレンド情報を検索できます。};
#   $self->{html_footertitle} = qq{};
	my $hr = &html_hr($self,1);	
	&html_header($self);

	# 日付情報
	my $wayear = $self->{date_y} - 1988;
	my $datestr = $self->{date_yyyy_mm_dd}."(平成".$wayear."年)";
	my $rokuyou = $self->{mem}->get( 'rokuyou' );
	my $geinou = &html_mojibake_str("geinou");

if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
<center><img src="http://imag.waao.jp/titlelogo.gif" width=88 height=33><font color="#0040FF" size=1>β版</font></center>
<center>
<form action="/search/" method="POST" ><input type="text" name="q" value="" size="20"><input type="hidden" name="guid" value="ON">
<br />
<input type="submit" value="検索"><br />
</form>
</center>
<font size=1>画像・動画・ブログ・着うたマルチ検索</font>
$hr
END_OF_HTML

&html_table($self, qq{<font color="red">今日のトレンドキーワード</font>}, 0, 1);

print << "END_OF_HTML";
<font size=1>
END_OF_HTML

my $memkey = "trendperson";
my $today_trend;
$today_trend = $self->{mem}->get( $memkey );

if($today_trend){
	my $cnt = 0;
	foreach my $keyword (@{$today_trend->{rank}}){
		$cnt++;
		my $str_encode = &str_encode($keyword);
print << "END_OF_HTML";
<a href="/search/$str_encode/">$keyword</a> 
END_OF_HTML
		last if($cnt >=10 );
	}
}

print << "END_OF_HTML";
</font>
$hr
<a href=""></a><br>
<a href=""></a><br>
<a href=""></a><br>
<a href=""></a><br>
<a href=""></a><br>
<a href=""></a><br>
<a href=""></a><br>
<a href=""></a><br>
<a href=""></a><br>
<a href=""></a><br>
$hr
<a href="/release/">リリース情報</a><br>
<a href="/kiyaku/">免責事項・利用規約</a><br>
<a href="/privacy/">プライバシーポリシー</a><br>
$hr
<font size=1>
みんなのモバイルは、
</font>
END_OF_HTML
	
}elsif($self->{access_type} eq 4){

print << "END_OF_HTML";
<center><img src="http://img.waao.jp/titlelogo.gif" width=120 height=28 alt="みんなのモバイル"><font color="#0040FF" size=1>β版</font></center>


<center>
<form action="/search.html" method="POST" ><input type="text" name="q" value="" size="20" autocorrect=on><input type="hidden" name="guid" value="ON">
<br />
<input type="submit" value="マルチ検索"><br />
</form>
</center>
<center>
<font size=1>画像動画ブログ…<font color="#FF0000">マルチ検索</font></font>
</center>
$hr
<center>
<a href="http://smart.goo.to/earth.htm">都圏版<br>
運行状況＋空気汚染情報</a>
</center>
$hr
<font size=1>$datestr $rokuyou <a href="http://weather.j-walker.jp/loca.php?url=http://waao.jp">天気</a></font>
END_OF_HTML
&html_table($self, qq{<font color="#00968c">今日のトレンドキーワード</font>}, 0, 0);


my $memkey = "trendperson";
my $today_trend;
$today_trend = $self->{mem}->get( $memkey );

if($today_trend){
	my $cnt = 0;
	foreach my $keyword (@{$today_trend->{rank}}){
		$cnt++;
		my $str_encode = &str_encode($keyword);
print << "END_OF_HTML";
<a href="/$str_encode/search/">$keyword</a> 
END_OF_HTML
		last if($cnt >=10 );
	}
}

print << "END_OF_HTML";
<br><img src="http://img.waao.jp/right07.gif" widht=10 height=10><a href="/list-rank/popword/1/">話題の人</a><br>
$hr
□<a href="http://s.goodgirl.jp/index.htm">スマフォで見れるエロ動画</a><br>
□<a href="http://twitter.tsukaeru.info/">有名人ツイッター</a><br>
□<a href="http://blog.tsukaeru.info/">有名人ブログ</a><br>
□<a href="/meikan/">人物名鑑プラス</a><br>
□<a href="/kizasi/">流行りモノ検索</a><br>
□<a href="/keywordranking/">今日のキーワードランキング</a><br>
□<a href="/bookmark/">みんなのブクマ検索</a><br>
□<a href="/hellowwork/">ハローワーク</a><br>
□<a href="/nensyu/"><a href="/nensyu/">年収ランキング2011</a><br>
$hr
<a href="/news/" accesskey=1>ニュース検索</a><br>
<a href="/shopping/" accesskey=2>ショッピング検索</a><br>
<a href="/uta/" accesskey=3>着うた検索</a><br>
<a href="/imagesearch/" accesskey=4>画像検索</a><br>
<a href="/zip/" accesskey=5>郵便番号検索</a><br>
<a href="/hotpepper/" accesskey=6>グルメ検索</a><br>
<a href="/travel/" accesskey=7>格安旅行検索</a><br>
<a href="http://blog.tsukaeru.info/" accesskey=8>タレント・有名人ブログ検索</a><br>
<a href="/car/" accesskey=9>新車・中古車検索</a><br>
⇒<a href="/sp-submenu/">他の検索メニュー</a><br>
<a href="/sp-pickupsite/">携帯サイト</a><br>
END_OF_HTML

&html_table($self, qq{<font color="#009525">サイトオーナー向けメニュー</font>}, 0, 0);

print << "END_OF_HTML";
<a href="/accessup/">アクセスアップ</a><br>
<a href="http://waao.jp/list-in/ranking/1/">携帯ランキング</a><br>
<a href="/searchword/">検索キーワードランキング</a><br>
$hr
<center>
<a href="/whatminmoba/">みんなのモバイルとは</a>
</center>
$hr
<a href="/release/">リリース情報</a><br>
<a href="/kiyaku/">免責事項・利用規約</a><br>
<a href="/privacy/">プライバシーポリシー</a><br>
<a href="/sp-policy/">サイト健全化</a><br>
$hr
<font size=1>
みんなのモバイル<font color="#FF0000">プラス</font>は、なんでもマルチに検索することのできる携帯最強の携帯検索エンジンです。
</font>
END_OF_HTML

}else{
# xhmlt chtml

print << "END_OF_HTML";
<center><img src="http://img.waao.jp/titlelogo.gif" width=120 height=28 alt="みんなのモバイル"><font color="#0040FF" size=1>β版</font></center>
<center>
<form action="/search.html" method="POST" ><input type="text" name="q" value="" size="20"><input type="hidden" name="guid" value="ON">
<br />
<input type="submit" value="マルチ検索"><br />
</form>
</center>

<center>
<font size=1>画像動画ブログ…<font color="#FF0000">マルチ検索</font></font><br>
<font size=1 color="#00968c">一日一膳<a href="http://wapnavi.net/click/link/mutually.cgi?id=gooto">クリック募金</a></font>
</center>
$hr
<font size=1>$datestr $rokuyou <a href="http://weather.j-walker.jp/loca.php?url=http://waao.jp">天気</a></font><br>
$hr
<center>
<a href="/kizasi/">１分で分かる<br>
今日の$geinouニュース</a>
</center>
$hr
END_OF_HTML

&html_table($self, qq{<font color="#00968c">今日のトレンドキーワード</font>}, 0, 1);

print << "END_OF_HTML";
<font size=1>
END_OF_HTML


my $memkey = "trendperson";
my $today_trend;
$today_trend = $self->{mem}->get( $memkey );

if($today_trend){
	my $cnt = 0;
	foreach my $keyword (@{$today_trend->{rank}}){
		$cnt++;
		my $str_encode = &str_encode($keyword);
print << "END_OF_HTML";
<a href="/$str_encode/search/">$keyword</a> 
END_OF_HTML
		last if($cnt >=10 );
	}
}

print << "END_OF_HTML";
<img src="http://img.waao.jp/right07.gif" widht=10 height=10><a href="/popword/">今日の有名人</a>
</font>
$hr
<img src="http://img.waao.jp/mb17.gif" width=11 height=12><a href="/meikan/">人物名鑑プラス</a><br>
<img src="http://img.waao.jp/mb17.gif" width=11 height=12><a href="http://twitter.tsukaeru.info/">有名人ツイッター</a><br>
<img src="http://img.waao.jp/mb17.gif" width=11 height=12><a href="http://blog.tsukaeru.info/">有名人ブログ</a><br>
<img src="http://img.waao.jp/mb17.gif" width=11 height=12><a href="/kizasi/">流行りモノ検索</a><br>
<img src="http://img.waao.jp/mb17.gif" width=11 height=12><a href="/2010rank/">2010検索ランキング</a><br>
<img src="http://img.waao.jp/mb17.gif" width=11 height=12><a href="/bookmark/">みんなのブクマ検索</a><br>
<img src="http://img.waao.jp/mb17.gif" width=11 height=12><a href="/hellowwork/">ハローワーク</a><br>
<img src="http://img.waao.jp/mb17.gif" width=11 height=12><a href="/nensyu/">年収ランキング2011</a><br>
<a href="/news/" accesskey=1>ニュース検索</a><br>
<a href="/shopping/" accesskey=2>ショッピング検索</a><br>
<a href="/uta/" accesskey=3>着うた検索</a><br>
<a href="/imagesearch/" accesskey=4>画像検索</a><br>
<a href="/zip/" accesskey=5>郵便番号検索</a><br>
<a href="/hotpepper/" accesskey=6>グルメ検索</a><br>
<a href="/travel/" accesskey=7>格安旅行検索</a><br>
<a href="/blog/" accesskey=8>タレント・有名人ブログ検索</a><br>
<a href="/car/" accesskey=9>新車・中古車検索</a><br>
⇒<a href="/sp-submenu/">他の検索メニュー</a><br>
<a href="/sp-pickupsite/">携帯サイト</a><br>
<img src="http://img.waao.jp/mb17.gif" width=11 height=12><a href="/keywordranking/">今日のキーワードランキング</a><br>
END_OF_HTML

&html_table($self, qq{<font size=1 color="#009525">サイトオーナー向けメニュー</font>}, 0, 0);

print << "END_OF_HTML";
<a href="/accessup/">アクセスアップ</a><br>
<a href="http://waao.jp/list-in/ranking/1/">携帯ランキング</a><br>
<a href="/searchword/">検索キーワードランキング</a><br>
$hr
<center>
<a href="/whatminmoba/">みんなのモバイルとは</a>
</center>
$hr
<a href="/release/">リリース情報</a><br>
<a href="/kiyaku/">免責事項・利用規約</a><br>
<a href="/privacy/">プライバシーポリシー</a><br>
<a href="/sp-policy/">サイト健全化</a><br>
<a href="/sp-infomation/">運営元</a><br>
<a href="http://goo.to/">みんなのモバイルクラシック</a><br>
$hr
<font size=1>
みんなのモバイル<font color="#FF0000">プラス</font>は、なんでもマルチに検索することのできる携帯最強の携帯検索エンジンです。
</font>
END_OF_HTML
}
	
	&html_footer($self);
	
	return;
}

1;