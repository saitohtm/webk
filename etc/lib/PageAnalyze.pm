package PageAnalyze;

use Exporter;
@ISA = (Exporter);
@EXPORT = qw(itunes_page googleplay_page facebook_page itunes_page_lookup);

use Unicode::Japanese;
use LWP::UserAgent;
use Jcode;
use JSON;

sub facebook_page(){
	my $dl_url = shift;

binmode(STDOUT, ":utf8");# PerlIOレイヤ
use open ":utf8";

	my $data;
	$data = &_facebook_page_analyze($dl_url,$data);

	# graph api 使用
	$data = &_facebook_graph_api($dl_url,$data);
	unless($data->{img}){
		$data = &_facebook_page_analyze($data->{link},$data) if($data->{link});
	}
	return $data;
}

sub _facebook_graph_api(){
	my $dl_url = shift;
	my $data = shift;

#	print "$dl_url _facebook_graph_api\n";

	if($dl_url=~/http:\/\/www.facebook.com\/(.*)/){
		$dl_url = $1;
	}
	if($dl_url=~/https:\/\/www.facebook.com\/(.*)/){
		$dl_url = $1;
	}
	if($dl_url=~/http:\/\/ja-jp.facebook.com\/(.*)/){
		$dl_url = $1;
	}
	if($dl_url=~/http:\/\/apps.facebook.com\/(.*)/){
		$dl_url = $1;
	}
	if($dl_url=~/pages\/(.*)\/(.*)/){
		$dl_url = $2;
	}
	$dl_url =~s/\#!//g;
	$dl_url = $data->{id} if($data->{id});
	my $cmd = qq{https://graph.facebook.com/$dl_url};
	print "$cmd _facebook_graph_api\n";
	my $get_url = `GET "$cmd"`;

eval{
	$get_url = decode_json($get_url);
};
#	print "unless_data" unless($get_url);

	return $data unless($get_url);

foreach my $key ( sort keys( %{$get_url} ) ) {
eval{
	if($get_url->{cover}->{source}){
		$data->{cover_img} = $get_url->{cover}->{source};
	}
	$data->{$key} = $get_url->{$key};
#    	print "$key : $data->{$key}\n "
};
}
	
my $datas;
foreach my $key ( sort keys( %{$data} ) ) {
#    print "$key:$data->{$key}\n ";
	$datas .= "$key:$data->{$key}\n";
}
$data->{datas} = $datas;

	return $data;
}

sub _facebook_page_analyze(){
	my $dl_url = shift;
	my $data   = shift;

#	print "$dl_url _facebook_page_analyze\n";
	my $get_url = `GET "$dl_url"`;

	
	my @lines = split(/\n/,$get_url);
	foreach my $line (@lines){

		if($line =~/(.*)profile_owner&quot;:&quot;(.*)&quot;,&quot;ref(.*)/){
			$data->{id} = $2;
		}
		if($line =~/(.*)<div class=\"uiScaledImageContainer profilePic\"(.*)><img class=\"scaledImageFitWidth img\" src=\"(.*)\" alt=\"(.*)\"(.*)/){
			$data->{img} = $3;
		}elsif($line =~/(.*)<div class=\"uiScaledImageContainer profilePic\"(.*)><img class=\"img\" src=\"(.*)\" alt=\"(.*)\"(.*)/){
			$data->{img} = $3;
		}elsif($line =~/(.*)<div class=\"uiScaledImageContainer profilePic\"(.*)><img class=\"img\" src=\"(.*)\" style=\"(.*)\"(.*)/){
			$data->{img} = $3;
		}elsif($line =~/(.*)<img class=\"profilePic img\" src=\"(.*)\" alt=\"(.*)/){
			$data->{img} = $2;
		}



		if($line =~/(.*)<img class=\"coverPhotoImg photo img\" src=\"(.*)\" style=(.*)/){
			$data->{cover_img} = $2;
		}
		if($line =~/(.*)<title>(.*)<\/title>(.*)/){
			$data->{name} = $2;
		}
		if($line =~/(.*)いいね！(.*)人(.*)話題にしている人(.*)人(.*)/){
			$data->{like} = $2;
			$data->{talking_about_count} = $4;
			$data->{like} =~s/,//g;
			$data->{talking_about_count} =~s/,//g;
		}
	}

	# 基本情報
	my $info_url = $dl_url.qq{/info};
#	print "$info_url _facebook_page_analyze\n";
	my $get_url = `GET "$info_url"`;

	my @lines = split(/\n/,$get_url);
	foreach my $line (@lines){
		if($line =~/(.*)<h3 tabindex=\"0\" class=\"uiHeaderTitle\">情報<\/h3>(.*)<div class="mhl">(.*)<\/div><div class=\"mhl\">(.*)/){
			$data->{expl} .= $3;
		}
		if($line =~/(.*)<div class=\"mvm uiP fsm\"><span class=\"fwb\">基本情報<\/span><\/div>(.*)<\/div><\/div><\/div>(.*)/){
			$data->{expl} .= $2;
		}		
	}

	return $data;
}


sub itunes_page(){
	my $dl_url = shift;

binmode(STDOUT, ":utf8");# PerlIOレイヤ
use open ":utf8";

	my $data;
	# url 整理
	if($dl_url =~/(.*)itunes(.*)\/id(.*)\?(.*)/){
		$data->{iphone_id} = $3;
	}elsif($dl_url =~/(.*)itunes(.*)\/id(.*)/){
		$data->{iphone_id} = $3;
	}

	my $get_url = `GET "$dl_url"`;

	$get_url=~s/<div class=\"price\">/\n<div class=\"price\">/g;
	$get_url=~s/<span>/\n<span>/g;
	$get_url=~s/<li>/\n<li>/g;
	$get_url=~s/<img/\n<img/g;
	my @lines = split(/\n/,$get_url);

	my $shotcnt;
	
	foreach my $line (@lines){


		# DL_URL
		if($line =~/<link rel=\"canonical\" href=\"(.*)\" \/>/){
			$data->{dl_url} = $1;
		}
		# アイコン画像
		if($line =~/<img width=\"175\"(.*) class=\"artwork\" src=\"(.*)\" \/>(.*)/){
			$data->{icon} = $2 unless($data->{icon});
		}elsif($line =~/(.*)width=\"175\" height=\"175\"(.*)src=\"(.*)\" \/><span(.*)/){
			$data->{icon} = $3;
		}

		
		# 名前
		if($line =~/<h1>(.*)<\/h1>/){
			$data->{name} = $1;
		}
		# 開発者
		if($line =~/<h2>開発: (.*)<\/h2>/){
			$data->{developer_name} = $1;
		}
		# 開発者ID
		if($line =~/(.*)<a href=(.*)\/artist\/(.*)\/id(.*)\"(.*)/){
			$data->{developer_id} = $3;
		}
		# カテゴリ
		if($line =~/<span class=\"label\">カテゴリ: <\/span><a href=\"(.*)\/genre\/(.*)\/id(.*)\?(.*)\">(.*)<\/a>(.*)/){
			$data->{category_id} = $3;
			$data->{category_name} = $5;
		}
		# 更新日
		if($line =~/<span class=\"label\">更新: <\/span> (.*)<\/li>/){
			$data->{rdate} = $1;
		}
		# バージョン
		if($line =~/<span class=\"label\">(.*)ジョン: <\/span>(.*)<\/li>/){
			$data->{version} = $2;
		}
		# 言語
		if($line =~/<span class=\"label\">言語: <\/span>(.*)<\/li>/){
			my $lang = $1;
			$data->{lang} = 0;
			$data->{lang} = 1 if($lang =~/日本語/);
		}
		# 評価
		if($line =~/<div class='rating' role='img' tabindex='-1' aria-label='星 (.*), (.*) 件の評価'><div>/){
			$data->{rateno} = $1;
			$data->{revcnt} = $2;
			$data->{rateno} =~s/ つ//g;
		}
		# 画面イメージ
		if($line =~/<img alt=\"(.*)ショット (.*)src=\"(.*)\" \/><\/div(.*)/){
			$shotcnt++;
			$data->{shot1} = $3 if($shotcnt eq 1);
			$data->{shot2} = $3 if($shotcnt eq 2);
			$data->{shot3} = $3 if($shotcnt eq 3);
			$data->{shot4} = $3 if($shotcnt eq 4);
			$data->{shot5} = $3 if($shotcnt eq 5);
		}
		if($line =~/<div class="price">(.*)<\/div>(.*)/){
			$data->{sale_price} = $1;
			$data->{sale_price} =~s/\?//;
			$data->{sale_price} = 0 if($data->{sale_price} eq "無料");
			$data->{sale_price} =~s/,//g;
		}
		# 詳細
		if($line =~/Titledbox_詳細/){
			$data->{detail_flag} = 1;
		}
		if($data->{detail_flag}){
			if($line =~/(.*)<p>(.*)<\/p>/){
				$data->{detail} = $2;
				$data->{detail_flag} = undef;
			}
		}
	}

#foreach my $key ( sort keys( %{$data} ) ) {
#    print "$key : $data->{$key} <br />\n "
#}
	
	return $data;
}


sub googleplay_page(){
	my $dl_url = shift;

binmode(STDOUT, ":utf8");# PerlIOレイヤ
use open ":utf8";

	my $data;
	if($dl_url =~/(.*)google(.*)\?id=(.*)/){
		my $tmp = $3;
		my @tmp_val = split(/&/,$tmp);
		$data->{android_id} = $tmp_val[0];
	}elsif($dl_url =~/(.*)android(.*)\?id=(.*)/){
		my $tmp = $3;
		my @tmp_val = split(/&/,$tmp);
		$data->{android_id} = $tmp_val[0];
	}else{
		$data->{android_id} = $dl_url;
#		$dl_url = qq{https://play.google.com/store/apps/details?id=}.$dl_url.qq{&hl=ja};
		$dl_url = qq{https://play.google.com/store/apps/details?id=}.$dl_url;
	}

	my $get_url = `GET "$dl_url"`;

	my $shotcnt;
		
	$get_url=~s/<div/\n<div/g;
	$get_url=~s/<dt/\n<dt/g;
	$get_url=~s/<img/\n<img/g;
	my @lines = split(/\n/,$get_url);
	my $iconflg;
	foreach my $line (@lines){
		# DL_URL
			$data->{dl_url} = $dl_url;
		# 名前
		if($line =~/<h1(.*)class=\"doc-banner-title\">(.*)<\/h1>/){
			$data->{name} = $2;
		}
		# アイコン画像
		if($line =~/<div class=\"doc-banner-icon\">/){
			$iconflg = 1;
		}
		if($iconflg){
			if($line =~/<img(.*)src=\"(.*)\"\/>(.*)/){
				$data->{icon} = $2 unless($data->{icon});
				$iconflg = undef;
			}
		}
		# 開発者
		if($line =~/<a href=\"\/store\/apps\/developer\?id=(.*)\" class=\"doc-header-link\">(.*)<\/a>(.*)/){
			$data->{developer_id} = $1;
			$data->{developer_name} = $2;
		}

		# カテゴリ
		if($line =~/<dt>Category:<\/dt><dd><a href=\"\/store\/apps\/category\/(.*)\?(.*)\">(.*)<\/a><\/dd>/){
			$data->{category_id} = $1;
			$data->{category_name} = $3;
		}
		# 更新日
		if($line =~/(.*)<dt>Updated:<\/dt><dd><time itemprop=\"datePublished\">(.*) (.*), (.*)<\/time><\/dd>/){
			my $month;
    		$month->{January} = 1;
    		$month->{February} = 2;
    		$month->{March} = 3;
    		$month->{April} = 4;
    		$month->{May} = 5;
    		$month->{June} = 6;
    		$month->{July} = 7;
    		$month->{August} = 8;
    		$month->{September} = 9;
    		$month->{October} = 10;
    		$month->{November} = 11;
    		$month->{December} = 12;
			$data->{rdate} = sprintf("%4d-%02d-%02d",$4,$month->{$2},$3);
		}

		# インストール
		if($line =~/(.*)<dt>Installs:<\/dt><dd itemprop=\"numDownloads\">(.*) - (.*)<\/dd>/){
			$data->{install} = $2;
			$data->{installmax} = $3;
		}
		# 評価
		if($line =~/<div class=\"ratings goog-inline-block\" title=\"Rating: (.*) stars (.*)/){
			$data->{rateno} = $1 unless($data->{rateno});
		}
		if($line =~/<div class=\"goog-inline-block\"(.*)title=\" (.*)ratings(.*)/){
			$data->{revcnt} = $2 unless($data->{revcnt});
		}
		# 画面イメージ
		if($line =~/<img src=\"(.*)\" class=\"doc-screenshot-img(.*)/){
			$shotcnt++;
			$data->{shot1} = $1 if($shotcnt eq 1);
			$data->{shot2} = $1 if($shotcnt eq 2);
			$data->{shot3} = $1 if($shotcnt eq 3);
			$data->{shot4} = $1 if($shotcnt eq 4);
			$data->{shot5} = $1 if($shotcnt eq 5);
		}
		# 詳細
		if($line =~/<div id=\"doc-original-text\" >(.*)<\/div><\/div>/){
			$data->{detail} = $1;
		}elsif($line =~/<div id=\"doc-original-text\" itemprop=\"description\">(.*)<\/div><\/div>/){
			$data->{detail} = $1;
		}elsif($line =~/<div id=\"doc-original-text\" itemprop=\"description\">(.*)<\/div>/){
			$data->{detail} = $1;
		}
		
		# DL数
		if($line =~/<dt>(.*)<\/dt><dd itemprop=\"numDownloads\">(.*) - (.*)/){
			$data->{dl_mini} = $2;
			$data->{dl_max} = $3;
			$data->{dl_mini} =~s/,//g;
			$data->{dl_max} =~s/,//g;
			$data->{dl_max} =~s/<\/dd>//g;
		}
		if($line =~/<dt>Price:(.*)<span itemprop=\"price\"(.*)<\/span>(.*)<span(.*)/){
			$data->{price} = $3;
			if($data->{price} =~/(.*)<span(.*)/){
				$data->{price} = $1;
				$data->{price} =~s/\?//;
				$data->{price} =~s/￥//;
				$data->{price} = 0 if($data->{sale_price} eq "無料");
				$data->{price} = 0 if($data->{price} eq "無");
				$data->{price} = 0 if($data->{price} eq "Free");
				$data->{price} =~s/,//g;
			}
		}
		# 画面イメージ
		if($line =~/<div class=\"doc-banner-image-container\"><img src=\"(.*)\" alt(.*)/){
			$data->{thum_img} = $1 unless($data->{thum_img});
		}
	}
	
	# ヤフーで確認
	unless($data->{price} eq 0){
		my	$dl_url = qq{http://market.yahoo.co.jp/app/android/details/}.$data->{android_id}.qq{/a};
		my $get_url = `GET "$dl_url"`;
		$get_url=~s/<p/\n<p/g;
		my @lines = split(/\n/,$get_url);
		foreach my $line (@lines){
			if($line =~/(.*)priceWp(.*)now\">(.*)<\/span>(.*)/){
				$data->{price} = $3;
				$data->{price} =~s/,//g;
				chop($data->{price});
			}
		}
	}

foreach my $key ( sort keys( %{$data} ) ) {
#    print "$key : $data->{$key} \n "
#    print "$key :  \n "
}

	return $data;
}

sub itunes_page_lookup(){
	my $dl_url = shift;

	my $iphone_id;
	if($dl_url =~/(.*)itunes(.*)\/id(.*)\?(.*)/){
		$iphone_id = $3;
	}elsif($dl_url =~/(.*)itunes(.*)\/id(.*)/){
		$iphone_id = $3;
    }else{
        $iphone_id = $dl_url;
	}
    $iphone_id =~s/\?//g;

	$dl_url = qq{http://itunes.apple.com/lookup?country=JP&id=$iphone_id};
#print $iphone_id."<br />\n";
#print $dl_url."<br />\n";
	my $get_url = `GET "$dl_url"`;

eval{
	$get_url = decode_json($get_url);
};

#use Data::Dumper;
#print Dumper $get_url->{results}->[0];

my $data;
foreach my $key ( sort keys( %{$get_url->{results}->[0]} ) ) {

eval{
	if(ref($get_url->{results}->[0]->{$key}) eq "ARRAY"){
		my $cnt;
		my $str;
		foreach my $array_val (@{$get_url->{results}->[0]->{$key}}) {
			$cnt++;
			my $tme_str = $key.$cnt;
			$data->{$tme_str} = $array_val;
			$str.= $data->{$tme_str};
		}
		$data->{$key} = $str;
	}else{
		$data->{$key} = $get_url->{results}->[0]->{$key};
		if($key eq "currency"){
			$data->{lang_flag} = 1 if($data->{$key} eq "JPY");
		}elsif($key eq "releaseDate"){
			$data->{releaseDate} = substr($data->{releaseDate},0,10);
		}
	}
};
}
foreach my $key ( sort keys( %{$data} ) ) {
#   print "$key : $data->{$key} \n ";
	if($data->{artworkUrl60}){
		$data->{img60} = $data->{artworkUrl60} unless($data->{img60});
	}
	if($data->{artworkUrl512}){
		$data->{img512} = $data->{artworkUrl512} unless($data->{img512});
	}
	if($data->{artworkUrl100}){
		$data->{img100} = $data->{artworkUrl100} unless($data->{img100});
	}
}

# tif対応
my $tmp_a=$data->{img512};
if($tmp_a =~/tif/ ){
	my $data2 = &itunes_page($data->{trackViewUrl});
	$data->{img100} = $data2->{icon};
	$data->{artworkUrl100} = $data2->{icon};
	$data->{img512} = $data2->{icon};
	$data->{artworkUrl512} = $data2->{icon};
}
	return $data;
}
1;