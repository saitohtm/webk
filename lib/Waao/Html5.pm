package Waao::Html5;
use Exporter;
@ISA = (Exporter);
@EXPORT = qw(html5_access_check html_header html_footer html_mojibake_str);

sub html5_access_check() {
	my $self = shift;
	return;
}

sub html_header(){
	my $self = shift;

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1, maximum-scale=1"/>
<meta name="format-detection" content="telephone=no" />
<meta http-equiv="Expires" content="86400">
<link rel="apple-touch-icon" href="http://s.waao.jp/img/home.png" />
<link rel="stylesheet" href="/css/smf.css" />
<link rel="stylesheet" href="/jquery.mobile-1.0a3.min.css" />
<script type="text/javascript" src="/jquery-1.5.min.js"></script>
<script type="text/javascript" src="/my.js"></script>
<script type="text/javascript" src="/jquery.mobile-1.0a3.min.js"></script>
<script type="text/javascript">
var admob_vars = {
 pubid: 'a14d9ff79ae0877', // publisher id
 bgcolor: '000000', // background color (hex)
 text: 'FFFFFF', // font-color (hex)
 ama: false, // set to true and retain comma for the AdMob Adaptive Ad Unit, a special ad type designed for PC sites accessed from the iPhone.  More info: http://developer.admob.com/wiki/IPhone#Web_Integration
 test: false // test mode, set to false to receive live ads
};
</script>
<script src='http://a.adimg.net/javascripts/AdLantisLoader.js' type='text/javascript' charset='UTF-8'></script>
<script type="text/javascript">
var admob_vars = {
 pubid: 'a14d9fd972dab72', // publisher id
 bgcolor: 'FF9119', // background color (hex)
 text: 'FFFFFF', // font-color (hex)
 ama: false, // set to true and retain comma for the AdMob Adaptive Ad Unit, a special ad type designed for PC sites accessed from the iPhone.  More info: http://developer.admob.com/wiki/IPhone#Web_Integration
 test: false // test mode, set to false to receive live ads
};
</script>

END_OF_HTML

if($self->{html_keywords}){
print << "END_OF_HTML";
<meta name="keyword" content="$self->{html_keywords}" xml:lang="ja" lang="ja"/>
END_OF_HTML
}

if($self->{html_description}){
print << "END_OF_HTML";
<meta name="description" content="$self->{html_description}" xml:lang="ja" lang="ja"/>
END_OF_HTML
}

if($self->{html_title}){
print << "END_OF_HTML";
<meta name="title" content="$self->{html_title}" xml:lang="ja" lang="ja"/>
<title>$self->{html_title}</title>
END_OF_HTML
}else{
print << "END_OF_HTML";
<meta name="title" content="スマートフォン" xml:lang="ja" lang="ja"/>
<title>$self->{html_title}</title>
END_OF_HTML
}

print << "END_OF_HTML";
</head>
<body>
<div id="home" data-role="page">
<!-- Begin: Adlantis, StickyZone: [smax ヘッダー] -->
<div class='adlantis_sticky_zone zid_MTE1NzE%3D%0A'></div>
<!-- End: Adlantis -->
END_OF_HTML


	
	return;
}

sub html_footer(){
	my $self = shift;
	
print << "END_OF_HTML";
<a href="http://person.smax.tv/">persons</a> 
<a href="http://animal.goo.to/">癒やしの動物画像</a> 
<a href="http://travel.goo.to/">一生に一度は行きたい世界の絶景</a> 
<a href="http://supercar.goo.to/">世界のスーパーカー</a> 
<a href="http://sexy.goo.to/">世界の美女</a> 
<br />
<script type="text/javascript" src="http://mmv.admob.com/static/iphone/iadmob.js"></script>
<br>

<g:plusone size="medium"></g:plusone>
<a href="http://twitter.com/share" class="twitter-share-button" data-count="horizontal" data-via="weare_allone" data-lang="ja">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script>

<a href="http://b.hatena.ne.jp/entry/http://s.waao.jp/" class="hatena-bookmark-button" data-hatena-bookmark-title="みんなのスマートフォンナビ" data-hatena-bookmark-layout="standard" title="このエントリーをはてなブックマークに追加"><img src="http://b.st-hatena.com/images/entry-button/button-only.gif" alt="このエントリーをはてなブックマークに追加" width="20" height="20" style="border: none;" /></a><script type="text/javascript" src="http://b.st-hatena.com/js/bookmark_button.js" charset="UTF-8" async="async"></script>
<div id="footer">
<table border="0" width=100%><tr><td BGCOLOR="#FFFFFF">
<a href="/poricy.htm"  target="_blank">プライバシーポリシー</a>｜
<a href="/menseki.htm" alt="免責" target="_blank">免責</a>｜<a href="/release.htm">リリース</a>
<center><img src="/img/We_Aer_All_One.png"><br>- <a href="http://waao.jp/">http://waao.jp/</a> -</center>
</td></tr></table>
</div>
</div>
<script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-12681370-3']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>
<script type="text/javascript" src="https://apis.google.com/js/plusone.js">
  {lang: 'ja'}
</script>
</body>
</html>	
END_OF_HTML

	return;
}

sub html_mojibake_str(){
	my $tmpl = shift;
	
my $file = qq{/var/www/vhosts/waao.jp/tmpl/$tmpl};
my $fh;
my $filedata;
open( $fh, "<", $file );
while( my $line = readline $fh ){ 
	$filedata .= $line;
}
close ( $fh );

	return $filedata;
}
1;
