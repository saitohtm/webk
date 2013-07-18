package Waao::Pages::SMFApp;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Html5;
use Waao::Data;
use Waao::Utility;

sub dispatch(){
	my $self = shift;
	
	if($self->{cgi}->param('id')){
		&_app($self);
	}elsif($self->{cgi}->param('q')){
		
	}elsif($self->{cgi}->param('page')){
		&_list();
	}elsif($self->{cgi}->param('iphone')){
		&_iphone_top($self);
	}elsif($self->{cgi}->param('android')){
		&_android_top($self);
	}else{
		&_top($self);
	}
	
	return;
}

sub _list(){
	my $self = shift;

	my $smf_str = qq{アイフォン};
	my $smf_str2 = qq{iphone};
	
	if($self->{cgi}->param('android')){
		$smf_str = qq{アンドロイド};
		$smf_str2 = qq{android};
	}


	my $a = "新着 $smf_strアプリ($smf_str2)";
	$self->{html_title} = qq{$a};
	my $b = "アプリ,アンドロイド,android,無料,セール,人気,検索,スマフォ,アンドロイドアプリ";
	$self->{html_keywords} = qq{$b};
	my $c = "iphoneアプリ検索|アンドロイドの人気アプリ、セール中の無料アプリが検索できるandroidアプリ検索サイトです。";
	$self->{html_description} = qq{$c};
	&html_header($self);

	# 新着アプリ
	my $newapp_list;
	my 	$sth = $self->{dbi}->prepare(qq{ select id, img, appname from app where device >= 4 order by id desc limit 3} );
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$newapp_list .= qq{<li><img src="$row[1]" height="20" class="ui-li-icon" alt="アンドロイドアプリ $row[2]"><a href="/appid$row[0]/">$row[2]</a></li>};
	}
print << "END_OF_HTML";
<div data-role="header"> 
<h1>アンドロイドアプリ検索(android)</h1> 
</div>
<a href="/">スマフォMAX</a>&gt;<a href="/app/">スマフォアプリ検索</a>&gt;<strong>androidアプリ検索</strong>

<div data-role="content">
<ul data-role="listview">
<li data-role="list-divider">新着アンドロイドアプリ</li>
$newapp_list
<li data-role="list-divider">アンドロイドアプリ一覧</li>
$cate_list

<li data-role="list-divider">androidアプリ検索サイト</li>
</ul>
</div>
<img src="/img/E00F_20.gif" height="20">アンドロイドアプリ検索は、アンドロイド(android)アプリをスマフォで検索できるアンドロイドアプリ検索サービスです。<img src="/img/E32F_20.gif" height="20">
<br>
END_OF_HTML


	&html_footer($self);

	return;
}

sub _app(){
	my $self = shift;

	my $app_id = $self->{cgi}->param('id');

	my ($img, $dl_url, $appname, $ex_str, $device, $category, $developer, $price, $sale, $cnt);
	my 	$sth = $self->{dbi}->prepare(qq{ select img, dl_url, appname, ex_str, device, category, developer, price, sale, cnt from app where id = ? } );
	$sth->execute($app_id);
	while(my @row = $sth->fetchrow_array) {
		($img, $dl_url, $appname, $ex_str, $device, $category, $developer, $price, $sale, $cnt) = @row;
	}
	
	# カテゴリ名
	my $category_name;
	my 	$sth = $self->{dbi}->prepare(qq{ select id, name, game, key_value, img, cnt from app_category where id = ? } );
	$sth->execute($category);
	while(my @row = $sth->fetchrow_array) {
		$category_name = $row[1];
	}

	my $smf_str = qq{アイフォン};
	my $smf_str2 = qq{iphone};
	
	if($device >= 4){
		$smf_str = qq{アンドロイド};
		$smf_str2 = qq{android};
	}
	my $free_str = qq{無料アプリ} if($price == 0);
	my $mini_ex = substr($ex_str,0,64);
	my $a = "$appname($smf_strアプリ) $category$free_str$smf_strアプリ検索";
	$self->{html_title} = qq{$a};
	my $b = "$appname, $category,アプリ,$smf_str,$smf_str2,無料,セール,人気,検索,スマフォ,$smf_strアプリ";
	$self->{html_keywords} = qq{$b};
	my $c = "$appnameは、$categoryの$smf_strアプリ。$mini_ex ";
	$self->{html_description} = qq{$c};

	my $price_str;
	if($price == 0){
		$price_str = qq{<font color="#FF0000">無料</font>};
	}else{
		$price_str = qq{$price_str円};
	}
	&html_header($self);

print << "END_OF_HTML";
<div data-role="header"> 
<h1>$appname</h1> 
</div>
<a href="/">スマフォMAX</a>&gt;<a href="/app/">スマフォアプリ検索</a>&gt;<a href="/$smf_str2-app/">$smf_strアプリ検索</a>&gt;<strong>$appname</strong>

<div data-role="content">
<ul data-role="listview">
<li data-role="list-divider">$smf_strアプリ情報</li>
<li>$price_str</li>
<li><a href="$dl_url"><img src="$img" alt="$appname $smf_strアプリ"><h3>$appname</h3><p>$category_name</p></a></li>
</ul>
<br>
<ul data-role="listview" data-inset="true">
<li><font color="#FF00BF">■</font>アプリ説明</li>
<li><a href="$dl_url">$ex_str</a></li>
</ul>
<ul data-role="listview" data-inset="true">
<li><font color="#FF00BF">■</font>カテゴリ</li>
<li><a href="/appcate-$category/">$category_name</a></li>
</ul>
<ul data-role="listview" data-inset="true">
<li><font color="#FF00BF">■</font>開発</li>
<li>$developer</li>
</ul>

</div>
<img src="/img/E00F_20.gif" height="20">$appnameは、$price_strの$smf_strアプリです。<img src="/img/E32F_20.gif" height="20">
<br>
END_OF_HTML

	&html_footer($self);

	return;
}

sub _android_top(){
	my $self = shift;

	my $a = "アンドロイドアプリ検索 androidアプリの人気アプリ・無料（セール）アプリ検索-スマフォMAX-";
	$self->{html_title} = qq{$a};
	my $b = "アプリ,アンドロイド,android,無料,セール,人気,検索,スマフォ,アンドロイドアプリ";
	$self->{html_keywords} = qq{$b};
	my $c = "iphoneアプリ検索|アンドロイドの人気アプリ、セール中の無料アプリが検索できるandroidアプリ検索サイトです。";
	$self->{html_description} = qq{$c};
	&html_header($self);

	# 新着アプリ
	my $newapp_list;
	my 	$sth = $self->{dbi}->prepare(qq{ select id, img, appname from app where device >= 4 order by id desc limit 3} );
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$newapp_list .= qq{<li><img src="$row[1]" height="20" class="ui-li-icon" alt="アンドロイドアプリ $row[2]"><a href="/appid$row[0]/">$row[2]</a></li>};
	}
	$newapp_list .= qq{<li><img src="/img/E23C_20.gif" height="20" class="ui-li-icon" alt="新着アンドロイドアプリ"><a href="/app-i-new-0/">全て見る</a></li>};

	# 人気アプリ

	# カテゴリ
	my $cate_list;
	my 	$sth = $self->{dbi}->prepare(qq{ select id, name, game, key_value, img, cnt from app_category where flag = 2 order by id } );
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$cate_list .= qq{<li><img src="/img/$row[4]" height="20" class="ui-li-icon"><a href="/appcate$row[0]/">$row[1]</a><span class="ui-li-count">$row[5]</span></li>};
	}
	

print << "END_OF_HTML";
<div data-role="header"> 
<h1>アンドロイドアプリ検索(android)</h1> 
</div>
<a href="/">スマフォMAX</a>&gt;<a href="/app/">スマフォアプリ検索</a>&gt;<strong>androidアプリ検索</strong>

<div data-role="content">
<ul data-role="listview">
<li data-role="list-divider">新着アンドロイドアプリ</li>
$newapp_list
<li data-role="list-divider">アンドロイドアプリ一覧</li>
$cate_list

<li data-role="list-divider">androidアプリ検索サイト</li>
</ul>
</div>
<img src="/img/E00F_20.gif" height="20">アンドロイドアプリ検索は、アンドロイド(android)アプリをスマフォで検索できるアンドロイドアプリ検索サービスです。<img src="/img/E32F_20.gif" height="20">
<br>
END_OF_HTML


	&html_footer($self);

	return;

}


sub _iphone_top(){
	my $self = shift;

	my $a = "アイフォンアプリ検索 iphoneアプリの人気アプリ・無料（セール）アプリ検索-スマフォMAX-";
	$self->{html_title} = qq{$a};
	my $b = "アプリ,アイフォン,iphone,無料,セール,人気,検索,スマフォ,アイフォンアプリ";
	$self->{html_keywords} = qq{$b};
	my $c = "iphoneアプリ検索|アイフォンの人気アプリ、セール中の無料アプリが検索できるiphoneアプリ検索サイトです。";
	$self->{html_description} = qq{$c};
	&html_header($self);

	# 新着アプリ
	my $newapp_list;
	my 	$sth = $self->{dbi}->prepare(qq{ select id, img, appname from app where device < 4 order by id desc limit 3} );
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$newapp_list .= qq{<li><img src="$row[1]" height="20" class="ui-li-icon" alt="アイフォンアプリ $row[2]"><a href="/appid$row[0]/">$row[2]</a></li>};
	}
	$newapp_list .= qq{<li><img src="/img/E23C_20.gif" height="20" class="ui-li-icon" alt="新着アイフォンアプリ"><a href="/app-i-new-0/">全て見る</a></li>};

	# 人気アプリ

	# カテゴリ
	my $cate_list;
	my 	$sth = $self->{dbi}->prepare(qq{ select id, name, game, key_value, img, cnt from app_category where flag = 1 order by id } );
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$cate_list .= qq{<li><img src="/img/$row[4]" height="20" class="ui-li-icon"><a href="/appcate$row[0]/">$row[1]</a><span class="ui-li-count">$row[5]</span></li>};
	}
	

print << "END_OF_HTML";
<div data-role="header"> 
<h1>アイフォンアプリ検索(iphone)</h1> 
</div>
<a href="/">スマフォMAX</a>&gt;<a href="/app/">スマフォアプリ検索</a>&gt;<strong>iphoneアプリ検索</strong>

<div data-role="content">
<ul data-role="listview">
<li data-role="list-divider">新着アイフォンアプリ</li>
$newapp_list
<li data-role="list-divider">アイフォンアプリ一覧</li>
$cate_list

<li data-role="list-divider">iphoneアプリ検索サイト</li>
</ul>
</div>
<img src="/img/E00F_20.gif" height="20">アイフォンアプリ検索は、アイフォン(iphone)アプリをスマフォで検索できるアイフォンアプリ検索サービスです。<img src="/img/E32F_20.gif" height="20">
<br>
END_OF_HTML


	&html_footer($self);

	return;

}

sub _top(){
	my $self = shift;

	my $a = "スマフォアプリ検索(iphoneアプリ/androidアプリ) -スマフォMAX-";
	$self->{html_title} = qq{$a};
	my $b = "アプリ,検索,スマフォ,iphone,アイフォン,アンドロイド,android";
	$self->{html_keywords} = qq{$b};
	my $c = "iphoneアプリ、andoroidアプリが検索できるスマートフォンアプリ専用の検索エンジンです。";
	$self->{html_description} = qq{$c};
	&html_header($self);
	

print << "END_OF_HTML";
<div data-role="header"> 
<h1>スマフォアプリ検索</h1> 
</div>
<a href="/">スマフォMAX</a>&gt;<strong>スマフォアプリ検索</strong>

<div data-role="content">
<ul data-role="listview">
<li data-role="list-divider">スマフォ別アプリ検索</li>
<li><img src="/img/apple.jpg" height="20" class="ui-li-icon" alt="アイフォンアプリ(iphone)検索"><a href="/iphone-app/">アイフォンアプリ(iphone)</a></li>
<li><img src="/img/android.jpg" height="20" class="ui-li-icon" alt="アンドロイドアプリ(android)検索"><a href="/android-app/">アンドロイドアプリ(android)</a></li>
</ul>
</div>
<img src="/img/E00F_20.gif" height="20">スマフォアプリ検索は、アイフォン(iphone)アンドロイド(andoroid)のアプリをスマフォで検索できるアプリ検索サービスです。<img src="/img/E32F_20.gif" height="20">
<br>
END_OF_HTML


	&html_footer($self);

	return;
}


1;