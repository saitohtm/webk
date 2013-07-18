package CarPhoto;

use Exporter;
@ISA = (Exporter);
@EXPORT = qw(car_photo);

use LWP::UserAgent;
use HTML::TreeBuilder;

sub car_photo(){
	my $dbh = shift;
	my $dl_url = shift;
	my $site_id = shift;
	my $tablename = shift;

	# facebookの場合
	print $dl_url."\n\n";
	if($dl_url=~/facebook/){
		&_facebook($dbh,$dl_url,$site_id,$tablename);
	}

	my $today = Date::Simple->new;
	$today = $today->format("%Y/%m/%d");

	my $totalcnt;
	my $todaycnt;

	print $dl_url." logging \n\n";

	my $sth = $dbh->prepare(qq{select count(*) as totalcnt from $tablename}.qq{_photo  });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$totalcnt = $row[0];
	}

	my $sth = $dbh->prepare(qq{select count(*) as todaycnt from $tablename}.qq{_photo where regist_date = ? });
	$sth->execute($today);
	while(my @row = $sth->fetchrow_array) {
		$todaycnt = $row[0];
	}

	# ログ記録
eval{
	my $sth = $dbh->prepare(qq{insert into $tablename}.qq{_photo_log (date,cnt,totalcnt) values(?,?,?)});
	$sth->execute($today,$todaycnt,$totalcnt);
};
if($@){
	my $sth = $dbh->prepare(qq{update $tablename}.qq{_photo_log set cnt = ?, totalcnt=? where date = ?});
	$sth->execute($todaycnt,$totalcnt,$today);
}
	return;
}

sub _facebook(){
	my $dbh = shift;
	my $dl_url = shift;
	my $site_id = shift;
	my $tablename = shift;

print "_facebook $dl_url \n";

	my $today = Date::Simple->new;
	$today = $today->format("%Y/%m/%d");

	my $user_agent = "Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.1; Trident/6.0)";

	# LWPを使ってサイトにアクセスし、HTMLの内容を取得する
	my $ua = LWP::UserAgent->new('agent' => $user_agent);
	my $res = $ua->get($dl_url);
	my $content = $res->content;

	my $content = `GET "$dl_url"`;
	$content=~s/>/>\n/g;

	my @lines = split(/\n/,$content);
	foreach my $line (@lines){
		if($line =~/(.*)facebook\.com\/photo\.php(.*)&amp;src=(.*)/){
			my $next_url = qq{http://www.facebook.com/photo.php}.$2;

			my $img_url = &_facebook_main_photo($next_url);
			if($img_url){
eval{
	my $sth = $dbh->prepare(qq{insert into $tablename}.qq{_photo (photo,site_id,regist_date,url) values(?,?,?,?)});
	$sth->execute($img_url,$site_id,$today,$dl_url);
};
if($@){
	last;
}else{
print "INS ###########\n";
}
			}
		}
	}
	
	return;
}

sub _facebook_main_photo(){
	my $dl_url = shift;
	
print "_facebook_main_photo $dl_url \n";
	my $user_agent = "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0)";

	# LWPを使ってサイトにアクセスし、HTMLの内容を取得する
	my $ua = LWP::UserAgent->new('agent' => $user_agent);
	my $res = $ua->get($dl_url);
	my $content = $res->content;

	my $content = `GET "$dl_url"`;
	$content=~s/>/>\n/g;
	my @lines = split(/\n/,$content);
	my $img_url;
	foreach my $line (@lines){
		if($line =~/(.*)id=\"fbPhotoImage\" src=\"(.*)\" alt=(.*)/){
			$img_url = $2;
print "IMG :: $2 \n";
		}
	}
	
	return $img_url;
}
1;