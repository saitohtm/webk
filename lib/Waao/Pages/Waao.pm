package Waao::Pages::Waao;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Data;
use Waao::Html;
use Waao::Utility;

# /waao/
# /list-waao/waao/id/
# /list-waao/waao/list/pageno/
sub dispatch(){
	my $self = shift;
	
	if($self->{cgi}->param('p1') eq 'list'){
		&_list($self);
	}elsif($self->{cgi}->param('p1')){
		&_detail($self);
	}else{
		&_top($self);
	}

	return;
}

sub _top(){
	my $self = shift;

	$self->{html_title} = qq{We Are All One プロジェクト -みんなのモバイル-};
	$self->{html_keywords} = qq{waao,we are all one};
	$self->{html_description} = qq{We Are All One プロジェクト : モバイルから始まる};

	my $waao_str;
	# 新着3件
	my $sth = $self->{dbi}->prepare(qq{ select  id, title from waao order by id desc  limit 3} );
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$waao_str .= qq{<a href="/list-waao/waao/$row[0]/">$row[0]</a><br>};
	}

	my $hr = &html_hr($self,1);	
	&html_header($self);

if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML
	
}else{# xhmlt chtml

print << "END_OF_HTML";
<center>
<img src="http://img.waao.jp/logo.jpg" alt="waao.jp"><br>
<h2><font size=1>We Are All One プロジェクト</font></h2>
</center>
$hr
$waao_str
<a href="/list-waao/waao/list/">一覧でみる</a>
$hr
<a href="/" accesskey=9>トップ</a>&gt<strong>We Are All One プロジェクト</strong><br>
<font size=1 color="#AAAAAA">We Are All One プロジェクトとは</a>
</font>
END_OF_HTML

}

	&html_footer($self);

	return;
}


sub _detail(){
	my $self = shift;
	my $waaoid = $self->{cgi}->param('p1'); 

	my $waaodata;
	my $sth = $self->{dbi}->prepare(qq{ select id, title, waaotxt, keywords, cnt, insdate from waao where id = ? limit 1} );
	$sth->execute($waaoid);
	while(my @row = $sth->fetchrow_array) {
		($waaodata->{title},$waaodata->{waaotxt},$waaodata->{keywords},$waaodata->{cnt},$waaodata->{insdate}) = @row;
	}

	$self->{html_title} = qq{$waaodata->{title} -みんなのモバイル-};
	$self->{html_keywords} = qq{$waaodata->{keywords}};
	$self->{html_description} = qq{We Are All One プロジェクト : $waaodata->{title} };

	my $hr = &html_hr($self,1);	
	&html_header($self);

	my $ad = &html_google_ad($self);


if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML
	
}else{# xhmlt chtml

print << "END_OF_HTML";
<center>
<img src="http://img.waao.jp/logo.jpg" alt="waao.jp"><br>
<h2><font size=1>We Are All One プロジェクト</font></h2>
</center>
$hr
$waaodata->{title}
$hr
$waaodata->{waaotxt}
<div align=right>$waaodata->{insdate}</div>
$waaodata->{cnt} waao!<br>
$hr
<a href="/" accesskey=9>トップ</a>&gt<a href="/waao/">We Are All One</a>&gt<strong>$waaodata->{title}</strong><br>
<font size=1 color="#AAAAAA">We Are All One プロジェクトとは</a>
END_OF_HTML

} # xhtml
	
	&html_footer($self);
	
	return;
}

sub _list(){
	my $self = shift;
	my $page = $self->{cgi}->param('p1'); 

	$self->{html_title} = qq{We Are All One プロジェクト -みんなのモバイル-};
	$self->{html_keywords} = qq{waao,we are all one};
	$self->{html_description} = qq{We Are All One プロジェクト : モバイルから始まる};

	my $hr = &html_hr($self,1);	
	&html_header($self);

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
	my $next_str = qq{<img src="http://img.waao.jp/m2028.gif" ><a href="/list-waao/waao/list/">最初</a> };
	$next_str .= qq{<a href="/list-waao/waao/list/$next_page/">$next_page</a> };
	$next_page++;
	$next_str .= qq{<a href="/list-waao/waao/list/$next_page/">$next_page</a> };
	$next_page++;
	$next_str .= qq{<a href="/list-waao/waao/list/$next_page/">$next_page</a> };
	$next_page++;
	$next_str .= qq{<a href="/list-waao/waao/list/$next_page/">$next_page</a> };
	$next_page++;
	$next_str .= qq{<a href="/list-waao/waao/list/$next_page/">$next_page</a> };

	my $waao_str;
	my $sth;
	$sth = $self->{dbi}->prepare(qq{ select id, title from waao order by id desc limit $limit_s, $limit} );
	$sth->execute();

	while(my @row = $sth->fetchrow_array) {
		$waao_str .= qq{<a href="/list-waao/waao/$row[0]/">$row[0]</a><br>};
	}


if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML
	
}else{# xhmlt chtml

print << "END_OF_HTML";
<center>
<img src="http://img.waao.jp/logo.jpg" alt="waao.jp"><br>
<h2><font size=1>We Are All One プロジェクト</font></h2>
</center>
$hr
$waao_str
<br>
$next_str
$hr
$hr
<a href="/" accesskey=9>トップ</a>&gt<a href="/waao/">We Are All One</a>&gt<strong>プロジェクト一覧</strong><br>
<font size=1 color="#AAAAAA">We Are All One プロジェクトとは</a>
END_OF_HTML

} # xhtml

	
	&html_footer($self);
	
	return;
}

1;