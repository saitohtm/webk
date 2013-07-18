package Waao::Pages::Meikan;
use strict;
use base qw(Waao::Pages::Base);
use Waao::Html;
use Waao::Data;
use Waao::Utility;

# /meikan/
# /keyword/meikan/keyword_id/
# /list-50on/meikan/50on/page/

sub dispatch(){
	my $self = shift;

	#ドメイン設定
	if($self->{cgi}->param('q') eq "list-1"){
		# 男性タレント名鑑
		&_meikan_top($self,1,1);
	}elsif($self->{cgi}->param('q') eq "list-2"){
		# 女性タレント名鑑
		&_meikan_top($self,2,1);
	}elsif($self->{cgi}->param('q') eq "list-3"){
		# グラビア名鑑
		&_meikan_top($self,3,0);
	}elsif($self->{cgi}->param('q') eq "list-4"){
		# お笑い名鑑
		&_meikan_top($self,4,1);
	}elsif($self->{cgi}->param('q') eq "list-6"){
		# 子役名鑑
		&_meikan_top($self,6,0);
	}elsif($self->{cgi}->param('q') eq "list-7"){
		# 落語名鑑
		&_meikan_top($self,7,0);
	}elsif($self->{cgi}->param('q') eq "list-8"){
		# 声優名鑑
		&_meikan_top($self,8,0);
	}elsif($self->{cgi}->param('q') eq "list-9"){
		# アーティスト名鑑
		&_meikan_top($self,9,1);
	}elsif($self->{cgi}->param('q') eq "list-10"){
		# アーティスト名鑑
		&_meikan_top($self,10,1);
	}elsif($self->{cgi}->param('q') eq "list-11"){
		# model名鑑
		&_meikan_top($self,11,0);
	}elsif($self->{cgi}->param('q') eq "list-12"){
		# レースクィーン名鑑
		&_meikan_top($self,12,0);
	}elsif($self->{cgi}->param('q') eq "list-13"){
		# 女子アナ名鑑
		&_meikan_top($self,13,0);
	}elsif($self->{cgi}->param('q') eq "list-14"){
		# AV女優名鑑
		&_meikan_top($self,14,1);
	}elsif($self->{cgi}->param('q') eq "list-15"){
		# ブログ名鑑
		&_meikan_top($self,15,0);
	}elsif($self->{cgi}->param('q') eq "list-50on"){
		# 50音検索
		&_50onsearch($self);
	}elsif($self->{cgi}->param('q')){
		# 詳細ページ
		&_person($self);
	}else{
		&_top($self);
	}
	
	return;
}

sub _top(){
	my $self = shift;

	$self->{html_title} = qq{みんなの人物名鑑プラス};
	$self->{html_keywords} = qq{名鑑,検索,人物検索};
	$self->{html_description} = qq{最強の人物検索「みんなの人物名鑑プラス」さまざまなジャンルの人物名鑑がシリーズ化};

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
<center>
<h2><img src="http://img.waao.jp/meikan.gif" width=120 height=28 alt="みんなの人物名鑑"><font size=1 color="#FF0000">プラス</font></h2>
<h2><font size=1>みんなの<font color="#FF0000">人物名鑑</font>プラス</font></h2>
</center>
$hr
<center>
$ad
</center>
$hr
END_OF_HTML


&_seriese_meikan($self);

print << "END_OF_HTML";
$hr
偂<a href="http://waao.jp/list-in/ranking/14/">みんなのランキング</a><br>
<a href="/" accesskey=0 title="みんなのモバイル">トップ</a>&gt;<strong>みんなの人物名鑑プラス</strong><br>
みんなの人物名鑑プラスは、<font color="#FF0000">リンクフリー</font>です。<br>
<textarea>
http://waao.jp/meikan/
</textarea>
<br>
<font size=1 color="#AAAAAA">ジャンル別人物名鑑シリーズ。人物のプロフィールや画像が検索できます</fonnt>
END_OF_HTML

}
	
	&html_footer($self);

	return;
}


# 名鑑top
sub _meikan_top(){
	my $self = shift;
	my $meikantype = shift;
	my $flag50 = shift;
	
	my ($meikanname, $sql_str) = &_meikan_name($meikantype);
	
	$self->{html_title} = qq{$meikanname名鑑 -みんなの人物名鑑プラス-};
	$self->{html_keywords} = qq{$meikanname,名鑑,検索,人物検索};
	$self->{html_description} = qq{最強の$meikanname検索「$meikanname名鑑プラス」なら$meikannameの画像やプロフィール情報が人目でわかる};

	my $slist;
	if($self->{cgi}->param('p1') eq '50on') {
		$slist = &_slist($self, $meikanname,$meikantype);
	}

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
<center>
<h1>$meikanname名鑑</h1>
<h2><font size=1>$meikanname<font color="#FF0000">画像名鑑</font>プラス</font></h2>
</center>
$hr
<center>
$ad
</center>
$hr
$slist
END_OF_HTML

&html_table($self, qq{<img src="http://img.waao.jp/lamp1.gif" width=14 height=11><font color="#009525">人気$meikanname</font>}, 0, 0);

&_top_dsp($self,$sql_str,$meikantype);

if($flag50){
print << "END_OF_HTML";
$hr
<a href="/list-$meikantype/meikan/50on/">50音検索</a>
END_OF_HTML
}

print << "END_OF_HTML";
$hr
END_OF_HTML

&_seriese_meikan($self);

print << "END_OF_HTML";
$hr
偂<a href="http://waao.jp/ranking/">みんなのランキング</a><br>
<a href="/" accesskey=0 title="みんなのモバイル">トップ</a>&gt;<a href="/meikan/" title="みんなの人物名鑑">みんなの人物名鑑プラス</a>&gt;<strong>$meikanname</strong><br>
<font size=1 color="#AAAAAA">$meikanname名鑑 ジャンル別人物名鑑シリーズ。人物のプロフィールや画像が検索できます</fonnt>
END_OF_HTML

}
	
	&html_footer($self);

	return;
}

sub _person(){
	my $self = shift;

	my $keyword = $self->{cgi}->param('q');
	my $keyword_id = $self->{cgi}->param('p1');
	
	my ($datacnt, $keyworddata) = &get_keyword($self, $keyword, $keyword_id);
	# photo データ
	my ($datacnt, $photodata) = &get_photo($self, $keyworddata->{id});

	# 画像
	
	my ($meikan,$meikantype) = &_get_meikan($keyworddata->{person},$keyworddata->{av},$keyworddata->{artist},$keyworddata->{model},$keyworddata->{ana});
	my ($meikanname, $sql_str) = &_meikan_name($meikantype);
	$self->{html_title} = qq{$keyword -$meikan名鑑プラス-};
	$self->{html_keywords} = qq{$keyword,$meikan,名鑑,検索,人物検索};
	my $wikistr;
	if($keyworddata->{simplewiki}){
		my $simplewiki = $keyworddata->{simplewiki};
		$simplewiki=~s/<//g;
		$simplewiki=~s/\/>//g;
		$simplewiki=~s/br//ig;
		$wikistr = substr($simplewiki, 0, 100);
		$wikistr =~s/\?//g;
		$self->{html_description} = qq{$wikistr};
	}else{
		$self->{html_description} = qq{$keyword: $keywordの画像付プロフィールが全て丸分かり! $meikan名鑑プラス};
	}

	my $hr = &html_hr($self,1);	
	&html_header($self);

	my $ad = &html_google_ad($self);

if($wikistr){
print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FF9900">$wikistr.. </font></marquee>
END_OF_HTML
}


&html_table($self, qq{<h1>$keyword</h1><h2><font size=1>$keyword</font><font size=1 color="#FF0000">人物プロフ</font></h2>}, 1, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
<h3>$keywordとは</h3>
END_OF_HTML

&html_keyword_info($self, $keyworddata, $photodata);

if($keyworddata->{simplewiki}){
print << "END_OF_HTML";
<img src="http://img.waao.jp/mb17.gif" width=11 height=12><font size=1 color="#555555">
$keyworddata->{simplewiki}
</font>
END_OF_HTML
}

print << "END_OF_HTML";
$hr
END_OF_HTML

&_meikan_lite($self,$keyworddata);

&html_table($self, qq{<img src="http://img.waao.jp/lamp2.gif" width=14 height=11><font color="#009525">オススメ$meikan</font>}, 0, 0);

my $start = int(rand(100));
	my $sth = $self->{dbi}->prepare(qq{ select id, inital, keyword from keyword where $sql_str order by cnt desc limit $start,20} );
	$sth->execute();
	my $cnt;
	my ($keyword_id, $inital, $keyword);
	while(my @row = $sth->fetchrow_array) {
		($keyword_id, $inital, $keyword) = @row;
		my $keyword_encode = &str_encode($keyword);
print << "END_OF_HTML";
<a href="/$keyword_encode/meikan/$keyword_id/" title="$keyword">$keyword</a> 
END_OF_HTML
	}

print << "END_OF_HTML";
$hr
END_OF_HTML

&_seriese_meikan($self);

print << "END_OF_HTML";
$hr
偂<a href="http://waao.jp/ranking/">みんなのランキング</a><br>
<a href="/" accesskey=0 title="みんなのモバイル">トップ</a>&gt;<a href="/meikan/">みんなの人物名鑑プラス</a>&gt;<a href="/list-$meikantype/meikan/" title="$meikan名鑑プラス">$meikan名鑑プラス</a>&gt;<strong>$keyword</strong><br>
<font size=1 color="#AAAAAA">$keyword名鑑は、$keywordの人気画像付プロフィール、ファンの投稿で作るうわさ、掲示板、ニュースなど$keywordに関連する全ての情報がまとめて検索できます</fonnt>
END_OF_HTML
	
	&html_footer($self);

	return;
}

sub _top_dsp(){
	my $self = shift;
	my $sql_str = shift;
	my $meikantype = shift;
	my $page = 0;
	$page = $self->{cgi}->param('p1') if($self->{cgi}->param('p1'));
	my $start = 0 + $page * 20;

	my $html;
	my $sth = $self->{dbi}->prepare(qq{ select id, inital, keyword from keyword where $sql_str order by cnt desc limit $start,20} );
	$sth->execute();
	my $cnt;
	my ($keyword_id, $inital, $keyword);
	while(my @row = $sth->fetchrow_array) {
		($keyword_id, $inital, $keyword) = @row;
		my $keyword_encode = &str_encode($keyword);
		$cnt++;
		# 最初の2つは、画像を表示する
		$cnt = 0 if($self->{access_type} eq 4);
		if($cnt <= 2 ){
			# 画像の取得
			my $sth2 = $self->{dbi}->prepare(qq{ select id, url from photo where keywordid = ? order by good desc limit 1} );
			$sth2->execute($keyword_id);
			my $photourl;
			while(my @row2 = $sth2->fetchrow_array) {
				$photourl = $row2[1];
			}
			if($photourl){
				$html .= qq{<center><a href="/$keyword_encode/meikan/$keyword_id/" title="$keyword"><img src="$photourl"  width=95  alt="$keywordの画像"><br>};
				$html .= qq{$keyword</a></center>};
			}else{
				$html .= qq{<font color="#009525">》</font><a href="/$keyword_encode/meikan/$keyword_id/" title="$keyword">$keyword</a><br>};
			}
		}else{
			$html .= qq{<font color="#009525">》</font><a href="/$keyword_encode/meikan/$keyword_id/" title="$keyword">$keyword</a><br>};
		}
	}
$page = $page + 1;
print << "END_OF_HTML";
$html
<img src="http://img.waao.jp/m2028.gif" width=48 height=9><a href="/list-$meikantype/meikan/$page/">次へ</a><br>
END_OF_HTML

	return;
}

sub _50onsearch(){
	my $self = shift;
	# p1 : type-50on-pageno
	my @p1 = split(/-/,$self->{cgi}->param('p1'));
	my $meikantype = $p1[0];
	my $inital = $p1[1];
	my $page = $p1[2] if($p1[2]);

	my $start = 0 + $page * 50;
	
	my $ad = &html_google_ad($self);
	my ($meikanname, $sql_str) = &_meikan_name($meikantype);
	
	my $waon = &_get_waon($inital);

	$self->{html_title} = qq{$waon行の$meikanname名鑑  -みんなの人物名鑑プラス-};
	$self->{html_keywords} = qq{$meikanname,名鑑,検索,人物検索,ランキング};
	$self->{html_description} = qq{最強の$meikanname検索「$meikanname名鑑プラス」なら$meikannameの画像やプロフィール情報が人目でわかる};
	my $hr = &html_hr($self,1);	
	&html_header($self);

print << "END_OF_HTML";
<center>
<h2><font size=1>$waon行の$meikanname<font color="#FF0000">画像名鑑</font>プラス</font></h2>
</center>
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

&html_table($self, qq{<img src="http://img.waao.jp/lamp1.gif" width=14 height=11><font color="#009525">$waon行の$meikanname</font>}, 0, 0);

	my $sth = $self->{dbi}->prepare(qq{ select id, keyword from keyword where $sql_str and inital = ? order by cnt desc limit $start, 50} );
	$sth->execute($inital);
	my $cnt;
	my ($keyword_id, $keyword);
	while(my @row = $sth->fetchrow_array) {
		($keyword_id, $keyword) = @row;
		my $keyword_encode = &str_encode($keyword);
print << "END_OF_HTML";
<font color="#009525">》</font><a href="/$keyword_encode/meikan/$keyword_id/" title="$keyword">$keyword</a><br>
END_OF_HTML
		$cnt++;
	}
if($cnt>=50){
	$page = $page + 1;
print << "END_OF_HTML";
<img src="http://img.waao.jp/m2028.gif" width=48 height=9><a href="/list-50on/meikan/$meikantype-$inital-$page/">次へ</a>
$hr
END_OF_HTML
}

print << "END_OF_HTML";
<a href="/list-1/meikan/50on/">50音検索</a>
$hr
END_OF_HTML

&_seriese_meikan($self);

print << "END_OF_HTML";
$hr
偂<a href="http://waao.jp/list-in/ranking/14/">みんなのランキング</a><br>
<a href="/" accesskey=0 title="みんなのモバイル">トップ</a>&gt;<a href="/meikan/">みんなの人物名鑑プラス</a>&gt;<strong>$meikanname名鑑</strong><br>
<font size=1 color="#AAAAAA">$meikanname名鑑:ジャンル別人物名鑑シリーズ。人物のプロフィールや画像が検索できます</fonnt>
END_OF_HTML
	
	&html_footer($self);
	return;
}

sub _seriese_meikan(){
	my $self = shift;

	my $hr = &html_hr($self,1);	

&html_table($self, qq{<img src="http://img.waao.jp/lamp1.gif" width=14 height=11><font color="#009525">人物名鑑シリーズ</font>}, 0, 0);

print << "END_OF_HTML";
$hr
<font color="#009525">■</font><a href="/list-1/meikan/" title="男性タレント名鑑">男性タレント名鑑</a><br>
<font color="#009525">■</font><a href="/list-2/meikan/" title="女性タレント名鑑">女性タレント名鑑</a><br>
<font color="#009525">■</font><a href="/list-3/meikan/" title="グラビアアイドル名鑑">グラビアアイドル名鑑</a><br>
<font color="#009525">■</font><a href="/list-4/meikan/" title="お笑いタレント名鑑">お笑いタレント名鑑</a><br>
<font color="#009525">■</font><a href="/list-6/meikan/" title="子役名鑑">子役名鑑</a><br>
<font color="#009525">■</font><a href="/list-7/meikan/" title="落語家名鑑">落語家名鑑</a><br>
<font color="#009525">■</font><a href="/list-8/meikan/" title="声優名鑑">声優名鑑</a><br>
<font color="#009525">■</font><a href="/list-9/meikan/" title="男性アーティスト名鑑">男性アーティスト名鑑</a><br>
<font color="#009525">■</font><a href="/list-10/meikan/" title="女性アーティスト名鑑">女性アーティスト名鑑</a><br>
<font color="#009525">■</font><a href="/list-11/meikan/" title="モデル名鑑">モデル名鑑</a><br>
<font color="#009525">■</font><a href="/list-12/meikan/" title="レースクィーン名鑑">レースクィーン名鑑</a><br>
<font color="#009525">■</font><a href="/list-13/meikan/" title="女子アナウンサー名鑑">女子アナウンサー名鑑</a><br>
<font color="#009525">■</font><a href="/list-14/meikan/" title="AV女優名鑑">AV女優名鑑</a><br>
<font color="#009525">■</font><a href="/list-15/meikan/" title="ブログ名鑑">ブログ名鑑</a><br>
END_OF_HTML

	return;
}

sub _get_meikan(){
	my $person = shift;
	my $av = shift;
	my $artist = shift;
	my $model = shift;
	my $ana = shift;
	
	my $meikan;
	my $meikantype;
	if($person eq 1){
		$meikan = qq{グラビアアイドル};
		$meikantype = 3;
	}elsif($person eq 2){
		$meikan = qq{女性タレント};
		$meikantype = 2;
	}elsif($person eq 3){
		$meikan = qq{男性タレント};
		$meikantype = 1;
	}elsif($person eq 4){
		$meikan = qq{お笑いタレント};
		$meikantype = 4;
	}elsif($person eq 5){
	}elsif($person eq 6){
		$meikan = qq{子役};
		$meikantype = 6;
	}elsif($person eq 7){
		$meikan = qq{落語家};
		$meikantype = 7;
	}elsif($person eq 8){
		$meikan = qq{声優};
		$meikantype = 8;
	}elsif($artist eq 1){
		$meikan = qq{アーティスト};
		$meikantype = 9;
	}elsif($artist eq 2){
		$meikan = qq{アーティスト};
		$meikantype = 10;
	}elsif($model eq 1){
		$meikan = qq{モデル};
		$meikantype = 11;
	}elsif($model eq 2){
		$meikan = qq{レースクィーン};
		$meikantype = 12;
	}elsif($ana){
		$meikan = qq{女子アナウンサー};
		$meikantype = 13;
	}elsif($av){
		$meikan = qq{AV女優};
		$meikantype = 14;
	}else{
		$meikan = qq{人物};
	}
	
	return ($meikan,$meikantype);
}

sub _slist(){
	my $self = shift;
	my $meikan = shift;
	my $meikantype = shift;
	
	my $slist;
	$slist .= qq{<a href="/list-50on/meikan/$meikantype-a/" title="$meikan あ行">あ</a> };
	$slist .= qq{<a href="/list-50on/meikan/$meikantype-i/" title="$meikan い行">い</a> };
	$slist .= qq{<a href="/list-50on/meikan/$meikantype-u/" title="$meikan う行">う</a> };
	$slist .= qq{<a href="/list-50on/meikan/$meikantype-e/" title="$meikan え行">え</a> };
	$slist .= qq{<a href="/list-50on/meikan/$meikantype-o/" title="$meikan お行">お</a> };
	$slist .= qq{<br>};
	$slist .= qq{<a href="/list-50on/meikan/$meikantype-ka/" title="$meikan か行">か</a> };
	$slist .= qq{<a href="/list-50on/meikan/$meikantype-ki/" title="$meikan き行">き</a> };
	$slist .= qq{<a href="/list-50on/meikan/$meikantype-ku/" title="$meikan く行">く</a> };
	$slist .= qq{<a href="/list-50on/meikan/$meikantype-ke/" title="$meikan け行">け</a> };
	$slist .= qq{<a href="/list-50on/meikan/$meikantype-ko/" title="$meikan こ行">こ</a> };
	$slist .= qq{<br>};
	$slist .= qq{<a href="/list-50on/meikan/$meikantype-sa/" title="$meikan さ行">さ</a> };
	$slist .= qq{<a href="/list-50on/meikan/$meikantype-si/" title="$meikan し行">し</a> };
	$slist .= qq{<a href="/list-50on/meikan/$meikantype-su/" title="$meikan す行">す</a> };
	$slist .= qq{<a href="/list-50on/meikan/$meikantype-se/" title="$meikan せ行">せ</a> };
	$slist .= qq{<a href="/list-50on/meikan/$meikantype-so/" title="$meikan そ行">そ</a> };
	$slist .= qq{<br>};
	$slist .= qq{<a href="/list-50on/meikan/$meikantype-ta/" title="$meikan た行">た</a> };
	$slist .= qq{<a href="/list-50on/meikan/$meikantype-ti/" title="$meikan ち行">ち</a> };
	$slist .= qq{<a href="/list-50on/meikan/$meikantype-tu/" title="$meikan つ行">つ</a> };
	$slist .= qq{<a href="/list-50on/meikan/$meikantype-te/" title="$meikan て行">て</a> };
	$slist .= qq{<a href="/list-50on/meikan/$meikantype-to/" title="$meikan と行">と</a> };
	$slist .= qq{<br>};
	$slist .= qq{<a href="/list-50on/meikan/$meikantype-na/" title="$meikan な行">な</a> };
	$slist .= qq{<a href="/list-50on/meikan/$meikantype-ni/" title="$meikan に行">に</a> };
	$slist .= qq{<a href="/list-50on/meikan/$meikantype-nu/" title="$meikan ぬ行">ぬ</a> };
	$slist .= qq{<a href="/list-50on/meikan/$meikantype-ne/" title="$meikan ね行">ね</a> };
	$slist .= qq{<a href="/list-50on/meikan/$meikantype-no/" title="$meikan の行">の</a> };
	$slist .= qq{<br>};
	$slist .= qq{<a href="/list-50on/meikan/$meikantype-ha/" title="$meikan は行">は</a> };
	$slist .= qq{<a href="/list-50on/meikan/$meikantype-hi/" title="$meikan ま行">ま</a> };
	$slist .= qq{<a href="/list-50on/meikan/$meikantype-hu/" title="$meikan や行">や</a> };
	$slist .= qq{<a href="/list-50on/meikan/$meikantype-he/" title="$meikan ら行">ら</a> };
	$slist .= qq{<a href="/list-50on/meikan/$meikantype-ho/" title="$meikan わ行">わ</a> };
	$slist .= qq{<br>};
	$slist .= qq{<a href="/list-50on/meikan/$meikantype-ma/" title="$meikan ま行">ま</a> };
	$slist .= qq{<a href="/list-50on/meikan/$meikantype-mi/" title="$meikan み行">み</a> };
	$slist .= qq{<a href="/list-50on/meikan/$meikantype-mu/" title="$meikan む行">む</a> };
	$slist .= qq{<a href="/list-50on/meikan/$meikantype-me/" title="$meikan め行">め</a> };
	$slist .= qq{<a href="/list-50on/meikan/$meikantype-mo/" title="$meikan も行">も</a> };
	$slist .= qq{<br>};
	$slist .= qq{<a href="/list-50on/meikan/$meikantype-ya/" title="$meikan や行">や</a> };
	$slist .= qq{<a href="/list-50on/meikan/$meikantype-yu/" title="$meikan ゆ行">ゆ</a> };
	$slist .= qq{<a href="/list-50on/meikan/$meikantype-yo/" title="$meikan よ行">よ</a> };
	$slist .= qq{<br>};
	$slist .= qq{<a href="/list-50on/meikan/$meikantype-ra/" title="$meikan ら行">ら</a> };
	$slist .= qq{<a href="/list-50on/meikan/$meikantype-ri/" title="$meikan り行">り</a> };
	$slist .= qq{<a href="/list-50on/meikan/$meikantype-ru/" title="$meikan る行">る</a> };
	$slist .= qq{<a href="/list-50on/meikan/$meikantype-re/" title="$meikan れ行">れ</a> };
	$slist .= qq{<a href="/list-50on/meikan/$meikantype-ro/" title="$meikan ろ行">ろ</a> };

	$slist .= qq{<a href="/list-50on/meikan/$meikantype-wa/" title="$meikan わ行">わ</a> };

	return $slist;
}

sub _get_waon(){
	my $inital = shift;
	my $waon;
	$waon->{a} = "あ";
	$waon->{i} = "い";
	$waon->{u} = "う";
	$waon->{e} = "え";
	$waon->{o} = "お";

	$waon->{ka} = "か";
	$waon->{ki} = "き";
	$waon->{ku} = "く";
	$waon->{ke} = "け";
	$waon->{ko} = "こ";

	$waon->{sa} = "さ";
	$waon->{si} = "し";
	$waon->{su} = "す";
	$waon->{se} = "せ";
	$waon->{so} = "そ";

	$waon->{ta} = "た";
	$waon->{ti} = "ち";
	$waon->{tu} = "つ";
	$waon->{te} = "て";
	$waon->{to} = "と";

	$waon->{na} = "な";
	$waon->{ni} = "に";
	$waon->{nu} = "ぬ";
	$waon->{ne} = "ね";
	$waon->{no} = "の";

	$waon->{ha} = "は";
	$waon->{hi} = "ひ";
	$waon->{hu} = "ふ";
	$waon->{he} = "へ";
	$waon->{ho} = "ほ";

	$waon->{ma} = "ま";
	$waon->{mi} = "み";
	$waon->{mu} = "む";
	$waon->{me} = "め";
	$waon->{mo} = "も";

	$waon->{ya} = "や";
	$waon->{yi} = "";
	$waon->{yu} = "ゆ";
	$waon->{ye} = "";
	$waon->{yo} = "よ";

	$waon->{ra} = "ら";
	$waon->{ri} = "り";
	$waon->{ru} = "る";
	$waon->{re} = "れ";
	$waon->{ro} = "ろ";

	$waon->{wa} = "わ";

	return $waon->{$inital};
}

sub _meikan_name(){
	my $meikantype = shift;
	
	my $meikanname;
	my $sql_str;
	$meikanname->{1} = qq{男性タレント};
	$sql_str->{1} = qq{ person = 3 };
	$meikanname->{2} = qq{女性タレント};
	$sql_str->{2} = qq{ person = 2 };
	$meikanname->{3} = qq{グラビアアイドル};
	$sql_str->{3} = qq{ person = 1 };
	$meikanname->{4} = qq{お笑いタレント};
	$sql_str->{4} = qq{ person = 4 };
	$meikanname->{6} = qq{子役};
	$sql_str->{6} = qq{ person = 6 };
	$meikanname->{7} = qq{落語家};
	$sql_str->{7} = qq{ person = 7 };
	$meikanname->{8} = qq{声優};
	$sql_str->{8} = qq{ person = 8 };
	$meikanname->{9} = qq{男性アーティスト};
	$sql_str->{9} = qq{ artist = 1 and sex = 1 };
	$meikanname->{10} = qq{女性アーティスト};
	$sql_str->{10} = qq{ artist = 1 and sex = 2 };
	$meikanname->{11} = qq{モデル};
	$sql_str->{11} = qq{ model = 1 };
	$meikanname->{12} = qq{レースクィーン};
	$sql_str->{12} = qq{ model = 2 };
	$meikanname->{13} = qq{女子アナウンサー};
	$sql_str->{13} = qq{ ana is not null };
	$meikanname->{14} = qq{AV女優};
	$sql_str->{14} = qq{ av = 1 };
	$meikanname->{15} = qq{ブログ};
	$sql_str->{15} = qq{ blogurl is not null };


	return ($meikanname->{$meikantype}, $sql_str->{$meikantype});
}

sub _meikan_lite(){
	my $self = shift;
	my $keyworddata = shift;
	my $filepath;
	my $keyword = $keyworddata->{keyword};
	if($keyworddata->{av}){
		my $keyword_id = $keyworddata->{id};
		my $inital = $keyworddata->{inital};
		my $dir = int($keyword_id / 1000);
		my $file = $keyword_id % 1000;
		$filepath = qq{http://av.goo.to/$inital/$keyword_id/};

	}elsif($keyworddata->{artist}){
		my $keyword_id = $keyworddata->{id};
		my $inital = $keyworddata->{inital};
		my $dir = int($keyword_id / 1000);
		my $file = $keyword_id % 1000;
		$filepath = qq{http://artist.goo.to/$inital/$keyword_id/};

	}elsif($keyworddata->{ana}){
		my $keyword_id = $keyworddata->{id};
		my $inital = $keyworddata->{inital};
		my $dir = int($keyword_id / 1000);
		my $file = $keyword_id % 1000;
		$filepath = qq{http://ana.goo.to/$dir/$keyword_id/};
	}elsif($keyworddata->{person} eq 1){
		my $keyword_id = $keyworddata->{id};
		my $dir = int($keyword_id / 1000);
		my $file = $keyword_id % 1000;
		$filepath = qq{http://idol.goo.to/$dir/$keyword_id/};
	}
	
	if($filepath){
print << "END_OF_HTML";
サクサク丨<br>
<a href="$filepath" title="$keyword ">$keyword 焚祝澎爪版</a><br>
END_OF_HTML
	}
	return;
}
1;