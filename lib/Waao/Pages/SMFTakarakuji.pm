package Waao::Pages::SMFTakarakuji;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Html5;
use Waao::Data;
use Waao::Utility;

sub dispatch(){
	my $self = shift;

	if($self->{cgi}->param('loto6')){
		&_loto6($self);
	}elsif($self->{cgi}->param('loto6id')){
		&_loto6_detail($self);
	}elsif($self->{cgi}->param('miniloto')){
		&_miniloto($self);
	}elsif($self->{cgi}->param('minilotoid')){
		&_miniloto_detail($self);
	}else{
		&_top($self);
	}

	return;
}

sub _miniloto_detail(){
	my $self = shift;
	my $id = $self->{cgi}->param('minilotoid');
	
my $sth = $self->{dbi}->prepare(qq{select * from miniloto where id = ? } );
$sth->execute($id);
while(my @row = $sth->fetchrow_array) {
	my $a = " ミニロト当選番号(miniloto) 第$row[0]回 宝くじMAX";
	$self->{html_title} = qq{$a};
	my $b = "第$row[0]回,宝くじ,ミニロト,miniloto,当選番号,案内,当選";
	$self->{html_keywords} = qq{$b};
	my $c = "第$row[0]回ミニロト(miniloto)の当選番号は、$row[2] $row[3] $row[4] $row[5] $row[6]";
	$self->{html_description} = qq{$c};
	&html_header($self);


	my $minilotolist.=qq{<ul data-role="listview" data-inset="true">};
	$minilotolist.=qq{<li data-role="list-divider">第$row[0]回　($row[1])</li>};
	$minilotolist.=qq{<li><a href="/minilotoid$row[0]/">$row[2] $row[3] $row[4] $row[5] $row[6] <font color="#00FF40">($row[7])</font><br>};

	$minilotolist.=qq{</ul>};


	my $p1 = &price_dsp($row[12]);
	my $p2 = &price_dsp($row[13]);
	my $p3 = &price_dsp($row[14]);
	my $p4 = &price_dsp($row[15]);

print << "END_OF_HTML";
<div data-role="header"> 
<h1>第$row[0]回ミニロト当選番号</h1>
</div>
<a href="/">スマフォMAX</a>&gt;<a href="/takarakuji/">宝くじ当選番号速報</a>&gt;<a href="/miniloto-1/">ミニロト当選番号</a>&gt;第$row[0]回ミニロト当選番号
<iframe frameborder="0" allowtransparency="true" height="60" width="234" marginheight="0" scrolling="no" src="http://ad.jp.ap.valuecommerce.com/servlet/htmlbanner?sid=2780819&pid=880124492" marginwidth="0"><script language="javascript" src="http://ad.jp.ap.valuecommerce.com/servlet/jsbanner?sid=2780819&pid=880124492"></script><noscript><a href="http://ck.jp.ap.valuecommerce.com/servlet/referral?sid=2780819&pid=880124492" target="_blank" ><img src="http://ad.jp.ap.valuecommerce.com/servlet/gifbanner?sid=2780819&pid=880124492" height="60" width="234" border="0"></a></noscript></iframe>
<br>
<br>
<div data-role="content">
<table border="0" width=100%><tr><td BGCOLOR="#FFFFFF">
<center><img src="/img/miniloto.gif" height="50" alt="ミニロト当選番号"></center>
<div class="ui-grid-b">
<div align="right">
	<div class="ui-block-a">1等<br>2等<br>3等<br>4等</div>
	<div class="ui-block-b">$row[8]口<br>$row[9]口<br>$row[10]口<br>$row[11]口</div>
	<div class="ui-block-c">$p1円<br>$p2円<br>$p3円<br>$p4円</div>
</dif>
</div><!-- /grid-a -->

</td></tr></table>
$minilotolist
<br>
</div>
<img src="/img/E426_20.gif" height="20">ミニロト(miniloto)当選番号速報をみんなにも教えてね<img src="/img/E425_20.gif" height="20"><br>
END_OF_HTML
}

	&html_footer($self);
	return;
}

sub _loto6_detail(){
	my $self = shift;
	my $id = $self->{cgi}->param('loto6id');
	
my $sth = $self->{dbi}->prepare(qq{select * from loto6 where id = ? } );
$sth->execute($id);
while(my @row = $sth->fetchrow_array) {
	my $a = " ロト6当選番号(loto6) 第$row[0]回 宝くじMAX";
	$self->{html_title} = qq{$a};
	my $b = "第$row[0]回,宝くじ,ロト6,loto6,当選番号,案内,当選";
	$self->{html_keywords} = qq{$b};
	my $c = "第$row[0]回ロト6(loto6)の当選番号は、$row[2] $row[3] $row[4] $row[5] $row[6]";
	$self->{html_description} = qq{$c};
	&html_header($self);


	my $loto6list.=qq{<ul data-role="listview" data-inset="true">};
	$loto6list.=qq{<li data-role="list-divider">第$row[0]回　($row[1])</li>};
	$loto6list.=qq{<li>$row[2] $row[3] $row[4] $row[5] $row[6] $row[7] <font color="#00FF40">($row[8])</font><br>};
	my $cov = &price_dsp($row[19]);
	if($cov){
		$loto6list.=qq{<font color="red">キャリーオーバー:<br>$cov円</font></li> };
	}else{
		$loto6list.=qq{キャリーオーバー:$cov円</li> };
	}

	$loto6list.=qq{</ul>};


	my $p1 = &price_dsp($row[14]);
	my $p2 = &price_dsp($row[15]);
	my $p3 = &price_dsp($row[16]);
	my $p4 = &price_dsp($row[17]);
	my $p5 = &price_dsp($row[18]);

print << "END_OF_HTML";
<div data-role="header"> 
<h1>第$row[0]回ロト6当選番号</h1>
</div>
<a href="/">スマフォMAX</a>&gt;<a href="/takarakuji/">宝くじ当選番号速報</a>&gt;<a href="/loto6-1/">ロト6当選番号</a>&gt;第$row[0]回ロト6当選番号
<iframe frameborder="0" allowtransparency="true" height="60" width="234" marginheight="0" scrolling="no" src="http://ad.jp.ap.valuecommerce.com/servlet/htmlbanner?sid=2780819&pid=880124492" marginwidth="0"><script language="javascript" src="http://ad.jp.ap.valuecommerce.com/servlet/jsbanner?sid=2780819&pid=880124492"></script><noscript><a href="http://ck.jp.ap.valuecommerce.com/servlet/referral?sid=2780819&pid=880124492" target="_blank" ><img src="http://ad.jp.ap.valuecommerce.com/servlet/gifbanner?sid=2780819&pid=880124492" height="60" width="234" border="0"></a></noscript></iframe>
<br>
<br>
<div data-role="content">
<table border="0" width=100%><tr><td BGCOLOR="#FFFFFF">
<center><img src="/img/loto6.jpg" height="50" alt="ロト6当選番号"></center>
<div class="ui-grid-b">
<div align="right">
	<div class="ui-block-a">1等<br>2等<br>3等<br>4等<br>5等</div>
	<div class="ui-block-b">$row[9]口<br>$row[10]口<br>$row[11]口<br>$row[12]口<br>$row[13]口</div>
	<div class="ui-block-c">$p1円<br>$p2円<br>$p3円<br>$p4円<br>$p5円</div>
</dif>
</div><!-- /grid-a -->

</td></tr></table>
$loto6list
<br>
</div>
<img src="/img/E426_20.gif" height="20">ロト6(loto6)当選番号速報をみんなにも教えてね<img src="/img/E425_20.gif" height="20"><br>
END_OF_HTML
}

	&html_footer($self);
	return;
}


sub _miniloto(){
	my $self = shift;
	my $page = $self->{cgi}->param('page');
	$page=1 unless($page);

	my $minilotolist;
	my $startpage = ($page - 1) * 30;
	my $cnt;
my $sth = $self->{dbi}->prepare(qq{select * from miniloto order by id desc limit $startpage, 30 } );
$sth->execute( );
while(my @row = $sth->fetchrow_array) {
	$cnt++;
	$minilotolist.=qq{<ul data-role="listview" data-inset="true">};
	$minilotolist.=qq{<li data-role="list-divider">第$row[0]回　($row[1])</li>};
	$minilotolist.=qq{<li><a href="/minilotoid$row[0]/">$row[2] $row[3] $row[4] $row[5] $row[6] <font color="#00FF40">($row[7])</font></a></li>};
	$minilotolist.=qq{</ul>};

}
	if($cnt eq 30){
		my $pagenext = $page + 1;
		$minilotolist.=qq{<br><ul data-role="listview">};
		$minilotolist .= qq{<li><img src="/img/E23C_20.gif" class="ui-li-icon"><a href="/miniloto-$pagenext/">次へ</a></li>};
		$minilotolist.=qq{</ul>};
	}

	my $a = " ミニロト当選番号(miniloto) $pageページ目 宝くじMAX";
	$self->{html_title} = qq{$a};
	my $b = "宝くじ,ミニロト,miniloto,当選番号,案内,当選";
	$self->{html_keywords} = qq{$b};
	my $c = "宝くじ、ミニロト(miniloto)の当選番号案内など当選する宝くじ情報サービスです";
	$self->{html_description} = qq{$c};
	&html_header($self);

print << "END_OF_HTML";
<div data-role="header"> 
<h1>ミニロト当選番号</h1>
</div>
<a href="/">スマフォMAX</a>&gt;<a href="/takarakuji/">宝くじ当選番号速報</a>&gt;ミニロト当選番号
<div data-role="content">
<table border="0" width=100%><tr><td BGCOLOR="#FFFFFF">
<center><img src="/img/miniloto.gif" height="50" alt="ミニロト当選番号"></center>
</td></tr></table>
$minilotolist
</div>

<img src="/img/E426_20.gif" height="20">ミニロト(miniloto)当選番号速報をみんなにも教えてね<img src="/img/E425_20.gif" height="20"><br>

END_OF_HTML

	&html_footer($self);

	return;
}


sub _loto6(){
	my $self = shift;
	my $page = $self->{cgi}->param('page');
	$page=1 unless($page);

	my $loto6list;
	my $startpage = ($page - 1) * 30;
	my $cnt;
my $sth = $self->{dbi}->prepare(qq{select * from loto6 order by id desc limit $startpage, 30 } );
$sth->execute( );
while(my @row = $sth->fetchrow_array) {
	$cnt++;
	$loto6list.=qq{<ul data-role="listview" data-inset="true">};
	$loto6list.=qq{<li data-role="list-divider">第$row[0]回　($row[1])</li>};
	$loto6list.=qq{<li><a href="/loto6id$row[0]/">$row[2] $row[3] $row[4] $row[5] $row[6] $row[7] <font color="#00FF40">($row[8])</font><br>};
	my $cov = &price_dsp($row[19]);
	if($cov){
		$loto6list.=qq{<font color="red">キャリーオーバー:<br>$cov円</font></a></li> };
	}else{
		$loto6list.=qq{キャリーオーバー:$cov円</a></li> };
	}

	$loto6list.=qq{</ul>};

}
	if($cnt eq 30){
		my $pagenext = $page + 1;
		$loto6list.=qq{<br><ul data-role="listview">};
		$loto6list .= qq{<li><img src="/img/E23C_20.gif" class="ui-li-icon"><a href="/loto6-$pagenext/">次へ</a></li>};
		$loto6list.=qq{</ul>};
	}

	my $a = " ロト6当選番号(loto6) $pageページ目 宝くじMAX";
	$self->{html_title} = qq{$a};
	my $b = "宝くじ,ロト6,loto6,当選番号,案内,当選";
	$self->{html_keywords} = qq{$b};
	my $c = "宝くじ、ロト6(loto6)の当選番号案内など当選する宝くじ情報サービスです";
	$self->{html_description} = qq{$c};
	&html_header($self);

print << "END_OF_HTML";
<div data-role="header"> 
<h1>ロト6当選番号</h1>
</div>
<a href="/">スマフォMAX</a>&gt;<a href="/takarakuji/">宝くじ当選番号速報</a>&gt;ロト6当選番号
<div data-role="content">
<table border="0" width=100%><tr><td BGCOLOR="#FFFFFF">
<center><img src="/img/loto6.jpg" height="50" alt="ロト6当選番号"></center>
</td></tr></table>
$loto6list
</div>

<img src="/img/E426_20.gif" height="20">ロト6(loto6)当選番号速報をみんなにも教えてね<img src="/img/E425_20.gif" height="20"><br>

END_OF_HTML

	&html_footer($self);

	return;
}

sub _top(){
	my $self = shift;
	
	my $a = "宝くじMAX ロト6/ミニロト当選番号速報";
	$self->{html_title} = qq{$a};
	my $b = "宝くじ,ロト6,ミニロト,当選番号,案内,当選";
	$self->{html_keywords} = qq{$b};
	my $c = "宝くじ、ロト6,ミニロトの当選番号案内など当選する宝くじ情報サービスです";
	$self->{html_description} = qq{$c};

my $loto6list;
my $sth = $self->{dbi}->prepare(qq{select * from loto6 order by id desc limit 5 } );
$sth->execute( );
while(my @row = $sth->fetchrow_array) {

	$loto6list.=qq{<ul data-role="listview" data-inset="true">};
	$loto6list.=qq{<li data-role="list-divider">第$row[0]回　($row[1])</li>};
	$loto6list.=qq{<li><a href="/loto6id$row[0]/">$row[2] $row[3] $row[4] $row[5] $row[6] $row[7] <font color="#00FF40">($row[8])</font><br>};
	my $cov = &price_dsp($row[19]);
	if($cov){
		$loto6list.=qq{<font color="red">キャリーオーバー:<br>$cov円</font></a></li> };
	}else{
		$loto6list.=qq{キャリーオーバー:$cov円</a></li> };
	}

	$loto6list.=qq{</ul>};

}

my $minilotolist;
my $sth = $self->{dbi}->prepare(qq{select * from miniloto order by id desc limit 5 } );
$sth->execute( );
while(my @row = $sth->fetchrow_array) {

	$minilotolist.=qq{<ul data-role="listview" data-inset="true">};
	$minilotolist.=qq{<li data-role="list-divider">第$row[0]回　($row[1])</li>};
	$minilotolist.=qq{<li><a href="/minilotoid$row[0]/">$row[2] $row[3] $row[4] $row[5] $row[6] <font color="#00FF40">($row[7])</font></a></li>};

	$minilotolist.=qq{</ul>};

}

	&html_header($self);

print << "END_OF_HTML";
<a href="/" style="display: block;"><img src="/img/smftakarakuji.jpg" width=100% alt="宝くじ当選番号速報"></a>
<div data-role="header"> 
<h1>宝くじ当選番号速報</h1>
</div>
<a href="/">スマフォMAX</a>&gt;宝くじ当選番号速報
<div data-role="content">
<table border="0" width=100%><tr><td BGCOLOR="#FFFFFF">
<center><img src="/img/loto6.jpg" height="50" alt="ロト6当選番号"></center>
</td></tr></table>
$loto6list
<br>
<ul data-role="listview">
<li><img src="/img/E12F_20.gif" height="20" class="ui-li-icon"><a href="/loto6-1/">ロト6(過去の当選番号)</a></li>
</ul>
<br>
<table border="0" width=100%><tr><td BGCOLOR="#FFFFFF">
<center><img src="/img/miniloto.gif" height="50" alt="ミニロト当選番号"></center>
</td></tr></table>
$minilotolist
<br>
<ul data-role="listview">
<li><img src="/img/E304_20.gif" height="20" class="ui-li-icon"><a href="/miniloto-1/">ミニロト(過去の当選番号)</a></li>
</ul>

</div>

<img src="/img/E426_20.gif" height="20">宝くじ当選番号速報をみんなにも教えてね<img src="/img/E425_20.gif" height="20"><br>

END_OF_HTML

	&html_footer($self);

	return;
}



1;