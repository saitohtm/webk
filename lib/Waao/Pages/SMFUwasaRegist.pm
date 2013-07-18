package Waao::Pages::SMFUwasaRegist;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Html5;
use Waao::Data;
use Waao::Utility;

sub dispatch(){
	my $self = shift;
	
	if($self->{cgi}->param('keyperson')){
		&_uwasa($self);
	}else{
		&_top($self);
	}
	
	return;
}

sub _uwasa(){
	my $self = shift;

	my $keyperson = $self->{cgi}->param('keyperson');
	my $type = $self->{cgi}->param('type');
	my $keywordid = $self->{cgi}->param('keywordid');
	
	# うわさデータ入力
	my ($datacnt, $keyworddata) = &get_keyword($self,"",$keywordid);
	my ($datacnt, $keypersondata) = &get_keyword($self, $keyperson);
	my $keypersonid = 0;
	$keypersonid = $keypersondata->{id} if($keypersondata);
	my $keyword = $keyworddata->{keyword};
eval{
	my $sth = $self->{dbi}->prepare(qq{insert into keyword_recomend  (`keywordid`,`keyword`,`keypersonid`,`keyperson`,`type`,`point`,`mid`) values (?,?,?,?,?,?,?)} );
	$sth->execute($keyworddata->{id}, $keyworddata->{keyword}, $keypersondata->{id}, $keyperson, $type, 1, $self->{session}->{_session_id});
};

	my $pcdsp;
	$pcdsp .= qq{不正防止のため、登録者情報を記録させていただきます<br>};
	$pcdsp .= $ENV{'REMOTE_ADDR'}."<br>";
	$pcdsp .= $ENV{'REMOTE_HOST'}."<br>";


	my $a = "$keywordのうわさを投稿完了画面";
	$self->{html_title} = qq{$a};
	my $b = "$keyword,うわさ,投稿,画面";
	$self->{html_keywords} = qq{$b};
	my $c = "みんなの投稿で作る$keywordのうわさ！$keywordのうわさは、他のサイトでは探せないくちこみ情報です。";
	$self->{html_description} = qq{$c};
	&html_header($self);

print << "END_OF_HTML";
<div data-role="header"> 
<h1>$keywordのうわさ</h1> 
</div>
<a href="/">トップ</a>&gt;<a href="/person$keywordid/">$keyword</a>&gt;<a href="/uwasalist$keywordid/">$keywordのうわさ一覧</a>&gt;$keywordのうわさ投稿

<div data-role="content">
<table border="0" width=100%><tr><td BGCOLOR="#FFFFFF">
<center>
<img src="/img/gr_domo.gif">
</center>
ご投稿ありがとうございます<br><br>
みんなの力で育てるソーシャル人物名鑑です。<br>
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

sub _top(){
	my $self = shift;
	my $keywordid=$self->{cgi}->param('keywordid');
	
	my ($datacnt, $keyworddata) = &get_keyword($self, "", $self->{cgi}->param('keywordid'));
	my $keyword = $keyworddata->{keyword};

	my $a = "$keywordのうわさを投稿画面";
	$self->{html_title} = qq{$a};
	my $b = "$keyword,うわさ,投稿,画面";
	$self->{html_keywords} = qq{$b};
	my $c = "みんなの投稿で作る$keywordのうわさ！$keywordのうわさは、他のサイトでは探せないくちこみ情報です。";
	$self->{html_description} = qq{$c};
	&html_header($self);

print << "END_OF_HTML";
<div data-role="header"> 
<h1>$keywordのうわさ</h1> 
</div>
<a href="/">トップ</a>&gt;<a href="/person$keywordid/">$keyword</a>&gt;<a href="/uwasalist$keywordid/">$keywordのうわさ一覧</a>&gt;$keywordのうわさ投稿

<div data-role="content">
<ul data-role="listview">
<li data-role="list-divider">$keywordのうわさ投稿</li>
</ul>
</div>

<div data-role="fieldcontain">
<form action="/uwasaregist.html"; method="get">

<label for="keyperson">人名:</label>
<input type="text" name="keyperson" id="keyperson" value=""  />
と(が)
<select name="type">
<option value='4'>友人</option>
<option value='7'>メル友</option>
<option value='14'>ライバル</option>
<option value='15'>同年代</option>
<option value='10'>共演者</option>
<option value='11'>同郷</option>
<option value='12'>同じ事務所</option>
<option value='1'>恋人</option>
<option value='2'>元恋人</option>
<option value='3'>夫婦</option>
<option value='13'>元夫婦</option>
<option value='5'>好き</option>
<option value='6'>嫌い</option>
<option value='8'>親子</option>
<option value='9'>兄弟/姉妹</option></select>
<input type="hidden" name="keywordid" value="$keywordid">

<button type="submit" data-transition="fade">だと思う</button>
</form>

</div>

END_OF_HTML

	
&html_footer($self);


	
	return;
}









1;