package Waao::FaceBook;

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
	my ($img, $url, $name, $category_id, $likecnt, $diff_cnt,$f_id,$f_category,$website,$f_username,$f_exp,$talking_about_count,$mission);
	my $sth = $self->{dbi}->prepare(qq{select img, url, name, category_id, likecnt, diff_cnt,f_id,f_category,website,f_username,f_exp,talking_about_count,mission from facebook where id = ? limit 1});
	$sth->execute($facebookid);
	while(my @row = $sth->fetchrow_array) {
		($img, $url, $name, $category_id, $likecnt, $diff_cnt,$f_id,$f_category,$website,$f_username,$f_exp,$talking_about_count,$mission) = @row;
	}

	# カテゴリ
	my ($c_name);
	my $sth = $self->{dbi}->prepare(qq{select name from facebook_category where id = ? limit 1});
	$sth->execute($category_id);
	while(my @row = $sth->fetchrow_array) {
		($c_name) = @row;
	}

	$html =~s/<!--NAME-->/$name/g;
	$html =~s/<!--URL-->/$url/g;

	my $facebook = qq{<div class="fb-like" data-href="http://www.facebook.com/pages/FreeDone-PJ/205450392884291" data-send="false" data-layout="button_count" data-width="50" data-show-faces="false" data-action="like" data-font="lucida grande"></div>};
	my $facebook_main = qq{<div class="fb-like" data-href="http://www.facebook.com/pages/FreeDone-PJ/205450392884291" data-send="false" data-layout="button_count" data-width="50" data-show-faces="true" data-action="recomend" data-font="lucida grande"></div>};
#	my $facebook = qq{<a href="/facebook$row[0]/" target="_blank"><img src="/img/facebook_like.png" width="80"></a>};
	my $twitter = qq{<a href="https://twitter.com/share" class="twitter-share-button" data-url="http://facebookrank.info/facebook$facebookid/" data-text="イイね！:$name" data-count="none" data-lang="ja">ツイート</a><script type="text/javascript" src="//platform.twitter.com/widgets.js"></script>};

	my $star_str = &_star_img($likecnt);
	my $like_str = &price_dsp($likecnt);
	my $like_diff_str = &price_dsp($diff_cnt);
	
	my $talking_about_count = &price_dsp($talking_about_count);
	$talking_about_count = 0 unless($talking_about_count);

	my $list;
	$list .= qq{<img src="/img/facebook.png" width="80">　お友達にFACEBOOKページを紹介する<img src="/img/kaow03.gif"><br />};
	$list .= qq{$facebook $twitter<br /><br />};
	$list .= qq{<table><tr>\n};
	$list .= qq{<td width=15%><a href="$url" target="_blank" rel="nofollow"><img src="$img" alt="$name"></a></td>\n};
	$list .= qq{<td><h3><a href="$url" target="_blank" rel="nofollow">$name</a></h3><br />$star_str<br /><a href="/category-$category_id-1/">$c_nameのfacebookページを見る</a>\n};

	if($f_exp){
		$f_exp =~s/\n/<br>/g;
		$list .= qq{<div class="well">$f_exp</div>\n};
	}
	if($mission){
		$list .= qq{<div class="well">$mission</div>\n};
	}

	$list .= qq{</td>\n};
	
	$list .= qq{<td width=25%><b>$like_str</b><br />$facebook_main<br /><br />今日のイイね！<br /><font color="#FF0000">+$like_diff_str</font><br /><br />話題：$talking_about_count</td>\n};
	$list .= qq{</tr></table>\n};
	$list .= qq{<br /><br />\n};
	$html =~s/<!--LIST-->/$list/g;


print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
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

	$html =~s/<!--META-->/$meta/g;
	$html =~s/<!--HEADER-->/$header/g;
	$html =~s/<!--FOOTER-->/$footer/g;
	$html =~s/<!--SLIDER_MAIN-->/$slider_main/g;
	$html =~s/<!--SLIDER_REGIST-->/$slider_regist/g;
	$html =~s/<!--SLIDER_CATEGORY-->/$slider_category/g;
	my $date = Date::Simple->new();
	my $ymd = $date->format('%Y/%m/%d');
	$html =~s/<!--DATE-->/$ymd/g;

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
	
my $file = qq{/var/www/vhosts/waao.jp/etc/facebook/tmpl/$tmpl};
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
	$str = qq{<img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif">};
	if($point >= 100000){
		$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif">};
	}elsif($point >= 80000){
		$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star_half.gif">};
	}elsif($point >= 50000){
		$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star_off.gif">};
	}elsif($point >= 30000){
		$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star_half.gif"><img src="/img/review_all_star_off.gif">};
	}elsif($point >= 10000){
		$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif">};
	}elsif($point >= 8000){
		$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star_half.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif">};
	}elsif($point >= 5000){
		$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif">};
	}elsif($point >= 3000){
		$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star_half.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif">};
	}elsif($point >= 1000){
		$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif">};
	}elsif($point >= 800){
		$str = qq{<img src="/img/review_all_star_half.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif">};
	}elsif($point >= 500){
		$str = qq{<img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif">};
	}
	return $str;
}

sub DESTROY{
	my $self = shift;

	$self->{db}->disconnect if($self->{db});

	return;
}
1;