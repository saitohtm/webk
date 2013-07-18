package Waao::ECDIET;

use DBI;
use CGI;
#use HTTP::MobileAgent;
use Cache::Memcached;
use Waao::Api;
use XML::Simple;
use LWP::Simple;
use Jcode;
use CGI qw( escape );


sub dispatch(){
	my $self = shift;
	my $itemcode = $self->{cgi}->param('item');

	my ($itemCode,$itemName,$catchcopy,$itemPrice,$itemCaption,$itemUrl,$affiliateUrl,$smallImageUrl,$mediumImageUrl,$taxFlag,$postageFlag,$creditdietdFlag,$shopOfTheYearFlag,$asurakuFlag,$reviewCount,$reviewAverage,$shopName,$shopCode,$shopUrl,$genreId,$titlestr);
	my $sth = $self->{dbi}->prepare(qq{select `itemCode`,`itemName`,`catchcopy`,`itemPrice`,`itemCaption`,`itemUrl`,`affiliateUrl`,`smallImageUrl`,`mediumImageUrl`,`taxFlag`,`postageFlag`,`creditCardFlag`,`shopOfTheYearFlag`,`asurakuFlag`,`reviewCount`,`reviewAverage`,`shopName`,`shopCode`,`shopUrl`,`genreId`,titlestr from yahoo_item_diet where itemCode = ? });
	$sth->execute($itemcode);
	while(my @row = $sth->fetchrow_array) {
      	($itemCode,$itemName,$catchcopy,$itemPrice,$itemCaption,$itemUrl,$affiliateUrl,$smallImageUrl,$mediumImageUrl,$taxFlag,$postageFlag,$creditCardFlag,$shopOfTheYearFlag,$asurakuFlag,$reviewCount,$reviewAverage,$shopName,$shopCode,$shopUrl,$genreId,$titlestr) = @row;
	}

	unless( $self->{cgi}->param('detail') ){
		if( $ENV{'HTTP_USER_AGENT'} =~/Googlebot/i ){
			my $html = &_load_tmpl("nobot.htm");
			$html =~s/<!--AFURL-->/$affiliateUrl/g;
print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML
		}else{
			print qq{Location: $affiliateUrl\n\n};
		}
		return;
	}

	my $html = &_load_tmpl("detail.htm");

	my ($pankuzu,$categorystr,$titlestr,$keywords,$categorylist);
	my $sth2 = $self->{dbi}->prepare(qq{select id, name, leve from yahoo_genre where id = ? });
	$sth2->execute($genreId);
	while(my @row = $sth2->fetchrow_array) {
		($pankuzu,$categorystr,$titlestr,$keywords,$categorylist) = &_category_file($self,$row[0],$row[1],$row[2]);
	}

#	$name = $catchcopy if($catchcopy);
	my $title = qq{$titlestr yahooID:$itemcode $itemName};
	$title = substr($title,0,128);
	$title .=qq{ };
	my $keys = qq{ダイエット用品通販,送料無料,yahoo,ダイエット用品,ショッピング,ダイエット,価格,$keywords};
	my $desc = qq{$itemName };

	$html =~s/<!--TITLE-->/$title/g;
	$html =~s/<!--KEYS-->/$keys/;
	$html =~s/<!--DESC-->/$desc/;
	$html =~s/<!--H1STR-->/$titlestr/g;
	$html =~s/<!--ITEMNAME-->/$itemName/g;
	$html =~s/<!--CATCH-->/$catchcopy/g;
	$html =~s/<!--PANKUZU-->/$pankuzu/g;

	$html =~s/<!--CATELIST-->/$categorylist/g;

	$itemPrice = &price_dsp($itemPrice);
	$html =~s/<!--itemPrice-->/$itemPrice/g;
	$html =~s/<!--itemCode-->/$itemCode/g;
	$html =~s/<!--IMAGE-->/$mediumImageUrl/g;
	$html =~s/<!--shopName-->/$shopName/g;

	my $star_img = &_star_img($reviewAverage);
	$html =~s/<!--star_img-->/$star_img/g;
	
	if($postageFlag){
		$postageFlag = qq{<font color="#FF0000"><strong>送料無料</strong></font>};
	}else{
		$postageFlag = qq{送料無料 無};
	}
	$html =~s/<!--postageFlag-->/$postageFlag/g;


	$itemCaption =~s/。/。<br \/>/g;
	$itemCaption =~s/●/<br \/>●/g;
	$itemCaption =~s/♪/♪<br \/>/g;
	$itemCaption =~s/！/！<br \/>/g;
	$itemCaption =~s/【/<br \/>【/g;
#	$itemCaption =~s/サイズ/サイズ<br \/>/g;
#	$itemCaption =~s/カラー/カラー<br \/>/g;
	$itemCaption =~s/<br \/><br \/>/<br \/>/g;

	$html =~s/<!--ITEMDETAIL-->/$itemCaption/g;

	my $qanda;
	my $sth2 = $self->{dbi}->prepare(qq{select content,bestanswer from rakuten_qanda where category_id = ? order by rand() limit 5});
	$sth2->execute($genreId);
	while(my @row2 = $sth2->fetchrow_array) {
		$qanda .= qq{<img src="/img/E020_20.gif" height=15>$titlestrの質問<br />$row2[0]<br /><br />};
		$qanda .= qq{<img src="/img/E00F_20.gif" height=15>$titlestrのベストアンサー<br />$row2[1]<br /><br />};
	}
	
	$html =~s/<!--QandA-->/$qanda/g;

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML


#	&_detail_rakuten($self,"100371");

	return;
}

sub _category_file(){
	my $self = shift;
	my $cateid = shift;
	my $catename = shift;
	my $level = shift;

	my $pankuzu;
	my $categorystr;
	my $titlestr;
	my $keywords;
	my $tmp_cateid = $cateid;
	
	my $max_name;
	my $max_cateid;
	
	for(my $i=1; $i<$level; $i++){
		my $sth = $self->{dbi}->prepare(qq{select pid, name, leve from yahoo_genre where id = ? });
		$sth->execute($tmp_cateid);
		while(my @row = $sth->fetchrow_array) {
			$keywords .= qq{$row[1],};
			if($i eq 1){
				$titlestr = qq{$row[1] $titlestr};
			}elsif($i eq ($level - 1)){
				$titlestr = qq{$row[1] $titlestr};
$max_name = $row[1];
$max_cateid = $row[0];
			}elsif($i eq ($level - 2)){
				$titlestr = qq{$row[1] $titlestr};
			}
			if($i eq 1){
				$categorystr .= qq{|$row[1]};
				$pankuzu = qq{&gt;<strong>$row[1]</strong>};
				$tmp_cateid = $row[0];
			}else{
				$categorystr .= qq{|$row[1]};
				$pankuzu = qq{&gt;<a href="/cateid$tmp_cateid">$row[1]</a>$pankuzu};
				$tmp_cateid = $row[0];
			}
		}
	}
	
	my $categorylist;
	my $sth = $self->{dbi}->prepare(qq{select id, name, leve from yahoo_genre where pid = ? });
	$sth->execute($max_cateid);
	while(my @row = $sth->fetchrow_array) {
		my $namestr = substr($row[1],0,22);
		$categorylist.=qq{<li><a href="/cateid$row[0]">$namestr</a></li>};
	}
	$categorylist = qq{<ul>$categorylist</ul>};
	return ($pankuzu,$categorystr,$titlestr,$keywords,$categorylist);
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
	
my $file = qq{/var/www/vhosts/waao.jp/etc/makeshophtm/tmpl_yahoo_diet/$tmpl};
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


sub dispatch_smf(){
	my $self = shift;
	my $itemcode = $self->{cgi}->param('item');

	my ($itemCode,$itemName,$catchcopy,$itemPrice,$itemCaption,$itemUrl,$affiliateUrl,$smallImageUrl,$mediumImageUrl,$taxFlag,$postageFlag,$creditCardFlag,$shopOfTheYearFlag,$asurakuFlag,$reviewCount,$reviewAverage,$shopName,$shopCode,$shopUrl,$genreId,$titlestr);
	my $sth = $self->{dbi}->prepare(qq{select `itemCode`,`itemName`,`catchcopy`,`itemPrice`,`itemCaption`,`itemUrl`,`affiliateUrl`,`smallImageUrl`,`mediumImageUrl`,`taxFlag`,`postageFlag`,`creditCardFlag`,`shopOfTheYearFlag`,`asurakuFlag`,`reviewCount`,`reviewAverage`,`shopName`,`shopCode`,`shopUrl`,`genreId`,titlestr from yahoo_item_diet where itemCode = ? });
	$sth->execute($itemcode);
	while(my @row = $sth->fetchrow_array) {
      	($itemCode,$itemName,$catchcopy,$itemPrice,$itemCaption,$itemUrl,$affiliateUrl,$smallImageUrl,$mediumImageUrl,$taxFlag,$postageFlag,$creditCardFlag,$shopOfTheYearFlag,$asurakuFlag,$reviewCount,$reviewAverage,$shopName,$shopCode,$shopUrl,$genreId,$titlestr) = @row;
	}


	if( $self->{cgi}->param('detail') ){
		if( $ENV{'HTTP_USER_AGENT'} =~/Googlebot/i ){
			my $html = &_load_tmpl("nobot.htm");
			$html =~s/<!--AFURL-->/$affiliateUrl/g;
print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML
		}else{
			print qq{Location: $affiliateUrl\n\n};
		}
		return;
	}


	my $html = &_load_tmpl("detail_smf.htm");
	my ($pankuzu,$categorystr,$titlestr,$keywords,$categorylist);
	my $sth2 = $self->{dbi}->prepare(qq{select id, name, leve, pid from yahoo_genre where id = ? });
	$sth2->execute($genreId);
	my $pid;
	while(my @row = $sth2->fetchrow_array) {
		$pid = $row[3];
		($pankuzu,$categorystr,$titlestr,$keywords,$categorylist) = &_category_file($self,$row[0],$row[1],$row[2]);
	}

	my $sth2 = $self->{dbi}->prepare(qq{select id, name from yahoo_genre where pid = ? });
	$sth2->execute($pid);
	while(my @row = $sth2->fetchrow_array) {
		$categorylist.=qq{<li><img src="/img/E231_20.gif" height="20" class="ui-li-icon"><a href="/cateid-1-$row[0]">$row[1]</a></li>};
	}
	
#	$name = $catchcopy if($catchcopy);
	my $title = qq{$titlestr yahooID:$itemcode ダイエット用品通販};
	my $keys = qq{ダイエット用品通販,送料無料,yahoo,ダイエット用品,価格,$keywords};
	my $desc = qq{$itemName };

	$pankuzu =~s/cateid/cateid-1-/g;
	$html =~s/<!--TITLE-->/$title/g;
	$html =~s/<!--KEYS-->/$keys/;
	$html =~s/<!--DESC-->/$desc/;
	$html =~s/<!--H1STR-->/$titlestr/g;
	$html =~s/<!--ITEMNAME-->/$itemName/g;
	$html =~s/<!--CATCH-->/$catchcopy/g;
	$html =~s/<!--PANKUZU-->/$pankuzu/g;

	$html =~s/<!--CATELIST-->/$categorylist/g;

	$itemPrice = &price_dsp($itemPrice);

	$html =~s/<!--itemPrice-->/$itemPrice/g;
	$html =~s/<!--itemCode-->/$itemCode/g;
	$html =~s/<!--IMAGE-->/$mediumImageUrl/g;
	$html =~s/<!--shopName-->/$shopName/g;
	
	if($postageFlag){
		$postageFlag = qq{<font color="#FF0000"><strong>送料無料</strong></font>};
	}else{
		$postageFlag = qq{送料無料 無};
	}
	$html =~s/<!--postageFlag-->/$postageFlag/g;


	$itemCaption =~s/。/。<br \/>/g;
	$itemCaption =~s/●/<br \/>●/g;
	$itemCaption =~s/♪/♪<br \/>/g;
	$itemCaption =~s/！/！<br \/>/g;
	$itemCaption =~s/【/<br \/>【/g;
#	$itemCaption =~s/サイズ/サイズ<br \/>/g;
#	$itemCaption =~s/カラー/カラー<br \/>/g;
	$itemCaption =~s/<br \/><br \/>/<br \/>/g;

	$html =~s/<!--ITEMDETAIL-->/$itemCaption/g;

	my $qanda;
	my $sth2 = $self->{dbi}->prepare(qq{select content,bestanswer from rakuten_qanda where category_id = ? order by rand() limit 5});
	$sth2->execute($genreId);
	while(my @row2 = $sth2->fetchrow_array) {
		$qanda .= qq{<img src="/img/E020_20.gif" height=15>$titlestrの質問<br />$row2[0]<br /><br />};
		$qanda .= qq{<img src="/img/E00F_20.gif" height=15>$titlestrのベストアンサー<br />$row2[1]<br /><br />};
	}
	
	$html =~s/<!--QandA-->/$qanda/g;

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}
sub _star_img(){
	my $point = shift;
	
	my $str;
	$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif">} if($point eq "5.0");
	$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star_half.gif">} if($point eq "4.5");
	$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star_off.gif">} if($point eq "4.0");
	$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star_half.gif"><img src="/img/review_all_star_off.gif">} if($point eq "3.5");
	$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif">} if($point eq "3.0");
	$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star_half.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif">} if($point eq "2.5");
	$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif">} if($point eq "2.0");
	$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star_half.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif">} if($point eq "1.5");
	$str = qq{<img src="/img/review_all_star.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif">} if($point eq "1.0");
	$str = qq{<img src="/img/review_all_star_half.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif">} if($point eq "0.5");
	$str = qq{<img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif"><img src="/img/review_all_star_off.gif">} if($point eq "0");

	return $str;
}
sub price_dsp(){
	my $price = shift;

	1 while $price =~ s/(.*\d)(\d\d\d)/$1,$2/;	

	return $price;
}

1;