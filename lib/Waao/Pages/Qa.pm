package Waao::Pages::Qa;
use strict;
use base qw(Waao::Pages::Base);
use Waao::Html;
use Waao::Data;
use Waao::Utility;

# /meikan/
# /keyword/meikan/keyword_id/
# /list-50on/meikan/50on/page/

sub dispatch(){
	my $self = shift;

	#ドメイン設定
	if($self->{cgi}->param('q') eq 'list-page'){
		&_page($self);
	}elsif($self->{cgi}->param('p1')){
		# 詳細ページ
		&_qa($self);
	}else{
		&_top($self);
	}
	
	return;
}

sub _top(){
	my $self = shift;

	$self->{html_title} = qq{みんなのお悩み解決検索 -知恵袋-};
	$self->{html_keywords} = qq{悩み,解決,コミュニティ,お得,知恵袋};
	$self->{html_description} = qq{みんなのお悩み解決検索なら、どんな質問でもみんなが答えてくれます};

	my $hr = &html_hr($self,1);	
	&html_header($self);

	my $ad = &html_google_ad($self);

if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML
	
}else{
# xhmlt chtml

print << "END_OF_HTML";
<center>
<h2><font size=1 color="#FF0000">みんなの知恵袋プラス</font></h2>
</center>
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

my $sth = $self->{dbi}->prepare(qq{  select id, question, bestanswer, url from qanda order by rand() limit 20} );
$sth->execute();
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<font color="#009525">》</font><a href="/list-qa/qa/$row[0]/" title="$row[1]">$row[1]</a><br>
END_OF_HTML
}

print << "END_OF_HTML";
<img src="http://img.waao.jp/m2028.gif" width=48 height=9><a href="http://waao.jp/list-page/qa/0/">次へ</a><br>
$hr
偂<a href="http://waao.jp/list-in/ranking/14/">みんなのランキング</a><br>
<a href="/" accesskey=0 title="みんなのモバイル">トップ</a>&gt;<strong>みんなの悩み解決</strong><br>
みんなの悩み解決プラスは、<font color="#FF0000">リンクフリー</font>です。<br>
<textarea>
http://waao.jp/qa/
</textarea>
<br>
END_OF_HTML

}
	
	&html_footer($self);

	return;
}

sub _page(){
	my $self = shift;
	my $pageno = $self->{cgi}->param('p1');

	$self->{html_title} = qq{話題の悩み一覧$pagenoページ -知恵袋-};
	$self->{html_keywords} = qq{悩み,解決,検索,情報};
	$self->{html_description} = qq{話題の悩み！同じ悩みを持っている人もたくさんいるよ};

	my $hr = &html_hr($self,1);	
	&html_header($self);

	my $ad = &html_google_ad($self);

if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML
	
}else{
# xhmlt chtml

print << "END_OF_HTML";
<center>
<h2><font size=1 color="#FF0000">悩み解決$pageno㌻</font></h2>
</center>
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

my $start = $pageno * 20;
my $sth = $self->{dbi}->prepare(qq{ select id, question, bestanswer, url from qanda order by id limit $start,20} );
$sth->execute();
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<font color="#009525">》</font><a href="/list-qa/qa/$row[0]/" title="$row[1]">$row[1]</a><br>
END_OF_HTML
}

$pageno++;
print << "END_OF_HTML";
<img src="http://img.waao.jp/m2028.gif" width=48 height=9><a href="http://waao.jp/list-page/qa/$pageno/">次へ</a><br>
$hr
偂<a href="http://waao.jp/list-in/ranking/14/">みんなのランキング</a><br>
<a href="/" accesskey=0 title="みんなのモバイル">トップ</a>&gt;<strong>みんなの悩み解決</strong><br>
みんなの悩み解決は、<font color="#FF0000">リンクフリー</font>です。<br>
<textarea>
http://waao.jp/qa/
</textarea>
<br>
END_OF_HTML

}
	
	&html_footer($self);

	return;
}
sub _qa(){
	my $self = shift;

	my $afno = $self->{cgi}->param('p1');
	my $id = $afno;
	my ($question,$bestanswer,$url);
	my $sth = $self->{dbi}->prepare(qq{ select question, bestanswer, url from qanda where id = ?} );
	$sth->execute($afno);
	while(my @row = $sth->fetchrow_array) {
		($question,$bestanswer,$url) = @row;
	}


	my $magatextmin = substr($question, 0, 100);
	my $magatextmin2 = substr($bestanswer, 0, 100);

	$self->{html_title} = qq{$magatextmin};
#	$self->{html_keywords} = qq{検索,お得,情報};
	$self->{html_description} = qq{$magatextmin2};

	my $hr = &html_hr($self,1);	
	&html_header($self);

	my $ad = &html_google_ad($self);

if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML
	
}else{
# xhmlt chtml

&html_table($self, qq{ソ問<h1>$question</h1>}, 1, 0);
print << "END_OF_HTML";
$hr
ベストアンサー<br>
$bestanswer<br>
$hr
END_OF_HTML

my $sth;
	$sth = $self->{dbi}->prepare(qq{ select id, question from qanda where id > ? limit 20} );
	$sth->execute($id);
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<font color="#009525">》</font><a href="/list-qa/qa/$row[0]/" title="$row[1]">$row[1]</a><br>
END_OF_HTML
}

my $filepath = &_make_file_path($id);
print << "END_OF_HTML";
$hr
<a href="http://qa.goo.to$filepath" title="$question">$question焚祝澎爪版</a><br>
偂<a href="http://waao.jp/list-in/ranking/14/">みんなのランキング</a><br>
<a href="/" accesskey=0 title="みんなのモバイル">トップ</a>&gt;<a href="/qa/">みんなの悩み解決</a>&gt;<strong>$question</strong><br>
$bestanswer<br>
みんなのイイネ！検索プラスは、<font color="#FF0000">リンクフリー</font>です。<br>
<textarea>
http://waao.jp/qa/
</textarea>
<br>
END_OF_HTML

}
	
	&html_footer($self);

	return;
}
sub _make_file_path(){
	my $keyword_id = shift;
	my $type = shift;

	my $dir = int($keyword_id / 1000);
	my $file = $keyword_id % 1000;
		
	my $filepath = qq{/$dir/$keyword_id/};
	$filepath = qq{/$dir/$keyword_id/$type/} if($type);
	
	return $filepath;
}

1;