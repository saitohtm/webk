package Waao::Pages::PcTest;
use strict;
use base qw(Waao::Pages::Base);

use Waao::Html;
use Waao::Data;
use Waao::Utility;
use Jcode;
use CGI qw( escape );

#
# TOP ページ

sub dispatch(){
	my $self = shift;
	
	if($self->{cgi}->param('keyperson')){
		&_uwasa_in($self);
		return;
	}elsif($self->{cgi}->param('bbs')){
		&_bbs_in($self);
		return;
	}elsif($self->{cgi}->param('id')){
		&_keyword($self);
		return;
	}elsif($self->{cgi}->param('q')){
		&_keyword($self);
		return;
	}elsif($self->{cgi}->param('photoid')){
		&_photo($self);
		return;
	}elsif($self->{cgi}->param('uwasaid')){
		&_uwasa($self);
		return;
	}elsif($self->{cgi}->param('uwasalist')){
		&_uwasalist($self);
		return;
	}elsif($self->{cgi}->param('bbsid')){
		&_bbsid($self);
		return;
	}elsif($self->{cgi}->param('bbslist')){
		&_bbslist($self);
		return;
	}elsif($self->{cgi}->param('qanda')){
		&_qanda($self);
		return;
	}elsif($self->{cgi}->param('qandalist')){
		&_qandalist($self);
	}elsif($self->{cgi}->param('meikan')){
		&_meikan($self);
		return;
	}
	
#	unless( $self->{mobile_access} ){
#		# pcログイン対応
#		unless($self->{session}->{_data}->{adminlogin}){
#			unless( $ENV{'HTTP_USER_AGENT'} =~/Google-Sitemaps/){
#				print "Location: http://web.goo.to/\n\n";
#				return;
#			}
#		}
#	}


return;
}

# ページビュー
sub _get_pv(){
	my $self = shift;
	
	my $today;
	my $yesterday;

	# memcache で実装
	# id:1 today{pv,date}
	# id:2 yesterday{pv,date}
	$today->{date} = &get_date(1);

	my $today_mem = $self->{mem}->get( 'q_mo_pv1' );
	my $yesterday_mem = $self->{mem}->get( 'q_mo_pv2' );

	if($today->{date} eq $today_mem->{date}){
		$today->{pv} = $today_mem->{pv} + 1;
		$yesterday = $yesterday_mem;
	}else{
		$today->{pv} = 1;
		$yesterday = $today_mem;
	}

	$self->{mem}->set( 'q_mo_pv1', $today );
	$self->{mem}->set( 'q_mo_pv2', $yesterday );
	
	return ($today->{pv}, $yesterday->{pv});
}

sub _message_dsp(){
	my $self = shift;
	my $message = shift;

	my $retstr;
	my @bbs = split(/\t/,$message);			
	for (my $i=0; $i<=$#bbs; $i++){
		my @comment = split(/::/,$bbs[$i]);
		my $str;
		$str = qq{$comment[1]代} if($comment[1] ne 99);
		$str .= qq{ 男性} if($comment[2] eq 1);
		$str .= qq{ 女性} if($comment[2] eq 2);
		$str .= qq{ 匿名} if($comment[2] eq 9);
		$retstr .= qq{偰$comment[3]<br>};
		$retstr .= qq{<div align="right">$str</div>};
		last;
	}
	
	return $retstr;
}

sub _keyword(){
	my $self = shift;

	# keyword 得
	my ( $keyword_id, $keyword, $cnt, $wikipedia, $yahookeyword, $blogurl, $person, $ana, $model, $artist);
	$keyword_id = $self->{cgi}->param('id');

	my $sth;
	if($self->{cgi}->param('q')){
		$sth = $self->{dbi}->prepare(qq{ select id, keyword, cnt, simplewiki, yahookeyword, blogurl, person, ana, model, artist from keyword where keyword = ? limit 1} );
		$sth->execute($self->{cgi}->param('q'));
	}else{
		$sth = $self->{dbi}->prepare(qq{ select id, keyword, cnt, simplewiki, yahookeyword, blogurl, person, ana, model, artist from keyword where id = ? limit 1} );
		$sth->execute($keyword_id);
	}
	while(my @row = $sth->fetchrow_array) {
		( $keyword_id, $keyword, $cnt, $wikipedia, $yahookeyword, $blogurl, $person, $ana, $model, $artist) = @row;
	}
	my $id = $keyword_id;

	my $keyword_utf8 = $keyword;
	Encode::from_to($keyword_utf8,'cp932','utf8');
	my $keyword_encode = &str_encode($keyword);
	$wikipedia =~s/&gt;/\>/g;
	$wikipedia =~s/&lt;/\</g;



if($ana){
	&_header($self,"女子アナウンサー$keywordの画像・動画・最新ニュースや噂を無料配信中!!","$keyword,女子アナ,アナウンサー,画像,動画,プロフィール,データ,情報","$keyword大好き -女子アナ名鑑-",$keyword);
}elsif($model){
	&_header($self,"モデル$keywordの画像・動画・最新ニュースや噂を無料配信中!!","$keyword,モデル,読者モデル,ファッション,画像,動画,プロフィール,データ,情報","$keyword大好き -人気モデル名鑑-",$keyword);
}elsif($artist){
	&_header($self,"$keywordのPV・最新曲・歌詞・画像・動画・最新ニュースや噂を無料配信中!!","$keyword,新曲,pv,歌詞,画像,動画,プロフィール,データ,情報","$keyword大好き -アーティスト名鑑-",$keyword);
}elsif($person){
	&_header($self,"$keywordの画像・動画・最新ニュースや噂を無料配信中!!","$keyword,画像,動画,プロフィール,データ,情報","$keyword大好き -人物名鑑-",$keyword);
}else{
	&_header($self,"$keywordの画像・動画・wiki情報を無料配信中!!","$keyword,画像,動画,wiki,wikipedia,データ,情報","$keyword -wikiデータベース-",$keyword);
}

print << "END_OF_HTML";
<div id="wrapper">
<div id="header">
<h1>$keyword</h1>
<p class="logo">
<form action="http://www.google.co.jp/cse" id="cse-search-box" target="_blank">
  <div>
<img src="http://goo.to/img/cn11.gif" width=46 height=52>
「$keyword」
    <input type="hidden" name="cx" value="partner-pub-2078370187404934:nqwfgk9rnxl" />
    <input type="hidden" name="ie" value="Shift_JIS" />
    <input type="text" value="$keyword" name="q" size="31" />
    <input type="submit" name="sa" value="&#x691c;&#x7d22;" />
  </div>
</form>
<script type="text/javascript" src="http://www.google.co.jp/cse/brand?form=cse-search-box&amp;lang=ja"></script> 
</p>
</div><!-- / header end -->

<div id="contents">
END_OF_HTML

&_body_best_photo($self,$keyword);
&_body_wiki($self, $keyword, $wikipedia);
&_body_uwasa($self, $keyword, $keyword_id);
&_body_shoplist($self, $keyword);
&_body_bbs($self, $keyword, $keyword_id);
&_body_qanda($self, $keyword, $keyword_id);
&_body_photolist($self,$keyword);
&_body_keyword($self, $keyword, $keyword_id);
&_body_pop_person($self);


print << "END_OF_HTML";
<center>
<a href="http://clickbokin.ekokoro.jp/" target="_blank"><img src="http://www.ekokoro.jp/supporter/br_468_60.jpg" width="468" height="60" border="0" alt="募金サイト イーココロ！"></a>
</center>
<p class="description">$keyword大好きは、携帯サイト みんなのモバイル -<a href="http://goo.to/">http://goo.to/</a>- で提供されています。<br><font color="#FF0000">携帯電話からアクセスしてください。</font></p>

<!-- コンテンツ ここまで -->

</div><!-- / contents end -->

END_OF_HTML
&_side_bar($self,$keyword);
&_footer($self,"$keyword データベース");
	return;
}


sub _photo(){
	my $self = shift;
	my $photo_id = $self->{cgi}->param('photoid');

	# photo
	my ( $url, $good, $keyword_id,$fullurl);
	my $sth = $self->{dbi}->prepare(qq{ select url, good, keywordid,fullurl from photo where id = ? limit 1} );
	$sth->execute($photo_id);
	while(my @row = $sth->fetchrow_array) {
		( $url, $good, $keyword_id,$fullurl) = @row;
	}

	# keyword 取得
	my ( $keyword, $cnt, $wikipedia, $yahookeyword, $blogurl, $song, $person, $ana, $model, $artist);
	my $sth = $self->{dbi}->prepare(qq{ select keyword, cnt, simplewiki, yahookeyword, blogurl, person, ana, model, artist from keyword where id = ? limit 1} );
	$sth->execute($keyword_id);
	while(my @row = $sth->fetchrow_array) {
		( $keyword, $cnt, $wikipedia, $yahookeyword, $blogurl, $person, $ana, $model, $artist) = @row;
	}
	my $keyword_utf8 = $keyword;
	Encode::from_to($keyword_utf8,'cp932','utf8');
	my $keyword_encode = &str_encode($keyword);

	&_header($self,"$keywordの原寸大画像・高画質のオリジナル画像・壁紙写真","$keyword,画像,原寸大,高画質,写真,壁紙","$keywordの原寸大高画質画像（壁紙サイズの写真）-$keyword大好き-",$keyword);


print << "END_OF_HTML";
<div id="wrapper">
<div id="header">
<h1>$keywordの画像</h1>
<p class="logo">
<form action="http://www.google.co.jp/cse" id="cse-search-box" target="_blank">
  <div>
<img src="http://goo.to/img/cn11.gif" width=46 height=52>
「<a href="/id$keyword_id/" title="$keyword大好き">$keyword</a>&gt;$keywordの画像」
    <input type="hidden" name="cx" value="partner-pub-2078370187404934:nqwfgk9rnxl" />
    <input type="hidden" name="ie" value="Shift_JIS" />
    <input type="text" value="$keyword" name="q" size="31" />
    <input type="submit" name="sa" value="&#x691c;&#x7d22;" />
  </div>
</form>
<script type="text/javascript" src="http://www.google.co.jp/cse/brand?form=cse-search-box&amp;lang=ja"></script> 
</p>
</div><!-- / header end -->

<div id="contents">
<table border="0" width=100%><tr><td BGCOLOR="#555555">
<center>
<img src="$fullurl" alt="$keyword原寸大画像(写真)"><br>
<img src="$url" alt="$keyword画像(写真)"><br>
<img src="http://goo.to/img/kya-.gif" width=15 height=15>みんなの評価 $good <font color="red">ポイント</font>
</center>
</td></tr></table>
END_OF_HTML


&_body_photolist($self,$keyword);
&_img_iframe($self,$keyword);
&_body_wiki($self, $keyword, $wikipedia);
&_body_uwasa($self, $keyword, $keyword_id);
&_body_shoplist($self, $keyword);
&_body_bbs($self, $keyword, $keyword_id);
&_body_qanda($self, $keyword, $keyword_id);
&_body_pop_person($self);

print << "END_OF_HTML";
<center>
<a href="http://clickbokin.ekokoro.jp/" target="_blank"><img src="http://www.ekokoro.jp/supporter/br_468_60.jpg" width="468" height="60" border="0" alt="募金サイト イーココロ！"></a>
</center>
<p class="description">$keyword大好きは、携帯サイト みんなのモバイル -<a href="http://goo.to/">http://goo.to/</a>- で提供されています。<br><font color="#FF0000">携帯電話からアクセスしてください。</font></p>

<!-- コンテンツ ここまで -->

</div><!-- / contents end -->
END_OF_HTML

&_side_bar($self,$keyword);
&_footer($self,"$keyword 原寸大画像写真データベース");

	return;
}

sub _bbs_in(){
	my $self = shift;
	my $id = $self->{cgi}->param('id');

	my $str = "2::99::9::".$self->{cgi}->param('bbs');
	my $keyword;
	my $sth = $self->{dbi}->prepare(qq{ select id, keyword, cnt, simplewiki, yahookeyword, blogurl, person, ana, model, artist from keyword where keyword = ? limit 1} );
	$sth->execute($self->{cgi}->param('q'));
	while(my @row = $sth->fetchrow_array) {
		$keyword = $row[1];
	}


eval{

	my $sex = $self->{cgi}->param('sex');
	my $age = $self->{cgi}->param('age');
	my $nickname = $self->{cgi}->param('nickname');
	my $mid = $self->{session}->{_session_id};

	my $sth = $self->{dbi}->prepare(qq{insert into bbs  (`keywordid`,`keyword`,`bbs`,`point`,`sex`,`age`,`nickname`,`mid`) values (?,?,?,?,?,?,?,?)} );
	$sth->execute($id, $keyword, $self->{cgi}->param('bbs'), 1, $sex, $age, $nickname, $mid);
	
};
	&_keyword($self);
	return;
}

sub _uwasalist(){
	my $self = shift;
	my $keyword_id = $self->{cgi}->param('uwasalist');

	# keyword 取得
	my ( $keyword, $cnt, $wikipedia, $yahookeyword, $blogurl, $person, $ana, $model, $artist);
	my $sth = $self->{dbi}->prepare(qq{ select keyword, cnt, simplewiki, yahookeyword, blogurl, person, ana, model, artist from keyword where id = ? limit 1} );
	$sth->execute($keyword_id);
	while(my @row = $sth->fetchrow_array) {
		( $keyword, $cnt, $wikipedia, $yahookeyword, $blogurl, $person, $ana, $model, $artist) = @row;
	}

	# うわさ
	my $uwasalist;
	my $sth = $self->{dbi}->prepare(qq{ select id, keywordid, keyword, keypersonid, keyperson, type, point
                                  from keyword_recomend  where  keywordid = ? and point >= -100 order by point desc limit 100});
	$sth->execute($keyword_id);
	while(my @row = $sth->fetchrow_array) {
			my $str = $row[2];
			$str =~ s/([^0-9A-Za-z_ ])/'%'.unpack('H2',$1)/ge;
			$str =~ s/ /%20/g;
			my $str2 = $row[4];
			$str2 =~ s/([^0-9A-Za-z_ ])/'%'.unpack('H2',$1)/ge;
			$str2 =~ s/ /%20/g;

		$uwasalist.=qq{<table border="0" width=100%><tr><td BGCOLOR="#FFEAEF"><a href="/uwasa$row[0]/">⇒</a><img src="http://goo.to/img/kya-.gif" width=15 height=15><a href="/uwasa$row[0]/">$row[2]</a>は};
		$uwasalist.=qq{<a href="/id$row[3]/">$row[4]</a>};
		$uwasalist.=qq{と恋人<img src="http://goo.to/img/kaochu03.gif" width=72 height=15><br>} if($row[5] eq 1);
		$uwasalist.=qq{と元恋人<img src="http://goo.to/img/kaobye06.gif" width=44 height=12><br>} if($row[5] eq 2);
		$uwasalist.=qq{と夫婦<img src="http://goo.to/img/kaow01.gif" width=53 height=15><br>} if($row[5] eq 3);
		$uwasalist.=qq{と友人<img src="http://goo.to/img/kaobye03.gif" width=35 height=15><br>} if($row[5] eq 4);
		$uwasalist.=qq{が好き<img src="http://goo.to/img/kao-a08.gif" width=15 height=15><br>} if($row[5] eq 5);
		$uwasalist.=qq{が嫌い<img src="http://goo.to/img/kaoikari03.gif" width=60 height=15><br>} if($row[5] eq 6);
		$uwasalist.=qq{とメル友<img src="http://goo.to/img/kaobye01.gif" width=35 height=15><br>} if($row[5] eq 7);
		$uwasalist.=qq{と親子<br>} if($row[5] eq 8);
		$uwasalist.=qq{と兄弟/姉妹<br>} if($row[5] eq 9);
		$uwasalist.=qq{と共演者<br>} if($row[5] eq 10);
		$uwasalist.=qq{と同郷<br>} if($row[5] eq 11);
		$uwasalist.=qq{と同じ事務所<br>} if($row[5] eq 12);
		$uwasalist.=qq{と元夫婦<br>} if($row[5] eq 13);
		$uwasalist.=qq{とライバル<br>} if($row[5] eq 14);
		$uwasalist.=qq{と同年代<br>} if($row[5] eq 15);
		$uwasalist.=qq{<div align=right>うわさ度 <font color="red">$row[6]</font>!!</div></td></tr></table>};
	}

	&_header($self,"$keywordのうわさデータベース","$keyword,うわさ,恋愛,恋人,結婚,熱愛","$keywordのうわさ -$keyword大好き-",$keyword);

print << "END_OF_HTML";
<div id="wrapper">
<div id="header">
<h1>$keywordのうわさ</h1>
<p class="logo">
<form action="http://www.google.co.jp/cse" id="cse-search-box" target="_blank">
  <div>
<img src="http://goo.to/img/cn11.gif" width=46 height=52>
「<a href="/id$keyword_id/" title="$keyword">$keyword</a>&gt;$keywordのうわさ一覧」
    <input type="hidden" name="cx" value="partner-pub-2078370187404934:nqwfgk9rnxl" />
    <input type="hidden" name="ie" value="Shift_JIS" />
    <input type="text" value="$keyword" name="q" size="31" />
    <input type="submit" name="sa" value="&#x691c;&#x7d22;" />
  </div>
</form>
<script type="text/javascript" src="http://www.google.co.jp/cse/brand?form=cse-search-box&amp;lang=ja"></script> 
</p>
</div><!-- / header end -->

<div id="contents">
<h2>$keywordのうわさ</h2>
<font color="blue">$keyword</font>といえば<form method='post' action='/pc.html'><input name="id" value="$keyword_id" type="hidden" /><input name="keyperson" value="" type="text" size="17"/>と(が)<select name='type'><option value='4'>友人</option><option value='7'>メル友</option><option value='14'>ライバル</option><option value='15'>同年代</option><option value='10'>共演者</option><option value='11'>同郷</option><option value='12'>同じ事務所</option><option value='1'>恋人</option><option value='2'>元恋人</option><option value='3'>夫婦</option><option value='13'>元夫婦</option><option value='5'>好き</option><option value='6'>嫌い</option><option value='8'>親子</option><option value='9'>兄弟/姉妹</option></select>関係<input type='submit' value='だと思う'/></form><br><font color="red" size=1>※投稿内容には、注意して自己責任の元ご投稿ください。</font>
<br>
$uwasalist<br>
END_OF_HTML

&_body_best_photo($self,$keyword);
&_body_wiki($self, $keyword, $wikipedia);
&_body_shoplist($self, $keyword);
&_body_bbs($self, $keyword, $keyword_id);
&_body_qanda($self, $keyword, $keyword_id);
&_body_photolist($self,$keyword);
&_body_keyword($self, $keyword, $keyword_id);
&_body_pop_person($self);

print << "END_OF_HTML";
<center>
<a href="http://clickbokin.ekokoro.jp/" target="_blank"><img src="http://www.ekokoro.jp/supporter/br_468_60.jpg" width="468" height="60" border="0" alt="募金サイト イーココロ！"></a>
</center>
<p class="description">$keyword大好きは、携帯サイト みんなのモバイル -<a href="http://goo.to/">http://goo.to/</a>- で提供されています。<br><font color="#FF0000">携帯電話からアクセスしてください。</font></p>

<!-- コンテンツ ここまで -->

</div><!-- / contents end -->

END_OF_HTML

&_side_bar($self,$keyword);
&_footer($self,"$keywordのうわさデータベース");

	return;
}

sub _uwasa_in(){
	my $self = shift;

	my $keyword_id = $self->{cgi}->param('id');
	my $keyperson = $self->{cgi}->param('keyperson');
	my $type = $self->{cgi}->param('type');
	my $keyword;
	my $keypersonid;

	my $sth = $self->{dbi}->prepare(qq{ select id, keyword from keyword  where id = ? limit 1});
	$sth->execute($keyword_id);
	while(my @row = $sth->fetchrow_array) {
		$keyword = $row[1];
	}
	my $sth = $self->{dbi}->prepare(qq{ select id, keyword from keyword  where keyword = ? limit 1});
	$sth->execute($keyperson);
	while(my @row = $sth->fetchrow_array) {
		$keypersonid = $row[0];
	}
	my $target_id;
eval{
	my $sth = $self->{dbi}->prepare(qq{insert into keyword_recomend  (`keywordid`,`keyword`,`keypersonid`,`keyperson`,`type`,`point`,`mid`) values (?,?,?,?,?,?,?)} );
	$sth->execute($keyword_id, $keyword, $keypersonid, $keyperson, $type, 1, $self->{session}->{_session_id});
	$target_id = $self->{dbi}->{q{mysql_insertid}};
};
	unless($target_id){
		&_uwasa($self, 475);
	}else{
		&_uwasa($self, $target_id);
	}
	return;
}
sub _uwasa(){
	my $self = shift;
	my $uwasa_id = shift;
	$uwasa_id = $self->{cgi}->param('uwasaid') if($self->{cgi}->param('uwasaid'));

	if($self->{cgi}->param('good')){
	    my $sth = $self->{dbi}->prepare(qq{update keyword_recomend set point = point + 1 where id = ? limit 1} );
	    $sth->execute( $uwasa_id );
	}elsif($self->{cgi}->param('bad')){
	    my $sth = $self->{dbi}->prepare(qq{update keyword_recomend set point = point - 1 where id = ? limit 1} );
	    $sth->execute( $uwasa_id );
	}

	# うわさ
	my $keyword_id;
	my $uwasalist;
	my $uwasastr;
	my $sth = $self->{dbi}->prepare(qq{ select id, keywordid, keyword, keypersonid, keyperson, type, point
                                  from keyword_recomend  where  id = ? order by point desc limit 50});
	$sth->execute($uwasa_id);
	while(my @row = $sth->fetchrow_array) {
			$keyword_id = $row[1];
			my $str = $row[2];
			$str =~ s/([^0-9A-Za-z_ ])/'%'.unpack('H2',$1)/ge;
			$str =~ s/ /%20/g;
			my $str2 = $row[4];
			$str2 =~ s/([^0-9A-Za-z_ ])/'%'.unpack('H2',$1)/ge;
			$str2 =~ s/ /%20/g;

		$uwasalist.=qq{<table border="0" width=100%><tr><td BGCOLOR="#FFEAEF"><img src="http://goo.to/img/kya-.gif" width=15 height=15><a href="/uwasa$row[0]/">$row[2]</a>は};
		$uwasalist.=qq{<a href="/id$row[3]/">$row[4]</a>};
		$uwasalist.=qq{と恋人<img src="http://goo.to/img/kaochu03.gif" width=72 height=15><br>} if($row[5] eq 1);
		$uwasalist.=qq{と元恋人<img src="http://goo.to/img/kaobye06.gif" width=44 height=12><br>} if($row[5] eq 2);
		$uwasalist.=qq{と夫婦<img src="http://goo.to/img/kaow01.gif" width=53 height=15><br>} if($row[5] eq 3);
		$uwasalist.=qq{と友人<img src="http://goo.to/img/kaobye03.gif" width=35 height=15><br>} if($row[5] eq 4);
		$uwasalist.=qq{が好き<img src="http://goo.to/img/kao-a08.gif" width=15 height=15><br>} if($row[5] eq 5);
		$uwasalist.=qq{が嫌い<img src="http://goo.to/img/kaoikari03.gif" width=60 height=15><br>} if($row[5] eq 6);
		$uwasalist.=qq{とメル友<img src="http://goo.to/img/kaobye01.gif" width=35 height=15><br>} if($row[5] eq 7);
		$uwasalist.=qq{と親子<br>} if($row[5] eq 8);
		$uwasalist.=qq{と兄弟/姉妹<br>} if($row[5] eq 9);
		$uwasalist.=qq{と共演者<br>} if($row[5] eq 10);
		$uwasalist.=qq{と同郷<br>} if($row[5] eq 11);
		$uwasalist.=qq{と同じ事務所<br>} if($row[5] eq 12);
		$uwasalist.=qq{と元夫婦<br>} if($row[5] eq 13);
		$uwasalist.=qq{とライバル<br>} if($row[5] eq 14);
		$uwasalist.=qq{と同年代<br>} if($row[5] eq 15);
		$uwasalist.=qq{<div align=right>うわさ度 <font color="red">$row[6]</font>!!</div>};
		$uwasastr.=qq{$row[2]は};
		$uwasastr.=qq{$row[4]};
		$uwasastr.=qq{と恋人} if($row[5] eq 1);
		$uwasastr.=qq{と元恋人} if($row[5] eq 2);
		$uwasastr.=qq{と夫婦} if($row[5] eq 3);
		$uwasastr.=qq{と友人} if($row[5] eq 4);
		$uwasastr.=qq{が好き} if($row[5] eq 5);
		$uwasastr.=qq{が嫌い} if($row[5] eq 6);
		$uwasastr.=qq{とメル友} if($row[5] eq 7);
		$uwasastr.=qq{と親子} if($row[5] eq 8);
		$uwasastr.=qq{と兄弟/姉妹} if($row[5] eq 9);
		$uwasastr.=qq{と共演者} if($row[5] eq 10);
		$uwasastr.=qq{と同郷} if($row[5] eq 11);
		$uwasastr.=qq{と同じ事務所} if($row[5] eq 12);
		$uwasastr.=qq{と元夫婦} if($row[5] eq 13);
		$uwasastr.=qq{とライバル} if($row[5] eq 14);
		$uwasastr.=qq{と同年代} if($row[5] eq 15);

	}
	# keyword 取得
	my ( $keyword, $cnt, $wikipedia, $yahookeyword, $blogurl, $song, $person, $ana, $model, $artist);
	my $sth = $self->{dbi}->prepare(qq{ select keyword, cnt, simplewiki, yahookeyword, blogurl, person, ana, model, artist from keyword where id = ? limit 1} );
	$sth->execute($keyword_id);
	while(my @row = $sth->fetchrow_array) {
		( $keyword, $cnt, $wikipedia, $yahookeyword, $blogurl, $person, $ana, $model, $artist) = @row;
	}
	my $str_encode = &str_encode($keyword);

	$uwasalist.=qq{<center><form method='post' action='/pc.html'><input name="uwasaid" value="$uwasa_id" type="hidden" /><input type='submit' name="good" value='ホント'/><input type='submit' name="bad" value='うそ'/></form></center>};
	$uwasalist.=qq{<font color="blue">$keyword</font>といえば<form method='post' action='/pc.html'><input name="id" value="$keyword_id" type="hidden" /><input name="keyperson" value="" type="text" size="17"/>と(が)<select name='type'><option value='4'>友人</option><option value='7'>メル友</option><option value='14'>ライバル</option><option value='15'>同年代</option><option value='10'>共演者</option><option value='11'>同郷</option><option value='12'>同じ事務所</option><option value='1'>恋人</option><option value='2'>元恋人</option><option value='3'>夫婦</option><option value='13'>元夫婦</option><option value='5'>好き</option><option value='6'>嫌い</option><option value='8'>親子</option><option value='9'>兄弟/姉妹</option></select>関係<input type='submit' value='だと思う'/></form><br><font color="red" size=1>※投稿内容には、注意して自己責任の元ご投稿ください。</font></center>};
	$uwasalist.=qq{</td></tr></table>};

	$uwasastr =~s/\<br\>//g;

	&_header($self,"$uwasastr $keywordのうわさ","$keyword,うわさ,恋愛,恋人,結婚,熱愛","$uwasastr $keywordのうわさ",$keyword);

print << "END_OF_HTML";
<div id="wrapper">
<div id="header">
<h1>$keywordのうわさ</h1>
<p class="logo">
<form action="http://www.google.co.jp/cse" id="cse-search-box" target="_blank">
  <div>
<img src="http://goo.to/img/cn11.gif" width=46 height=52>
「<a href="/id$keyword_id/" title="$keyword">$keyword</a>&gt;$keywordのうわさ」
    <input type="hidden" name="cx" value="partner-pub-2078370187404934:nqwfgk9rnxl" />
    <input type="hidden" name="ie" value="Shift_JIS" />
    <input type="text" value="$keyword" name="q" size="31" />
    <input type="submit" name="sa" value="&#x691c;&#x7d22;" />
  </div>
</form>
<script type="text/javascript" src="http://www.google.co.jp/cse/brand?form=cse-search-box&amp;lang=ja"></script> 
</p>
</div><!-- / header end -->

<div id="contents">
<h2>$keywordのうわさ</h2>
$uwasalist<br>
END_OF_HTML

&_body_uwasa($self, $keyword, $keyword_id, 100);
&_body_best_photo($self,$keyword);
&_body_wiki($self, $keyword, $wikipedia);
&_body_shoplist($self, $keyword);
&_body_bbs($self, $keyword, $keyword_id);
&_body_qanda($self, $keyword, $keyword_id);
&_body_photolist($self,$keyword);
&_body_keyword($self, $keyword, $keyword_id);
&_body_pop_person($self);

print << "END_OF_HTML";
<center>
<a href="http://clickbokin.ekokoro.jp/" target="_blank"><img src="http://www.ekokoro.jp/supporter/br_468_60.jpg" width="468" height="60" border="0" alt="募金サイト イーココロ！"></a>
</center>
<p class="description">$keyword大好きは、携帯サイト みんなのモバイル -<a href="http://goo.to/">http://goo.to/</a>- で提供されています。<br><font color="#FF0000">携帯電話からアクセスしてください。</font></p>

<!-- コンテンツ ここまで -->

</div><!-- / contents end -->

END_OF_HTML

&_side_bar($self,$keyword);
&_footer($self,"$keywordのうわさデータベース");

	return;
}

sub _bbslist(){
	my $self = shift;
	my $keyword_id = $self->{cgi}->param('bbslist');

	# keyword 取得
	my ( $keyword, $cnt, $wikipedia, $yahookeyword, $blogurl, $song, $person, $ana, $model, $artist);
	my $sth = $self->{dbi}->prepare(qq{ select keyword, cnt, simplewiki, yahookeyword, blogurl, person, ana, model, artist from keyword where id = ? limit 1} );
	$sth->execute($keyword_id);
	while(my @row = $sth->fetchrow_array) {
		( $keyword, $cnt, $wikipedia, $yahookeyword, $blogurl, $person, $ana, $model, $artist) = @row;
	}

	# BBS
	my $bbslist;
	my $sth = $self->{dbi}->prepare(qq{ select id, bbs from bbs  where keywordid = ? order by id desc limit 100} );
	$sth->execute($keyword_id);
	while(my @row = $sth->fetchrow_array) {
		my $bbs .= $row[1];
		$bbslist .= qq{<a href="/bbsid$row[0]/" title="$keywordの掲示板">■</a>$bbs<br>};
	}

	&_header($self,"$keywordの掲示板(BBS) $keywordについて語ろう！ ","$keyword,掲示板,BBS,投稿","$keywordの掲示板(BBS) -$keyword大好き-",$keyword);

print << "END_OF_HTML";
<div id="wrapper">
<div id="header">
<h1>$keywordの画像</h1>
<p class="logo">
<form action="http://www.google.co.jp/cse" id="cse-search-box" target="_blank">
  <div>
<img src="http://goo.to/img/cn11.gif" width=46 height=52>
「<a href="/id$keyword_id/" title="$keyword大好き">$keyword</a>&gt;$keyword掲示板」
    <input type="hidden" name="cx" value="partner-pub-2078370187404934:nqwfgk9rnxl" />
    <input type="hidden" name="ie" value="Shift_JIS" />
    <input type="text" value="$keyword" name="q" size="31" />
    <input type="submit" name="sa" value="&#x691c;&#x7d22;" />
  </div>
</form>
<script type="text/javascript" src="http://www.google.co.jp/cse/brand?form=cse-search-box&amp;lang=ja"></script> 
</p>
</div><!-- / header end -->

<div id="contents">
<h2>$keyword の掲示板</h2>
<font color="blue">$keyword</font>について一言！<br>
<form method='post' action='/pc.html'><input name="id" value="$keyword_id" type="hidden" />
<input name="bbs" value="" type="text" size="17"/>
<input type='submit' value='投稿'/></form>
<br><font color="red" size=1>※投稿内容には、注意して自己責任の元ご投稿ください。</font>
<br>
$bbslist
END_OF_HTML


&_body_wiki($self, $keyword, $wikipedia);
&_body_shoplist($self, $keyword);
&_body_uwasa($self, $keyword, $keyword_id);
&_body_photolist($self,$keyword);
&_img_iframe($self,$keyword);
&_body_qanda($self, $keyword, $keyword_id);
&_body_pop_person($self);

print << "END_OF_HTML";
<center>
<a href="http://clickbokin.ekokoro.jp/" target="_blank"><img src="http://www.ekokoro.jp/supporter/br_468_60.jpg" width="468" height="60" border="0" alt="募金サイト イーココロ！"></a>
</center>
<p class="description">$keyword大好きは、携帯サイト みんなのモバイル -<a href="http://goo.to/">http://goo.to/</a>- で提供されています。<br><font color="#FF0000">携帯電話からアクセスしてください。</font></p>

<!-- コンテンツ ここまで -->

</div><!-- / contents end -->
END_OF_HTML

&_side_bar($self,$keyword);
&_footer($self,"$keyword 原寸大画像写真データベース");


	return;
}

sub _bbsid(){
	my $self = shift;
	my $bbs_id = $self->{cgi}->param('bbsid');

	my $keyword_id;
	
	# BBS
	my $bbslist;
	my $bbs;
	my $sth = $self->{dbi}->prepare(qq{ select id, bbs, keywordid  from bbs  where id = ? limit 1} );
	$sth->execute($bbs_id);
	while(my @row = $sth->fetchrow_array) {
		$keyword_id = $row[2];
		$bbs .= $row[1];
		$bbslist .= qq{$bbs};
		$bbs = undef;
		my @bbs = split(/\t/,$row[1]);			
		#for (my $i=0; $i<=$#bbs; $i++){
		#	my @comment = split(/::/,$bbs[$i]);
		#	$bbs = qq{$comment[3]};
		#	last;
		#}

	}
	$bbs =~s/\<br\>//g;
	# keyword 取得
	my ( $keyword, $cnt, $wikipedia, $yahookeyword, $blogurl, $song, $person, $ana, $model, $artist);
	my $sth = $self->{dbi}->prepare(qq{ select keyword, cnt, simplewiki, yahookeyword, blogurl, person, ana, model, artist from keyword where id = ? limit 1} );
	$sth->execute($keyword_id);
	while(my @row = $sth->fetchrow_array) {
		( $keyword, $cnt, $wikipedia, $yahookeyword, $blogurl, $person, $ana, $model, $artist) = @row;
	}

	&_header($self,"$bbs","$keyword,掲示板,BBS,投稿","$bbs -$keyword大好き-",$keyword);

print << "END_OF_HTML";
<div id="wrapper">
<div id="header">
<h1>$keywordの掲示板</h1>
<p class="logo">
<form action="http://www.google.co.jp/cse" id="cse-search-box" target="_blank">
  <div>
<img src="http://goo.to/img/cn11.gif" width=46 height=52>
「<a href="/id$keyword_id/" title="$keyword大好き">$keyword</a>&gt;$keyword掲示板」
    <input type="hidden" name="cx" value="partner-pub-2078370187404934:nqwfgk9rnxl" />
    <input type="hidden" name="ie" value="Shift_JIS" />
    <input type="text" value="$keyword" name="q" size="31" />
    <input type="submit" name="sa" value="&#x691c;&#x7d22;" />
  </div>
</form>
<script type="text/javascript" src="http://www.google.co.jp/cse/brand?form=cse-search-box&amp;lang=ja"></script> 
</p>
</div><!-- / header end -->

<div id="contents">
<h2>$keyword の掲示板</h2>
$bbs
<br>
<br>
<font color="blue">$keyword</font>について一言！<br>
<form method='post' action='/pc.html'><input name="id" value="$keyword_id" type="hidden" />
<input name="bbs" value="" type="text" size="17"/>
<input type='submit' value='投稿'/></form>
<br><font color="red" size=1>※投稿内容には、注意して自己責任の元ご投稿ください。</font>
<br>
END_OF_HTML


&_body_bbs($self, $keyword, $keyword_id);
&_body_wiki($self, $keyword, $wikipedia);
&_body_shoplist($self, $keyword);
&_body_uwasa($self, $keyword, $keyword_id);
&_body_photolist($self,$keyword);
&_img_iframe($self,$keyword);
&_body_qanda($self, $keyword, $keyword_id);
&_body_pop_person($self);

print << "END_OF_HTML";
<center>
<a href="http://clickbokin.ekokoro.jp/" target="_blank"><img src="http://www.ekokoro.jp/supporter/br_468_60.jpg" width="468" height="60" border="0" alt="募金サイト イーココロ！"></a>
</center>
<p class="description">$keyword大好きは、携帯サイト みんなのモバイル -<a href="http://goo.to/">http://goo.to/</a>- で提供されています。<br><font color="#FF0000">携帯電話からアクセスしてください。</font></p>

<!-- コンテンツ ここまで -->

</div><!-- / contents end -->
END_OF_HTML

&_side_bar($self,$keyword);
&_footer($self,"$keyword 掲示板データベース");



	return;
}

sub _qanda(){
	my $self = shift;
	my $qanda_id = $self->{cgi}->param('qanda');


my ($id, $question, $bestanswer, $url, $keyword_id);
my $qandacnt;
my $qandalist;
my $question;
my $sth = $self->{dbi}->prepare(qq{select id, question, bestanswer, url,keywordid from qanda where id = ? limit 50 } );
$sth->execute( $qanda_id );
while(my @row = $sth->fetchrow_array) {
	($id, $question, $bestanswer, $url, $keyword_id) = @row;
$qandacnt++;
$question=$row[1];
my $answer = $row[2];
$qandalist.=qq{<table border="0" width=100%><tr><td BGCOLOR="#FFEAEF">};
$qandalist.=qq{<img src="http://goo.to/img/kaohatena02.gif" width=50 height=12><img src="http://goo.to/img/kaohatena03.gif" width=44 height=15><br>};
$qandalist.=qq{<font color="#555555">};
$qandalist.=qq{<font color="#0035D5">■質問</font>:<br>$row[1]<br>};
$qandalist.=qq{<img src="http://goo.to/img/kaow02.gif" width=56 height=12><br>};
$qandalist.=qq{<font color="#FF0000">■回答</font>:<br>$answer <br>};
$qandalist.=qq{</font>};
$qandalist.=qq{</td></tr></table>};
}

# keyword 取得
my ( $keyword, $cnt, $wikipedia, $yahookeyword, $blogurl, $song, $person, $ana, $model, $artist);
my $sth = $self->{dbi}->prepare(qq{ select keyword, cnt, simplewiki, yahookeyword, blogurl, person, ana, model, artist from keyword where id = ? limit 1} );
$sth->execute($keyword_id);
while(my @row = $sth->fetchrow_array) {
	( $keyword, $cnt, $wikipedia, $yahookeyword, $blogurl, $person, $ana, $model, $artist) = @row;
}

	&_header($self,"$question","$keyword,質問,Q&A","$question -$keyword大好き-",$keyword);

print << "END_OF_HTML";
<div id="wrapper">
<div id="header">
<h1>$keywordのQ&A</h1>
<p class="logo">
<form action="http://www.google.co.jp/cse" id="cse-search-box" target="_blank">
  <div>
<img src="http://goo.to/img/cn11.gif" width=46 height=52>
「<a href="/id$keyword_id/" title="$keyword">$keyword</a>&gt;$keywordのQ&A」
    <input type="hidden" name="cx" value="partner-pub-2078370187404934:nqwfgk9rnxl" />
    <input type="hidden" name="ie" value="Shift_JIS" />
    <input type="text" value="$keyword" name="q" size="31" />
    <input type="submit" name="sa" value="&#x691c;&#x7d22;" />
  </div>
</form>
<script type="text/javascript" src="http://www.google.co.jp/cse/brand?form=cse-search-box&amp;lang=ja"></script> 
</p>
</div><!-- / header end -->

<div id="contents">
<h2>$keywordのQ&A</h2>
$qandalist<br>
END_OF_HTML

&_body_qanda($self, $keyword, $keyword_id);
&_body_uwasa($self, $keyword, $keyword_id);
&_body_best_photo($self,$keyword);
&_body_wiki($self, $keyword, $wikipedia);
&_body_shoplist($self, $keyword);
&_body_bbs($self, $keyword, $keyword_id);
&_body_photolist($self,$keyword);
&_body_keyword($self, $keyword, $keyword_id);
&_body_pop_person($self);

print << "END_OF_HTML";
<center>
<a href="http://clickbokin.ekokoro.jp/" target="_blank"><img src="http://www.ekokoro.jp/supporter/br_468_60.jpg" width="468" height="60" border="0" alt="募金サイト イーココロ！"></a>
</center>
<p class="description">$keyword大好きは、携帯サイト みんなのモバイル -<a href="http://goo.to/">http://goo.to/</a>- で提供されています。<br><font color="#FF0000">携帯電話からアクセスしてください。</font></p>

<!-- コンテンツ ここまで -->

</div><!-- / contents end -->

END_OF_HTML

&_side_bar($self,$keyword);
&_footer($self,"$keywordのQ&Aデータベース");


	return;
}
sub _qandalist(){
	my $self = shift;
	my $keyword_id = $self->{cgi}->param('qandalist');

	# keyword 取得
	my ( $keyword, $cnt, $wikipedia, $yahookeyword, $blogurl, $song, $person, $ana, $model, $artist);
	my $sth = $self->{dbi}->prepare(qq{ select keyword, cnt, simplewiki, yahookeyword, blogurl, person, ana, model, artist from keyword where id = ? limit 1} );
	$sth->execute($keyword_id);
	while(my @row = $sth->fetchrow_array) {
		( $keyword, $cnt, $wikipedia, $yahookeyword, $blogurl, $person, $ana, $model, $artist) = @row;
	}

my $qandacnt;
my $qandalist;
my $sth = $self->{dbi}->prepare(qq{select id, question, bestanswer, url from qanda where keywordid = ? limit 100 } );
$sth->execute( $keyword_id );
while(my @row = $sth->fetchrow_array) {
$qandacnt++;
my $answer = substr($row[2], 0, 64);
$qandalist.=qq{<table border="0" width=100%><tr><td BGCOLOR="#FFEAEF">};
$qandalist.=qq{<img src="http://goo.to/img/kaohatena02.gif" width=50 height=12><img src="http://goo.to/img/kaohatena03.gif" width=44 height=15><br>};
$qandalist.=qq{<font color="#555555" size=1>};
$qandalist.=qq{<font color="#0035D5">■質問</font>:$row[1]<br>};
$qandalist.=qq{<img src="http://goo.to/img/kaow02.gif" width=56 height=12><br>};
$qandalist.=qq{<font color="#FF0000">■回答</font>:$answer <a href="/qanda$row[0]/" title="$keywordの質問">⇒詳細を見る</a><br>};
$qandalist.=qq{</font>};
$qandalist.=qq{</td></tr></table>};
}


	&_header($self,"$keywordの画像・動画・wiki情報を無料配信中!!","$keyword,画像,動画,wiki,wikipedia,データ,情報","$keyword -wikiデータベース-",$keyword);

print << "END_OF_HTML";
<div id="wrapper">
<div id="header">
<h1>$keywordのQ&A</h1>
<p class="logo">
<form action="http://www.google.co.jp/cse" id="cse-search-box" target="_blank">
  <div>
<img src="http://goo.to/img/cn11.gif" width=46 height=52>
「<a href="/id$keyword_id/" title="$keyword">$keyword</a>&gt;$keywordのQ&A」
    <input type="hidden" name="cx" value="partner-pub-2078370187404934:nqwfgk9rnxl" />
    <input type="hidden" name="ie" value="Shift_JIS" />
    <input type="text" value="$keyword" name="q" size="31" />
    <input type="submit" name="sa" value="&#x691c;&#x7d22;" />
  </div>
</form>
<script type="text/javascript" src="http://www.google.co.jp/cse/brand?form=cse-search-box&amp;lang=ja"></script> 
</p>
</div><!-- / header end -->

<div id="contents">
<h2>$keywordのQ&A</h2>
$qandalist
END_OF_HTML

&_body_best_photo($self,$keyword);
&_body_wiki($self, $keyword, $wikipedia);
&_body_uwasa($self, $keyword, $keyword_id);
&_body_shoplist($self, $keyword);
&_body_bbs($self, $keyword, $keyword_id);
&_body_photolist($self,$keyword);
&_body_keyword($self, $keyword, $keyword_id);
&_body_pop_person($self);

print << "END_OF_HTML";
<center>
<a href="http://clickbokin.ekokoro.jp/" target="_blank"><img src="http://www.ekokoro.jp/supporter/br_468_60.jpg" width="468" height="60" border="0" alt="募金サイト イーココロ！"></a>
</center>
<p class="description">$keyword大好きは、携帯サイト みんなのモバイル -<a href="http://goo.to/">http://goo.to/</a>- で提供されています。<br><font color="#FF0000">携帯電話からアクセスしてください。</font></p>

<!-- コンテンツ ここまで -->

</div><!-- / contents end -->

END_OF_HTML
&_side_bar($self,$keyword);
&_footer($self,"$keyword Q&A データベース");
	return;
}



sub _header(){
	my $self = shift;
	my $description = shift;
	my $keywords = shift;
	my $title = shift;
	my $keyword = shift;
	my $keyword_encode = &str_encode($keyword);
	
print << "END_OF_HTML";
Content-type: text/html; charset=shift_jis

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html lang="ja">
<head>
<meta http-equiv="Content-Style-Type" content="text/css">
<meta http-equiv="Content-Script-Type" content="text/javascript">
<meta http-equiv="Content-Type" content="text/html; charset=Shift_JIS">
<meta name="Description" content="$description">
<meta name="Keywords" content="$keywords">
<title>$title</title>
<link rel="stylesheet" href="http://waao.jp/base.css" type="text/css" media="screen,tv">
<link rel="alternate" media="handheld" href="http://goo.to/keyword$keyword_encode/" />
</head>
<body>


END_OF_HTML

	return;
}

sub _footer(){
	my $self = shift;
	my $title = shift;

print << "END_OF_HTML";
<div id="footer">
<!-- コピーライト -->
<p>Copyright &copy; $title All Rights Reserved.</p>
<p id="cds">CSS Template <a href="http://www.css-designsample.com/">CSSデザインサンプル</a></p>
<img src="http://ameblo.jp/nsr250-se/" width=0 height=0>
</div><!-- / footer end -->
</div><!-- / wrapper end -->
</body>
</html>
END_OF_HTML
	
	return;
}

sub _img_iframe(){
	my $self = shift;
	my $keyword = shift;
	my $keyword_encode = &str_encode($keyword);
	
if($self->{session}->{_session_id} ne "robot"){
print << "END_OF_HTML";
<br>
<img src="http://goo.to/img/lamp1.gif" width=14 height=11><a href="http://www.google.co.jp/images?hl=ja&source=imghp&biw=908&bih=676&q=$keyword_encode&uss=1" target="_blank">$keywordの画像検索(Google)</a><br>
<iframe src="http://www.google.co.jp/images?hl=ja&source=imghp&biw=908&bih=676&q=$keyword_encode&uss=1" width=550 height=500></iframe>
<img src="http://goo.to/img/lamp1.gif" width=14 height=11><a href="http://search.naver.jp/image?sm=tab_opt&q=$keyword_encode&o_sz=all&o_sf=0&t_size=0" target="_blank">$keywordの画像検索(NAVER)</a><br>
<iframe src="http://search.naver.jp/image?sm=tab_opt&q=$keyword_encode&o_sz=all&o_sf=0&t_size=0" width=550 height=500></iframe>
END_OF_HTML
}
	return;
}

sub _body_best_photo(){
	my $self = shift;
	my $keyword = shift;

print << "END_OF_HTML";
<!-- 写真 -->
<table border="0" width=100%><tr><td BGCOLOR="#555555">
END_OF_HTML

my $sth = $self->{dbi}->prepare(qq{ select url, fullurl,id from photo where keyword = ? and yahoo=1 order by good desc limit 4} );
$sth->execute($keyword);
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<a href="/photoid$row[2]/" title="$keywordの画像"><img src="$row[0]" alt="$keyword写真" width=120 memo="拡大" /></a>
END_OF_HTML
}

print << "END_OF_HTML";
</td></tr></table>
END_OF_HTML
	
	return;
}
sub _body_wiki(){
	my $self = shift;
	my $keyword = shift;
	my $wikipedia =shift;
	
if($wikipedia){
print << "END_OF_HTML";
<h2>$keywordとは</h2>
<font color="#AAAAAA">$wikipedia </font><br>
END_OF_HTML

if($self->{session}->{_session_id} ne "robot"){
print << "END_OF_HTML";
<div align="right"><img src="http://goo.to/img/right07.gif" widht=10 height=10><a href="http://ja.wikipedia.org/wiki/$keyword" target="_blank">wikipediaで検索</a></div><br>
<br>
END_OF_HTML
}
}
	
	return;
}

sub _body_uwasa(){
	my $self = shift;
	my $keyword = shift;
	my $id = shift;
	my $cnt = shift;
	
	$cnt = 10 unless($cnt);

	my $uwasalist;
	my $sth;
	if($cnt == 10){
		$sth = $self->{dbi}->prepare(qq{ select id, keywordid, keyword, keypersonid, keyperson, type, point
	                         from keyword_recomend  where  keywordid = ? and point >= 2 order by point desc limit $cnt});
	}else{
		$sth = $self->{dbi}->prepare(qq{ select id, keywordid, keyword, keypersonid, keyperson, type, point
	                         from keyword_recomend  where  keywordid = ? and point >= -100 order by point desc limit $cnt});
	}
	$sth->execute($id);
	while(my @row = $sth->fetchrow_array) {
		my $str = $row[2];
		$str =~ s/([^0-9A-Za-z_ ])/'%'.unpack('H2',$1)/ge;
		$str =~ s/ /%20/g;
		my $str2 = $row[4];
		$str2 =~ s/([^0-9A-Za-z_ ])/'%'.unpack('H2',$1)/ge;
		$str2 =~ s/ /%20/g;

		$uwasalist.=qq{<table border="0" width=100%><tr><td BGCOLOR="#FFEAEF"><img src="http://goo.to/img/kya-.gif" width=15 height=15><a href="/uwasa$row[0]/">$row[2]</a>は};
		$uwasalist.=qq{<a href="/id$row[3]/">$row[4]</a>};
		$uwasalist.=qq{と恋人<img src="http://goo.to/img/kaochu03.gif" width=72 height=15><br>} if($row[5] eq 1);
		$uwasalist.=qq{と元恋人<img src="http://goo.to/img/kaobye06.gif" width=44 height=12><br>} if($row[5] eq 2);
		$uwasalist.=qq{と夫婦<img src="http://goo.to/img/kaow01.gif" width=53 height=15><br>} if($row[5] eq 3);
		$uwasalist.=qq{と友人<img src="http://goo.to/img/kaobye03.gif" width=35 height=15><br>} if($row[5] eq 4);
		$uwasalist.=qq{が好き<img src="http://goo.to/img/kao-a08.gif" width=15 height=15><br>} if($row[5] eq 5);
		$uwasalist.=qq{が嫌い<img src="http://goo.to/img/kaoikari03.gif" width=60 height=15><br>} if($row[5] eq 6);
		$uwasalist.=qq{とメル友<img src="http://goo.to/img/kaobye01.gif" width=35 height=15><br>} if($row[5] eq 7);
		$uwasalist.=qq{と親子<br>} if($row[5] eq 8);
		$uwasalist.=qq{と兄弟/姉妹<br>} if($row[5] eq 9);
		$uwasalist.=qq{と共演者<br>} if($row[5] eq 10);
		$uwasalist.=qq{と同郷<br>} if($row[5] eq 11);
		$uwasalist.=qq{と同じ事務所<br>} if($row[5] eq 12);
		$uwasalist.=qq{と元夫婦<br>} if($row[5] eq 13);
		$uwasalist.=qq{とライバル<br>} if($row[5] eq 14);
		$uwasalist.=qq{と同年代<br>} if($row[5] eq 15);
		$uwasalist.=qq{<div align=right><font size=1>うわさ度 <font color="red">$row[6]</font>!!</font></div></td></tr></table>};
	}

if($uwasalist){
print << "END_OF_HTML";
<!-- コンテンツ ここから -->
<h2>$keyword うわさ</h2>
$uwasalist
<div align=right><img src="http://goo.to/img/right07.gif" widht=10 height=10><a href="/uwasalist$id/" title="$keywordのうわさ">$keywordのうわさを見る</a></div>
END_OF_HTML
}else{
print << "END_OF_HTML";
<h2>$keyword うわさ</h2>
$keywordのうわさがありません。<br>
$keywordのうわさにご協力ください（<img src="http://goo.to/img/right07.gif" widht=10 height=10><a href="/uwasalist$id/" title="$keywordのうわさ">うわさを投稿</a>）<br>
END_OF_HTML
}
	return;
}

sub _body_shoplist(){
	my $self = shift;
	my $keyword = shift;

	my $keyword_utf8 = $keyword;
	Encode::from_to($keyword_utf8,'cp932','utf8');
	
print << "END_OF_HTML";
<h2>$keyword 関連商品</h2>
<iframe src="http://rcm-jp.amazon.co.jp/e/cm?t=gooto-22&o=9&p=15&l=st1&mode=dvd-jp&search=$keyword_utf8&fc1=000000&lt1=&lc1=3366FF&bg1=FFFFFF&f=ifr" marginwidth="0" marginheight="0" width="468" height="240" border="0" frameborder="0" style="border:none;" scrolling="no"></iframe>
<br>
<iframe src="http://rcm-jp.amazon.co.jp/e/cm?t=gooto-22&o=9&p=15&l=st1&mode=books-jp&search=$keyword_utf8&fc1=000000&lt1=&lc1=3366FF&bg1=FFFFFF&f=ifr" marginwidth="0" marginheight="0" width="468" height="240" border="0" frameborder="0" style="border:none;" scrolling="no"></iframe>
<br>
END_OF_HTML

	return;
}

sub _body_bbs(){
	my $self = shift;
	my $keyword = shift;
	my $id = shift;

my $bbslist;
my $sth = $self->{dbi}->prepare(qq{ select id, bbs, keywordid  from bbs  where keywordid = ? order by id desc limit 10} );
$sth->execute($id);
while(my @row = $sth->fetchrow_array) {
	my $str2 = $keyword;
	$str2 =~ s/([^0-9A-Za-z_ ])/'%'.unpack('H2',$1)/ge;
	$str2 =~ s/ /%20/g;
#	$bbslist .= qq{<a href="/bbs$row[2]/">$keyword</a><br>};
	$bbslist .= $row[1];
}
if($bbslist){
print << "END_OF_HTML";
<h2>$keyword の掲示板</h2>
$bbslist
<div align=right><img src="http://goo.to/img/right07.gif" widht=10 height=10><a href="/bbslist$id/" title="$keywordの掲示板">$keyword掲示板を見る</a></div>
END_OF_HTML
}else{
print << "END_OF_HTML";
<h2>$keyword の掲示板</h2>
$keywordの投稿がありません。<br>
$keywordの書き込みにご協力ください（<img src="http://goo.to/img/right07.gif" widht=10 height=10><a href="/bbslist$id/" title="$keywordの掲示板">投稿</a>）<br>
END_OF_HTML
}

	return;
}

sub _body_qanda(){
	my $self = shift;
	my $keyword = shift;
	my $id  =shift;

print << "END_OF_HTML";
<h2>$keyword のQ&A</h2>
END_OF_HTML

my $sth = $self->{dbi}->prepare(qq{select id, question, bestanswer, url from qanda where keywordid = ? limit 10 } );
$sth->execute( $id );
while(my @row = $sth->fetchrow_array) {
my $answer = substr($row[2], 0, 64);
print << "END_OF_HTML";
<table border="0" width=100%><tr><td BGCOLOR="#FFEAEF">
<img src="http://goo.to/img/kaohatena02.gif" width=50 height=12><img src="http://goo.to/img/kaohatena03.gif" width=44 height=15><br>
<font color="#555555" size=1>
<font color="#0035D5">■質問</font>:$row[1]<br>
<img src="http://goo.to/img/kaow02.gif" width=56 height=12><br>
<font color="#FF0000">■回答</font>:$answer <a href="/qanda$row[0]/" title="$keywordの質問">⇒詳細を見る</a><br>
</font>
</td></tr></table>
END_OF_HTML
}

print << "END_OF_HTML";
<div align=right><img src="http://goo.to/img/right07.gif" widht=10 height=10><a href="/qandalist$id/" title="$keywordのQ&A">$keywordのQ&Aを見る</a></div>
END_OF_HTML

	return;
}

sub _body_photolist(){
	my $self = shift;
	my $keyword = shift;
	
print << "END_OF_HTML";
<h2>$keyword 関連画像</h2>
<br>
<table border="0" width=100%><tr><td BGCOLOR="#555555">
END_OF_HTML

my $imgcnt;
my $sth = $self->{dbi}->prepare(qq{ select url, fullurl, id from photo where keyword = ? order by yahoo desc, good desc} );
$sth->execute($keyword);
while(my @row = $sth->fetchrow_array) {
$imgcnt++;
print << "END_OF_HTML";
<a href="/photoid$row[2]/" title="$keywordの画像"><img src="$row[0]" alt="$keyword写真" width=120 memo="拡大" /></a>
END_OF_HTML
}

unless($imgcnt){
print << "END_OF_HTML";
画像が見つかりませんでした。<br>
END_OF_HTML
&_img_iframe($self,$keyword);
}
print << "END_OF_HTML";
</td></tr></table>
END_OF_HTML
	return;
}

sub _body_pop_person(){
	my $self = shift;
	
print << "END_OF_HTML";
</td></tr></table>
<h2>話題の人物</h2>
END_OF_HTML

my $keywords = $self->{mem}->get("randperson");
my @randpersonlist = split(/:::/,$keywords);
foreach my $persondata (@randpersonlist){
    my @personval = split(/::/,$persondata);
print << "END_OF_HTML";
<a href="http://good.goo.to/?q=$personval[1]">$personval[0]</a> 
END_OF_HTML
}
	return;
}

sub _body_keyword(){
	my $self = shift;
	my $keyword = shift;
	my $keyword_id = shift;

print << "END_OF_HTML";
</td></tr></table>
<h2>$keywordの関連キーワード</h2>
END_OF_HTML

my $sth = $self->{dbi}->prepare(qq{ select id, keyword, cnt from keyword_chainx  where parentid = ? and id != ? order by cnt desc limit 20});
$sth->execute($keyword_id, $keyword_id);
while(my @row = $sth->fetchrow_array) {
		my $str_encode = &str_encode($row[1]);
print << "END_OF_HTML";
<a href="http://good.goo.to/?q=$str_encode">$row[1]</a> 
END_OF_HTML
}
	return;
}

sub _side_bar(){
	my $self = shift;
	my $keyword = shift;

print << "END_OF_HTML";
<div id="sidebar">
<!-- サイドバー ここから -->
<center>
<br>

<OBJECT classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="http://fpdownload.macromedia.com/get/flashplayer/current/swflash.cab" id="Player_73cb6eea-490b-4a1f-be5a-b5d07172fbed"  WIDTH="160px" HEIGHT="400px"> <PARAM NAME="movie" VALUE="http://ws.amazon.co.jp/widgets/q?ServiceVersion=20070822&MarketPlace=JP&ID=V20070822%2FJP%2Fgooto-22%2F8009%2F73cb6eea-490b-4a1f-be5a-b5d07172fbed&Operation=GetDisplayTemplate"><PARAM NAME="quality" VALUE="high"><PARAM NAME="bgcolor" VALUE="#FFFFFF"><PARAM NAME="allowscriptaccess" VALUE="always"><embed src="http://ws.amazon.co.jp/widgets/q?ServiceVersion=20070822&MarketPlace=JP&ID=V20070822%2FJP%2Fgooto-22%2F8009%2F73cb6eea-490b-4a1f-be5a-b5d07172fbed&Operation=GetDisplayTemplate" id="Player_73cb6eea-490b-4a1f-be5a-b5d07172fbed" quality="high" bgcolor="#ffffff" name="Player_73cb6eea-490b-4a1f-be5a-b5d07172fbed" allowscriptaccess="always"  type="application/x-shockwave-flash" align="middle" height="400px" width="160px"></embed></OBJECT> <NOSCRIPT><A HREF="http://ws.amazon.co.jp/widgets/q?ServiceVersion=20070822&MarketPlace=JP&ID=V20070822%2FJP%2Fgooto-22%2F8009%2F73cb6eea-490b-4a1f-be5a-b5d07172fbed&Operation=NoScript">Amazon.co.jp ウィジェット</A></NOSCRIPT><br>
<br>
<script type="text/javascript"><!--
amazon_ad_tag = "gooto-22"; amazon_ad_width = "160"; amazon_ad_height = "600"; amazon_ad_link_target = "new"; amazon_ad_price = "retail";//--></script>
<script type="text/javascript" src="http://www.assoc-amazon.jp/s/ads.js"></script><!-- サイドバー ここまで -->
</div><!-- / sidebar end -->
</center>
<br>
<!-- Begin Yahoo! JAPAN Web Services Attribution Snippet -->
<a href="http://developer.yahoo.co.jp/about">
<img src="http://i.yimg.jp/images/yjdn/yjdn_attbtn1_125_17.gif" title="Webサービス by Yahoo! JAPAN" alt="Web Services by Yahoo! JAPAN" width="125" height="17" border="0" style="margin:15px 15px 15px 15px"></a>
<!-- End Yahoo! JAPAN Web Services Attribution Snippet -->
<br>
wikipedia(SimpleAPI)の情報を利用しています。
<br>
END_OF_HTML

	return;
}

sub _meikan(){
	my $self = shift;
	
	if($self->{cgi}->param('meikan') eq "1"){
		# 男性タレント名鑑
		&_meikan_top($self,1,1);
	}elsif($self->{cgi}->param('meikan') eq "2"){
		# 女性タレント名鑑
		&_meikan_top($self,2,1);
	}elsif($self->{cgi}->param('meikan') eq "3"){
		# グラビア名鑑
		&_meikan_top($self,3,0);
	}elsif($self->{cgi}->param('meikan') eq "4"){
		# お笑い名鑑
		&_meikan_top($self,4,1);
	}elsif($self->{cgi}->param('meikan') eq "6"){
		# 子役名鑑
		&_meikan_top($self,6,0);
	}elsif($self->{cgi}->param('meikan') eq "7"){
		# 落語名鑑
		&_meikan_top($self,7,0);
	}elsif($self->{cgi}->param('meikan') eq "8"){
		# 声優名鑑
		&_meikan_top($self,8,0);
	}elsif($self->{cgi}->param('meikan') eq "9"){
		# アーティスト名鑑
		&_meikan_top($self,9,1);
	}elsif($self->{cgi}->param('meikan') eq "10"){
		# アーティスト名鑑
		&_meikan_top($self,10,1);
	}elsif($self->{cgi}->param('meikan') eq "11"){
		# model名鑑
		&_meikan_top($self,11,0);
	}elsif($self->{cgi}->param('meikan') eq "12"){
		# レースクィーン名鑑
		&_meikan_top($self,12,0);
	}elsif($self->{cgi}->param('meikan') eq "13"){
		# 女子アナ名鑑
		&_meikan_top($self,13,0);
	}elsif($self->{cgi}->param('meikan') eq "14"){
		# AV女優名鑑
		&_meikan_top($self,14,1);
	}elsif($self->{cgi}->param('meikan') eq "15"){
		# ブログ名鑑
		&_meikan_top($self,15,0);
	}elsif($self->{cgi}->param('meikan') eq "50on"){
		# 50音検索
		&_50onsearch($self);
	}else{
#		&_meikan_top($self);
	}
	
	
	return;
}


# 名鑑top
sub _meikan_top(){
	my $self = shift;
	my $meikantype = shift;
	my $flag50 = shift;
	
	my ($meikanname, $sql_str) = &_meikan_name($meikantype);
	
	my $slist;
	if($self->{cgi}->param('p1') eq '50on') {
		$slist = &_slist($self, $meikanname,$meikantype);
	}

&_header($self,"$meikanname名鑑は、$meikannameのプロフィール・画像・動画が検索できる人物検索サービスです。","$meikanname,プロフィール,画像,動画,wiki,wikipedia,データ,情報","$meikanname名鑑",$meikanname);

print << "END_OF_HTML";
<div id="wrapper">
<div id="header">
<h1>$meikanname名鑑</h1>
<p class="logo">
<form action="http://www.google.co.jp/cse" id="cse-search-box" target="_blank">
  <div>
<img src="http://goo.to/img/cn11.gif" width=46 height=52>
「$meikanname名鑑」
    <input type="hidden" name="cx" value="partner-pub-2078370187404934:nqwfgk9rnxl" />
    <input type="hidden" name="ie" value="Shift_JIS" />
    <input type="text" value="$meikanname" name="q" size="31" />
    <input type="submit" name="sa" value="&#x691c;&#x7d22;" />
  </div>
</form>
<script type="text/javascript" src="http://www.google.co.jp/cse/brand?form=cse-search-box&amp;lang=ja"></script> 
</p>
</div><!-- / header end -->

<div id="contents">
<h2>$meikanname名鑑</h2>
END_OF_HTML

$slist
&_top_dsp($self,$sql_str,$meikantype);

print << "END_OF_HTML";
<a href="/person$meikantype-50on/">50音検索</a>
<center>
<a href="http://clickbokin.ekokoro.jp/" target="_blank"><img src="http://www.ekokoro.jp/supporter/br_468_60.jpg" width="468" height="60" border="0" alt="募金サイト イーココロ！"></a>
</center>
<p class="description">$meikanname名鑑は、携帯サイト みんなのモバイル -<a href="http://goo.to/">http://goo.to/</a>- で提供されています。<br><font color="#FF0000">携帯電話からアクセスしてください。</font></p>

<!-- コンテンツ ここまで -->

</div><!-- / contents end -->

END_OF_HTML
&_side_bar($self,$meikanname);
&_footer($self,"$meikanname名鑑");



	return;
}

sub _meikan_name(){
	my $meikantype = shift;
	
	my $meikanname;
	my $sql_str;
	$meikanname->{1} = qq{男性タレント};
	$sql_str->{1} = qq{ person = 3 };
	$meikanname->{2} = qq{女性タレント};
	$sql_str->{2} = qq{ person = 2 };
	$meikanname->{3} = qq{グラビアアイドル};
	$sql_str->{3} = qq{ person = 1 };
	$meikanname->{4} = qq{お笑いタレント};
	$sql_str->{4} = qq{ person = 4 };
	$meikanname->{6} = qq{子役};
	$sql_str->{6} = qq{ person = 6 };
	$meikanname->{7} = qq{落語家};
	$sql_str->{7} = qq{ person = 7 };
	$meikanname->{8} = qq{声優};
	$sql_str->{8} = qq{ person = 8 };
	$meikanname->{9} = qq{男性アーティスト};
	$sql_str->{9} = qq{ artist = 1 and sex = 1 };
	$meikanname->{10} = qq{女性アーティスト};
	$sql_str->{10} = qq{ artist = 1 and sex = 2 };
	$meikanname->{11} = qq{モデル};
	$sql_str->{11} = qq{ model = 1 };
	$meikanname->{12} = qq{レースクィーン};
	$sql_str->{12} = qq{ model = 2 };
	$meikanname->{13} = qq{女子アナウンサー};
	$sql_str->{13} = qq{ ana is not null };
	$meikanname->{14} = qq{AV女優};
	$sql_str->{14} = qq{ av = 1 };
	$meikanname->{15} = qq{ブログ};
	$sql_str->{15} = qq{ blogurl is not null };


	return ($meikanname->{$meikantype}, $sql_str->{$meikantype});
}

sub _slist(){
	my $self = shift;
	my $meikan = shift;
	my $meikantype = shift;
	
	my $slist;
	$slist .= qq{<a href="/person$meikantype-a/" title="$meikan あ行">あ</a> };
	$slist .= qq{<a href="/person$meikantype-i/" title="$meikan い行">い</a> };
	$slist .= qq{<a href="/person$meikantype-u/" title="$meikan う行">う</a> };
	$slist .= qq{<a href="/person$meikantype-e/" title="$meikan え行">え</a> };
	$slist .= qq{<a href="/person$meikantype-o/" title="$meikan お行">お</a> };
	$slist .= qq{<br>};
	$slist .= qq{<a href="/person$meikantype-ka/" title="$meikan か行">か</a> };
	$slist .= qq{<a href="/person$meikantype-ki/" title="$meikan き行">き</a> };
	$slist .= qq{<a href="/person$meikantype-ku/" title="$meikan く行">く</a> };
	$slist .= qq{<a href="/person$meikantype-ke/" title="$meikan け行">け</a> };
	$slist .= qq{<a href="/person$meikantype-ko/" title="$meikan こ行">こ</a> };
	$slist .= qq{<br>};
	$slist .= qq{<a href="/person$meikantype-sa/" title="$meikan さ行">さ</a> };
	$slist .= qq{<a href="/person$meikantype-si/" title="$meikan し行">し</a> };
	$slist .= qq{<a href="/person$meikantype-su/" title="$meikan す行">す</a> };
	$slist .= qq{<a href="/person$meikantype-se/" title="$meikan せ行">せ</a> };
	$slist .= qq{<a href="/person$meikantype-so/" title="$meikan そ行">そ</a> };
	$slist .= qq{<br>};
	$slist .= qq{<a href="/person$meikantype-ta/" title="$meikan た行">た</a> };
	$slist .= qq{<a href="/person$meikantype-ti/" title="$meikan ち行">ち</a> };
	$slist .= qq{<a href="/person$meikantype-tu/" title="$meikan つ行">つ</a> };
	$slist .= qq{<a href="/person$meikantype-te/" title="$meikan て行">て</a> };
	$slist .= qq{<a href="/person$meikantype-to/" title="$meikan と行">と</a> };
	$slist .= qq{<br>};
	$slist .= qq{<a href="/person$meikantype-na/" title="$meikan な行">な</a> };
	$slist .= qq{<a href="/person$meikantype-ni/" title="$meikan に行">に</a> };
	$slist .= qq{<a href="/person$meikantype-nu/" title="$meikan ぬ行">ぬ</a> };
	$slist .= qq{<a href="/person$meikantype-ne/" title="$meikan ね行">ね</a> };
	$slist .= qq{<a href="/person$meikantype-no/" title="$meikan の行">の</a> };
	$slist .= qq{<br>};
	$slist .= qq{<a href="/person$meikantype-ha/" title="$meikan は行">は</a> };
	$slist .= qq{<a href="/person$meikantype-hi/" title="$meikan ま行">ま</a> };
	$slist .= qq{<a href="/person$meikantype-hu/" title="$meikan や行">や</a> };
	$slist .= qq{<a href="/person$meikantype-he/" title="$meikan ら行">ら</a> };
	$slist .= qq{<a href="/person$meikantype-ho/" title="$meikan わ行">わ</a> };
	$slist .= qq{<br>};
	$slist .= qq{<a href="/person$meikantype-ma/" title="$meikan ま行">ま</a> };
	$slist .= qq{<a href="/person$meikantype-mi/" title="$meikan み行">み</a> };
	$slist .= qq{<a href="/person$meikantype-mu/" title="$meikan む行">む</a> };
	$slist .= qq{<a href="/person$meikantype-me/" title="$meikan め行">め</a> };
	$slist .= qq{<a href="/person$meikantype-mo/" title="$meikan も行">も</a> };
	$slist .= qq{<br>};
	$slist .= qq{<a href="/person$meikantype-ya/" title="$meikan や行">や</a> };
	$slist .= qq{<a href="/person$meikantype-yu/" title="$meikan ゆ行">ゆ</a> };
	$slist .= qq{<a href="/person$meikantype-yo/" title="$meikan よ行">よ</a> };
	$slist .= qq{<br>};
	$slist .= qq{<a href="/person$meikantype-ra/" title="$meikan ら行">ら</a> };
	$slist .= qq{<a href="/person$meikantype-ri/" title="$meikan り行">り</a> };
	$slist .= qq{<a href="/person$meikantype-ru/" title="$meikan る行">る</a> };
	$slist .= qq{<a href="/person$meikantype-re/" title="$meikan れ行">れ</a> };
	$slist .= qq{<a href="/person$meikantype-ro/" title="$meikan ろ行">ろ</a> };

	$slist .= qq{<a href="/person$meikantype-wa/" title="$meikan わ行">わ</a> };

	return $slist;
}

sub _top_dsp(){
	my $self = shift;
	my $sql_str = shift;
	my $meikantype = shift;
	my $page = 0;
	$page = $self->{cgi}->param('p1') if($self->{cgi}->param('p1'));
	my $start = 0 + $page * 20;

	my $html;
	my $sth = $self->{dbi}->prepare(qq{ select A.id, inital, A.keyword, url, simplewiki from keyword A, photo B where A.id = B.keywordid and $sql_str order by cnt desc limit $start,20} );
	$sth->execute();
	my $cnt;
	my ($keyword_id, $inital, $keyword, $photourl, $wikipedia);
	while(my @row = $sth->fetchrow_array) {
		($keyword_id, $inital, $keyword, $photourl, $wikipedia) = @row;
		my $keyword_encode = &str_encode($keyword);
		$cnt++;
		# 最初の2つは、画像を表示する
		$html .= qq{<a href="/id$keyword_id/" title="$keyword"><img src="$photourl"  width=95  alt="$keywordの画像">$keyword</a>$wikipedia<br>};
	}
print << "END_OF_HTML";
$html
<img src="http://img.waao.jp/m2028.gif" width=48 height=9><a href="/person$meikantype-p$page/">次へ</a><br>
END_OF_HTML

	return;
}

1;