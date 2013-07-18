package Waao::AppAndroidList;

use lib qw(/var/www/vhosts/goo.to/etc/lib /var/www/vhosts/goo.to/lib/Waao);
use DBI;
use CGI;
use Cache::Memcached;
use Date::Simple;

sub dispatch(){
	my $self = shift;

	my $page = $self->{cgi}->param('page');

	my $html = &_load_tmpl("good_androidlist.html");
	$html =~s/<!--PAGE-->/$page/g;
	$html = &_parts_set($html);
	
	my $pagemax = 15;
	my $start =  0 + ($pagemax * ($page - 1));

	my $list2 = &_make_list($self, qq{ order by rdate desc, rateno desc limit $start, $pagemax },$start);
	$html =~s/<!--LIST-->/$list2/g;

	my $pager .= &_pager($page,"good-android-app");
	$html =~s/<!--PAGER-->/$pager/g;

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}

sub _pager(){
	my $page = shift;
	my $type = shift;
	my $pagelist;

	$pagelist .= qq{<div class="pagination">\n};
	$pagelist .= qq{<ul>\n};
	if($page == 1){
	   	$pagelist .= qq{<li class="prev disabled"><a href="/android/$type-1/">&larr; Previous</a></li>\n};
	}else{
		my $preno = $page - 1;
	   	$pagelist .= qq{<li class="prev"><a href="/android/$type-$preno/">&larr; Previous</a></li>\n};
	}
	my $pageno;
	for(my $i=0; $i<10; $i++){
		$pageno = $page + $i;
		if($page eq $pageno){
		    $pagelist .= qq{<li class="active"><a href="/android/$type-$pageno/">$pageno</a></li>\n};
		}else{
		    $pagelist .= qq{<li><a href="/android/$type-$pageno/">$pageno</a></li>\n};
		}
	}
	$pageno++;
    $pagelist .= qq{<li class="next"><a href="/android/$type-$pageno/">Next &rarr;</a></li>\n};
    $pagelist .= qq{</ul>\n};
    $pagelist .= qq{</div>\n};

	return $pagelist;
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

sub _make_list(){
	my $self = shift;
	my $where = shift;
	my $startno = shift;

	my $list;
	my $sth;
	$sth = $self->{dbi}->prepare(qq{select id,name,url,developer_id,developer_name,img,category_id,category_name,rdate,rateno,revcnt,detail,dl_max,price from app_android $where });

	$sth->execute();
	$startno = 0 unless($startno);
	my $no = $startno;
	while(my @row = $sth->fetchrow_array) {
	my ($id,$name,$url,$developer_id,$developer_name,$img,$category_id,$category_name,$rdate,$rateno,$revcnt,$detail,$dl_max,$price) = @row;

	my $shotimgs;
	my $sth2 = $self->{dbi}->prepare(qq{select type,img1,img2,img3,img4,img5 from app_android_img where app_id = ? limit 1});
	$sth2->execute($row[6]);
	while(my @row2 = $sth2->fetchrow_array) {
		my ($type,$img1,$img2,$img3,$img4,$img5) = @row2;
		$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img1" alt="$row[0]" /><img src="$img1" alt="$row[0]" class="preview" /></a></li>} if($img1);
		$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img2" alt="$row[0]" /><img src="$img2" alt="$row[0]" class="preview" /></a></li>} if($img2);
		$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img3" alt="$row[0]" /><img src="$img3" alt="$row[0]" class="preview" /></a></li>} if($img3);
		$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img4" alt="$row[0]" /><img src="$img4" alt="$row[0]" class="preview" /></a></li>} if($img4);
		$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img5" alt="$row[0]" /><img src="$img5" alt="$row[0]" class="preview" /></a></li>} if($img5);
	}

		$img=~s/w124/w200/g;

		my $star_str = &_star_img($rateno);

		$list .= qq{<tr>};
		$list .= qq{<td width="200" bgcolor="#000000">};
		$list .= qq{<font color="#FFFFFF">};
		$list .= qq{<span class="rounded-img" style="background: url($img) no-repeat center center; width: 200px; height: 200px;"><a href="/androidapp-$id/" target="_blank" rel="nofollow"><img src="$img" style="opacity: 0;" alt="$name" /></a></span>};
		$list .= qq{<br />};
		$list .=qq{<p><img src="/img/E20D_20.gif" width="15">$name</p>};
		$list .=qq{<a href="/category$category_id-android-app-1/">$category_name</a><br />};
		$list .= qq{<p>	$star_str ($revcnt)<br />$price<br />};
		$list .= qq{<form action="$url"><button class="btn primary" type="submit">アプリをインストール</button></form>};
		$list .= qq{</font>};
		$list .= qq{</p>};
		$list .= qq{</td>};
		$list .= qq{<td>};

		my $ex_str = substr($detail,0,400);
		$ex_str.=qq{...};

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

sub _category_list(){
	my $dbh = shift;

	my $list = &_load_tmpl("cate_list.html");

	return $list;
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
	
my $file = qq{/var/www/vhosts/goo.to/etc/makehtml/app/tmpl_android/$tmpl};
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


1;