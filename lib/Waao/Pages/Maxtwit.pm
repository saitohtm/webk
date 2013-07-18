package Waao::Pages::Maxtwit;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Html;
use Waao::Data;
use Waao::Utility;
use Waao::AdMob;

sub dispatch(){
	my $self = shift;

	if($self->{cgi}->param('cate')){
		&_catelist($self);
	}elsif($self->{cgi}->param('cate') eq '0'){
		&_catelist($self);
	}elsif($self->{cgi}->param('id')){
		&_detail($self);
	}else{
		&_top($self);
	}

	return;
}

sub _top(){
	my $self = shift;

my $list;	
my $sth = $self->{dbi}->prepare(qq{ select id,name from twitcate } );
$sth->execute();
while(my @row = $sth->fetchrow_array) {
	$list .= qq{<font color="#009525">》</font><a href="/twit$row[0]/">$row[1]</a><br>};
}

	my $a = "有名人のツイッター検索 スマフォMAX";
	$self->{html_title} = qq{$a};
	my $b = "有名人,ツイッター,Twitter,ツイッター検索,プライベート";
	$self->{html_keywords} = qq{$b};
	my $c = "有名人のオフィシャルツイッター。有名人の赤裸々なつぶやきプライベート大公開";
	$self->{html_description} = qq{$c};

	my $hr = &html_hr($self,1);	
	&html_header($self);

print << "END_OF_HTML";
<center><img src="http://img.waao.jp/geinouplus.gif" width=120 height=28 alt="有名人ツイッター"></center>
<table border=0 bgcolor="#DFFFBF" width="100%"><tr><td><font color="#00968c">有名人ツイッター検索</font><br></td></tr></table>
$hr
$list
$hr
ツイッター検索

END_OF_HTML
	
&html_footer($self);

	
	return;
}

sub _detail(){
	my $self = shift;
	my $id = $self->{cgi}->param('id');
	
	my ($datacnt, $keyworddata) = &get_keyword($self, "", $self->{cgi}->param('id'));
	my $keyword = $keyworddata->{keyword};

	my $a = "$keywordの公式ツイッター(Twitter) 有名人ツイッター検索";
	$self->{html_title} = qq{$a};
	my $b = "$keyword,ツイッター,twitter,有名人,検索";
	$self->{html_keywords} = qq{$b};
	my $c = "$keywordの公式ツイッター(twitter)。$keywordのリアルつぶやきをスマフォで見れます";
	$self->{html_description} = qq{$c};
	&html_header($self);
	my $hr = &html_hr($self,1);	
	
	if($keyword=~/(.*)\((.*)\)/){
#		$keyword = $1;
#		($datacnt, $keyworddata) = &get_keyword($self, $keyword, "");
	}
	# 画像
#my $images;
#my $sth = $self->{dbi}->prepare(qq{ select id, good, url, fullurl from photo where keywordid = ? order by good desc, yahoo limit 4} );
#$sth->execute($keyworddata->{id});
#while(my @row = $sth->fetchrow_array) {
#	$images.=qq{<a href="/photoid$row[0]/"<img src="$row[2]" alt="$keyword画像" width="75"></a>};
#}
	
my $twitter_id;
if($keyworddata->{twitterurl} =~/(.*)com\/(.*)/){
	$twitter_id = $2;
}

my $blog;
if($keyworddata->{blogurl}){
	$blog = qq{<a href="/blogid$keyworddata->{id}/">ブログ $keyword</a><br>};
}

print << "END_OF_HTML";
<table border=0 bgcolor="#DFFFBF" width="100%"><tr><td><font color="#00968c">$keyword公式ツイッター</font><br></td></tr></table>
$hr
END_OF_HTML

#&admob_ad();

print << "END_OF_HTML";
<center>
<font color="#00968c">▽▽▽▽▽</font><br>
<blink></blink><a href="$keyworddata->{twitterurl}">$keywordのツイッター</a><br>
<font color="#00968c">△△△△△</font><br>
</center>
$hr
END_OF_HTML

my ($datacnt, $photodata) = &get_photo($self, $keyworddata->{id});
&html_keyword_info($self, $keyworddata, $photodata);

print << "END_OF_HTML";
$blog

$hr
<a href="/">有名人ツイッター検索</a>&gt;<a href="/twit$keyworddata->{twitgenre}/">ツイッター一覧</a>&gt;$keyword公式ツイッター
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
	my 	$sth = $self->{dbi}->prepare(qq{ select name,id from twitcate where id = ?} );
	$sth->execute($cate);
	while(my @row = $sth->fetchrow_array) {
		$category_name = $row[0];
		$cateid = $row[1];
	}

	my $name_page = $page +1;

	my $a = "$category_nameツイッター一覧 $name_pageページ目 有名人ツイッター（twitter）検索";
	$self->{html_title} = qq{$a};
	my $b = "$category_name,ツイッター検索,有名人,ツイッター,twitter";
	$self->{html_keywords} = qq{$b};
	my $c = "$category_nameのツイッター検索。有名人($category_name)の公式ツイッターがスマフォで検索できます";
	$self->{html_description} = qq{$c};
	&html_header($self);
	my $hr = &html_hr($self,1);	
	
	my $liststr;
	my $cnt;
	my $startpage = $page * 30;
	my 	$sth = $self->{dbi}->prepare(qq{ select id, keyword,birthday, blood, photo, twitprofimg  from keyword where twitflag=1 and twitgenre = ? order by cnt desc limit ?, 30} );
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
		$photo = $row[5] if($row[5]);
		unless($photo){
			my ($photodatacnt, $photodata) = &get_photo($self, $row[0]);
			$photo = $photodata->{url};
		}
		$photo = qq{http://s.waao.jp/img/noimage75.gif} unless($photo);

		$liststr .= qq{<font color="#009525">》</font><a href="/twitid$row[0]/">$row[1]</a><br>};
		$cnt++;
	}
	my $pagenext = $page + 1;
	$liststr .= qq{<img src="http://img.waao.jp/right07.gif"><a href="/twit$cate-$pagenext/">次へ</a><br>} if($cnt eq 30);
	
print << "END_OF_HTML";
<table border=0 bgcolor="#DFFFBF" width="100%"><tr><td><font color="#00968c">$category_name</font><br></td></tr></table>
$hr
$liststr
$hr
<a href="/">タレントツイッター検索</a>&gt;<a href="/twit$cate/">ツイッター一覧</a>&gt;$category_name
END_OF_HTML
	
&html_footer($self);
	
	return;
}


1;