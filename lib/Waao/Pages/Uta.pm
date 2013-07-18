package Waao::Pages::Uta;
use strict;
use base qw(Waao::Pages::Base);
use Waao::Data;
use Waao::Html;
use Waao::Utility;
use LWP::UserAgent;
use Jcode;
use CGI qw( escape );

# /list-song50/
# /list-artist50/
# /artist/uta/song/
sub dispatch(){
	my $self = shift;
	
	if($self->{cgi}->param('q') eq 'list-ranking'){
		&_ranking($self);
	}elsif($self->{cgi}->param('q') eq 'list-artist50'){
		&_list_artist50($self);
	}elsif($self->{cgi}->param('q') eq 'list-song50'){
		&_list_song50($self);
	}elsif($self->{cgi}->param('p1') eq 'asearch'){
		&_artist($self);
	}elsif($self->{cgi}->param('p1') eq 'page'){
		&_search($self);
	}elsif($self->{cgi}->param('p1')){
		&_song($self);
	}elsif($self->{cgi}->param('q')){
		&_search($self);
	}else{
		&_top($self);
	}
	return;
}

sub _top(){
	my $self = shift;
	
   $self->{html_title} = qq{無料着うたフル検索 -みんなの着うたプラス-};
   $self->{html_keywords} = qq{無料,着うた,着うたフル,掲示板,ランキング};
   $self->{html_description} = qq{無料着うたフル検索エンジン。全ての着うたサイトからマルチ検索できます。最新着うたフルランキングもあるよ};
	my $hr = &html_hr($self,1);	
	&html_header($self);

if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML
	
}else{
# xhmlt chtml

print << "END_OF_HTML";
<center>
<img src="http://img.waao.jp/utalogo.gif" width=120 height=28 alt="無料着うたフル検索"><font size=1 color="#FF0000">プラス</font>
</center>
<center>
<form action="/uta.html" method="POST" ><input type="text" name="q" value="" size="20"><input type="hidden" name="guid" value="ON">
<br />
<input type="submit" value="着うた検索プラス"><br />
</form>
</center>
<center>
<font size=1>着うたフル<font color="#FF0000">マルチ検索</font></font>
</center>
$hr

<a href="/list-ranking/uta/" accesskey=1>着うたランキング</a><br>
<a href="#s50" accesskey=2>曲名検索</a><br>
<a href="#a50" accesskey=3>アーティスト検索</a><br>
<a href="http://r.smaf.jp/_rotate_ad?m=408004&c=51&fg=&bg=ffffff&hr=008000" accesskey=4>スペシャルサイト</a><br>
<!--<a href="" accesskey=5></a><br>
<a href="" accesskey=6></a><br>
<a href="" accesskey=7></a><br>
<a href="" accesskey=8></a><br>
<a href="" accesskey=9></a><br>
-->
$hr
偂<a href="http://waao.jp/list-in/ranking/6/">みんなのランキング</a><br>
<a href="/" accesskey=0>トップ</a>&gt;<strong>無料着うたフル検索プラス</strong><br>
<font size=1 color="#AAAAAA">無料着うたフル検索プラスは,複数の着うたサイトから、着うた・着メロ・着歌フルなどマルチに検索できる無料着うた検索サイトです。<br>
</font>
END_OF_HTML
}

print << "END_OF_HTML";
<br>
<br>
<br>
<br>
<br>
END_OF_HTML

&html_table($self, qq{<h2><font size=1 color="#FF0000">曲名50音検索</font></h2>}, 1, 0);

print << "END_OF_HTML";
<a name="s50"></a>
・<font color="#003AEA">50検索</font><br>
<font size=1>
<a href="#sa">あ行</a><br> 
<a href="#ska">か行</a><br> 
<a href="#ssa">さ行</a><br> 
<a href="#sta">た行</a><br> 
<a href="#sna">な行</a><br>
<a href="#sha">は行</a><br> 
<a href="#sma">ま行</a><br> 
<a href="#sya">や行</a><br> 
<a href="#sra">ら行</a><br> 
<a href="#swa">わ行</a><br>

$hr
<a name="sa"></a>
<a href="/list-song50/uta/%B1/">あ</a>|
<a href="/list-song50/uta/%B2/">い</a>|
<a href="/list-song50/uta/%B3/">う</a>|
<a href="/list-song50/uta/%B4/">え</a>|
<a href="/list-song50/uta/%B5/">お</a>
<br>
<a name="ska"></a>
<a href="/list-song50/uta/%B6/">か</a>|
<a href="/list-song50/uta/%B7/">き</a>|
<a href="/list-song50/uta/%B8/">く</a>|
<a href="/list-song50/uta/%B9/">け</a>|
<a href="/list-song50/uta/%BA/">こ</a>
<br>
<a name="ssa"></a>
<a href="/list-song50/uta/%BB/">さ</a>|
<a href="/list-song50/uta/%BC/">し</a>|
<a href="/list-song50/uta/%BD/">す</a>|
<a href="/list-song50/uta/%BE/">せ</a>|
<a href="/list-song50/uta/%BF/">そ</a>

<br>
<a name="sta"></a>
<a href="/list-song50/uta/%C0/">た</a>|
<a href="/list-song50/uta/%C1/">ち</a>|
<a href="/list-song50/uta/%C2/">つ</a>|
<a href="/list-song50/uta/%C3/">て</a>|
<a href="/list-song50/uta/%C4/">と</a>
<br>
<a name="sna"></a>
<a href="/list-song50/uta/%C5/">な</a>|
<a href="/list-song50/uta/%C6/">に</a>|
<a href="/list-song50/uta/%C7/">ぬ</a>|
<a href="/list-song50/uta/%C8/">ね</a>|
<a href="/list-song50/uta/%C9/">の</a>
<br>
<a name="sha"></a>
<a href="/list-song50/uta/%CA/">は</a>|
<a href="/list-song50/uta/%CB/">ひ</a>|
<a href="/list-song50/uta/%CC/">ふ</a>|
<a href="/list-song50/uta/%CD/">へ</a>|
<a href="/list-song50/uta/%CE/">ほ</a>

<br>
<a name="sma"></a>
<a href="/list-song50/uta/%CF/">ま</a>|
<a href="/list-song50/uta/%D0/">み</a>|
<a href="/list-song50/uta/%D1/">む</a>|
<a href="/list-song50/uta/%D2/">め</a>|
<a href="/list-song50/uta/%D3/">も</a>
<br>
<a name="sya"></a>
<a href="/list-song50/uta/%D4/">や</a>|
　|
<a href="/list-song50/uta/%D5/">ゆ</a>|
　|
<a href="/list-song50/uta/%D6/">よ</a>
<br>
<a name="sra"></a>
<a href="/list-song50/uta/%D7/">ら</a>|
<a href="/list-song50/uta/%D8/">り</a>|
<a href="/list-song50/uta/%D9/">る</a>|
<a href="/list-song50/uta/%DA/">れ</a>|
<a href="/list-song50/uta/%DB/">ろ</a>

<br>
<a name="swa"></a>
<a href="/list-song50/uta/%DC/">わ</a>|
　|
　|
　|
</font>
END_OF_HTML

print << "END_OF_HTML";
<br>
<br>
<br>
<br>
<br>
END_OF_HTML

&html_table($self, qq{<h2><font size=1 color="#FF0000">アーティスト50音検索</font></h2>}, 1, 0);

print << "END_OF_HTML";
<a name="a50"></a>
・<font color="#003AEA">50音検索</font><br>
<font size=1>
<a href="#aa">あ行</a><br> 
<a href="#aka">か行</a><br> 
<a href="#asa">さ行</a><br> 
<a href="#ata">た行</a><br> 
<a href="#ana">な行</a><br>
<a href="#aha">は行</a><br> 
<a href="#ama">ま行</a><br> 
<a href="#aya">や行</a><br> 
<a href="#ara">ら行</a><br> 
<a href="#awa">わ行</a><br>

$hr
<a name="aa"></a>
<a href="/list-artist50/uta/%B1/">あ</a>|
<a href="/list-artist50/uta/%B2/">い</a>|
<a href="/list-artist50/uta/%B3/">う</a>|
<a href="/list-artist50/uta/%B4/">え</a>|
<a href="/list-artist50/uta/%B5/">お</a>
<br>
<a name="aka"></a>
<a href="/list-artist50/uta/%B6/">か</a>|
<a href="/list-artist50/uta/%B7/">き</a>|
<a href="/list-artist50/uta/%B8/">く</a>|
<a href="/list-artist50/uta/%B9/">け</a>|
<a href="/list-artist50/uta/%BA/">こ</a>
<br>
<a name="asa"></a>
<a href="/list-artist50/uta/%BB/">さ</a>|
<a href="/list-artist50/uta/%BC/">し</a>|
<a href="/list-artist50/uta/%BD/">す</a>|
<a href="/list-artist50/uta/%BE/">せ</a>|
<a href="/list-artist50/uta/%BF/">そ</a>

<br>
<a name="ata"></a>
<a href="/list-artist50/uta/%C0/">た</a>|
<a href="/list-artist50/uta/%C1/">ち</a>|
<a href="/list-artist50/uta/%C2/">つ</a>|
<a href="/list-artist50/uta/%C3/">て</a>|
<a href="/list-artist50/uta/%C4/">と</a>
<br>
<a name="ana"></a>
<a href="/list-artist50/uta/%C5/">な</a>|
<a href="/list-artist50/uta/%C6/">に</a>|
<a href="/list-artist50/uta/%C7/">ぬ</a>|
<a href="/list-artist50/uta/%C8/">ね</a>|
<a href="/list-artist50/uta/%C9/">の</a>
<br>
<a name="aha"></a>
<a href="/list-artist50/uta/%CA/">は</a>|
<a href="/list-artist50/uta/%CB/">ひ</a>|
<a href="/list-artist50/uta/%CC/">ふ</a>|
<a href="/list-artist50/uta/%CD/">へ</a>|
<a href="/list-artist50/uta/%CE/">ほ</a>

<br>
<a name="ama"></a>
<a href="/list-artist50/uta/%CF/">ま</a>|
<a href="/list-artist50/uta/%D0/">み</a>|
<a href="/list-artist50/uta/%D1/">む</a>|
<a href="/list-artist50/uta/%D2/">め</a>|
<a href="/list-artist50/uta/%D3/">も</a>
<br>
<a name="aya"></a>
<a href="/list-artist50/uta/%D4/">や</a>|
　|
<a href="/list-artist50/uta/%D5/">ゆ</a>|
　|
<a href="/list-artist50/uta/%D6/">よ</a>
<br>
<a name="ara"></a>
<a href="/list-artist50/uta/%D7/">ら</a>|
<a href="/list-artist50/uta/%D8/">り</a>|
<a href="/list-artist50/uta/%D9/">る</a>|
<a href="/list-artist50/uta/%DA/">れ</a>|
<a href="/list-artist50/uta/%DB/">ろ</a>

<br>
<a name="awa"></a>
<a href="/list-artist50/uta/%DC/">わ</a>|

　|
　|
　|
　
</font>
END_OF_HTML

	
	&html_footer($self);
	
	return;
}

sub _api_get(){
	my $self = shift;
	my $cginame = shift;
	my $api_params = shift;

	my $url = qq{http://api.music.froute.jp/guest/servlet/};
	$url .= $cginame;
	$url .= "&mid=m-mob";
	$url .= "&ua=" . escape($ENV{"HTTP_USER_AGENT"});
	$url .= "&oe=Shift_JIS";
	if($api_params->{view} eq 5){
		$url .= "&fetchsize=5";
	}else{
		$url .= "&fetchsize=20";
	}

	while ( my ( $key, $value ) = each ( %{$api_params} ) ) {
		next unless($value);
        $url = sprintf("%s&%s=%s",$url, $key, $api_params->{$key});
	}
&debug_dumper($url);	
	my $ua = LWP::UserAgent->new;
	$ua->timeout(2);
	my $result = $ua->get($url);
	my $xmlstr;
	if ($result->is_success) {
	  $xmlstr = $result->content;
	}

	return $xmlstr;
}

sub _list_song50(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('p1');
	$keyword =~s/-//g;
	my $keyword_encode = &str_encode($keyword);

	$self->{html_title} = qq{無料着うたフル検索プラス -$keyword:曲名検索-};
	$self->{html_keywords} = qq{無料,着うた,フル,検索};
	$self->{html_description} = qq{無料着うたフル検索 :$keyword の曲名検索};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);

	&html_table($self, qq{<h2><font size=1 color="#FF0000">$keyword の曲名検索</font></h2>}, 1, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

	my $api_params;
	$api_params->{k} = $keyword;
	$api_params->{page} = $self->{cgi}->param('p2');
	my $xmlstr = &_api_get($self,"MusicSearch?kind=music_initial", $api_params);
if($xmlstr){
	my ($music,$music_name,$artist,$artist_name);
	my ($pagestr,$nextpage);
	my @lines = split(/\n/,$xmlstr);
	foreach my $line (@lines){
		if($line =~/(.*)totalhit\>(.*)\<(.*)/){
			($pagestr,$nextpage) = &_pager_str($self, $2);
print << "END_OF_HTML";
$pagestr
END_OF_HTML
		}elsif($line =~/(.*)music_name\>(.*)\<(.*)/){
			$music = $2;
		}elsif($line =~/(.*)music_name_label\>(.*)\<(.*)/){
			$music_name = $2;
		}elsif($line =~/(.*)musician_name\>(.*)\<(.*)/){
			$artist = $2;
		}elsif($line =~/(.*)musician_name_label\>(.*)\<(.*)/){
			$artist_name = $2;
		}
		
		if($artist_name){
			my $music_encode;
			my $artist_encode;
			$music_encode = &str_encode($music);
			$artist_encode = &str_encode($artist);
print << "END_OF_HTML";
$hr
<a href="/$artist_encode/uta/$music_encode/">$music_name</a><br>
<div align=right><a href="/$artist_encode/uta/asearch/">$artist_name</a></div>
END_OF_HTML
			($music,$music_name,$artist,$artist_name)=undef;

		}
	}
	if($nextpage){
print << "END_OF_HTML";
$hr
<a href="/list-song50/uta/$keyword_encode/$nextpage/" accesskey="#">次へ(#)</a><br>	
END_OF_HTML
	}else{
print << "END_OF_HTML";
$hr
END_OF_HTML
	}
}else{
print << "END_OF_HTML";
<font color="red">該当曲が多すぎます。更に絞り込んで検索してください。</font>
$hr
END_OF_HTML
}

print << "END_OF_HTML";
<a href="/"><strong>無料着うた</strong>検索</a>
$hr
<font size=1>更に絞り込む</font><br>
<font size=1>
<a href="#sa">あ行</a><br> 
<a href="#ska">か行</a><br> 
<a href="#ssa">さ行</a><br> 
<a href="#sta">た行</a><br> 
<a href="#sna">な行</a><br>
<a href="#sha">は行</a><br> 
<a href="#sma">ま行</a><br> 
<a href="#sya">や行</a><br> 
<a href="#sra">ら行</a><br> 
<a href="#swa">わ行</a><br>

<hr size=1 color=#FF0000>
<a name="sa"></a>
<a href="/list-song50/uta/$keyword-%B1/">あ</a>|
<a href="/list-song50/uta/$keyword-%B2/">い</a>|
<a href="/list-song50/uta/$keyword-%B3/">う</a>|
<a href="/list-song50/uta/$keyword-%B4/">え</a>|
<a href="/list-song50/uta/$keyword-%B5/">お</a>
<br>
<a name="ska"></a>
<a href="/list-song50/uta/$keyword-%B6/">か</a>|
<a href="/list-song50/uta/$keyword-%B7/">き</a>|
<a href="/list-song50/uta/$keyword-%B8/">く</a>|
<a href="/list-song50/uta/$keyword-%B9/">け</a>|
<a href="/list-song50/uta/$keyword-%BA/">こ</a>
<br>
<a name="ssa"></a>
<a href="/list-song50/uta/$keyword-%BB/">さ</a>|
<a href="/list-song50/uta/$keyword-%BC/">し</a>|
<a href="/list-song50/uta/$keyword-%BD/">す</a>|
<a href="/list-song50/uta/$keyword-%BE/">せ</a>|
<a href="/list-song50/uta/$keyword-%BF/">そ</a>

<br>
<a name="sta"></a>
<a href="/list-song50/uta/$keyword-%C0/">た</a>|
<a href="/list-song50/uta/$keyword-%C1/">ち</a>|
<a href="/list-song50/uta/$keyword-%C2/">つ</a>|
<a href="/list-song50/uta/$keyword-%C3/">て</a>|
<a href="/list-song50/uta/$keyword-%C4/">と</a>
<br>
<a name="sna"></a>
<a href="/list-song50/uta/$keyword-%C5/">な</a>|
<a href="/list-song50/uta/$keyword-%C6/">に</a>|
<a href="/list-song50/uta/$keyword-%C7/">ぬ</a>|
<a href="/list-song50/uta/$keyword-%C8/">ね</a>|
<a href="/list-song50/uta/$keyword-%C9/">の</a>
<br>
<a name="sha"></a>
<a href="/list-song50/uta/$keyword-%CA/">は</a>|
<a href="/list-song50/uta/$keyword-%CB/">ひ</a>|
<a href="/list-song50/uta/$keyword-%CC/">ふ</a>|
<a href="/list-song50/uta/$keyword-%CD/">へ</a>|
<a href="/list-song50/uta/$keyword-%CE/">ほ</a>

<br>
<a name="sma"></a>
<a href="/list-song50/uta/$keyword-%CF/">ま</a>|
<a href="/list-song50/uta/$keyword-%D0/">み</a>|
<a href="/list-song50/uta/$keyword-%D1/">む</a>|
<a href="/list-song50/uta/$keyword-%D2/">め</a>|
<a href="/list-song50/uta/$keyword-%D3/">も</a>
<br>
<a name="sya"></a>
<a href="/list-song50/uta/$keyword-%D4/">や</a>|
　|
<a href="/list-song50/uta/$keyword-%D5/">ゆ</a>|
　|
<a href="/list-song50/uta/$keyword-%D6/">よ</a>
<br>
<a name="sra"></a>
<a href="/list-song50/uta/$keyword-%D7/">ら</a>|
<a href="/list-song50/uta/$keyword-%D8/">り</a>|
<a href="/list-song50/uta/$keyword-%D9/">る</a>|
<a href="/list-song50/uta/$keyword-%DA/">れ</a>|
<a href="/list-song50/uta/$keyword-%DB/">ろ</a>

<br>
<a name="swa"></a>
<a href="/list-song50/uta/$keyword-%DC/">わ</a>|
　|
　|
　|

</font>
$hr
<a href="/" accesskey=0>トップ</a>&gt;<strong>無料着うたフル検索プラス</strong><br>
<font size=1 color="#AAAAAA">無料着うたフル検索プラスは,複数の着うたサイトから、着うた・着メロ・着歌フルなどマルチに検索できる無料着うた検索サイトです。<br>
</font>
END_OF_HTML

	&html_footer($self);
	
	return;
}

sub _pager_str(){
	my $self = shift;
	my $total = shift;
	my ($pagestr,$nextpage);
	
	my $totalpage = &_ceil(( $total/20 ));
	my $page = $self->{cgi}->param('p2') || 1;

	if($totalpage ne $page){
		$nextpage = $page+1;
	}
	if($2 eq 0){

		$pagestr = qq{<font size=1 color="red">ただ今サイトが非常に込み合っています。</font><br>};
		$pagestr .= qq{<font size=1>しばらくしてから、再度アクセスしてください</font><br>};
		$pagestr .= qq{おいそぎの方は、<a href="http://r.smaf.jp/_rotate_ad?m=408004&c=51&fg=&bg=ffffff&hr=008000">コチラ</a><br>};
		$nextpage=undef;
	}else{
		$pagestr = qq{<center><font color="red">$2</font>件HIT!</center><div align="right">【$page/$totalpage】</div>};
	}
	return ($pagestr,$nextpage);
}
sub _ceil {
   my $var = shift;
   my $a = 0;
   $a = 1 if($var > 0 and $var != int($var));
   return int($var + $a);
}

sub _song(){
	my $self = shift;
	my $artist_str = $self->{cgi}->param('q');
	my $song_str = $self->{cgi}->param('p1');
	my $artist_encode = &str_encode($artist_str);
	my $song_encode = &str_encode($song_str);

	$self->{html_title} = qq{$artist_str $song_str -着うたフル検索-};
	$self->{html_keywords} = qq{$artist_str,$song_str,無料,着うた,フル,検索};
	$self->{html_description} = qq{無料着うたフル検索 :$artist_str $song_str};

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);

	my $uta_link;
	my $dsp_str;
	my $api_params;
	$api_params->{music} = $song_encode;
	$api_params->{musician} = $artist_encode;
	$api_params->{view} = 20;
	$api_params->{k} = $artist_encode;
	my $xmlstr = &_api_get($self,"SongSearch?kind=artist_keyword",$api_params);
if($xmlstr){
	my ($cp_id,$seq,$music_name,$artist_name,$type,$price,$site_name,$site_url,$sample_flag,$typestr);
	my ($pagestr,$nextpage);
	my @lines = split(/\n/,$xmlstr);
	my $recnt;

	foreach my $line (@lines){
		my $last;
		$recnt++;
		if($line =~/(.*)totalhit\>(.*)\<(.*)/){
			($pagestr,$nextpage) = &_pager_str($self, $2);
$dsp_str.=qq{$pagestr};
$dsp_str.=qq{<font size=1 color="#009570">};
$dsp_str.=qq{あなたにピッタリの「<font color="blue">$song_str</font>」の着うたが見つかりました};
$dsp_str.=qq{</font><br>};
		}elsif($line =~/(.*)cp_id\>(.*)\<(.*)/){
			$cp_id = $2;
		}elsif($line =~/(.*)seq\>(.*)\<(.*)/){
			$seq = $2;
		}elsif($line =~/(.*)music_name\>(.*)\<(.*)/){
			$music_name = $2;
		}elsif($line =~/(.*)musician_name\>(.*)\<(.*)/){
			$artist_name = $2;
		}elsif($line =~/(.*)type\>(.*)\<(.*)/){
			$type = $2;
			if($type eq 1){
				$typestr =qq{<font color="#6F9178">着メロ</font>};
			}elsif($type eq 2){
				$typestr =qq{<font color="#FF8080">着うた</font>};
			}elsif($type eq 3){
				$typestr =qq{偂<font color="#BF008F">着うたフル</font>};
			}
		}elsif($line =~/(.*)price\>(.*)\<(.*)/){
			$price = $2;
		}elsif($line =~/(.*)site_name\>(.*)\<(.*)/){
			$site_name = $2;
		}elsif($line =~/(.*)site_url\>(.*)\<(.*)/){
			$site_url = $2;
		}elsif($line =~/(.*)sample_flg\>(.*)\<(.*)/){
			$last = 1;
			if($2){
				$sample_flag = qq{<font color="red">無料サンプル</font><br>};
			}
		}
		if($last){

$dsp_str.=qq{$hr};
		unless($recnt % 2){
$dsp_str.=qq{<table border="0" width=100%><tr><td BGCOLOR="#E9E9E9"><font size=1>};
		}else{
$dsp_str.=qq{<font size=1>};
		}
		if($uta_link){
			$uta_link = qq{http://api.music.froute.jp/guest/servlet/MusicDownload?mid=m-mob&seq=$seq&type=$type} if( $self->{date_min} % 3 );
		}else{
			$uta_link = qq{http://api.music.froute.jp/guest/servlet/MusicDownload?mid=m-mob&seq=$seq&type=$type};
		}
			if($sample_flag){
$dsp_str.=qq{<a href="http://api.music.froute.jp/guest/servlet/MusicDownload?mid=m-mob&seq=$seq&type=$type">$song_str</a>の$typestr <br>};
$dsp_str.=qq{<font color="red">無料サンプル アリ</font><br>};
$dsp_str.=qq{<div align=right><font color="#747474" size=1><font color="#F4F4F4">$price円 </font>⇒<a href="$site_url">$site_name</a></font></div>};
			}else{
$dsp_str.=qq{<a href="http://api.music.froute.jp/guest/servlet/MusicDownload?mid=m-mob&seq=$seq&type=$type">$song_str</a>の$typestr<br>};
$dsp_str.=qq{<div align=right><font color="#747474" size=1><font color="#F4F4F4">$price円 </font>⇒<a href="$site_url">$site_name</a></font></div>};
			}
			($cp_id,$seq,$music_name,$artist_name,$type,$price,$site_name,$site_url,$sample_flag,$typestr)=undef;

		unless($recnt % 2){
$dsp_str.=qq{</font></td></tr></table>};
		}else{
$dsp_str.=qq{</font>};
		}
		}

	}

}
if($self->{real_mobile}){
	if($self->{date_hour} >=23){
		print qq{Location: }.$uta_link.qq{\n\n};
		return;
	}elsif($self->{date_hour} <=2){
		print qq{Location: }.$uta_link.qq{\n\n};
		return;
	}
}

&html_header($self);
&html_table($self, qq{<h2><font size=1 color="#FF0000">$artist_str $song_str</font></h2>}, 1, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
$dsp_str
<a href="/$artist_encode/uta/asearch/">$artist_strの曲一覧</a><br>
$hr
END_OF_HTML

&html_table($self, qq{<font size=1 color="#00968c">$artist_str</font><font size=1 color="#FF0000">検索プラス</font>}, 0, 0);
my ($datacnt, $keyworddata) = &get_keyword($self, $artist_str);
my ($photodatacnt, $photodata) = &get_photo($self, $keyworddata->{id});

&html_keyword_info($self, $keyworddata, $photodata);

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/uta/">無料着うたフル検索プラス</a>&gt;<a href="/$artist_encode/uta/asearch/">$artist_strの曲一覧</a>&gt;<strong>$artist_str($song_str)</strong><br>
<font size=1 color="#AAAAAA">無料着うたフル検索プラスは,複数の着うたサイトから、着うた・着メロ・着歌フルなどマルチに検索できる無料着うた検索サイトです。<br>
</font>
END_OF_HTML

	&html_footer($self);

	return;
}

sub _artist(){
	my $self = shift;
	my $artist_str = $self->{cgi}->param('q');
	my $artist_encode = &str_encode($artist_str);


	$self->{html_title} = qq{$artist_str の着うた -着うたフル検索-};
	$self->{html_keywords} = qq{$artist_str,無料,着うた,フル,検索};
	$self->{html_description} = qq{無料着うたフル検索 :$artist_strの着うたをマルチ検索};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);

	&html_table($self, qq{<h1><font color="#FF0000">$artist_str</font>の着うた</h1>}, 1, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML


	my $api_params;
	$api_params->{musician} = $artist_encode;
	$api_params->{view} = 20;
	$api_params->{k} = $artist_encode;
	$api_params->{searchtype} = qq{equal};
	$api_params->{page} = $self->{cgi}->param('p2');
	my $xmlstr = &_api_get($self,"ArtistSearch?kind=artist_keyword",$api_params);
	
	
if($xmlstr){
	my ($music,$music_name,$artist,$artist_name,$tieup,$counts);
	my $artist_encode;
	my ($pagestr,$nextpage);
	my @lines = split(/\n/,$xmlstr);
	my $recnt;
	foreach my $line (@lines){
		if($line =~/(.*)totalhit\>(.*)\<(.*)/){
			($pagestr,$nextpage) = &_pager_str($self, $2);
print << "END_OF_HTML";
$pagestr
END_OF_HTML
		}elsif($line =~/(.*)music_name\>(.*)\<(.*)/){
			$music = $2;
		}elsif($line =~/(.*)music_name_label\>(.*)\<(.*)/){
			$music_name = $2;
		}elsif($line =~/(.*)musician_name\>(.*)\<(.*)/){
			$artist = $2;
		}elsif($line =~/(.*)musician_name_label\>(.*)\<(.*)/){
			$artist_name = $2;
		}elsif($line =~/(.*)tieup\>(.*)\<(.*)/){
			if($2){
         		    $tieup = qq{<font color="blue" size="1">$2</font><br>};
			}
		}elsif($line =~/(.*)counts\>(.*)\<(.*)/){
			$counts = $2;
		}
		if($counts){
			# 表示部分
			my $music_encode = &str_encode($music);
			$artist_encode = &str_encode($artist);
			$recnt++;
print << "END_OF_HTML";
$hr
END_OF_HTML
		unless($recnt % 2){
print << "END_OF_HTML";
<table border="0" width=100%><tr><td BGCOLOR="#E9E9E9">
<font size=1><a href="/$artist_encode/uta/$music_encode/">$music_name</a></font><br>
$tieup
</td></tr></table>
END_OF_HTML
			}else{
print << "END_OF_HTML";
<font size=1><a href="/$artist_encode/uta/$music_encode/">$music_name</a></font><br>
$tieup
END_OF_HTML
			}
			($music,$music_name,$tieup,$counts)=undef;

		}
	}
	if($nextpage){
print << "END_OF_HTML";
$hr
<div align=right><img src="http://img.waao.jp/m2028.gif" width=48 height=9 ><a href="/$artist_encode/uta/asearch/$nextpage/" accesskey="#">$artist_strの次の着うた</a>(#)</div>	
END_OF_HTML
	}
}else{
print << "END_OF_HTML";
<font color="red">該当アーティストが多すぎます。更に絞り込んで検索してください。</font>
$hr
END_OF_HTML
}

print << "END_OF_HTML";
<a href="/"><strong>無料着うた</strong>検索</a>
END_OF_HTML
	

&html_table($self, qq{<font size=1 color="#00968c">$artist_str</font><font size=1 color="#FF0000">検索プラス</font>}, 0, 0);
my ($datacnt, $keyworddata) = &get_keyword($self, $artist_str);
my ($photodatacnt, $photodata) = &get_photo($self, $keyworddata->{id});

&html_keyword_info($self, $keyworddata, $photodata);

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/uta/">無料着うたフル検索プラス</a>&gt;<strong>$artist_str</strong><br>
<font size=1 color="#AAAAAA">無料着うたフル検索プラスは,複数の着うたサイトから、着うた・着メロ・着歌フルなどマルチに検索できる無料着うた検索サイトです。<br>
</font>
END_OF_HTML

	&html_footer($self);

	return;
}

sub _search(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('q');

	$self->{html_title} = qq{$keyword の着うた -着うたフル検索-};
	$self->{html_keywords} = qq{$keyword,無料,着うた,フル,検索};
	$self->{html_description} = qq{無料着うたフル検索 :$keywordの着うたをマルチ検索};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);

	&html_table($self, qq{<h2><font size=1 color="#FF0000">$keyword</font></h2>}, 1, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML
	
&html_table($self, qq{アーティスト検索結果}, 0, 0);
	# アーティスト検索
	&_search_artist($self);
	
&html_table($self, qq{曲名検索結果}, 0, 0);
	# 曲名検索
	&_search_song($self);
	
print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/uta/">無料着うたフル検索プラス</a>&gt;<strong>$keyword</strong><br>
<font size=1 color="#AAAAAA">無料着うたフル検索プラスは,複数の着うたサイトから、着うた・着メロ・着歌フルなどマルチに検索できる無料着うた検索サイトです。<br>
</font>
END_OF_HTML

	&html_footer($self);
	return;
}

sub _search_artist(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('q');
	my $keyword_encode = &str_encode($keyword);

	my $api_params;
	$api_params->{view} = 5;
	$api_params->{k} = $keyword_encode;
	$api_params->{page} = $self->{cgi}->param('p2');
	my $xmlstr = &_api_get($self,"ArtistSearch?kind=artist_keyword",$api_params);
	my $hr = &html_hr($self,1);	

if($xmlstr){
	my ($music,$music_name,$artist,$artist_name,$tieup,$counts);
	my $artist_encode;
	my ($pagestr,$nextpage);
	my @lines = split(/\n/,$xmlstr);
	my $recnt;
	foreach my $line (@lines){
		if($line =~/(.*)totalhit\>(.*)\<(.*)/){
			($pagestr,$nextpage) = &_pager_str($self, $2);
		}elsif($line =~/(.*)musician_name\>(.*)\<(.*)/){
			$artist = $2;
		}elsif($line =~/(.*)musician_name_label\>(.*)\<(.*)/){
			$artist_name = $2;
		}elsif($line =~/(.*)tieup\>(.*)\<(.*)/){
			if($2){
         		    $tieup = qq{<font color="blue" size="1">$2</font><br>};
			}
		}elsif($line =~/(.*)counts\>(.*)\<(.*)/){
			$counts = $2;
		}
		if($counts){
			# 表示部分
			my $music_encode = &str_encode($music);
			$artist_encode = &str_encode($artist);
			$recnt++;
print << "END_OF_HTML";
$hr
END_OF_HTML
		unless($recnt % 2){
print << "END_OF_HTML";
<table border="0" width=100%><tr><td BGCOLOR="#E9E9E9">
<font size=1><a href="/$artist_encode/uta/asearch/">$artist_name</a></font><br>
$tieup
</td></tr></table>
END_OF_HTML
			}else{
print << "END_OF_HTML";
<font size=1><a href="/$artist_encode/uta/asearch/">$artist_name</a></font><br>
$tieup
END_OF_HTML
			}
			($music,$music_name,$tieup,$counts)=undef;
		}
	}
	if($nextpage){
print << "END_OF_HTML";
$hr
<a href="/$keyword_encode/uta/page/$nextpage/" accesskey="#">へ(#)</a><br>	
END_OF_HTML
	}
}else{
print << "END_OF_HTML";
<font color="red">該当アーティストが見つかりませんでした。</font>
$hr
END_OF_HTML
}

	return;
}

sub _search_song(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('q');
	my $keyword_encode = &str_encode($keyword);
	
	my $api_params;
	$api_params->{view} = 5;
	$api_params->{k} = $keyword_encode;
	$api_params->{page} = $self->{cgi}->param('p2');
	my $xmlstr = &_api_get($self,"MusicSearch?kind=music_keyword",$api_params);
	my $hr = &html_hr($self,1);	

if($xmlstr){
	my ($music,$music_name,$artist,$artist_name,$tieup,$counts);
	my $artist_encode;
	my ($pagestr,$nextpage);
	my @lines = split(/\n/,$xmlstr);
	my $recnt;
	foreach my $line (@lines){
		if($line =~/(.*)totalhit\>(.*)\<(.*)/){
			($pagestr,$nextpage) = &_pager_str($self, $2);
		}elsif($line =~/(.*)music_name\>(.*)\<(.*)/){
			$music = $2;
		}elsif($line =~/(.*)music_name_label\>(.*)\<(.*)/){
			$music_name = $2;
		}elsif($line =~/(.*)musician_name\>(.*)\<(.*)/){
			$artist = $2;
		}elsif($line =~/(.*)musician_name_label\>(.*)\<(.*)/){
			$artist_name = $2;
		}elsif($line =~/(.*)tieup\>(.*)\<(.*)/){
			if($2){
         		    $tieup = qq{<font color="blue" size="1">$2</font><br>};
			}
		}elsif($line =~/(.*)counts\>(.*)\<(.*)/){
			$counts = $2;
		}
		if($artist_name){
			# 表示部分
			my $music_encode = &str_encode($music);
			$artist_encode = &str_encode($artist);
			$recnt++;
print << "END_OF_HTML";
$hr
END_OF_HTML
		unless($recnt % 2){
print << "END_OF_HTML";
<table border="0" width=100%><tr><td BGCOLOR="#E9E9E9">
<font size=1>
<a href="/$artist_encode/uta/$music_encode/">$music_name</a><br>
<div align=right><a href="/$artist_encode/uta/asearch/">$artist_name</a></div>
</td></tr></table>
END_OF_HTML
			}else{
print << "END_OF_HTML";
<font size=1>
<a href="/$artist_encode/uta/$music_encode/">$music_name</a><br>
<div align=right><a href="/$artist_encode/uta/asearch/">$artist_name</a></div>
</font>
$tieup
END_OF_HTML
			}
			($music,$music_name,$artist,$artist_name)=undef;
		}
	}
	if($nextpage){
print << "END_OF_HTML";
$hr
<a href="/$keyword_encode/uta/page/$nextpage/" accesskey="#">次へ(#)</a><br>	
END_OF_HTML
	}
}else{
print << "END_OF_HTML";
<font color="red">該当する曲が見つかりませんでした。</font>
$hr
END_OF_HTML
}
	
	return;
}

sub _list_artist50(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('p1');
	$keyword =~s/-//g;
	my $keyword_encode = &str_encode($keyword);

	$self->{html_title} = qq{無料着うたフル検索プラス -$keyword:アーティスト検索-};
	$self->{html_keywords} = qq{無料,着うた,フル,検索};
	$self->{html_description} = qq{無料着うたフル検索 :$keyword のアーティスト検索};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);

	&html_table($self, qq{<h2><font size=1 color="#FF0000">$keyword のアーティスト検索</font></h2>}, 1, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

	my $api_params;
	$api_params->{k} = $keyword;
	$api_params->{page} = $self->{cgi}->param('p2');
	my $xmlstr = &_api_get($self,"ArtistSearch?kind=artist_initial", $api_params);
if($xmlstr){
	my ($music,$music_name,$artist,$artist_name,$counts);
	my ($pagestr,$nextpage);
	my @lines = split(/\n/,$xmlstr);
	foreach my $line (@lines){
		if($line =~/(.*)totalhit\>(.*)\<(.*)/){
			($pagestr,$nextpage) = &_pager_str($self, $2);
print << "END_OF_HTML";
$pagestr
END_OF_HTML
		}elsif($line =~/(.*)music_name\>(.*)\<(.*)/){
			$music = $2;
		}elsif($line =~/(.*)music_name_label\>(.*)\<(.*)/){
			$music_name = $2;
		}elsif($line =~/(.*)musician_name\>(.*)\<(.*)/){
			$artist = $2;
		}elsif($line =~/(.*)musician_name_label\>(.*)\<(.*)/){
			$artist_name = $2;
		}elsif($line =~/(.*)counts\>(.*)\<(.*)/){
			$counts = $2;
		}
		
		if($artist_name){
			my $music_encode;
			my $artist_encode;
			$music_encode = &str_encode($music);
			$artist_encode = &str_encode($artist);
print << "END_OF_HTML";
$hr
<a href="/$artist_encode/uta/asearch/">$artist_name</a>($counts曲)<br>
END_OF_HTML
			($music,$music_name,$artist,$artist_name)=undef;

		}
	}
	if($nextpage){
print << "END_OF_HTML";
$hr
<a href="/list-artist50/uta/$keyword_encode/$nextpage/" accesskey="6">次へ</a><br>	
END_OF_HTML
	}else{
print << "END_OF_HTML";
$hr
END_OF_HTML
	}
}else{
print << "END_OF_HTML";
<font color="red">該当アーティストが多すぎます。更に絞り込んで検索してください。</font>
$hr
END_OF_HTML
}

print << "END_OF_HTML";
<a href="/"><strong>無料着うた</strong>検索</a>
$hr
<font size=1>更に絞り込む</font><br>
<font size=1>
<a href="#sa">あ行</a><br> 
<a href="#ska">か行</a><br> 
<a href="#ssa">さ行</a><br> 
<a href="#sta">た行</a><br> 
<a href="#sna">な行</a><br>
<a href="#sha">は行</a><br> 
<a href="#sma">ま行</a><br> 
<a href="#sya">や行</a><br> 
<a href="#sra">ら行</a><br> 
<a href="#swa">わ行</a><br>

<hr size=1 color=#FF0000>
<a name="sa"></a>
<a href="/list-artist50/uta/$keyword-%B1/">あ</a>|
<a href="/list-artist50/uta/$keyword-%B2/">い</a>|
<a href="/list-artist50/uta/$keyword-%B3/">う</a>|
<a href="/list-artist50/uta/$keyword-%B4/">え</a>|
<a href="/list-artist50/uta/$keyword-%B5/">お</a>
<br>
<a name="ska"></a>
<a href="/list-artist50/uta/$keyword-%B6/">か</a>|
<a href="/list-artist50/uta/$keyword-%B7/">き</a>|
<a href="/list-artist50/uta/$keyword-%B8/">く</a>|
<a href="/list-artist50/uta/$keyword-%B9/">け</a>|
<a href="/list-artist50/uta/$keyword-%BA/">こ</a>
<br>
<a name="ssa"></a>
<a href="/list-artist50/uta/$keyword-%BB/">さ</a>|
<a href="/list-artist50/uta/$keyword-%BC/">し</a>|
<a href="/list-artist50/uta/$keyword-%BD/">す</a>|
<a href="/list-artist50/uta/$keyword-%BE/">せ</a>|
<a href="/list-artist50/uta/$keyword-%BF/">そ</a>

<br>
<a name="sta"></a>
<a href="/list-artist50/uta/$keyword-%C0/">た</a>|
<a href="/list-artist50/uta/$keyword-%C1/">ち</a>|
<a href="/list-artist50/uta/$keyword-%C2/">つ</a>|
<a href="/list-artist50/uta/$keyword-%C3/">て</a>|
<a href="/list-artist50/uta/$keyword-%C4/">と</a>
<br>
<a name="sna"></a>
<a href="/list-artist50/uta/$keyword-%C5/">な</a>|
<a href="/list-artist50/uta/$keyword-%C6/">に</a>|
<a href="/list-artist50/uta/$keyword-%C7/">ぬ</a>|
<a href="/list-artist50/uta/$keyword-%C8/">ね</a>|
<a href="/list-artist50/uta/$keyword-%C9/">の</a>
<br>
<a name="sha"></a>
<a href="/list-artist50/uta/$keyword-%CA/">は</a>|
<a href="/list-artist50/uta/$keyword-%CB/">ひ</a>|
<a href="/list-artist50/uta/$keyword-%CC/">ふ</a>|
<a href="/list-artist50/uta/$keyword-%CD/">へ</a>|
<a href="/list-artist50/uta/$keyword-%CE/">ほ</a>

<br>
<a name="sma"></a>
<a href="/list-artist50/uta/$keyword-%CF/">ま</a>|
<a href="/list-artist50/uta/$keyword-%D0/">み</a>|
<a href="/list-artist50/uta/$keyword-%D1/">む</a>|
<a href="/list-artist50/uta/$keyword-%D2/">め</a>|
<a href="/list-artist50/uta/$keyword-%D3/">も</a>
<br>
<a name="sya"></a>
<a href="/list-artist50/uta/$keyword-%D4/">や</a>|
　|
<a href="/list-artist50/uta/$keyword-%D5/">ゆ</a>|
　|
<a href="/list-artist50/uta/$keyword-%D6/">よ</a>
<br>
<a name="sra"></a>
<a href="/list-artist50/uta/$keyword-%D7/">ら</a>|
<a href="/list-artist50/uta/$keyword-%D8/">り</a>|
<a href="/list-artist50/uta/$keyword-%D9/">る</a>|
<a href="/list-artist50/uta/$keyword-%DA/">れ</a>|
<a href="/list-artist50/uta/$keyword-%DB/">ろ</a>

<br>
<a name="swa"></a>
<a href="/list-artist50/uta/$keyword-%DC/">わ</a>|
　|
　|
　|

</font>
$hr
<a href="/" accesskey=0>トップ</a>&gt;<strong>無料着うたフル検索プラス</strong><br>
<font size=1 color="#AAAAAA">無料着うたフル検索プラスは,複数の着うたサイトから、着うた・着メロ・着歌フルなどマルチに検索できる無料着うた検索サイトです。<br>
</font>
END_OF_HTML

	&html_footer($self);
	
	return;
}

sub _ranking(){
	my $self = shift;

	my $page = $self->{cgi}->param('p1');
	my $ad = &html_google_ad($self);

	# ページ制御
	my $limit_s = 0;
	my $limit = 20;
	if( $page ){
		$limit_s = $limit * $page;
	}
	my $next_page = $page + 1;

my $rankdate;
my $sth = $self->{dbi}->prepare(qq{ select rankdate from music order by id desc limit 1});
$sth->execute();
while(my @row = $sth->fetchrow_array) {
	$rankdate = $row[0];
}		

my $sth = $self->{dbi}->prepare(qq{ select id,artist,song from music where rankdate = ? limit $limit_s, $limit} );
$sth->execute($rankdate);

my $recnt;
my $keyword_str;
while(my @row = $sth->fetchrow_array) {
	my $artist_encode = &str_encode($row[1]);
	my $song_encode = &str_encode($row[2]);
	$recnt++;
	$limit_s++;
	unless($recnt % 2){
		$keyword_str .= qq{<table border="0" width=100%><tr><td BGCOLOR="#E9E9E9"><font size=1>};
	}
	my $artist_encode2 = $artist_encode;
	$artist_encode2 =~s/\%20//g;
	my $song_encode2 = $song_encode;
	$song_encode2 =~s/\%20//g;

	$keyword_str .= qq{<font color="blue">$limit_s</font> <a href="/$artist_encode2/uta/$song_encode2/">$row[2]</a><br>};
	$keyword_str .= qq{<div align=right><a href="/$artist_encode2/uta/asearch/">$row[1]</a></div>};
	unless($recnt % 2){
		$keyword_str .= qq{</font></td></tr></table>};
	}
}
	
	$self->{html_title} = qq{無料着うたフル検索ランキング};
	$self->{html_keywords} = qq{無料,着うた,フル,検索,ランキング};
	$self->{html_description} = qq{無料着うたフル検索ランキング :今週の新曲が丸分かり};

	my $hr = &html_hr($self,1);	
	&html_header($self);

&html_table($self, qq{<h1><font color="#FF0000">人気</font>着うたランキング</h1>}, 0, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

print << "END_OF_HTML";
<font size=1>
$keyword_str
<div align=right><img src="http://img.waao.jp/m2028.gif" width=48 height=9 ><a href="/list-ranking/uta/$next_page/" accesskey="#">次の着うたランキングを見る</a>(#)</div>
</font>
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/uta/">無料着うた検索</a>&gt;<strong>無料着うたフル検索ランキング</strong><br>
<font size=1 color="#AAAAAA">無料着うたフル検索プラスは,複数の着うたサイトから、着うた・着メロ・着歌フルなどマルチに検索できる無料着うた検索サイトです。<br>
</font>
END_OF_HTML

	&html_footer($self);

	
	return;
}

1;