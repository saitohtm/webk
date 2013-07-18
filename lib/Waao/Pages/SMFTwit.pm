package Waao::Pages::SMFTwit;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Html5;
use Waao::Data;
use Waao::Utility;

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
	$list .= qq{<li><a href="/twit$row[0]/">$row[1]</a></li>};
}

	my $a = "有名人のツイッター検索 スマフォMAX";
	$self->{html_title} = qq{$a};
	my $b = "有名人,ツイッター,Twitter,ツイッター検索,プライベート";
	$self->{html_keywords} = qq{$b};
	my $c = "有名人のオフィシャルツイッター。有名人の赤裸々なつぶやきプライベート大公開";
	$self->{html_description} = qq{$c};
	&html_header($self);
	
	my $adlantice_top = &_adlantice_top();
	my $adlantice_footer = &_adlantice_footer();

print << "END_OF_HTML";
<div data-role="header"> 
<h1>有名人のツイッター</h1>
</div>
$adlantice_top
<a href="/">トップ</a>&gt;ツイッター検索

<div data-role="content">
<ul data-role="listview">
$list
</ul>
</div>
$adlantice_footer 
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
	$blog = qq{<li><img src="/img/blog.jpg" height="25" class="ui-li-icon"><a href="/blogid$keyworddata->{id}/">ブログ $keyword</a></li>};
}

	my $adlantice_top = &_adlantice_top();
	my $adlantice_footer = &_adlantice_footer();

print << "END_OF_HTML";
<div data-role="header"> 
<h1>$keyword公式ツイッター</h1>
</div>
$adlantice_top
<a href="/">スマフォMAX</a>&gt;<a href="/twitter/">有名人ツイッター検索</a>&gt;<a href="/twit$keyworddata->{twitgenre}/">ツイッター一覧</a>&gt;$keyword公式ツイッター


<div data-role="content">
<ul data-role="listview">
<li><a href="/person$keyworddata->{id}/"><img src="$keyworddata->{photo}" height="115"><h3>$keyword</h3><p>プロフィール</p></a></li>
END_OF_HTML

if($keyworddata->{twitterurl}=~/twitter/){
print << "END_OF_HTML";
<script src="http://widgets.twimg.com/j/2/widget.js"></script>
<script>
new TWTR.Widget({
  version: 2,
  type: 'profile',
  rpp: 5,
  interval: 6000,
  width: 'auto',
  height: 300,
  theme: {
    shell: {
      background: '#333333',
      color: '#ffffff'
    },
    tweets: {
      background: '#000000',
      color: '#ffffff',
      links: '#4aed05'
    }
  },
  features: {
    scrollbar: false,
    loop: false,
    live: false,
    hashtags: true,
    timestamp: true,
    avatars: true,
    behavior: 'all'
  }
}).render().setUser("$twitter_id").start();
</script>
END_OF_HTML

}else{
print << "END_OF_HTML";
<iframe src="$keyworddata->{twitterurl}" height=300 width=300></iframe>
END_OF_HTML
}

print << "END_OF_HTML";
<li><a href="$keyworddata->{twitterurl}" target="_blank">公式ツイッターはこちら</a></li>
<li><img src="/img/E106_20_ani.gif" height="20" class="ui-li-icon"><a href="/person$keyworddata->{id}/">$keywordプロフィール</a></li>
$blog
</ul>
</div>
$adlantice_footer
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
	my $c = "$category_nameのツイッター検索。$name_pageページ目 有名人($category_name)の公式ツイッターがスマフォで検索できます";
	$self->{html_description} = qq{$c};
	&html_header($self);
	
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

		$liststr .= qq{<li><a href="/twitid$row[0]/"><img src="$photo" alt="$row[1]の画像" width=115><h3>$row[1]</h3><p>$tmp_birth $blood</p></a></li>};
		$cnt++;
	}
	my $pagenext = $page + 1;
	$liststr .= qq{<li><img src="/img/E23C_20.gif" class="ui-li-icon"><a href="/twit$cate-$pagenext/">次へ</a></li>} if($cnt eq 30);
	
	my $adlantice_top = &_adlantice_top();
	my $adlantice_footer = &_adlantice_footer();

print << "END_OF_HTML";
<div data-role="header"> 
<h1>$category_name</h1>
</div>
$adlantice_top
<a href="/">スマフォMAX</a>&gt;<a href="/twitter/">タレントツイッター検索</a>&gt;<a href="/twit$cate/">ツイッター一覧</a>&gt;$category_name
<div data-role="content">
<ul data-role="listview">
<li data-role="list-divider">$category_nameツイッター一覧</li>
$liststr
</ul>
</div>
$adlantice_footer
END_OF_HTML
	
&html_footer($self);
	
	return;
}

sub _adlantice_top(){

my $str = qq{<center>\n<!-- Begin: Adlantis, SpUnitZone: [smax_tiwt_nomal_top] -->\n<div class='adlantis_sp_unit zid_MjMzNTU%3D%0A lsvol_1'></div>\n<!-- End: Adlantis -->\n</center>};

return $str;
}
sub _adlantice_footer(){

my $str = qq{<center>\n<!-- Begin: Adlantis, SpUnitZone: [smax_tiwt_footer] -->\n<div class='adlantis_sp_unit zid_MjMzNTY%3D%0A lsvol_1'></div>\n<!-- End: Adlantis -->\n</center>};

return $str;
}

1;