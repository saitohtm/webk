package Waao::Pages::Bbs;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Html;
use Waao::Utility;
use Waao::Data;


# /keyword/bbs/
# /keyword/bbs/id/
# /keyword/bbs/list/pageno/
# /keyword/bbs/add/ 

sub dispatch(){
	my $self = shift;

	if($self->{cgi}->param('p1') eq 'list'){
		&_list($self);
	}elsif($self->{cgi}->param('p1') eq 'add'){
		&_no_bbs($self);
	}elsif($self->{cgi}->param('p1')){
		&_detail($self);
	}elsif($self->{cgi}->param('bbs_text')){
		&_bbs_input($self);
	}else{
		&_list($self);
	}
	return;
}

sub _list(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('q');
	my $keyword_encode = &str_encode($keyword);
	my $pageno = 0;
	$pageno = $self->{cgi}->param('p2') if($self->{cgi}->param('p2'));

	my ($datacnt, $keyworddata) = &get_keyword($self, $keyword);
	# データが検索できない場合
	unless($datacnt){
		$self->{no_keyword} = 1;
		return;
	}

	# 画像データ
	my ($photodatacnt, $photodata) = &get_photo($self, $keyworddata->{id});

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);

	my $simplewiki = &simple_wiki_upd($keyworddata->{simplewiki}, 128) if($keyworddata->{simplewiki});

	my $wikilink;
	if($keyworddata->{person}){
		$self->{html_title} = qq{$keywordファンのための応援メッセージボード -みんなの掲示板(BBS)プラス-};
		$self->{html_keywords} = qq{$keyword,掲示板,BBS,ファン,応援,画像掲示板};
		$self->{html_description} = qq{$keyword応援メッセージボードは、$keywordファン限定。$keywordをみんなで応援するコミュニティ掲示板です。};
	}else{
		$self->{html_title} = qq{$keyword掲示板(BBS) -みんなの掲示板プラス-};
		$self->{html_keywords} = qq{$keyword,掲示板,BBS,掲示板};
		$self->{html_description} = qq{$keyword掲示板(BBS)。クチコミで作る$keywordの掲示板情報};
	}

	# うわさ情報
	# ページ制御
	my $limit_s = 0;
	my $limit = 10;
	if( $pageno ){
		$limit_s = $limit * $pageno;
	}

	my $bbs_str;
	my $sth = $self->{dbi}->prepare(qq{ select id, keyword, bbs, point, sex, age, nickname from bbs where keywordid = ? order by point desc limit $limit_s, $limit} );
	$sth->execute( $keyworddata->{id} );
	my $recordcnt;
	while(my @row = $sth->fetchrow_array) {
		$recordcnt++;
		$bbs_str .= qq{<font color="#009525">■</font>$row[2]<br>};
		$bbs_str .= qq{<div align=right><font size=1><a href="/$keyword_encode/bbsthread/$row[0]/">詳しく見る</a></font></div>};
		$bbs_str .= qq{$hr};
	}

	unless( $recordcnt ){
		&_no_bbs( $self );
		return;
	}

	my $next_page = $pageno + 1;
	my $next_str = qq{<img src="http://img.waao.jp/m2028.gif" width=48 height=9><a href="/$keyword_encode/bbs/list/$next_page/" accesskey="#">次へ</a>(#)<br>};

	&html_header($self);

if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML
	
}else{
# xhmlt chtml

if($simplewiki){

print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FF9900">$simplewiki </font></marquee>
END_OF_HTML

}

&html_table($self, qq{<h1>$keyword</h1><h2><font size=1 color="#00968c">$keyword</font><font size=1 color="#FF0000">掲示板</font>}, 1, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
$bbs_str
$next_str
<img src="http://img.waao.jp/kya-.gif" width=15 height=15><a href="/$keyword_encode/bbs/add/">投稿する</a>
$hr
END_OF_HTML

&html_keyword_info($self, $keyworddata, $photodata);

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/$keyword_encode/search/$keyworddata->{id}/">$keyword</a>&gt;<strong>$keyword</strong>掲示板<br>
<font size=1 color="#E9E9E9">$keyword掲示板(BBS)の㌻は、$keywordの情報や応援メッセージをクチコミによって集めた$keywordの掲示板㌻です。<br>
$keywordの情報の収集にご協力をお願いします。<br>
</font>
END_OF_HTML
}
	
	&html_footer($self);
	
	return;
}

sub _no_bbs(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('q');
	my $keyword_encode = &str_encode($keyword);

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);

	$self->{html_title} = qq{$keyword掲示板(BBS)投稿画面 -みんなの掲示板プラス-};
	$self->{html_keywords} = qq{$keyword,掲示板,BBS,掲示板,投稿};
	$self->{html_description} = qq{$keyword掲示板(BBS)投稿画面。クチコミで作る$keywordの掲示板情報};
	my ($datacnt, $keyworddata) = &get_keyword($self, $keyword);

	&html_header($self);

if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML
	
}else{
# xhmlt chtml

&html_table($self, qq{<h1>$keyword</h1><h2><font size=1 color="#00968c">$keyword</font><font size=1 color="#FF0000">掲示板</font>}, 1, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
<font color="#FF0000"><strong>$keyword</strong>に関する投稿を募集しています</font><br>
<font size=1>情報提供にご協力をお願いします。</font><br>
<center>
<img src="http://img.waao.jp/kaoonegai02t.gif" width=82 height=15>
</center>
<br>
$hr
END_OF_HTML

&_bbs_input_form($self, $keyword);
&html_shopping_plus($self);
&html_table($self, qq{<font color="#00968c">$keywordの検索</font><font color="#FF0000">プラス</font>}, 0, 0);
&html_keyword_info($self,$keyworddata);

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/$keyword_encode/search/">$keyword</a>&gt;<strong>$keyword</strong>掲示板<br>
<font size=1 color="#E9E9E9">$keyword掲示板(BBS)の㌻は、$keywordの情報や応援メッセージをクチコミによって集めた$keywordの掲示板㌻です。<br>
$keywordの情報の収集にご協力をお願いします。<br>
</font>

END_OF_HTML
}
	
	&html_footer($self);

	return;
}

sub _bbs_input_form(){
	my $self = shift;
	my $keyword = shift;
	
print << "END_OF_HTML";
<strong>$keyword</strong><font size=1>掲示板</font><br>
<form method='post' action='/bbs.html'>
<font color="#009525">■</font>メッセージ(<font color="#FF0000">必須</font>)<br>
<input name="q" value="$keyword" type="hidden" />
<input name="guid" value="on" type="hidden" />
<input name="bbs_text" value="" type="text" size="17"/><br/>
<font color="#009525">■</font>性別(任意)<br>
<select name='sex'>
<option value=0>--</option>
<option value=1>男</option>
<option value=2>女</option>
</select><br>
<font color="#009525">■</font>年代(任意)<br>
<select name='age'>
<option value=0>--</option>
<option value=1>10代</option>
<option value=2>20代</option>
<option value=3>30代</option>
<option value=4>40代</option>
<option value=5>50代〜</option>
</select><br>
<font color="#009525">■</font>ニックネーム(任意)<br>
<input name="nickname" value="" type="text" size="17"/><br/>
<input type='submit' value='投稿する'/>
</form> 
<br><font color="#FF0000" size=1>※投稿内容には、注意して自己責任の元ご投稿ください。</font>
END_OF_HTML

	return;
}

sub _bbs_input(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('q');
	my $keyword_encode = &str_encode($keyword);
	my $bbs_text = $self->{cgi}->param('bbs_text');
	
	my $title_bbs = substr($bbs_text, 0, 32);
	my $desc_bbs = substr($bbs_text, 0, 128);
	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);

	$self->{html_title} = qq{$keyword掲示板:$title_bbs};
	$self->{html_keywords} = qq{$keyword,掲示板,BBS,掲示板,投稿};
	$self->{html_description} = qq{$desc_bbs};

	my ($datacnt, $keyworddata) = &get_keyword($self, $keyword);

	&html_header($self);

if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML
	
}else{
# xhmlt chtml

&html_table($self, qq{<h1>$keyword</h1><h2><font size=1 color="#00968c">$keyword</font><font size=1 color="#FF0000">掲示板</font>}, 1, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
<img src="http://img.waao.jp/gr_domo.gif" width=26 height=47 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left">
<font size=1>
$keywordの情報投稿にご協力いただきありがとうございました。
</font>
<br clear="all" />
$hr
END_OF_HTML

&html_shopping_plus($self);
&html_table($self, qq{<font color="#00968c">$keywordの検索</font><font color="#FF0000">プラス</font>}, 0, 0);
&html_keyword_info($self,$keyworddata);

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/$keyword_encode/search/">$keyword</a>&gt;<strong>$keyword掲示板</strong><br>
<font size=1 color="#E9E9E9">$keyword掲示板(BBS)の㌻は、$keywordの情報や応援メッセージをクチコミによって集めた$keywordの掲示板㌻です。<br>
$keywordの情報の収集にご協力をお願いします。<br>
</font>

END_OF_HTML
}
	
	&html_footer($self);
	
	return unless($self->{real_mobile});
	# データ入力
eval{
	my $sex = $self->{cgi}->param('sex');
	my $age = $self->{cgi}->param('age');
	my $nickname = $self->{cgi}->param('nickname');
	my $mid = $self->{session}->{_session_id};

	my $sth = $self->{dbi}->prepare(qq{insert into bbs  (`keywordid`,`keyword`,`bbs`,`point`,`sex`,`age`,`nickname`,`mid`) values (?,?,?,?,?,?,?,?)} );
	$sth->execute($keyworddata->{id}, $keyword, $bbs_text, 1, $sex, $age, $nickname, $mid);
};
	return;
}

1;