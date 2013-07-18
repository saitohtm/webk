#!/usr/bin/perl
use lib qw(/var/www/vhosts/goo.to/etc/lib /var/www/vhosts/goo.to/lib/Waao);

# googleplay
# http://d.hatena.ne.jp/tamiyant/20120414/1334390962

#use strict;
use DBI;
use Unicode::Japanese;
use LWP::UserAgent;
use Jcode;
use Utility;
use XML::Simple;
use LWP::Simple;
use PageAnalyze;
use DataController;

use Date::Simple;

# ２重起動防止
if ($$ != `/usr/bin/pgrep -fo $0`) {
print "exit \n";
    exit 1;
}
print "start \n";


my $dbh = &_db_connect();

# 課題：＄表示が残る
#       カテゴリ名が英語

&_mkdir("apprank");
&_mkdir("apprank/paid");
&_mkdir("apprank/free");
&_mkdir("apprank/newpaid");
&_mkdir("apprank/newfree");

&_mkdir("appranklist");
&_mkdir("appranklist/paid");
&_mkdir("appranklist/free");
&_mkdir("appranklist/newpaid");
&_mkdir("appranklist/newfree");

my $url = qq{http://www.appannie.com/top/android/japan/};

&_install($dbh,$url,1);
&_install($dbh,$url,2);
&_install($dbh,$url,4);
&_install($dbh,$url,0);

my $sth = $dbh->prepare(qq{SELECT id,key_value,game FROM app_category where id < 6000 order by id desc });
$sth->execute();
while(my @row = $sth->fetchrow_array) {
	my $genre = $row[1];
	$genre =~ tr/A-Z/a-z/;
	$genre =~s/_/-/g;
	&_mkdir("apprank/$genre");
	&_mkdir("apprank/$genre/paid");
	&_mkdir("apprank/$genre/free");
	&_mkdir("apprank/$genre/newpaid");
	&_mkdir("apprank/$genre/newfree");
	&_mkdir("appranklist/$genre");
	&_mkdir("appranklist/$genre/paid");
	&_mkdir("appranklist/$genre/free");
	&_mkdir("appranklist/$genre/newpaid");
	&_mkdir("appranklist/$genre/newfree");
	my $url;
	if($row[2]){
		$url = qq{http://www.appannie.com/top/android/japan/game/$genre/};
	}else{
		$url = qq{http://www.appannie.com/top/android/japan/application/$genre/};
	}
	&_install($dbh,$url,1,$genre);
	&_install($dbh,$url,2,$genre);
	&_install($dbh,$url,4,$genre);
	&_install($dbh,$url,0,$genre);
}
$dbh->disconnect;
exit;

sub _install(){
	my $dbh = shift;
	my $url = shift;
	my $retu = shift;
	my $genre = shift;

print "INS $url \n";
	my $list;

my $ua = LWP::UserAgent->new(
	agent		=> "Mozilla/5.0",
	timeout		=> 10,
);
	my $request  = $ua->get("$url");

	my $get_url = $request->content;
	my @lines = split(/>/,$get_url);

	my $rankno;
	my $ranking;
	foreach my $line (@lines){
		if($line =~/(.*)app\/android\/(.*)\/\"/){
			my $id = $2;
			$rankno++;
			if(($rankno % 5) == $retu){
				$ranking++;
				my $data = &googleplay_page($id);
				&app_android_data($dbh,$data);
foreach my $key ( sort keys( %{$data} ) ) {
#    print "$key : $data->{$key} \n " if($key eq "price");
    print "$key :  $data->{$key}\n "
}

				my $name = $data->{name};
				my $url = $data->{dl_url};
				my $img100 = $data->{icon};
				my $eva = $data->{rateno};
				my $evacount = $data->{revcnt};
				$eva=0 unless($eva);
				$evacount=0 unless($evacount);

				my $formattedPrice = $data->{price};
				my $genres = $data->{category_name}; 
				my $genre_id =$data->{category_id};
				my $star_str = &_star_img($eva);
				my $price_str = &_price_str($formattedPrice);
				my $genrestr = substr($genres,0,30);
				$genrestr.=qq{...};

				$list.=qq{<div>\n};
				$list.=qq{<a href="/androidapp-$id/">\n};
				$list.=qq{<p class=price>\n};
				$list.=qq{$price_str\n} if($formattedPrice);
				$list.=qq{<span class="rounded-img" style="background: url($img100) no-repeat center center; width: 86px; height: 86px;">\n};
				$list.=qq{<img src="$img100" style="opacity: 0;" alt="$name" /></span>\n};
				$list.=qq{</p>\n};
				$list.=qq{<h3 class="textOverflow">$name</h3>};
				$list.=qq{$star_str};
				$list.=qq{<p class="textOverflow category">$genrestr</p>};
				$list.=qq{</a>\n};
				$list.=qq{</div>\n};
last if($ranking >= 300);
				print "$ranking $id \n";
			}
		}
	}

	if($list){
		$list = qq{<div id="grid-content">}.$list.qq{</div>};
	}

	my $html;
	my $dir_str;
	if($retu == 1){
		$dir_str = qq{free};
		$html = &_load_tmpl("androidrank300_free.html");
	}elsif($retu == 2){
		$dir_str = qq{paid};
		$html = &_load_tmpl("androidrank300.html");
	}elsif($retu == 4){
		$dir_str = qq{newfree};
		$html = &_load_tmpl("androidrank300_newfree.html");
	}elsif($retu == 0){
		$dir_str = qq{newpaid};
		$html = &_load_tmpl("androidrank300_newpaid.html");
	}
	if($genre){
		$dir_str = qq{$genre/$dir_str};
	}

	use Encode;
	$list = encode('utf-8', $list);
	$html =~s/<!--LIST-->/$list/g;

	my $titlestr = &_get_name($retu);
	$html =~s/<!--TITLESTR-->/$titlestr/g;
	my $ranktab = &_rank_tab_set($retu);
	$html =~s/<!--RANK_TABS-->/$ranktab/g;

	my $caterank;
	my $caterankstr.=qq{<form><select onChange="location.href=value;">};
	$caterankstr.=qq{<option value="#">選択</option>};
	my $sth = $dbh->prepare(qq{SELECT id,name FROM app_category where id < 6000 order by id });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$caterank .= qq{<a href="/android/apprank/$genre/$row[0]/">$row[1]</a> };
		$caterankstr.=qq{<option value="/android/apprank/$genre/$row[0]/">$row[1]</option>};
	}
	$caterankstr.=qq{</select></form>};
	
	$html =~s/<!--CATERANKLISTSTR-->/$caterankstr/g;
	$html =~s/<!--CATERANKLIST-->/$caterank/g;

	$html = &_parts_set($html);
	
	
	$html =~s/<!--DIRSTR-->/$dir_str/g;
	&_move_file300($dir_str);

	my $backstr;
	my $back.=qq{<form><select onChange="location.href=value;">};
	$back.=qq{<option value="#">選択</option>};
	for (my $i=1; $i<=30; $i++){
		$backstr .= qq{<a href="/android/apprank/$dir_str/index$i.html">$i日前</a> };
		$back.=qq{<option value="/android/apprank/$dir_str/index$i.html">$i日前</option>};
	}
	$back.=qq{</select></form>};
	$html =~s/<!--BACKLIST-->/$backstr/g;
	$html =~s/<!--BACKLISTSTR-->/$back/g;

	my $a = qq{my.css};
	my $b = qq{smartphone.css};
	$html =~s/$a/$b/g;
print "/var/www/vhosts/goo.to/httpdocs-applease/android/apprank/$dir_str/index.html\n";

	&_file_output("/var/www/vhosts/goo.to/httpdocs-applease/android/apprank/$dir_str/index.html",$html);

	return;
}

sub _category_list(){
	my $dbh = shift;

	my $list = &_load_tmpl("cate_list.html");

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
	my $catelist = &_category_list();
	$html =~s/<!--CATELIST-->/$catelist/g;

	$html =~s/<!--META-->/$meta/g;
	$html =~s/<!--HEADER-->/$header/g;
	$html =~s/<!--FOOTER-->/$footer/g;

	# slider
	my $social_tag = &_load_tmpl("social_tag.html");
	$html =~s/<!--SOCIAL_TAG-->/$social_tag/g;

	# ad
	my $ad_header = &_load_tmpl("ad_header.html");
	$html =~s/<!--AD_HEADER-->/$ad_header/g;

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

sub _date_set(){
	my $html = shift;
	my $date = Date::Simple->new();
	my $ymd = $date->format('%Y/%m/%d');
	$html =~s/<!--DATE-->/$ymd/ig;
	return $html;
}

sub _load_tmpl(){
	my $tmpl = shift;
	
my $file = qq{/var/www/vhosts/goo.to/etc/makehtml/app/tmpl_android_new/$tmpl};
#print "$file\n";
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

sub _file_output(){
	my $filename = shift;
	my $html = shift;

	$html =~s/<!--LISTDSP-->//g;
print "$filename";
	open(OUT,"> $filename") || die('error');
	print OUT "$html";
	close(OUT);

	return;
}

sub _move_file300(){
	my $dir = shift;
	
	for (my $i=30; $i>=0; $i--){
		if($i eq 30){
		}else{
			my $next = $i + 1;
			$i = undef if($i eq 0);
			my $cmd = qq{mv /var/www/vhosts/goo.to/httpdocs-applease/android/apprank/$dir/index$i.html /var/www/vhosts/goo.to/httpdocs-applease/android/apprank/$dir/index$next.html};
eval{
			`$cmd`;
};
		}
	}

	return;
}

sub _get_name(){
	my $keyword = shift;
	
	my $name;
	$name->{1} = qq{有料アプリ};
	$name->{2} = qq{無料アプリ};
	$name->{4} = qq{新着有料アプリ};
	$name->{5} = qq{新着無料アプリ};
	
	return $name->{$keyword};
}

sub _rank_tab_set(){
	my $genre = shift;
	my $tabs;

	my $activ_1;
	$activ_1 = qq{ class="active"} if($genre eq 1);
	my $activ_2;
	$activ_2 = qq{ class="active"} if($genre eq 2);
	my $activ_3;
	$activ_3 = qq{ class="active"} if($genre eq 4);
	my $activ_4;
	$activ_4 = qq{ class="active"} if($genre eq 5);

	$tabs .= qq{<div class="container-fluid">\n};
	$tabs .= qq{<ul class="tabs">\n};
	$tabs .= qq{<li$activ_1><a href="/android/apprank/paid/">無料アプリ</a></li>\n};
	$tabs .= qq{<li$activ_2><a href="/android/apprank/free/">有料アプリ</a></li>\n};
	$tabs .= qq{<li$activ_3><a href="/android/apprank/newpaid/">新着無料アプリ</a></li>\n};
	$tabs .= qq{<li$activ_4><a href="/android/apprank/newfree/">新着有料アプリ</a></li>\n};
	$tabs .= qq{</ul>\n};
	$tabs .= qq{</div>\n};

	return $tabs;
}

sub _mkdir(){
	my $dir = shift;
	
	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-applease/android/$dir/};
	mkdir($dirname, 0755);

	return;
}

sub _star_img(){
	my $point = shift;
	$point=~s/ //g;
	
	my $str;
	$str = qq{<img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">};
	if($point == 5){
		$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png">};
	}elsif($point < 5.0){
		$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-half.png">};
	}elsif($point < 4.5){
		$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-off.png">};
	}elsif($point < 4.0){
		$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-half.png"><img src="/img/star-off.png">};
	}elsif($point < 3.5){
		$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-off.png"><img src="/img/star-off.png">};
	}elsif($point < 3.0){
		$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-half.png"><img src="/img/star-off.png"><img src="/img/star-off.png">};
	}elsif($point < 2.5){
		$str = qq{<img src="/img/star-on.png"><img src="/img/star-on.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">};
	}elsif($point < 2.0){
		$str = qq{<img src="/img/star-on.png"><img src="/img/star-half.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">};
	}elsif($point < 1.5){
		$str = qq{<img src="/img/star-on.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">};
	}elsif($point < 1){
		$str = qq{<img src="/img/star-half.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">};
	}elsif($point < 0.5){
		$str = qq{<img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png"><img src="/img/star-off.png">};
	}
	
	return $str;
}
sub _price_str(){
	my $price = shift;
	my $price_str;
    $price =~s/\?/￥/g;

	if($price eq 0){
		$price_str = qq{<img src="/img/Free.gif" alt="無料アプリ">};
	}elsif($price eq "無料"){
		$price_str = qq{<img src="/img/Free.gif" alt="無料アプリ">};
	}else{
		$price_str = qq{<img src="/img/E12F_20.gif" height=15> $price};
	}

	return $price_str;
}

sub _db_connect(){

    my $dsn = 'DBI:mysql:waao';
    my $user = 'mysqlweb';
    my $password = 'WaAoqzxe7h6yyHz';
    my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 1, AutoCommit => 0});

    return $dbh;
}

1;
