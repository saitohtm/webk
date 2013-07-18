package Waao::PersonSmax;
use strict;
use DBI;
use CGI;
use Waao::Html5;
use Waao::Data;
use Waao::Utility;
use Date::Simple;
use Cache::Memcached::Fast;

sub dispatch(){
	my $self = shift;

	if($self->{cgi}->param('test')){
		&_test($self);
		exit;
	}

	# memcashed 
	my $accesstype = &access_check();

	my $key = $self->{memkey}.$accesstype.$ENV{REQUEST_URI};
	my $html = $self->{mem}->get($key);
	if($html){
		unless($self->{cgi}->param('clear')){
print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML
		return;
		}
	}
	
	if($self->{cgi}->param('blog')){
		&_blog($self);
	}elsif($self->{cgi}->param('twitter')){
		&_twitter($self);
	}elsif($self->{cgi}->param('search')){
		&_search($self);
	}elsif($self->{cgi}->param('menu')){
		&_menu($self);
	}elsif($self->{cgi}->param('pop')){
		&_pop($self);
	}elsif($self->{cgi}->param('good')){
		&_good($self);
	}elsif($self->{cgi}->param('person')){
		&_person($self);
	}elsif($self->{cgi}->param('photolist')){
		&_photolist($self);
	}elsif($self->{cgi}->param('photoid')){
		&_photo($self);
	}elsif($self->{cgi}->param('qandalist')){
		&_qandalist($self);
	}elsif($self->{cgi}->param('qandaid')){
		&_qanda($self);
	}elsif($self->{cgi}->param('id')){
		&_keyword($self);
	}else{
		&_top($self);
	}
	
	return;
}

sub _test(){
	my $self = shift;

 	my $html;
	$html = &_load_tmpl("test.html",$self);
	$html = &_parts_set($html,$self);

	&_output($self,$html);
	return;
}

sub _search(){
	my $self = shift;

 	my $html;
	$html = &_load_tmpl("search.html",$self);
	$html = &_parts_set($html,$self);
	unless($self->{cgi}->param('entry')){
	&_output($self,$html);
	return;
	}

	unless($self->{cgi}->param('keyword')){
		&_top($self);
		return;
	}
	my $keyword = $self->{cgi}->param('keyword');
eval{
	my $sth = $self->{dbi}->prepare(qq{insert into keyword_search (`keyword`,`delflag`) values(?,0)});
	$sth->execute($keyword);
};
	my $keywordid;
	my $sth = $self->{dbi}->prepare(qq{select id from keyword where keyword = ?});
	$sth->execute($keyword);
	while(my @row = $sth->fetchrow_array) {
		$keywordid = $row[0];
	}

	if($keywordid){
		&_keyword($self,$keywordid);
		return;
	}else{
		my $msg = qq{該当する検索結果がありませんでした。<br>リクエストとして受付ましたので、しばらくお待ちください。<br><br><br>};
		$html =~s/<!--RESULT-->/$msg/g;
	}

	&_output($self,$html);
	return;
}

sub _blog(){
	my $self = shift;

 	my $html;
	$html = &_load_tmpl("blog.html",$self);
	$html = &_parts_set($html,$self);

	my $id = $self->{cgi}->param('id');
	my ($datacnt, $keyworddata) = &get_keyword($self, "", $id);
	$html =~s/<!--NAME-->/$keyworddata->{keyword}/g;
	$html =~s/<!--URL-->/$keyworddata->{blogurl}/g;
	$html =~s/<!--ID-->/$id/g;

	&_output($self,$html);
	return;
}

sub _twitter(){
	my $self = shift;

 	my $html;
	$html = &_load_tmpl("twitter.html",$self);
	$html = &_parts_set($html,$self);
	my $id = $self->{cgi}->param('id');
	my ($datacnt, $keyworddata) = &get_keyword($self, "", $id);

my $twitter_id;
if($keyworddata->{twitterurl} =~/(.*)com\/(.*)/){
	$twitter_id = $2;
}

	$html =~s/<!--NAME-->/$keyworddata->{keyword}/g;
	$html =~s/<!--URL-->/twitter_id/g;
	$html =~s/<!--ID-->/$id/g;

	&_output($self,$html);
	return;
}

sub _qandalist(){
	my $self = shift;

 	my $html;
	$html = &_load_tmpl("qandalist.html",$self);
	$html = &_parts_set($html,$self);

	my $page = $self->{cgi}->param('page');
	$html =~s/<!--PAGE-->/$page/g;
	
	my $start = ($page - 1) * 15;
	my $qandalist;
	my $id = $self->{cgi}->param('id');
	my $sth2 = $self->{dbi}->prepare(qq{select id, question, bestanswer, url,keyword from qanda where keywordid = ? limit $start,15} );
	$sth2->execute($id);
	while(my @row2 = $sth2->fetchrow_array) {
	$html =~s/<!--ID-->/$id/g;
	$html =~s/<!--KEYWORD-->/$row2[4]/g;
		my $answer = substr($row2[2], 0, 64);
		$qandalist.=qq{<ul data-role="listview" data-inset="true">};
		$qandalist.=qq{<li><font color="#555555" size=1><font color="#0035D5">■質問</font>:$row2[1] </font></li>};
		$qandalist.=qq{<li><a href="/keyword-$id/qanda-$row2[0]/"><font color="#555555" size=1><font color="#FF0000">■回答</font>:$answer ...</font></a></li>};
		$qandalist.=qq{</ul>};

	}

	$html =~s/<!--QANDA-->/$qandalist/g;

	&_output($self,$html);
	return;
}

sub _qanda(){
	my $self = shift;

	my $id = $self->{cgi}->param('qandaid');

	if($self->{cgi}->param('type')){
		# qa削除
		my $sth = $self->{dbi}->prepare(qq{delete qanda where id = ? limit 1 });
		$sth->execute($id);

		&_keyword($self);
		return;
	}


 	my $html;
	$html = &_load_tmpl("qanda.html",$self);
	$html = &_parts_set($html,$self);

	my $sth = $self->{dbi}->prepare(qq{select id, question, bestanswer, url from qanda where id = ? limit 1 } );
	$sth->execute($id);
	while(my @row = $sth->fetchrow_array) {
		$html =~s/<!--QUESTION-->/$row[1]/g;
		$html =~s/<!--ANSWER-->/$row[2]/g;
		$html =~s/<!--URL-->/$row[3]/g;

		my $questionmini = substr($row[1], 0, 64);
		my $answermini = substr($row[2], 0, 64);

		$html =~s/<!--QUESTION_MINI-->/$questionmini/g;
		$html =~s/<!--ANSWER_MINI-->/$answermini/g;
	}

	my ($datacnt, $keyworddata) = &get_keyword($self, "", $self->{cgi}->param('id'));
	$html =~s/<!--NAME-->/$keyworddata->{keyword}/g;
	$html =~s/<!--KEYWORDID-->/$keyworddata->{id}/g;

	&_output($self,$html);

	return;
}

sub _menu(){
	my $self = shift;

 	my $html;
	$html = &_load_tmpl("menu.html",$self);
	$html = &_parts_set($html,$self);

	&_output($self,$html);
	return;
}


sub _photolist(){
	my $self = shift;

 	my $html;
	$html = &_load_tmpl("photolist.html",$self);
	$html = &_parts_set($html,$self);

	my $page = $self->{cgi}->param('page');
	$html =~s/<!--PAGE-->/$page/g;
	
	my $start = ($page - 1) * 60;
	my $list;
	my $keyword;

	my $sth2 = $self->{dbi}->prepare(qq{select id, url,good,title,keywordid,keyword from photo where keywordid = ? order by good desc limit $start,60});
	$sth2->execute($self->{cgi}->param('id'));
	while(my @row2 = $sth2->fetchrow_array) {
		$keyword = $row2[5];
		$html =~s/<!--ID-->/$row2[4]/g;
		$html =~s/<!--KEYWORD-->/$row2[5]/g;
		$list .= qq{<div>};
		$list .= qq{<a href="/keyword-$row2[4]/photo-$row2[0]/">};
		$list .= qq{<img src="$row2[1]" width=86></a>};
		my $star = &_star_img($row2[2]);
		$list .= qq{<p>$star</p>};
		$list .= qq{<h3 class="textOverflow">$row2[5]</h3>};
#			$list .= qq{<p class="textOverflow category">$row2[3]</p>};
		$list .= qq{</div>};
	}

	$html =~s/<!--GRID-->/$list/g;

	if($self->{cgi}->param('setword')){
eval{
	my $sth2 = $self->{dbi}->prepare(qq{insert into keyword_search_id (`keyword`,`delflag`,`keyword_id`) values(?,0,?)});
	$sth2->execute($keyword,$self->{cgi}->param('id'));
};
	}

	&_output($self,$html);
	return;
}

sub _photo(){
	my $self = shift;

	my $id = $self->{cgi}->param('photoid');

	if($self->{cgi}->param('type')){
		# 画像削除
	    unless( $ENV{'HTTP_USER_AGENT'} =~/bot/i ){

			my $sth = $self->{dbi}->prepare(qq{update photo set good = 0 where id = ? limit 1 });
			$sth->execute($id);
			my $sth = $self->{dbi}->prepare(qq{insert into photo_check (`photo_id`,`type`) values (?,?)});
			$sth->execute($id,$self->{cgi}->param('type'));
		}
		&_keyword($self);
		return;
	}

 	my $html;
	$html = &_load_tmpl("photo.html",$self);
	$html = &_parts_set($html,$self);
	if($self->{cgi}->param('goodpoint')){
		my $goodpoint = 1;
 		if( $self->{cgi}->param('goodpoint') > 1 ){
			 $goodpoint = $self->{cgi}->param('goodpoint');
		}
		my $sth = $self->{dbi}->prepare(qq{update photo set good = good + $goodpoint where id = ? limit 1 });
		$sth->execute($id);
	}
	my $keywordid;
	my $sth2 = $self->{dbi}->prepare(qq{select id, url,good,title,keywordid,keyword,backurl,fullurl from photo where id=? limit 1});
	$sth2->execute($id);
	while(my @row2 = $sth2->fetchrow_array) {
		my $fullurl = $row2[2];
		if($row2[7] =~/(jpg|jpeg|gif|png|bmp)/){
			$fullurl = $row2[7];
		}
		$html =~s/<!--ID-->/$row2[0]/g;
		$html =~s/<!--URL-->/$row2[1]/g;
		$html =~s/<!--GOOD-->/$row2[2]/g;
		$html =~s/<!--TITLE-->/$row2[3]/g;
		$keywordid = $row2[4];
		$html =~s/<!--KEYWORDID-->/$row2[4]/g;
		$html =~s/<!--KEYWORD-->/$row2[5]/g;
		$html =~s/<!--BACKURL-->/$row2[6]/g;
		$html =~s/<!--FULLURL-->/$fullurl/g;
		my $star = &_star_img($row2[2]);
		$html =~s/<!--STAR-->/$star/g;

	}
eval{
	my $sth = $self->{dbi}->prepare(qq{update keyword set cnt = cnt + 1 where id = ? limit 1 });
	$sth->execute($keywordid);
};
	
	# グループ
	my $list_str = &_keyword_group($self,$keywordid);

	my $randid = int(rand(10));
	if($randid % 2){
		# リスト
		$list_str .= &_keyword_recomend($self,$keywordid);
		unless($list_str){
			$list_str .= &_keyword_genre($self,$keywordid);
		}
		$html =~s/<!--RECLIST-->/$list_str/g;
	}else{
		# ジャンル
		$list_str .= &_keyword_genre($self,$keywordid);
		$html =~s/<!--RECLIST-->/$list_str/g;
	}

	
	&_output($self,$html);

	return;
}

sub _keyword(){
	my $self = shift;
	my $keywordid = shift;
	my $id = $self->{cgi}->param('id');
	$id = $keywordid if($keywordid);
	
 	my $html;
	$html = &_load_tmpl("keyword.html",$self);
	$html = &_parts_set($html,$self);
	$html =~s/<!--ID-->/$id/g;

	my ($datacnt, $keyworddata) = &get_keyword($self, "", $id);
	$html =~s/<!--NAME-->/$keyworddata->{keyword}/g;

	my $list;
	my $sth2 = $self->{dbi}->prepare(qq{select id, url,good,title,keywordid,keyword from photo where keywordid = ? order by good desc limit 9});
	$sth2->execute($id);
	while(my @row2 = $sth2->fetchrow_array) {
		$list .= qq{<div>};
		$list .= qq{<a href="/keyword-$row2[4]/photo-$row2[0]/">};
		$list .= qq{<img src="$row2[1]" width=86></a>};
		my $star = &_star_img($row2[2]);
		$list .= qq{<p>$star</p>};
		$list .= qq{<h3 class="textOverflow">$row2[5]</h3>};
		$list .= qq{</div>};
	}

	$html =~s/<!--GRID-->/$list/g;

	my $links;	
	if($keyworddata->{blogurl}){
		$links .= qq{<li><a href="/?id=$id&blog=1"><img src="/img/E148_20.gif" height="20" class="ui-li-icon">ブログ</a></li>};
	}

	if($keyworddata->{twitterurl}){
		$links .= qq{<li><a href="/?id=$id&twitter=1"><img src="/img/E317_20_ani.gif" height="20" class="ui-li-icon">Twitter</a></li>};
	}
	$html =~s/<!--LINKS-->/$links/g;

	my $prof;	
	if($keyworddata->{birthday}){
		if($keyworddata->{birthday} ne '0000-00-00'){
			$prof .= qq{<strong>生年月日</strong>:$keyworddata->{birthday}<br>};
			my $age = &_calcage($keyworddata->{birthday});
			$prof .= qq{<strong>年齢</strong>:$age歳<br>};
		}
	}
	if($keyworddata->{blood}){
		if($keyworddata->{blood} ne 1){
			$prof .= qq{<strong>血液型</strong>:$keyworddata->{blood}<br>};
		}
	}
	$html =~s/<!--PROF-->/$prof/g;

	my $wikistr;
	if($keyworddata->{simplewiki}){
		$wikistr = $keyworddata->{simplewiki};
	}
	$html =~s/<!--WIKI-->/$wikistr/g;

	my $qandalist;
	my $sth = $self->{dbi}->prepare(qq{select id, question, bestanswer, url from qanda where keywordid = ? order by id desc limit 3 } );
	$sth->execute( $keyworddata->{id} );
	while(my @row = $sth->fetchrow_array) {
		my $answer = substr($row[2], 0, 64);
		$qandalist.=qq{<ul data-role="listview" data-inset="true">};
		$qandalist.=qq{<li><font color="#555555" size=1><font color="#0035D5">■質問</font>:$row[1] </font></li>};
		$qandalist.=qq{<li><a href="/keyword-$id/qanda-$row[0]/"><font color="#555555" size=1><font color="#FF0000">■回答</font>:$answer ...</font></a></li>};
		$qandalist.=qq{</ul>};
	}
	$html =~s/<!--QANDA-->/$qandalist/g;


	&_output($self,$html);

	return;
}

sub _person(){
	my $self = shift;

 	my $html;
	$html = &_load_tmpl("person.html",$self);
	$html = &_parts_set($html,$self);

	my $page = $self->{cgi}->param('page');
	$html =~s/<!--PAGE-->/$page/g;
	
	my $start = ($page - 1) * 60;
	my $list;

	my $meikantype = $self->{cgi}->param('type');
	my ($meikanname, $sql_str) = &_meikan_name($meikantype);

	$html =~s/<!--NAME-->/$meikanname/g;
	$html =~s/<!--TYPE-->/$meikantype/g;

	my $sth = $self->{dbi}->prepare(qq{select id, keyword from keyword where $sql_str order by cnt desc limit $start,60});
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my $sth2 = $self->{dbi}->prepare(qq{select id, url,good,title from photo where keywordid = ? order by good desc limit 1});
		$sth2->execute($row[0]);
		while(my @row2 = $sth2->fetchrow_array) {
			$list .= qq{<div>};
			$list .= qq{<a href="/keyword-$row[0]/">};
			$list .= qq{<img src="$row2[1]" width=86></a>};
			$list .= qq{<h3 class="textOverflow">$row[1]</h3>};
#			$list .= qq{<p class="textOverflow category">$row2[3]</p>};
			$list .= qq{</div>};
		}
	}

	$html =~s/<!--GRID-->/$list/g;

	&_output($self,$html);

	return;
}

sub _good(){
	my $self = shift;

 	my $html;
	$html = &_load_tmpl("good.html",$self);
	$html = &_parts_set($html,$self);

	my $page = $self->{cgi}->param('page');
	$html =~s/<!--PAGE-->/$page/g;
	
	my $start = ($page - 1) * 60;
	my $list;

		my $sth2 = $self->{dbi}->prepare(qq{select id, url,good,title,keywordid,keyword from photo order by good desc limit $start,60});
		$sth2->execute();
		while(my @row2 = $sth2->fetchrow_array) {
			$list .= qq{<div>};
			$list .= qq{<a href="/keyword-$row2[4]/photo-$row2[0]/">};
			$list .= qq{<img src="$row2[1]" width=86></a>};
			$list .= qq{<h3 class="textOverflow">$row2[5]</h3>};
#			$list .= qq{<p class="textOverflow category">$row2[3]</p>};
			$list .= qq{</div>};
		}

	$html =~s/<!--GRID-->/$list/g;

	&_output($self,$html);

	return;
}

sub _pop(){
	my $self = shift;

 	my $html;
	$html = &_load_tmpl("pop.html",$self);
	$html = &_parts_set($html,$self);

	my $page = $self->{cgi}->param('page');
	$html =~s/<!--PAGE-->/$page/g;
	
	my $start = ($page - 1) * 60;
	my $list;

	my $sth = $self->{dbi}->prepare(qq{select id, keyword from keyword where person >= 1 and av is null order by cnt desc limit $start,60});
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my $sth2 = $self->{dbi}->prepare(qq{select id, url,good,title from photo where keywordid = ? order by good desc limit 1});
		$sth2->execute($row[0]);
		while(my @row2 = $sth2->fetchrow_array) {
			$list .= qq{<div>};
			$list .= qq{<a href="/keyword-$row[0]/">};
			$list .= qq{<img src="$row2[1]" width=86></a>};
			$list .= qq{<h3 class="textOverflow">$row[1]</h3>};
#			$list .= qq{<p class="textOverflow category">$row2[3]</p>};
			$list .= qq{</div>};
		}
	}

	$html =~s/<!--GRID-->/$list/g;

	&_output($self,$html);

	return;
}


sub _top(){
	my $self = shift;

 	my $html;
	$html = &_load_tmpl("top.html",$self);
	$html = &_parts_set($html,$self);

	my $list;

	my 	$sth = $self->{dbi}->prepare(qq{ select id, title, bodystr, datestr, type, geturl, ext from rssdata where type = ? order by datestr desc,id limit 12} );
	$sth->execute(6);
	my $cnt;
	while(my @row = $sth->fetchrow_array) {
		next if($row[2] eq "utf8");
		my ($datacnt, $keyworddata) = &get_keyword($self, $row[1]);
		my ($photodatacnt, $photodata) = &get_photo($self, $keyworddata->{id});

		$list .= qq{<div>};
		$list .= qq{<a href="/keyword-$keyworddata->{id}/">};
		$list .= qq{<img src="$photodata->{url}" width=86></a>};
		$list .= qq{<h3 class="textOverflow">$row[1]</h3>};
#			$list .= qq{<p class="textOverflow category">$row2[3]</p>};
		$list .= qq{</div>};
	}

	# 女性タレントの情報
	my $start = int(rand(20));
	my $sth = $self->{dbi}->prepare(qq{select id, keyword from keyword where person = 2 and cnt >= 100 order by cnt desc limit $start,9});
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my $sth2 = $self->{dbi}->prepare(qq{select id, url,good,title from photo where keywordid = ? order by good desc limit 1});
		$sth2->execute($row[0]);
		while(my @row2 = $sth2->fetchrow_array) {
			$list .= qq{<div>};
			$list .= qq{<a href="/keyword-$row[0]/">};
			$list .= qq{<img src="$row2[1]" width=86></a>};
			$list .= qq{<h3 class="textOverflow">$row[1]</h3>};
#			$list .= qq{<p class="textOverflow category">$row2[3]</p>};
			$list .= qq{</div>};
		}
	}

	$html =~s/<!--GRID-->/$list/g;

	&_output($self,$html);

	return;
}

sub _load_tmpl(){
	my $tmpl = shift;
	my $self = shift;
my $file;
$file = qq{/var/www/vhosts/goo.to/etc/makehtml/smax/person_tmpl/$tmpl};


if($ENV{SERVER_NAME} eq 'img.cospa.info'){
	$file = qq{/var/www/vhosts/goo.to/etc/makehtml/smax/cospa_tmpl/$tmpl};
}elsif($ENV{SERVER_NAME} eq 'img.brand-search.biz'){
	$file = qq{/var/www/vhosts/goo.to/etc/makehtml/smax/brand_tmpl/$tmpl};
}elsif($ENV{SERVER_NAME} eq 'photo.webk-vps.com'){
	$file = qq{/var/www/vhosts/goo.to/etc/makehtml/smax/webk_tmpl/$tmpl};
}elsif($ENV{SERVER_NAME} eq 'photo.fxhost.pro'){
	$file = qq{/var/www/vhosts/goo.to/etc/makehtml/smax/fxhost_tmpl/$tmpl};
}

my $fh;
my $filedata;
open( $fh, "<", $file );
while( my $line = readline $fh ){ 
	$filedata .= $line;
}
close ( $fh );

	return $filedata;
}

sub _output(){
	my $self = shift;
	my $html = shift;
	
	my $accesstype = &access_check();
	my $key = $self->{memkey}.$accesstype.$ENV{REQUEST_URI};
	my $flag=1;
	if($self->{cgi}->param('photoid')){
		$flag=undef;
	}
	if($self->{cgi}->param('search')){
		$flag=undef;
	}
	if($flag){
		$self->{mem}->set($key, $html, 60 * 60 * 2);
	}

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}

sub _parts_set(){
	my $html = shift;
	my $self = shift;

	# meta
	my $meta = &_load_tmpl("meta.html", $self);
	$html =~s/<!--META-->/$meta/g;
	# header
	my $header = &_load_tmpl("header.html", $self);
	$html =~s/<!--HEADER-->/$header/g;
	# header
	my $top_html = &_load_tmpl("top_html.html", $self);
	$html =~s/<!--TOP_HTML-->/$top_html/g;
	my $thtml = &_load_tmpl("html.html", $self);
	$html =~s/<!--HTML-->/$thtml/g;
	# footer
	my $footer = &_load_tmpl("footer.html", $self);
	$html =~s/<!--FOOTER-->/$footer/g;

	my $date = Date::Simple->new();
	my $p_from = $date->format('%Y-%m-%d');
	$html =~s/<!--DATE-->/$p_from/g;

	# ad
	my $ad_header;
	my $ad_imobile;
	
	my $accesstype = &access_check();
	if($accesstype eq 3){
		$ad_header = &_load_tmpl("adlantice.html", $self);
		$ad_imobile = &_load_tmpl("imobile.html", $self);
	}else{
		$ad_header = &_load_tmpl("imobilepc.html", $self);
		$ad_imobile = &_load_tmpl("imobilepc.html", $self);
	}
	$html =~s/<!--AD_HEADER-->/$ad_header/g;
	$html =~s/<!--AD_IMOBILE-->/$ad_imobile/g;


	if($self->{cgi}->param('page')){
		my $pre_page = $self->{cgi}->param('page') - 1;
		my $next_page = $self->{cgi}->param('page') + 1;
		$html =~s/<!--PRE_PAGE-->/$pre_page/g;
		$html =~s/<!--NEXT_PAGE-->/$next_page/g;
	}

	my $gridtmp = &_gridtmp($self);
	$html =~s/<!--GRID_TEMP-->/$gridtmp/g;
	my $gridtmp2 = &_gridtmp2($self);
	$html =~s/<!--GRID_TEMP2-->/$gridtmp2/g;

	return $html;
}

sub _gridtmp(){
	my $self = shift;
	my $key = "gridtmp";

	my $str = $self->{mem}->get($key);
	unless($str){
		
		my $start = int(rand(10));
		my 	$sth = $self->{dbi}->prepare(qq{ select id, title, bodystr, datestr, type, geturl, ext from rssdata where type = ? order by datestr desc,id limit $start,12} );
		$sth->execute(6);
		my $cnt;
		while(my @row = $sth->fetchrow_array) {
			next if($row[2] eq "utf8");
			my ($datacnt, $keyworddata) = &get_keyword($self, $row[1]);
			my ($photodatacnt, $photodata) = &get_photo($self, $keyworddata->{id});

			$str .= qq{<div>};
			$str .= qq{<a href="/keyword-$keyworddata->{id}/">};
			$str .= qq{<img src="$photodata->{url}" width=86></a>};
			$str .= qq{<h3 class="textOverflow">$row[1]</h3>};
			$str .= qq{</div>};
		}
		$self->{mem}->set($key, $str, 60 * 60 * 2);
	}
	
	return $str;
}
sub _gridtmp2(){
	my $self = shift;


	my $key = "gridtmp2";

	my $id = $self->{cgi}->param('id');
	my $tmpid = $id % 50;
	$key = "gridtmp2$tmpid";

	my $str = $self->{mem}->get($key);
	unless($str){
		
		my $start = int(rand(500));
		my $sth = $self->{dbi}->prepare(qq{select id, keyword,birthday,blood from keyword where person = 2 and cnt >= 10 order by cnt desc limit $start,9});
		$sth->execute();
		while(my @row = $sth->fetchrow_array) {
			my $sth2 = $self->{dbi}->prepare(qq{select id, url,good,title from photo where keywordid = ? order by good desc limit 1});
			$sth2->execute($row[0]);
			while(my @row2 = $sth2->fetchrow_array) {
				$str .= qq{<li>};
				$str .= qq{<a href="/keyword-$row[0]/">};
				$str .= qq{<img src="$row2[1]" width=86>};
				$str .= qq{<h3>$row[1]</h3>};
				my $birth;
				if($row[2]){
					if($row[2] ne '0000-00-00'){
						$birth .= $row[2];
					}
				}	
				if($row[3]){
					if($row[3] ne 1){
						$birth .= qq{ $row[3]};
					}
				}	
				$str .= qq{<p>$birth</p>} if($birth);
				$str .= qq{</a></li>};
			}
			$self->{mem}->set($key, $str, 60 * 60 * 1);
		}
	}
	
	return $str;
}

sub _keyword_group(){
	my $self = shift;
	my $keywordid = shift;

	my $key = "_keyword_group".$keywordid;

	my $str = $self->{mem}->get($key);
	unless($str){
		my $sth = $self->{dbi}->prepare(qq{select group_id from keyword_group where keyword_id = ? });
		$sth->execute($keywordid);
		my $group_id;
		while(my @row = $sth->fetchrow_array) {
			$group_id = $row[0];
		}

		my $sth3 = $self->{dbi}->prepare(qq{select keyword_id from keyword_group where group_id = ? });
		$sth3->execute($group_id);
		while(my @row3 = $sth3->fetchrow_array) {
		
			my $sth = $self->{dbi}->prepare(qq{select id, keyword,birthday,blood from keyword where id = ? });
			$sth->execute($row3[0]);
			while(my @row = $sth->fetchrow_array) {
				my $sth2 = $self->{dbi}->prepare(qq{select id, url,good,title from photo where keywordid = ? order by good desc limit 1});
				$sth2->execute($row[0]);
				while(my @row2 = $sth2->fetchrow_array) {
					$str .= qq{<li>};
					$str .= qq{<a href="/keyword-$row[0]/">};
					$str .= qq{<img src="$row2[1]" width=86>};
					$str .= qq{<h3>$row[1]</h3>};
					my $birth;
					if($row[2]){
						if($row[2] ne '0000-00-00'){
							$birth .= $row[2];
						}
					}	
					if($row[3]){
						if($row[3] ne 1){
							$birth .= qq{ $row[3]};
						}
					}	
					$str .= qq{<p>$birth</p>} if($birth);
					$str .= qq{</a></li>};
				}
				$self->{mem}->set($key, $str, 60 * 60 * 1);
			}
		}
	}
	
	return $str;
}

sub _keyword_recomend(){
	my $self = shift;
	my $keywordid = shift;

	my $key = "_keyword_recomend".$keywordid;

	my $str = $self->{mem}->get($key);
	unless($str){
		my $sth3 = $self->{dbi}->prepare(qq{select keypersonid from keyword_recomend where keywordid = ? order by point limit 10});
		$sth3->execute($keywordid);
		while(my @row3 = $sth3->fetchrow_array) {
		
			my $sth = $self->{dbi}->prepare(qq{select id, keyword,birthday,blood from keyword where id = ? });
			$sth->execute($row3[0]);
			while(my @row = $sth->fetchrow_array) {
				my $sth2 = $self->{dbi}->prepare(qq{select id, url,good,title from photo where keywordid = ? order by good desc limit 1});
				$sth2->execute($row[0]);
				while(my @row2 = $sth2->fetchrow_array) {
					$str .= qq{<li>};
					$str .= qq{<a href="/keyword-$row[0]/">};
					$str .= qq{<img src="$row2[1]" width=86>};
					$str .= qq{<h3>$row[1]</h3>};
					my $birth;
					if($row[2]){
						if($row[2] ne '0000-00-00'){
							$birth .= $row[2];
						}
					}	
					if($row[3]){
						if($row[3] ne 1){
							$birth .= qq{ $row[3]};
						}
					}	
					$str .= qq{<p>$birth</p>} if($birth);
					$str .= qq{</a></li>};
				}
				$self->{mem}->set($key, $str, 60 * 60 * 1);
			}
		}
	}
	
	return $str;
}

sub _keyword_genre(){
	my $self = shift;
	my $keywordid = shift;

	my $key = "_keyword_genre".$keywordid;

	my $str = $self->{mem}->get($key);
	unless($str){
		my $sth3 = $self->{dbi}->prepare(qq{select genre,av,artist,model,ana,sex from keyword where id = ? });
		$sth3->execute($keywordid);
		while(my @row3 = $sth3->fetchrow_array) {
			my $where_str;
			if($row3[0]){
				$where_str .= qq{ genre = $row3[0]};
			}elsif($row3[1]){
				$where_str .= qq{ av = $row3[1]};
			}elsif($row3[2]){
				$where_str .= qq{ artist = $row3[2]};
			}elsif($row3[3]){
				$where_str .= qq{ model = $row3[3]};
			}elsif($row3[4]){
				$where_str .= qq{ ana = $row3[4]};
			}elsif($row3[5]){
				$where_str .= qq{ sex = $row3[5]};
			}else{
				$where_str .= qq{ cnt > 50 };
			}
		
			my $sth = $self->{dbi}->prepare(qq{select id, keyword,birthday,blood from keyword where $where_str order by rand() limit 10});
			$sth->execute();
			while(my @row = $sth->fetchrow_array) {
				my $sth2 = $self->{dbi}->prepare(qq{select id, url,good,title from photo where keywordid = ? order by good desc limit 1});
				$sth2->execute($row[0]);
				while(my @row2 = $sth2->fetchrow_array) {
					$str .= qq{<li>};
					$str .= qq{<a href="/keyword-$row[0]/">};
					$str .= qq{<img src="$row2[1]" width=86>};
					$str .= qq{<h3>$row[1]</h3>};
					my $birth;
					if($row[2]){
						if($row[2] ne '0000-00-00'){
							$birth .= $row[2];
						}
					}	
					if($row[3]){
						if($row[3] ne 1){
							$birth .= qq{ $row[3]};
						}
					}	
					$str .= qq{<p>$birth</p>} if($birth);
					$str .= qq{</a></li>};
				}
				$self->{mem}->set($key, $str, 60 * 60 * 1);
			}
		}
	}
	
	return $str;
}


sub new(){
	my $class = shift;
	my $q = new CGI;

	my $memkey;
if($ENV{SERVER_NAME} eq 'img.cospa.info'){
	$memkey = qq{cospa};
}elsif($ENV{SERVER_NAME} eq 'img.brand-search.biz'){
	$memkey = qq{brand};
}elsif($ENV{SERVER_NAME} eq 'photo.webk-vps.com'){
	$memkey = qq{webk};
}elsif($ENV{SERVER_NAME} eq 'photo.fxhost.pro'){
	$memkey = qq{fxhost};
}

	my $self={
			'mem' => &_mem_connect(),
			'dbi' => &_db_connect(),
			'cgi' => $q,
			'memkey' => $memkey
			};
	
	return bless $self, $class;
}

# memcached connect
sub _mem_connect(){

	my $memd = new Cache::Memcached::Fast {
    'servers' => [ "localhost:11211" ],
    'compress_threshold' => 10_000,
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

sub _meikan_name(){
	my $meikantype = shift;
	
	my $meikanname;
	my $sql_str;
	$meikanname->{1} = qq{男性タレント};
	$sql_str->{1} = qq{ person = 3 };
	$meikanname->{2} = qq{女性タレント};
	$sql_str->{2} = qq{ person = 2 };
	$meikanname->{3} = qq{グラビアアイドル};
	$sql_str->{3} = qq{ person = 1 };
	$meikanname->{4} = qq{お笑いタレント};
	$sql_str->{4} = qq{ person = 4 };
	$meikanname->{6} = qq{子役};
	$sql_str->{6} = qq{ person = 6 };
	$meikanname->{7} = qq{落語家};
	$sql_str->{7} = qq{ person = 7 };
	$meikanname->{8} = qq{声優};
	$sql_str->{8} = qq{ person = 8 };
	$meikanname->{9} = qq{男性アーティスト};
	$sql_str->{9} = qq{ artist = 1 and sex = 1 };
	$meikanname->{10} = qq{女性アーティスト};
	$sql_str->{10} = qq{ artist = 1 and sex = 2 };
	$meikanname->{11} = qq{モデル};
	$sql_str->{11} = qq{ model = 1 };
	$meikanname->{12} = qq{レースクィーン};
	$sql_str->{12} = qq{ model = 2 };
	$meikanname->{13} = qq{女子アナウンサー};
	$sql_str->{13} = qq{ ana is not null };
	$meikanname->{14} = qq{AV女優};
	$sql_str->{14} = qq{ av = 1 };
	$meikanname->{15} = qq{ブログ};
	$sql_str->{15} = qq{ blogurl is not null };


	return ($meikanname->{$meikantype}, $sql_str->{$meikantype});
}

sub _star_img(){
	my $point = shift;
	
	my $str;
	if($point >= 100){
		$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png">};
	}elsif($point >= 90){
		$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-half.png">};
	}elsif($point >= 80){
		$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-off.png">};
	}elsif($point >= 70){
		$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-half.png"><img src="/img/star-off.png">};
	}elsif($point >= 60){
		$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-off.png"><img src="/img/star-off.png">};
	}elsif($point >= 50){
		$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-half.png"><img src="/img/star-off.png"><img src="/img/star-off.png">};
	}elsif($point >= 40){
		$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">};
	}elsif($point >= 30){
		$str = qq{<img src="/img/star-on.png"><img src="/img/star-half.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">};
	}elsif($point >= 20){
		$str = qq{<img src="/img/star-on.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">};
	}elsif($point >= 10){
		$str = qq{<img src="/img/star-half.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">};
	}else{
		$str = qq{<img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">};
	}
	return $str;
}

sub _calcage{ 
  ## // 引数受取 
  my $p_to=shift; 
 
my $date = Date::Simple->new();
my $p_from = $date->format('%Y-%m-%d');

  my ($ret_age) = 0;        
 
  if ($p_from ne "" && $p_to ne ""){ 
    $p_from =~ s/-//g; 
    $p_to   =~ s/-//g; 
    if ($p_to < $p_from){ 
      $ret_age = int(( $p_from - $p_to) / 10000); 
    } 
  }
  return $ret_age; 
}

1;