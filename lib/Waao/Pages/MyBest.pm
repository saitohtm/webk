package Waao::Pages::MyBest;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Html;
use Waao::Utility;

# /mybest/
# /keyword/mybest/type/
sub dispatch(){
	my $self = shift;
	
	$self->{html_title} = qq{自分手帳 -みんなのネタ帳-};
	$self->{html_keywords} = qq{ネタ帳,メモ帳,記録,自分史,お気に入り,ブックマーク,共有};
	$self->{html_description} = qq{ディリー今もっとも検索されている有名人/タレントはこの人だ！毎日変っちゃうからお見逃し無く};

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);

	&html_table($self, qq{<font color="#FF0000">自分手帳</font>-マイネタ帳-}, 1, 0);

	&html_header($self);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
自分専用の自分手帳<br>
お気に入りをたくさん登録してネタ帳を作ろう<br>
他人には覗けません<br>
$hr
<a href="/list-best/mybest/1/" accesskey=1>歴代好きな有名人</a><br>
<a href="/list-best/mybest/2/" accesskey=2></a><br>
<a href="/list-best/mybest/3/" accesskey=3></a><br>
<a href="/list-best/mybest/4/" accesskey=4></a><br>
<a href="/list-best/mybest/5/" accesskey=5></a><br>
<a href="/list-best/mybest/6/" accesskey=6></a><br>
<a href="/list-best/mybest/7/" accesskey=7></a><br>
<a href="/list-best/mybest/8/" accesskey=8></a><br>
<a href="/list-best/mybest/9/" accesskey=9></a><br>
$hr
<a href="/" accesskey=0>トップ</a>&gt;<strong>自分手帳</strong><br>
<font size=1 color="#AAAAAA">話題の有名人・タレント㌻は、検索数を元に今、まさに話題となっている有名人やタレント情報を提供しています。<br>
END_OF_HTML

	&html_footer($self);
	
	return;
}

1;