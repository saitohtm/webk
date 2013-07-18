#!/usr/bin/perl

use strict;
use URI::Escape;
use DBI;
use Cache::Memcached;

use Jcode;

# top page
&_top();

# person page
&_person();

# pages
&_pages();

exit;

sub str_encode(){
	my $str = shift;
	return uri_escape($str);
}


sub _top(){

	my $geinou = &html_mojibake_str("geinou");
	my $datestr = &_get_date();
	my $html;
		
	$html .= &_html_header("$geinou人ﾌﾞﾛｸﾞ名鑑 -無料ﾌﾞﾛｸﾞ検索-","ﾌﾞﾛｸﾞ,$geinou人,無料,検索","$geinou人ﾌﾞﾛｸﾞ名鑑は、携帯で$geinou人ﾌﾞﾛｸﾞを無料検索して閲覧できるサービスです","http://waao.jp/blog/");

	$html .= qq{<center><h1><img src="http://img.waao.jp/blog.gif" alt="$geinou人ﾌﾞﾛｸﾞ名鑑"></h1><br><h2><font size=1 color="#FF0000">$geinou人ﾌﾞﾛｸﾞ名鑑</font></h2></center>\n};
	$html .= qq{<center><form action="http://waao.jp/search.html" method="POST" ><input type="text" name="q" value="" size="12"><input type="hidden" name="guid" value="ON"><input type="submit" value="検索"></form></center>\n};
	$html .= qq{<table border=0 bgcolor="#000000" width="100%"><tr><td><font size=1  color="#FFFF2B">人気$geinou人ﾌﾞﾛｸﾞ($datestr)</font><br></td></tr></table>\n};

	# 今日の芸能人
	my $dbh = &_db_connect();
	my $sth = $dbh->prepare(qq{ select id, inital, keyword from keyword where blogurl is not null order by cnt desc limit 20} );
	$sth->execute();
	my $cnt;
	my ($keyword_id, $inital, $keyword);
	while(my @row = $sth->fetchrow_array) {
		($keyword_id, $inital, $keyword) = @row;
		$cnt++;
		# 最初の2つは、画像を表示する
		if($cnt <= 2 ){
			# 画像の取得
			my $sth2 = $dbh->prepare(qq{ select id, url from photo where keywordid = ? order by good desc limit 1} );
			$sth2->execute($keyword_id);
			my $photourl;
			while(my @row2 = $sth2->fetchrow_array) {
				$photourl = $row2[1];
			}
			if($photourl){
				my $link_path = &_make_file_path($keyword_id);
				$html .= qq{<center><a href="$link_path" title="$keywordのﾌﾞﾛｸﾞ"><img src="$photourl" width=95 alt="$keyword">};
				$html .= qq{<br>$keyword</a></center><br>};
			}else{
				my $link_path = &_make_file_path($keyword_id);
				$html .= qq{<a href="$link_path" title="$keywordのﾌﾞﾛｸﾞ">$keyword</a><br>};
			}
		}else{
			my $link_path = &_make_file_path($keyword_id);
			$html .= qq{<font color="#FF0000">》</font><a href="$link_path" title="$keywordのﾌﾞﾛｸﾞ">$keyword</a><br>};
		}
	}
	$html .= qq{<img src="http://img.waao.jp/m2028.gif" width=48 height=9><a href="/page/0.html" title="ﾀﾚﾝﾄﾌﾞﾛｸﾞ名鑑">もっと見る</a><br>\n};
	$html .= qq{<hr color="#009525">\n};
	$html .= &_html_meikanlist();
	$html .= qq{<hr color="#009525">\n};
	$html .= qq{<a href="http://waao.jp/">みんなのモバイルプラス</a><br>\n};
	$html .= qq{<a href="http://waao.jp/kiyaku/">免責事項・利用規約</a><br>\n};
	$html .= qq{<a href="http://waao.jp/privacy/">プライバシーポリシー</a><br>\n};
	$html .= qq{<a href="http://waao.jp/sp-policy/">サイト健全化</a><br>\n};
	$html .= qq{<a href="http://waao.jp/sp-infomation/">運営元</a><br>\n};
	$html .= qq{<hr color="#009525">\n};
	
	$html .= &_html_footer();
	
	$dbh->disconnect;
	
	my $filename = qq{/var/www/vhosts/goo.to/httpdocs-blog/index.html};
	open(OUT,"> $filename") || die('error');
	print OUT "$html";
	close(OUT);
	print $filename."\n";

	# robots.txt
#	my $robots_str = qq{Sitemap: http://blog.waao.jp/\n};
	my $robots_str;
	
	my $robots = qq{/var/www/vhosts/goo.to/httpdocs-blog/robots.txt};
	open(OUT,"> $robots") || die('error');
	print OUT "$robots_str";
	close(OUT);
	
	return;
}


sub _person(){

	my $geinou = &html_mojibake_str("geinou");
	my $datestr = &_get_date();

	my $dbh = &_db_connect();
	# 人物のみ作成
for(my $i=0;$i<150;$i++){
	my $start = $i * 100;
	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-blog/$i/};
	mkdir($dirname, 0755);
	print "start $start \n";
	my $sitemaptxt;
	$sitemaptxt .= qq{<?xml version="1.0" encoding="UTF-8"?>\n};
	$sitemaptxt .= qq{<urlset xmlns="http://www.google.com/schemas/sitemap/0.84"\n};
	$sitemaptxt .= qq{  xmlns:mobile="http://www.google.com/schemas/sitemap-mobile/1.0">\n};

	# ランダムパーソン
	my $recommend;
	my $sth = $dbh->prepare(qq{ select id, keyword from keyword where blogurl is not null order by rand() limit 10} );
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my $link_path = &_make_file_path($row[0]);
		$recommend .= qq{<a href="$link_path">$row[1]</a> };
	}

	my $sth = $dbh->prepare(qq{ select id, keyword, wiki_id, simplewiki, blogurl from keyword where blogurl is not null order by id limit $start, 100} );
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
# page make start
		my $html;		
		my ($id, $keyword, $wiki_id, $simplewiki, $blogurl ) = @row;
		my $keyword_encode = &str_encode($keyword);
		my $link_path = &_make_file_path($id);
		#画像取得
		my $sth2 = $dbh->prepare(qq{ select id, url from photo where keywordid = ? order by good desc limit 10} );
		$sth2->execute( $id );
		my ($photoid,$photourl, $photourls);
		while(my @row2 = $sth2->fetchrow_array) {
			$photourl = $row2[1] unless($photourl);
			$photourls .=qq{<img src="http://img.waao.jp/camera.gif" width=15 height=15 alt="$keyword画像"><a href="http://waao.jp/$keyword_encode/photo/$row2[0]/">$keyword画像</a><br>};
		}
		$html .= &_html_header("$keywordのﾌﾞﾛｸﾞ -ﾀﾚﾝﾄﾌﾞﾛｸﾞ名鑑-","$keyword,ﾌﾞﾛｸﾞ,ﾀﾚﾝﾄ,ｵﾌｨｼｬﾙﾌﾞﾛｸﾞ","$keywordのﾌﾞﾛｸﾞ。$keywordがｵﾌｨｼｬﾙﾌﾞﾛｸﾞで赤裸々にﾌﾟﾗｲﾍﾞｰﾄを告白中","http://waao.jp/$keyword_encode/blog/");
		if($simplewiki){
			$simplewiki =~s/\?//g;
			$html .= qq{<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">$simplewiki </font></marquee>};
		}
		$html .= qq{<center><h1>$keyword</h1></center>\n};
		$html .= qq{<center><h2><font color="#FF0000" size=1>｢$keyword｣のﾌﾞﾛｸﾞ</font></h2></center>\n};
		$html .= qq{<hr color="#009525">\n};
		$html .= qq{<center><a href="http://cgi.i-mobile.co.jp/ad_link.aspx?guid=on&asid=12525&pnm=0&asn=1"><img border="0" src="http://cgi.i-mobile.co.jp/ad_img.aspx?guid=on&asid=12525&pnm=0&asn=1&asz=0&atp=3&lnk=6666ff&bg=&txt=000000" alt="i-mobile"></a></center>\n};
		$html .= qq{<hr color="#009525">\n};
		$html .= qq{<h3><img src="http://img.waao.jp/mb17.gif" width=11 height=12 alt="$keyword">$keywordのﾌﾞﾛｸﾞ</h3>\n};
		$html .= qq{<center><img src="http://img.waao.jp/kaow03.gif" height=15 width=84 alt="$keywordのﾌﾞﾛｸﾞ"><br><a href="$blogurl" title="$keywordのﾌﾞﾛｸﾞ">ﾌﾞﾛｸﾞを見る</a><br><img src="http://img.waao.jp/kaowink02.gif" height=15 width=53 alt="$keywordのﾌﾞﾛｸﾞ"></center>\n};
		$html .= qq{<hr color="#009525">\n};
		$html .= qq{<h3><img src="http://img.waao.jp/kao-a08.gif" width=15 height=15 alt="$keyword">$keyword検索</h3>\n};
		unless($photourl){
			$html .= qq{<img src="http://img.waao.jp/noimage95.gif" width=95  style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left">};
		}else{
			my $link_img_path = &_make_file_path($id,"photo");
			$html .= qq{<a href="$link_img_path" title="$keyword"><img src="$photourl"  alt="$keyword画像" width=95  style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"></a>};
		}
		$html .= qq{<font size=1>};
		$html .= qq{<a href="$link_path}.qq{photolist/" title="$keywordの画像一覧">画像一覧</a><br>};
		if($wiki_id){
			my $link_wiki_path = &_make_file_path($id,"wiki");
			$html .= qq{<a href="$link_wiki_path" title="$keywordのﾌﾟﾛﾌ">ﾌﾟﾛﾌｨｰﾙ</a><br>};
			&_wiki($id, $wiki_id, $keyword );
			$sitemaptxt .= qq{<url>\n};
			$sitemaptxt .= qq{<loc>http://blog.waao.jp$link_path}.qq{wiki/</loc>\n};
			$sitemaptxt .= qq{<mobile:mobile/>\n};
			$sitemaptxt .= qq{</url>\n};

		}
		$html .= qq{<a href="http://waao.jp/$keyword_encode/uwasa/" title="$keywordのうわさ">うわさ</a><br>};
		$html .= qq{<a href="http://waao.jp/$keyword_encode/bbs/" title="$keywordの掲示板">掲示板</a><br>};
		$html .= qq{<a href="http://waao.jp/$keyword_encode/qanda/" title="$keywordのQ&A">Q&A</a><br>};
		$html .= qq{<a href="http://waao.jp/$keyword_encode/shopping/" title="$keywordのｱﾀﾞﾙﾄﾋﾞﾃﾞｵ">関連商品</a><br>};
		$html .= qq{<a href="http://waao.jp/$keyword_encode/news/" title="$keywordの関連ﾆｭｰｽ">関連ﾆｭｰｽ</a><br>};
		$html .= qq{</font>};
		$html .= qq{<br clear="all" />};
		$html .= qq{<hr color="#009525">\n};
		$html .= qq{<center><a href="http://cgi.i-mobile.co.jp/ad_link.aspx?guid=on&asid=12525&pnm=0&asn=2"><img border="0" src="http://cgi.i-mobile.co.jp/ad_img.aspx?guid=on&asid=12525&pnm=0&asn=2&asz=0&atp=3&lnk=6666ff&bg=&txt=000000" alt="i-mobile"></a></center>\n};
		$html .= qq{<hr color="#009525">\n};

		# yicha設定
		$html .= &_yicha_sp_menu($keyword);
		$html .= qq{<h3>$keywordを検索した人はこんな人も検索中</h3><br><font size=1>$recommend</font><br>};
		$html .= qq{<hr color="#009525">\n};
		$html .= qq{<center><a href="http://cgi.i-mobile.co.jp/ad_link.aspx?guid=on&asid=12525&pnm=0&asn=3"><img border="0" src="http://cgi.i-mobile.co.jp/ad_img.aspx?guid=on&asid=12525&pnm=0&asn=3&asz=0&atp=3&lnk=6666ff&bg=&txt=000000" alt="i-mobile"></a></center>\n};
		$html .= qq{<hr color="#009525">\n};
		$html .= qq{<a href="/" title="$geinou人ﾌﾞﾛｸﾞ検索">$geinou人ﾌﾞﾛｸﾞ検索</a>&gt;<strong>$keywordﾌﾞﾛｸﾞ</strong><br>};
		$html .= qq{<font color="#AAAAAA">$keywordのﾌﾞﾛｸﾞ㌻はｵﾌｨｼｬﾙﾌﾞﾛｸﾞと$keywordの画像や$keywordﾌﾟﾛﾌｨｰﾙ、$keyword動画、$keywordﾌﾞﾛｸﾞ、$keywordうわさなどの$keyword情報を無料で検索できる$keyword検索ｴﾝｼﾞﾝです<br>$datestr更新データ</font>};
		$html .= &_html_footer();
		
		my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-blog}.$link_path;
		mkdir($dirname, 0755);
		my $dirname_wiki = $dirname."wiki/";
		mkdir($dirname_wiki, 0755);
		my $dirname_photo = $dirname."photo/";
		mkdir($dirname_photo, 0755);
		my $dirname_photolist = $dirname."photolist/";
		mkdir($dirname_photolist, 0755);

		$sitemaptxt .= qq{<url>\n};
		$sitemaptxt .= qq{<loc>http://blog.waao.jp$link_path</loc>\n};
		$sitemaptxt .= qq{<mobile:mobile/>\n};
		$sitemaptxt .= qq{</url>\n};

		my $filename = qq{/var/www/vhosts/goo.to/httpdocs-blog}.$link_path.qq{index.html};
		print "$id $dirname $filename \n";
eval{
		open(OUT,"> $filename") || die('error');
		print OUT "$html";
		close(OUT);
#		print "$id $filename \n";
	};
if($@){
	print "$@ \n";
}
	# page photo
		$html = undef;
		
		$html .= &_html_header("$keywordの画像 -$geinou人ﾌﾞﾛｸﾞ検索-","$keyword,画像,写真,ﾌﾞﾛｸﾞ","$keywordの写真(無料画像)。$keywordの無料画像。","http://waao.jp/$keyword_encode/photo/");
		if($simplewiki){
			$simplewiki =~s/\?//g;
			$html .= qq{<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">$simplewiki </font></marquee>};
		}
		$html .= qq{<center><h1>$keyword</h1></center>\n};
		$html .= qq{<center><h2><font color="#FF0000" size=1>$keywordのﾌﾞﾛｸﾞ画像</font></h2></center>\n};
		$html .= qq{<hr color="#009525">\n};
		$html .= qq{<center><a href="http://cgi.i-mobile.co.jp/ad_link.aspx?guid=on&asid=12525&pnm=0&asn=1"><img border="0" src="http://cgi.i-mobile.co.jp/ad_img.aspx?guid=on&asid=12525&pnm=0&asn=1&asz=0&atp=3&lnk=6666ff&bg=&txt=000000" alt="i-mobile"></a></center>\n};
		$html .= qq{<hr color="#009525">\n};
		$html .= qq{<center><img src="$photourl" alt="$keyword画像(写真)"></center>\n};
		$html .= qq{<a href="http://waao.jp/$keyword_encode/photolist/0-1/" title="$keywordの画像一覧">画像一覧</a><br>};
		$html .= qq{<hr color="#009525">\n};
		$html .= qq{<center><a href="http://cgi.i-mobile.co.jp/ad_link.aspx?guid=on&asid=12525&pnm=0&asn=2"><img border="0" src="http://cgi.i-mobile.co.jp/ad_img.aspx?guid=on&asid=12525&pnm=0&asn=2&asz=0&atp=3&lnk=6666ff&bg=&txt=000000" alt="i-mobile"></a></center>\n};
		$html .= qq{<hr color="#009525">\n};

		# yicha設定
		$html .= &_yicha_sp_menu($keyword);
		$html .= qq{<h3>$keywordを検索した人はこんな人も検索中</h3><br><font size=1>$recommend</font><br>};

		$html .= qq{<hr color="#009525">\n};
			$html .= qq{<center><a href="http://cgi.i-mobile.co.jp/ad_link.aspx?guid=on&asid=12525&pnm=0&asn=3"><img border="0" src="http://cgi.i-mobile.co.jp/ad_img.aspx?guid=on&asid=12525&pnm=0&asn=3&asz=0&atp=3&lnk=6666ff&bg=&txt=000000" alt="i-mobile"></a></center>\n};
		$html .= qq{<hr color="#009525">\n};
		$html .= qq{<a href="/" title="$geinou人ﾌﾞﾛｸﾞ検索">$geinou人ﾌﾞﾛｸﾞ検索</a>&gt;<a href="$link_path" title="$keywordのﾌﾞﾛｸﾞ">$keywordﾌﾞﾛｸﾞ</a>&gt;<strong>$keyword画像(写真)</strong><br>};
		$html .= qq{<font color="#AAAAAA">$keywordのﾌﾞﾛｸﾞ㌻はｵﾌｨｼｬﾙﾌﾞﾛｸﾞと$keywordの画像や$keywordﾌﾟﾛﾌｨｰﾙ、$keyword動画、$keywordﾌﾞﾛｸﾞ、$keywordうわさなどの$keyword情報を無料で検索できる$keyword検索ｴﾝｼﾞﾝです<br>$datestr更新データ</font>};
		$html .= &_html_footer();
		
		$sitemaptxt .= qq{<url>\n};
		$sitemaptxt .= qq{<loc>http://blog.waao.jp$link_path}.qq{photo/</loc>\n};
		$sitemaptxt .= qq{<mobile:mobile/>\n};
		$sitemaptxt .= qq{</url>\n};
		my $filename = qq{/var/www/vhosts/goo.to/httpdocs-blog}.$link_path.qq{photo/index.html};
		print "$id $dirname $filename \n";
eval{
		open(OUT,"> $filename") || die('error');
		print OUT "$html";
		close(OUT);
#		print "$id $filename \n";
	};
if($@){
	print "$@ \n";
}
	# page photo end
	# page photolist
		$html = undef;
		
		$html .= &_html_header("画像:$keyword","$keyword,画像,ﾌﾟﾛﾌ","$keywordの画像。$keywordの無料画像。");
		if($simplewiki){
			$html .= qq{<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">$simplewiki </font></marquee>};
		}
		$html .= qq{<center><h1>$keyword</h1></center>\n};
		$html .= qq{<center><h2><font color="#FF0000" size=1>$keyword画像一覧</font></h2></center>\n};
		$html .= qq{<hr color="#009525">\n};
		$html .= qq{<center><a href="http://cgi.i-mobile.co.jp/ad_link.aspx?guid=on&asid=12525&pnm=0&asn=1"><img border="0" src="http://cgi.i-mobile.co.jp/ad_img.aspx?guid=on&asid=12525&pnm=0&asn=1&asz=0&atp=3&lnk=6666ff&bg=&txt=000000" alt="i-mobile"></a></center>\n};
		$html .= qq{<hr color="#009525">\n};
		$html .= qq{<h3><img src="http://img.waao.jp/kao-a08.gif" width=15 height=15 alt="$keyword">$keyword画像一覧</h3>\n};
		$html .= qq{$photourls\n};
		$html .= qq{<a href="http://waao.jp/$keyword_encode/photolist/0-1/">画像一覧</a><br>};
		$html .= qq{<hr color="#009525">\n};
		$html .= qq{<center><a href="http://cgi.i-mobile.co.jp/ad_link.aspx?guid=on&asid=12525&pnm=0&asn=2"><img border="0" src="http://cgi.i-mobile.co.jp/ad_img.aspx?guid=on&asid=12525&pnm=0&asn=2&asz=0&atp=3&lnk=6666ff&bg=&txt=000000" alt="i-mobile"></a></center>\n};
		$html .= qq{<hr color="#009525">\n};

		# yicha設定
		$html .= &_yicha_sp_menu($keyword);
		$html .= qq{<h3>$keywordを検索した人はこんな人も検索中</h3><br><font size=1>$recommend</font><br>};

		$html .= qq{<hr color="#009525">\n};
		$html .= qq{<center><a href="http://cgi.i-mobile.co.jp/ad_link.aspx?guid=on&asid=12525&pnm=0&asn=3"><img border="0" src="http://cgi.i-mobile.co.jp/ad_img.aspx?guid=on&asid=12525&pnm=0&asn=3&asz=0&atp=3&lnk=6666ff&bg=&txt=000000" alt="i-mobile"></a></center>\n};
		$html .= qq{<hr color="#009525">\n};
		$html .= qq{<a href="/" title="$geinou人ﾌﾞﾛｸﾞ検索">$geinou人ﾌﾞﾛｸﾞ検索</a>&gt;<a href="$link_path">$keyword検索</a>&gt;<strong>$keyword画像</strong><br>};
		$html .= qq{<font color="#AAAAAA">$keywordの画像は人力であつめた$keywordの画像(写真)を無料で検索できる$keyword検索ｴﾝｼﾞﾝです<br>$datestr更新データ</font>};
		$html .= &_html_footer();
		
		$sitemaptxt .= qq{<url>\n};
		$sitemaptxt .= qq{<loc>http://blog.waao.jp$link_path}.qq{photolist/</loc>\n};
		$sitemaptxt .= qq{<mobile:mobile/>\n};
		$sitemaptxt .= qq{</url>\n};
		my $filename = qq{/var/www/vhosts/goo.to/httpdocs-blog}.$link_path.qq{photolist/index.html};
		print "$id $dirname $filename \n";
eval{
		open(OUT,"> $filename") || die('error');
		print OUT "$html";
		close(OUT);
#		print "$id $filename \n";
	};
if($@){
	print "$@ \n";
}
	# page photolist end


# page make end		
		
	}
	
	# sitemap
	$sitemaptxt .= qq{</urlset>\n};
	my $sitemap = qq{/var/www/vhosts/goo.to/httpdocs-blog/sitemap$i.xml};
	open(OUT,"> $sitemap") || die('error');
	print OUT "$sitemaptxt";
	close(OUT);
	
	# robots.txt
	my $robots_str = qq{Sitemap: http://blog.waao.jp/sitemap$i.xml\n};
	
	my $robots = qq{/var/www/vhosts/goo.to/httpdocs-blog/robots.txt};
	open(OUT,">> $robots") || die('error');
	print OUT "$robots_str";
	close(OUT);

}
	$dbh->disconnect;
	return;
}

sub _wiki(){
	my $id = shift;
	my $wiki_id = shift;
	my $keyword = shift;
	my $keyword_encode = &str_encode($keyword);
	my $link_path = &_make_file_path($id);
	my $geinou = &html_mojibake_str("geinou");

	my $dbh = &_db_connect();

	my $sth = $dbh->prepare(qq{ select wikipedia, linklist, person, sex, birthday from wikipedia where rev_id = ? limit 1} );
	$sth->execute($wiki_id);
	while(my @row = $sth->fetchrow_array) {
		my ($wikipedia, $linklist, $person, $sex, $birthday) = @row;

		$wikipedia=~s/href=\"\//href=\"http:\/\/waao.jp\//g;
		my $html;
		
		$html .= &_html_header("$keywordﾌﾟﾛﾌｨｰﾙ(wikipedia)","$keyword,ﾌﾟﾛﾌｨｰﾙ,wikipedia","$keywordのﾌﾟﾛﾌｨｰﾙ。$keywordの無料wikipedia。","http://waao.jp/$keyword_encode/wiki/");
		$html .= qq{<center><h1>$keyword</h1></center>\n};
		$html .= qq{<center><h2><font color="#FF0000" size=1>$keywordﾌﾟﾛﾌｨｰﾙ</font></h2></center>\n};
		$html .= qq{<hr color="#009525">\n};
		$html .= qq{<center><a href="http://cgi.i-mobile.co.jp/ad_link.aspx?guid=on&asid=12525&pnm=0&asn=1"><img border="0" src="http://cgi.i-mobile.co.jp/ad_img.aspx?guid=on&asid=12525&pnm=0&asn=1&asz=0&atp=3&lnk=6666ff&bg=&txt=000000" alt="i-mobile"></a></center>\n};
		$html .= qq{<hr color="#009525">\n};
		$html .= qq{<h3><img src="http://img.waao.jp/kao-a08.gif" width=15 height=15 alt="$keyword">$keywordとは</h3>\n};
		$html .= qq{<div align=right>⇒画像は<a href="$link_path">コチラ</a></div>};
		if($linklist){
			$html .= qq{$linklist<br>};
			$html .= qq{<hr color="#009525">\n};
		}
		$html .= qq{<center><a href="http://cgi.i-mobile.co.jp/ad_link.aspx?guid=on&asid=12525&pnm=0&asn=2"><img border="0" src="http://cgi.i-mobile.co.jp/ad_img.aspx?guid=on&asid=12525&pnm=0&asn=2&asz=0&atp=3&lnk=6666ff&bg=&txt=000000" alt="i-mobile"></a></center>\n};
		$html .= qq{<hr color="#009525">\n};
		$html .= qq{$wikipedia\n};
		$html .= qq{<hr color="#009525">\n};

		# yicha設定
		$html .= &_yicha_sp_menu($keyword);

		$html .= qq{<hr color="#009525">\n};
			$html .= qq{<center><a href="http://cgi.i-mobile.co.jp/ad_link.aspx?guid=on&asid=12525&pnm=0&asn=3"><img border="0" src="http://cgi.i-mobile.co.jp/ad_img.aspx?guid=on&asid=12525&pnm=0&asn=3&asz=0&atp=3&lnk=6666ff&bg=&txt=000000" alt="i-mobile"></a></center>\n};
		$html .= qq{<hr color="#009525">\n};
		$html .= qq{<a href="/">$geinou人ﾌﾞﾛｸﾞ検索</a>&gt;<a href="$link_path" title="$keywordのﾌﾞﾛｸﾞ">$keywordﾌﾞﾛｸﾞ</a>&gt;<strong>$keywordﾌﾟﾛﾌｨｰﾙ</strong><br>};
		$html .= qq{<font color="#AAAAAA">$keywordのﾌﾟﾛﾌｨｰﾙは$keywordのwikipediaの情報を元に無料でﾌﾟﾛﾌｨｰﾙ検索できる$keyword検索ｴﾝｼﾞﾝです</font>};
		$html .= &_html_footer();
		
		my $filename = qq{/var/www/vhosts/goo.to/httpdocs-blog}.$link_path.qq{/wiki/index.html};
		print "wiki $id $filename \n";
eval{
		open(OUT,"> $filename") || die('error');
		print OUT "$html";
		close(OUT);
#		print "$id $filename \n";
	};
if($@){
	print "$@ \n";
}
	}


	$dbh->disconnect;
	return;
}
sub _pages(){
	
	my $datestr = &_get_date();

	my $dbh = &_db_connect();
for(my $i=0;$i<3000;$i++){
	my $start = $i * 50;
	print "start $start \n";
	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-blog/page/};

	# ランダムパーソン
	my $recommend;
	my $sth = $dbh->prepare(qq{ select id, keyword from keyword where blogurl is not null order by rand() limit 10} );
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my $link_path = &_make_file_path($row[0]);
		$recommend .= qq{<a href="$link_path" title="$row[1]">$row[1]</a> };
	}

	my $html;
	my $pagestr = $i + 1;
	$html .= &_html_header("ﾀﾚﾝﾄﾌﾞﾛｸﾞ $pagestrﾍﾟｰｼﾞ $datestr","ﾌﾞﾛｸﾞ,ﾀﾚﾝﾄ,ｷｰﾜｰﾄﾞ,ﾗﾝｷﾝｸﾞ,検索","ﾀﾚﾝﾄﾌﾞﾛｸﾞﾗﾝｷﾝｸﾞ：あなたの知りたいｷｰﾜｰﾄﾞのﾀﾚﾝﾄﾌﾞﾛｸﾞ情報が発見できるお得なｷｰﾜｰﾄﾞ辞典です","http://waao.jp/bookmark/");
	$html .= qq{<table border=0 bgcolor="#DFFFBF" width="100%"><tr><td><center><h1>ﾀﾚﾝﾄﾌﾞﾛｸﾞﾗﾝｷﾝｸﾞ</h1></center></td></tr></table>\n};
	$html .= qq{<center><h2><font color="#FF0000" size=1>$pagestrﾍﾟｰｼﾞ目 $datestr更新</font></h2></center>\n};
	$html .= qq{<hr color="#009525">\n};
	$html .= qq{<center><a href="http://cgi.i-mobile.co.jp/ad_link.aspx?guid=on&asid=22272&pnm=0&asn=1"><img border="0" src="http://cgi.i-mobile.co.jp/ad_img.aspx?guid=on&asid=22272&pnm=0&asn=1&asz=0&atp=3&lnk=6666ff&bg=&txt=000000" alt="i-mobile"></a></center>\n};
	$html .= qq{<hr color="#009525">\n};
	my $sth = $dbh->prepare(qq{ select id, keyword, simplewiki from keyword where blogurl is not null limit $start, 50} );
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my $link_path = &_make_file_path($row[0]);
		$html .= qq{<font color="#FF0000">》</font><a href="$link_path" title="$row[1]">$row[1]</a><br>\n};

	}
	my $nextpage = $i + 1;
	$html .= qq{<a href="/page/$nextpage.html">$nextpageﾍﾟｰｼﾞ目へ</a><br>\n};
	
	$html .= qq{<hr color="#009525">\n};
	$html .= qq{<center><a href="http://cgi.i-mobile.co.jp/ad_link.aspx?guid=on&asid=22272&pnm=0&asn=2"><img border="0" src="http://cgi.i-mobile.co.jp/ad_img.aspx?guid=on&asid=22272&pnm=0&asn=2&asz=0&atp=3&lnk=6666ff&bg=&txt=000000" alt="i-mobile"></a></center>\n};
	$html .= qq{<hr color="#009525">\n};

	# yicha設定
	$html .= qq{<h3>ｵｽｽﾒｷｰﾜｰﾄﾞ</h3><font size=1>$recommend</font><br>};
	$html .= qq{<hr color="#009525">\n};
	$html .= qq{<center><a href="http://cgi.i-mobile.co.jp/ad_link.aspx?guid=on&asid=22272&pnm=0&asn=3"><img border="0" src="http://cgi.i-mobile.co.jp/ad_img.aspx?guid=on&asid=22272&pnm=0&asn=3&asz=0&atp=3&lnk=6666ff&bg=&txt=000000" alt="i-mobile"></a></center>\n};
	$html .= qq{<hr color="#009525">\n};
	$html .= qq{<a href="/" title="ﾀﾚﾝﾄﾌﾞﾛｸﾞ">ﾀﾚﾝﾄﾌﾞﾛｸﾞ</a><br>};
	$html .= &_html_footer();

	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-blog/page/};
	mkdir($dirname, 0755);
	my $filename = qq{/var/www/vhosts/goo.to/httpdocs-blog/page/$i.html};
eval{
		open(OUT,"> $filename") || die('error');
		print OUT "$html";
		close(OUT);
	};
if($@){
	print "$@ \n";
}
}

	$dbh->disconnect;
	return;
}

sub _make_file_path(){
	my $keyword_id = shift;
	my $type = shift;

	my $dir = int($keyword_id / 1000);
	my $file = $keyword_id % 1000;
		
	my $filepath = qq{/$dir/$keyword_id/};
	$filepath = qq{/$dir/$keyword_id/$type/} if($type);
	
	return $filepath;
}

sub _html_footer(){
	my $html;

	$html .= qq{<center><img src="http://img.waao.jp/logo.jpg" alt="waao.jp"></center>\n};
	$html .= qq{</body>\n};
	$html .= qq{</html>\n};
	
	return $html;

}

sub _html_header(){
	my $title = shift;
	my $keywords = shift;
	my $description = shift;
	my $mld = shift;
	
	my $html;
	
	$html .= qq{<!DOCTYPE HTML PUBLIC "-//W3C//DTD Compact HTML 1.0 Draft //EN">};
	$html .= qq{<html>};
	$html .= qq{<head>};
	$html .= qq{<meta http-equiv="content-type" CONTENT="text/html;charset=Shift_JIS">};
	$html .= qq{<meta name="google-site-verification" content="cxJSvOw2PI0z0sXEEx3KDvT3mvpKq8CP7PE1Ge1zPgs" />};
	$html .= qq{<meta name="robots" content="index,follow">};
	$html .= qq{<meta http-equiv="Expires" content="0">};
	$html .= qq{<meta http-equiv="Pragma" CONTENT="no-cache">};
	$html .= qq{<meta http-equiv="Cache-Control" CONTENT="no-cache">};
	$html .= qq{<meta name="keywords" content="$keywords">\n};
	$html .= qq{<meta name="description" content="$description">\n};
	$html .= qq{<title>$title</title>\n};
	$html .= qq{<link rel="alternate" media="handheld" href="$mld" />\n} if($mld);
	$html .= qq{</head>\n};
	$html .= qq{<body>\n};
	
	return $html;

}

sub _db_connect(){

	my $dsn = 'DBI:mysql:waao';
	my $user = 'mysqlweb';
	my $password = 'WaAoqzxe7h6yyHz';
	my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 1, AutoCommit => 0});

	return $dbh;
}

sub html_mojibake_str(){
	my $tmpl = shift;
	
my $file = qq{/var/www/vhosts/goo.to/tmpl/$tmpl};
my $fh;
my $filedata;
open( $fh, "<", $file );
while( my $line = readline $fh ){ 
	$filedata .= $line;
}
close ( $fh );

	return $filedata;
}

sub _memcache(){

	my $memd = new Cache::Memcached {
    'servers' => [ "localhost:11211" ],
    'debug' => 0,
    'compress_threshold' => 1_000,
	};

	return $memd;
}

sub _get_yicha_url(){
	my $str  = shift;
	my $type = shift;

	# type
	# p ｻｲﾄ
	# v 動画
	# i 画像
	# m 音楽
	
	$type = 'p' unless($type);

	my $url;
	my $str_encode = &str_encode($str);

	$url = qq{http://u.yicha.jp/union/u.jsp?st=$type&s=108402691&keyword=$str_encode};

	return $url;
}

sub _get_date(){
	my $date;
	my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
	$year = $year + 1900;
	$mon = $mon + 1;
	$date = sprintf("%d-%02d-%02d",$year,$mon,$mday);

	return $date;
}

sub _yicha_sp_menu(){
	my $keyword =shift;
	my $html;
	
	my $y_p = &_get_yicha_url($keyword,'p');
	my $y_v = &_get_yicha_url($keyword,'v');
	my $y_i = &_get_yicha_url($keyword,'i');
	my $y_m = &_get_yicha_url($keyword,'m');
	$html .= qq{<h3>$keyword<font color="#ff0000">特別ﾒﾆｭｰ</font></h3>\n};
	$html .= qq{<center><img src="http://img.waao.jp/kya-.gif" widht=15 height=15> <a href="$y_p">ｵｽｽﾒ</a> <a href="$y_v">動画</a> <a href="$y_i">画像</a> <a href="$y_m">音楽</a> </center>};

	return $html;
}

sub _html_meikanlist(){
my $file = qq{/var/www/vhosts/goo.to/etc/makehtml/meikanlist.html};
my $fh;
my $filedata;
open( $fh, "<", $file );
while( my $line = readline $fh ){ 
	$filedata .= $line;
}
close ( $fh );
	
	return $filedata;
}
