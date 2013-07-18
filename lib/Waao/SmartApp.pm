package Waao::SmartApp;

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

	my $url = qq{http://www.applease.info/smart/};
	print qq{Location: $url\n\n};

	return;
}

sub _parts_set(){
	my $html = shift;

	# meta
	my $meta = &_load_tmpl("meta.html");
	$html =~s/<!--META-->/$meta/g;

	# header
	my $header = &_load_tmpl("header.html");
	$html =~s/<!--HEADER-->/$header/g;

	# top_html
	my $top_html = &_load_tmpl("top_html.html");
	$html =~s/<!--TOP_HTML-->/$top_html/g;

	# top_html
	my $top_html_iphone = &_load_tmpl("top_html_iphone.html");
	$html =~s/<!--TOP_HTML_IPHONE-->/$top_html_iphone/g;

	# footer
	my $footer = &_load_tmpl("footer.html");
	$html =~s/<!--FOOTER-->/$footer/g;

	my $footer_top = &_load_tmpl("footer_top.html");
	$html =~s/<!--FOOTER_TOP-->/$footer_top/g;

	my $adsence = &_load_tmpl("adsence.html");
	$html =~s/<!--ADSENCE-->/$adsence/g;

	my $adlantice = &_load_tmpl("adlantice.html");
	$html =~s/<!--ADLANTICE-->/$adlantice/g;

	return $html;
}

sub _parts_set2(){
	my $html = shift;

	# meta
	my $meta = &_load_tmpl2("meta.html");
	$html =~s/<!--META-->/$meta/g;

	# header
	my $header = &_load_tmpl2("header.html");
	$html =~s/<!--HEADER-->/$header/g;

	# top_html
	my $top_html = &_load_tmpl2("top_html.html");
	$html =~s/<!--TOP_HTML-->/$top_html/g;

	# top_html
	my $top_html_iphone = &_load_tmpl2("top_html_iphone.html");
	$html =~s/<!--TOP_HTML_IPHONE-->/$top_html_iphone/g;

	# footer
	my $footer = &_load_tmpl2("footer.html");
	$html =~s/<!--FOOTER-->/$footer/g;

	my $footer_top = &_load_tmpl2("footer_top.html");
	$html =~s/<!--FOOTER_TOP-->/$footer_top/g;

	my $adsence = &_load_tmpl2("adsence.html");
	$html =~s/<!--ADSENCE-->/$adsence/g;

	my $adlantice = &_load_tmpl2("adlantice.html");
	$html =~s/<!--ADLANTICE-->/$adlantice/g;

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
	
my $file = qq{/var/www/vhosts/goo.to/etc/makehtml/app/tmp_smf_iphone/$tmpl};
my $fh;
my $filedata;
open( $fh, "<", $file );
while( my $line = readline $fh ){ 
	$filedata .= $line;
}
close ( $fh );
	$filedata = &_date_set($filedata);
#	$filedata = &_tab_set($filedata,$tmpl);

	return $filedata;
}
sub _load_tmpl2(){
	my $tmpl = shift;
	
my $file = qq{/var/www/vhosts/goo.to/etc/makehtml/app/tmp_smf_android/$tmpl};
my $fh;
my $filedata;
open( $fh, "<", $file );
while( my $line = readline $fh ){ 
	$filedata .= $line;
}
close ( $fh );
	$filedata = &_date_set($filedata);
#	$filedata = &_tab_set($filedata,$tmpl);

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
			$app_data->{$vals[$i]} = $row[$i] if($vals[$i]);
			
			if($vals[$i] eq "evaCurrent"){
				$app_data->{$vals[$i]} = 0 unless($row[$i]);
			}
		}
	}
	$app_data->{formattedPrice}=~s/\?/¥/g;
	
	$app_data->{img100}=$app_data->{img100};
	$app_data->{img100}=~s/\.jpg/\.100x100-75\.jpg/g;
	$app_data->{img100}=~s/\.png/\.100x100-75\.png/g;
	
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
		$shotimgs_full .= qq{<img src="$img1" width=100% alt="$appname"> } if($img1);
		$shotimgs_full .= qq{<img src="$img2" width=100% alt="$appname"><br /> } if($img2);
		$shotimgs_full .= qq{<img src="$img3" width=100% alt="$appname"> } if($img3);
		$shotimgs_full .= qq{<img src="$img4" width=100% alt="$appname"><br /> } if($img4);
		$shotimgs_full .= qq{<img src="$img5" width=100% alt="$appname"> } if($img5);
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
	my $list;
	my $rankdate;
	my $sth = $self->{dbi}->prepare(qq{select rankdate from app_iphone_rank order by rankdate limit 1});
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$rankdate = $row[0];
	}
	my $sth = $self->{dbi}->prepare(qq{SELECT name, url, img100, eva, evacount,formattedPrice,A.id,genres,genre_id
										FROM app_iphone AS A, app_iphone_rank AS B
										WHERE A.id = B.app_id
											AND B.type =1
											AND B.genre =?
											AND B.rankdate = ?
											ORDER BY B.rankno
											LIMIT 9});
	$sth->execute($app_data->{genre_id},$rankdate);
	while(my @row = $sth->fetchrow_array) {
		my $img = $row[2];
		$img=~s/\.jpg/\.100x100-75\.jpg/ig;
		$img=~s/\.png/\.100x100-75\.png/ig;
		my $eva = $row[3];
		$eva=0 unless($eva);
		my $star_str = &_star_img($eva);

		my $price_str;
		$price_str.=qq{$price_str<br />};
		my $genrestr = substr($row[7],0,30);
		$row[4] = 0 unless($row[4]);

		$list.=qq{<div>\n};
		$list.=qq{<a href="/smart/iphone-app-$row[6]/">\n};
		$list.=qq{<p class=price>\n};
		$list.=qq{$price_str\n};
		$list.=qq{<span class="rounded-img" style="background: url($img) no-repeat center center; width: 86px; height: 86px;">\n};
		$list.=qq{<img src="$img" style="opacity: 0;" alt="$row[0]" /></span>\n};
		$list.=qq{</p>\n};
		$list.=qq{<h3 class="textOverflow">$row[0]</h3>};
		$list.=qq{$star_str};
		$list.=qq{<p class="textOverflow category">$genrestr</p>};
		$list.=qq{</a>\n};
		$list.=qq{</div>\n};


	}
	$html =~s/<!--LIST-->/$list/g;


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

sub _detail_dsp_android(){
	my $self = shift;

	my $html = &_load_tmpl2("app_android_detail.html");
	$html = &_parts_set2($html);

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
	$html =~s/<!--LIST-->/$rank_rec/g;

	# ランダム
	my $randam_rec;
	my $sth = $self->{dbi}->prepare(qq{SELECT name, url, img, rateno, revcnt,price,detail,id
										FROM app_android
										WHERE rateno >= 4
											ORDER BY rand()
											LIMIT 16});
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

1;