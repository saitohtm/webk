package Waao::Pages::PhotoList;
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

	my $pageinfo = $self->{cgi}->param('p1'); 
	my ($page, $thumflag) = split(/-/,$pageinfo);

	my $keywordid = $self->{cgi}->param('p2');

	my ($datacnt, $keyworddata) = &get_keyword($self, $keyword, $keywordid);
	# データが検索できない場合
	unless($datacnt){
		$self->{no_keyword} = 1;
		return;
	}

	$self->{html_title} = qq{$keywordの画像一覧 -みんなのフォトプラス-};
	$self->{html_keywords} = qq{$keyword,検索,画像,フォト,壁紙,cm,プロフィール};
	$self->{html_description} = qq{$keywordの画像一覧。ここにしかない$keyword画像をプラス！};

	my $hr = &html_hr($self,1);	
	&html_header($self);

	my $ad = &html_google_ad($self);

	# ページ制御
	my $limit_s = 0;
	my $limit = 30;
	if( $thumflag ){
		$limit = 3;
	}
	$limit = 30 if($self->{access_type} eq 4);
	$limit = 200 if($self->{access_type} eq 9);
	if( $page ){
		$limit_s = $limit * $page;
	}else{
		$page=1;
	}

	$limit = 30 unless($self->{real_mobile});

	my $next_page = $page + 1;
	my $next_str = qq{<img src="http://img.waao.jp/m2028.gif" width=48 height=9 alt="$keyword"><a href="/$keyword_encode/photolist/0-1/">最初</a> };
	$next_str .= qq{<a href="/$keyword_encode/photolist/$next_page-$thumflag/">$next_page</a> };
	$next_page++;
	$next_str .= qq{<a href="/$keyword_encode/photolist/$next_page-$thumflag/">$next_page</a> };
	$next_page++;
	$next_str .= qq{<a href="/$keyword_encode/photolist/$next_page-$thumflag/">$next_page</a> };
	$next_page++;
	$next_str .= qq{<a href="/$keyword_encode/photolist/$next_page-$thumflag/">$next_page</a> };
	$next_page++;
	$next_str .= qq{<a href="/$keyword_encode/photolist/$next_page-$thumflag/">$next_page</a> };

	my $keyword_str;
	my $sth;
	if($self->{access_type} eq 4){
		if($keywordid){
			$sth = $self->{dbi}->prepare(qq{ select id, keyword, good, url, fullurl from photo where keywordid = ? order by good desc limit $limit_s, $limit} );
			$sth->execute($keywordid);
		}else{
			$sth = $self->{dbi}->prepare(qq{ select id, keyword, good, url, fullurl from photo where keyword = ? order by good desc limit $limit_s, $limit} );
			$sth->execute($keyword);
		}
	}else{
		if($keywordid){
			$sth = $self->{dbi}->prepare(qq{ select id, keyword, good, url from photo where keywordid = ? order by good desc limit $limit_s, $limit} );
			$sth->execute($keywordid);
		}else{
			$sth = $self->{dbi}->prepare(qq{ select id, keyword, good, url from photo where keyword = ? order by good desc limit $limit_s, $limit} );
			$sth->execute($keyword);
		}
	}

	my $fpage_cnt=0;
	while(my @row = $sth->fetchrow_array) {
		$fpage_cnt++;
		$limit_s++;
		$keyword_str .= qq{<font size=1>} unless($self->{access_type} eq 4);
		if( $thumflag ){
			if($self->{access_type} eq 4){
				my $img_path = $row[3];
				$img_path = $row[4] if($row[4]);
			$keyword_str .= qq{<table border=0 bgcolor="#000000" width="100%"><tr><td><center><img src="$img_path" width=300 alt="$row[1]の画像"><br></center></td></tr></table>};
			}else{
			$keyword_str .= qq{<table border=0 bgcolor="#000000" width="100%"><tr><td><center><a href="/$keyword_encode/photo/$row[0]/"><img src="$row[3]" alt="$row[1]の画像"><br><font size=1>[拡大]</font></a></center></td></tr></table>};
			}
		}
		if( $thumflag ){
			$keyword_str .= qq{<font size=1>};
			$keyword_str .= qq{<strong>$keyword</strong>の評価：<font color="blue">$row[2]</font><font color="red">Good！</font></font><br>};
			$keyword_str .= qq{<center><form action="/photoeva.html" method="POST">};
			$keyword_str .= qq{<input type="hidden" name="photoid" value="$row[0]">};
			$keyword_str .= qq{<input type="hidden" name="good" value="1">};
			$keyword_str .= qq{<input type="hidden" name="guid" value="on">};
			$keyword_str .= qq{<input type="hidden" name="q" value="$row[1]">};
			$keyword_str .= qq{<input type="submit" value="good">};
			$keyword_str .= qq{</form>};
			$keyword_str .= qq{<form action="/photoeva.html" method="POST">};
			$keyword_str .= qq{<input type="hidden" name="photoid" value="$row[0]">};
			$keyword_str .= qq{<input type="hidden" name="bad" value="1">};
			$keyword_str .= qq{<input type="hidden" name="guid" value="on">};
			$keyword_str .= qq{<input type="hidden" name="q" value="$row[1]">};
			$keyword_str .= qq{<input type="submit" value="Bad!"><br>};
			$keyword_str .= qq{</form>};
			$keyword_str .= qq{</center>};
		}else{
			$keyword_str .= qq{<font size=1><a href="/$keyword_encode/photo/$row[0]/">$keywordの画像</a><div align="right"><font color="blue">$row[2]</font><font color="red">Good!</font></div></font><br>};
		}
		$keyword_str .= qq{</font>} unless($self->{access_type} eq 4);
		$keyword_str .= qq{$hr};
	}
	if($fpage_cnt eq 0){
	}elsif($fpage_cnt < 3){
	}



my $simplewiki = &simple_wiki_upd($keyworddata->{simplewiki}, 128) if($keyworddata->{simplewiki});


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

&html_table($self, qq{<h1>$keyword</h1><h2><font size=1>$keyword</font><font size=1 color="#FF0000">画像一覧</font></h2>}, 1, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML

print << "END_OF_HTML";
<div align=right>
画像サムネイル <a href="/$keyword_encode/photolist/0-1/">ON</a>/<a href="/$keyword_encode/photolist/0-0/">OFF</a>
</div>
$keyword_str</font>
<br>
$next_str <br>
<a href="/$keyword_encode/yahooimage/">Y!Imageでも探す</a><br>
<a href="/$keyword_encode/flickr/">flickrでも探す</a><br>
$hr
END_OF_HTML

&html_table($self, qq{<h1>$keyword</h1><h2><font size=1 color="#FF0000">情報</font></h2>}, 1, 0);

&html_keyword_info($self,$keyworddata);


print << "END_OF_HTML";
$hr
<a href="/" access_key=0>トップ</a>&gt;<a href="/$keyword_encode/search/">$keyword検索</a>&gt;<strong>$keyword</strong>画像一覧<br>
<font size=1 color="#AAAAAA">$keywordの画像検索プラスの㌻は、$keywordの画像情報を口コミによって集めた$keywordの画像検索㌻です。<br>
$keywordの画像情報の収集にご協力をお願いします。<br>
</font>
END_OF_HTML

} # xhtml


	
	&html_footer($self);
	
	return;
}

1;