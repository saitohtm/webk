package Waao::Pages::Wiki;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Data;
use Waao::Html;
use Waao::Utility;

sub dispatch(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('q');
	my $keyword_encode = &str_encode($keyword);
	my $wikiid = $self->{cgi}->param('p1');
	my $links_no = $self->{cgi}->param('p2');

	my ($datacnt, $wikipedia) = &get_wiki($self, $keyword, $wikiid);
	# wiki情報ゲット
	# データが検索できない場合
	unless($datacnt){
		$self->{no_keyword} = 1;
		return;
	}
	
	$self->{html_title} = qq{$keywordとは -みんなのwikipediaプラス- };
	$self->{html_keywords} = qq{$keyword,wikipedia,検索,データ,情報,wiki};
	$self->{html_description} = qq{$keywordとは…$keywordのwikipedia情報に独自情報をプラスした最強の$keywordデータベースです。};
	
	my ($datacnt, $keyworddata) = &get_keyword($self, $keyword);
	if($keyworddata->{wiki_id}){
		if($keyworddata->{birthday}){
			$self->{html_title} = qq{$keywordの画像付プロフィール -みんなのプロフィールプラス- };
			$self->{html_keywords} = qq{$keyword,wikipedia,プロフ,画像,プロフィール,検索};
			$self->{html_description} = qq{$keywordとは…$keywordのプロフィール情報+画像+wikipedia情報のマルチ検索サイトです。};
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
		$wikistr .= qq{<br><a href="/$keyword_encode/wiki/$wikiid/">$keywordへ戻る</a>}."\n";
	}else{
		foreach my $line (@lines){
			if( ($line=~/links_1\"/) || ($line=~/links_1\>/) ){
				$wikistr .= $wikipedia->{linklist};
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

&html_table($self, qq{<h1>$keyword</h1><h2><font size=1>$keywordのデータベース</font></h2>}, 1, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

if($wikistr){
print << "END_OF_HTML";
$wikistr
$hr
END_OF_HTML
}

&html_keyword_info($self, $keyworddata, $photodata);

print << "END_OF_HTML";
$hr
<a href="/" access_key=0>トップ</a>&gt;<a href="/$keyword_encode/search/">$keyword検索プラス</a>&gt;<strong>$keyword</strong><br>
<font size=1 color="#AAAAAA">この㌻は、wikipediaの情報を利用した$keywordの情報㌻です。<br>
みんなのモバイルで独自に収集した$keywordのクチコミ情報をプラスして$keywordの情報を検索できる$keywordデータベースです。<br>
$keywordの情報収集にご協力をお願いします。<br>
出典Wikipedia/GFDL準拠
</font>
END_OF_HTML

}
	
	&html_footer($self);
	
	return;
}

1;