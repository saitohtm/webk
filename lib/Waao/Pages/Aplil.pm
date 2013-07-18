package Waao::Pages::Aplil;
use strict;
use base qw(Waao::Pages::Base);
use Waao::Html;
use Waao::Utility;

# エイプリル
# /20100401/

sub dispatch(){
	my $self = shift;

	if($self->{cgi}->param('flag') eq 'yes'){
		&_yes($self);
	}elsif($self->{cgi}->param('flag') eq 'no'){
		&_no($self);
	}else{
		&_top($self);
	}
	return;
}
sub _top(){
	my $self = shift;

	$self->{html_title} = qq{恥ずかしくない告白ツール。};
	$self->{html_keywords} = qq{告白,ツール,恋愛,こくはく};
	$self->{html_description} = qq{最強告白ツール。恥ずかしくない、気づつかないで告白できちゃいます 2010エイプリルフール};

	my $hr = &html_hr($self,1);	
	&html_header($self);

	my $ad = &html_google_ad($self);

print << "END_OF_HTML";
じつは・・・<br>
あなたの事が・・・<br>
<font color="#FF00BF">ずーっと好き</font>でした<br>
勇気をもって告白します<br>
<br>
<br>
あなたの気持ちを教えてください<br>
<center>
<a href="/20100401.html?guid=on&flag=yes">好き</a> <a href="/20100401.html?guid=on&flag=no">好きじゃない</a>
</center>
$hr
<br>
<br>
<center>
$ad
</center>
END_OF_HTML
	
	&html_footer($self);
	
	return;
}

sub _yes(){
	my $self = shift;

	$self->{html_title} = qq{恥ずかしくない告白ツール。};
	$self->{html_keywords} = qq{告白,ツール,恋愛,こくはく};
	$self->{html_description} = qq{最強告白ツール。恥ずかしくない、気づつかないで告白できちゃいます 2010エイプリルフール};

	my $hr = &html_hr($self,1);	
	&html_header($self);

	my $ad = &html_google_ad($self);

print << "END_OF_HTML";
今日から<font color="#FF00BF">両思い</font>ですネ<br>
あなたも勇気をもって、今直ぐ連絡しましょう<br>
<br>
<br>
他の人にも、カップルになってもらえば、2人の恋愛も上手く良くヨ<br>
<a href="mailto:?body=http://waao.jp/sp-da/">友達に教える</a>
$hr
<center>
$ad
</center>
END_OF_HTML
	
	&html_footer($self);
	
	return;
}

sub _no(){
	my $self = shift;

	$self->{html_title} = qq{恥ずかしくない告白ツール。};
	$self->{html_keywords} = qq{告白,ツール,恋愛,こくはく};
	$self->{html_description} = qq{最強告白ツール。恥ずかしくない、気づつかないで告白できちゃいます 2010エイプリルフール};

	my $hr = &html_hr($self,1);	
	&html_header($self);

	my $ad = &html_google_ad($self);

print << "END_OF_HTML";
今日は、4月1日エイプリルフールだよ〜<br>
冗談だから忘れてね〜<br>
弴弴弴弴弴弴弴弴弴弴弴弴弴弴弴弴弴弴弴弴弴弴<br>
でも3人以上の友達に教えないと・・・不幸が訪れますヨ<br>
弴弴弴弴弴弴弴弴弴弴弴弴弴弴弴弴弴弴弴弴弴弴<br>
<a href="mailto:?body=http://waao.jp/sp-da/">友達に教える</a>
$hr
<center>
$ad
</center>
END_OF_HTML
	
	&html_footer($self);
	
	return;
}

1;