package Waao::Pages::Nensyu;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Data;
use Waao::Html;
use Waao::Utility;
use Jcode;
use CGI qw( escape );

# /station/		topページ
# /list-area/station/pref-add1-add2/

sub dispatch(){
	my $self = shift;
	
	if($self->{cgi}->param('q') eq "list-cate"){
		&_salary_category($self);
	}elsif($self->{cgi}->param('p1')){
		&_salary($self);
	}else{
		&_salary_top($self);
	}

	return;
}

sub _salary_top(){
	my $self = shift;

	$self->{html_title} = qq{企業別年収ランキング　みんなのモバイル};
	$self->{html_keywords} = qq{年収,企業,ランキング,転職,就職,仕事,求人,給料};
	$self->{html_description} = qq{企業別の平均年収が検索できます。転職の参考に};

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);
	&html_header($self);
print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">企業別の平均年収が分かる転職の参考に</font></marquee>
<center>
偂企業別年収ランキング
</center>
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

my $sth = $self->{dbi}->prepare(qq{select id,name,money from job_company order by money desc limit 10});
$sth->execute();
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<font color="#FF8000">》</font><a href="/list-cid/nensyu/$row[0]/" title="$row[1]">$row[1]</a><br>
　$row[2]<br>
END_OF_HTML
}

print << "END_OF_HTML";
<img src="http://img.waao.jp/ol03s.gif" width=46 height=52 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"><font color="#FF8000">職種別年収ランキング</font><br>
<br clear="all" />
<font size=1>
END_OF_HTML

my $sth = $self->{dbi}->prepare(qq{select id, name from job_category });
$sth->execute();
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<font color="#FF8000">》</font><a href="/list-cate/nensyu/$row[0]/" title="$row[1]の年収">$row[1]の年収</a><br>
END_OF_HTML
}

print << "END_OF_HTML";
</font>
$hr
<a href="/" accesskey=0 title="みんなのモバイル">トップ</a>&gt;企業別年収ランキング<br>
$hr
<font size=1 color="#E9E9E9">企業別年収ランキングは、独自で集めた情報を公開しています。<br>
公開している企業別年収の情報が最新である保証はしておりません。<br>
企業別年収ランキングは、企業別平均年収の情報が検索できます。転職の参考にどうぞ</font>
$hr
END_OF_HTML

	&_footer($self);

	return;
}

sub _salary_category(){
	my $self = shift;
	
	my $cid = $self->{cgi}->param('p1');
	
	my $category_name;
	my $sth = $self->{dbi}->prepare(qq{select name from job_category where id = ?});
	$sth->execute($cid);
	while(my @row = $sth->fetchrow_array) {
		$category_name = $row[0];
	}

	$self->{html_title} = qq{$category_nameの企業年収ランキング 転職ナビ};
	$self->{html_keywords} = qq{年収,給料,$category_name,職業,仕事,求人};
	$self->{html_description} = qq{$category_nameの企業年収ランキング：$category_nameの平均年収の情報が検索できます};

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);
	&html_header($self);
	
print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">$category_nameの企業年収ランキング棈転職するならまず給料をチェック</font></marquee>
<center>
<font color="#FF0000">【</font>企業年収ランキング<font color="#FF0000">】</font>
</center>
$hr
<center>
$ad
</center>
$hr
<img src="http://img.waao.jp/mb17.gif" width=11 height=12>年収ベスト10<br>
<font size=1>
END_OF_HTML
	
my $sth = $self->{dbi}->prepare(qq{select id,name,money from job_company where job_category_id = ? order by money desc});
$sth->execute($cid);
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<font color="#FF8000">》</font><a href="/list-cid/nensyu/$row[0]/" title="$row[1]">$row[1]</a>($row[2])<br>
END_OF_HTML
}

	
print << "END_OF_HTML";
</font>
$hr
<a href="/" accesskey=0 title="みんなのモバイル">トップ</a>&gt;<a href="/nensyu/" title="年収ランキング">年収ランキング</a>&gt;$category_nameの企業年収ランキング<br>
$hr
<font size=1 color="#E9E9E9">企業別年収ランキングは、独自で集めた情報を公開しています。<br>
公開している企業別年収の情報が最新である保証はしておりません。<br>
$category_nameの企業別年収ランキングは、$category_nameの平均年収の情報が検索できます</font>
$hr
END_OF_HTML

	&_footer($self);
	return;
}

sub _salary(){
	my $self = shift;
	
	my $cid = $self->{cgi}->param('p1');

my ($name,$job_category,$money,$member,$aveage,$avejob,$opdate);
my $sth = $self->{dbi}->prepare(qq{select name,job_category,money,member,aveage,avejob,opdate from job_company where id = ?});
$sth->execute($cid);
while(my @row = $sth->fetchrow_array) {
	($name,$job_category,$money,$member,$aveage,$avejob,$opdate) = @row;
}

	$self->{html_title} = qq{$nameの平均年収は、$money};
	$self->{html_keywords} = qq{$name,年収,給与,給料,職業,仕事,求人,場所};
	$self->{html_description} = qq{$nameの平均年収は、$money};

	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);
	&html_header($self);

	my $yicha_link_hellowwork = &html_yicha_url($self, "$name", 'p');
	
print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">企業年収ランキング棈転職するならまず給料をチェック</font></marquee>
<center>
<font color="#FF0000">【</font>$nameの平均年収<font color="#FF0000">】</font>
</center>
$hr
<center>
$ad
</center>
$hr
<font size=1>
職種：$job_category<br>
平均年収:$money<br>
社員数:$member<br>
平均年齢:$aveage<br>
平均勤務年数:$avejob<br>
更新日:$opdate<br>

<img src="http://img.waao.jp/right06.gif" width=10 height=10><a href="$yicha_link_hellowwork">詳しく見る</a>
</font>
$hr
<a href="/" accesskey=0 title="みんなのモバイル">トップ</a>&gt;<a href="/nensyu/" title="年収ランキング">年収ランキング</a>&gt;$job_categoryの企業年収ランキング<br>
$hr
<font size=1 color="#E9E9E9">企業別年収ランキングは、独自で集めた情報を公開しています。<br>
公開している企業別年収の情報が最新である保証はしておりません。<br>
$nameの平均年収は、$money</font>
$hr
END_OF_HTML

	&_footer($self);
	return;
}

1;
