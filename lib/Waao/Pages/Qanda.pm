package Waao::Pages::Qanda;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Data;
use Waao::Html;
use Waao::Utility;

# /keyword/qanda/
# /keyword/qanda/qandaid/
# /keyword/qanda/list/pageno/
sub dispatch(){
	my $self = shift;
	
	my $keyword = $self->{cgi}->param('q');
	my $errsite;
	$errsite = 1 if($keyword eq '%94%FC%94g');
	$errsite = 1 if($keyword eq '美波');
	if($errsite){
		print "Status: 404 Not Found\n\n";
		exit;
		return;
	}
	
	if($self->{cgi}->param('p1') eq 'list'){
		&_list($self);
	}elsif($self->{cgi}->param('p1')){
		&_detail($self);
	}else{
		&_list($self);
	}

	return;
}

sub _detail(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('q');
	my $keyword_encode = &str_encode($keyword);
	my $qandaid = $self->{cgi}->param('p1'); 


	# qanda データ
	my ($datacnt, $qandadata) = &get_qanda($self, $qandaid);

	my ($datacnt, $keyworddata) = &get_keyword($self, $keyword);
	# データが検索できない場合
	unless($datacnt){
		$self->{no_keyword} = 1;
		return;
	}

	# photo データ
	my ($datacnt, $photodata) = &get_photo($self, $keyworddata->{id});

	my $question = substr($qandadata->{question},0,32)."...";
	my $question2 = substr($qandadata->{question},0,64)."...";

	$self->{html_title} = qq{$question -$keywordの知恵袋-};
	$self->{html_keywords} = qq{$keyword,QA,疑問,知恵袋,悩み};
	$self->{html_description} = qq{$question2};

	my $hr = &html_hr($self,1);	
	&html_header($self);

	my $ad = &html_google_ad($self);

if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML
	
}else{# xhmlt chtml

&html_table($self, qq{<h1>$keyword</h1><h2><font size=1>$keywordの</font><font size=1 color="#FF0000">疑問解消</font></h2>}, 1, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

&html_table($self, qq{<img src="http://img.waao.jp/kaohatena03.gif" width=44 height=15>質問}, 0, 0);

print << "END_OF_HTML";
$qandadata->{question}<br>
$hr
END_OF_HTML

&html_table($self, qq{<img src="http://img.waao.jp/kaobye02.gif" width=35 height=15>回答}, 0, 0);

my $pc_url = &html_pc_2_mb($qandadata->{url});
print << "END_OF_HTML";
$qandadata->{bestanswer}<br>
$hr
<font size=1>
更に詳しい内容は、<a href="$pc_url">Y!知恵袋</a>
で確認できます</font>
$hr
END_OF_HTML

&html_keyword_info($self, $keyworddata);

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/qandaplus/">QandAプラス</a>&gt;<a href="/$keyword_encode/qanda/">$keywordの疑問一覧</a>&gt;<strong>$keyword</strong>
<font size=1 color="#E9E9E9">$keywordの疑問解消プラスの㌻は、$keywordのqandaの情報(yahoo!知恵袋API)と独自で集めた口コミによる$keywordに関する質問・悩み・相談をプラスして検索できる$keyword疑問解消㌻です。<br>
$keywordに関する疑問や質問にご協力をお願いします。<br>
<a href="http://developer.yahoo.co.jp/about">Webサービス by Yahoo! JAPAN</a>

END_OF_HTML

} # xhtml

	
	&html_footer($self);
	
	return;
}

sub _list(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('q');
	my $keyword_encode = &str_encode($keyword);

	my $page = $self->{cgi}->param('p1'); 

	my $keywordid = $self->{cgi}->param('p2');

	my ($datacnt, $keyworddata) = &get_keyword($self, $keyword, $keywordid);
	# データが検索できない場合
	unless($datacnt){
		$self->{no_keyword} = 1;
		return;
	}

	$self->{html_title} = qq{$keywordのQandA -みんなの疑問解消プラス-};
	$self->{html_keywords} = qq{$keyword,qanda,疑問,知恵袋,悩み};
	$self->{html_description} = qq{$keywordのQ and A。$keywordに関する疑問解消サイト！};

	my $hr = &html_hr($self,1);	
	&html_header($self);

	my $ad = &html_google_ad($self);

	# ページ制御
	my $limit_s = 0;
	my $limit = 10;
	if( $page ){
		$limit_s = $limit * $page;
	}else{
		$page=1;
	}

	$limit = 30 unless($self->{real_mobile});

	my $next_page = $page + 1;
	my $next_str = qq{<img src="http://img.waao.jp/m2028.gif" width=48 height=9><a href="/$keyword_encode/qanda/">最初</a> };
	$next_str .= qq{<a href="/$keyword_encode/qanda/list/$next_page/">$next_page</a> };
	$next_page++;
	$next_str .= qq{<a href="/$keyword_encode/qanda/list/$next_page/">$next_page</a> };
	$next_page++;
	$next_str .= qq{<a href="/$keyword_encode/qanda/list/$next_page/">$next_page</a> };
	$next_page++;
	$next_str .= qq{<a href="/$keyword_encode/qanda/list/$next_page/">$next_page</a> };
	$next_page++;
	$next_str .= qq{<a href="/$keyword_encode/qanda/list/$next_page/">$next_page</a> };

	my $qanda_str;
	my $sth;
	
	if($keywordid){
		$sth = $self->{dbi}->prepare(qq{ select id, question, bestanswer from qanda where keywordid = ? limit $limit_s, $limit} );
		$sth->execute($keywordid);
	}else{
		$sth = $self->{dbi}->prepare(qq{ select id, question, bestanswer from qanda where keyword = ?  limit $limit_s, $limit} );
		$sth->execute($keyword);
	}

	my $fpage_cnt=0;
	while(my @row = $sth->fetchrow_array) {
		$fpage_cnt++;
		$limit_s++;
		if($limit_s % 2){
			$qanda_str .= qq{<table border=0 bgcolor="#DFFFBF" width="100%"><tr><td>};
		}
		my $question = substr($row[1],0,64)."...";
		$qanda_str .= qq{<font size=1><a href="/$keyword_encode/qanda/$row[0]/">$question</a></font>};
		if($limit_s % 2){
			$qanda_str .= qq{</td></tr></table>};
		}
	}
	if($fpage_cnt eq 0){
	}elsif($fpage_cnt < 3){
#		$keyword_str .= qq{<br><br><center><a href="$ad_yicha_site"><strong>$keyword</strong>サーチ</a></center><br><br>};
	}



my $simplewiki = &simple_wiki_upd($keyworddata->{simplewiki}, 128) if($keyworddata->{simplewiki});


if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
$hr
<a href="/"></a>&gt;<strong>$keyword</strong>
$hr

END_OF_HTML
	
}else{# xhmlt chtml

if($simplewiki){

print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FF9900">$simplewiki </font></marquee>
END_OF_HTML

}

&html_table($self, qq{<h1>$keyword</h1><h2><font size=1>$keywordの</font><font size=1 color="#FF0000">疑問解消</font></h2>}, 1, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
$qanda_str</font>
<br>
$next_str
$hr
END_OF_HTML

&html_keyword_info($self, $keyworddata);

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/$keyword_encode/search/">$keyword</a>&gt;<strong>$keyword</strong>のQ&amp;A疑問一覧<br>
<font size=1 color="#E9E9E9">$keywordの疑問解消プラスの㌻は、$keywordのQ&amp;Aの情報(yahoo!知恵袋API)と独自で集めた口コミによる$keywordに関する質問・悩み・相談をプラスして検索できる$keyword疑問解消㌻です。<br>
$keywordに関する疑問や質問にご協力をお願いします。<br>
<a href="http://developer.yahoo.co.jp/about">Webサービス by Yahoo! JAPAN</a>
</font>
END_OF_HTML

} # xhtml

	
	&html_footer($self);
	
	return;
}

1;