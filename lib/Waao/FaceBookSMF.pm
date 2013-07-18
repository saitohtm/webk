package Waao::FaceBookSMF;

use DBI;
use CGI;
use Cache::Memcached;
use Waao::Api;
use XML::Simple;
use LWP::Simple;
use Date::Simple;
use Jcode;
use CGI qw( escape );

sub dispatch_search(){
	my $self = shift;

	my $html;
	$html = &_load_tmpl("search.html");
	$html = &_set_heder_str($html);
	my $keyword=$self->{cgi}->param('q');
	$html =~s/<!--KEYWORD-->/$keyword/g;

	# item
	my ($id,$img, $url, $name, $category_id, $likecnt, $diff_cnt,$f_id,$f_category,$website,$f_username);
	my $sth = $self->{dbi}->prepare(qq{select id,img, url, name, category_id, likecnt, diff_cnt,f_id,f_category,website,f_username from facebook where name like "%$keyword%" group by url order by likecnt desc limit 50});
	$sth->execute();
	my $list;
	$list .= qq{<table>\n};
	while(my @row = $sth->fetchrow_array) {
		($id, $img, $url, $name, $category_id, $likecnt, $diff_cnt,$f_id,$f_category,$website,$f_username) = @row;

		my $star_str = &_star_img($likecnt);
		my $like_str = &price_dsp($likecnt);
		my $like_diff_str = &price_dsp($diff_cnt);

		$list .= qq{<tr>\n};
		$list .= qq{<td width=15%><a href="/facebook$id/"><img src="$img" alt="$name"></a></td>\n};
		$list .= qq{<td><h3><a href="/facebook$id/">$name</a></h3><br />$star_str<br />$c_name</td>\n};
		$list .= qq{<td width=25%><b>$like_str</b><br />$facebook_main<br /><br />今日のイイね！<br /><font color="#FF0000">+$like_diff_str</font></td>\n};
		$list .= qq{</tr>\n};
	}
	$list .= qq{</table>\n};

	$html =~s/<!--LIST-->/$list/g;


print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML


	return;
}

sub dispatch_regist(){
	my $self = shift;

	if($self->{cgi}->param('url')){
		&_regist($self);
	}else{
		&_regist_top($self);
	}

	return;
}

sub _regist(){
	my $self = shift;

	my $html;
	$html = &_load_tmpl("regist_end.html");
	$html = &_set_heder_str($html);
	
eval{
	my $sth = $self->{dbi}->prepare(qq{insert into facebook_tmp_url (`url`) values(?)});
	$sth->execute($self->{cgi}->param('url'));
};
	
print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}

sub _regist_top(){
	my $self = shift;

	my $html;
	$html = &_load_tmpl("regist.html");
	$html = &_set_heder_str($html);

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}

sub dispatch(){
	my $self = shift;
	my $facebookid = $self->{cgi}->param('id');

	my $html;
	$html = &_load_tmpl("facebook.html");
	$html = &_set_heder_str($html);

	my ($img, $url, $name, $category_id, $likecnt, $diff_cnt,$f_id,$f_category,$website,$f_username,$f_exp,$talking_about_count,$mission,$keyword_id,$cover_img,$datas);
	my $sth = $self->{dbi}->prepare(qq{select img, url, name, category_id, likecnt, diff_cnt,f_id,f_category,website,f_username,f_exp,talking_about_count,mission,keyword_id,cover_img,datas from facebook where id = ? limit 1});
	$sth->execute($facebookid);
	while(my @row = $sth->fetchrow_array) {
		($img, $url, $name, $category_id, $likecnt, $diff_cnt,$f_id,$f_category,$website,$f_username,$f_exp,$talking_about_count,$mission,$keyword_id,$cover_img,$datas) = @row;
	}

	# カテゴリ
	my ($c_name);
	my $sth = $self->{dbi}->prepare(qq{select name from facebook_category where id = ? limit 1});
	$sth->execute($category_id);
	while(my @row = $sth->fetchrow_array) {
		($c_name) = @row;
	}

	my $keyword_list;
	if($keyword_id){
		$keyword_list = &_keyword_detail($self,$keyword_id);
	}
	$html =~s/<!--KEYWORDLIST-->/$keyword_list/g;

	my $else_facebooklist = &_else_facebooklist($self,$category_id);
	$html =~s/<!--ELSELIST-->/$else_facebooklist/g;


	$html =~s/<!--NAME-->/$name/g;
	$html =~s/<!--URL-->/$url/g;

	my $star_str = &_star_img($likecnt);
	my $like_str = &price_dsp($likecnt);
	my $like_diff_str = &price_dsp($diff_cnt);
	my $talking_about_count = &price_dsp($talking_about_count);
	$talking_about_count = 0 unless($talking_about_count);

	my $list;


	$list .= qq{<table border="0" width=100%>\n};

	if($cover_img){
		$list .= qq{<tr><td BGCOLOR="#FFFFFF" colspan=2><img src="$cover_img" width=100%></td></tr>\n};
	}

	$list .= qq{<tr><td BGCOLOR="#FFFFFF" colspan=2><img src="/img/E110_20.gif" width="15"><strong>$name</strong><br />\n};
	$list .= qq{</td></tr>\n};
	$list .= qq{<tr>\n};
	$list .= qq{<td BGCOLOR="#FFFFFF"><a href="$url" target="_blank" rel="nofollow"><img src="$img" alt="$name" width=120></a></td>\n};
	$list .= qq{<td BGCOLOR="#FFFFFF">$star_str<br />\n};
	$list .= qq{<img src="/img/facebook.png" width="15">いいね！：$like_str<br />\n};
	$list .= qq{<img src="/img/E404_20.gif" width="15">シェア：$talking_about_count<br />\n};
	$list .= qq{</td></tr>\n};
	if($f_exp){
		$f_exp=~s/\n/<br>/g;
		$list .= qq{<tr><td BGCOLOR="#FFFFFF" colspan=2>$f_exp</td></tr>\n};
	}
	if($mission){
		$mission=~s/\n/<br>/g;
		$list .= qq{<tr><td BGCOLOR="#FFFFFF" colspan=2>$mission</td></tr>\n};
	}
	$list .= qq{</table>\n};

	$list .= qq{<ul data-role="listview">\n};
	$list .= qq{<li><a href="/smf/category-$category_id-1/">カテゴリ:$c_nameのfacebookページ</a></li>\n};
	$list .= qq{<li><a href="$url" target="_blank" rel="nofollow">facebook㌻を見る</a></li>\n};
	$list .= qq{</ul>\n};

	$html =~s/<!--LIST-->/$list/g;
	$html =~s/<!--FID-->/$facebookid/g;
	$html =~s/<!--DATAS-->/$datas/g;


print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}

sub _keyword_detail(){
	my $self = shift;
	my $keyword_id = shift;


	my ($datacnt, $keyworddata) = &get_keyword($self, "", $keyword_id);
	my $keyword = $keyworddata->{keyword};

	if($keyword=~/(.*)\((.*)\)/){
		my ($datacnt_tmp, $keyworddata_tmp) = &get_keyword($self, $1, "");
		if($keyworddata_tmp->{id}){
			$datacnt = $datacnt_tmp;
			$keyworddata = $keyworddata_tmp;
		}
	}
	
my $images;
my $sth = $self->{dbi}->prepare(qq{ select id, good, url, fullurl from photo where keywordid = ? order by good desc, yahoo limit 4} );
$sth->execute($keyworddata->{id});
while(my @row = $sth->fetchrow_array) {
	$images.=qq{<a href="http://waao.jp/photoid$row[0]/" target="_blank" ref="nofollow"><img src="$row[2]" alt="$keyword画像" width="75"></a>};
}

my $uwasalist;

my $sth = $self->{dbi}->prepare(qq{ select id, keywordid, keyword, keypersonid, keyperson, type, point
                                  from keyword_recomend  where  keywordid = ? and point >= -100 order by point desc limit 5});
$sth->execute($keyworddata->{id});
while(my @row = $sth->fetchrow_array) {
	my ($photodatacnt, $photodata) = &get_photo($self, $row[3]);
	my $photo = $photodata->{url};

	$uwasalist.=qq{<a href="http://waao.jp/uwasa$row[0]/" target="_blank" ref="nofollow"><img src="$photo" title="$row[4]の画像" width=115>};
	$uwasalist.=qq{<h3>$row[4]</h3><p>};
	$uwasalist.=qq{と恋人} if($row[5] eq 1);
	$uwasalist.=qq{と元恋人} if($row[5] eq 2);
	$uwasalist.=qq{と夫婦} if($row[5] eq 3);
	$uwasalist.=qq{と友人} if($row[5] eq 4);
	$uwasalist.=qq{が好き} if($row[5] eq 5);
	$uwasalist.=qq{が嫌い} if($row[5] eq 6);
	$uwasalist.=qq{とメル友} if($row[5] eq 7);
	$uwasalist.=qq{と親子} if($row[5] eq 8);
	$uwasalist.=qq{と兄弟/姉妹} if($row[5] eq 9);
	$uwasalist.=qq{と共演者} if($row[5] eq 10);
	$uwasalist.=qq{と同郷} if($row[5] eq 11);
	$uwasalist.=qq{と同じ事務所} if($row[5] eq 12);
	$uwasalist.=qq{と元夫婦} if($row[5] eq 13);
	$uwasalist.=qq{とライバル} if($row[5] eq 14);
	$uwasalist.=qq{と同年代} if($row[5] eq 15);
	$uwasalist.=qq{ うわさ度 <font color="red">$row[6]</font></p></a>};
	$uwasalist.=qq{<br />};
}

my $qandalist;
my $sth = $self->{dbi}->prepare(qq{select id, question, bestanswer, url from qanda where keywordid = ? order by id desc limit 5 } );
$sth->execute( $keyworddata->{id} );
while(my @row = $sth->fetchrow_array) {
my $answer = substr($row[2], 0, 64);
	$qandalist.=qq{<ul data-role="listview" data-inset="true">};
	$qandalist.=qq{<li><font color="#555555" size=1><font color="#0035D5">■質問</font>:$row[1] </font></li>};
	$qandalist.=qq{<li><a href="http://waao.jp/qanda$row[0]/" target="_blank" ref="nofollow"><font color="#555555" size=1><font color="#FF0000">■回答</font>:$answer ...</font></a></li>};
	$qandalist.=qq{</ul>};
}

my $blog;
my $twitter;
if($keyworddata->{blogurl}){
	$blog = qq{<li><img src="/img/blog.jpg" height="25" class="ui-li-icon"><a href="http://waao.jp/blogid$keyworddata->{id}/" target="_blank" ref="nofollow">ブログ $keyword</a></li>};
}

if($keyworddata->{twitterurl}){
	$twitter = qq{<li><img src="/img/twitter.png" height="25" class="ui-li-icon"><a href="http://waao.jp/twitid$keyworddata->{id}/" target="_blank" ref="nofollow">Twitter $keyword</a></li>};
}

my $list;
$list .= qq{<img src="/img/E00F_20.gif">$keyword の関連情報<br>};

if($images){
	$list .= qq{<div class="well">};
	$list .= qq{$images};
	$list .= qq{</div>};
}

if($twitter){
	
	my $twitter_id;
	if($keyworddata->{twitterurl} =~/(.*)com\/(.*)/){
		$twitter_id = $2;
	}
	
	$list .= qq{<div class="well">};
	$list .= qq{<img src="/img/tweet.png" height="25"><a href="$keyworddata->{twitterurl}" target="_blank" ref="nofollow">$keyword のTwitter</a><br>};

	if($twitter_id){
	$list .= qq{<script src="http://widgets.twimg.com/j/2/widget.js"></script>
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
</script>};
	}
	
	$list .= qq{</div>};
}

if($keyworddata->{blogurl}){
	$list .= qq{<div class="well">};
	$list .= qq{<img src="/img/E011_20.gif" height="25"><a href="http://waao.jp/blogid$keyworddata->{id}/" target="_blank" ref="nofollow">$keyword のブログ</a>};
	$list .= qq{</div>};
}

if($uwasalist){
	$list .= qq{<div class="well">};
	$list .= qq{$uwasalist};
	$list .= qq{</div>};
}
if($qandalist){
	$list .= qq{<div class="well">};
	$list .= qq{$qandalist};
	$list .= qq{</div>};
}


	return $list;
}

sub _else_facebooklist(){
	my $self = shift;
	my $category_id = shift;
	
	my $list;

	$list .= qq{<ul data-role="listview"><li data-role="list-divider">オススメFaceBook㌻</li>};
	my $sth;
	my $num = int(rand(10));
	if($num % 2){
		$sth = $self->{dbi}->prepare(qq{select id, name, img, url, likecnt, talking_about_count from facebook where category_id = ? and likecnt >= 100 order by rand() limit 10});
		$sth->execute($category_id);
	}else{
		$sth = $self->{dbi}->prepare(qq{select id, name, img, url, likecnt, talking_about_count from facebook where likecnt >= 1000 order by rand() limit 10});
		$sth->execute();
	}
	
	
	
	while(my @row = $sth->fetchrow_array) {
		my $star_str = &_star_img($row[4]);

		$list .= qq{<li><a href="/smf/facebook$row[0]/"><img src="$row[2]" alt="$row[1]"><h3>$row[1]</h3><p>$star_str<br />いいね！：$row[4] シェア：$row[5]</p></a></li>\n};


	}
	$list .= qq{</ul>\n};
	
	return $list;
}

sub _set_heder_str(){
	my $html = shift;

	# header
	my $header = &_load_tmpl("header.html");
	# footer
	my $footer = &_load_tmpl("footer.html");

	$html =~s/<!--HEADER-->/$header/g;
	$html =~s/<!--FOOTER-->/$footer/g;

	return $html;
}

sub new(){
	my $class = shift;
	my $q = new CGI;

	my $self={
			'mem' => &_mem_connect(),
			'dbi' => &_db_connect(),
			'cgi' => $q
			};
	
	return bless $self, $class;
}

# memcached connect
sub _mem_connect(){

	my $memd = new Cache::Memcached {
    'servers' => [ "localhost:11211" ],
    'debug' => 0,
    'compress_threshold' => 1_000,
	};

	return $memd;
}

# db connect
sub _db_connect(){
    my $dsn = 'DBI:mysql:waao';
    my $user = 'mysqlweb';
    my $password = 'WaAoqzxe7h6yyHz';

    my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 0, AutoCommit => 1, PrintError => 0});
	
	return $dbh;
}

sub _load_tmpl(){
	my $tmpl = shift;
	
my $file = qq{/var/www/vhosts/goo.to/etc/makehtml/facebook/tmpl_smf/$tmpl};
my $fh;
my $filedata;
open( $fh, "<", $file );
while( my $line = readline $fh ){ 
	$filedata .= $line;
}
close ( $fh );
	$filedata = &_date_set($filedata);

	return $filedata;
}
sub _date_set(){
	my $html = shift;
	my $date = Date::Simple->new();
	my $ymd = $date->format('%Y/%m/%d');
	$html =~s/<!--DATE-->/$ymd/gi;
	return $html;
}

sub price_dsp(){
	my $price = shift;

	1 while $price =~ s/(.*\d)(\d\d\d)/$1,$2/;	

	return $price;
}


sub _star_img(){
	my $point = shift;
	
	my $str;
	$str = qq{<img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">};
	if($point >= 100000){
		$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png">};
	}elsif($point >= 80000){
		$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-half.png">};
	}elsif($point >= 50000){
		$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-off.png">};
	}elsif($point >= 30000){
		$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-half.png"><img src="/img/star-off.png">};
	}elsif($point >= 10000){
		$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-off.png"><img src="/img/star-off.png">};
	}elsif($point >= 8000){
		$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-half.png"><img src="/img/star-off.png"><img src="/img/star-off.png">};
	}elsif($point >= 5000){
		$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">};
	}elsif($point >= 3000){
		$str = qq{<img src="/img/star-on.png"><img src="/img/star-half.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">};
	}elsif($point >= 1000){
		$str = qq{<img src="/img/star-on.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">};
	}elsif($point >= 800){
		$str = qq{<img src="/img/star-half.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">};
	}elsif($point >= 500){
		$str = qq{<img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">};
	}
	return $str;
}

sub DESTROY{
	my $self = shift;

	$self->{db}->disconnect if($self->{db});

	return;
}
1;