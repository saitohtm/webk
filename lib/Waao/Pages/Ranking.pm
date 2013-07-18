package Waao::Pages::Ranking;
use strict;
use base qw(Waao::Pages::Base);
use Waao::Html;
use Waao::Utility;
use Waao::Data;

#/waao.jp/ranking/
#/waao.jp/list-rank-id/ranking/pageno/
#/waao.jp/list-out-id/ranking/
#/waao.jp/list-dsp-id/ranking/
#/waao.jp/list-regist/ranking/
#/waao.jp/list-in-id/ranking/

sub dispatch(){
	my $self = shift;
	
	if($self->{cgi}->param('q') =~/list-rank/){
		&_rank_detail($self);
	}elsif($self->{cgi}->param('q') =~/list-out/){
		&_rank_out($self);
	}elsif($self->{cgi}->param('q') =~/list-in/){
		&_top($self);
	}elsif($self->{cgi}->param('q') =~/list-dsp/){
		&_rank_dsp($self);
	}elsif($self->{cgi}->param('q') =~/list-regist/){
		&_rank_regist($self);
	}elsif( $self->{cgi}->param('action') eq 'entry' ){
		&_ranking_entry( $self );
	}elsif($self->{cgi}->param('q')){
		&_person_top($self);
	}else{
		&_top($self);
	}
	if($self->{cgi}->param('q') =~/list-in/){
		&_rank_in($self);
	}
	
	return;
	
}

sub _top(){
	my $self = shift;
	
    $self->{html_title} = qq{携帯ランキング みんなのランキング};
    $self->{html_keywords} = qq{アクセスアップ,ランキング,携帯,アクセスアップ,SEO,比較};
    $self->{html_description} = qq{SEO対策万全の携帯サイトランキング。アクセス数が劇的にアップするみんなのランキング};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);
	my $sc = &_get_site_cnt( $self );
	my ($today,$yesterday) = &_get_pv( $self );

	my $categorylist = &_get_category_list( $self );

if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML
	
}else{
# xhmlt chtml

print << "END_OF_HTML";
<center>
<img src="http://img.waao.jp/rankinglogo.gif" width=120 height=28 alt="携帯ランキング"><font size=1 color="#FF0000">プラス</font>
</center>
END_OF_HTML


	&html_table($self, qq{<h2><font size=1 color="#FF0000">SEO対策済 無料携帯ランキング</font></h2>}, 1, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
<center><font color="#FF0000">$sc</font><font color="blue">サイト参加中!</font></center>
<font size=1><center>今日$today/昨日$yesterday</center></font>
$hr
<center>
<a href="http://ranking.waao.jp/">
毎日更新タレント<br>
偂ランキング
</a>
</center>
$hr
<font size=1>
$categorylist
</font>
$hr
⇒<a href="/list-regist/ranking/">サイト登録</a><br>
坙<a href="/accessup/">鍔岬憾汁⒜灼</a><br>
$hr
<a href="/" accesskey=0>トップ</a>&gt;<strong>みんなのランキング</strong><br>
<a href="http://ranking.goo.to/">みんなのランキングクラシック</a><br>
<font size=1>
みんなのランキングハは、SEO対策済みの携帯専用ランキングデスサイトです。無料で使えてアクセス数アップすることができます。<br>
END_OF_HTML
}
	
	&html_footer($self);
	
	return;
}

sub _get_category_list(){
	my $self = shift;

	my $categorylist;
	# サイト管理
	# 通常
	my $sth = $self->{dbi}->prepare( qq{select * from r_category where ad_flag = 0 order by adult_flag, order_flag, id } );
	$sth->execute();
	my $flag;
	while( my @row = $sth->fetchrow_array ) {
		if( !$flag && $row[3] ){
			# 夜だけ表示
			my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
			last if( $hour =~/8|9|10|11|12|13|14|15|16|17|18|19|20/ );
			$flag = 1;
			$categorylist .= qq{<br>▼<font color=red>大人メニュー</font>▼<br>};
		}
		$categorylist .= qq{$row[1]<a href="/list-rank-$row[0]/ranking/">$row[2]</a>($row[5])<br>};
	}

	return $categorylist;
}
sub _person_top(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('q');
	my ($datacnt, $keyworddata) = &get_keyword($self, $keyword);
	my ($datacnt, $photodata) = &get_photo($self, $keyworddata->{id});
	$self->{html_title} = qq{$keywordランキング みんなのランキング};
	$self->{html_keywords} = qq{$keyword,ランキング,人気,比較,評価};
	$self->{html_description} = qq{$keywordランキングなら$keywordランキングの人気情報がすぐに分かる};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad = &html_google_ad($self);
	my $sc = &_get_site_cnt( $self );
	my ($today,$yesterday) = &_get_pv( $self );

	my $categorylist = &_get_category_list( $self );

if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML
	
}else{
# xhmlt chtml

print << "END_OF_HTML";
<center>
<img src="http://img.waao.jp/rankinglogo.gif" width=120 height=28 alt="$keywordランキング"><font size=1 color="#FF0000">プラス</font>
</center>
END_OF_HTML


	&html_table($self, qq{<h2><font size=1 color="#FF0000">$keywordランキング</font></h2>}, 1, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
<center>
<a href="http://ranking.waao.jp/">
毎日更新タレント<br>
偂ランキング
</a>
</center>
$hr
END_OF_HTML

&html_keyword_info($self, $keyworddata, $photodata);

print << "END_OF_HTML";
$hr
<center><font color="#FF0000">$sc</font><font color="blue">サイト参加中!</font></center>
<font size=1><center>今日$today/昨日$yesterday</center></font>
$hr
<font size=1>
$categorylist
</font>
$hr
⇒<a href="/list-regist/ranking/">サイト登録</a><br>
坙<a href="/accessup/">鍔岬憾汁⒜灼</a><br>
$hr
<a href="/" accesskey=0>トップ</a>&gt;<strong>みんなのランキング</strong><br>
<a href="http://ranking.goo.to/">みんなのランキングクラシック</a><br>
<font size=1>
$keywordランキングハは、SEO対策済みの携帯専用ランキングデスサイトです。無料で使えてアクセス数アップすることができます。<br>
END_OF_HTML
}
	
	&html_footer($self);
	
	return;
}

sub _get_category_list(){
	my $self = shift;

	my $categorylist;
	# サイト管理
	# 通常
	my $sth = $self->{dbi}->prepare( qq{select * from r_category where ad_flag = 0 order by adult_flag, order_flag, id } );
	$sth->execute();
	my $flag;
	while( my @row = $sth->fetchrow_array ) {
		if( !$flag && $row[3] ){
			# 夜だけ表示
			my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
			last if( $hour =~/8|9|10|11|12|13|14|15|16|17|18|19|20/ );
			$flag = 1;
			$categorylist .= qq{<br>▼<font color=red>大人メニュー</font>▼<br>};
		}
		$categorylist .= qq{$row[1]<a href="/list-rank-$row[0]/ranking/">$row[2]</a>($row[5])<br>};
	}

	return $categorylist;
}

# サイト登録数
sub _get_site_cnt(){
	my $self = shift;
	my $site_cnt = 0;

	my $sth = $self->{dbi}->prepare(qq{select count(*) from r_ranking });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$site_cnt = $row[0];
	}

	return $site_cnt;
}

# ページビュー
sub _get_pv(){
	my $self = shift;
	
	my $today;
	my $yesterday;

	# memcache で実装
	# id:1 today{pv,date}
	# id:2 yesterday{pv,date}
	$today->{date} = $self->{date_yyyy_mm_dd};

	my $today_mem = $self->{mem}->get( 'r_pv1' );
	my $yesterday_mem = $self->{mem}->get( 'r_pv2' );

	if($today->{date} eq $today_mem->{date}){
		$today->{pv} = $today_mem->{pv} + 1;
		$yesterday = $yesterday_mem;
	}else{
		$today->{pv} = 1;
		$yesterday = $today_mem;
	}

	$self->{mem}->set( 'r_pv1', $today );
	$self->{mem}->set( 'r_pv2', $yesterday );
	
	$today->{pv} = "32545" unless($today->{pv});
	$yesterday->{pv} = "32545" unless($yesterday->{pv});
	return ($today->{pv}, $yesterday->{pv});
}

sub _rank_detail(){
	my $self = shift;
	my @ids = split(/-/, $self->{cgi}->param('q'));
	my $category_id = $ids[2];
	my $page = $self->{cgi}->param('p1');

	# ページ制御
	my $limit_s = 0;
	my $limit = 10;
	if( $page ){
		$limit_s = $limit * $page;
	}
	my $next_cnt = $self->{cgi}->param('maxlist') + 1;
	my $next_str = qq{<a href="/}.$self->{cgi}->param('q').qq{/ranking/$next_cnt/">次へ</a><br>};

	my $sort = qq{ incnt desc };
	my $list_str;
	my $counter;

	my $hr = &html_hr($self,1);	

	#　選択
#	my $sth = $self->{dbi}->prepare(qq{select * from r_ranking where category_id  = ? and incnt >= 1 order by $sort limit $limit_s, $limit});
	my $sth = $self->{dbi}->prepare(qq{select * from r_ranking where category_id  = ? order by $sort limit $limit_s, $limit});
	$sth->execute( $category_id );
	while(my @row = $sth->fetchrow_array) {
		$counter++;
		$list_str .= qq{<font color="blue">$counter位</font>$row[15]/$row[16]<br>};
		if($self->{real_mobile}){
			$list_str .= qq{<a href="/list-out-$row[0]/ranking/">$row[3]</a><br>};
		}else{
			# SEO対策ページへ
			$list_str .= qq{<a href="/list-dsp-$row[0]/ranking/">$row[3]</a><br>};
		}
		$list_str .= qq{<font size=1>};
		$list_str .= qq{<font color="#555555">$row[5]</font><br>};
		$list_str .= qq{Tag:} if($row[10]|$row[11]|$row[12]|$row[13]|$row[14]);
		for(my $j=10; $j<=14; $j++){
			if( $row[$j] ){
				my $e_key = &str_encode($row[$j]);
				$list_str .= qq{<a href="/$e_key/search/"><font color="#333333">$row[$j]</font></a> };
			}
		}
		$list_str .= qq{</font>};
		$list_str .= qq{$hr};
	}
	unless($counter){
		$list_str = qq{登録サイトはありません。<br>今がチャンスです<br>};
	}
	
	my $category_name;
	my $category_name2;
	my $category_cnt;
	my $adult_flag;
	# カテゴリ情報
	$sth = $self->{dbi}->prepare(qq{select * from r_category where  id = ? });
	$sth->execute($category_id);
	while(my @row = $sth->fetchrow_array) {
		$category_name = "$row[1]$row[2]";
		$category_name2 = "$row[2]";
		$category_cnt = $row[5];
		$adult_flag = $row[3];
	}

	my $pager;
	if($counter >= $limit){
		$pager = q{<br><div align="right">}.$next_str.q{</div>};
	}

   $self->{html_title} = qq{$category_name -携帯ランキング-};
   $self->{html_keywords} = qq{$category_name,アクセスアップ,ランキング,携帯,SEO,比較};
   $self->{html_description} = qq{$category_name SEO対策万全の携帯サイトランキング。アクセス数が劇的にアップするみんなのランキング};

	&html_header($self);
	my $ad = &html_google_ad($self);

	&html_table($self, qq{<h1>$category_name</h1><h2><font size=1 color="#FF0000">登録:<font size=1 color="blue">$category_cntサイト</font>
</font></h2>}, 1, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
$list_str
$pager
$hr
<center>
<a href="http://ranking.waao.jp/">
毎日更新タレント<br>
偂ランキング
</a>
</center>
$hr
偂<a href="/ranking/">みんなの携帯ランキング</a><br>
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/ranking/">みんなの携帯ランキング</a>&gt;<strong>$category_name</strong><br>
<font size=1>
みんなのランキングハは、SEO対策済みの携帯専用ランキングデスサイトです。無料で使えてアクセス数アップすることができます。<br>
END_OF_HTML

	&html_footer($self);
	
	return;
}

sub _rank_out(){
	my $self = shift;
	my @ids = split(/-/, $self->{cgi}->param('q'));
	my $site_id = $ids[2];

	my $url;
	
	my $sth = $self->{dbi}->prepare(qq{select * from r_ranking where id = ? limit 1});
	$sth->execute($site_id);
	while(my @row = $sth->fetchrow_array) {
		$url = $row[4];
	}

	$sth = $self->{dbi}->prepare(qq{update r_ranking set outcnt = outcnt + 1 where id = ? } );
	$sth->execute($site_id);

	print qq{Location: $url \n\n}; 
	
	return;
}

sub _rank_dsp(){
	my $self = shift;
	my @ids = split(/-/, $self->{cgi}->param('q'));
	my $site_id = $ids[2];

	my ($url,$sitename,$comment);
	
	my $sth = $self->{dbi}->prepare(qq{select siteurl,sitename,comment from r_ranking where id = ? limit 1});
	$sth->execute($site_id);
	while(my @row = $sth->fetchrow_array) {
		($url,$sitename,$comment) = @row;
	}

	$sth = $self->{dbi}->prepare(qq{update r_ranking set outcnt = outcnt + 1 where id = ? } );
	$sth->execute($site_id);

   $self->{html_title} = qq{$sitename -みんなの携帯ランキング-};
   $self->{html_keywords} = qq{アクセスアップ,ランキング,携帯,アクセスアップ,SEO,比較};
   $self->{html_description} = qq{$sitename: $comment};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	
	&html_table($self, qq{<h1>$sitename</h1>}, 1, 0);

print << "END_OF_HTML";
$hr
$comment
$hr
坙<a href="/accessup/">鍔岬憾汁⒜灼</a><br>
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/ranking/">みんなの携帯ランキング</a>&gt;<strong>$sitename</strong><br>
<font size=1>
みんなのランキングハは、SEO対策済みの携帯専用ランキングデスサイトです。無料で使えてアクセス数アップすることができます。<br>
END_OF_HTML

	&html_footer($self);

	return;
}

sub _rank_regist(){
	my $self = shift;

   $self->{html_title} = qq{携帯ランキング みんなのランキング};
   $self->{html_keywords} = qq{アクセスアップ,ランキング,携帯,アクセスアップ,SEO,比較};
   $self->{html_description} = qq{SEO対策万全の携帯サイトランキング。アクセス数が劇的にアップするみんなのランキング};

	my $hr = &html_hr($self,1);	
	&html_header($self);

	my $select_category = &_get_select_category( $self );
&html_table($self, qq{[<font color="red">無料</font>]サイト登録}, 1, 0);
print << "END_OF_HTML";
$hr
<form name="form" action="ranking.html" method="post">
<font color=#009525>■</font>ID[半角英数4-16字]<BR>
<input type="text" name="id" maxlength="16" istyle="3" size="22"><BR>
<BR>
<font color=#009525>■</font>パスワード<BR>[半角英数4-16字]<BR>
<input type="text" name="pass" maxlength="16" istyle="4" size="22"><BR>
<BR>
<font color=#009525>■</font>サイト名[全角30字内]<BR>
<input type="text" name="site" maxlength="30" size="22"><BR>
<BR>
<font color=#009525>■</font>サイトURL<BR>
<input type="text" name="url" value="http://" istyle="3" MAXLENGTH="100" size="22"><BR>
<BR>
<font color=#009525>■</font>紹介文[全角100]<BR>
<input type="text" name="comment" value="" MAXLENGTH="100" size="44"><BR>
<BR>
<font color=#009525>■</font>カテゴリ<BR>
$select_category
<BR>
<font color=#009525>■</font>検索キーワード[自由]<BR>
<font size=1>
<font color="red">※</font>サイトの内容にあった検索用のキーワードを入力してください。</font><BR>
<input type="text" name="key1" maxlength="30" size="22"><BR>
<input type="text" name="key2" maxlength="30" size="22"><BR>
<input type="text" name="key3" maxlength="30" size="22"><BR>
<input type="text" name="key4" maxlength="30" size="22"><BR>
<input type="text" name="key5" maxlength="30" size="22"><BR>
<BR>
<font color=#009525>■</font>メールアドレス<BR>
<input type="text" name="email" maxlength="64" istyle="3" size="22"><BR>
<input name="guid" value="on" type="hidden" />
<BR>
<a href="/kiyaku/">規約</a>に同意する
<BR><BR>
<input type="hidden" name="action" value="entry">
<input type="submit" value=" 新規登録 ">
</form>
END_OF_HTML
	&html_footer($self);

	return;
}

sub _ranking_entry(){
	my $self = shift;
	my $siteid;
	
	return &err_dsp($self, "001") if( &lengthcheck($self->{cgi}->param('id'),4,16) );
	return &err_dsp($self, "002") if(&lengthcheck($self->{cgi}->param('pass'),4,16));
	return &err_dsp($self, "003") if(&lengthcheck($self->{cgi}->param('site'),1,60));
	return &err_dsp($self, "004") unless($self->{cgi}->param('comment'));
	return &err_dsp($self, "007") if(&lengthcheck($self->{cgi}->param('email'),1,64));

	# URL check
	return &err_dsp($self, "003") if(&urlcheck($self->{cgi}->param('url')));
	
	# email check
	return &err_dsp($self, "007") if(&mailcheck($self->{cgi}->param('email')));
		
	#　選択
	my $encodepass = &encodestr($self->{cgi}->param('pass'), $self->{cgi}->param('id'));

	my $sth = $self->{dbi}->prepare(qq{select * from r_ranking where siteid = ? and pass = ? limit 1});
	$sth->execute( $self->{cgi}->param('id'), $encodepass );
	my $idcnt;
	while(my @row = $sth->fetchrow_array) {
		$idcnt++;
	}
	# ID+パスワードでユニーク
	if($idcnt){
		return &err_dsp($self, "005");
	}else{
		# 登録
        $sth = $self->{dbi}->prepare(qq{insert into r_ranking ( `siteid`,
                                                                `pass`,
                                                                `sitename`,
                                                                `siteurl`,
                                                                `comment`,
                                                                `category_id`,
                                                                `key1`,
                                                                `key2`,
                                                                `key3`,
                                                                `key4`,
                                                                `key5`,
                                                                `mail`,
                                                                `ip` )  
                                         values (?,?,?,?,?,?,?,?,?,?,?,?,?)});
		$sth->execute($self->{cgi}->param('id'),
		              $encodepass,
		              &input_str( $self->{cgi}->param('site') ),
		              &input_str( $self->{cgi}->param('url') ),
		              &input_str( $self->{cgi}->param('comment') ),
		              $self->{cgi}->param('categoryid'),
		              &input_str( $self->{cgi}->param('key1') ),
		              &input_str( $self->{cgi}->param('key2') ),
		              &input_str( $self->{cgi}->param('key3') ),
		              &input_str( $self->{cgi}->param('key4') ),
		              &input_str( $self->{cgi}->param('key5') ),
		              $self->{cgi}->param('email'),
		              $self->{session}->{_data}->{mid});

		$siteid = $self->{dbi}->{q{mysql_insertid}};

		$sth = $self->{dbi}->prepare(qq{update r_category set cnt = cnt + 1 where id = ? } );
		$sth->execute( $self->{cgi}->param('categoryid') );

	}

	# PC登録の場合、情報を表示
	my $pcdsp;
	unless( $self->{real_mobile} ){
		$pcdsp .= qq{不正防止のため、登録者情報を記録させていただきます<br>};
		$pcdsp .= $ENV{'REMOTE_ADDR'}."<br>";
		$pcdsp .= $ENV{'REMOTE_HOST'}."<br>";
	}
	
   $self->{html_title} = qq{-携帯ランキング-};
   $self->{html_keywords} = qq{アクセスアップ,ランキング,携帯,SEO,比較};
   $self->{html_description} = qq{SEO対策万全の携帯サイトランキング。アクセス数が劇的にアップするみんなのランキング};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	&html_table($self, qq{登録完了}, 1, 0);

print << "END_OF_HTML";
$hr
$pcdsp
<br>
<font color="blue">登録ありがとうございました</font><blink>炻</blink><br>
<font size=1>
下のリンクタグを必ずサイトに掲載してください。<br>
<font color="red">掲載が確認できない場合は、削除させていただきます。</font></font><br>
<form action="" method="post" wrap="VIRTUAL" name="dummy">
<textarea name="text" rows="3" cols="50">&lt;a href="http://waao.jp/list-in/ranking/$siteid/"&gt;みんなのランキング&lt;/a&gt;</textarea>
</form><br>
$hr
⇒<a href="/list-regist/ranking/">サイト登録</a><br>
 <a href="/accessup/">トラフィックエクスチェンジ</a><br>
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/ranking/">みんなの携帯ランキング</a>&gt;<strong>サイト登録</strong><br>
<font size=1>
みんなのランキングハは、SEO対策済みの携帯専用ランキングデスサイトです。無料で使えてアクセス数アップすることができます。<br>
END_OF_HTML

	&html_footer($self);

	return;
}

# エラー表示
sub err_dsp(){
	use strict;

	my $self = shift;
	my $err_code = shift;

	my $errstr;
	if($err_code eq '001'){
		$errstr = q{id入力に不備があります。};
	}elsif($err_code eq '002'){
	    $errstr = q{パスワード入力に不備があります。};
	}elsif($err_code eq '003'){
		$errstr = q{サイト情報入力に不備があります。};
	}elsif($err_code eq '004'){
	    $errstr = q{コメント情報入力に不備があります。};
	}elsif($err_code eq '005'){
	    $errstr = q{そのidは既に登録されています。別のidを入力してください。};
	}elsif($err_code eq '006'){
	    $errstr = q{サイトが見つかりませんでした。ID/PASSをご確認ください。};
	}elsif($err_code eq '007'){
	    $errstr = q{メールアドレス情報入力に不備があります。};
	}elsif($err_code eq '008'){
	    $errstr = q{タイトル入力に不備があります。};
	}elsif($err_code eq '009'){
	    $errstr = q{画像に不備があります。};
	}elsif($err_code eq '100'){
	    $errstr = q{タイムアウトしました。再度ログインしてください。};
	}

   $self->{html_title} = qq{携帯ランキング みんなのランキング};
   $self->{html_keywords} = qq{アクセスアップ,ランキング,携帯,アクセスアップ,SEO,比較};
   $self->{html_description} = qq{SEO対策万全の携帯サイトランキング。アクセス数が劇的にアップするみんなのランキング};
	
	my $hr = &html_hr($self,1);	
	&html_header($self);

	&html_table($self, qq{エラー}, 1, 0);

print << "END_OF_HTML";
$hr
$errstr
<br>
<font color="blue" size=1>
※バックキーでお戻りください。
</font>
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/ranking/">みんなの携帯ランキング</a>&gt;<strong>みんなのランキング</strong><br>
<font size=1>
みんなのランキングハは、SEO対策済みの携帯専用ランキングデスサイトです。無料で使えてアクセス数アップすることができます。<br>
END_OF_HTML
	&html_footer($self);

	return;
}

sub _rank_in(){
	my $self = shift;
	
	# 携帯以外ノーカウント
	return unless( $self->{real_mobile} );
	
	# 不正対策
	my $memkey = $self->{cgi}->param('p1');
	my $checkstr = $ENV{'HTTP_USER_AGENT'};
	if( $ENV{'REMOTE_HOST'} =~/docomo/i ){
		$memkey .= $self->{session}->{_session_id};
	}elsif( $ENV{'REMOTE_HOST'} =~/ezweb/i ){
		$memkey .= "ezweb";
		$checkstr = $self->{session}->{_session_id};
	}elsif( $ENV{'REMOTE_HOST'} =~/voda|softbank/i ){
		$memkey .= "softbank";
		$checkstr = $self->{session}->{_session_id};
	}
	return unless( $checkstr );

	my $befor_access = $self->{mem}->get( $memkey );
	if($befor_access ne $checkstr){
   		my $sth = $self->{dbi}->prepare(qq{update r_ranking set incnt = incnt + 1 where id = ? } );
    	$sth->execute( $self->{cgi}->param('p1'));
	}

	$self->{mem}->set( $memkey, $checkstr );
	return;
}

sub _get_select_category(){
	my $self = shift;
	my $selectno = shift;	

	# カテゴリ
	my $category_str = qq{<select name="categoryid">};

	# データ取得
	my $sth = $self->{dbi}->prepare(qq{select * from r_category order by adult_flag, order_flag, id });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		my $selectstr;
		$selectstr = qq{selected} if($row[0] eq $selectno);
		$category_str .= qq{<option label="$row[2]" value=$row[0] $selectstr>$row[2]</option>};
	}
	$category_str .= qq{</select><br>};

	return $category_str;
}

1;