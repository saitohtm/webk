package Waao::App;

use lib qw(/var/www/vhosts/goo.to/etc/lib /var/www/vhosts/goo.to/lib/Waao);
use PageAnalyze;
use DataController;
use Utility;

use DBI;
use CGI;
use Cache::Memcached;
use Waao::Api;
use XML::Simple;
use LWP::Simple;
use Jcode;
use CGI qw( escape );
use Date::Simple;

sub dispatch_links(){
	my $self = shift;

	if($self->{cgi}->param('clickid')){
		&_links_click($self);
	}elsif($self->{cgi}->param('regist')){
		&_links_regist_top($self);
	}elsif($self->{cgi}->param('site')){
		&_links_regist_upd($self);
	}elsif($self->{cgi}->param('page')){
		&_links_list($self);
	}

	return;
}

sub _links_regist_top(){
	my $self = shift;
	
	my $html;
	$html = &_load_tmpl("link_regist.html");
	$html = &_parts_set($html);

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	
	return;
}

sub _links_click(){
	my $self = shift;

	my $id = $self->{cgi}->param('clickid');

	my $sth = $self->{dbi}->prepare(qq{select url from app_site where id = ? });
	$sth->execute($id);
	my $url;
	while(my @row = $sth->fetchrow_array) {
		$url = $row[0];
	}
eval{
my $sth2 = $self->{dbi}->prepare(qq{update app_site set out = out + 1 where id = ? limit 1});
$sth2->execute($id);
};

	print qq{Location: $url\n\n};

	return;
}

sub dispatch_review_iphone(){
	my $self = shift;

	if($self->{cgi}->param('mainbody')){
		&_review_iphone($self);
	}elsif($self->{cgi}->param('url')){
		&_review_iphone_pre($self);
	}elsif($self->{cgi}->param('page')){
		&_review_iphone_list($self);
	}elsif($self->{cgi}->param('reviewid')){
		&_detail_dsp_iphone($self);
	}else{
		&_review_iphone_top($self);
	}

	return;
}


sub _review_iphone_list(){
	my $self = shift;
	
	my $page = $self->{cgi}->param('page');
	my $start = ($page - 1) * 30;

	my $html;
	$html = &_load_tmpl("review_iphone_list.html");
	$html = &_parts_set($html);

	my $list;
	my ($id,$app_id,$review,$updated,$author,$target,$age,$name,$url, $img100, $eva, $evacount,$formattedPrice,$genres,$genre_id);
	my $sth = $self->{dbi}->prepare(qq{SELECT A.id,A.app_id,A.review,A.updated,A.author,A.target,A.age,
	                                          B.name, B.url, B.img100, B.eva, B.evacount,B.formattedPrice,B.genres,B.genre_id 
	                                          FROM app_review_iphone as A, app_iphone as B 
	                                          WHERE A.app_id = B.id  order by A.updated asc limit $start, 30});
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		($id,$app_id,$review,$updated,$author,$target,$age,$name,$url, $img100, $eva, $evacount,$formattedPrice,$genres,$genre_id) = @row;

		my $shotimgs;
		my $sth2 = $self->{dbi}->prepare(qq{select type,img1,img2,img3,img4,img5 from app_iphone_img where app_id = ? limit 1});
		$sth2->execute($app_id);
		while(my @row2 = $sth2->fetchrow_array) {
			my ($type,$img1,$img2,$img3,$img4,$img5) = @row2;
			$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img1" alt="$row[0]" /><img src="$img1" alt="$row[0]" class="preview" /></a></li>} if($img1);
			$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img2" alt="$row[0]" /><img src="$img2" alt="$row[0]" class="preview" /></a></li>} if($img2);
			$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img3" alt="$row[0]" /><img src="$img3" alt="$row[0]" class="preview" /></a></li>} if($img3);
			$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img4" alt="$row[0]" /><img src="$img4" alt="$row[0]" class="preview" /></a></li>} if($img4);
			$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img5" alt="$row[0]" /><img src="$img5" alt="$row[0]" class="preview" /></a></li>} if($img5);
		}

		my $img200 = $img100;
		if($img200=~/-75/){
			$img200=~s/175/200/ig;
		}else{
			$img200=~s/\.jpg/\.200x200-75\.jpg/ig;
			$img200=~s/\.png/\.200x200-75\.png/ig;
		}
		$eva=0 unless($eva);
		my $star_str = &_star_img($eva);
		my $price_str = &_price_str($formattedPrice);
		my $genrestr = substr($genres,0,30);
		$genrestr.=qq{...};

		my $ex_str = substr($review,0,400);
		$ex_str.=qq{...};

		$list .= qq{<tr>};
		$list .= qq{<td width="200" bgcolor="#000000">};
		$list .= qq{<font color="#FFFFFF">};
		$list .= qq{<span class="rounded-img" style="background: url($img200) no-repeat center center; width: 200px; height: 200px;"><a href="/iphoneapp-review-$app_id-$id/" target="_blank" rel="nofollow"><img src="$img200" style="opacity: 0;" alt="$row[0]" /></a></span>};
		$list .= qq{<br />};
		$list .=qq{<p><img src="/img/E20D_20.gif" width="15">$name</p>};
		$list .=qq{<a href="/category$genre_id-iphone-app-1/">$genrestr</a><br />};
		$list .= qq{<p>	$star_str ($evacount)<br />$price_str<br />};
		$list .= qq{<form action="/click.htm" target="_blank" ref="nofollow"><input type="hidden" name="app_id" value="$app_id"><input type="hidden" name="id" value="$id"><input type="hidden" name="type" value="1"><button class="btn primary" type="submit">アプリをインストール</button></form>};
		$list .= qq{</font>};
		$list .= qq{</p>};
		$list .= qq{</td>};
		$list .= qq{<td>};
		$list .= qq{$ex_str<br /><br />};
		$list .= qq{<ul class="hoverbox">};
		$list .= qq{$shotimgs};
		$list .= qq{</ul>};
		$list .= qq{</td>};
		$list .= qq{</tr>};


	}
	if($list){
		$list = qq{<table><tbody>}.$list.qq{</tbody></table>};
	}
	$html =~s/<!--LIST-->/$list/g;

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}

sub _review_iphone(){
	my $self = shift;
	
	my $app_id = $self->{cgi}->param('app_id');
	
	my $html;
	$html = &_load_tmpl("review_iphone_end.html");
	$html = &_parts_set($html);

	my $date = Date::Simple->new();
	my $ymd = $date->format('%Y/%m/%d');
	# DB登録
	my $id;
	my $sth = $self->{dbi}->prepare(qq{SELECT id FROM app_review_iphone WHERE app_id = ? and updated = ?});
	$sth->execute($app_id,$ymd);
	while(my @row = $sth->fetchrow_array) {
		$id = $row[0];
	}
eval{
	if($id){
		my $sth = $self->{dbi}->prepare(qq{update app_review_iphone set review = ? where id = ? limit 1 });	 
		$sth->execute($self->{cgi}->param('mainbody'));
	}else{
		my $sth = $self->{dbi}->prepare(qq{insert into app_review_iphone (`app_id`,`review`,`updated`,`author`,`target`,`age`,`tanto`,`email`) values(?,?,?,?,?,?,?,?)});
		$sth->execute($app_id,$self->{cgi}->param('mainbody'),$ymd,$self->{cgi}->param('autohr'),$self->{cgi}->param('target'),$self->{cgi}->param('age'),$self->{cgi}->param('tanto'),$self->{cgi}->param('email'));
	}
};

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}

sub _review_iphone_pre(){
	my $self = shift;
	
	my $url = $self->{cgi}->param('url');

	my $data = &itunes_page_lookup($url);

#print $url."\n";
#print $data->{trackId}."\n";

	my $html;
	if($data->{trackId}){
		&app_iphone_data($self->{dbi}, $data);

		# カテゴリ名
		my $sth = $self->{dbi}->prepare(qq{select name from app_category where id = ? limit 1});
		$sth->execute($app_data->{genre_id});
		while(my @row = $sth->fetchrow_array) {
			$html =~s/<!--genre_name_jp-->/$row[0]/g;
		}

		$html = &_load_tmpl("review_iphone_pre.html");
		$html = &_parts_set($html);

		$data->{img200}=$data->{img100};
		$data->{img200}=~s/\.jpg/\.200x200-75\.jpg/g;
		$data->{img200}=~s/\.png/\.200x200-75\.png/g;

		foreach my $key ( sort keys( %{$data} ) ) {
			$html =~s/<!--$key-->/$data->{$key}/g;
		}
		my $ex_str = substr($data->{description},0,300);
		$html =~s/<!--EXSTR-->/$ex_str/g;

	}else{
		$html = &_load_tmpl("review_iphone.html");
		my $err = qq{<font color="#FF0000" size=1> ERROR URL page not found</font>};
		$html =~s/<!--ERROR-->/$err/g;
		$html = &_parts_set($html);
	}

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}

sub _review_iphone_top(){
	my $self = shift;

	my $html;
	$html = &_load_tmpl("review_iphone.html");
	$html = &_parts_set($html);

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}


sub dispatch_review_android(){
	my $self = shift;

	if($self->{cgi}->param('mainbody')){
		&_review_android($self);
	}elsif($self->{cgi}->param('url')){
		&_review_android_pre($self);
	}elsif($self->{cgi}->param('page')){
		&_review_android_list($self);
	}elsif($self->{cgi}->param('reviewid')){
		&_detail_dsp_android($self);
	}else{
		&_review_android_top($self);
	}

	return;
}

sub _review_android_list(){
	my $self = shift;
	
	my $page = $self->{cgi}->param('page');
	my $start = ($page - 1) * 30;

	my $html;
	$html = &_load_tmpl("review_android_list.html");
	$html = &_parts_set($html);

	my $list;
	my ($id,$app_id,$review,$updated,$author,$target,$age,$name,$url, $img100, $eva, $evacount,$formattedPrice,$genres,$genre_id);
	my $sth = $self->{dbi}->prepare(qq{SELECT A.id,A.app_id,A.review,A.updated,A.author,A.target,A.age,
	                                          B.name, B.url, B.img, B.rateno, B.revcnt,B.price,B.category_name,B.category_id 
	                                          FROM app_review_android as A, app_android as B 
	                                          WHERE A.app_id = B.id  order by A.updated asc limit $start, 30});
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		($id,$app_id,$review,$updated,$author,$target,$age,$name,$url, $img100, $eva, $evacount,$formattedPrice,$genres,$genre_id) = @row;

		my $shotimgs;
		my $sth2 = $self->{dbi}->prepare(qq{select type,img1,img2,img3,img4,img5 from app_android_img where app_id = ? limit 1});
		$sth2->execute($app_id);
		while(my @row2 = $sth2->fetchrow_array) {
			my ($type,$img1,$img2,$img3,$img4,$img5) = @row2;
			$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img1" alt="$row[0]" /><img src="$img1" alt="$row[0]" class="preview" /></a></li>} if($img1);
			$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img2" alt="$row[0]" /><img src="$img2" alt="$row[0]" class="preview" /></a></li>} if($img2);
			$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img3" alt="$row[0]" /><img src="$img3" alt="$row[0]" class="preview" /></a></li>} if($img3);
			$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img4" alt="$row[0]" /><img src="$img4" alt="$row[0]" class="preview" /></a></li>} if($img4);
			$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img5" alt="$row[0]" /><img src="$img5" alt="$row[0]" class="preview" /></a></li>} if($img5);
		}

		my $img200 = $img100;
		$eva=0 unless($eva);
		my $star_str = &_star_img($eva);
		my $price_str = &_price_str($formattedPrice);
		my $genrestr = substr($genres,0,30);
		$genrestr.=qq{...};

		my $ex_str = substr($review,0,400);
		$ex_str.=qq{...};

		$list .= qq{<tr>};
		$list .= qq{<td width="200" bgcolor="#000000">};
		$list .= qq{<font color="#FFFFFF">};
		$list .= qq{<span class="rounded-img" style="background: url($img200) no-repeat center center; width: 200px; height: 200px;"><a href="/androidapp-review-$app_id-$id/" target="_blank" rel="nofollow"><img src="$img200" style="opacity: 0;" alt="$row[0]" /></a></span>};
		$list .= qq{<br />};
		$list .=qq{<p><img src="/img/E20D_20.gif" width="15">$name</p>};
		$list .=qq{<a href="/category$genre_id-android-app-1/">$genrestr</a><br />};
		$list .= qq{<p>	$star_str ($evacount)<br />$price_str<br />};
		$list .= qq{<form action="/click.htm" target="_blank" ref="nofollow"><input type="hidden" name="app_id" value="$app_id"><input type="hidden" name="id" value="$id"><input type="hidden" name="type" value="2"><button class="btn primary" type="submit">アプリをインストール</button></form>};
		$list .= qq{</font>};
		$list .= qq{</p>};
		$list .= qq{</td>};
		$list .= qq{<td>};
		$list .= qq{$ex_str<br /><br />};
		$list .= qq{<ul class="hoverbox">};
		$list .= qq{$shotimgs};
		$list .= qq{</ul>};
		$list .= qq{</td>};
		$list .= qq{</tr>};


	}
	if($list){
		$list = qq{<table><tbody>}.$list.qq{</tbody></table>};
	}
	$html =~s/<!--LIST-->/$list/g;

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}

sub _review_android(){
	my $self = shift;
	
	my $app_id = $self->{cgi}->param('app_id');
	
	my $html;
	$html = &_load_tmpl("review_android_end.html");
	$html = &_parts_set($html);

	my $date = Date::Simple->new();
	my $ymd = $date->format('%Y/%m/%d');
	# DB登録
	my $id;
	my $sth = $self->{dbi}->prepare(qq{SELECT id FROM app_review_android WHERE app_id = ? and updated = ?});
	$sth->execute($app_id,$ymd);
	while(my @row = $sth->fetchrow_array) {
		$id = $row[0];
	}
eval{
	if($id){
		my $sth = $self->{dbi}->prepare(qq{update app_review_android set review = ? where id = ? limit 1 });	 
		$sth->execute($self->{cgi}->param('mainbody'));
	}else{
		my $sth = $self->{dbi}->prepare(qq{insert into app_review_android (`app_id`,`review`,`updated`,`author`,`target`,`age`,`tanto`,`email`) values(?,?,?,?,?,?,?,?)});
		$sth->execute($app_id,$self->{cgi}->param('mainbody'),$ymd,$self->{cgi}->param('autohr'),$self->{cgi}->param('target'),$self->{cgi}->param('age'),$self->{cgi}->param('tanto'),$self->{cgi}->param('email'));
	}
};

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}

sub _review_android_pre(){
	my $self = shift;
	
	my $url = $self->{cgi}->param('url');

	my $data = &googleplay_page($url);


	my $html;
	if($data->{android_id}){
		&app_android_data($self->{dbi}, $data);

		$html = &_load_tmpl("review_android_pre.html");
		$html = &_parts_set($html);

		foreach my $key ( sort keys( %{$data} ) ) {
			$html =~s/<!--$key-->/$data->{$key}/g;
		}
		my $ex_str = substr($data->{detail},0,300);
		$html =~s/<!--EXSTR-->/$ex_str/g;

	}else{
		$html = &_load_tmpl("review_android.html");
		my $err = qq{<font color="#FF0000" size=1> ERROR URL page not found</font>};
		$html =~s/<!--ERROR-->/$err/g;
		$html = &_parts_set($html);
	}

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}

sub _review_android_top(){
	my $self = shift;

	my $html;
	$html = &_load_tmpl("review_android.html");
	$html = &_parts_set($html);

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
	$html = &_parts_set($html);
	my $date = Date::Simple->new();
	my $ymd = $date->format('%Y/%m/%d');


eval{

	my $sth = $self->{dbi}->prepare(qq{insert into app_press (`pressdate`,`title`,`mainbody`,`facebook`,`email`,`company`,`type`) values(?,?,?,?,?,?,?)});
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
	my $sth = $self->{dbi}->prepare(qq{insert into app_tmp_url (`url`) values(?)});
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
	$html = &_parts_set($html);

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}


sub dispatch_search(){
	my $self = shift;

	my $html;
	$html = &_load_tmpl("search.html");
	$html = &_parts_set($html);
	my $keyword = $self->{cgi}->param('q');
	$html =~s/<!--KEYWORD-->/$keyword/g;

eval{
	my $sth = $self->{dbi}->prepare(qq{insert into app_keyword (`app_keyword`) values(?)});
	$sth->execute($keyword);
};

	# item
	my $list;
	my $sth = $self->{dbi}->prepare(qq{select id, img, dl_url, appname, ex_str, device, category, developer, price, sale, rdate, eva, review, rank, saledate from app where appname like "%$keyword%" and device <=5 order by review desc limit 100 });
	$sth->execute();
	my $no = 0;
	while(my @row = $sth->fetchrow_array) {
		$no++;
		if($type_free eq 1){
			next if($row[9] != 0);
		}
		$list .= qq{<tr>\n};
		$list .= qq{<td><b>$no</b></td>\n};
		$list .= qq{<td width=10%><span class="rounded-img" style="background: url($row[1]) no-repeat center center; width: 100px; height: 100px;"><a href="/app-$row[0]/" target="_blank"><img src="$row[1]" style="opacity: 0;" alt="無料アプリ $row[2]" /></span></td>\n};
		my $star_str = &_star_img($row[11]);
		my $review = qq{未評価};
		$review = $row[12] if($row[12]);

		my $price_str;
		if($type_free eq 2){
			if($row[8] > $row[9]){
				if($row[9] eq 0){
					$price_str .= qq{<S>$row[8]</S> → <font color="#FF0000"><b>無料!!</b></font>};
				}else{
					$price_str .= qq{<S>$row[8]</S> → <font color="#FF0000"><b>$row[9]</b></font>};
				}
			}else{
				$price_str .= qq{<b>$row[8]</b>};
			}
		}elsif($type_free){
			$price_str .= qq{<S>$row[8]</S> → <font color="#FF0000"><b>無料!!</b></font>};
		}else{
			$price_str .= qq{<font color="#FF0000"><b>無料!!</b></font>};
		}

		my $facebook = qq{<a href="/app-$row[0]/" target="_blank"><img src="/img/facebook_like.png" width="80"></a>};

		$list .= qq{<td width=20%><a href="/app-$row[0]/">$row[3]</a><br />$star_str（$review）<br />$price_str<br />$row[10]</td>\n};
		my $exp_short = substr($row[4],0, 200);

		$list .= qq{<td><div class="well">$exp_short</div></td>\n};
		$list .= qq{<td>$facebook</td>\n};
		$list .= qq{</tr>\n};
	}

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
	$html = &_parts_set($html);
	
	my $dl_url = $self->{cgi}->param('url');
	
	if($dl_url=~/android|play\.google/){
		&_android($self,$dl_url);
	}else{
		&_iphone($self,$dl_url);
	}

eval{
	my $sth = $self->{dbi}->prepare(qq{insert into app_tmp_url (`url`) values(?)});
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
	$html = &_parts_set($html);

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}

sub _android(){
	my $self = shift;
	my $dl_url = shift;

	my $data = &googleplay_page($dl_url);

	# 存在確認
	my $exist_flag;
	my $sth = $self->{dbi}->prepare(qq{SELECT id FROM app where android_id = ? });
	$sth->execute($data->{android_id});
	while(my @row = $sth->fetchrow_array) {
		$exist_flag = 1;
		&_android_upd($self,$row[0],$data);
	}
	
	unless($exist_flag){
		&_android_ins($self,$data);
	}
	
	return;
}

sub _android_upd(){
	my $self = shift;
	my $id = shift;
	my $data = shift;

eval{
my $sth = $self->{dbi}->prepare(qq{update app set img=?,dl_url=?,appname=?,ex_str=?,device=?,category=?,developer=?,lang_flag=?,rdate=?,eva=?,review=?,price=?,updated = NOW() where id = ? limit 1} );
$sth->execute($data->{icon},$data->{dl_url},$data->{name},$data->{detail},4,$data->{category_id},$data->{developer_name},$data->{lang},$data->{rdate} ,$data->{rateno},$data->{revcnt},$data->{sale_price},$id);
};
eval{
my $sth2 = $self->{dbi}->prepare(qq{insert into app_info ( `app_id`,`sshot1`,`sshot2`,`sshot3`,`sshot4`,`sshot5`,`exp` ) values (?,?,?,?,?,?,?)} );
$sth2->execute($id,$data->{shot1},$data->{shot2},$data->{shot3},$data->{shot4},$data->{shot5},$data->{detail});
};
	
	return;
}

sub _android_ins(){
	my $self = shift;
	my $data = shift;

eval{
my $sth2 = $self->{dbi}->prepare(qq{insert into app ( `img`,`dl_url`,`appname`,`ex_str`,`device`,`category`,`developer`,`lang_flag` ) values (?,?,?,?,?,?,?,?)} );
$sth2->execute($data->{icon},$data->{dl_url},$data->{name},$data->{detail},4,$data->{category_id},$data->{developer_name},$data->{lang});
};

my $sth2 = $self->{dbi}->prepare(qq{SELECT id FROM app where dl_url = ? limit 1 });
$sth2->execute($data->{dl_url});
while(my @row = $sth2->fetchrow_array) {
	$app_id = $row[0];
}

eval{
my $sth2 = $self->{dbi}->prepare(qq{update app set rdate=?,eva=?,review=?,price=? where id = ? });
$sth2->execute($data->{rdate} ,$data->{rateno},$data->{revcnt},$data->{sale_price},$app_id);
my $sth2 = $self->{dbi}->prepare(qq{insert into app_info ( `app_id`,`sshot1`,`sshot2`,`sshot3`,`sshot4`,`sshot5`,`exp` ) values (?,?,?,?,?,?,?)} );
$sth2->execute($app_id,$data->{shot1},$data->{shot2},$data->{shot3},$data->{shot4},$data->{shot5},$data->{detail});
};
	return;
}



sub _iphone(){
	my $self = shift;
	my $dl_url = shift;

	my $data = &itunes_page_lookup($dl_url);
	&app_data($self->{dbi}, $data);
	return;

	# 存在確認
	my $exist_flag;
	my $sth = $self->{dbi}->prepare(qq{SELECT id FROM app where iphone_id = ? });
	$sth->execute($data->{iphone_id});
	while(my @row = $sth->fetchrow_array) {
		$exist_flag = 1;
		&_iphone_upd($self,$row[0],$data);
	}
	
	unless($exist_flag){
		&_iphone_ins($self,$data);
	}
	
	return;
}

sub _iphone_upd(){
	my $self = shift;
	my $id = shift;
	my $data = shift;

my $sth;

my $sth = $self->{dbi}->prepare(qq{update app set img=?,dl_url=?,appname=? ,updated = now() where id = ? } );
$sth->execute($data->{icon},$data->{dl_url},$data->{name},$id);
$sth = $self->{dbi}->prepare(qq{update app set ex_str=? where id = ? } );
$sth->execute($data->{detail},$id);

$sth = $self->{dbi}->prepare(qq{update app set device=?,category=?,developer=?,lang_flag=?,iphone_id=?,rdate=?,eva=?,review=?,price=? where id = ? } );
$sth->execute(2,$data->{category_id},$data->{developer_name},$data->{lang},$data->{iphone_id},$data->{rdate} ,$data->{rateno},$data->{revcnt},$data->{sale_price},$id);

my $sth2;
$sth2 = $self->{dbi}->prepare(qq{update app set app_id=?,sshot1=?,sshot2=?,sshot3=?,sshot4=?,sshot5=?,`exp`=?} );
$sth2->execute($id,$data->{shot1},$data->{shot2},$data->{shot3},$data->{shot4},$data->{shot5},$data->{detail});

	return;
}

sub _iphone_ins(){
	my $self = shift;
	my $data = shift;
	
eval{
my $sth = $self->{dbi}->prepare(qq{insert into app ( `img`,`dl_url`,`appname`,`ex_str`,`device`,`category`,`developer`,`lang_flag`,`iphone_id` ) values (?,?,?,?,?,?,?,?,?)} );
$sth->execute($data->{icon},$data->{dl_url},$data->{name},$data->{detail},2,$data->{category_id},$data->{developer_name},$data->{lang},$data->{iphone_id});
};

my $sth = $self->{dbi}->prepare(qq{SELECT id FROM app where dl_url = ? limit 1 });
$sth->execute($data->{dl_url});
while(my @row = $sth->fetchrow_array) {
	$app_id = $row[0];
}

eval{
my $sth2 = $self->{dbi}->prepare(qq{update app set rdate=?,eva=?,review=?,price=? where id = ? });
$sth2->execute($data->{rdate} ,$data->{rateno},$data->{revcnt},$data->{sale_price},$app_id);
my $sth2 = $self->{dbi}->prepare(qq{insert into app_info ( `app_id`,`sshot1`,`sshot2`,`sshot3`,`sshot4`,`sshot5`,`exp` ) values (?,?,?,?,?,?,?)} );
$sth2->execute($app_id,$data->{shot1},$data->{shot2},$data->{shot3},$data->{shot4},$data->{shot5},$data->{detail});
};
	return;
}

sub dispatch(){
	my $self = shift;

	# 切り替え
	if($self->{cgi}->param('iphoneid')){
		&_detail_dsp_iphone($self);
		return;
	}

	if($self->{cgi}->param('androidid')){
		&_detail_dsp_android($self);
		return;
	}

	my $appid = $self->{cgi}->param('id');
	# 更新
	if($self->{cgi}->param('upd')){
		my $sth = $self->{dbi}->prepare(qq{select dl_url,device from app where id = ? limit 1});
		$sth->execute($appid);
		while(my @row = $sth->fetchrow_array) {
			if($row[1] >= 4){
				&_android($self,$row[0]);
			}else{
				&_iphone($self,$row[0]);
			}
		}
	}

	# item
	my ($img, $dl_url, $appname, $ex_str, $device, $category, $developer, $price, $sale, $cnt, $lang_flag, $rdate, $eva, $review, $dl_mini, $dl_max, $rank, $saledate);
	my $sth = $self->{dbi}->prepare(qq{select img, dl_url, appname, ex_str, device, category, developer, price, sale, cnt, lang_flag, rdate, eva, review, dl_mini, dl_max, rank, saledate from app where id = ? limit 1});
	$sth->execute($appid);
	while(my @row = $sth->fetchrow_array) {
		($img, $dl_url, $appname, $ex_str, $device, $category, $developer, $price, $sale, $cnt, $lang_flag, $rdate, $eva, $review, $dl_mini, $dl_max, $rank, $saledate) = @row;
	}

	# カテゴリ(iphone/android)
	my ($c_name, $c_category, $c_cnt, $c_flag, $game, $c_key_value, $c_img);
	my $sth = $self->{dbi}->prepare(qq{select name, category, cnt, flag, game, key_value, img from app_category where id = ? limit 1});
	$sth->execute($category);
	while(my @row = $sth->fetchrow_array) {
		($c_name, $c_category, $c_cnt, $c_flag, $game, $c_key_value, $c_img) = @row;
	}

	# アプリ本体
	my ($sshot1, $sshot2, $sshot3, $sshot4, $sshot5,$exp_long);
	my $sth = $self->{dbi}->prepare(qq{select sshot1,sshot2,sshot3,sshot4,sshot5,exp from app_info where app_id = ? limit 1});
	$sth->execute($appid);
	while(my @row = $sth->fetchrow_array) {
		($sshot1, $sshot2, $sshot3, $sshot4, $sshot5,$exp_long) = @row;
	}

	my $html;
	if($device < 4){
		$html = &_load_tmpl("app_iphone.html");
	}else{
		$html = &_load_tmpl("app_android.html");
	}

	# 画面ショット
	my $shotimgs;
	$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$sshot1" alt="$appname" /><img src="$sshot1" alt="$appname" class="preview" /></a></li>} if($sshot1);
	$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$sshot2" alt="$appname" /><img src="$sshot2" alt="$appname" class="preview" /></a></li>} if($sshot2);
	$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$sshot3" alt="$appname" /><img src="$sshot3" alt="$appname" class="preview" /></a></li>} if($sshot3);
	$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$sshot4" alt="$appname" /><img src="$sshot4" alt="$appname" class="preview" /></a></li>} if($sshot4);
	$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$sshot5" alt="$appname" /><img src="$sshot5" alt="$appname" class="preview" /></a></li>} if($sshot5);
	$html =~s/<!--SHOTIMGS-->/$shotimgs/g;

	my $shotimgs_full;
	$shotimgs_full .= qq{<form action="/app.htm" method="post"><input type="hidden" name="id" value="$appid"><input type="hidden" name="upd" value="1"><input type="submit" value="最新の情報で更新する"></form><br />};
	$shotimgs_full .= qq{<img src="$sshot1" alt="$appname"> } if($sshot1);
	$shotimgs_full .= qq{<img src="$sshot2" alt="$appname"><br /> } if($sshot2);
	$shotimgs_full .= qq{<img src="$sshot3" alt="$appname"> } if($sshot3);
	$shotimgs_full .= qq{<img src="$sshot4" alt="$appname"><br /> } if($sshot4);
	$shotimgs_full .= qq{<img src="$sshot5" alt="$appname"> } if($sshot5);
	$html =~s/<!--SHOTIMGS_FULL-->/$shotimgs_full/g;

	$eva=0 unless($eva);
	my $star_str = &_star_img($eva);

	$html = &_parts_set($html);

	$ex_str = substr($ex_str,0,300);

	$img =~s/175x175/200x200/g;
	$html =~s/<!--IMG-->/$img/g;
	$html =~s/<!--STAR-->/$star_str/g;
	$html =~s/<!--VAL-->/$review/g;
	$html =~s/<!--C_NAME-->/$c_name/g;
	$html =~s/<!--CATEGORY-->/$category/g;
	$html =~s/<!--DL_URL-->/$dl_url/g;
	$html =~s/<!--APPNAME-->/$appname/g;
	$html =~s/<!--EX_STR-->/$ex_str/g;
	$html =~s/<!--EXP_LONG-->/$exp_long/g;
	$html =~s/<!--DEVELOPER-->/$developer/g;

	# 価格
	if($price == 0){
		$sale= "無料" if($sale==0);
		$price=qq{<font color="#FF0000">$sale</font>};
	}if($price > $sale){
		$sale= "無料" if($sale==0);
		$price=qq{<S>$price</S> → <font color="#FF0000">$sale</font>};
	}else{
		$price=qq{<font color="#FF0000">$price</font>};
	}
	$html =~s/<!--PRICE-->/$price/g;
	$html =~s/<!--RDATE-->/$rdate/g;
	$html =~s/<!--EVA-->/$eva/g;
	$html =~s/<!--REVIEW-->/$review/g;
	$html =~s/<!--DL_MINI-->/$dl_mini/g;
	$html =~s/<!--DL_MAX->/$dl_max/g;
	$html =~s/<!--RANK->/$rank/g;

	# レコメンド
	my $list = &_recomment($self,$category);
	$html =~s/<!--LIST-->/$list/g;
print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}

sub _recomment(){
	my $self = shift;
	my $category_id = shift;
	
	my $startno;
	my $list;
	my $order_str = qq{ order by eva desc };
	my $sth = $self->{dbi}->prepare(qq{select id, img, dl_url, appname, ex_str, device, category, developer, price, sale, rdate, eva, review, rank, saledate from app where category = ? $order_str limit 10 });
	$sth->execute($category_id);
	$startno = 0 unless($startno);
	my $no = $startno;
	while(my @row = $sth->fetchrow_array) {
		$no++;
		if($type_free eq 1){
			next if($row[9] != 0);
		}
		my $img = $row[1];
		$img =~s/175x175/100x100/g;
		$list .= qq{<tr>\n};
		$list .= qq{<td><b>$no</b></td>\n};
		$list .= qq{<td width=10%><span class="rounded-img" style="background: url($img) no-repeat center center; width: 100px; height: 100px;"><a href="/app-$row[0]/" target="_blank"><img src="$row[1]" style="opacity: 0;" alt="無料アプリ $row[2]" /></span></td>\n};
		my $star_str = &_star_img($row[11]);
		my $review = qq{未評価};
		$review = $row[12] if($row[12]);

		my $price_str;
		if($type_free eq 2){
			if($row[8] > $row[9]){
				if($row[8] eq 0){
					$price_str .= qq{<font color="#FF0000"><b>無料!!</b></font>};
				}else{
					$price_str .= qq{<S>$row[8]</S> → <font color="#FF0000"><b>$row[9]</b></font>};
				}
			}else{
				$price_str .= qq{<b>$row[8]</b>};
			}
		}elsif($type_free){
			$price_str .= qq{<S>$row[8]</S> → <font color="#FF0000"><b>無料!!</b></font>};
		}else{
			$price_str .= qq{<font color="#FF0000"><b>無料!!</b></font>};
		}

#		my $facebook = qq{<div class="fb-like" data-href="http://applease.info/app-$row[0]/" data-send="false" data-layout="button_count" data-width="50" data-show-faces="false" data-action="recommend" data-font="lucida grande"></div>};
#		my $twitter = qq{<a href="https://twitter.com/share" class="twitter-share-button" data-url="http://applease.info/app-$row[0]/" data-text="イイ！アプリ:$row[3]" data-count="none" data-lang="ja">ツイート</a><script type="text/javascript" src="//platform.twitter.com/widgets.js"></script>};

		my $facebook = qq{<a href="/app-$row[0]/" target="_blank"><img src="/img/facebook_like.png" width="80"></a>};

		$list .= qq{<td width=20%><a href="/app-$row[0]/">$row[3]</a><br />$star_str（$review）<br />$price_str<br />$row[10]</td>\n};
		my $exp_short = substr($row[4],0, 200);

		$list .= qq{<td><div class="well">$exp_short</div></td>\n};
		$list .= qq{<td>$facebook</td>\n};
		$list .= qq{</tr>\n};
	}

	return $list;
}

sub _parts_set(){
	my $html = shift;

	# meta
	my $meta = &_load_tmpl("meta.html");
	# header
	my $header = &_load_tmpl("header.html");
	# footer
	my $footer = &_load_tmpl("footer.html");
	# slider
	my $side_free = &_load_tmpl("side_free.html");
	$html =~s/<!--SIDE_FREE-->/$side_free/g;
	my $catelist = &_load_tmpl("cate_list.html");
	$html =~s/<!--CATELIST-->/$catelist/g;

	# ad
	my $ad_header = &_load_tmpl("ad_header.html");
	$html =~s/<!--AD_HEADER-->/$ad_header/g;

	$html =~s/<!--META-->/$meta/g;
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
	
my $file = qq{/var/www/vhosts/goo.to/etc/makehtml/app/tmpl/$tmpl};
my $fh;
my $filedata;
open( $fh, "<", $file );
while( my $line = readline $fh ){ 
	$filedata .= $line;
}
close ( $fh );
	$filedata = &_date_set($filedata);
	$filedata = &_tab_set($filedata,$tmpl);

	return $filedata;
}

sub price_dsp(){
	my $price = shift;

	1 while $price =~ s/(.*\d)(\d\d\d)/$1,$2/;	

	return $price;
}


sub _star_img(){
	my $point = shift;
	$point=~s/ //g;

	my $str;
	$str = qq{<img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">};
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png">} if($point eq "5");
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png">} if($point eq "5.0");
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-half.png">} if($point eq "4.5");
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-off.png">} if($point eq "4");
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-off.png">} if($point eq "4.0");
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-half.png"><img src="/img/star-off.png">} if($point eq "3.5");
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-off.png"><img src="/img/star-off.png">} if($point eq "3");
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-off.png"><img src="/img/star-off.png">} if($point eq "3.0");
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-half.png"><img src="/img/star-off.png"><img src="/img/star-off.png">} if($point eq "2.5");
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">} if($point eq "2");
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">} if($point eq "2.0");
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-half.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">} if($point eq "1.5");
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">} if($point eq "1");
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">} if($point eq "1.0");
	$str = qq{<img src="/img/star-half.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">} if($point eq "0.5");
	$str = qq{<img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">} if($point eq "0");

	return $str;
}

sub DESTROY{
	my $self = shift;

	$self->{db}->disconnect if($self->{db});

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
	$html = &_parts_set($html);
	
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
	$html = &_parts_set($html);
	
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
	$html = &_parts_set($html);

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

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

sub _socialnews_date(){
	my $self = shift;
	my $date = $self->{cgi}->param('date');
	my $html;
	$html = &_load_tmpl("socialnews_date.html");
	$html = &_parts_set($html);

	my $sth = $self->{dbi}->prepare(qq{select id,url,title,type,date,cnt from fmfm where type >= 5 and type < 10 and date = ? order by id desc });	 
	$sth->execute($date);
	my $list;
	while(my @row = $sth->fetchrow_array) {
		my $typename;
		if($type eq 5){
			$typename = qq{アプリ関連};
		}elsif($type eq 6){
			$typename = qq{ソーシャルゲーム関連};
		}else{
			$typename = qq{値下げセール関連};
		}
		$list .= qq{<tr>};
		$list .= qq{<td>$row[2] <br /><a href="$row[1]" target="_blank" ref="nofollow">情報を見る</a></td>};
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
	$html = &_parts_set($html);
	my $page = 0;
	$page = $self->{cgi}->param('page');
	$page = 0 if($page <=0);
	my $pagemax = 50;
	my $start = 0 + ($pagemax * ($page - 1));

	my $sth = $self->{dbi}->prepare(qq{select id,url,title,type,date,cnt from fmfm where type >= 5 and type < 10  order by id desc limit $start,$pagemax});	 
	$sth->execute();
	my $list;
	while(my @row = $sth->fetchrow_array) {
		my $typename;
		if($type eq 5){
			$typename = qq{アプリ関連};
		}elsif($type eq 6){
			$typename = qq{ソーシャルゲーム関連};
		}else{
			$typename = qq{値下げセール関連};
		}
		$list .= qq{<tr>};
		$list .= qq{<td>$row[2] <br /><a href="$row[1]" target="_blank" ref="nofollow">情報を見る</a></td>};
		$list .= qq{<td>$typename</td>};
		my $date = $row[4];
		$list .= qq{<td><a href="/app-topics$date/">$row[4]</a></td>};
		$list .= qq{<td>$row[5]</td>};
		$list .= qq{</tr>};
	}
	my $pager = &_pager($page,"apptopics");
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
		&_review_top($self);
	}elsif($self->{cgi}->param('who')){
		&_review($self);
	}else{
	}

	return;
}

sub _review(){
	my $self = shift;

	my $html;
	$html = &_load_tmpl("review_regist_end.html");
	$html = &_parts_set($html);
	my $date = Date::Simple->new();
	my $ymd = $date->format('%Y/%m/%d');


eval{

	my $sth = $self->{dbi}->prepare(qq{insert into app_review (`a_id`,`who`,`mainbody`,`good`,`nickname`,`linkurl`) values(?,?,?,?,?,?)});
	$sth->execute($self->{cgi}->param('a_id'),
	              $self->{cgi}->param('who'),
	              $self->{cgi}->param('mainbody'),
	              $self->{cgi}->param('good'),
	              $self->{cgi}->param('nickname'),
	              $self->{cgi}->param('linkurl')
	              );
};


if($self->{cgi}->param('url')){

eval{
	my $sth = $self->{dbi}->prepare(qq{insert into app_tmp_url (`url`) values(?)});
	$sth->execute($self->{cgi}->param('url'));
};

}	


print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}

sub _review_top(){
	my $self = shift;

	my $html;
	$html = &_load_tmpl("review_regist_check.html");
	$html = &_parts_set($html);

	my $list = qq{<table>};
	my $sth = $self->{dbi}->prepare(qq{select id, img, dl_url, appname, ex_str, device, category, developer, price, sale, rdate, eva, review, rank, saledate from app where id = ? });
	$sth->execute($self->{cgi}->param('id'));
	my $no = $startno;
	while(my @row = $sth->fetchrow_array) {
		$list .= qq{<tr>\n};
		$list .= qq{<td width=10%><span class="rounded-img" style="background: url($row[1]) no-repeat center center; width: 100px; height: 100px;"><a href="/app-$row[0]/" target="_blank"><img src="$row[1]" style="opacity: 0;" alt="無料アプリ $row[2]" /></span></td>\n};
		$list .= qq{<td width=30%><a href="/app-$row[0]/">$row[3]</a><br />$row[10]</td>\n};
		$list .= qq{<td><div class="well">$exp_short</div></td>\n};
		$list .= qq{</tr>\n};
	}
	$list .= qq{</table>};

	$html =~s/<!--LIST-->/$list/g;
    my $id = $self->{cgi}->param('id');
	$html =~s/<!--ID-->/$id/g;

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}

sub _detail_dsp_iphone(){
	my $self = shift;

	my $html = &_load_tmpl("app_iphone_detail.html");
	$html = &_parts_set($html);

	my $reviewid = $self->{cgi}->param('reviewid');
	my $reviewlist;
	if($reviewid){
		my $sth = $self->{dbi}->prepare(qq{SELECT review,updated,author,target,age FROM app_review_iphone where id = ? limit 1});
		$sth->execute($reviewid);
		while(my @row = $sth->fetchrow_array) {
			$reviewlist .= qq{レビュー日：$row[1] };
			$reviewlist .= qq{レビューした人：};
			$reviewlist .= qq{製作者（関係者）} if($row[2] eq 1);
			$reviewlist .= qq{アプリのファン} if($row[2] eq 2);
			$reviewlist .= qq{ライター} if($row[2] eq 3);
			$reviewlist .= qq{その他} if($row[2] eq 9);
			my $rev = $row[0];
			$rev =~s/\n/<br>\n/g;
			$reviewlist .= qq{<div class=well>$rev</div><br /><br /><br />};
		}
		$html =~s/<!--reviewlist-->/$reviewlist/g;
	}
	
	my $iphoneid = $self->{cgi}->param('iphoneid');
	if($self->{cgi}->param('upd')){
		my $data = &itunes_page_lookup($iphoneid);
		&app_iphone_data($self->{dbi}, $data);
	}
	
	my @vals=(id,
				    name,
				    url,
				    artistId,
				    artistName,
				    artistViewUrl,
				    img60,
				    img100,
				    img512,
				    genre_id,
				    genre_name,
				    price,
				    formattedPrice,
				    eva,
				    evaCurrent,
				    evacount,
				    evacountCurrent,
				    evaAdvisory,
				    description,
				    releaseDate,
				    releaseNotes,
				    languageCodes,
				    currency,
				    sellerName,
				    sellerUrl,
				    trackCensoredName,
				    trackContentRating,
				    appversion,
				    supportedDevices,
				    bundleId,
				    features,
				    fileSizeBytes,
				    genreIds,
				    genres);

	my $sql_str;
	for(my $i=0;$i<50;$i++){
		$sql_str .= $vals[$i]."," if($vals[$i]);
		last unless($vals[$i]);
	}
	chop $sql_str;


	my $sth = $self->{dbi}->prepare(qq{select $sql_str from app_iphone where id = ? limit 1});
	$sth->execute($iphoneid);
	my $app_data;
	while(my @row = $sth->fetchrow_array) {
		for(my $i=0;$i<50;$i++){
			$app_data->{$vals[$i]} = $row[$i] if($row[$i]);
		}
	}
	$app_data->{formattedPrice}=~s/\?/¥/g;
	
	$app_data->{img200}=$app_data->{img100};
	if($app_data->{img200}=~/175/){
		$app_data->{img200}=~s/175/200/g;
	}else{
		$app_data->{img200}=~s/\.jpg/\.200x200-75\.jpg/g;
		$app_data->{img200}=~s/\.png/\.200x200-75\.png/g;
	}
	# カテゴリ名
	my $sth = $self->{dbi}->prepare(qq{select name from app_category where id = ? limit 1});
	$sth->execute($app_data->{genre_id});
	while(my @row = $sth->fetchrow_array) {
		$html =~s/<!--genre_name_jp-->/$row[0]/g;
	}
		
	# サムネイルの取得
	my $shotimgs;
	my $shotimgs_full;
	my $appname = $app_data->{name};
	my ($type,$img1,$img2,$img3,$img4,$img5);
	my $sth = $self->{dbi}->prepare(qq{select type,img1,img2,img3,img4,img5 from app_iphone_img where app_id = ? limit 1});
	$sth->execute($iphoneid);
	while(my @row = $sth->fetchrow_array) {
		($type,$img1,$img2,$img3,$img4,$img5) = @row;
		$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img1" alt="$appname" /><img src="$img1" alt="$appname" class="preview" /></a></li>} if($img1);
		$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img2" alt="$appname" /><img src="$img2" alt="$appname" class="preview" /></a></li>} if($img2);
		$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img3" alt="$appname" /><img src="$img3" alt="$appname" class="preview" /></a></li>} if($img3);
		$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img4" alt="$appname" /><img src="$img4" alt="$appname" class="preview" /></a></li>} if($img4);
		$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img5" alt="$appname" /><img src="$img5" alt="$appname" class="preview" /></a></li>} if($img5);
		$shotimgs_full .= qq{<img src="$img1" alt="$appname"> } if($img1);
		$shotimgs_full .= qq{<img src="$img2" alt="$appname"><br /> } if($img2);
		$shotimgs_full .= qq{<img src="$img3" alt="$appname"> } if($img3);
		$shotimgs_full .= qq{<img src="$img4" alt="$appname"><br /> } if($img4);
		$shotimgs_full .= qq{<img src="$img5" alt="$appname"> } if($img5);
	}
	$html =~s/<!--SHOTIMGS-->/$shotimgs/g;
	$html =~s/<!--SHOTIMGS_FULL-->/$shotimgs_full/g;
	
	$app_data->{releaseNotes}=~s/\n/<br \/>/g;
	$app_data->{description}=~s/\n/<br \/>/g;


	foreach my $key ( sort keys( %{$app_data} ) ) {
		$html =~s/<!--$key-->/$app_data->{$key}/g;
	}
	my $eva = $app_data->{eva};
	$eva=0 unless($eva);
	my $star_str = &_star_img($eva);
	$html =~s/<!--STAR-->/$star_str/g;

	my $price_str = &_price_str($app_data->{formattedPrice});
	$html =~s/<!--PRICESTR-->/$price_str/g;

	my $ex_str = substr($app_data->{description},0,300);
	$html =~s/<!--EXSTR-->/$ex_str/g;

	#　人気ランキング(カテゴリ別)
	my $rank_rec;
	my $rankdate;
	my $sth = $self->{dbi}->prepare(qq{select rankdate from app_iphone_rank order by rankdate limit 1});
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$rankdate = $row[0];
	}
	my $sth = $self->{dbi}->prepare(qq{SELECT name, url, img100, eva, evacount,formattedPrice,app_id
										FROM app_iphone AS A, app_iphone_rank AS B
										WHERE A.id = B.app_id
											AND B.type =1
											AND B.genre =?
											AND B.rankdate = ?
											ORDER BY B.rankno
											LIMIT 8});
	$sth->execute($app_data->{genre_id},$rankdate);
	while(my @row = $sth->fetchrow_array) {
		my $img200 = $row[2];
		$img200=~s/\.jpg/\.200x200-75\.jpg/ig;
		$img200=~s/\.png/\.200x200-75\.png/ig;
		my $eva = $row[3];
		$eva=0 unless($eva);
		my $star_str = &_star_img($eva);
		my $price_str = &_price_str($row[5]);
		$rank_rec.=qq{<div>};
		$rank_rec.=qq{<span class="rounded-img" style="background: url($img200) no-repeat center center; width: 200px; height: 200px;"><a href="/iphoneapp-$row[6]/"><img src="$img200" style="opacity: 0;" alt="$row[0]" /></a></span>};
		$rank_rec.=qq{<p><img src="/img/E20D_20.gif" width="15">$row[0]</p>};
		$rank_rec.=qq{$star_str ($row[4])<br />};
		$rank_rec.=qq{$price_str<br />};

		$rank_rec.=&_af_link($self->{cgi}->param('iphoneid'),$row[1]);
#		$rank_rec.=qq{<form action="$row[1]">};
#		$rank_rec.=qq{<button class="btn primary" type="submit">アプリをインストール</button>};
#		$rank_rec.=qq{</form>};
		$rank_rec.=qq{</div>};

	}
	$html =~s/<!--RANKREC-->/$rank_rec/g;

	# ランダム
	my $rand_start = int(rand(1000));
	my $randam_rec;
	my $sth = $self->{dbi}->prepare(qq{SELECT name, url, img100, eva, evacount,formattedPrice,description,id
										FROM app_iphone
										WHERE eva >= 4
                                            and evacountCurrent >= 80
											LIMIT $rand_start,16});
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my $img100 = $row[2];
		if($img100=~/175/){
			$img100=~s/175/100/ig;
		}else{
			$img100=~s/\.jpg/\.100x100-75\.jpg/ig;
			$img100=~s/\.png/\.100x100-75\.png/ig;
		}
		my $eva = $row[3];
		$eva=0 unless($eva);
		my $star_str = &_star_img($eva);
		my $desc_str = substr($row[6],0,300);
		my $price_str = &_price_str($row[5]);
		$randam_rec.=qq{<tr>};
		$randam_rec.=qq{<td>};
		$randam_rec.=qq{<span class="rounded-img" style="background: url($img100) no-repeat center center; width: 100px; height: 100px;"><a href="/iphoneapp-$row[7]/"><img src="$img100" style="opacity: 0;" alt="$row[0]" /></a></span>};
		$randam_rec.=qq{</td>};
		$randam_rec.=qq{<td  width=30%>};
		$randam_rec.=qq{<p><img src="/img/E20D_20.gif" width="15">$row[0]</p>};
		$randam_rec.=qq{$star_str ($row[4])<br />};
		$randam_rec.=qq{$price_str<br />};

		$randam_rec.=&_af_link($self->{cgi}->param('iphoneid'),$row[1]);

#		$randam_rec.=qq{<form action="$row[1]">};
#		$randam_rec.=qq{<button class="btn primary" type="submit">アプリをインストール</button>};
#		$randam_rec.=qq{</form>};
		$randam_rec.=qq{</td>};
		$randam_rec.=qq{<td>};
		$randam_rec.=qq{<div class=well>};
		$randam_rec.=qq{$desc_str};
		$randam_rec.=qq{</div>};
		$randam_rec.=qq{</td>};
		$randam_rec.=qq{</tr>};

	}
	$html =~s/<!--RANDAMREC-->/$randam_rec/g;

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML
		
	return;
}
sub _price_str(){
	my $price = shift;
	my $price_str;
    $price =~s/\?/¥/g;

	if($price <= 0){
		$price_str = qq{<img src="/img/Free.gif" alt="無料アプリ">};
	}elsif($price eq "無料"){
		$price_str = qq{<img src="/img/Free.gif" alt="無料アプリ">};
	}else{
		$price_str = qq{<img src="/img/E12F_20.gif" height=15> $price};
	}

	return $price_str;
}

sub _date_set(){
	my $html = shift;
	my $date = Date::Simple->new();
	my $ymd = $date->format('%Y/%m/%d');
	$html =~s/<!--DATE-->/$ymd/ig;
	return $html;
}

sub _tab_set(){
	my $html = shift;
	my $tmpl = shift;
	my $type = shift;
	my $tabs;

	my $dir_str=qq{/iphone};
	$dir_str=qq{/android} if($type eq 2);

	my $activ_new;
	$activ_new = qq{ class="active"} if($tmpl eq "new_new.html");
	my $activ_app;
	$activ_app = qq{ class="active"} if($tmpl eq "new_pop.html");
	my $activ_sale;
	$activ_sale = qq{ class="active"} if($tmpl eq "new_sale.html");
	my $activ_ranking;
	$activ_ranking = qq{ class="active"} if($tmpl eq "new_ranking.html");
	my $activ_charge;
	$activ_charge = qq{ class="active"} if($tmpl eq "new_charge.html");
	my $activ_category;
	$activ_category = qq{ class="active"} if($tmpl eq "new_category.html");
	my $activ_news;
	$activ_news = qq{ class="active"} if($tmpl eq "facebooksite.html");

	my $geinou = &html_mojibake_str("geinou");
	my $kyujosho = &html_mojibake_str("kyujosho");
	$tabs .= qq{<div class="container-fluid">\n};
	$tabs .= qq{<ul class="tabs">\n};
	$tabs .= qq{<li$activ_sale><a href="$dir_str/sale-iphone-app-1/">セールアプリ</a></li>\n};
	$tabs .= qq{<li$activ_app><a href="$dir_str/app-1/">アプリまとめ</a></li>\n};
	$tabs .= qq{<li$activ_ranking><a href="$dir_str/ranking-iphone-app-1/">無料アプリランキング</a></li>\n};
	$tabs .= qq{<li$activ_new><a href="$dir_str/new-iphone-app-1/">新着無料アプリ</a></li>\n};
	$tabs .= qq{<li$activ_charge><a href="$dir_str/charge-iphone-app-1/">新着有料アプリ</a></li>\n};
	$tabs .= qq{<li$activ_category><a href="$dir_str/category-iphone-app/">カテゴリ別</a></li>\n};
	$tabs .= qq{<li$activ_category><a href="$dir_str/itunes/">アップル公式</a></li>\n};
	$tabs .= qq{<li$activ_news><a href="$dir_str/news/">ニュース</a></li>\n};
	$tabs .= qq{</ul>\n};
	$tabs .= qq{</div>\n};

	$html =~s/<!--TABS-->/$tabs/gi;
	return $html;
}

sub _detail_dsp_android(){
	my $self = shift;

	my $html = &_load_tmpl("app_android_detail.html");
	$html = &_parts_set($html);

	my $reviewid = $self->{cgi}->param('reviewid');
	my $reviewlist;
	if($reviewid){
		my $sth = $self->{dbi}->prepare(qq{SELECT review,updated,author,target,age FROM app_review_android where id = ? limit 1});
		$sth->execute($reviewid);
		while(my @row = $sth->fetchrow_array) {
			$reviewlist .= qq{レビュー日：$row[1] };
			$reviewlist .= qq{レビューした人：};
			$reviewlist .= qq{製作者（関係者）} if($row[2] eq 1);
			$reviewlist .= qq{アプリのファン} if($row[2] eq 2);
			$reviewlist .= qq{ライター} if($row[2] eq 3);
			$reviewlist .= qq{その他} if($row[2] eq 9);
			my $rev = $row[0];
			$rev =~s/\n/<br>\n/g;
			$reviewlist .= qq{<div class=well>$rev</div><br /><br /><br />};
		}
		$html =~s/<!--reviewlist-->/$reviewlist/g;
	}

	my $androidid = $self->{cgi}->param('androidid');
	if($self->{cgi}->param('upd')){
		my $data = &googleplay_page($iphoneid);
		&app_android_data($self->{dbi}, $data);
	}
	
	my @vals=(id,
 name,
 url,
 developer_id,
 developer_name,
 img,
 category_id,
 category_name,
 rdate,
 install,
 installmax,
 rateno,
 revcnt,
 detail,
 dl_min,
 dl_max,
 price);

	my $sql_str;
	for(my $i=0;$i<20;$i++){
		$sql_str .= $vals[$i]."," if($vals[$i]);
		last unless($vals[$i]);
	}
	chop $sql_str;


	my $sth = $self->{dbi}->prepare(qq{select $sql_str from app_android where id = ? limit 1});
	$sth->execute($androidid);
	my $app_data;
	while(my @row = $sth->fetchrow_array) {
		for(my $i=0;$i<20;$i++){
			$app_data->{$vals[$i]} = $row[$i] if($row[$i]);
		}
	}

	$app_data->{img}=~s/w124/w200/g;
		
	# サムネイルの取得
	my $shotimgs;
	my $appname = $app_data->{name};
	my ($type,$img1,$img2,$img3,$img4,$img5);
	my $sth = $self->{dbi}->prepare(qq{select type,img1,img2,img3,img4,img5 from app_android_img where app_id = ? limit 1});
	$sth->execute($androidid);
	while(my @row = $sth->fetchrow_array) {
		($type,$img1,$img2,$img3,$img4,$img5) = @row;
		$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img1" alt="$appname" /><img src="$img1" alt="$appname" class="preview" /></a></li>} if($img1);
		$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img2" alt="$appname" /><img src="$img2" alt="$appname" class="preview" /></a></li>} if($img2);
		$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img3" alt="$appname" /><img src="$img3" alt="$appname" class="preview" /></a></li>} if($img3);
		$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img4" alt="$appname" /><img src="$img4" alt="$appname" class="preview" /></a></li>} if($img4);
		$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img5" alt="$appname" /><img src="$img5" alt="$appname" class="preview" /></a></li>} if($img5);
		$shotimgs_full .= qq{<img src="$img1" alt="$appname"> } if($img1);
		$shotimgs_full .= qq{<img src="$img2" alt="$appname"><br /> } if($img2);
		$shotimgs_full .= qq{<img src="$img3" alt="$appname"> } if($img3);
		$shotimgs_full .= qq{<img src="$img4" alt="$appname"><br /> } if($img4);
		$shotimgs_full .= qq{<img src="$img5" alt="$appname"> } if($img5);
	}
	$html =~s/<!--SHOTIMGS-->/$shotimgs/g;
	
	foreach my $key ( sort keys( %{$app_data} ) ) {
		$html =~s/<!--$key-->/$app_data->{$key}/g;
	}

	my $rateno = $app_data->{rateno};
	$rateno=0 unless($rateno);
	my $star_str = &_star_img($rateno);
	$html =~s/<!--STAR-->/$star_str/g;

	my $price_str = &_price_str($app_data->{price});
	$html =~s/<!--PRICESTR-->/$price_str/g;

	my $ex_str = substr($app_data->{detail},0,300);
	$html =~s/<!--EXSTR-->/$ex_str/g;

	#　人気ランキング(カテゴリ別)
	my $rank_rec;
	my $rankdate;
	my $sth = $self->{dbi}->prepare(qq{select rankdate from app_android_rank order by rankdate limit 1});
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$rankdate = $row[0];
	}
	my $sth = $self->{dbi}->prepare(qq{SELECT name, url, img, rateno, revcnt,price,app_id
										FROM app_android AS A, app_android_rank AS B
										WHERE A.id = B.app_id
											AND B.type =1
											AND B.genre =?
											AND B.rankdate = ?
											ORDER BY B.rankno
											LIMIT 8});
	$sth->execute($app_data->{category_id},$rankdate);
	while(my @row = $sth->fetchrow_array) {
		my $img200 = $row[2];
		$img200=~s/w124/w200/g;
		my $eva = $row[3];
		$eva=0 unless($eva);
		my $star_str = &_star_img($eva);
		my $price_str = &_price_str($row[5]);
		$rank_rec.=qq{<div>};
		$rank_rec.=qq{<span class="rounded-img" style="background: url($img200) no-repeat center center; width: 200px; height: 200px;"><a href="/androidapp-$row[6]/"><img src="$img200" style="opacity: 0;" alt="$row[0]" /></a></span>};
		$rank_rec.=qq{<p><img src="/img/E20D_20.gif" width="15">$row[0]</p>};
		$rank_rec.=qq{$star_str ($row[4])<br />};
		$rank_rec.=qq{$price_str<br />};
		$rank_rec.=qq{<form action="$row[1]">};
		$rank_rec.=qq{<button class="btn primary" type="submit">アプリをインストール</button>};
		$rank_rec.=qq{</form>};
		$rank_rec.=qq{</div>};

	}
	$html =~s/<!--RANKREC-->/$rank_rec/g;

	# ランダム
	my $rand_start = int(rand(1000));
	my $randam_rec;
	my $sth = $self->{dbi}->prepare(qq{SELECT name, url, img, rateno, revcnt,price,detail,id
										FROM app_android
										WHERE rateno >= 4
											LIMIT $rand_start,16});
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my $img100 = $row[2];
		$img100=~s/w100/w100/g;
		my $eva = $row[3];
		$eva=0 unless($eva);
		my $star_str = &_star_img($eva);
		my $desc_str = substr($row[6],0,300);
		my $price_str = &_price_str($row[5]);
		$randam_rec.=qq{<tr>};
		$randam_rec.=qq{<td>};
		$randam_rec.=qq{<span class="rounded-img" style="background: url($img100) no-repeat center center; width: 100px; height: 100px;"><a href="/androidapp-$row[7]/"><img src="$img100" style="opacity: 0;" alt="$row[0]" /></a></span>};
		$randam_rec.=qq{</td>};
		$randam_rec.=qq{<td  width=30%>};
		$randam_rec.=qq{<p><img src="/img/E20D_20.gif" width="15">$row[0]</p>};
		$randam_rec.=qq{$star_str ($row[4])<br />};
		$randam_rec.=qq{$price_str<br />};
		$randam_rec.=qq{<form action="$row[1]">};
		$randam_rec.=qq{<button class="btn primary" type="submit">アプリをインストール</button>};
		$randam_rec.=qq{</form>};		$randam_rec.=qq{</td>};
		$randam_rec.=qq{<td>};
		$randam_rec.=qq{<div class=well>};
		$randam_rec.=qq{$desc_str};
		$randam_rec.=qq{</div>};
		$randam_rec.=qq{</td>};
		$randam_rec.=qq{</tr>};

	}
	$html =~s/<!--RANDAMREC-->/$randam_rec/g;

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML
		
	return;
}

sub _af_link(){
	my $aid = shift;
	my $link_str = shift;
	
use URI::Escape;
	my $af_link;
	
	if( $ENV{'HTTP_USER_AGENT'} =~/bot/i ){
		$af_link.=qq{<form action="$link_str">};
		$af_link.=qq{<button class="btn primary" type="submit">アプリをインストール</button>};
		$af_link.=qq{</form>};
	}else{
		#https://itunes.apple.com/jp/app/jiu-hu-zhong-xin/id619607676?mt=8&uo=4		
		my $escapestr = uri_escape($link_str);
		
#		my $str = qq{http://click.linksynergy.com/link?id=AfFNaqUQKyA&offerid=94348.}.$aid.qq{&type=2&murl=$escapestr};

		$af_link.=qq{<form action="http://click.linksynergy.com/link">};
		$af_link.=qq{<input type=hidden name=id value="AfFNaqUQKyA">};
		$af_link.=qq{<input type=hidden name=offerid value="94348.$aid">};
		$af_link.=qq{<input type=hidden name=type value=2>};
		$af_link.=qq{<input type=hidden name=murl value="$escapestr">};
		$af_link.=qq{<button class="btn primary" type="submit">アプリをインストール</button>};
		$af_link.=qq{</form>};
		$af_link.=qq{<IMG border=0 width=1 height=1 src="http://ad.linksynergy.com/fs-bin/show?id=AfFNaqUQKyA&bids=94348.}.$aid.qq{&type=2&subid=0" >};

	}

	return $af_link;
}


1;