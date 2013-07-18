package Waao::Pages::Uwasa;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Data;
use Waao::Html;
use Waao::Utility;

# /keyword/uwasa/  top
# /keyword/uwasa/id uwasa 詳細
# /keyword/uwasa/list/pageno/
# /keyword/uwasa/add/ 投稿
sub dispatch(){
	my $self = shift;

	if($self->{cgi}->param('p1') eq 'list'){
		&_list($self);
	}elsif($self->{cgi}->param('p1') eq 'good'){
		&_eva($self);
	}elsif($self->{cgi}->param('p1') eq 'bad'){
		&_eva($self);
	}elsif($self->{cgi}->param('p1') eq 'add'){
		&_no_family($self);
	}elsif($self->{cgi}->param('p1')){
		&_detail($self);
	}elsif($self->{cgi}->param('keyperson')){
		&_uwasa_input($self);
	}else{
		&_list($self);
	}
	return;
}

sub _list(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('q');
	my $keyword_encode = &str_encode($keyword);
	my $pageno = 0;
	$pageno = $self->{cgi}->param('p2') if($self->{cgi}->param('p2'));

	my ($datacnt, $keyworddata) = &get_keyword($self, $keyword);
	# データが検索できない場合
	unless($datacnt){
		$self->{no_keyword} = 1;
		return;
	}
	# 画像データ
	my ($photodatacnt, $photodata) = &get_photo($self, $keyworddata->{id});

	if($keyworddata->{person}){
		$self->{html_title} = qq{$keywordのうわさで作る恋愛マップ};
	}else{
		$self->{html_title} = qq{$keywordのうわさ -みんなのうわさプラス-};
	}
	$self->{html_keywords} = qq{$keyword,うわさ,恋愛,熱愛,恋};
	$self->{html_description} = qq{$keywordのうわさ。口コミのうわさで作る$keywordのうわさ情報};
	my $hr = &html_hr($self,1);	

	my $ad = &html_google_ad($self);

	my $simplewiki = &simple_wiki_upd($keyworddata->{simplewiki}, 128) if($keyworddata->{simplewiki});

	# うわさ情報
	# ページ制御
	my $limit_s = 0;
	my $limit = 10;
	if( $pageno ){
		$limit_s = $limit * $pageno;
	}

	my $persons_str;
	my $sth = $self->{dbi}->prepare(qq{ select id, keyperson, type,	point, keypersonid from keyword_recomend where keyword = ? and point >= -10 order by point desc limit $limit_s, $limit} );
	$sth->execute( $keyword );
	my $recordcnt;
	while(my @row = $sth->fetchrow_array) {
		$recordcnt++;
		my $keyperson_encode = &str_encode($row[1]);
		if($row[4]){
			$persons_str.=qq{<a href="/$keyperson_encode/search/$row[4]/">$row[1]</a>};
		}else{
			$persons_str.=qq{<a href="/$keyperson_encode/search/">$row[1]</a>};
		}
		$persons_str.=qq{と恋人<br>} if($row[2] eq 1);
		$persons_str.=qq{と元恋人<br>} if($row[2] eq 2);
		$persons_str.=qq{と夫婦<br>} if($row[2] eq 3);
		$persons_str.=qq{と友人<br>} if($row[2] eq 4);
		$persons_str.=qq{が好き<br>} if($row[2] eq 5);
		$persons_str.=qq{が嫌い<br>} if($row[2] eq 6);
		$persons_str.=qq{とメル友倞<br>} if($row[2] eq 7);
		$persons_str.=qq{と親子<br>} if($row[2] eq 8);
		$persons_str.=qq{と兄弟/姉妹<br>} if($row[2] eq 9);
		$persons_str.=qq{と共演者<br>} if($row[2] eq 10);
		$persons_str.=qq{と同郷<br>} if($row[2] eq 11);
		$persons_str.=qq{と同じ事務所<br>} if($row[2] eq 12);
		$persons_str.=qq{と元夫婦<br>} if($row[2] eq 13);
		$persons_str.=qq{とライバル<br>} if($row[2] eq 14);
		$persons_str.=qq{と同年代<br>} if($row[2] eq 15);
		$persons_str.=qq{<div align=right><font size=1>うわさ度 <font color="red">$row[3]</font>炻</font></div>};
		$persons_str.=qq{<a href="/$keyword_encode/uwasa/$row[0]/">$keywordのうわさ</a>} unless($self->{real_mobile});
		$persons_str.=qq{<center><font size=1><font color="#00968c">みんなで投票</font> ⇒　<a href="/$keyword_encode/uwasa/good/$row[0]/">ホント</a>!<a href="/$keyword_encode/uwasa/bad/$row[0]/">うそ</a>!</font></center>$hr};
	}

	unless( $recordcnt ){
		&_no_family( $self );
		return;
	}

	my $next_page = $pageno + 1;
	my $next_str = qq{<img src="http://img.waao.jp/m2028.gif" width=48 height=9><a href="/$keyword_encode/uwasa/list/$next_page/" accesskey="#">次へ</a>(#)<br>};

	&html_header($self);

if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML

}else{# xhmlt chtml

if($simplewiki){

print << "END_OF_HTML";
<marquee bgcolor="black" loop="INFINITY"><font color="#FF9900">$simplewiki </font></marquee>
END_OF_HTML

}

&html_table($self, qq{<h1>$keyword</h1><h2><font size=1 color="#00968c">$keywordの</font><font size=1 color="#FF0000">うわさ</font>}, 1, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
$persons_str
$next_str
<img src="http://img.waao.jp/kya-.gif" width=15 height=15><a href="/$keyword_encode/uwasa/add/">うわさを投稿する</a>
$hr
END_OF_HTML

&html_table($self, qq{<font color="#00968c">$keywordの検索</font><font color="#FF0000">プラス</font>}, 0, 0);

&html_keyword_info($self,$keyworddata,$photodata);

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/$keyword_encode/search/$keyworddata->{id}/">$keyword</a>&gt;<strong>$keyword</strong>のうわさ<br>
<font size=1 color="#E9E9E9">$keywordのクチコミうわさプラスの㌻は、$keywordのうわさ情報を口コミによって集めた$keywordのうわさ情報㌻です。<br>
$keywordのうわさ情報の収集にご協力をお願いします。<br>
</font>

END_OF_HTML

} # xhtml
	
	&html_footer($self);
	
	return;
}

sub _no_family(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('q');
	my $keyword_encode = &str_encode($keyword);
	my ($datacnt, $keyworddata) = &get_keyword($self, $keyword);

	$self->{html_title} = qq{$keywordのうわさ -みんなのうわさプラス-};
	$self->{html_keywords} = qq{$keyword,うわさ,恋愛,熱愛,恋};
	$self->{html_description} = qq{$keywordのうわさ。みんなのクチコミやうわさで作る$keywordのうわさ。};

	my $hr = &html_hr($self,1);	
	&html_header($self);

	my $ad = &html_google_ad($self);

if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML

}else{# xhmlt chtml

&html_table($self, qq{<h1>$keyword</h1><h2><font size=1 color="#00968c"><strong>$keyword</strong>の</font><font size = 1 color="#FF0000">うわさ</font>}, 1, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
<font color="#FF0000"><strong>$keyword</strong>に関するうわさを募集しています</font><br>
<font size=1>情報提供にご協力をお願いします。</font><br>
<center>
<img src="http://img.waao.jp/kaoonegai02t.gif" width=82 height=15>
</center>
<br>
END_OF_HTML

&_uwasa_input_form($self, $keyword);

print << "END_OF_HTML";
$hr
END_OF_HTML

&html_shopping_plus($self);
&html_table($self, qq{<font color="#00968c">$keywordの検索</font><font color="#FF0000">プラス</font>}, 0, 0);
&html_keyword_info($self,$keyworddata);

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/$keyword_encode/search/">$keyword</a>&gt;<strong>$keywordのうわさ</strong><br>
<font size=1 color="#E9E9E9">$keywordのクチコミうわさプラスの㌻は、$keywordのうわさ情報を口コミによって集めた$keywordのうわさ情報㌻です。<br>投稿情報を元に、恋愛、熱愛、恋などの相関関係をクチコミで調査し、恋愛・熱愛のうわさを提供しています。<br>
$keywordのうわさ情報の収集にご協力をお願いします。<br>
</font>

END_OF_HTML

}

	&html_footer($self);
	
	return;
}

sub _eva(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('q');
	my $keyword_encode = &str_encode($keyword);
	my $uwasaid = $self->{cgi}->param('p2');

	# うわさデータ
	my ($datacnt, $uwasadata) = &get_uwasa($self, $uwasaid);
	my $uwasa = qq{$keywordは、}.$uwasadata->{keyperson}.&html_uwasa_type($uwasadata->{type});
	my ($datacnt, $keyworddata) = &get_keyword($self, $keyword);

	$self->{html_title} = qq{$keywordのうわさ:$uwasa};
	$self->{html_keywords} = qq{$keyword,$uwasadata->{keyperson},うわさ,恋愛,熱愛,恋};
	$self->{html_description} = qq{$keywordのうわさ。$uwasa};

	my $hr = &html_hr($self,1);	
	&html_header($self);

	my $ad = &html_google_ad($self);

if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML

}else{# xhmlt chtml

&html_table($self, qq{<h1>$keyword</h1><h2><font size=1 color="#00968c">$keywordの</font><font size=1 color="#FF0000">うわさ</font>}, 1, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
<img src="http://img.waao.jp/kao-a08.gif" width=15 height=15>$uwasa
$hr
<img src="http://img.waao.jp/gr_domo.gif" width=26 height=47 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left">
<font size=1>
$keywordのうわさの精度向上にご協力いただきありがとうございました。
</font>
<br clear="all" />
<img src="http://img.waao.jp/kya-.gif" width=15 height=15><a href="/$keyword_encode/uwasa/add/">$keywordのうわさを投稿する</a>
$hr
END_OF_HTML

&html_shopping_plus($self);
&html_table($self, qq{<font color="#00968c">$keywordの検索</font><font color="#FF0000">プラス</font>}, 0, 0);
&html_keyword_info($self,$keyworddata);
print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/$keyword_encode/search/">$keyword</a>&gt;<a href="/$keyword_encode/uwasa/">$keywordのうわさ</a>&gt;<strong>$uwasa</strong><br>
<font size=1 color="#E9E9E9">$keywordのクチコミうわさプラスの㌻は、$keywordのうわさ情報を口コミによって集めた$keywordのうわさ情報㌻です。<br>
$keywordのうわさ情報の収集にご協力をお願いします。<br>
</font>

END_OF_HTML

}

	&html_footer($self);

	# 評価
	my $good = 1 if($self->{cgi}->param('p1') eq 'good');
	my $bad = 1 if($self->{cgi}->param('p1') eq 'bad');
	&eva_uwasa($self,$uwasaid,$good,$bad);

	return;
}

sub _detail(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('q');
	my $keyword_encode = &str_encode($keyword);
	my $uwasaid = $self->{cgi}->param('p1');

	# うわさデータ
	my ($datacnt, $uwasadata) = &get_uwasa($self, $uwasaid);
	# データが検索できない場合
	unless($datacnt){
		$self->{no_keyword} = 1;
		return;
	}
	my ($datacnt, $keyworddata) = &get_keyword($self, $keyword);
	my ($photodatacnt, $photodata) = &get_photo($self, $keyworddata->{id});

	my $uwasa = qq{$keywordは、}.$uwasadata->{keyperson}.&html_uwasa_type($uwasadata->{type});

	$self->{html_title} = qq{$keyword $uwasadata->{keyperson} のうわさ -みんなのうわさプラス-};
	$self->{html_keywords} = qq{$keyword,$uwasadata->{keyperson},うわさ,恋愛,熱愛,恋};
	$self->{html_description} = qq{$uwasa -$keywordのうわさ-};

	my $hr = &html_hr($self,1);	
	&html_header($self);

	my $ad = &html_google_ad($self);

if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML

}else{# xhmlt chtml

&html_table($self, qq{<h1>$keyword</h1><h2><font size=1 color="#00968c">$uwasa</font>}, 1, 0);
print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
$uwasa
<div align=right><font size=1>うわさ度 <font color="red">$uwasadata->{point}</font>炻</font></div>
<center><font size=1><font color="blue">みんなで投票</font> ⇒　<a href="/$keyword_encode/uwasa/good/$uwasadata->{id}/">ホント</a>!<a href="/$keyword_encode/uwasa/bad/$uwasadata->{id}/">うそ</a>!</font></center>
$hr
END_OF_HTML

&html_keyword_info($self,$keyworddata,$photodata);

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/$keyword_encode/search/">$keyword検索プラス</a>&gt;<strong>$uwasa</strong><br>
<font size=1 color="#E9E9E9">$keywordのクチコミうわさプラスの㌻は、$keywordのうわさ情報を口コミによって集めた$keywordのうわさ情報㌻です。<br>
$keywordのうわさ情報の収集にご協力をお願いします。<br>
</font>
END_OF_HTML

}

	&html_footer($self);

	return;
}

sub _uwasa_input(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('q');
	my $keyword_encode = &str_encode($keyword);
	my $keyperson = $self->{cgi}->param('keyperson');
	my $type = $self->{cgi}->param('type');

	# うわさデータ
	my $uwasa = qq{$keywordは、}.$keyperson.&html_uwasa_type($type);
	my ($datacnt, $keyworddata) = &get_keyword($self, $keyword);

	$self->{html_title} = qq{$keyword  $keyperson のうわさ -みんなのうわさプラス-};
	$self->{html_keywords} = qq{$keyword,$keyperson,うわさ,恋愛,熱愛,恋};
	$self->{html_description} = qq{$uwasa -$keywordのうわさ-};

	my $hr = &html_hr($self,1);	
	&html_header($self);

	my $ad = &html_google_ad($self);


if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML

}else{# xhmlt chtml

&html_table($self, qq{<h1>$keyword</h1><h2><font size=1 color="#00968c">$uwasa</font>}, 1, 0);
print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
<img src="http://img.waao.jp/kao-a08.gif" width=15 height=15>$uwasa
$hr
<img src="http://img.waao.jp/gr_domo.gif" width=26 height=47 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left">
<font size=1>
$keywordのうわさのご提供ありがとうございました。<br>
</font>
<br clear="all" />
END_OF_HTML

&html_shopping_plus($self);
&html_table($self, qq{<font color="#00968c">$keywordの検索</font><font color="#FF0000">プラス</font>}, 0, 0);
&html_keyword_info($self,$keyworddata);

print << "END_OF_HTML";
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/$keyword_encode/search/">$keyword</a>&gt;<a href="/$keyword_encode/uwasa/">$keywordのうわさ</a>&gt;<strong>$uwasa</strong><br>
<font size=1 color="#E9E9E9">$keywordのクチコミうわさプラスの㌻は、$keywordのうわさ情報を口コミによって集めた$keywordのうわさ情報㌻です。<br>
$keywordのうわさ情報の収集にご協力をお願いします。<br>
</font>
END_OF_HTML

}

	&html_footer($self);

	return unless($self->{real_mobile});

	# うわさデータ入力
	my ($datacnt, $keyworddata) = &get_keyword($self, $keyword);
	my ($datacnt, $keypersondata) = &get_keyword($self, $keyperson);
	my $keypersonid = 0;
	$keypersonid = $keypersondata->{id} if($keypersondata);

eval{
	my $sth = $self->{dbi}->prepare(qq{insert into keyword_recomend  (`keywordid`,`keyword`,`keypersonid`,`keyperson`,`type`,`point`,`mid`) values (?,?,?,?,?,?,?)} );
	$sth->execute($keyworddata->{id}, $keyword, $keypersonid, $keyperson, $type, 1, $self->{session}->{_session_id});
};

	return;
}

sub _uwasa_input_form(){
	my $self = shift;
	my $keyword = shift;
	
print << "END_OF_HTML";
<strong>$keyword</strong><font size=1>といえば</font><br>
<form method='post' action='/uwasa.html'>
<input name="q" value="$keyword" type="hidden" />
<input name="guid" value="on" type="hidden" />
<input name="keyperson" value="" type="text" size="17"/><br/>
と(が)
<br>
<select name='type'>
<option value='4'>友人</option>
<option value='7'>メル友倞</option>
<option value='14'>ライバル</option>
<option value='15'>同年代</option>
<option value='10'>共演者</option>
<option value='11'>同郷</option>
<option value='12'>同じ事務所</option>
<option value='1'>恋人</option>
<option value='2'>元恋人</option>
<option value='3'>夫婦</option>
<option value='13'>元夫婦</option>
<option value='5'>好き</option>
<option value='6'>嫌い</option>
<option value='8'>親子</option>
<option value='9'>兄弟/姉妹</option>
</select>関係<br>
<input type='submit' value='だと思う'/>
</form> 
<br><font color="#FF0000" size=1>※投稿内容には、注意して自己責任の元ご投稿ください。</font>
END_OF_HTML

	return;
}
1;