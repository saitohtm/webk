package Waao::Pages::GoGokigen;
use strict;
use base qw(Waao::Pages::Base);
use Waao::Html;
use Waao::Utility;
use Waao::Data;

sub dispatch(){
	my $self = shift;

	if( $self->{cgi}->param('p1') eq 'makeevent'){
		&_makeevent();
	}elsif( $self->{cgi}->param('entryevent')){
		&_entryevent();
	}else{
		&_top();
	}

	return;
}

sub _entryevent(){
	my $self = shift;

	my $title = $self->{cgi}->param('eventTitle');
	&_inputerr($self) unless($title);
	my $message = $self->{cgi}->param('eventExplanation');
	my $nickname = $self->{cgi}->param('eventManager');
	&_inputerr($self) unless($nickname);
	my $mon1 = $self->{cgi}->param('choice1M');
	&_inputerr($self) unless($mon1);
	my $day1 = $self->{cgi}->param('choice1D');
	&_inputerr($self) unless($day1);
	my $choice1 = $self->{cgi}->param('choice1');

if($self->{access_type} eq 4){
# iphone
}elsif($self->{real_mobile}){
# mobile
}else{
# PC
}
	return;
}
sub _makeevent(){
	my $self = shift;
	
if($self->{access_type} eq 4){
# iphone
}elsif($self->{real_mobile}){
# mobile
}else{
# PC
&_pc_header($self);

print << "END_OF_HTML";
   <div id="contents">
      <div id="main">
         <h2>新規出欠イベント作成</h2>

<form id="input_form" method="post" action="/?entryevent=1">
<table width="800" border="0" cellpadding="5" cellspacing="0" class="tbl01 spb10">
	<tr>
		<td valign="middle" align="left" class="sub" width="180">イベント名<br/><font color="red">[必須]</font></td>
		<td valign="middle" align="left">
			<p><input type="text" name="eventTitle" maxlength="40" size="40" value="" /></p>
			<p><font color="#999999">（全角20文字以内）</font></p>
			<p>例：フットサルの練習/○○ツーリングなど</p>
		</td>
	</tr>
	<tr>
		<td valign="middle" align="left" class="sub">メッセージ</td>
		<td valign="middle" align="left">
			<p><input type="text" name="eventExplanation" maxlength="200" size="40" value="" /></p>
			<p><font color="#999999">（全角800文字以内）</font></p>
			<p>例：練習場所／集合場所は○○など</p>
		</td>
	</tr>
	<tr>
		<td valign="middle" align="left" class="sub">あなたのニックネーム<br/><font color="red">[必須]</font></td>
		<td valign="middle" align="left">
			<p><input type="text" name="eventManager" maxlength="10" value="" />&nbsp;さん</p>
			<p><font color="#999999">（全角5文字以内）</font></p>
			<p class="size12">本名などの個人情報の入力はお控えください。</p>
		</td>
	</tr>
	<tr>
		<td valign="middle" align="left" class="sub">日程の候補<br/><font color="red">[必須]</font></td>
		<td valign="middle" align="left">
			１．
			<select name="choice1M"><option value="">--</option><option value="1">1</option><option value="2">2</option><option value="3">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option><option value="8">8</option><option value="9">9</option><option value="10">10</option><option value="11">11</option><option value="12">12</option></select>月
			<select name="choice1D"><option value="">--</option><option value="1">1</option><option value="2">2</option><option value="3">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option><option value="8">8</option><option value="9">9</option><option value="10">10</option><option value="11">11</option><option value="12">12</option><option value="13">13</option><option value="14">14</option><option value="15">15</option><option value="16">16</option><option value="17">17</option><option value="18">18</option><option value="19">19</option><option value="20">20</option><option value="21">21</option><option value="22">22</option><option value="23">23</option><option value="24">24</option><option value="25">25</option><option value="26">26</option><option value="27">27</option><option value="28">28</option><option value="29">29</option><option value="30">30</option><option value="31">31</option></select>日
			<input type="text" name="choice1" maxlength="5" size="7" value="" />〜
			<br />
			２．
			<select name="choice2M"><option value="">--</option><option value="1">1</option><option value="2">2</option><option value="3">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option><option value="8">8</option><option value="9">9</option><option value="10">10</option><option value="11">11</option><option value="12">12</option></select>月
			<select name="choice2D"><option value="">--</option><option value="1">1</option><option value="2">2</option><option value="3">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option><option value="8">8</option><option value="9">9</option><option value="10">10</option><option value="11">11</option><option value="12">12</option><option value="13">13</option><option value="14">14</option><option value="15">15</option><option value="16">16</option><option value="17">17</option><option value="18">18</option><option value="19">19</option><option value="20">20</option><option value="21">21</option><option value="22">22</option><option value="23">23</option><option value="24">24</option><option value="25">25</option><option value="26">26</option><option value="27">27</option><option value="28">28</option><option value="29">29</option><option value="30">30</option><option value="31">31</option></select>日
			<input type="text" name="choice2" maxlength="5" size="7" value="" />〜
			<br />
			３．
			<select name="choice3M"><option value="">--</option><option value="1">1</option><option value="2">2</option><option value="3">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option><option value="8">8</option><option value="9">9</option><option value="10">10</option><option value="11">11</option><option value="12">12</option></select>月
			<select name="choice3D"><option value="">--</option><option value="1">1</option><option value="2">2</option><option value="3">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option><option value="8">8</option><option value="9">9</option><option value="10">10</option><option value="11">11</option><option value="12">12</option><option value="13">13</option><option value="14">14</option><option value="15">15</option><option value="16">16</option><option value="17">17</option><option value="18">18</option><option value="19">19</option><option value="20">20</option><option value="21">21</option><option value="22">22</option><option value="23">23</option><option value="24">24</option><option value="25">25</option><option value="26">26</option><option value="27">27</option><option value="28">28</option><option value="29">29</option><option value="30">30</option><option value="31">31</option></select>日
			<input type="text" name="choice3" maxlength="5" size="7" value="" />〜
			<br />
			４．
			<select name="choice4M"><option value="">--</option><option value="1">1</option><option value="2">2</option><option value="3">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option><option value="8">8</option><option value="9">9</option><option value="10">10</option><option value="11">11</option><option value="12">12</option></select>月
			<select name="choice4D"><option value="">--</option><option value="1">1</option><option value="2">2</option><option value="3">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option><option value="8">8</option><option value="9">9</option><option value="10">10</option><option value="11">11</option><option value="12">12</option><option value="13">13</option><option value="14">14</option><option value="15">15</option><option value="16">16</option><option value="17">17</option><option value="18">18</option><option value="19">19</option><option value="20">20</option><option value="21">21</option><option value="22">22</option><option value="23">23</option><option value="24">24</option><option value="25">25</option><option value="26">26</option><option value="27">27</option><option value="28">28</option><option value="29">29</option><option value="30">30</option><option value="31">31</option></select>日
			<input type="text" name="choice4" maxlength="5" size="7" value="" />〜
			<br />
			５．
			<select name="choice5M"><option value="">--</option><option value="1">1</option><option value="2">2</option><option value="3">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option><option value="8">8</option><option value="9">9</option><option value="10">10</option><option value="11">11</option><option value="12">12</option></select>月
			<select name="choice5D"><option value="">--</option><option value="1">1</option><option value="2">2</option><option value="3">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option><option value="8">8</option><option value="9">9</option><option value="10">10</option><option value="11">11</option><option value="12">12</option><option value="13">13</option><option value="14">14</option><option value="15">15</option><option value="16">16</option><option value="17">17</option><option value="18">18</option><option value="19">19</option><option value="20">20</option><option value="21">21</option><option value="22">22</option><option value="23">23</option><option value="24">24</option><option value="25">25</option><option value="26">26</option><option value="27">27</option><option value="28">28</option><option value="29">29</option><option value="30">30</option><option value="31">31</option></select>日
			<input type="text" name="choice5" maxlength="5" size="7" value="" />〜
			<br />
			<p class="size12">開始時間の入力は必須ではありません。</p>
		</td>
	</tr>
</table>
<div align="center">
	<input type="image" name="" src="bn_make.png" border="0" />
</div>
</form><!-- /column5D -->
<br>
<br>

         <h2>使い方</h2>
<p>
飲み会・同窓会・イベント・会議・打ち合わせ... これらを設定する際に必ず必要になってくる、「全員の日程調整作業」を簡単スムーズに行う事ができるお手軽便利ツールです。特徴は以下のとおり<br>
<br>
面倒なユーザ登録・ログインが一切不要 <br>
面倒な参加者メールアドレスの登録作業も不要<br> 
皆の日程を調整する機能のみに特化 <br>
携帯からも利用可能 <br>
その他情報連絡はメール等の別手段で <br>
今までは口頭伝達や何回ものメールのやりとりで直接行っていたこの面倒な作業を、調整さんでラクチンにこなしてしまいしょう♪<br>
</p>

<center>
<a href="/makeevent/">イベント新規作成</a>
</center>
<hr color="#009525">
<a href="/">TOP</a><br>
      </div><!-- main end -->

END_OF_HTML

&_pc_sidemenu($self);

&_pc_footer($self);


}

return;
}

sub _top(){
	my $self = shift;
	
if($self->{access_type} eq 4){
# iphone
}elsif($self->{real_mobile}){
# mobile
}else{
# PC

&_pc_header($self);

print << "END_OF_HTML";
   <div id="contents">
      <div id="main">
         <h2>メニュー</h2>

<a href="/makeevent/">イベント新規作成</a> <a href="/">利用規約</a>
<br>
<br>

         <h2>使い方</h2>
<p>
飲み会・同窓会・イベント・会議・打ち合わせ... これらを設定する際に必ず必要になってくる、「全員の日程調整作業」を簡単スムーズに行う事ができるお手軽便利ツールです。特徴は以下のとおり<br>
<br>
面倒なユーザ登録・ログインが一切不要 <br>
面倒な参加者メールアドレスの登録作業も不要<br> 
皆の日程を調整する機能のみに特化 <br>
携帯からも利用可能 <br>
その他情報連絡はメール等の別手段で <br>
今までは口頭伝達や何回ものメールのやりとりで直接行っていたこの面倒な作業を、調整さんでラクチンにこなしてしまいしょう♪<br>
</p>

<center>
<a href="/makeevent/">イベント新規作成</a>
</center>
<hr color="#009525">
<a href="/">TOP</a><br>
      </div><!-- main end -->

END_OF_HTML

&_pc_sidemenu($self);

&_pc_footer($self);



}

	return;
}

sub _pc_header(){
	my $self = shift;

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ja" lang="ja">
<head>
<meta http-equiv="content-type" content="text/html; charset=UTF-8" />
<meta http-equiv="Content-style-Type" content="text/css" />
<link rel="stylesheet" href="base.css" type="text/css" />
<title>調整くん！みんなの出欠確認！ - go.gokigen.com -</title>
</head>
<body>
<script type="text/javascript" src="http://shots.snap.com/snap_shots.js?ap=1&amp;key=d708678ff333c1147a0e7fc90cbc3cd2&amp;sb=1&amp;th=orange&amp;cl=0&amp;si=0&amp;po=0&amp;df=0&amp;oi=0&amp;lang=en-us&amp;domain=admin.goo.to/&amp;as=1"></script>

<div id="top">
   <div id="header">
      <h1><a href="index.html"><img src="logo.png"></a></h1>
      <div id="pr">
         <p>　　　　　　　　　　　　　　　　　　　　　　みんなの出欠確認は、イベントの出欠管理を調整!!</p>
      </div>
      <div id="menu" alight=right>
         <img src="http://img.waao.jp/3ca.PNG">
         <img src="http://img.waao.jp/iphone.PNG">
      </div><!-- menu end -->
   </div><!-- header end -->

END_OF_HTML

	return;
}
sub _pc_sidemenu(){
	my $self = shift;
	
print << "END_OF_HTML";
      <div id="sub">
         <div class="section">
<script type="text/javascript"><!--
google_ad_client = "pub-2078370187404934";
/* 200x200, 作成済み 10/04/08 */
google_ad_slot = "6955074634";
google_ad_width = 200;
google_ad_height = 200;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
         </div>
         <div class="section">
            <h2>バージョン</h2>
            version β 1.0
            
<br>
<center>
<script language='JavaScript' src='http://bnr.dff.jp/001click.js'> </script>
</center>
         </div><!-- section end -->
      </div><!-- sub end -->
END_OF_HTML

	return;
}

sub _pc_footer($self){
	my $self = shift;
	
print << "END_OF_HTML";
      <div id="totop">
         <p><a href="#top">ページのトップへ戻る</a></p>
      </div><!-- totop end -->
   </div><!-- contents end -->
   <div id="footMenu">
      <ul>
         <li><a href="/">ホーム</a></li>
      </ul>
   </div><!-- footerMenu end -->
   <div id="footer">
      <address>Copyright &copy; 2010 みんなの出欠確認！調整くん One All Rights Reserved.</address>
   </div><!-- footer end -->
</div><!-- top end -->
</body>
</html>
END_OF_HTML

	return;
}

sub _inputerr(){
	my $self = shift;
	
	
if($self->{access_type} eq 4){
# iphone
}elsif($self->{real_mobile}){
# mobile
}else{
# PC
&_pc_header($self);
print << "END_OF_HTML";
   <div id="contents">
      <div id="main">
         <h2>入力エラー</h2>
入力エラーがあります<br>
必須項目は必ず入力してください<br>
	  </div>
	</div>
END_OF_HTML
	
&_pc_sidemenu($self);

&_pc_footer($self);

	return;
}
print << "END_OF_HTML";
<html>
<body>
入力エラーがあります<br>
必須項目は必ず入力してください<br>
</body>
</html>
END_OF_HTML

	return;
}
1;