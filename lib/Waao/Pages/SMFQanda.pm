package Waao::Pages::SMFQanda;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Html5;
use Waao::Data;
use Waao::Utility;

sub dispatch(){
	my $self = shift;
	
	if($self->{cgi}->param('id')){
		&_qanda($self);
	}elsif($self->{cgi}->param('keywordid')){
		&_qandalist($self);
	}
	
	return;
}

sub _qanda(){
	my $self = shift;
	my $qandaid=$self->{cgi}->param('id');

my $keywordid;
my $qandalist;
my $title_q;
my $desc_q;
my $sth = $self->{dbi}->prepare(qq{select id, question, bestanswer, url, keywordid from qanda where id = ?} );
$sth->execute( $qandaid );
while(my @row = $sth->fetchrow_array) {
	$keywordid = $row[4];
	$title_q = substr($row[1], 0, 64);
	$desc_q = substr($row[1], 0, 128);
	$qandalist.=qq{<ul data-role="listview" data-inset="true">};
	$qandalist.=qq{<li><font color="#555555" size=1><font color="#0035D5">■質問</font>:$row[1] </font></li>};
	$qandalist.=qq{<li><font color="#555555" size=1><font color="#FF0000">■回答</font>:$row[2] </font></li>};
	$qandalist.=qq{</ul>};
}
	
	my ($datacnt, $keyworddata) = &get_keyword($self, "", $keywordid);
	my $keyword = $keyworddata->{keyword};
	my $keyword_encode = &str_encode($keyword);

	my $a = "$title_q $qandaid";
	$self->{html_title} = qq{$a};
	my $b = "$keyword,Q&A,質問,疑問,謎";
	$self->{html_keywords} = qq{$b};
	my $c = "$keyword:$desc_q $qandaid";
	$self->{html_description} = qq{$c};
	&html_header($self);

print << "END_OF_HTML";
<div data-role="header"> 
<h1>$keywordのQ&A</h1> 
</div>
<a href="/">トップ</a>&gt;<a href="/person$keywordid/">$keyword</a>&gt;<a href="/qandalist$keywordid/">$keywordのQ&A一覧</a>&gt;$keywordのQ&A

<div data-role="content">
<ul data-role="listview">
<li data-role="list-divider">$keywordのQ&A</li>
</ul>
<br>
$qandalist
<br>
</ul>
<ul data-role="listview">
<li><a href="/qandalist$keyworddata->{id}/"><font size=1>$keywordのQ&A一覧</font></a></li>
<li data-role="list-divider">NAVER トピック検索</li>
<iframe src="http://search.naver.jp/m/bbs?q=$keyword_encode&o_it=qa" height=300 width=300></iframe>
<li data-role="list-divider">Yahoo! 知恵袋</li>
<iframe src="http://chiebukuro.spn.yahoo.co.jp/search/search.php?ei=UTF-8&fr=sfp&p=$keyword_encode" height=300 width=300></iframe>
</ul>
</div>
END_OF_HTML
	
&html_footer($self);

	return;
}

sub _qandalist(){
	my $self = shift;
	my $keywordid = $self->{cgi}->param('keywordid');
	
	my ($datacnt, $keyworddata) = &get_keyword($self, "", $self->{cgi}->param('keywordid'));
	my $keyword = $keyworddata->{keyword};
	my $keyword_encode = &str_encode($keyword);

my $qandalist;
my $sth = $self->{dbi}->prepare(qq{select id, question, bestanswer, url from qanda where keywordid = ? order by id desc} );
$sth->execute( $keywordid );
while(my @row = $sth->fetchrow_array) {
my $answer = substr($row[2], 0, 64);
	$qandalist.=qq{<ul data-role="listview" data-inset="true">};
	$qandalist.=qq{<li><font color="#555555" size=1><font color="#0035D5">■質問</font>:$row[1] </font></li>};
	$qandalist.=qq{<li><a href="/qanda$row[0]/"><font color="#555555" size=1><font color="#FF0000">■回答</font>:$answer ...</font></a></li>};
	$qandalist.=qq{</ul>};
}

	my $a = "$keywordのQ&A一覧 $keywordへの質問$keywordの知りたい事・秘密や謎などお悩み解決";
	$self->{html_title} = qq{$a};
	my $b = "$keyword,Q&A,質問,秘密,謎";
	$self->{html_keywords} = qq{$b};
	my $c = "$keywordのQ&A一覧は、誰もが知りたがっている$keywordの秘密や謎など全ての疑問を解決してくれます";
	$self->{html_description} = qq{$c};
	&html_header($self);

print << "END_OF_HTML";
<div data-role="header"> 
<h1>$keywordのQ&A</h1> 
</div>
<a href="/">トップ</a>&gt;<a href="/person$keywordid/">$keyword</a>&gt;$keywordのQ&A一覧

<div data-role="content">
<ul data-role="listview">
<li data-role="list-divider">$keywordのQ&A一覧</li>
</ul>
<br>
$qandalist
</ul>
<br>
<ul data-role="listview">
<li><a href="/person$keywordid/"><font size=1>$keywordとは</font></a></li>
<li data-role="list-divider">NAVER トピック検索</li>
<iframe src="http://search.naver.jp/m/bbs?q=$keyword_encode&o_it=qa" height=300 width=300></iframe>
<li data-role="list-divider">Yahoo! 知恵袋</li>
<iframe src="http://chiebukuro.spn.yahoo.co.jp/search/search.php?ei=UTF-8&fr=sfp&p=$keyword_encode" height=300 width=300></iframe>
</ul>
</div>

END_OF_HTML
	
&html_footer($self);

	return;
}

1;