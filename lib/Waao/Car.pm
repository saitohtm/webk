package Waao::Car;

use DBI;
use CGI;
use Cache::Memcached;
use Jcode;
use CGI qw( escape );
use Date::Simple;
use Waao::Utility;

sub dispatch_car_photo(){
	my $self = shift;

	if($self->{cgi}->param('dsp')){
		&_car_photo_dsp($self);
	}elsif($self->{cgi}->param('page')){
		&_car_photo_list($self);
	}elsif($self->{cgi}->param('cate_top')){
		&_car_photo_cate_top($self);
	}elsif($self->{cgi}->param('cate_ins')){
		&_car_photo_cate_ins($self);
	}elsif($self->{cgi}->param('photo_site_ins')){
		&_car_photo_ins($self);
	}else{
		&_car_photo_top($self);
	}

	return;
}

sub _car_photo_list(){
	my $self = shift;
	my $html;
	$html = &_load_tmpl("car_photo_list.html",$self);
	$html = &_parts_set($html,$self);

	my $page  = $self->{cgi}->param('page');
	my $start = ($page - 1) * 50;

	my $list;
	my $sth = $self->{dbi}->prepare(qq{select id, photo, site_id, url, regist_date from car_photo order by id desc limit $start,50 });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my ($id, $photo,$site_id,$url,$date) = @row;
		$list.=qq{<div><img src="$photo"><br><a href="$url">取得元</a> $date </div>};
	}	
	$html =~s/<!--LIST-->/$list/g;

	my $pager = &_pager($page,"car-photo");
	$html =~s/<!--PAGER-->/$pager/g;

	&_output($html);

	return;
}

sub _car_photo_cate_top(){
	my $self = shift;
	$html = &_load_tmpl("car_photo_cate_top.html",$self);
	$html = &_parts_set($html,$self);

	&_output($html);

	return;
}

sub _car_photo_cate_ins(){
	my $self = shift;

eval{
	my $sth = $self->{dbi}->prepare(qq{insert into car_photo_category (name) values(?)});
	$sth->execute($self->{cgi}->param('name'));
};
	&_car_photo_top($self);

	return;
}

sub _car_photo_ins(){
	my $self = shift;
	$html = &_load_tmpl("car_photo_ins.html",$self);
	$html = &_parts_set($html,$self);

eval{
	my $sth = $self->{dbi}->prepare(qq{insert into car_photo_site (url,photo_category_id,keyword) values(?,?,?)});
	$sth->execute($self->{cgi}->param('car_url'),$self->{cgi}->param('car_photo_category'),$self->{cgi}->param('car_keyword'));
};

if($self->{cgi}->param('car_keyword')){
eval{
	my $sth = $self->{dbi}->prepare(qq{insert into car_keyword (name) values(?)});
	$sth->execute($self->{cgi}->param('car_keyword'));
};
}

	&_output($html);

	return;
}

sub _car_photo_top(){
	my $self = shift;
	$html = &_load_tmpl("car_photo_top.html",$self);
	$html = &_parts_set($html,$self);

	my $category_list;
	my $sth = $self->{dbi}->prepare(qq{select id,name from car_photo_category});
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$category_list.=qq{<option value="$row[0]">$row[1]</option>};
	}
	$html =~s/<!--CATEGORY_LIST-->/$category_list/g;

	&_output($html);

	return;
}
sub dispatch_used_car_entry(){
	my $self = shift;

	if($self->{cgi}->param('check')){
		&_used_car_entry_ins($self);
	}elsif($self->{cgi}->param('name')){
		&_used_car_entry_check($self);
	}else{
		&_used_car_entry($self);
	}

	return;
}

sub _used_car_entry(){
	my $self = shift;
	my $html;
	$html = &_load_tmpl("used_car_entry.html",$self);
	$html = &_parts_set($html,$self);

	# type of car cs_body
	
	# engine desplacement car_engin_desplacement

	# year_of_car 1970
	
	# mileage 

	# brand
	
	&_output($html);

	return;
}

sub dispatch_news_topics(){
	my $self = shift;

	if($self->{cgi}->param('id')){
		&_news_topics_detail($self);
	}else{
		&_news_topics_list($self);
	}

	return;
}

sub _news_topics_list(){
	my $self = shift;
	my $html;
	$html = &_load_tmpl("news_topics_list.html",$self);
	$html = &_parts_set($html,$self);

	my $page  = $self->{cgi}->param('page');
	my $start = $page * 50;

	my $newslist;
	my $sth = $self->{dbi}->prepare(qq{select B.id, B.title,B.body,B.url,B.date,B.img,A.name from car_site A, car_topics B where A.id = B.site_id order by B.date desc limit $start,50 });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my ($id, $title,$body,$url,$date,$img,$name) = @row;
		$newslist.=qq{<a href="/car-news/$id/">$title</a><br>$body<br>$date<br>};
	}	
	$html =~s/<!--NEWSLIST-->/$newslist/g;

	my $pager = &_pager($page,"car-news");
	$html =~s/<!--PAGER-->/$pager/g;

	&_output($html);

	return;
}

sub _news_topics_detail(){
	my $self = shift;
	my $html;
	$html = &_load_tmpl("news_topics_detail.html",$self);
	$html = &_parts_set($html,$self);

	my $newslist;
	my $sth = $self->{dbi}->prepare(qq{select B.id, B.title,B.body,B.url,B.date,B.img,A.name from car_site A, car_topics B where A.id = B.site_id and B.id = ? });
	$sth->execute($self->{cgi}->param('id'));
	while(my @row = $sth->fetchrow_array) {
		my ($id, $title,$body,$url,$date,$img,$name) = @row;
		$html =~s/<!--NEWSID-->/$id/g;
		$html =~s/<!--NEWSTITLE-->/$title/g;
		$html =~s/<!--NEWSBODY-->/$body/g;
		$html =~s/<!--NEWSURL-->/$url/g;
		$html =~s/<!--NEWSDATE-->/$date/g;
		$html =~s/<!--SITENAME-->/$name/g;
	}	

	&_output($html);

	return;
}

sub dispatch_site_entry(){
	my $self = shift;

	if($self->{cgi}->param('sitename')){
		&_entry_site_ins($self);
	}else{
		&_entry_site($self);
	}

	return;
}

sub _entry_site_ins(){
	my $self = shift;

	my $html;
	
	my $err_str;
	$err_str = 1 unless($self->{cgi}->param('category'));
	$err_str = 1 unless($self->{cgi}->param('sitename'));
	$err_str = 1 unless($self->{cgi}->param('url'));
	
	$html = &_load_tmpl("site_entry_ins.html",$self);
	$html = &_parts_set($html,$self);

	unless($err_str){
eval{
	my $sth = $self->{dbi}->prepare(qq{insert into car_site (name,url,category_id,brand_id,rss_url) values(?,?,?,?,?)});
	$sth->execute($self->{cgi}->param('sitename'),$self->{cgi}->param('url'),$self->{cgi}->param('category'),$self->{cgi}->param('brand_id'),$self->{cgi}->param('rss_url'));
};
	}
	
	&_output($html);
	
	return;
}
sub _entry_site(){
	my $self = shift;

	my $html;
	$html = &_load_tmpl("site_entry.html",$self);
	$html = &_parts_set($html,$self);

	# カテゴリ
	my $category_list;
	my $sth = $self->{dbi}->prepare(qq{select id,name from car_category});
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$category_list.=qq{<option value="$row[0]">$row[1]</option>};
	}
	$html =~s/<!--CATEGORY_LIST-->/$category_list/g;
	# ブランド
	my $brand_list;
	my $sth = $self->{dbi}->prepare(qq{select id,name from cs_brand});
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$brand_list.=qq{<option value="$row[0]">$row[1]</option>};
	}
	$html =~s/<!--BRAND_LIST-->/$brand_list/g;

	&_output($html);

	return;
}

sub dispatch_car_entry(){
	my $self = shift;

	if($self->{cgi}->param('name')){
		&_entry_used_car_ins($self);
	}else{
		&_entry_used_car($self);
	}

	return;
}


sub _entry_used_car(){
	my $self = shift;

	my $html;
	$html = &_load_tmpl("entry_used_car.html",$self);
	$html = &_parts_set($html,$self);

	&_output($html);

	return;
}

sub _entry_used_car_ins(){
	my $self = shift;
	return;
}

sub dispatch_whats_my_car_worth(){
	my $self = shift;

	if($self->{cgi}->param('id')){
		&_whats_my_car_worth_detail($self);
	}elsif($self->{cgi}->param('model_id')){
		&_whats_my_car_worth_model($self);
	}elsif($self->{cgi}->param('brand_code')){
		&_whats_my_car_worth_brand($self);
	}else{
		&_whats_my_car_worth_top($self);
	}

	return;
}

sub _whats_my_car_worth_detail(){
	my $self = shift;

	my $html;
	$html = &_load_tmpl("whats_my_car_worth_detail.html",$self);
	$html = &_parts_set($html,$self);

	my $year = $self->{cgi}->param('year');
	$html =~s/<!--YEAR-->/$year/g;

	my $list;
	my ($id,$brand_code,$brand_name,$country_name,$body_code,$body_name,$model,$grade,$price,$person,$period,$series,$width,$height,$length_val,$photo_frot_l,$photo_frot_s,$photo_frot_caption,$photo_rear_l,$photo_rear_s,$photo_rear_caption,$photo_inpane_l,$photo_inpane_s,$photo_inpane_caption);
	my $sth = $self->{dbi}->prepare(qq{select id,brand_code,brand_name,country_name,body_code,body_name,model,grade,price,person,period,series,width,height,length_val,photo_frot_l,photo_frot_s,photo_frot_caption,photo_rear_l,photo_rear_s,photo_rear_caption,photo_inpane_l,photo_inpane_s,photo_inpane_caption from cs_catalog where id = ?  });
	$sth->execute($self->{cgi}->param('id'));
	while(my @row = $sth->fetchrow_array) {
		($id,$brand_code,$brand_name,$country_name,$body_code,$body_name,$model,$grade,$price,$person,$period,$series,$width,$height,$length_val,$photo_frot_l,$photo_frot_s,$photo_frot_caption,$photo_rear_l,$photo_rear_s,$photo_rear_caption,$photo_inpane_l,$photo_inpane_s,$photo_inpane_caption) = @row;
		$list .= qq{<img src="$photo_frot_l"><a href="/used-car/$brand_code/$id/">$model $grade </a><br>};
	}
	
	$html =~s/<!--LIST-->/$list/g;
	$html =~s/<!--BRAND_NAME-->/$brand_name/g;
	$html =~s/<!--BRAND_CODE-->/$brand_code/g;
	$html =~s/<!--MODEL-->/$model/g;
	$html =~s/<!--GRADE-->/$grade/g;
	$html =~s/<!--ID-->/$id/g;

	&_output($html);

	return;
}

sub _whats_my_car_worth_model(){
	my $self = shift;

	my $html;
	$html = &_load_tmpl("whats_my_car_worth_model.html",$self);
	$html = &_parts_set($html,$self);

	my $year = $self->{cgi}->param('year');
	$html =~s/<!--YEAR-->/$year/g;

	my $model_str;
	my $sth = $self->{dbi}->prepare(qq{select model from cs_catalog where id = ?  });
	$sth->execute($self->{cgi}->param('model_id'));
	while(my @row = $sth->fetchrow_array) {
		$model_str = $row[0];
	}

	my $list;
	my $seo_list;
	my ($id,$brand_code,$brand_name,$country_name,$body_code,$body_name,$model,$grade,$price,$person,$period,$series,$width,$height,$length_val,$photo_frot_l,$photo_frot_s,$photo_frot_caption,$photo_rear_l,$photo_rear_s,$photo_rear_caption,$photo_inpane_l,$photo_inpane_s,$photo_inpane_caption);
	my $sth = $self->{dbi}->prepare(qq{select id,brand_code,brand_name,country_name,body_code,body_name,model,grade,price,person,period,series,width,height,length_val,photo_frot_l,photo_frot_s,photo_frot_caption,photo_rear_l,photo_rear_s,photo_rear_caption,photo_inpane_l,photo_inpane_s,photo_inpane_caption from cs_catalog where model = ?  });
	$sth->execute($model_str);
	while(my @row = $sth->fetchrow_array) {
		($id,$brand_code,$brand_name,$country_name,$body_code,$body_name,$model,$grade,$price,$person,$period,$series,$width,$height,$length_val,$photo_frot_l,$photo_frot_s,$photo_frot_caption,$photo_rear_l,$photo_rear_s,$photo_rear_caption,$photo_inpane_l,$photo_inpane_s,$photo_inpane_caption) = @row;
		$list .= qq{<img src="$photo_frot_l"><a href="/whats-my-car-worth/$brand_code/car-$id-$year/">$model $grade </a><br>};
		$seo_list.=qq{<li><a href="/whats-my-car-worth/$brand_code/car-$id-$year/">$model $grade</a></li>};
	}
	
	$html =~s/<!--LIST-->/$list/g;
	$html =~s/<!--SEO_LIST-->/$seo_list/g;
	$html =~s/<!--BRAND_NAME-->/$brand_name/g;
	$html =~s/<!--BRAND_CODE-->/$brand_code/g;
	$html =~s/<!--MODEL-->/$model_str/g;

	&_output($html);

	return;
}


sub _whats_my_car_worth_brand(){
	my $self = shift;

	my $brand_code = $self->{cgi}->param('brand_code');
	my $html;
	$html = &_load_tmpl("whats_my_car_worth_brand.html",$self);
	$html = &_parts_set($html,$self);

	my $year = $self->{cgi}->param('year');

	unless($year){
		my $date = Date::Simple->new();
		my $year = $date->year;
		my $year_list;
		for(my $i=0;$i<=10;$i++){
			my $tmp_year = $year - $i;
			$year_list .= qq{<li><a href="/whats-my-car-worth/$brand_code-$tmp_year/">$tmp_year</a></li>}
		}
		$html =~s/<!--YEAR_LIST-->/$year_list/g;
	}else{
		$html =~s/<!--YEAR-->/$year/g;
	}

	my $list;
	my $brand_name;
	my $sth = $self->{dbi}->prepare(qq{select model,max(id) as mid,brand_name from cs_catalog where brand_code = ? group by model });
	$sth->execute($brand_code);
	while(my @row = $sth->fetchrow_array) {
		$list .= qq{<a href="/whats-my-car-worth/$brand_code/$row[1]/">$row[0]</a><br>};
		$brand_name = $row[2];
	}
	
	$html =~s/<!--BRAND_NAME-->/$brand_name/g;
	$html =~s/<!--LIST-->/$list/g;

	&_output($html);

	return;
}

sub _whats_my_car_worth_top(){
	my $self = shift;

	my $html;
	$html = &_load_tmpl("whats_my_car_worth_top.html",$self);

	$html = &_parts_set($html,$self);

	# 日本車
	my $jpn_list;
	my $sth = $self->{dbi}->prepare(qq{select id, code, name, country_code, country_name from cs_brand where country_code = ? });
	$sth->execute("JPN");
	while(my @row = $sth->fetchrow_array) {
		$jpn_list .= qq{<li><a href="/whats-my-car-worth/$row[1]/">$row[2]</a></li>};
	}
	
	# 外車
	my $list;
	my $sth = $self->{dbi}->prepare(qq{select id, code, name, country_code, country_name from cs_brand where country_code != ? order by country_code });
	$sth->execute("JPN");
	while(my @row = $sth->fetchrow_array) {
		$list .= qq{<li><a href="/whats-my-car-worth/$row[1]/">$row[2]($row[4])</a></li>};
	}
	
	$html =~s/<!--JPN_LIST-->/$jpn_list/g;
	$html =~s/<!--LIST-->/$list/g;

	&_output($html);

	return;
}


sub dispatch_used_cars(){
	my $self = shift;

	if($self->{cgi}->param('id')){
		&_used_cars_detail($self);
	}elsif($self->{cgi}->param('model_id')){
		&_used_cars_model($self);
	}elsif($self->{cgi}->param('brand_code')){
		&_used_cars_brand($self);
	}else{
		&_used_cars_top($self);
	}

	return;
}

sub _used_cars_detail(){
	my $self = shift;

	my $html;
	$html = &_load_tmpl("used_cars_detail.html",$self);
	$html = &_parts_set($html,$self);

	my $list;
	my ($id,$brand_code,$brand_name,$country_name,$body_code,$body_name,$model,$grade,$price,$person,$period,$series,$width,$height,$length_val,$photo_frot_l,$photo_frot_s,$photo_frot_caption,$photo_rear_l,$photo_rear_s,$photo_rear_caption,$photo_inpane_l,$photo_inpane_s,$photo_inpane_caption);
	my $sth = $self->{dbi}->prepare(qq{select id,brand_code,brand_name,country_name,body_code,body_name,model,grade,price,person,period,series,width,height,length_val,photo_frot_l,photo_frot_s,photo_frot_caption,photo_rear_l,photo_rear_s,photo_rear_caption,photo_inpane_l,photo_inpane_s,photo_inpane_caption from cs_catalog where id = ?  });
	$sth->execute($self->{cgi}->param('id'));
	while(my @row = $sth->fetchrow_array) {
		($id,$brand_code,$brand_name,$country_name,$body_code,$body_name,$model,$grade,$price,$person,$period,$series,$width,$height,$length_val,$photo_frot_l,$photo_frot_s,$photo_frot_caption,$photo_rear_l,$photo_rear_s,$photo_rear_caption,$photo_inpane_l,$photo_inpane_s,$photo_inpane_caption) = @row;
		$list .= qq{<img src="$photo_frot_l"><a href="/used-cars/$brand_code/$id/">$model $grade </a><br>};
	}
	
	$html =~s/<!--LIST-->/$list/g;
	$html =~s/<!--BRAND_NAME-->/$brand_name/g;
	$html =~s/<!--BRAND_CODE-->/$brand_code/g;
	$html =~s/<!--MODEL-->/$model/g;
	$html =~s/<!--GRADE-->/$grade/g;
	$html =~s/<!--ID-->/$id/g;

	&_output($html);

	return;
}

sub _used_cars_model(){
	my $self = shift;

	my $html;
	$html = &_load_tmpl("used_cars_model.html",$self);
	$html = &_parts_set($html,$self);

	my $model_str;
	my $sth = $self->{dbi}->prepare(qq{select model from cs_catalog where id = ?  });
	$sth->execute($self->{cgi}->param('model_id'));
	while(my @row = $sth->fetchrow_array) {
		$model_str = $row[0];
	}

	my $list;
	my $seo_list;
	my ($id,$brand_code,$brand_name,$country_name,$body_code,$body_name,$model,$grade,$price,$person,$period,$series,$width,$height,$length_val,$photo_frot_l,$photo_frot_s,$photo_frot_caption,$photo_rear_l,$photo_rear_s,$photo_rear_caption,$photo_inpane_l,$photo_inpane_s,$photo_inpane_caption);
	my $sth = $self->{dbi}->prepare(qq{select id,brand_code,brand_name,country_name,body_code,body_name,model,grade,price,person,period,series,width,height,length_val,photo_frot_l,photo_frot_s,photo_frot_caption,photo_rear_l,photo_rear_s,photo_rear_caption,photo_inpane_l,photo_inpane_s,photo_inpane_caption from cs_catalog where model = ?  });
	$sth->execute($model_str);
	while(my @row = $sth->fetchrow_array) {
		($id,$brand_code,$brand_name,$country_name,$body_code,$body_name,$model,$grade,$price,$person,$period,$series,$width,$height,$length_val,$photo_frot_l,$photo_frot_s,$photo_frot_caption,$photo_rear_l,$photo_rear_s,$photo_rear_caption,$photo_inpane_l,$photo_inpane_s,$photo_inpane_caption) = @row;
		$list .= qq{<img src="$photo_frot_l"><a href="/used-cars/$brand_code/car-$id/">$model $grade </a><br>};
		$seo_list.=qq{<li><a href="/used-cars/$brand_code/car-$id/">$model $grade</a></li>};
	}
	
	$html =~s/<!--LIST-->/$list/g;
	$html =~s/<!--SEO_LIST-->/$seo_list/g;
	$html =~s/<!--BRAND_NAME-->/$brand_name/g;
	$html =~s/<!--BRAND_CODE-->/$brand_code/g;
	$html =~s/<!--MODEL-->/$model_str/g;

	&_output($html);

	return;
}


sub _used_cars_brand(){
	my $self = shift;

	my $brand_code = $self->{cgi}->param('brand_code');
	my $html;
	$html = &_load_tmpl("used_cars_brand.html",$self);
	$html = &_parts_set($html,$self);

	my $list;
	my $brand_name;
	my $sth = $self->{dbi}->prepare(qq{select model,max(id) as mid,brand_name from cs_catalog where brand_code = ? group by model });
	$sth->execute($brand_code);
	while(my @row = $sth->fetchrow_array) {
		$list .= qq{<li><a href="/used-cars/$brand_code/$row[1]/">$row[0]</a></li>};
		$brand_name = $row[2];
	}
	
	$html =~s/<!--BRAND_NAME-->/$brand_name/g;
	$html =~s/<!--LIST-->/$list/g;

	&_output($html);

	return;
}

sub _used_cars_top(){
	my $self = shift;

	my $html;
	$html = &_load_tmpl("used_cars_top.html",$self);
	$html = &_parts_set($html,$self);

	# 日本車
	my $jpn_list;
	my $sth = $self->{dbi}->prepare(qq{select id, code, name, country_code, country_name from cs_brand where country_code = ? });
	$sth->execute("JPN");
	while(my @row = $sth->fetchrow_array) {
		$jpn_list .= qq{<li><a href="/used-cars/$row[1]/">$row[2]</a></li>};
	}
	
	# 外車
	my $list;
	my $sth = $self->{dbi}->prepare(qq{select id, code, name, country_code, country_name from cs_brand where country_code != ? order by country_code });
	$sth->execute("JPN");
	while(my @row = $sth->fetchrow_array) {
		$list .= qq{<li><a href="/used-cars/$row[1]/">$row[2]($row[4])</a></li>};
	}
	
	$html =~s/<!--JPN_LIST-->/$jpn_list/g;
	$html =~s/<!--LIST-->/$list/g;

	&_output($html);

	return;
}

sub dispatch_new_cars(){
	my $self = shift;

	if($self->{cgi}->param('id')){
		&_new_cars_detail($self);
	}elsif($self->{cgi}->param('model_id')){
		&_new_cars_model($self);
	}elsif($self->{cgi}->param('brand_code')){
		&_new_cars_brand($self);
	}else{
		&_new_cars_top($self);
	}

	return;
}

sub _new_cars_detail(){
	my $self = shift;

	my $html;
	$html = &_load_tmpl("new_cars_detail.html",$self);
	$html = &_parts_set($html,$self);

	my $list;
	my ($id,$brand_code,$brand_name,$country_name,$body_code,$body_name,$model,$grade,$price,$person,$period,$series,$width,$height,$length_val,$photo_frot_l,$photo_frot_s,$photo_frot_caption,$photo_rear_l,$photo_rear_s,$photo_rear_caption,$photo_inpane_l,$photo_inpane_s,$photo_inpane_caption);
	my $sth = $self->{dbi}->prepare(qq{select id,brand_code,brand_name,country_name,body_code,body_name,model,grade,price,person,period,series,width,height,length_val,photo_frot_l,photo_frot_s,photo_frot_caption,photo_rear_l,photo_rear_s,photo_rear_caption,photo_inpane_l,photo_inpane_s,photo_inpane_caption from cs_catalog where id = ?  });
	$sth->execute($self->{cgi}->param('id'));
	while(my @row = $sth->fetchrow_array) {
		($id,$brand_code,$brand_name,$country_name,$body_code,$body_name,$model,$grade,$price,$person,$period,$series,$width,$height,$length_val,$photo_frot_l,$photo_frot_s,$photo_frot_caption,$photo_rear_l,$photo_rear_s,$photo_rear_caption,$photo_inpane_l,$photo_inpane_s,$photo_inpane_caption) = @row;
		$list .= qq{<img src="$photo_frot_l"><a href="/new-cars/$brand_code/$id/">$model $grade </a><br>};
	}
	
	$html =~s/<!--LIST-->/$list/g;
	$html =~s/<!--BRAND_NAME-->/$brand_name/g;
	$html =~s/<!--BRAND_CODE-->/$brand_code/g;
	$html =~s/<!--MODEL-->/$model/g;
	$html =~s/<!--GRADE-->/$grade/g;
	$html =~s/<!--ID-->/$id/g;

	&_output($html);

	return;
}

sub _new_cars_model(){
	my $self = shift;

	my $html;
	$html = &_load_tmpl("new_cars_model.html",$self);
	$html = &_parts_set($html,$self);

	my $model_str;
	my $sth = $self->{dbi}->prepare(qq{select model from cs_catalog where id = ?  });
	$sth->execute($self->{cgi}->param('model_id'));
	while(my @row = $sth->fetchrow_array) {
		$model_str = $row[0];
	}

	my $list;
	my $seo_list;

	my $sth = $self->{dbi}->prepare(qq{select max(price) as mp,photo_frot_l from cs_catalog where model = ? and end_piriod = ? group by photo_frot_l order by mp desc });
	$sth->execute($model_str,999999);
	while(my @row = $sth->fetchrow_array) {

		my ($id,$brand_code,$brand_name,$country_name,$body_code,$body_name,$model,$grade,$price,$person,$period,$series,$width,$height,$length_val,$photo_frot_l,$photo_frot_s,$photo_frot_caption,$photo_rear_l,$photo_rear_s,$photo_rear_caption,$photo_inpane_l,$photo_inpane_s,$photo_inpane_caption);
		my $sth2 = $self->{dbi}->prepare(qq{select id,brand_code,brand_name,country_name,body_code,body_name,model,grade,price,person,period,series,width,height,length_val,photo_frot_l,photo_frot_s,photo_frot_caption,photo_rear_l,photo_rear_s,photo_rear_caption,photo_inpane_l,photo_inpane_s,photo_inpane_caption from cs_catalog where model = ? and photo_frot_l = ? and end_piriod = ? order by price desc });
		$sth2->execute($model_str,$row[1],999999);
		my $loopcnt;
		while(my @row2 = $sth2->fetchrow_array) {
			$loopcnt++;		
			($id,$brand_code,$brand_name,$country_name,$body_code,$body_name,$model,$grade,$price,$person,$period,$series,$width,$height,$length_val,$photo_frot_l,$photo_frot_s,$photo_frot_caption,$photo_rear_l,$photo_rear_s,$photo_rear_caption,$photo_inpane_l,$photo_inpane_s,$photo_inpane_caption) = @row2;
			my $dsp_price = &price_dsp($price);
			if($loopcnt eq 1){
				$list .= qq{<img src="$photo_frot_l" alt="$model 前"><br />};
				# <img src="$photo_rear_l" alt="$model 後ろ"> <img src="$photo_inpane_l" alt="$model インパネ"><br />};
			}
			$list .= qq{<a href="/new-cars/$brand_code/car-$id/">$model $grade </a> 価格：～$dsp_price<br />};

			$seo_list.=qq{<li><a href="/new-cars/$brand_code/car-$id/">$model $grade</a></li>};
		}
	}
	
	$html =~s/<!--LIST-->/$list/g;
	$html =~s/<!--SEO_LIST-->/$seo_list/g;
	$html =~s/<!--BRAND_NAME-->/$brand_name/g;
	$html =~s/<!--BRAND_CODE-->/$brand_code/g;
	$html =~s/<!--MODEL-->/$model_str/g;

	&_output($html);

	return;
}


sub _new_cars_brand(){
	my $self = shift;

	my $brand_code = $self->{cgi}->param('brand_code');
	my $html;
	$html = &_load_tmpl("new_cars_brand.html",$self);
	$html = &_parts_set($html,$self);

	my $list;
	my $brand_name;
	my $sth = $self->{dbi}->prepare(qq{select model,id,max(price) as maxprice,brand_code,brand_name,country_code,country_name,body_code,body_name,photo_frot_l,photo_frot_caption, photo_rear_l,photo_inpane_l from cs_catalog where brand_code = ? and end_piriod = ? group by model order by length(price) desc, maxprice desc });
	$sth->execute($brand_code,999999);
	while(my @row = $sth->fetchrow_array) {
		my ($model,$id,$price,$brand_code,$brand_name,$country_code,$country_name,$body_code,$body_name,$photo_frot_l,$photo_frot_caption, $photo_rear_l,$photo_inpane_l) = @row;
		my $dsp_price = &price_dsp($price);
		$list .= qq{<div> <a href="/new-cars/brand-$brand_code/">$brand_name</a> (<a href="/new-cars/country-$country_code/">$country_name</a>) $model 価格：～$dsp_price<br />};
		$list .= qq{<a href="/new-cars/$brand_code/$id/"><img src="$photo_frot_l" alt="$model"></a><br />};
		#$list .= qq{<img src="$photo_rear_l">};
		#$list .= qq{<img src="$photo_inpane_l">};
		$list .= qq{<a href="/new-cars/$brand_code/$id/">$modelの全グレード</a></div>};
		$html =~s/<!--BRAND_NAME-->/$brand_name/g;
	}
	
	$html =~s/<!--LIST-->/$list/g;

	&_output($html);

	return;
}

sub _new_cars_top(){
	my $self = shift;

	my $html;
	$html = &_load_tmpl("new_cars_top.html",$self);

	$html = &_parts_set($html,$self);

	# 日本車
	my $jpn_list;
	my $sth = $self->{dbi}->prepare(qq{select id, code, name, country_code, country_name from cs_brand where country_code = ? order by dspno });
	$sth->execute("JPN");
	while(my @row = $sth->fetchrow_array) {
		$jpn_list .= qq{<li><a href="/new-cars/$row[1]/">$row[2]</a></li>};
	}
	
	# 外車
	my $list;
	my $sth = $self->{dbi}->prepare(qq{select id, code, name, country_code, country_name from cs_brand where country_code != ? order by country_code, dspno });
	$sth->execute("JPN");
	while(my @row = $sth->fetchrow_array) {
		$list .= qq{<li><a href="/new-cars/$row[1]/">$row[2]($row[4])</a></li>};
	}
	
	$html =~s/<!--JPN_LIST-->/$jpn_list/g;
	$html =~s/<!--LIST-->/$list/g;

	&_output($html);

	return;
}
sub dispatch(){
	my $self = shift;

	if($self->{cgi}->param('id')){
		&_detail($self);
	}else{
		&_top($self);
	}

	return;
}

sub _top(){
	my $self = shift;

	my $html;
	$html = &_load_tmpl("index.html",$self);

	$html = &_parts_set($html,$self);

	# 画像表示
	my $list;
	my ($id,$brand_code,$brand_name,$country_name,$body_code,$body_name,$model,$grade,$price,$person,$period,$series,$width,$height,$length_val,$photo_frot_l,$photo_frot_s,$photo_frot_caption,$photo_rear_l,$photo_rear_s,$photo_rear_caption,$photo_inpane_l,$photo_inpane_s,$photo_inpane_caption);
	my $sth = $self->{dbi}->prepare(qq{select id,brand_code,brand_name,country_name,body_code,body_name,model,grade,price,person,period,series,width,height,length_val,photo_frot_l,photo_frot_s,photo_frot_caption,photo_rear_l,photo_rear_s,photo_rear_caption,photo_inpane_l,photo_inpane_s,photo_inpane_caption from cs_catalog limit 30 });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		($id,$brand_code,$brand_name,$country_name,$body_code,$body_name,$model,$grade,$price,$person,$period,$series,$width,$height,$length_val,$photo_frot_l,$photo_frot_s,$photo_frot_caption,$photo_rear_l,$photo_rear_s,$photo_rear_caption,$photo_inpane_l,$photo_inpane_s,$photo_inpane_caption) = @row;
		$list .= qq{<img src="$photo_frot_l"><a href="/new-cars/$brand_code/car-$id/">$model $grade </a><br>};
	}
	
	$html =~s/<!--LIST-->/$list/g;
	# ニュース
	my $newslist;
	my $sth = $self->{dbi}->prepare(qq{select B.id, B.title,B.body,B.url,B.date,B.img,A.name from car_site A, car_topics B where A.id = B.site_id order by B.date desc limit 30 });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my ($id, $title,$body,$url,$date,$img,$name) = @row;
		$newslist.=qq{<a href="/car-news/$id/">$title</a><br>$body<br>$date<br>};
	}	
	$html =~s/<!--NEWSLIST-->/$newslist/g;

	&_output($html);

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

sub _parts_set(){
	my $html = shift;
	my $self = shift;

	# meta
	my $meta = &_load_tmpl("meta.html", $self);
	my $metatop = &_load_tmpl("metatop.html", $self);
	# header
	my $header = &_load_tmpl("header.html", $self);
	# footer
	my $footer = &_load_tmpl("footer.html", $self);
	# slider
	my $side_free = &_load_tmpl("side_free.html", $self);
	$html =~s/<!--SIDE_FREE-->/$side_free/g;

	$html =~s/<!--META-->/$meta/g;
	$html =~s/<!--METATOP-->/$metatop/g;
	$html =~s/<!--HEADER-->/$header/g;
	$html =~s/<!--FOOTER-->/$footer/g;

	# slider
	my $social_tag = &_load_tmpl("social_tag.html", $self);
	$html =~s/<!--SOCIAL_TAG-->/$social_tag/g;

	# ad
	my $ad_header = &_load_tmpl("ad_header.html", $self);
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
	my $self = shift;
my $file;
$file = qq{/var/www/vhosts/goo.to/etc/makehtml/car/tmpl/$tmpl};

my $fh;
my $filedata;
open( $fh, "<", $file );
while( my $line = readline $fh ){ 
	$filedata .= $line;
}
close ( $fh );

	return $filedata;
}



sub _star_img(){
	my $point = shift;
	
	my $str;
	$str = qq{<img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">};
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png">} if($point eq "5");
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-half.png">} if($point eq "4.5");
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-off.png">} if($point eq "4");
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-half.png"><img src="/img/star-off.png">} if($point eq "3.5");
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-off.png"><img src="/img/star-off.png">} if($point eq "3");
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-half.png"><img src="/img/star-off.png"><img src="/img/star-off.png">} if($point eq "2.5");
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">} if($point eq "2");
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-half.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">} if($point eq "1.5");
	$str = qq{<img src="/img/star-on.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">} if($point eq "1");
	$str = qq{<img src="/img/star-half.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">} if($point eq "0.5");
	$str = qq{<img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">} if($point eq "0");

	return $str;
}
sub DESTROY{
	my $self = shift;

	$self->{db}->disconnect if($self->{db});

	return;
}

sub _output(){
	my $html = shift;
	
print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}
1;