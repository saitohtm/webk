package Waao::Pages::Nice;
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
	if($self->{cgi}->param('p1')){
		# 詳細ページ
		&_af($self);
	}else{
		&_top($self);
	}
	
	return;
}

sub _top(){
	my $self = shift;

	$self->{html_title} = qq{みんなのイイネ！検索 -お得情報-};
	$self->{html_keywords} = qq{検索,お得,情報};
	$self->{html_description} = qq{最強のイイネ！検索「みんながイイネ！」と思うお得情報が満載};

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
<h1><img src="http://img.waao.jp/iine.gif" width=120 height=28></h1>
<h2><font size=1 color="#FF0000">イイネ！検索プラス</font></h2>
</center>
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

my $sth = $self->{dbi}->prepare(qq{ select no,afname from afseo order by rand() limit 20} );
$sth->execute();
while(my @row = $sth->fetchrow_array) {
	my $name = $row[1];
	if( $name =~/(.*)【(.*)】/){
		$name = $1;
	}

print << "END_OF_HTML";
<font color="#009525">》</font><a href="/list-af/nice/$row[0]/" title="$row[1]">$name</a><br>
END_OF_HTML
}

print << "END_OF_HTML";
$hr
偂<a href="http://waao.jp/list-in/ranking/14/">みんなのランキング</a><br>
<a href="/" accesskey=0 title="みんなのモバイル">トップ</a>&gt;<strong>みんなのイイネ！検索プラス</strong><br>
みんなのイイネ！検索プラスは、<font color="#FF0000">リンクフリー</font>です。<br>
<textarea>
http://waao.jp/nice/
</textarea>
<br>
END_OF_HTML

}
	
	&html_footer($self);

	return;
}

sub _af(){
	my $self = shift;

	my $afno = $self->{cgi}->param('p1');
	my ($afname,$atag,$btag,$magatext,$category);
	my $sth = $self->{dbi}->prepare(qq{ select afname,atag,btag,magatext,category from afseo where no = ?} );
	$sth->execute($afno);
	while(my @row = $sth->fetchrow_array) {
		($afname,$atag,$btag,$magatext,$category) = @row;
	}

			if( $afname =~/(.*)【(.*)】/){
				$afname = $1;
			}

	my $magatextmin = substr($magatext, 0, 100);

	$self->{html_title} = qq{$afname $category};
#	$self->{html_keywords} = qq{検索,お得,情報};
	$self->{html_description} = qq{$afname:$magatextmin};

	my $hr = &html_hr($self,1);	
	&html_header($self);

	my $ad = &html_google_ad($self);

if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML
	
}else{
# xhmlt chtml
&html_table($self, qq{<h1>$afname</h1>}, 1, 1);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

if($atag){
print << "END_OF_HTML";
<center>$atag</center>
END_OF_HTML
}
if($btag){
print << "END_OF_HTML";
<center>$btag</center>
END_OF_HTML
}

print << "END_OF_HTML";
$magatext
END_OF_HTML

my $sth;
if($category){
	$sth = $self->{dbi}->prepare(qq{ select no,afname from afseo where category = ? order by rand() limit 20} );
	$sth->execute($category);
}else{
	$sth = $self->{dbi}->prepare(qq{ select no,afname from afseo order by rand() limit 20} );
	$sth->execute();
}
while(my @row = $sth->fetchrow_array) {
	my $name = $row[1];
	if( $name =~/(.*)【(.*)】/){
		$name = $1;
	}

print << "END_OF_HTML";
<font color="#009525">》</font><a href="/list-af/nice/$row[0]/" title="$row[1]">$name</a><br>
END_OF_HTML
}

print << "END_OF_HTML";
$hr
偂<a href="http://waao.jp/list-in/ranking/14/">みんなのランキング</a><br>
<a href="/" accesskey=0 title="みんなのモバイル">トップ</a>&gt;<a href="/nice/">イイネ！検索プラス</a>&gt;<strong>$afname</strong><br>
$afname $magatext <br>
みんなのイイネ！検索プラスは、<font color="#FF0000">リンクフリー</font>です。<br>
<textarea>
http://waao.jp/nice/
</textarea>
<br>
END_OF_HTML

}
	
	&html_footer($self);

	return;
}


1;