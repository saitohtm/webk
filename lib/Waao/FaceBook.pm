package Waao::FaceBook;
use lib qw(/var/www/vhosts/goo.to/etc/lib /var/www/vhosts/goo.to/lib/Waao);

use DBI;
use CGI;
use Cache::Memcached;
use Waao::Api;
use Waao::Data;
use XML::Simple;
use LWP::Simple;
use Date::Simple;
use Jcode;
use CGI qw( escape );
use JSON;
use PageAnalyze;
use DataController;

sub dispatch_search(){
	my $self = shift;

	my $html;
	$html = &_load_tmpl("search.html");
	$html = &_set_heder_str($html);
	my $keyword=$self->{cgi}->param('q');
	$html =~s/<!--KEYWORD-->/$keyword/g;

eval{
	my $sth = $self->{dbi}->prepare(qq{insert into facebook_keyword (`keyword`) values(?)});
	$sth->execute($keyword);
};

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

my $data = &facebook_page($fb_url);
&facebook_data($self->{dbi},$data);

	
#	my $id = &_get_facebook($self);


eval{
#	my $sth = $self->{dbi}->prepare(qq{insert into facebook_tmp_url (`url`) values(?)});
#	$sth->execute($self->{cgi}->param('url'));
};

	my $list;
	my $sth = $self->{dbi}->prepare(qq{select id, name from facebook where url = ? });
	$sth->execute($self->{cgi}->param('url'));
	while(my @row = $sth->fetchrow_array) {
		$list = qq{<a href="/facebook$row[0]/">$row[1]</a><br />};
	}

	$html =~s/<!--LISTA-->/$list/g;

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}

sub _get_facebook(){
	my $self = shift;

	my $url = $self->{cgi}->param('url');
	my $appflag;
	my $ins_url = $url;
	if($url=~/http:\/\/www.facebook.com\/(.*)/){
		$url = $1;
	}elsif($url=~/https:\/\/www.facebook.com\/(.*)/){
		$url = $1;
	}elsif($url=~/http:\/\/ja-jp.facebook.com\/(.*)/){
		$url = $1;
	# application
	}elsif($url=~/http:\/\/apps.facebook.com\/(.*)/){
		$appflag = 1;
		$url = $1;
	}elsif($url=~/https:\/\/apps.facebook.com\/(.*)/){
		$appflag = 1;
		$url = $1;
	}

	if($url=~/pages\/(.*)\/(.*)/){
		$url = $2;
	}
	$url =~s/\#!//g;
	my $cmd = qq{https://graph.facebook.com/$url};

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$cmd _get_facebook $id
END_OF_HTML


	my $get_url = `GET "$cmd"`;
eval{
	$get_url = decode_json($get_url);
};
	return unless($get_url);

my ($img,$like,$f_id,$category,$website,$username,$name,$street,$city,$country,$zip,$expl,$mission,$talking_about_count);

eval{
	$img = $get_url->{picture};
	$like = $get_url->{likes};
	$f_id = $get_url->{id};
	$category = $get_url->{category};
	$website = $get_url->{website};
	$username = $get_url->{username};
	$name = $get_url->{name};
	$name = Jcode->new($name, 'utf8')->sjis;

	$street = $get_url->{location}->{street} if($get_url->{location});
	$city = $get_url->{location}->{city} if($get_url->{location});
	$country = $get_url->{location}->{country} if($get_url->{location});
	$zip = $get_url->{location}->{zip} if($get_url->{location});

	$expl = $get_url->{public_transit};
	$expl .= $get_url->{description};
	$expl .= $get_url->{personal_info};
	$expl = Jcode->new($expl, 'utf8')->sjis;

	$mission = $get_url->{mission};
	$mission = Jcode->new($mission, 'utf8')->sjis;
	$talking_about_count = $get_url->{talking_about_count};
};

$name = $fname unless($name);

#print "img:$img\n";
#print "like:$like\n";
#print "f_id:$f_id\n";
#print "category:$category\n";
#print "website:$website\n";
#print "username:$username\n";
#print "name:$name\n";
#print "street:$street\n";
#print "city:$city\n";
#print "country:$country\n";
#print "zip:$zip\n";
#print "talking_about_count:$talking_about_count\n";
#print "expl:$expl\n";
#print "mission:$mission\n";

my $diff_cnt =0;
my $t_diff_cnt =0;
my $id;

my 	$category_id;
my $sth2 = $self->{dbi}->prepare(qq{select id from facebook_category where category ="}.$category.qq{"} );
$sth2->execute();
while(my @row2 = $sth2->fetchrow_array) {
	$category_id = $row2[0];
}

$category_id = 186 unless($category_id);
eval{
	my $sth = $self->{dbi}->prepare(qq{insert into facebook (img,likecnt,diff_cnt,f_id,f_category,website,f_username,name,f_exp,mission,url,app_flag,category_id) values(?,?,?,?,?,?,?,?,?,?,?,?,?) });
	$sth->execute($img,$like,$diff_cnt,$f_id,$category,$website,$username,$name,$expl,$mission,$ins_url,$appflag,$category_id);
	
#	$id = $self->{dbi}->last_insert_id('waao', 'waao', 'facebook', 'id');
};

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

sub dispatch_press(){
	my $self = shift;

	if($self->{cgi}->param('email')){
		&_press($self);
	}else{
		&_press_top($self);
	}

	return;
}

sub _press(){
	my $self = shift;

	my $html;
	$html = &_load_tmpl("press_end.html");
	$html = &_set_heder_str($html);
	my $date = Date::Simple->new();
	my $ymd = $date->format('%Y/%m/%d');

eval{

	my $sth = $self->{dbi}->prepare(qq{insert into facebook_press (`pressdate`,`title`,`mainbody`,`facebook`,`email`,`company`,`type`) values(?,?,?,?,?,?,?)});
	$sth->execute($ymd,
	              $self->{cgi}->param('title'),
	              $self->{cgi}->param('mainbody'),
	              $self->{cgi}->param('url'),
	              $self->{cgi}->param('email'),
	              $self->{cgi}->param('company'),
	              $self->{cgi}->param('newstype')
	              );
};


if($self->{cgi}->param('url')){

eval{
	my $sth = $self->{dbi}->prepare(qq{insert into facebook_tmp_url (`url`) values(?)});
	$sth->execute($self->{cgi}->param('url'));
};

}	

# ニュースリリース登録

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}

sub _press_top(){
	my $self = shift;

	my $html;
	$html = &_load_tmpl("press.html");
	$html = &_set_heder_str($html);

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}

sub _facebooknews_detail(){
	my $self = shift;
	my $newsid = shift;

	my $html;
	$html = &_load_tmpl("facebooknewsdetail.html");
	$html = &_set_heder_str($html);

	my $newslist;
	my $sth = $self->{dbi}->prepare(qq{select `id`,`pressdate`,`title`,`mainbody`,`facebook`,`company`,`type` from facebook_press where id = ? });
	$sth->execute($newsid);
	while(my @row = $sth->fetchrow_array) {
		my ($pressid,$pressdate,$title,$mainbody,$facebook,$company,$type);
		($pressid,$pressdate,$title,$mainbody,$facebook,$company,$type) = @row;

		$html =~s/<!--TITLE-->/$title/g;

		$newslist.=qq{<tr>};

		my $tmpbody = $mainbody;
		$tmpbody =~s/\n/<br>/g;
		$newslist.=qq{<td><h3>$title</h3><br>$tmpbody<br> };

		if($facebook){
			# サイト内URL検索
			$newslist.=qq{<a href="$facebook" target="_blank">$facebook</a>};
		}

		$newslist.=qq{<div align=right>$pressdate</div><div align=right><a href="/facebookpress-$type-1/">};
		if($type eq 1){
			$newslist.=qq{ファンページ(PR)};
		}elsif($type eq 2){
			$newslist.=qq{Marketing};
		}elsif($type eq 3){
			$newslist.=qq{ページ作成/システム開発(PR)};
		}elsif($type eq 4){
			$newslist.=qq{ページレビュー};
		}elsif($type eq 5){
			$newslist.=qq{関連ニュース};
		}else{
			$newslist.=qq{その他};
		}
		$newslist.=qq{</a></div></td>};


		$newslist.=qq{</tr>};

	}

	$html =~s/<!--LIST-->/$newslist/g;


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

	# item
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

	my $facebook = qq{<div class="fb-like" data-href="http://www.facebook.com/pages/FreeDone-PJ/205450392884291" data-send="false" data-layout="button_count" data-width="50" data-show-faces="false" data-action="like" data-font="lucida grande"></div>};
	my $facebook_main = qq{<div class="fb-like" data-href="$url" data-send="false" data-layout="button_count" data-width="50" data-show-faces="true" data-action="recomend" data-font="lucida grande"></div>};
#	my $facebook = qq{<a href="/facebook$row[0]/" target="_blank"><img src="/img/facebook_like.png" width="80"></a>};
	my $twitter = qq{<a href="https://twitter.com/share" class="twitter-share-button" data-url="http://facebookrank.info/facebook$facebookid/" data-text="イイね！:$name" data-count="none" data-lang="ja">ツイート</a><script type="text/javascript" src="//platform.twitter.com/widgets.js"></script>};

	my $star_str = &_star_img($likecnt);
	my $like_str = &price_dsp($likecnt);
	my $like_diff_str = &price_dsp($diff_cnt);
	
	my $talking_about_count = &price_dsp($talking_about_count);
	$talking_about_count = 0 unless($talking_about_count);

	my $list;
#	$list .= qq{$facebook $twitter<br /><br />};
	$list .= qq{<table>\n};
	$list .= qq{<tr>\n};
	$list .= qq{<td width=15%><a href="$url" target="_blank" rel="nofollow"><img src="$img" alt="$name"></a>\n};
	$list .= qq{<br />\n};
	$list .= qq{<form action="/review_regist.htm" >\n};
	$list .= qq{<input name="id"type="hidden" value="$facebookid">\n};
	$list .= qq{<button class="btn primary" type="submit">レビューを書く</button>\n};
	$list .= qq{</form>\n};
	$list .= qq{<form action="/facebookupd.htm" >\n};
	$list .= qq{<input name="id"type="hidden" value="$facebookid">\n};
	$list .= qq{<button class="btn primary" type="submit">最新の情報に更新</button>\n};
	$list .= qq{</form>\n};
	
	$list .= qq{</td>\n};
	$list .= qq{<td><h2><a href="$url" target="_blank" rel="nofollow">$name</a></h2><br />$star_str 　<img src="/img/facebook.png" width="15"> いいね！：$like_str 　<img src="/img/E404_20.gif" width="15"> シェア：$talking_about_count<br />カテゴリ：$c_name <a href="/category-$category_id-1/">$c_nameのfacebookページを見る</a>\n};

	if($website){
		$list .= qq{<br />Website:<a href="$website" target="_blank" rel="nofollow">$website</a><br />\n};
	}

	if($cover_img){
		$list .= qq{<img src="$cover_img" width="550"><br />\n};
	}

	
	if($f_exp){
		$f_exp =~s/\n/<br>/g;
		$list .= qq{<div class="well">$f_exp</div>\n};
	}
	if($mission){
		$list .= qq{<div class="well">$mission</div>\n};
	}

	$list .= qq{</td>\n};
	
	$list .= qq{</tr></table>\n};
#	$list .= qq{<br />\n};

	
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
	$list .= qq{<h2><!--NAME-->を見た人にオススメFacebookページ</h2><br />};
	my $sth;
	my $num = int(rand(10));
	if($num % 2){
		$sth = $self->{dbi}->prepare(qq{select id, name, img, url, likecnt, talking_about_count from facebook where category_id = ? and likecnt >= 100 order by rand() limit 10});
		$sth->execute($category_id);
	}else{
		$sth = $self->{dbi}->prepare(qq{select id, name, img, url, likecnt, talking_about_count from facebook where likecnt >= 1000 order by rand() limit 10});
		$sth->execute();
	}
	
	$list .= qq{<table class="zebra-striped">\n};
	$list .= qq{<tbody>\n};
	
	
	while(my @row = $sth->fetchrow_array) {
		my $star_str = &_star_img($row[4]);

		$list .= qq{<tr>\n};
		$list .= qq{<td>\n};
		$list .= qq{<a href="/facebook$row[0]/"><img src="$row[2]"></a>\n};
		$list .= qq{</td>\n};
		$list .= qq{<td>\n};
		$list .= qq{<a href="/facebook$row[0]/">$row[1]</a>\n};
		$list .= qq{<div class="well">\n};

		$list .= qq{$star_str 　<img src="/img/facebook.png" width="15"> いいね！：$row[4] 　<img src="/img/E404_20.gif" width="15"> 話題：$row[5]\n};

		$list .= qq{</div>\n};
		$list .= qq{</td>\n};
		$list .= qq{</tr>\n};

	}
	$list .= qq{</tbody>\n};
	$list .= qq{</table>\n};
	
	return $list;
}

sub dispatch_facebooknews(){
	my $self = shift;

	if($self->{cgi}->param('id')){
		&_facebooknews_detail($self,$self->{cgi}->param('id'));
		return;
	}

	my $page = $self->{cgi}->param('page');
	my $type = 0;
	$type = $self->{cgi}->param('type');


	my $start = 0;
	my $limitcnt = 10;
	$start = ($page - 1) * $limitcnt if($page);

	my $where_type;
	$where_type = qq{ where type = $type } if($type);
	
	my $html;
	$html = &_load_tmpl("facebooknews.html");
	$html = &_set_heder_str($html);
	$html =~s/<!--PAGE-->/$page/g;
	$html =~s/<!--TYPE-->/$type/g;

	my $newslist;
	my $sth = $self->{dbi}->prepare(qq{select `id`,`pressdate`,`title`,`mainbody`,`facebook`,`company`,`type` from facebook_press $where_type order by pressdate desc limit $start,$limitcnt});
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my ($pressid,$pressdate,$title,$mainbody,$facebook,$company,$type);
		($pressid,$pressdate,$title,$mainbody,$facebook,$company,$type) = @row;

		$newslist.=qq{<tr>};

		my $tmpbody = substr($mainbody,0,128);

		$newslist.=qq{<td><h3><a href="/facebooknews-$pressid/">$title</a></h3><br>$tmpbody<br> };

		if($facebook){
			# サイト内URL検索
			$newslist.=qq{<a href="$facebook" target="_blank">$facebook</a>};
		}

		$newslist.=qq{<div align=right>$pressdate</div><div align=right><a href="/facebookpress-$type-1/">};
		if($type eq 1){
			$newslist.=qq{ファンページ(PR)};
		}elsif($type eq 2){
			$newslist.=qq{Marketing};
		}elsif($type eq 3){
			$newslist.=qq{ページ作成/システム開発(PR)};
		}elsif($type eq 4){
			$newslist.=qq{ページレビュー};
		}elsif($type eq 5){
			$newslist.=qq{関連ニュース};
		}else{
			$newslist.=qq{その他};
		}
		$newslist.=qq{</a></div></td>};


		$newslist.=qq{</tr>};

	}

	$html =~s/<!--LIST-->/$newslist/g;


print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}

sub _set_heder_str(){
	my $html = shift;

	# meta
	my $meta = &_load_tmpl("meta.html");
	# header
	my $header = &_load_tmpl("header.html");
	# footer
	my $footer = &_load_tmpl("footer.html");
	# slider
	my $slider_main = &_load_tmpl("slider_main.html");
	# slider
	my $slider_regist = &_load_tmpl("slider_regist.html");
	# slider
	my $slider_category = &_load_tmpl("slider_category.html");

	my $header_menu = &_load_tmpl("header_menu.html");

	$html =~s/<!--META-->/$meta/g;
	$html =~s/<!--HEADER-->/$header/g;
	$html =~s/<!--FOOTER-->/$footer/g;
	$html =~s/<!--SLIDER_MAIN-->/$slider_main/g;
	$html =~s/<!--SLIDER_REGIST-->/$slider_regist/g;
	$html =~s/<!--SLIDER_CATEGORY-->/$slider_category/g;
	$html =~s/<!--HEADER_MENUE-->/$header_menu/g;
	my $date = Date::Simple->new();
	my $ymd = $date->format('%Y/%m/%d');
	$html =~s/<!--DATE-->/$ymd/g;

	my $ad_header = &_load_tmpl("ad_header.html");
	$html =~s/<!--AD_HEADER-->/$ad_header/g;

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
	
my $file = qq{/var/www/vhosts/goo.to/etc/makehtml/facebook/tmpl/$tmpl};
my $fh;
my $filedata;
open( $fh, "<", $file );
while( my $line = readline $fh ){ 
	$filedata .= $line;
}
close ( $fh );

	return $filedata;
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

sub dispatch_rd(){
	my $self = shift;

	my $id = $self->{cgi}->param('id');

	my $sth = $self->{dbi}->prepare(qq{select `url` from fmfm where id = ? });	 
	$sth->execute($id);
	my $url;
	while(my @row = $sth->fetchrow_array) {
		$url = $row[0];
	}
eval{
	my $sth = $self->{dbi}->prepare(qq{update fmfm set cnt = cnt + 1 where id = ? limit 1 });	 
	$sth->execute($id);
};	
	print qq{Location: $url\n\n};
	return;
}


sub dispatch_fmfm_regist(){
	my $self = shift;

	if($self->{cgi}->param('url')){
		&_fmfm_check($self);
	}elsif($self->{cgi}->param('title')){
		&_fmfm_regist($self);
	}else{
		&_fmfm_regist_top($self);
	}

	return;
}

sub _fmfm_check(){
	my $self = shift;
	my $html;
	$html = &_load_tmpl("fmfm_regist_check.html");
	$html = &_set_heder_str($html);
	
	my $url = $self->{cgi}->param('url');

	my $get_url = `GET "$url"`;
	my @lines = split(/\n/,$get_url);
my $title;
	my $ut8;
	foreach my $line (@lines){
		if($line=~/utf-8/i){
			$utf=1;
		}
		if($line=~/utf8/i){
			$utf=1;
		}
		if($line=~/(.*)title>(.*)<\/title(.*)/i){
			$title = $2;
			if($utf){
				$title = Jcode->new($title, 'utf8')->sjis;
			}
		}
	}
	$html =~s/<!--URL-->/$url/g;
	$html =~s/<!--TITLE-->/$title/g;

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}

sub _fmfm_regist(){
	my $self = shift;

	my $html;
	$html = &_load_tmpl("fmfm_regist_end.html");
	$html = &_set_heder_str($html);
	
	my $date = Date::Simple->new();
	my $ymd = $date->format('%Y/%m/%d');

eval{
	my $sth = $self->{dbi}->prepare(qq{insert into fmfm (`url`,`title`,`type`,`date`,`moto`) values(?,?,?,?,?)});
	$sth->execute($self->{cgi}->param('tmp_url'),$self->{cgi}->param('title'),$self->{cgi}->param('newstype'),$ymd,$self->{cgi}->param('moto'));
};
	
print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}

sub _fmfm_regist_top(){
	my $self = shift;

	my $html;
	$html = &_load_tmpl("fmfm_regist.html");
	$html = &_set_heder_str($html);

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}


sub _socialnews_date(){
	my $self = shift;
	my $date = $self->{cgi}->param('date');
	my $html;
	$html = &_load_tmpl("socialnews_date.html");
	$html = &_set_heder_str($html);

	my $sth = $self->{dbi}->prepare(qq{select id,url,title,type,date,cnt from fmfm where type <= 2 and date = ? order by id desc });	 
	$sth->execute($date);
	my $list;
	while(my @row = $sth->fetchrow_array) {
		my $typename;
		if($type eq 1){
			$typename = qq{ソーシャル関連};
		}else{
			$typename = qq{facebook関連};
		}
		$list .= qq{<tr>};
		$list .= qq{<td>$row[2] <br /><a href="/rd.htm?id=$row[0]" target="_blank" ref="nofollow">情報を見る</a></td>};
		$list .= qq{<td>$typename</td>};
		$list .= qq{<td>$row[4]</td>};
		$list .= qq{<td>$row[5]</td>};
		$list .= qq{</tr>};
	}
	$html =~s/<!--DATE-->/$date/g;
	$html =~s/<!--LIST-->/$list/g;

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}

sub _socialnews_list(){
	my $self = shift;

	my $html;
	$html = &_load_tmpl("socialnews.html");
	$html = &_set_heder_str($html);
	my $page = 0;
	$page = $self->{cgi}->param('page');
	$page = 0 if($page <=0);
	my $pagemax = 50;
	my $start = 0 + ($pagemax * ($page - 1));

	my $sth = $self->{dbi}->prepare(qq{select id,url,title,type,date,cnt from fmfm where type <= 2 order by id desc limit $start,$pagemax});	 
	$sth->execute();
	my $list;
	while(my @row = $sth->fetchrow_array) {
		my $typename;
		if($type eq 1){
			$typename = qq{ソーシャル関連};
		}else{
			$typename = qq{facebook関連};
		}
		$list .= qq{<tr>};
		$list .= qq{<td>$row[2] <br /><a href="/rd.htm?id=$row[0]" target="_blank" ref="nofollow">情報を見る</a></td>};
		$list .= qq{<td>$typename</td>};
		my $date = $row[4];
		$list .= qq{<td><a href="/facebook-topics$date/">$row[4]</a></td>};
		$list .= qq{<td>$row[5]</td>};
		$list .= qq{</tr>};
	}
	my $pager = &_pager($page,"facebooktopics");
	$html =~s/<!--LIST-->/$list/g;
	$html =~s/<!--PAGER-->/$pager/g;

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}

sub dispatch_socialnews(){
	my $self = shift;

	if($self->{cgi}->param('date')){
		&_socialnews_date($self);
	}else{
		&_socialnews_list($self);
	}

	return;
}

sub _pager(){
	my $page = shift;
	my $type = shift;
	my $pagelist;

	$pagelist .= qq{<div class="pagination">\n};
	$pagelist .= qq{<ul>\n};
	if($page == 1){
	   	$pagelist .= qq{<li class="prev disabled"><a href="/$type-1/">&larr; Previous</a></li>\n};
	}else{
		my $preno = $page - 1;
	   	$pagelist .= qq{<li class="prev"><a href="/$type-$preno/">&larr; Previous</a></li>\n};
	}
	my $pageno;
	for(my $i=0; $i<10; $i++){
		$pageno = $page + $i;
		if($page eq $pageno){
		    $pagelist .= qq{<li class="active"><a href="/$type-$pageno/">$pageno</a></li>\n};
		}else{
		    $pagelist .= qq{<li><a href="/$type-$pageno/">$pageno</a></li>\n};
		}
	}
	$pageno++;
	my $page_next = $page + 1;
    $pagelist .= qq{<li class="next"><a href="/$type-$page_next/">Next &rarr;</a></li>\n};
    $pagelist .= qq{</ul>\n};
    $pagelist .= qq{</div>\n};

	return $pagelist;
}

sub dispatch_review_regist(){
	my $self = shift;

	if($self->{cgi}->param('id')){
		&_review_check($self);
	}elsif($self->{cgi}->param('title')){
		&_review_regist($self);
	}

	return;
}

sub _review_check(){
	my $self = shift;
	my $html;
	$html = &_load_tmpl("review_regist_check.html");
	$html = &_set_heder_str($html);
	
	my $id = $self->{cgi}->param('id');
	my $title;
	my $list;

	$list .=qq{<table class="zebra-striped">};
	$list .=qq{<tbody>};


	my $sth = $self->{dbi}->prepare(qq{select id, img, url, name, category_id, likecnt, diff_cnt,f_exp,talking_about_count,diff_talking  from facebook where id = ? limit 1});
	$sth->execute($id);
	while(my @row = $sth->fetchrow_array) {
		$title = $row[3];
		my $exp_str = $row[7];
		$exp_str = substr($exp_str,0,256);
		my $talking_about_count = &price_dsp($row[8]);
		$talking_about_count = 0 unless($talking_about_count);
		my $talking_about_diff = &price_dsp($row[9]);
		$talking_about_diff = 0 unless($talking_about_diff);
		my $like_str = &price_dsp($row[5]);
		my $like_diff_str = &price_dsp($row[6]);
		$list .= qq{<tr>\n};
		$list .= qq{<td><img src="$row[1]" alt="$row[3]"></td>\n};
		$list .= qq{<td><h3><a href="/facebook$row[0]/">$row[3]</a></h3>};

		if($exp_str){
			$list .= qq{<div class="well">$exp_str <a href="/facebook$row[0]/">...続きを見る</a></div>\n};
		}else{
			$list .= qq{<br />\n};
		}
		$list .= qq{<td width=15%>$like_str<br /><font color="#FF0000">+$like_diff_str</font><br />話題:$talking_about_count<br /><font color="#FF0000">+$talking_about_diff</font><br />$facebook</td>\n};
		$list .= qq{</tr>\n};
	}
	$list .=qq{</tbody>};
	$list .=qq{</table>};

	$html =~s/<!--ID-->/$id/g;
	$html =~s/<!--TITLE-->/$title/g;
	$html =~s/<!--LIST-->/$list/g;

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}

sub _review_regist(){
	my $self = shift;

	my $html;
	$html = &_load_tmpl("review_regist_end.html");
	$html = &_set_heder_str($html);
	
	my $date = Date::Simple->new();
	my $ymd = $date->format('%Y/%m/%d');

eval{
	my $sth = $self->{dbi}->prepare(qq{insert into facebook_review (`f_id`,`title`,`review`,`nickname`,`url`,`date`) values(?,?,?,?,?,?)});
	$sth->execute($self->{cgi}->param('f_id'),$self->{cgi}->param('title'),$self->{cgi}->param('mainbody'),$self->{cgi}->param('nickname'),$self->{cgi}->param('linkurl'),$ymd);
};
	
print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}


sub price_dsp(){
	my $price = shift;

	1 while $price =~ s/(.*\d)(\d\d\d)/$1,$2/;	

	return $price;
}

sub dispatch_facebook_upd(){
	my $self = shift;

	my $facebookid=$self->{cgi}->param('id');

	# facebook情報取得
	&_get_facebook($self,$facebookid);

	my $url = qq{http://www.facebookranking.info/facebook$facebookid/};
	print qq{Location: $url\n\n};

	return;
}

sub _get_facebook(){
	my $self = shift;
	my $id = shift;

	my $url;
	my $likecnt;
	my $tcnt;
	my $fname;

	my $sth = $self->{dbi}->prepare(qq{select id, url, likecnt,talking_about_count,name from facebook where id = ? limit 1} );
	$sth->execute($id);
	while(my @row = $sth->fetchrow_array) {
		$url = $row[1];
		$likecnt = $row[2];
		$tcnt = $row[3];
		$name = $row[4];
	}
	my $ins_url = $url;

	my $data;
	$data = &facebook_page($url);

	my $expl = $data->{public_transit};
	$expl .= $data->{description};
	$expl .= $data->{personal_info};

my $diff_cnt = $data->{like} - $likecnt;
my $t_diff_cnt = $data->{talking_about_count} - $tcnt;

$diff_cnt = 0 if($diff_cnt eq $likecnt);
$t_diff_cnt = 0 if($t_diff_cnt eq $tcnt);
eval{
print "ID $id \n";
foreach my $key ( sort keys( %{$data} ) ) {
    print "$key : $data->{$key}\n ";
}

	if($id){
		my $sth = $self->{dbi}->prepare(qq{update facebook set likecnt=?,diff_cnt=?,f_id=?,f_category=?,website=?,f_username=?,name=?,f_exp=?,mission=?,talking_about_count=?,diff_talking=?, img=?, cover_img = ? , datas = ? where id = ? });
		$sth->execute($data->{like},
		              $diff_cnt,
		              $data->{id},
		              $data->{category},
		              $data->{website},
		              $data->{username},
		              $data->{name},
		              $expl,
		              $data->{mission},
		              $data->{talking_about_count},
		              $t_diff_cnt,
		              $data->{img},
		              $data->{cover_img},
		              $data->{datas},
		              $id);
	}else{
		my $sth = $self->{dbi}->prepare(qq{insert into facebook (img,likecnt,diff_cnt,f_id,f_category,website,f_username,name,f_exp,mission,url) values(?,?,?,?,?,?,?,?,?,?,?) });
		$sth->execute($data->{img},
		              $data->{like},
		              $diff_cnt,
		              $data->{id},
		              $data->{category},
		              $data->{website},
		              $data->{username},
		              $data->{name},
		              $expl,
		              $data->{mission},
		              $ins_url);
	}
};
if($@){
print $@;
}

	return;
}


1;