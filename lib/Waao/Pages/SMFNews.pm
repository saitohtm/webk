package Waao::Pages::SMFNews;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Html5;
use Waao::Data;
use Waao::Utility;

sub dispatch(){
	my $self = shift;
	
	if($self->{cgi}->param('id')){
		&_detail($self);
	}elsif($self->{cgi}->param('type')){
		&_list($self);
	}else{
		&_top($self);
	}

	return;
}

sub _list(){
	my $self = shift;
	my $type = $self->{cgi}->param('type');
	my $page = $self->{cgi}->param('page');
	$page=0 unless($page);
	my $geinou = &html_mojibake_str("geinou");

	my $str;
	my $cnt;

	my $startpage = $page * 10;

	my $limitcnt = 10;
	my 	$sth = $self->{dbi}->prepare(qq{ select id, title, bodystr, datestr, type, geturl, ext from rssdata where type = ? order by datestr desc,id limit $startpage, $limitcnt} );
	$sth->execute($type);
	my $cnt;
	while(my @row = $sth->fetchrow_array) {
		my ($datacnt, $keyworddata) = &get_keyword($self, $row[1]);
		if($keyworddata->{id}){
			my ($photodatacnt, $photodata) = &get_photo($self, $keyworddata->{id});
			if($photodata->{url}){
				$str.=qq{<li><img src="$photodata->{url}" height="25" width="25" class="ui-li-icon"><a href="/news$row[0]/">$row[1]</a></li>};
			}else{
				$str.=qq{<li><a href="/news$row[0]/">$row[1]</a></li>};
			}
		}else{
			$str.=qq{<li><a href="/news$row[0]/">$row[1]</a></li>};
		}
		next if($type eq 1);
		next if($row[2] eq "utf8");
		$row[2] =~s/border=\"0\" align=\"left\" hspace=\"5\"\>/\>\<br>/;
		$str.=qq{$row[2]<br>};
	}
	
	my $pagenext = $page + 1;
	$str.=qq{<li><a href="/news-$type-$pagenext/"><img src="/img/E23C_20.gif" height="20" class="ui-li-icon">次のページへ</a></li>};

	my $type_str = &_get_type($type);

	my $a = "$type_str $geinouニュース $pageページ目";
	$self->{html_title} = qq{$a};
	my $b = "流行,人気,ブーム,きざし,検索";
	$self->{html_keywords} = qq{$b};
	my $c = "$type_str $geinouニュース $pageページ目";
	$self->{html_description} = qq{$c};

	&html_header($self);

print << "END_OF_HTML";
<div data-role="header"> 
<h1>$type_str</h1> 
</div>
<a href="/">スマフォMAX</a>&gt;<a href="/news/">$geinouニュース</a>&gt;<strong>$type_str</strong>
<div data-role="content">
<ul data-role="listview">
$str
</ul>
</div>
END_OF_HTML

	&html_footer($self);

	return;
}

sub _detail(){
	my $self = shift;
	my $dataid = $self->{cgi}->param('id');
	my $geinou = &html_mojibake_str("geinou");

	my ($title,$bodystr,$datestr,$geturl,$ext,$type);	
	my 	$sth = $self->{dbi}->prepare(qq{ select title, bodystr, datestr, geturl, ext, type from rssdata where id= ?});
	$sth->execute($dataid);
	my $str;
	while(my @row = $sth->fetchrow_array) {
		($title,$bodystr,$datestr,$geturl,$ext,$type) = @row;

		my ($datacnt, $keyworddata) = &get_keyword($self, $row[0]);
		if($keyworddata->{id}){
			my ($photodatacnt, $photodata) = &get_photo($self, $keyworddata->{id});
			if($photodata->{url}){
				$str.=qq{<li><img src="$photodata->{url}" height="25" width="25" class="ui-li-icon"><a href="/person$keyworddata->{id}/">$row[0]</a></li>};
			}else{
				$str.=qq{<li><a href="/person$keyworddata->{id}/">$row[0]</a></li>};
			}
		}else{
			$str.=qq{<li>$row[0]</li>};
		}
	}
	
	my $title_tmp = Jcode->new($title, 'sjis')->utf8;
	my $keyword_tmp_encode = &str_encode($title_tmp);

	my $geinou = &html_mojibake_str("geinou");	

	my $a = "$title $geinouニュース $dataid";
	$self->{html_title} = qq{$a};
	my $b = "$title,流行,人気,ブーム,きざし,検索";
	$self->{html_keywords} = qq{$b};
	my $c = "$dataid $title 今話題になってます！$titleについて詳しく検索できます！ ";
	$self->{html_description} = qq{$c};

	&html_header($self);

	$bodystr = undef if($bodystr eq "utf8");
	
print << "END_OF_HTML";
<div data-role="header"> 
<h1>$title</h1> 
</div>
<a href="/">スマフォMAX</a>&gt;<a href="/news/">$geinouニュース</a>&gt;<strong>$title</strong>
<div data-role="content">
<ul data-role="listview">
<li data-role="list-divider">$datestr</li>
$str
$bodystr<br>
<iframe src="http://search.yahoo.co.jp/search?ei=UTF-8&p=$keyword_tmp_encode" height=300 width=300></iframe>
</ul>
</div>
END_OF_HTML

	&html_footer($self);

	return;
}

sub _top(){
	my $self = shift;
	
	my $geinou = &html_mojibake_str("geinou");	

	my $a = "ニュース:今話題のニュース($geinouネタ付き$geinouニュース)";
	$self->{html_title} = qq{$a};
	my $b = "ニュース,話題,$geinou,$geinouニュース";
	$self->{html_keywords} = qq{$b};
	my $c = "たった1分でわかる今日の$geinouニュース。最新トレンド情報付";
	$self->{html_description} = qq{$c};
	&html_header($self);

print << "END_OF_HTML";
<div data-role="header"> 
<h1>今日の$geinouニュース</h1> 
</div>
<a href="/">スマフォMAX</a>&gt;$geinouニュース

<div data-role="content">
<ul data-role="listview">
END_OF_HTML

print << "END_OF_HTML";
<li data-role="list-divider">今がわかる上昇ワード5</li>
END_OF_HTML
&_get_rss_data($self,3);

print << "END_OF_HTML";
<li data-role="list-divider">ただいま、検索上昇中</li>
END_OF_HTML
&_get_rss_data($self,4);

print << "END_OF_HTML";
<li data-role="list-divider">ブログで話題のキーワード</li>
END_OF_HTML
&_get_rss_data($self,1);

print << "END_OF_HTML";
<li data-role="list-divider">上昇中キーワード</li>
END_OF_HTML
&_get_rss_data($self,2);



print << "END_OF_HTML";
<li data-role="list-divider">検索数ランキング</li>
END_OF_HTML
&_get_rss_data($self,5);

print << "END_OF_HTML";
<li data-role="list-divider">人名検索数ランキング</li>
END_OF_HTML
&_get_rss_data($self,6);

print << "END_OF_HTML";
<li data-role="list-divider">テレビ・ドラマ検索数ランキング</li>
END_OF_HTML
&_get_rss_data($self,7);

print << "END_OF_HTML";
<li data-role="list-divider">ゲーム・アニメ検索数ランキング</li>
END_OF_HTML
&_get_rss_data($self,8);

print << "END_OF_HTML";
<li data-role="list-divider">スポーツ検索数ランキング</li>
END_OF_HTML
&_get_rss_data($self,9);

print << "END_OF_HTML";
<li data-role="list-divider">トレンドサーフィン</li>
END_OF_HTML
&_get_rss_data($self,10);

print << "END_OF_HTML";
<li data-role="list-divider">All About人気記事</li>
END_OF_HTML
&_get_rss_data($self,11);

print << "END_OF_HTML";
<li data-role="list-divider">はてぶ人気エントリー</li>
END_OF_HTML
&_get_rss_data($self,12);

print << "END_OF_HTML";
<li data-role="list-divider">R25人気記事</li>
END_OF_HTML
&_get_rss_data($self,13);


print << "END_OF_HTML";
</ul>
</div>
END_OF_HTML
	
&html_footer($self);

	return;
}

sub _get_rss_data(){
	my $self = shift;
	my $type = shift;

	my $str;
	my 	$sth = $self->{dbi}->prepare(qq{ select id, title, bodystr, datestr, type, geturl, ext from rssdata where type = ? and datestr >= ADDDATE(CURRENT_DATE,INTERVAL -1 DAY) order by datestr desc,id limit 10} );
	$sth->execute($type);
	my $cnt;
	while(my @row = $sth->fetchrow_array) {
		$cnt++;
		my ($datacnt, $keyworddata) = &get_keyword($self, $row[1]);
		if($keyworddata->{id}){
			my ($photodatacnt, $photodata) = &get_photo($self, $keyworddata->{id});
			if($photodata->{url}){
				$str.=qq{<li><img src="$photodata->{url}" height="25" width="25" class="ui-li-icon"><a href="/news$row[0]/">$row[1]</a></li>};
			}else{
				$str.=qq{<li><a href="/news$row[0]/">$row[1]</a></li>};
			}
		}else{
			$str.=qq{<li><a href="/news$row[0]/">$row[1]</a></li>};
		}
		next if($type eq 1);
		next if($row[2] eq "utf8");
		$row[2] =~s/border=\"0\" align=\"left\" hspace=\"5\"\>/\>\<br>/;
		$str.=qq{$row[2]<br>};
	}
	unless($cnt){
		my $limitcnt = 10;
		$limitcnt = 3 if($type == 13);
		my 	$sth = $self->{dbi}->prepare(qq{ select id, title, bodystr, datestr, type, geturl, ext from rssdata where type = ? order by datestr desc,id limit $limitcnt} );
		$sth->execute($type);
		my $cnt;
		while(my @row = $sth->fetchrow_array) {
			my ($datacnt, $keyworddata) = &get_keyword($self, $row[1]);
			if($keyworddata->{id}){
				my ($photodatacnt, $photodata) = &get_photo($self, $keyworddata->{id});
				if($photodata->{url}){
					$str.=qq{<li><img src="$photodata->{url}" height="25" width="25" class="ui-li-icon"><a href="/news$row[0]/">$row[1]</a></li>};
				}else{
					$str.=qq{<li><a href="/news$row[0]/">$row[1]</a></li>};
				}
			}else{
				$str.=qq{<li><a href="/news$row[0]/">$row[1]</a></li>};
			}
			next if($type eq 1);
			next if($row[2] eq "utf8");
			$row[2] =~s/border=\"0\" align=\"left\" hspace=\"5\"\>/\>\<br>/;
			$str.=qq{$row[2]<br>};
		}
	}
	$str.=qq{<li><a href="/news-$type-0/"><img src="/img/E23C_20.gif" height="20" class="ui-li-icon">全て見る</a></li>};

print << "END_OF_HTML";
$str
END_OF_HTML

	return;
}

sub _get_type(){
	my $type = shift;
	my $str;
	
	if($type eq 1){
		$str=qq{ブログで話題のキーワード};
	}elsif($type eq 2){
		$str=qq{上昇中キーワード};
	}elsif($type eq 3){
		$str=qq{今がわかる上昇ワード5};
	}elsif($type eq 4){
		$str=qq{ただいま、検索上昇中};
	}elsif($type eq 5){
		$str=qq{検索数ランキング};
	}elsif($type eq 6){
		$str=qq{人名検索数ランキング};
	}elsif($type eq 7){
#		$str=q{テレビ・ドラマ検索数ランキング};
	}elsif($type eq 8){
		$str=qq{ゲーム・アニメ検索数ランキング};
	}elsif($type eq 9){
		$str=qq{スポーツ検索数ランキング};
	}elsif($type eq 10){
		$str=qq{トレンドサーフィン};
	}elsif($type eq 11){
		$str=qq{All About人気記事};
	}elsif($type eq 12){
		$str=qq{はてぶ人気エントリー};
	}elsif($type eq 13){
		$str=qq{R25人気記事};
	}
	
	return $str;
}
1;