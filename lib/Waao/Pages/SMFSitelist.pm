package Waao::Pages::SMFSitelist;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Html5;
use Waao::Data;
use Waao::Utility;

sub dispatch(){
	my $self = shift;

	if($self->{cgi}->param('type')){
		&_list($self);
	}elsif($self->{cgi}->param('id')){
		&_site($self);
	}else{
		&_top($self);
	}
	
	return;
}

sub _site(){
	my $self = shift;
	my $id = $self->{cgi}->param('id');

	my $goodstr;
	if($self->{cgi}->param('good')){
		&eva_smf_site($self, $id, 1, "");
		$goodstr = qq{良いサイト};
	}
	if($self->{cgi}->param('bad')){
		&eva_smf_site($self, $id, "", 1);
		$goodstr = qq{悪いサイト};
	}

	my ($name, $url, $title, $keyword, $description, $good, $category_id, $icon, $adult, $official_good);
	my 	$sth = $self->{dbi}->prepare(qq{ select name, url, title, keyword, description, good, category_id, icon, adult, official_good from smf_site where id = ? } );
	$sth->execute($id);
	while(my @row = $sth->fetchrow_array) {
		($name, $url, $title, $keyword, $description, $good, $category_id, $icon, $adult, $official_good) = @row;
	}
	my $category_name;
	my 	$sth = $self->{dbi}->prepare(qq{ select id, name from smf_category where id = ?} );
	$sth->execute($category_id);
	while(my @row = $sth->fetchrow_array) {
		$category_name = $row[1];
	}
	
	my $sitebbslist;
	my 	$sth = $self->{dbi}->prepare(qq{ select id, comment from site_bbs where site_id = ? order by id desc limit 30} );
	$sth->execute($id);
	while(my @row = $sth->fetchrow_array) {
		$sitebbslist .= qq{<li>$row[1]</li>} ;
	}

	my $a = "$name -スマフォMAX (iphone・アンドロイド)- $goodstr";
	$self->{html_title} = qq{$a};
	my $b;
	if($keyword){
		$b = "$keyword";
	}else{
		$b = "スマートフォン,スマフォ,サイト,検索,iphone,アンドロイド";
	}
	$self->{html_keywords} = qq{$b};
	$description =~s/\r//g;
	$description =~s/\n//g;
	my $c = "$description $goodstr";
	$self->{html_description} = qq{$c};
	&html_header($self);

print << "END_OF_HTML";
<div data-role="header"> 
<h1>$name</h1>
</div>
<a href="/">スマフォMAX</a>&gt;<a href="/sitelist/">スマフォサイト検索</a>&gt;<a href="/sitelist-$category_id-0/">$category_name</a>&gt;<strong>$name</strong>
<div data-role="content">
<ul data-role="listview">
<li><img src="/img/E252_20.gif" height="20" class="ui-li-icon"><a href="$url" target="_blank">サイトが正常に見れない方はこちら</a></li>
<iframe src="$url" height=300 width=300></iframe>
<li data-role="list-divider">$nameの口コミ</li>
</ul>
<br>
<ul data-role="listview" data-inset="true">
<li>サイト説明<br>$description</li>
</ul>
</div>
<center>
みんなの評価：<font color="red">$good</font><br>
<a href="/goodsite$id/" data-role="button" data-inline="true">いいね！</a>
<a href="/badsite$id/" data-role="button" data-inline="true">イマイチ</a>
<a href="$url" data-role="button" data-inline="true" target="_blank">$nameのサイトを見る</a>
</center>
<div data-role="fieldcontain">
<form action="/sitebbsregist.html"; method="get">
<label for="textarea">コメント:</label>
<textarea cols="40" rows="8" name="description" id="textarea"></textarea>
<input type="hidden" name="id" value="$id">
<button type="submit" data-transition="fade">口コミ投票</button>
</form>
</div>
$sitebbslist;
END_OF_HTML
	
&html_footer($self);

	return;
}

sub _list(){
	my $self = shift;
	
	my $type = $self->{cgi}->param('type');
	my $page = $self->{cgi}->param('page');
	
	my $category_name;
	my $icon;
	my 	$sth = $self->{dbi}->prepare(qq{ select id, name, icon from smf_category where id = ?} );
	$sth->execute($type);
	while(my @row = $sth->fetchrow_array) {
		$category_name = $row[1];
		$icon = $row[2];
	}

	my $a = "$category_name スマフォ専用サイト検索 -スマフォMAX(iphone・アンドロイド)-";
	$self->{html_title} = qq{$a};
	my $b = "$category_name,スマートフォン,スマフォ,サイト,検索,iphone,アンドロイド";
	$self->{html_keywords} = qq{$b};
	my $c = "$category_nameのスマフォ専用サイト検索。iphone/アンドロイドのスマートフォン専用のサイトだけを検索します";
	$self->{html_description} = qq{$c};
	&html_header($self);
	
	my $liststr;
	my 	$sth = $self->{dbi}->prepare(qq{ select id, name, url, title,description,icon from smf_site where category_id = ? order by good desc limit ?, 30} );
	$sth->execute($type, $page);
	while(my @row = $sth->fetchrow_array) {
		my $icon_url;
		if($row[5] eq 1){
			$icon_url=qq{/img/$icon};
		}else{
			$icon_url=$row[5];
		}
		$liststr .= qq{<li><img src="$icon_url" height="20" class="ui-li-icon"><a href="/site$row[0]/">$row[1]</a></li>};
	}
	unless($liststr){
		$liststr .= qq{<li>$category_name には現在サイトが登録されていません。</li>};
	}
	$liststr .= qq{<li><img src="/img/c5.gif" height="25" class="ui-li-icon"><a href="/regist.html">サイト登録</a></li>};
	
print << "END_OF_HTML";
<div data-role="header"> 
<h1>$category_name</h1>
</div>
<a href="/">スマフォMAX</a>&gt;<a href="/sitelist/">スマフォサイト検索</a>&gt;<strong>$category_name</strong>
<div data-role="content">
<ul data-role="listview">
<li data-role="list-divider">$category_nameスマフォサイト</li>
$liststr
</ul>
</div>
END_OF_HTML
	
&html_footer($self);
	
	return;
}

sub _top(){
	my $self = shift;
	
	my $a = 'スマートフォン専用サイト検索 -スマフォMAX(iphone・アンドロイド)-';
	$self->{html_title} = qq{$a};
	my $b = 'スマートフォン,スマフォ,サイト,検索,iphone,アンドロイド';
	$self->{html_keywords} = qq{$b};
	my $c = 'スマートフォン専用サイト検索。iphone/アンドロイドのスマートフォン専用のサイトだけを検索します';
	$self->{html_description} = qq{$c};
	&html_header($self);
	
	my $categorystr;
	my 	$sth = $self->{dbi}->prepare(qq{ select id, name, cnt,icon from smf_category} );
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$categorystr .= qq{<li><img src="/img/$row[3]" height="20" class="ui-li-icon"><a href="/sitelist-$row[0]-0/">$row[1]</a><span class="ui-li-count">$row[2]</span></li>};
	}
	
print << "END_OF_HTML";
<div data-role="header"> 
<h1>スマフォサイト検索</h1>
</div>
<a href="/">スマフォMAX</a>&gt;スマフォサイト検索
<div data-role="content">
<ul data-role="listview">
<li data-role="list-divider">人気スマフォサイト</li>
$categorystr
</ul>
</div>
END_OF_HTML
	
&html_footer($self);
	
	return;
}
1;