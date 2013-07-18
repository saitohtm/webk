package Waao::Pages::Sign;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Data;
use Waao::Html;
use Waao::Utility;
use Jcode;
use CGI qw( escape );

# /list-sign/sign/$no/	topページ

sub dispatch(){
	my $self = shift;
	
	if($self->{cgi}->param('q') eq 'list-sign'){
		&_top($self);
	}elsif($self->{cgi}->param('q') eq 'list-click'){
		&_click($self);
	}else{
		&_top($self);
	}

	return;
}

sub _click(){
	my $self = shift;
	my $sign_no = $self->{cgi}->param('signno');
	
	my ($title, $keywords, $descript, $bodystr, $thanks, $ret_atag, $cnt);
	my $sth = $self->{dbi}->prepare(qq{ select title, keywords, descript, bodystr, thanks, ret_atag, cnt from sign where id = ? limit 1});
	$sth->execute($sign_no);
	while(my @row = $sth->fetchrow_array) {
		($title, $keywords, $descript, $bodystr, $thanks, $ret_atag, $cnt) = @row;
	}

	$self->{html_title} = qq{$title -みんなのケータイ署名-};
	$self->{html_keywords} = qq{$keywords};
	$self->{html_description} = qq{$descript};

	$cnt = $cnt + 777 + 1 if($cnt <= 777);
	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);

if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML
	
}else{# xhmlt chtml

&html_table($self, qq{<img src="http://img.waao.jp/lamp1.gif" width=14 height=11><font color="00968c">$title</font>}, 0, 0);
print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
<br>
ご協力ありがとうございました<br>
<center>
<img src="http://img.waao.jp/kaow01.gif" width=53 height=15 alt="$title">
<br>
<br>
現在の署名数<br>
<font color="#FF0000">$cnt</font><br>
<br>
</center>
<a href="mailto:?subject=&body=http://waao.jp/list-sign/sign/$sign_no/">倞お友達にも教えて</a>、署名にご協力してください。<br>
<center>
<img src="http://img.waao.jp/kaoonegai02t.gif" width=82 height=15 alt="$title">
</center>
<br>
$thanks
$hr
$ret_atag<br>
$hr
<center>
<font size=1>一日一膳<a href="http://wapnavi.net/click/link/mutually.cgi?id=gooto">クリック募金</a></font>
</center>
$hr
<a href="/" accesskey=0>トップ</a>&gt;<strong>$title</strong><br>
END_OF_HTML

}
	&html_footer($self);

if($self->{real_mobile}){
my $sing_log_cnt;
eval{	
my $sth = $self->{dbi}->prepare(qq{ select * from sign_log where mid = ? and sign_no = ? } );
$sth->execute($self->{session}->{_session_id},$sign_no);
while(my @row = $sth->fetchrow_array) {
	$sing_log_cnt++;
}
my $sth = $self->{dbi}->prepare(qq{ insert into sign_log (`mid`,`sign_no`) values (?,?)} );
$sth->execute($self->{session}->{_session_id},$sign_no);
};
unless($sing_log_cnt){
	my $sth = $self->{dbi}->prepare(qq{ update sign set cnt = cnt + 1 where id = ? limit 1 } );
	$sth->execute($sign_no);
}
}	
	return;
}
sub _top(){
	my $self = shift;
	my $sign_no = $self->{cgi}->param('p1');

	my ($title, $keywords, $descript, $bodystr, $thanks, $ret_atag, $cnt);
	my $sth = $self->{dbi}->prepare(qq{ select title, keywords, descript, bodystr, thanks, ret_atag, cnt from sign where id = ? limit 1});
	$sth->execute($sign_no);
	while(my @row = $sth->fetchrow_array) {
		($title, $keywords, $descript, $bodystr, $thanks, $ret_atag, $cnt) = @row;
	}

	$self->{html_title} = qq{$title -みんなのケータイ署名-};
	$self->{html_keywords} = qq{$keywords};
	$self->{html_description} = qq{$descript};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);
	$cnt = $cnt + 777 if($cnt <= 777);

if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML
	
}else{# xhmlt chtml

&html_table($self, qq{<img src="http://img.waao.jp/lamp1.gif" width=14 height=11><font color="00968c">$title</font>}, 0, 0);
print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
$bodystr
$hr
<center>
<br>
現在の署名数<br>
<font color="#FF0000">$cnt</font><br>
<br>
<form action="/sign.html" method="POST" >
<input type="hidden" name="q" value="list-click">
<input type="hidden" name="guid" value="ON">
<input type="hidden" name="signno" value="$sign_no">
<input type="submit" value="賛同する"><br />
</form>
</center>
$hr
$ret_atag<br>
<a href="/" accesskey=0>トップ</a>&gt;<strong>$title</strong><br>
<font size=1 color="#AAAAAA">注)本、署名活動は、正式な署名活動ではありませんので、ご注意ください。携帯電話の識別番号をカウントすることにより、
国内のこれだけの人が賛同しているという参考値を表示させるシステムです。この署名活動による効果については、一切責任を負いません。<br>
</font>

END_OF_HTML

}
	&html_footer($self);

	return;
}

1;
