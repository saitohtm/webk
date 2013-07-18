package Waao::Ngword;
use Exporter;
@ISA = (Exporter);
@EXPORT = qw(ng_word_dsp);
use Waao::Html;

sub ng_word_dsp(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('q');

	$self->{html_title} = qq{$keyword:$keywordデータベース -みんなのモバイル-};
	$self->{html_keywords} = qq{$keyword,wikipedia,検索,データ,情報};
	$self->{html_description} = qq{$keywordとは…$keywordの独自データで更に詳しい内容が今すぐわかる。};
	my $hr = &html_hr($self,1);	

	my $ad = &html_google_ad($self);
	my $yicha_url = &html_yicha_url($self,$keyword);

	&html_header($self);

print << "END_OF_HTML";
<center>
<h1>$keyword</h1>
<h2><font size=1>$keyword:wikipediaデータ</font></h2>
</center>
$hr
<center>
$ad
</center>
$hr
<strong>$keyword</strong>のデータは、削除依頼により削除されました。
$hr
<strong>$keyword</strong>を別な検索エンジンで検索したい方は、
<a href="$yicha_url">こちら</a>から<strong>$keyword</strong>を検索することができます。<br>
<font size=1>※別の検索サイトに遷移します。</font>
END_OF_HTML
	
	&html_footer($self);

	return;
}

1;