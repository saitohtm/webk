package Waao::Pages::Subdomain::Wiki;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Data;
use Waao::Html;
use Waao::Utility;

sub dispatch(){
	my $self = shift;
	
	if($self->{cgi}->param('q')){
		&_keyword($self);
	}else{
		&_top($self);
	}

	return;
}

sub _top(){
	my $self = shift;

	$self->{html_title} = qq{wikipedia みんなのwikipedia検索(無料)};
	$self->{html_description} = qq{wikipedia検索。携帯から無料で使えるwikipedia検索};
	$self->{html_keywords} = qq{wikipedia,wiki,検索,無料,調べる,調査};

	my $hr = &html_hr($self,1);	

	my $ad = &html_google_ad($self);
	my $datestr = $self->{date_yyyy_mm_dd};
	&html_header($self);

print << "END_OF_HTML";
<center>
<h1><img src="http://img.waao.jp/wiki.gif" width=120 height=28 alt="wikipedia検索無料"></h1>
</center>
$hr
<center>
$ad
</center>
$hr
<center>
<form action="/" method="POST" >
<input type="text" name="q" value="" size="20">
<input type="hidden" name="guid" value="ON">
<input type="hidden" name="date" value="$datestr">
<br />
<input type="submit" value="とりあえず検索"><br />
</form>
</center>
<font size=1>画像・動画・ブログ・着うたマルチ検索</font>
$hr
END_OF_HTML
&html_table($self, qq{<font color="red">今日のトレンドキーワード</font>}, 0, 1);
print << "END_OF_HTML";
<font size=1>
END_OF_HTML

my $memkey = "trendperson";
my $today_trend;
$today_trend = $self->{mem}->get( $memkey );

if($today_trend){
	my $cnt = 0;
	foreach my $keyword (@{$today_trend->{rank}}){
		$cnt++;
		my $str_encode = &str_encode($keyword);
print << "END_OF_HTML";
<a href="/$str_encode/" title="$keyword">$keyword</a> 
END_OF_HTML
	}
}

print << "END_OF_HTML";
<br>
⇒<a href="http://waao.jp/keywordranking/" title="人気検索ワード">検索キーワードランキング</a><br>
END_OF_HTML

&html_table($self, qq{<font color="red">オススメピックアップ</font>}, 0, 1);

my $sth = $self->{dbi}->prepare(qq{ select keyword, id from keyword where  person = 1 order by rand() limit 10} );
$sth->execute();
while(my @row = $sth->fetchrow_array) {
		my $str_encode = &str_encode($row[0]);
print << "END_OF_HTML";
<a href="/$str_encode/" title="$row[0]">$row[0]</a> 
END_OF_HTML
}

print << "END_OF_HTML";
$hr
<a href="/" access_key=0>wikipedia 無料携帯辞書</a><br>
<font size=1 color="#AAAAAA">携帯wikipedia検索は、<strong>wikipedia</strong>の情報を利用したキーワード検索エンジンです。<br>
出典Wikipedia/GFDL準拠
</font>
END_OF_HTML
	
	&html_footer($self);

	return;
}

sub _keyword(){	
	my $self = shift;
	my $keyword = $self->{cgi}->param('q');
	my $keyword_encode = &str_encode($keyword);
	my $date = $self->{cgi}->param('date');
	my $wikiid = $self->{cgi}->param('wiki');
	my $links_no = $self->{cgi}->param('wikino');

	my ($datacnt, $wikipedia) = &get_wiki($self, $keyword, $wikiid);
	# wiki情報ゲット
	# データが検索できない場合
	unless($datacnt){
		$self->{no_keyword} = 1;
		return;
	}
	my $description = substr($wikipedia->{simpletext2},0,100);
	
	$self->{html_title} = qq{$keywordとは -無料$keywordデータベース-};
	$self->{html_description} = qq{$description};
	$self->{html_keywords} = qq{$keyword,無料,データベース,wikipedia,ウィキペディア};
	
	my ($datacnt, $keyworddata) = &get_keyword($self, $keyword);
	if($keyworddata->{wiki_id}){
		if($keyworddata->{birthday}){
			$self->{html_title} = qq{$keyword 画像付プロフィール};
			$self->{html_keywords} = qq{$keyword,画像,プロフィール};
		}
	}

	# photo データ
	my ($datacnt, $photodata) = &get_photo($self, $keyworddata->{id});

	my $hr = &html_hr($self,1);	

	my $ad = &html_google_ad($self);

	&html_header($self);
	if($wikipedia->{linklist}){
		my $links = $wikipedia->{linklist};
		my $str_encode = &str_encode( $keyword );
		$links =~s/\#links\_/\/$str_encode\/wiki\/$wikipedia->{rev_id}\//g;
		$links =~s/\"\>/\/\"\>/g;
		$wikipedia->{linklist} = qq{$hr<font size=1>$links</font>};
	}

	my $simplewiki = &simple_wiki_upd($keyworddata->{simplewiki}, 128) if($keyworddata->{simplewiki});

	my $wikistr;
	my @lines = split(/\n/,$wikipedia->{wikipedia});

	# 見出しごとに分割
	if($links_no){
		my $flag;
		foreach my $line (@lines){
			$line =~s/wiki\///g;
			if( ($line=~/links_$links_no\"/) || ($line=~/links_$links_no\>/) ){
				$flag = 1;
			}elsif( $line=~/links_/ ){
				if($flag eq 1){
					last;
				}
			}
			if($flag){
				$line =~s/\|/<br>/g;
				$wikistr .= $line."\n";
			}
		}
		$wikistr .= qq{<br><a href="/$keyword_encode/$wikiid/">$keywordへ戻る</a>}."\n";
	}else{
		foreach my $line (@lines){
			$line =~s/wiki\///g;
			if( ($line=~/links_1\"/) || ($line=~/links_1\>/) ){
				$wikistr .= $wikipedia->{linklist};
				$wikistr =~s/wiki\///g;
				last unless($links_no);
				$wikistr .= $hr;
				$wikistr .= $line."\n";
			}else{
				$line =~s/\|/<br>/g;
				$wikistr .= $line."\n";
			}
		}
	}

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

if($keyworddata->{wiki_id}){
	if($keyworddata->{birthday}){
		&html_table($self, qq{<h1>$keyword</h1><h2><font size=1>$keywordのプロフィール</font></h2>}, 1, 0);
	}else{
		&html_table($self, qq{<h1>$keyword</h1><h2><font size=1>$keywordのデータベース</font></h2>}, 1, 0);
	}
}else{
	&html_table($self, qq{<h1>$keyword</h1><h2><font size=1>$keywordのデータベース</font></h2>}, 1, 0);
}

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

print << "END_OF_HTML";
<h2><font size=1>$keyword</font></h2>
END_OF_HTML


&html_keyword_info3($self, $keyworddata, $photodata);

if($keyworddata->{simplewiki}){
print << "END_OF_HTML";
$keyworddata->{simplewiki}
END_OF_HTML
}


if($wikistr){
print << "END_OF_HTML";
$hr
$wikistr
END_OF_HTML
}


print << "END_OF_HTML";
$hr
<a href="/" access_key=0>wiki無料携帯</a>&gt;<a href="http://waao.jp/$keyword_encode/search/">$keyword検索プラス</a>&gt;<strong>$keyword</strong><br>
<font size=1 color="#AAAAAA">この㌻は、wikipediaの情報を利用した<strong>$keyword</strong>の情報㌻です。<br>
みんなのモバイルで独自に収集した<strong>$keyword</strong>のクチコミ情報をプラスして<strong>$keyword</strong>の情報を検索できる<strong>$keyword</strong>データベースです。<br>
$keywordの情報収集にご協力をお願いします。<br>
$date更新の最新wikipediaデータです。<br>
出典Wikipedia/GFDL準拠
</font>
END_OF_HTML

}
	
	&html_footer($self);
	
	return;
}

1;