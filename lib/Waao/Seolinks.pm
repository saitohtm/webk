package Seolinks;
use Exporter;
@ISA = (Exporter);
@EXPORT = qw(seolink toplink);
use URI::Escape;
use DBI;

sub toplink(){
	my $toplink;
	
	my $toplink_rand = int(rand(10));
	my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
	$toplink_rand = $hour;
	if($toplink_rand < 1){
		$toplink = qq{<a href="http://goo.to/" title="みんなのモバイル">みんなのモバイル</a><br>};
	}elsif($toplink_rand <= 1){
		$toplink = qq{<a href="http://photo.goo.to/" title="みんなの画像検索">画像検索</a><br>};
	}elsif($toplink_rand <= 2){
		$toplink = qq{<a href="http://2ch.goo.to/" title="2chうわさ検索">2chうわさ検索</a><br>};
	}elsif($toplink_rand <= 3){
		$toplink = qq{<a href="http://aaa.goo.to/" title="みんなのモバイル">みんなのモバイル</a><br>};
	}elsif($toplink_rand <= 4){
		$toplink = qq{<a href="http://lucky2011.gokigen.com/" title="初詣ナビ2011">初詣ナビ2011</a><br>};
	}elsif($toplink_rand <= 5){
		$toplink = qq{<a href="http://now.goo.to/" title="アイドルなう">アイドルなう</a><br>};
	}elsif($toplink_rand <= 6){
		$toplink = qq{<a href="http://chintai.goo.to/" title="賃貸プラス">お部屋探しは賃貸プラス</a><br>};
	}elsif($toplink_rand <= 7){
		$toplink = qq{<a href="http://job.goo.to/salary/" title="企業別年収ランキング">企業別年収ランキング</a><br>};
	}elsif($toplink_rand <= 8){
		$toplink = qq{<a href="http://town.goo.to/" title="タウンページプラス">タウンページプラス</a><br>};
	}elsif($toplink_rand <= 9){
		$toplink = qq{<a href="http://job.goo.to/" title="仕事探し">ジョブプラス</a><br>};
	}elsif($toplink_rand <= 10){
		$toplink = qq{<a href="http://links.goo.to/" title="タレントリンク集">タレントリンク集</a><br>};
	}elsif($toplink_rand <= 11){
		$toplink = qq{<a href="http://woman.waao.jp/" title="究極の女性サイト">究極の女性サイト</a><br>};
	}elsif($toplink_rand <= 12){
		$toplink = qq{<a href="http://wiki.waao.jp/" title="wikipedia検索">wikipedia検索</a><br>};
	}elsif($toplink_rand <= 13){
		$toplink = qq{<a href="http://ranking.waao.jp/" title="タレントランキング">タレントランキング</a><br>};
	}elsif($toplink_rand <= 14){
		$toplink = qq{<a href="http://nice.waao.jp/" title="いいね！検索">いいね！検索</a><br>};
	}elsif($toplink_rand <= 15){
		$toplink = qq{<a href="http://job.goo.to/hellowwork/" title="ハローワーク">ハローワーク</a><br>};
	}elsif($toplink_rand <= 16){
		$toplink = qq{<a href="http://homes.goo.to/" title="一人暮らし.com">一人暮らし.com</a><br>};
	}elsif($toplink_rand <= 17){
		$toplink = qq{<a href="http://now.goo.to/" title="タレントプラス">タレントプラス</a><br>};
	}elsif($toplink_rand <= 18){
		$toplink = qq{<a href="http://qa.goo.to/" title="みんなの知恵袋">みんなの知恵袋</a><br>};
	}elsif($toplink_rand <= 19){
		$toplink = qq{<a href="http://qa.goo.to/" title="みんなの知恵袋">みんなの知恵袋</a><br>};
	}elsif($toplink_rand <= 20){
		$toplink = qq{<a href="http://artist.goo.to/" title="アーティスト名鑑">アーティスト名鑑</a><br>};
	}elsif($toplink_rand <= 21){
		$toplink = qq{<a href="http://blog.waao.jp/" title="タレントブログ">タレントブログ</a><br>};
	}elsif($toplink_rand <= 22){
		$toplink = qq{<a href="http://postcode.goo.to/" title="郵便番号検索">郵便番号検索</a><br>};
	}elsif($toplink_rand <= 23){
		$toplink = qq{<a href="http://ana.goo.to/" title="女子アナ名鑑">女子アナ名鑑</a><br>};
	}else{
		$toplink = qq{<a href="http://waao.jp/" title="みんなのモバイルプラス">みんなのモバイルプラス</a><br>};
	}
	
	return $toplink;
}

sub seolink(){
	my $keyword = shift;
	my $waao_keyword_id = shift;
	my $gooto_keyword_id = shift;
	my $cnt = shift;
	my $type = shift;
	# type 
	# null  person
	# 1		keyword
	# 2		アダルト
	my $keyword_encode = uri_escape($keyword);

	unless($waao_keyword_id){
		my $dbh = &db_connect();
		my $sth = $dbh->prepare(qq{ select id from keyword where keyword = ? limit 1} );
		$sth->execute($keyword);
		while(my @row = $sth->fetchrow_array) {
			$waao_keyword_id = $row[0];
		}
		$dbh->disconnect;
	}	
	
	
	my $seolinks;
	
	# 人名
	if($waao_keyword_id){
		my $waao_rand = int(rand(12));
		if($waao_rand <= 2){
			$seolinks .= &waaojp($keyword,$waao_keyword_id);
			$seolinks .= &ana($keyword,$waao_keyword_id);
		}elsif($waao_rand <= 4){
			$seolinks .= &announcer($keyword,$waao_keyword_id);
			$seolinks .= &artist($keyword,$waao_keyword_id);
			$seolinks .= &av($keyword,$waao_keyword_id);
		}elsif($waao_rand <= 6){
			$seolinks .= &bookmark($keyword,$waao_keyword_id);
			$seolinks .= &idol($keyword,$waao_keyword_id);
		}elsif($waao_rand <= 8){
			$seolinks .= &blog($keyword,$waao_keyword_id);
			$seolinks .= &keyword($keyword,$waao_keyword_id);
		}elsif($waao_rand <= 10){
			$seolinks .= &s2ch($keyword,$waao_keyword_id);
			$seolinks .= &now($keyword,$waao_keyword_id);
		}else{
			$seolinks .= &ranking($keyword,$waao_keyword_id);
			$seolinks .= &real($keyword,$waao_keyword_id);
		}
	}
	if($gooto_keyword_id){
		my $gooto_rand = int(rand(20));
		if($gooto_rand <= 2){
			$seolinks .= &s33_gooto($keyword,$gooto_keyword_id);
			$seolinks .= &x_gooto($keyword,$gooto_keyword_id);
		}elsif($gooto_rand <= 4){
			$seolinks .= &e_gooto($keyword,$gooto_keyword_id);
			$seolinks .= &hate_gooto($keyword,$gooto_keyword_id);
		}elsif($gooto_rand <= 6){
			$seolinks .= &green_gooto($keyword,$gooto_keyword_id);
			$seolinks .= &s109_gooto($keyword,$gooto_keyword_id);
		}elsif($gooto_rand <= 8){
			$seolinks .= &go_gooto($keyword,$gooto_keyword_id);
			$seolinks .= &gre_gooto($keyword,$gooto_keyword_id);
		}elsif($gooto_rand <= 10){
			$seolinks .= &mixy_gooto($keyword,$gooto_keyword_id);
			$seolinks .= &waao_gooto($keyword,$gooto_keyword_id);
		}elsif($gooto_rand <= 12){
			$seolinks .= &wicki_gooto($keyword,$gooto_keyword_id);
			$seolinks .= &keyword_gooto($keyword,$gooto_keyword_id);
		}elsif($gooto_rand <= 14){
			$seolinks .= &ranking_gooto($keyword,$gooto_keyword_id);
			$seolinks .= &bookmark_gooto($keyword,$gooto_keyword_id);
		}elsif($gooto_rand <= 16){
			$seolinks .= &aaa_gooto($keyword,$gooto_keyword_id);
		}else{
			$seolinks .= &search_gooto($keyword,$gooto_keyword_id);
			$seolinks .= &bbs_gooto($keyword,$gooto_keyword_id);
		}
	}
	
	return $seolinks;
}

sub now(){
	my $keyword = shift;
	my $keyword_id = shift;
	my $str;
	
	my $dir = int($keyword_id / 1000);
	my $htmlfile = qq{/var/www/vhosts/waao.jp/httpdocs-now/$dir/$keyword_id/index.html};
	if (-f $htmlfile) {
		$str = qq{<a href="http://now.goo.to/$dir/$keyword_id/" title="$keyword">$keyword</a><br>};
	}

	return $str;
}
sub s2ch(){
	my $keyword = shift;
	my $keyword_id = shift;
	my $str;
	
	my $dir = int($keyword_id / 1000);
	my $htmlfile = qq{/var/www/vhosts/waao.jp/httpdocs-2ch/$dir/$keyword_id/index.html};
	if (-f $htmlfile) {
		$str = qq{<a href="http://2ch.goo.to/$dir/$keyword_id/" title="$keyword">$keyword</a><br>};
	}

	return $str;
}
sub ana(){
	my $keyword = shift;
	my $keyword_id = shift;
	my $str;
	
	my $dir = int($keyword_id / 1000);
	my $htmlfile = qq{/var/www/vhosts/waao.jp/httpdocs-ana/$dir/$keyword_id/index.html};
	if (-f $htmlfile) {
		$str = qq{<a href="http://ana.goo.to/$dir/$keyword_id/" title="$keyword">$keyword(女子アナ)</a><br>};
	}

	return $str;
}

sub announcer(){
	my $keyword = shift;
	my $keyword_id = shift;
	my $str;
	
	my $dir = int($keyword_id / 1000);
	my $htmlfile = qq{/var/www/vhosts/waao.jp/httpdocs-ana/$dir/$keyword_id/index.html};
	if (-f $htmlfile) {
		$str = qq{<a href="http://announcer.goodgirl.jp/$dir/$keyword_id/" title="$keyword">$keyword(女子アナ)</a><br>};
	}

	return $str;
}

sub artist(){
	my $keyword = shift;
	my $keyword_id = shift;
	my $str;
	
	my $dir = int($keyword_id / 1000);
	my @inital=("a","i","u","e","o","ka","ki","ku","ke","ko","sa","si","su","se","so","ta","ti","tu","te","to","na","ni","nu","ne","no","ha","hi","hu","he","ho","ma","mi","mu","me","mo","ya","yi","yu","ye","yo","ra","ri","ru","re","ro","wa");

	foreach my $ini (@inital){
		my $htmlfile = qq{/var/www/vhosts/waao.jp/httpdocs-artist//$ini/$keyword_id//index.html};
		if (-f $htmlfile) {
			$str = qq{<a href="http://artist.goo.to/$dir/$keyword_id/" title="$keyword">$keyword(アーティスト)</a><br>};
		}
	}
	

	return $str;
}

sub av(){
	my $keyword = shift;
	my $keyword_id = shift;
	my $str;
	
	my $dir = int($keyword_id / 1000);
	my @inital=("a","i","u","e","o","ka","ki","ku","ke","ko","sa","si","su","se","so","ta","ti","tu","te","to","na","ni","nu","ne","no","ha","hi","hu","he","ho","ma","mi","mu","me","mo","ya","yi","yu","ye","yo","ra","ri","ru","re","ro","wa");

	foreach my $ini (@inital){
		my $htmlfile = qq{/var/www/vhosts/waao.jp/httpdocs-av//$ini/$keyword_id//index.html};
		if (-f $htmlfile) {
			$str = qq{<a href="http://av.goo.to/$dir/$keyword_id/" title="$keyword(AV女優)">$keyword(AV女優)</a><br>};
		}
	}
	

	return $str;
}

sub bookmark(){
	my $keyword = shift;
	my $keyword_id = shift;
	my $str;
	
	my $dir = int($keyword_id / 1000);
	my $htmlfile = qq{/var/www/vhosts/waao.jp/httpdocs-bookmark/$dir/$keyword_id/index.html};
	if (-f $htmlfile) {
		$str = qq{<a href="http://b.goo.to/$dir/$keyword_id/" title="$keyword">$keywordのブクマ</a><br>};
	}

	return $str;
}

sub idol(){
	my $keyword = shift;
	my $keyword_id = shift;
	my $str;
	
	my $dir = int($keyword_id / 1000);
	my $htmlfile = qq{/var/www/vhosts/waao.jp/httpdocs-idol/$dir/$keyword_id/index.html};
	if (-f $htmlfile) {
		$str = qq{<a href="http://idol.goo.to/$dir/$keyword_id/" title="$keyword">$keyword（アイドル）</a><br>};
	}

	return $str;
}

sub blog(){
	my $keyword = shift;
	my $keyword_id = shift;
	my $str;
	
	my $dir = int($keyword_id / 1000);
	my $htmlfile = qq{/var/www/vhosts/waao.jp/httpdocs-blog/$dir/$keyword_id/index.html};
	if (-f $htmlfile) {
		$str = qq{<a href="http://blog.waao.jp/$dir/$keyword_id/" title="$keywordのブログ">$keywordのブログ</a><br>};
	}

	return $str;
}

sub keyword(){
	my $keyword = shift;
	my $keyword_id = shift;
	my $str;
	
	my $dir = int($keyword_id / 1000);
	my $htmlfile = qq{/var/www/vhosts/waao.jp/httpdocs-keyword/$dir/$keyword_id/index.html};
	if (-f $htmlfile) {
		$str = qq{<a href="http://keyword.waao.jp/$dir/$keyword_id/" title="$keyword">$keyword</a><br>};
	}

	return $str;
}
sub ranking(){
	my $keyword = shift;
	my $keyword_id = shift;
	my $str;
	
	my $dir = int($keyword_id / 1000);
	my $htmlfile = qq{/var/www/vhosts/waao.jp/httpdocs-ranking/$dir/$keyword_id/index.html};
	if (-f $htmlfile) {
		$str = qq{<a href="http://ranking.waao.jp/$dir/$keyword_id/" title="$keyword">$keywordランキング</a><br>};
	}

	return $str;
}

sub real(){
	my $keyword = shift;
	my $keyword_id = shift;
	my $str;
	
	my $dir = int($keyword_id / 1000);
	my $htmlfile = qq{/var/www/vhosts/waao.jp/httpdocs-real/$dir/$keyword_id/index.html};
	if (-f $htmlfile) {
		$str = qq{<a href="http://real.waao.jp/$dir/$keyword_id/" title="$keyword">$keywordランキング</a><br>};
	}

	return $str;
}

sub db_connect(){

	my $dsn = 'DBI:mysql:waao';
	my $user = 'mysqlweb';
	my $password = 'WaAoqzxe7h6yyHz';
	my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 1, AutoCommit => 0});

	return $dbh;
}

sub s33_gooto(){
	my $keyword = shift;
	my $keyword_id = shift;
	my $str;
	
	my $dir = int($keyword_id / 1000);
	$str = qq{<a href="http://33.goo.to/$dir/$keyword_id/" title="$keyword">$keyword</a><br>};
	
	return $str;
}

sub x_gooto(){
	my $keyword = shift;
	my $keyword_id = shift;
	my $keyword_encode = uri_escape($keyword);
	my $str;
	my $dir = int($keyword_id / 1000);
	
	my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
	my $domain = qq{x.goo.to};
	if($mday <= 2){
		$domain = qq{x.gokigen.com};
	}elsif($mday <= 4){
		$domain = qq{x.tsukaeru.info};
	}elsif($mday <= 6){
		$domain = qq{x.bonyari.jp};
	}elsif($mday <= 8){
		$domain = qq{x.goodgirl.jp};
	}elsif($mday <= 10){
		$domain = qq{x.obei.jp};
	}elsif($mday <= 12){
		$domain = qq{x.soteigai.jp};
	}elsif($mday <= 14){
		$domain = qq{x.rakusite.com};
	}else{
		$domain = qq{x.goo.to};
	}

	$str = qq{<a href="http://$domain/person/$keyword_encode/$keyword_id/" title="$keyword">$keyword</a><br>};
	
	return $str;
}

sub e_gooto(){
	my $keyword = shift;
	my $keyword_id = shift;
	my $keyword_encode = uri_escape($keyword);
	my $str;
	
	my $dir = int($keyword_id / 1000);

	my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
	my $domain = qq{e.goo.to};
	if($mday <= 2){
		$domain = qq{e.gokigen.com};
	}elsif($mday <= 4){
		$domain = qq{e.tsukaeru.info};
	}elsif($mday <= 6){
		$domain = qq{e.bonyari.jp};
	}elsif($mday <= 8){
		$domain = qq{e.goodgirl.jp};
	}elsif($mday <= 10){
		$domain = qq{e.obei.jp};
	}elsif($mday <= 12){
		$domain = qq{e.soteigai.jp};
	}elsif($mday <= 14){
		$domain = qq{e.rakusite.com};
	}else{
		$domain = qq{e.goo.to};
	}
#	$str = qq{<a href="http://$domain/person/$keyword_encode/personid/$keyword_id/" title="$keyword">$keyword</a><br>};
	$str = qq{<a href="http://$domain/person/$keyword_encode/" title="$keyword">$keyword</a><br>};
	
	return $str;
}

sub hate_gooto(){
	my $keyword = shift;
	my $keyword_id = shift;
	my $keyword_encode = uri_escape($keyword);
	my $str;
	
	my $dir = int($keyword_id / 1000);

	my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
	my $domain = qq{hate.goo.to};
	if($mday <= 2){
		$domain = qq{hate.gokigen.com};
	}elsif($mday <= 4){
		$domain = qq{hate.tsukaeru.info};
	}elsif($mday <= 6){
		$domain = qq{hate.bonyari.jp};
	}elsif($mday <= 8){
		$domain = qq{hate.goodgirl.jp};
	}elsif($mday <= 10){
		$domain = qq{hate.obei.jp};
	}elsif($mday <= 12){
		$domain = qq{hate.soteigai.jp};
	}elsif($mday <= 14){
		$domain = qq{hate.rakusite.com};
	}else{
		$domain = qq{hate.goo.to};
	}

	$str = qq{<a href="http://$domain/$keyword_encode/personid/$keyword_id/" title="$keyword">$keyword</a><br>};
	
	return $str;
}

sub green_gooto(){
	my $keyword = shift;
	my $keyword_id = shift;
	my $keyword_encode = uri_escape($keyword);
	my $str;
	
	my $dir = int($keyword_id / 1000);

	my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
	my $domain = qq{green.goo.to};
	if($mday <= 2){
		$domain = qq{green.gokigen.com};
	}elsif($mday <= 4){
		$domain = qq{green.tsukaeru.info};
	}elsif($mday <= 6){
		$domain = qq{green.bonyari.jp};
	}elsif($mday <= 8){
		$domain = qq{green.goodgirl.jp};
	}elsif($mday <= 10){
		$domain = qq{green.obei.jp};
	}elsif($mday <= 12){
		$domain = qq{green.soteigai.jp};
	}elsif($mday <= 14){
		$domain = qq{green.rakusite.com};
	}else{
		$domain = qq{green.goo.to};
	}

	$str = qq{<a href="http://$domain/wiki/$keyword_encode/" title="$keyword">$keyword</a><br>};
	
	return $str;
}

sub s109_gooto(){
	my $keyword = shift;
	my $keyword_id = shift;
	my $keyword_encode = uri_escape($keyword);
	my $str;
	
	$str = qq{<a href="http://109.goo.to/$keyword_encode/personid/$keyword_id/" title="$keyword">$keyword</a><br>};
	
	return $str;
}

sub go_gooto(){
	my $keyword = shift;
	my $keyword_id = shift;
	my $keyword_encode = uri_escape($keyword);
	my $str;
	
	$str = qq{<a href="http://go.goo.to/$keyword_encode/personid/$keyword_id/" title="$keyword">$keyword</a><br>};
	
	return $str;
}

sub gre_gooto(){
	my $keyword = shift;
	my $keyword_id = shift;
	my $keyword_encode = uri_escape($keyword);
	my $str;
	
	$str = qq{<a href="http://gre.goo.to/$keyword_encode/personid/$keyword_id/" title="$keyword">$keyword</a><br>};
	
	return $str;
}

sub mixy_gooto(){
	my $keyword = shift;
	my $keyword_id = shift;
	my $keyword_encode = uri_escape($keyword);
	my $str;
	
	$str = qq{<a href="http://mixy.goo.to/$keyword_encode/personid/$keyword_id/" title="$keyword">$keyword</a><br>};
	
	return $str;
}

sub waao_gooto(){
	my $keyword = shift;
	my $keyword_id = shift;
	my $keyword_encode = uri_escape($keyword);
	my $str;
	
	$str = qq{<a href="http://waao.goo.to/$keyword_encode/personid/$keyword_id/" title="$keyword">$keyword</a><br>};
	
	return $str;
}

sub wicki_gooto(){
	my $keyword = shift;
	my $keyword_id = shift;
	my $keyword_encode = uri_escape($keyword);
	my $str;
	
	$str = qq{<a href="http://wicki.goo.to/$keyword_encode/personid/$keyword_id/" title="$keyword">$keyword</a><br>};
	
	return $str;
}

sub waaojp(){
	my $keyword = shift;
	my $keyword_id = shift;
	my $keyword_encode = uri_escape($keyword);
	my $str;
	
	$str = qq{<a href="http://waao.jp/$keyword_encode/search/$keyword_id/" title="$keyword">$keyword</a><br>};
	
	return $str;
}

sub keyword_gooto(){
	my $keyword = shift;
	my $keyword_id = shift;
	my $keyword_encode = uri_escape($keyword);
	my $str;
	
	$str = qq{<a href="http://keyword.goo.to/$keyword_encode/" title="$keyword">$keyword</a><br>};
	
	return $str;
}

sub ranking_gooto(){
	my $keyword = shift;
	my $keyword_id = shift;
	my $keyword_encode = uri_escape($keyword);
	my $str;
	
	$str = qq{<a href="http://ranking.goo.to/?guid=ON&q=$keyword_encode" title="$keyword">$keyword</a><br>};
	
	return $str;
}

sub bookmark_gooto(){
	my $keyword = shift;
	my $keyword_id = shift;
	my $keyword_encode = uri_escape($keyword);
	my $str;
	
	$str = qq{<a href="http://bookmark.goo.to/person/$keyword_encode/" title="$keyword">$keyword</a><br>};
	
	return $str;
}

sub search_gooto(){
	my $keyword = shift;
	my $keyword_id = shift;
	my $keyword_encode = uri_escape($keyword);
	my $str;
	
	$str = qq{<a href="http://search.goo.to/$keyword_encode/get/" title="$keyword">$keyword</a><br>};
	
	return $str;
}

sub bbs_gooto(){
	my $keyword = shift;
	my $keyword_id = shift;
	my $keyword_encode = uri_escape($keyword);
	my $str;
	
	$str = qq{<a href="http://bbs.goo.to/?guid=ON&type=1&q=$keyword_encode&keyword_id=$keyword_id" title="$keyword">$keyword</a><br>};
	
	return $str;
}

sub aaa_gooto(){
	my $keyword = shift;
	my $keyword_id = shift;
	my $keyword_encode = uri_escape($keyword);
	my $str;
	
	$str = qq{<a href="http://aaa.goo.to/kizasi/$keyword_encode/$keyword_id/" title="$keyword">$keyword</a><br>};

	return $str;
}
#http://aaa.goo.to/人名/search/				peekaboo@csc.jp		△		×		×
#http://geinou.gokigen.com/人名/				peekaboo@csc.jp		×		×		×
#http://av.goo.to/イニシャル/人名ID/			peekaboo@csc.jp		×		○		○
#http://blog.goo.to/blog/4680/%88%c0%93c%97%9d%91%e5/	peekaboo@csc.jp		○	△	○
#http://g1.goo.to/%90%85%91%F2%8E%B5%94%FC/428/		peekaboo@csc.jp　	×	×	×
#※out のみ可
#http://labs.goo.to/2009/%82%a0%82%a2%82%cc%/		peekaboo@csc.jp		×	×	×
#http://love.goo.to/%91%e5%89Y%82%a0%82%f1%82%c8/	peekaboo@csc.jp		×	×	×
#http://movie.goo.to/dvd/person.html?q=%92&search1=1	peekaboo@csc.jp		×	×	○
#http://music.goo.to/ranking/person.html?&q=%8&q2=%8dD%82%a&musicid=10302&rankdate=2010-09-18peekaboo@csc.jp		×	×	○
#http://my.goo.to/person/Marin./2010-09-23/		peekaboo@csc.jp		×	×	×
#http://uta.goo.to/?menu=asearch&key=%97%92		peekaboo@csc.jp		○	△	○
#http://video.goo.to/%8e%85%96%ee%82%df%82%a2/		peekaboo@csc.jp		○	×	×
#http://wiki.goo.to/0/%8eO%89Y%8ft%94n/			peekaboo@csc.jp		○	×	×
#http://av.goodgirl.jp/blog.html?&id=1895&q=%94%92%92%b9%82%a0%82%ab%82%e7	peekaboo@csc.jp		×	×	×			
#sexy.goodgirl.jp
#so.goodgirl.jp
#very.goodgirl.jp
#good.obei.jp
#s.obei.jp
#goodjob.rakusite.com
#dvd.soteigai.jp
#wiki.waao.jp
#x.waao.jp
#http://tv.goo.to/

	
1;