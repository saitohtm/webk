package Waao::Pages::SMFBlog;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Html5;
use Waao::Data;
use Waao::Utility;
use CGI::Cookie;

sub dispatch(){
	my $self = shift;

	if($self->{cgi}->param('cate')){
		&_catelist($self);
	}elsif($self->{cgi}->param('id')){
		&_detail($self);
	}

	return;
}

sub _detail(){
	my $self = shift;
	my $id = $self->{cgi}->param('id');
	my $geinou = &html_mojibake_str("geinou");

	my ($datacnt, $keyworddata) = &get_keyword($self, "", $self->{cgi}->param('id'));
	my $keyword = $keyworddata->{keyword};

# アダルトの場合
#if(){
#	my %cookies = fetch CGI::Cookie;
#	if(exists $cookies{'smaxadult'}){
#		my $value = $cookies{'smaxadult'}->value;
#	}else{
#	}
#}

my $twitter;
if($keyworddata->{twitterurl}){
	$twitter = qq{<li><img src="/img/twitter.png" height="25" class="ui-li-icon"><a href="/twitid$keyworddata->{id}/">Twitter $keyword</a></li>};
}

	my $a = "$keywordの公式ブログ $geinou人ブログ検索";
	$self->{html_title} = qq{$a};
	my $b = "$keyword,ブログ,ブログ検索,プライベート,公式ブログ";
	$self->{html_keywords} = qq{$b};
	my $c = "$keywordの公式ブログ。$keywordのプライベートをブログで大公開中";
	$self->{html_description} = qq{$c};
	&html_header($self);
	
	if($keyword=~/(.*)\((.*)\)/){
		$keyword = $1;
#		($datacnt, $keyworddata) = &get_keyword($self, $keyword, "");
	}
	# 画像
my $images;
#my $sth = $self->{dbi}->prepare(qq{ select id, good, url, fullurl from photo where keywordid = ? order by good desc, yahoo limit 4} );
#$sth->execute($keyworddata->{id});
#while(my @row = $sth->fetchrow_array) {
#	$images.=qq{<a href="/photoid$row[0]/"<img src="$row[2]" alt="$keyword画像" width="75"></a>};
#}
	
print << "END_OF_HTML";
<div data-role="header"> 
<h1>$keyword公式ブログ</h1>
</div>
<a href="/">スマフォMAX</a>&gt;<a href="/blog/">ブログ検索</a>&gt;<a href="/blog$keyworddata->{genre}/">ブログ一覧</a>&gt;$keyword公式ブログ


<div data-role="content">
<ul data-role="listview">
<li><a href="/person$keyworddata->{id}/"><img src="$keyworddata->{photo}" height="115"><h3>$keyword</h3><p>プロフィール</p></a></li>
<li><img src="/img/E252_20.gif" height="20" class="ui-li-icon"><a href="$keyworddata->{blogurl}" target="_blank">ブログが正常に見れない方はこちら</a></li>
<iframe src="$keyworddata->{blogurl}" height=300 width=300></iframe>
<li><img src="/img/E252_20.gif" height="20" class="ui-li-icon"><a href="$keyworddata->{blogurl}" target="_blank">ブログが正常に見れない方はこちら</a></li>
<li><img src="/img/E011_20.gif" height="20" class="ui-li-icon"><a href="/person$keyworddata->{id}/">$keywordプロフィール</a></li>
$twitter
</ul>
</div>

END_OF_HTML
	
&html_footer($self);
	
&cnt_keyword($self, $self->{cgi}->param('id'));

	return;
}	
	
sub _catelist(){
	my $self = shift;
	my $cate = $self->{cgi}->param('cate');
	my $page = $self->{cgi}->param('page');
	$page=0 unless($page);
	
	my $category_name;
	my $cateid;
	my 	$sth = $self->{dbi}->prepare(qq{ select name,cate from bloggenre where genre = ?} );
	$sth->execute($cate);
	while(my @row = $sth->fetchrow_array) {
		$category_name = $row[0];
		$cateid = $row[1];
	}
	my $geinou = &html_mojibake_str("geinou");
	my $name_page;
	$name_page = $page +1 if($self->{cgi}->param('page'));

	my $a = "$category_nameのブログ一覧 $name_pageページ目 $geinou人ブログ検索";
	$self->{html_title} = qq{$a};
	my $b = "$category_name,ブログ検索,$geinou人,ブログ,プライベート";
	$self->{html_keywords} = qq{$b};
	my $c = "$category_nameのブログ一覧。$category_nameの赤裸々プライベートブログが多数登録 $geinou人ブログ検索 $name_pageページ目";
	$self->{html_description} = qq{$c};
	&html_header($self);
	
	my $liststr;
	my $cnt;
	my $startpage = $page * 30;
	my 	$sth = $self->{dbi}->prepare(qq{ select id, keyword, birthday, blood, photo from keyword where blogflag=1 and genre = ? order by cnt desc limit ?, 30} );
	$sth->execute($cate, $startpage);
	while(my @row = $sth->fetchrow_array) {
		my $tmp_birth = $row[2];
		if($tmp_birth eq '0000-00-00'){
			$tmp_birth = undef;
		}elsif($tmp_birth){
			my $tmp_birth2 = substr($tmp_birth,0,4)."年".substr($tmp_birth,5,2)."月".substr($tmp_birth,8,2)."日";
			$tmp_birth = $tmp_birth2;
		}
		my $blood;
		if($row[3]){
			$blood = $row[3];
		}
		if($blood eq 1){
			$blood = undef;
		}
		if($blood =~/^A/){
		}elsif($blood =~/^B/){
		}elsif($blood =~/^O/){
		}else{
			$blood = undef;
		}
			
		my $photo = $row[4];
		unless($photo){
			my ($photodatacnt, $photodata) = &get_photo($self, $row[0]);
			$photo = $photodata->{url};
		}
		$photo = qq{http://s.waao.jp/img/noimage75.gif} unless($photo);

		$liststr.=qq{<li><a href="/blogid$row[0]/"><img src="$photo" alt="$row[1]の画像" width=115><h3>$row[1]</h3><p>$tmp_birth $blood</p></a></li>};
		$cnt++;
	}
	my $pagenext = $page + 1;
	$liststr .= qq{<li><img src="/img/E23C_20.gif" class="ui-li-icon"><a href="/blog$cate-$pagenext/">次へ</a></li>} if($cnt eq 30);
	
print << "END_OF_HTML";
<div data-role="header"> 
<h1>$category_nameブログ</h1>
</div>
<a href="/">スマフォMAX</a>&gt;<a href="/blog/">$geinou人ブログ検索</a>&gt;<a href="/blog_$cateid/">ブログ一覧</a>&gt;$category_nameブログ一覧
<div data-role="content">
<ul data-role="listview">
<li data-role="list-divider">$category_nameブログ一覧</li>
$liststr
</ul>
</div>
END_OF_HTML
	
&html_footer($self);
	
	return;
}


1;