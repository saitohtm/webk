package Waao::Pages::Maxblog;
use strict;
use base qw(Waao::Pages::Base);

use Waao::Html;
use Waao::Data;
use Waao::Utility;
use Waao::AdMob;

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
my $twitter;
if($keyworddata->{twitterurl}){
	$twitter = qq{<img src="http://s.waao.jp/img/twitter.png" height="15"><a href="/twitid$keyworddata->{id}/">Twitter $keyword</a><br>};
}

	my $a = "$keywordの公式ブログ $geinou人ブログ検索";
	$self->{html_title} = qq{$a};
	my $b = "$keyword,ブログ,ブログ検索,プライベート,公式ブログ";
	$self->{html_keywords} = qq{$b};
	my $c = "$keywordの公式ブログ。$keywordのプライベートをブログで大公開中";
	$self->{html_description} = qq{$c};

	my $hr = &html_hr($self,1);	
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
<table border=0 bgcolor="#DFFFBF" width="100%"><tr><td><font color="#00968c">$keyword公式ブログ</font><br></td></tr></table>
$hr
END_OF_HTML

&admob_ad();

print << "END_OF_HTML";
<center>
<font color="#00968c">▽▽▽▽▽</font><br>
<blink></blink><a href="$keyworddata->{blogurl}">$keywordのブログ</a><br>
<font color="#00968c">△△△△△</font><br>
</center>
$hr
END_OF_HTML

if($twitter){
print << "END_OF_HTML";
$twitter
$hr
END_OF_HTML
}

my ($datacnt, $photodata) = &get_photo($self, $keyworddata->{id});
&html_keyword_info($self, $keyworddata, $photodata);

print << "END_OF_HTML";
$hr
<a href="/">ブログ検索</a>&gt;<a href="/blog$keyworddata->{genre}/">ブログ一覧</a>&gt;$keyword公式ブログ
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
	my $name_page = $page +1;

	my $a = "$category_nameのブログ一覧 $name_pageページ目 $geinou人ブログ検索";
	$self->{html_title} = qq{$a};
	my $b = "$category_name,ブログ検索,$geinou人,ブログ,プライベート";
	$self->{html_keywords} = qq{$b};
	my $c = "$category_nameのブログ一覧。$category_nameの赤裸々プライベートブログが多数登録 $geinou人ブログ検索";
	$self->{html_description} = qq{$c};

	my $hr = &html_hr($self,1);	
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
		if($tmp_birth || $blood){
#			$liststr.=qq{<font color="#009525">》</font><a href="/blogid$row[0]/">$row[1]($tmp_birth $blood)</a><br>};
		}else{
#			$liststr.=qq{<font color="#009525">》</font><a href="/blogid$row[0]/">$row[1]</a><br>};
		}
		$liststr.=qq{<font color="#009525">》</font><a href="/blogid$row[0]/">$row[1]</a><br>};
		$cnt++;
	}
	my $pagenext = $page + 1;
	$liststr .= qq{<img src="http://img.waao.jp/right07.gif"><a href="/blog$cate-$pagenext/">次へ</a><br>} if($cnt eq 30);
	
print << "END_OF_HTML";
<center><img src="http://img.waao.jp/blog.gif" width=120 height=28 alt="芸能人ブログ"></center>
<table border=0 bgcolor="#DFFFBF" width="100%"><tr><td><font color="#00968c">$category_nameブログ</font><br></td></tr></table>
$hr
$liststr
$hr
<a href="/">$geinou人ブログ検索</a>&gt;<a href="/blog_$cateid/">ブログ一覧</a>&gt;$category_nameブログ一覧
END_OF_HTML
	
&html_footer($self);
	
	return;
}


1;