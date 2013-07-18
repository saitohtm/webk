package Waao::Pages::SMFSiteBbs;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Html5;
use Waao::Data;
use Waao::Utility;

sub dispatch(){
	my $self = shift;
	my $siteid = $self->{cgi}->param('id');
	my $description = $self->{cgi}->param('description');
	
	
	my $a = '口コミサイト検索 -スマートフォンナビ(iphone・アンドロイド)-';
	$self->{html_title} = qq{$a};
	my $b = '口コミ,スマートフォン,スマフォ,サイト,検索,iphone,アンドロイド';
	$self->{html_keywords} = qq{$b};
	my $c = '口コミサイトスマートフォン専用サイト検索。iphone/アンドロイドのスマートフォン専用のサイトだけを検索します';
	$self->{html_description} = qq{$c};
	&html_header($self);

eval{	
	my $sth = $self->{dbi}->prepare(qq{insert into site_bbs ( `site_id`, `comment`)  
                                         VALUES (?,?)});
		$sth->execute($siteid,
			&input_str( $description )
		);
};

	my $pcdsp;
	$pcdsp .= qq{不正防止のため、登録者情報を記録させていただきます<br>};
	$pcdsp .= $ENV{'REMOTE_ADDR'}."<br>";
	$pcdsp .= $ENV{'REMOTE_HOST'}."<br>";	

print << "END_OF_HTML";
<div id="header">
<h1><a href="/" style="display: block;"><img src="/img/smftop.jpg" width=100% alt="スマフォナビ"></a></h1>
</div>
<div data-role="header">
<h2>投稿完了</h2>
</div>
<a href="/">トップ</a>&gt;<a href="/site$id/">サイト</a>&gt;口コミ投稿完了
<div data-role="content">
<table border="0" width=100%><tr><td BGCOLOR="#FFFFFF">
<center>
<img src="/img/gr_domo.gif">
</center>
ご投稿ありがとうございます<br><br>
みんなの力で育てるスマートフォン専用の検索エンジン<br>
リンクフリーです。<br>
<br>
http://s.waao.jp/<br>
<br>
$pcdsp
</td></tr></table>
</div>
END_OF_HTML	
&html_footer($self);
	
	return;
}
1;