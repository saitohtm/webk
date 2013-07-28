package DataController;

use Exporter;
@ISA = (Exporter);
@EXPORT = qw(app_iphone_data app_data app_android_data facebook_data);

use Date::Simple;

sub facebook_data(){
	my $dbh = shift;
	my $data = shift;
	return unless($data->{id});
	return unless($data->{img});

	# データ有無
	my $flag;
	my $diff_cnt;
	my $t_diff_cnt;

	my $sth = $dbh->prepare(qq{select id, likecnt, talking_about_count from facebook where f_id = ? });
	$sth->execute($data->{id});
	while(my @row = $sth->fetchrow_array) {
		$flag = 1;
	    $diff_cnt = $data->{like} - $row[1];
        $t_diff_cnt = $data->{talking_about_count} - $row[2];
	}
	
	# カテゴリID取得
	my $sth = $dbh->prepare(qq{select id from facebook_category where category = ? });
	$sth->execute($data->{category});
	while(my @row = $sth->fetchrow_array) {
		$data->{category_id} = $row[0];
	}

	# 説明文
	my $expl = $data->{public_transit};
	$expl .= $data->{description};
	$expl .= $data->{personal_info};

	if($data->{like} < $data->{likes}){
		$data->{like}=$data->{likes};
	}

	if($flag){
		# 更新
eval{
		my $sth = $dbh->prepare(qq{update facebook set 
				    img=?,
				    url=?,
				    name=?,
				    likecnt=?,
				    diff_cnt=?,
				    f_category=?,
				    website=?,
				    f_username=?,
				    f_exp=?,
				    mission=?,
				    talking_about_count=?,
				    diff_talking=?,
				    cover_img=?,
				    datas =?		
                    where f_id = ? });
		$sth->execute(
					$data->{img},
					$data->{link},
					$data->{name},
					$data->{like},
					$diff_cnt,
					$data->{category},
					$data->{website},
					$data->{username},
					$expl,
	                $data->{mission},
	                $data->{talking_about_count},
					$t_diff_cnt,
	                $data->{cover_img},
		            $data->{datas},
					$data->{id}
						);
};

	}else{
		# 追加
eval{
		my $sth = $dbh->prepare(qq{insert into facebook (
				    `img`,
				    `url`,
				    `name`,
				    `category_id`,
				    `likecnt`,
				    `diff_cnt`,
				    `f_id`,
				    `f_category`,
				    `website`,
				    `f_username`,
				    `f_exp`,
				    `mission`,
				    `talking_about_count`,
				    `diff_talking`,
				    `cover_img`,
				    `datas`) 
				values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)} );
		$sth->execute(
					$data->{img},
					$data->{link},
					$data->{name},
					$data->{category_id},
					$data->{like},
					0,
					$data->{id},
					$data->{category},
					$data->{website},
					$data->{username},
					$expl,
	                $data->{mission},
	                $data->{talking_about_count},
					0,
 	                $data->{cover_img},
		            $data->{datas}
						);
};
	}

	return;
}
sub app_iphone_data(){
	my $dbh = shift;
	my $data = shift;

	return unless($data->{trackId});

	# カテゴリの有無
	my $category_check;
	my $sth = $dbh->prepare(qq{select id from app_category where id = ? });
	$sth->execute($data->{primaryGenreId});
	while(my @row = $sth->fetchrow_array) {
		$category_check = 1;
	}
	unless($category_check){
eval{
		my $sth = $dbh->prepare(qq{insert into app_category (id,name,category,flag) values(?,?,?,1) });
		$sth->execute($data->{primaryGenreId},$data->{primaryGenreName},$data->{primaryGenreName});
};
	}
	
	# データの追加 or 更新
	my $app_check;
	my $now_price;
	my $sth = $dbh->prepare(qq{select id,price from app_iphone where id = ? });
	$sth->execute($data->{trackId});
	while(my @row = $sth->fetchrow_array) {
		$app_check = $row[0];
		$now_price = $row[1];
	}
	unless($app_check){
eval{
		my $sth = $dbh->prepare(qq{insert into app_iphone (
				    `id`,
				    `name`,
				    `url`,
				    `artistId`,
				    `artistName`,
				    `artistViewUrl`,
				    `img60`,
				    `img100`,
				    `img512`,
				    `genre_id`,
				    `genre_name`,
				    `price`,
				    `formattedPrice`,
				    `eva`,
				    `evaCurrent`,
				    `evacount`,
				    `evacountCurrent`,
				    `evaAdvisory`,
				    `description`,
				    `releaseDate`,
				    `releaseNotes`,
				    `languageCodes`,
				    `currency`,
				    `sellerName`,
				    `sellerUrl`,
				    `trackCensoredName`,
				    `trackContentRating`,
				    `appversion`,
				    `supportedDevices`,
				    `bundleId`,
				    `features`,
				    `fileSizeBytes`,
				    `genreIds`,
				    `genres`) 
				values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)} );
		$sth->execute(
					$data->{trackId},
					$data->{trackName},
					$data->{trackViewUrl},
					$data->{artistId},
					$data->{artistName},
					$data->{artistViewUrl},
					$data->{artworkUrl60},
					$data->{artworkUrl100},
					$data->{artworkUrl512},
					$data->{primaryGenreId},
					$data->{primaryGenreName},
					$data->{price},
					$data->{formattedPrice},
					$data->{averageUserRating},
					$data->{averageUserRatingForCurrentVersion},
					$data->{userRatingCount},
					$data->{userRatingCountForCurrentVersion},
					$data->{contentAdvisoryRating},
					$data->{description},
					$data->{releaseDate},
					$data->{releaseNotes},
					$data->{languageCodesISO2A},
					$data->{currency},
					$data->{sellerName},
					$data->{sellerUrl},
					$data->{trackCensoredName},
					$data->{trackContentRating},
					$data->{version},
					$data->{supportedDevices},
					$data->{bundleId},
					$data->{features},
					$data->{fileSizeBytes},
					$data->{genreIds},
					$data->{genres}
						);
};
	}else{
		# 更新対象
		# price 
		# sale セール値
		# sale_flag 
		# sale_date
		my $price = $data->{price};

		# 値段が違った場合
		if($now_price ne $data->{price}){
			&_iphone_sale($dbh,$now_price,$data->{price},$app_check);
		}

eval{
		my $sth = $dbh->prepare(qq{update app_iphone set
				    name=?,
				    url=?,
				    artistId=?,
				    artistName=?,
				    artistViewUrl=?,
				    img60=?,
				    img100=?,
				    img512=?,
				    genre_id=?,
				    genre_name=?,
				    price=?,
				    formattedPrice=?,
				    eva=?,
				    evaCurrent=?,
				    evacount=?,
				    evacountCurrent=?,
				    evaAdvisory=?,
				    description=?,
				    releaseDate=?,
				    releaseNotes=?,
				    languageCodes=?,
				    currency=?,
				    sellerName=?,
				    sellerUrl=?,
				    trackCensoredName=?,
				    trackContentRating=?,
				    appversion=?,
				    supportedDevices=?,
				    bundleId=?,
				    features=?,
				    fileSizeBytes=?,
				    genreIds=?,
				    genres=?
		 where id = ? limit 1});
		$sth->execute(
					$data->{trackName},
					$data->{trackViewUrl},
					$data->{artistId},
					$data->{artistName},
					$data->{artistViewUrl},
					$data->{artworkUrl60},
					$data->{artworkUrl100},
					$data->{artworkUrl512},
					$data->{primaryGenreId},
					$data->{primaryGenreName},
					$price,
					$data->{formattedPrice},
					$data->{averageUserRating},
					$data->{averageUserRatingForCurrentVersion},
					$data->{userRatingCount},
					$data->{userRatingCountForCurrentVersion},
					$data->{contentAdvisoryRating},
					$data->{description},
					$data->{releaseDate},
					$data->{releaseNotes},
					$data->{languageCodesISO2A},
					$data->{currency},
					$data->{sellerName},
					$data->{sellerUrl},
					$data->{trackCensoredName},
					$data->{trackContentRating},
					$data->{version},
					$data->{supportedDevices},
					$data->{bundleId},
					$data->{features},
					$data->{fileSizeBytes},
					$data->{genreIds},
					$data->{genres},
					$app_check
		);

};
	}
	
	# サムネイルの追加 or 更新
	# type 1 iphone 2 ipad
if($data->{screenshotUrls1}){
	my $img_check;
	my $sth = $dbh->prepare(qq{select app_id from app_iphone_img where app_id = ? and type = 1});
	$sth->execute($data->{trackId});
	while(my @row = $sth->fetchrow_array) {
		$img_check=1;
	}
	unless($img_check){
		$sth = $dbh->prepare(qq{insert into app_iphone_img (
					app_id,
					type,
					img1,
					img2,
					img3,
					img4,
					img5)
					values (?,1,?,?,?,?,?)});
		$sth->execute(
					$data->{trackId},
					$data->{screenshotUrls1},
					$data->{screenshotUrls2},
					$data->{screenshotUrls3},
					$data->{screenshotUrls4},
					$data->{screenshotUrls5}
					);
	}else{
		$sth = $dbh->prepare(qq{update app_iphone_img set 
					img1=?,
					img2=?,
					img3=?,
					img4=?,
					img5=?
					where app_id = ? and type = 1 limit 1});
		$sth->execute(
					$data->{screenshotUrls1},
					$data->{screenshotUrls2},
					$data->{screenshotUrls3},
					$data->{screenshotUrls4},
					$data->{screenshotUrls5},
					$data->{trackId}
					);
	}
}

if($data->{ipadScreenshotUrls1}){
	my $img_check;
	my $sth = $dbh->prepare(qq{select app_id from app_iphone_img where app_id = ? and type = 2});
	$sth->execute($data->{trackId});
	while(my @row = $sth->fetchrow_array) {
		$img_check=1;
	}
	unless($img_check){
		$sth = $dbh->prepare(qq{insert into app_iphone_img (
					app_id,
					type,
					img1,
					img2,
					img3,
					img4,
					img5)
					values (?,2,?,?,?,?,?)});
		$sth->execute(
					$data->{trackId},
					$data->{ipadScreenshotUrls1},
					$data->{ipadScreenshotUrls2},
					$data->{ipadScreenshotUrls3},
					$data->{ipadScreenshotUrls4},
					$data->{ipadScreenshotUrls5}
					);
	}else{
		$sth = $dbh->prepare(qq{update app_iphone_img set 
					img1=?,
					img2=?,
					img3=?,
					img4=?,
					img5=?
					where app_id = ? and type = 2 limit 1});
		$sth->execute(
					$data->{ipadScreenshotUrls1},
					$data->{ipadScreenshotUrls2},
					$data->{ipadScreenshotUrls3},
					$data->{ipadScreenshotUrls4},
					$data->{ipadScreenshotUrls5},
					$data->{trackId}
					);
	}

}	
	return;
}

sub _iphone_sale(){
	my $dbh = shift;
	my $old_price = shift;
	my $price = shift;
	my $app_id = shift;

	return if($old_price <= $price);

	my $date = Date::Simple->new();
	my $ymd = $date->format('%Y-%m-%d');

	my $existflag;
	my $db_price;
	my $db_sale_price;
	my $sth = $dbh->prepare(qq{select price,sale_price from app_iphone_sale where app_id = ? and delflag = 0});
	$sth->execute($app_id);
	while(my @row = $sth->fetchrow_array) {
		$db_price = $row[0];
		$db_sale_price = $row[1];
		$existflag = 1;
	}

	unless($existflag){
		# insert
		my $sth = $dbh->prepare(qq{insert into app_iphone_sale (app_id, price, sale_price, datestr, siteinfo) values(?,?,?,?,?)});
		$sth->execute($app_id,$old_price,$price,$ymd,"crowl");
	}elsif($price > $old_price){
		# セール終了
		my $sth = $dbh->prepare(qq{update app_iphone_sale set delflag = 1 where app_id = ? and delflag = 0 });
		$sth->execute($app_id);
	}elsif($price eq $db_sale_price){
		# 同じ場合は、何もしない
	}else{
		# 違う条件で更新
		my $sth = $dbh->prepare(qq{update app_iphone_sale set price=?, sale_price=?, datestr=? where app_id = ? and delflag = 0 });
		$sth->execute($old_price, $price, $ymd, $app_id);
	}
	
	return;
}




sub app_data(){
	my $dbh = shift;
	my $data = shift;

#use Data::Dumper;
#print Dumper $data;

	# カテゴリの有無
	my $category_check;
	my $sth = $dbh->prepare(qq{select id from app_category where id = ? });
	$sth->execute($data->{primaryGenreId});
	while(my @row = $sth->fetchrow_array) {
		$category_check = 1;
	}
	unless($category_check){
eval{
		my $sth = $dbh->prepare(qq{insert into app_category (id,name,category,flag) values(?,?,?,1) });
		$sth->execute($data->{primaryGenreId},$data->{primaryGenreName},$data->{primaryGenreName});
};
	}
	
	# データの追加 or 更新
	my $app_check;
	my $now_price;
	my $sth = $dbh->prepare(qq{select id,price from app where iphone_id = ? });
	$sth->execute($data->{trackId});
	while(my @row = $sth->fetchrow_array) {
		$app_check = $row[0];
	}
	unless($app_check){
eval{
		my $sth = $dbh->prepare(qq{insert into app (
				    `img`,
				    `dl_url`,
				    `appname`,
				    `ex_str`,
				    `device`,
				    `category`,
				    `developer`,
				    `price`,
				    `lang_flag`,
				    `rdate`,
				    `eva`,
				    `review`,
				    `iphone_id`,
				    `artistid`,
				    `artistname`,
				    `artisturl`,
				    `img60`,
				    `evacurrent`,
				    `advisoryeva`,
				    `cuurency`,
				    `fileSizeBytes`,
				    `formattedPrice`,
				    `categorys`,
				    `languages`,
				    `releasenotes`,
				    `sellername`,
				    `sellerurl`,
				    `supporteddevices`,
				    `reviewcuurent` ) 
				values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)} );
		$sth->execute(
					$data->{artworkUrl512},
					$data->{trackViewUrl},
					$data->{trackName},
					$data->{description},
					3,
					$data->{primaryGenreId},
					$data->{artistName},
					$data->{price},
					$data->{lang_flag},
					$data->{releaseDate},
					$data->{averageUserRating},
					$data->{userRatingCount},
					$data->{trackId},
					$data->{artistId},
					$data->{artistName},
					$data->{artistViewUrl},
					$data->{artworkUrl60},
					$data->{averageUserRatingForCurrentVersion},
					$data->{contentAdvisoryRating},
					$data->{currency},
					$data->{fileSizeBytes},
					$data->{formattedPrice},
					$data->{genreIds},
					$data->{languageCodesISO2A},
					$data->{releaseNotes},
					$data->{sellerName},
					$data->{sellerUrl},
					$data->{supportedDevices},
					$data->{userRatingCountForCurrentVersion}
						);
};
	}else{
		# 更新対象
		# price 
		# sale セール値
		# sale_flag 
		# sale_date
		my $price;
		my $sale;
		my $sale_flag = 0;
		my $sale_date;
			
		my $date = Date::Simple->new();
		my $ymd = $date->format('%Y-%m-%d');
		if($now_price > $data->{price}){
			$price = $now_price;
			$sale = $data->{price};
			$sale_flag = 1;
			$sale_date = $ymd;
		}else{
			$price = $data->{price};
		}
		my $sth = $dbh->prepare(qq{update app set device = ? where id = ? limit 1});
		$sth->execute(3,$app_check);



#eval{
		my $sth = $dbh->prepare(qq{update app set 
			img = ?,
			dl_url = ?,
			appname = ?,
			ex_str = ?,
			device = ?,
			category = ?,
			developer = ?,
			price = ?,
			lang_flag = ?,
			rdate = ?,
			eva = ?,
			review = ?,
			iphone_id = ?,
			artistid = ?,
			artistname = ?,
			artisturl = ?,
			img60 = ?,
			evacurrent = ?,
			advisoryeva = ?,
			cuurency = ?,
			fileSizeBytes = ?,
			formattedPrice = ?,
			categorys = ?,
			languages = ?,
			releasenotes = ?,
			sellername = ?,
			sellerurl = ?,
			supporteddevices = ?,
			reviewcuurent = ?,
			sale = ?,
			sale_flag = ?,
			sale_date = ?
		 where id = ? limit 1});
		$sth->execute(
					$data->{artworkUrl512},
					$data->{trackViewUrl},
					$data->{trackName},
					$data->{description},
					3,
					$data->{primaryGenreId},
					$data->{artistName},
					$price,
					$data->{lang_flag},
					$data->{releaseDate},
					$data->{averageUserRating},
					$data->{userRatingCount},
					$data->{trackId},
					$data->{artistId},
					$data->{artistName},
					$data->{artistViewUrl},
					$data->{artworkUrl60},
					$data->{averageUserRatingForCurrentVersion},
					$data->{contentAdvisoryRating},
					$data->{currency},
					$data->{fileSizeBytes},
					$data->{formattedPrice},
					$data->{genreIds},
					$data->{languageCodesISO2A},
					$data->{releaseNotes},
					$data->{sellerName},
					$data->{sellerUrl},
					$data->{supportedDevices},
					$data->{userRatingCountForCurrentVersion},
					$sale,
					$sale_flag,
					$sale_date,
					$app_check
		);

#};
#print "$@\n";
	}
	
	# サムネイルの追加 or 更新
	
	
	return;
}

sub app_android_data(){
	my $dbh = shift;
	my $data = shift;

	return unless($data->{android_id});

	# データの追加 or 更新
	my $app_check;
	my $now_price;
	my $sth = $dbh->prepare(qq{select id,price from app_android where id = ? });
	$sth->execute($data->{android_id});
	while(my @row = $sth->fetchrow_array) {
		$app_check = $row[0];
		$now_price = $row[1];
	}
	
	unless($app_check){
	
eval{
my $sth = $dbh->prepare(qq{insert into app_android (
 `id`,
 `name`,
 `url`,
 `developer_id`,
 `developer_name`,
 `img`,
 `category_id`,
 `category_name`,
 `rdate`,
 `install`,
 `installmax`,
 `rateno`,
 `revcnt`,
 `detail`,
 `dl_min`,
 `dl_max`,
 `price`
 ) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)} );
$sth->execute(
 $data->{android_id},
 $data->{name},
 $data->{dl_url},
 $data->{developer_id},
 $data->{developer_name},
 $data->{icon},
 $data->{category_id},
 $data->{category_name},
 $data->{rdate},
 $data->{install},
 $data->{installmax},
 $data->{rateno},
 $data->{revcnt},
 $data->{detail},
 $data->{dl_min},
 $data->{dl_max},
 $data->{price}
);

};

}else{ # app check
	
	# 値段が違った場合
	if($now_price ne $data->{price}){
		&_android_sale($dbh,$now_price,$data->{price},$data->{android_id});
	}
	
eval{
my $sth = $dbh->prepare(qq{update app_android set 
 `name`=?,
 `url`=?,
 `developer_id`=?,
 `developer_name`=?,
 `img`=?,
 `category_id`=?,
 `category_name`=?,
 `rdate`=?,
 `install`=?,
 `installmax`=?,
 `rateno`=?,
 `revcnt`=?,
 `detail`=?,
 `dl_min`=?,
 `dl_max`=?,
 `price`=?
 where id = ? });
$sth->execute(
 $data->{name},
 $data->{dl_url},
 $data->{developer_id},
 $data->{developer_name},
 $data->{icon},
 $data->{category_id},
 $data->{category_name},
 $data->{rdate},
 $data->{install},
 $data->{installmax},
 $data->{rateno},
 $data->{revcnt},
 $data->{detail},
 $data->{dl_min},
 $data->{dl_max},
 $data->{price},
 $data->{android_id}
);
};

}

	# サムネイルの追加 or 更新
if($data->{shot1}){
	my $img_check;
	my $sth = $dbh->prepare(qq{select app_id from app_android_img where app_id = ? and type = 0});
	$sth->execute($data->{android_id});
	while(my @row = $sth->fetchrow_array) {
		$img_check=1;
	}
	unless($img_check){
eval{
		$sth = $dbh->prepare(qq{insert into app_android_img (
					app_id,
					type,
					img1,
					img2,
					img3,
					img4,
					img5)
					values (?,0,?,?,?,?,?)});
		$sth->execute(
					$data->{android_id},
					$data->{shot1},
					$data->{shot2},
					$data->{shot3},
					$data->{shot4},
					$data->{shot5}
					);
};
	}else{
eval{
		$sth = $dbh->prepare(qq{update app_android_img set 
					img1=?,
					img2=?,
					img3=?,
					img4=?,
					img5=?
					where app_id = ? and type = 0 limit 1});
		$sth->execute(
					$data->{shot1},
					$data->{shot2},
					$data->{shot3},
					$data->{shot4},
					$data->{shot5},
					$data->{android_id}
					);
};
	}
}

	
	return;
}

sub _android_sale(){
	my $dbh = shift;
	my $old_price = shift;
	my $price = shift;
	my $app_id = shift;

	return if($old_price <= $price);
	my $date = Date::Simple->new();
	my $ymd = $date->format('%Y-%m-%d');

	my $existflag;
	my $db_price;
	my $db_sale_price;
	my $sth = $dbh->prepare(qq{select price,sale_price from app_android_sale where app_id = ? and delflag = 0});
	$sth->execute($app_id);
	while(my @row = $sth->fetchrow_array) {
		$db_price = $row[0];
		$db_sale_price = $row[1];
		$existflag = 1;
	}

	unless($existflag){
		# insert
eval{
		my $sth = $dbh->prepare(qq{insert into app_android_sale (app_id, price, sale_price, datestr, siteinfo) values(?,?,?,?,?)});
		$sth->execute($app_id,$old_price,$price,$ymd,"crowl");
};
	}elsif($price > $old_price){
		# セール終了
		my $sth = $dbh->prepare(qq{update app_android_sale set delflag = 1 where app_id = ? and delflag = 0 });
		$sth->execute($app_id);
	}elsif($price eq $db_sale_price){
		# 同じ場合は、何もしない
	}else{
		# 違う条件で更新
		my $sth = $dbh->prepare(qq{update app_android_sale set price=?, sale_price=?, datestr=? where app_id = ? and delflag = 0 });
		$sth->execute($old_price, $price, $ymd, $app_id);
	}
	
	return;
}



1;