package Waao::Pages::Kizasi;
use strict;
use base qw(Waao::Pages::Base);
use Waao::Html;
use Waao::Data;
use Waao::Utility;

# 人気ワードを表示するページ
# /kizasi/
# /list-detail/kizasi/

sub dispatch(){
	my $self = shift;

	if($self->{cgi}->param('q') eq 'list-kizasi'){
		&_detail($self);
	}elsif($self->{cgi}->param('q') eq 'list-type'){
		&_list($self);
	}else{
		&_top($self);
	}
	return;
}
sub _top(){
	my $self = shift;

	my $geinou = &html_mojibake_str("geinou");
	$self->{html_title} = qq{今日の$geinouニュース -流行モノ検索プラス-};
	$self->{html_keywords} = qq{$geinou,$geinouニュース,流行,人気,ブーム,検索};
	$self->{html_description} = qq{たった1分でわかる今日の$geinouニュース。最新トレンド情報付};

	my $hr = &html_hr($self,1);	
	&html_header($self);

	my $ad = &html_google_ad($self);

if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML
	
}else{
# xhmlt chtml

print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FFFF2B">たった1分でわかる今日の$geinouニュース棈</font></marquee>
<center>
<h2><img src="http://img.waao.jp/geinou.gif" width=120 height=28 alt="$geinouニュース"><font size=1 color="#FF0000">プラス</font></h2>
<h2><font size=1>ブーム・流行の<font color="#FF0000">きざし</font>検索エンジン</font></h2>
</center>
$hr
<center>
$ad
</center>
$hr
<center>
<a href="/meikan/">
25万人褜棈<br>
<font color="#FF0000">無料</font>タレント名鑑
</a>
</center>
$hr
END_OF_HTML

&html_table($self, qq{<img src="http://img.waao.jp/lamp1.gif" width=14 height=11><font color="#009525">ブログで話題のキーワード</font>}, 0, 0);
&_get_rss_data($self,1);

&html_table($self, qq{<img src="http://img.waao.jp/lamp2.gif" width=14 height=11><font color="#009525">上昇中キーワード</font>}, 0, 0);
&_get_rss_data($self,2);

&html_table($self, qq{<img src="http://img.waao.jp/lamp3.gif" width=14 height=11><font color="#009525">今がわかる上昇ワード5</font>}, 0, 0);
&_get_rss_data($self,3);

&html_table($self, qq{<img src="http://img.waao.jp/lamp4.gif" width=14 height=11><font color="#009525">ただいま、検索上昇中</font>}, 0, 0);
&_get_rss_data($self,4);

&html_table($self, qq{<img src="http://img.waao.jp/lamp5.gif" width=14 height=11><font color="#009525">検索数ランキング</font>}, 0, 0);
&_get_rss_data($self,5);

&html_table($self, qq{<img src="http://img.waao.jp/lamp1.gif" width=14 height=11><font color="#009525">人名検索数ランキング</font>}, 0, 0);
&_get_rss_data($self,6);

&html_table($self, qq{<img src="http://img.waao.jp/lamp2.gif" width=14 height=11><font color="#009525">テレビ・ドラマ検索数ランキング</font>}, 0, 0);
&_get_rss_data($self,7);

&html_table($self, qq{<img src="http://img.waao.jp/lamp3.gif" width=14 height=11><font color="#009525">ゲーム・アニメ検索数ランキング</font>}, 0, 0);
&_get_rss_data($self,8);

&html_table($self, qq{<img src="http://img.waao.jp/lamp4.gif" width=14 height=11><font color="#009525">スポーツ検索数ランキング</font>}, 0, 0);
&_get_rss_data($self,9);

&html_table($self, qq{<img src="http://img.waao.jp/lamp5.gif" width=14 height=11><font color="#009525">トレンドサーフィン</font>}, 0, 0);
&_get_rss_data($self,10);

&html_table($self, qq{<img src="http://img.waao.jp/lamp1.gif" width=14 height=11><font color="#009525">All About人気記事</font>}, 0, 0);
&_get_rss_data($self,11);

&html_table($self, qq{<img src="http://img.waao.jp/lamp2.gif" width=14 height=11><font color="#009525">はてぶ人気エントリー</font>}, 0, 0);
&_get_rss_data($self,12);

&html_table($self, qq{<img src="http://img.waao.jp/lamp3.gif" width=14 height=11><font color="#009525">R25人気記事</font>}, 0, 0);
&_get_rss_data($self,13);


print << "END_OF_HTML";
$hr
$geinouニュースは、毎日更新されます<br>
1分で今日の話題がわかる携帯便利ツールです<br>
<font color="#FF0000">ブックマーク</font>を利用すると便利です。<br>
$hr
<center>
<a href="/meikan/">
画像付棈完全無料<br>
<font color="#FF0000">無料</font>タレント名鑑
</a>
</center>
$hr
偂<a href="http://waao.jp/ranking/">みんなのランキング</a><br>
<a href="/" accesskey=0>トップ</a>&gt;<strong>$geinouニュース</strong><br>
<font size=1 color="#AAAAAA">$geinouニュースは、急上昇中の話題ネタやこれからの流行や人気のきざしをいち早く検索できます。<br>
トレンドチェックに役立つ情報を集めたきざし検索専用の情報RSSリーダです。<br>
<a href="http://developer.yahoo.co.jp/about">Webサービス by Yahoo! JAPAN</a><br>
hatena<br>
allabout<br>
</fonnt>
END_OF_HTML

}
	
	&html_footer($self);
	
	return;
}

sub _get_rss_data(){
	my $self = shift;
	my $type = shift;

	my $str;
	$str.=qq{<font size=1>} unless($self->{access_type} eq 4);
	my 	$sth = $self->{dbi}->prepare(qq{ select id, title, bodystr, datestr, type, geturl, ext from rssdata where type = ? and datestr >= ADDDATE(CURRENT_DATE,INTERVAL -1 DAY) order by datestr desc,id limit 10} );
	$sth->execute($type);
	my $cnt;
	while(my @row = $sth->fetchrow_array) {
		$cnt++;
 #		my $url = &html_pc_2_mb($row[);
		$str.=qq{<font color="#009525">■</font><a href="/list-kizasi/kizasi/$row[0]/" title="$row[1]">$row[1]</a><br>};
		next if($type eq 1);
		next if($row[2] eq "utf8");
		$row[2] =~s/border=\"0\" align=\"left\" hspace=\"5\"\>/\>\<br>/;
		$str.=qq{$row[2]<br>};
#		$str.=qq{$row[3]<br>};
	}
	unless($cnt){
		my $limitcnt = 10;
		$limitcnt = 3 if($type == 13);
		my 	$sth = $self->{dbi}->prepare(qq{ select id, title, bodystr, datestr, type, geturl, ext from rssdata where type = ? order by datestr desc,id limit $limitcnt} );
		$sth->execute($type);
		my $cnt;
		while(my @row = $sth->fetchrow_array) {
			$str.=qq{<font color="#009525">■</font><a href="/list-kizasi/kizasi/$row[0]/" title="$row[1]">$row[1]</a><br>};
			next if($type eq 1);
			next if($row[2] eq "utf8");
			$row[2] =~s/border=\"0\" align=\"left\" hspace=\"5\"\>/\>\<br>/;
			$str.=qq{$row[2]<br>};
		}
	}
	$str.=qq{<div align=right>⇒<a href="/list-type/kizasi/$type/">全て見る</a></div>};
	$str.=qq{</font>} unless($self->{access_type} eq 4);
print << "END_OF_HTML";
$str
END_OF_HTML

	return;
}

sub _detail(){
	my $self = shift;
	my $dataid = $self->{cgi}->param('p1');
	my $geinou = &html_mojibake_str("geinou");
	my $type;
	my ($title,$bodystr,$datestr,$geturl,$ext);	
	my 	$sth = $self->{dbi}->prepare(qq{ select title, bodystr, datestr, geturl, ext, type from rssdata where id= ?});
	$sth->execute($dataid);
	while(my @row = $sth->fetchrow_array) {
		($title,$bodystr,$datestr,$geturl,$ext,$type) = @row;
		$geturl = &html_pc_2_mb($geturl);
	}
	
	$self->{html_title} = qq{$title};
	$self->{html_keywords} = qq{$title,流行,人気,ブーム,きざし,検索};
	$self->{html_description} = qq{$title 今話題になってます！$titleについて詳しく検索できます！};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	
	$bodystr = undef if($bodystr eq "utf8");

	my $ad = &html_google_ad($self);
	$geturl = &html_link_no_robot($self, $geturl);
	my $ad_yicha_site = &html_yicha_url($self, $title, 'p');

&html_table($self, qq{<h1><font color="#555555">$title</font></h1>}, 1, 0);
print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
<img src="http://img.waao.jp/kya-.gif" width=15 height=15>$title<br>
<br>
<center>
<a href="$ad_yicha_site">オく知りたい方</a>丨
</center>
<br>
$hr
END_OF_HTML

if($bodystr){
print << "END_OF_HTML";
<font color="#555555">
$datestr<br>
$title<br>
$bodystr<br>
<div align=right>⇒<a href="$geturl">詳しく見る</a></div>
</font>
$hr
END_OF_HTML
}
my ($datacnt, $keyworddata) = &get_keyword($self, $title);
if($datacnt){
	&html_table($self, qq{<font size=1 color="#00968c">$title</font><font size=1 color="#FF0000">検索プラス</font>}, 0, 0);
	my ($photodatacnt, $photodata) = &get_photo($self, $keyworddata->{id});
	&html_keyword_info($self, $keyworddata, $photodata);
print << "END_OF_HTML";
$hr
END_OF_HTML
}else{
	#主要ワードであれば追加
	if( ($type eq 4) || ($type eq 5) || ($type eq 6) || ($type eq 7) || ($type eq 8)){
			use Waao::Data;
			my ($datacnt, $wikipedia) = &get_wiki($self, $title);
			my $rev_id;
			$rev_id = $wikipedia->{rev_id} if($wikipedia);
			my $sth = $self->{dbi}->prepare(qq{ insert into keyword (`keyword`,`cnt`,`wiki_id`) values (?,?,?)} );
			$sth->execute($title,1,$rev_id);
			$sth = $self->{dbi}->prepare(qq{ delete from keyword_tmp where keyword = ? limit 1} );
			$sth->execute($title);
	}
}

print << "END_OF_HTML";
<center>
<a href="/meikan/">
画像付棈完全無料<br>
<font color="#FF0000">無料</font>タレント名鑑
</a>
</center>
$hr
END_OF_HTML

&html_table($self, qq{<font color="#555555">過去の話題</font>}, 0, 0);

# 過去の話題
my 	$sth = $self->{dbi}->prepare(qq{ select id, title, bodystr, datestr, type, geturl, ext from rssdata where type = ? and id < ? order by id desc limit 10} );
$sth->execute($type,$dataid);
while(my @row = $sth->fetchrow_array) {
print << "END_OF_HTML";
<a href="/list-kizasi/kizasi/$row[0]/">$row[1]</a> 
END_OF_HTML
}

print << "END_OF_HTML";
$hr
偂<a href="http://waao.jp/ranking/>みんなのランキング</a><br>
<a href="/" accesskey=0>トップ</a>&gt;<a href="/kizasi/" title="$geinouニュース">$geinouニュース</a>&gt;<strong>$title</strong><br>
<font size=1 color="#AAAAAA">急上昇中の話題ネタやこれからの流行や人気のきざしをいち早く検索できます。<br>
トレンドチェック専用の情報RSSリーダです。<br>
<a href="http://developer.yahoo.co.jp/about">Webサービス by Yahoo! JAPAN</a><br>
hatena<br>
allabout<br>
</fonnt>
END_OF_HTML

	&html_footer($self);
	return;
}

sub _list(){
	my $self = shift;
	
	my $type = $self->{cgi}->param('p1');
	my $page = $self->{cgi}->param('p2');

	my $pagecnt = 10;
	my ($limit_s, $limit, $next_page) = &pager( $pagecnt, ($page || 0) );

	my $str;
	$str.=qq{<font size=1>};

	my 	$sth = $self->{dbi}->prepare(qq{ select id, title, bodystr, datestr, type, geturl, ext from rssdata where type = ? order by datestr desc,id limit $limit_s,$limit} );
	$sth->execute($type);
	my $cnt;
	my $datestr;
	while(my @row = $sth->fetchrow_array) {
		$cnt++;
		if( $datestr ne $row[3] ){
			$datestr = $row[3];
			$str.=qq{ $row[3]<br>};
		}
		$str.=qq{<font color="#009525">■</font><a href="/list-kizasi/kizasi/$row[0]/">$row[1]</a><br>};
		next if($type eq 1);
		next if($row[2] eq "utf8");
		$row[2] =~s/border=\"0\" align=\"left\" hspace=\"5\"\>/\>\<br>/;
		$str.=qq{$row[2]<br>};
	}
	$str.=qq{データ取得中です。} unless($cnt);
	$str.= qq{<div align=right><img src="http://img.waao.jp/m2028.gif" width=48 height=9><a href="/list-type/kizasi/$type/$next_page/">次へ</a></div>};
	$str.=qq{</font>};

	my $title;
	if($type eq 1){
		$self->{html_title} = qq{ブログで話題のキーワード 流行モノ検索プラス};
		$self->{html_keywords} = qq{ブログ,話題,流行,人気,ブーム,きざし,検索};
		$self->{html_description} = qq{ブログで話題のキーワードから、今後流行する人気ブームのきざしを先に発見する検索サービス};
		$title = qq{ブログで話題のキーワード};
	}elsif($type eq 2){
		$self->{html_title} = qq{上昇中キーワード 流行モノ検索プラス};
		$self->{html_keywords} = qq{上昇中,キーワード,流行,人気,ブーム,きざし,検索};
		$self->{html_description} = qq{上昇中キーワードから、今後流行する人気ブームのきざしを先に発見する検索サービス};
		$title = qq{上昇中キーワード};
	}elsif($type eq 3){
		$self->{html_title} = qq{今がわかる上昇ワード5 流行モノ検索プラス};
		$self->{html_keywords} = qq{上昇ワード,話題,流行,人気,ブーム,きざし,検索};
		$self->{html_description} = qq{今がわかる上昇ワード5から、今後流行する人気ブームのきざしを先に発見する検索サービス};
		$title = qq{今がわかる上昇ワード5};
	}elsif($type eq 4){
		$self->{html_title} = qq{ただいま、検索上昇中 流行モノ検索プラス};
		$self->{html_keywords} = qq{上昇,話題,流行,人気,ブーム,きざし,検索};
		$self->{html_description} = qq{ただいま、検索上昇中から、今後流行する人気ブームのきざしを先に発見する検索サービス};
		$title = qq{ただいま、検索上昇中};
	}elsif($type eq 5){
		$self->{html_title} = qq{検索数ランキング 流行モノ検索プラス};
		$self->{html_keywords} = qq{検索数,ランキング,流行,人気,ブーム,きざし,検索};
		$self->{html_description} = qq{検索数ランキングから、今後流行する人気ブームのきざしを先に発見する検索サービス};
		$title = qq{検索数ランキング};
	}elsif($type eq 6){
		$self->{html_title} = qq{人名検索数ランキング 流行モノ検索プラス};
		$self->{html_keywords} = qq{人名,ランキング,流行,人気,ブーム,きざし,検索};
		$self->{html_description} = qq{人名検索数ランキングから、今後流行する人気ブームのきざしを先に発見する検索サービス};
		$title = qq{人名検索数ランキング};
	}elsif($type eq 7){
		$self->{html_title} = qq{テレビ・ドラマ検索数ランキング 流行モノ検索プラス};
		$self->{html_keywords} = qq{テレビ,ドラマ,話題,流行,人気,ブーム,きざし,検索};
		$self->{html_description} = qq{テレビ・ドラマ検索数ランキングから、今後流行する人気ブームのきざしを先に発見する検索サービス};
		$title = qq{テレビ・ドラマ検索数ランキング};
	}elsif($type eq 8){
		$self->{html_title} = qq{ゲーム・アニメ検索数ランキング 流行モノ検索プラス};
		$self->{html_keywords} = qq{ゲーム,アニメ,話題,流行,人気,ブーム,きざし,検索};
		$self->{html_description} = qq{ゲーム・アニメ検索数ランキングから、今後流行する人気ブームのきざしを先に発見する検索サービス};
		$title = qq{ゲーム・アニメ検索数ランキング};
	}elsif($type eq 9){
		$self->{html_title} = qq{スポーツ検索数ランキング 流行モノ検索プラス};
		$self->{html_keywords} = qq{スポーツ,ランキング,話題,流行,人気,ブーム,きざし,検索};
		$self->{html_description} = qq{スポーツ検索数ランキングから、今後流行する人気ブームのきざしを先に発見する検索サービス};
		$title = qq{スポーツ検索数ランキング};
	}elsif($type eq 10){
		$self->{html_title} = qq{トレンドサーフィン 流行モノ検索プラス};
		$self->{html_keywords} = qq{トレンドサーフィン,話題,流行,人気,ブーム,きざし,検索};
		$self->{html_description} = qq{トレンドサーフィンから、今後流行する人気ブームのきざしを先に発見する検索サービス};
		$title = qq{トレンドサーフィン};
	}elsif($type eq 11){
		$self->{html_title} = qq{All About人気記事 流行モノ検索プラス};
		$self->{html_keywords} = qq{allabout,話題,流行,人気,ブーム,きざし,検索};
		$self->{html_description} = qq{All About人気記事から、今後流行する人気ブームのきざしを先に発見する検索サービス};
		$title = qq{All About人気記事};
	}elsif($type eq 12){
		$self->{html_title} = qq{はてぶ人気エントリー 流行モノ検索プラス};
		$self->{html_keywords} = qq{はてぶ,話題,流行,人気,ブーム,きざし,検索};
		$self->{html_description} = qq{はてぶ人気エントリーから、今後流行する人気ブームのきざしを先に発見する検索サービス};
		$title = qq{はてぶ人気エントリー};
	}elsif($type eq 13){
		$self->{html_title} = qq{R25人気記事 流行モノ検索プラス};
		$self->{html_keywords} = qq{R25,話題,流行,人気,ブーム,きざし,検索};
		$self->{html_description} = qq{R25人気記事から、今後流行する人気ブームのきざしを先に発見する検索サービス};
		$title = qq{R25人気記事};
	}
	
	my $hr = &html_hr($self,1);	
	&html_header($self);

	my $ad = &html_google_ad($self);

&html_table($self, qq{<img src="http://img.waao.jp/lamp1.gif" width=14 height=11><font color="#009525">$title</font>}, 0, 0);
	my $geinou = &html_mojibake_str("geinou");

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
$str
$hr
偂<a href="http://waao.jp/ranking/">みんなのランキング</a><br>
<a href="/" accesskey=0>トップ</a>&gt;<a href="/kizasi/" title="$geinouニュース">$geinouニュース</a>&gt;<strong>$title</strong><br>
<font size=1 color="#AAAAAA">急上昇中の話題ネタやこれからの流行や人気のきざしをいち早く検索できます。<br>
トレンドチェックに役立つ情報を集めたきざし検索専用の情報RSSリーダです。<br>
<a href="http://developer.yahoo.co.jp/about">Webサービス by Yahoo! JAPAN</a><br>
hatena<br>
allabout<br>
</fonnt>
END_OF_HTML

&html_footer($self);

	return;
}
sub pager(){
	use strict;
	my $limit = shift;
	my $page = shift;
	
	my $limit_s = 0;
	if( $page ){
		$limit_s = $limit * $page;
	}
	my $next_page = $page + 1;

	return ($limit_s, $limit, $next_page);
}

1;