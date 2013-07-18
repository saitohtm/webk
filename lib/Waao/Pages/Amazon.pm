package Waao::Pages::Amazon;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Data;
use Waao::Html;
use Waao::Utility;
use Net::Amazon;
use Cache::File;
use Jcode;
use CGI qw( escape );


# /amazon/					topページ
# /keyword/amazon/			商品検索
# /keyword/amazon/pageno/	商品検索
# /keyword/amazon/amazon/商品ID	商品詳細
sub dispatch(){
	my $self = shift;
	
	if($self->{cgi}->param('p1') eq 'amazon'){
		&_detail($self);
	}elsif($self->{cgi}->param('p1')){
		&_search($self);
	}elsif($self->{cgi}->param('q')){
		&_search($self);
	}else{
		&_top($self);
	}

	return;
}

sub _top(){
	my $self = shift;

	$self->{html_title} = qq{amazon(アマゾン)通販ショッピングプラス -みんなのモバイル-};
	$self->{html_keywords} = qq{amazon,アマゾン,ショッピング,通販,送料無料};
	$self->{html_description} = qq{みんなのamazon(アマゾン)通販ショッピングプラス:amazon(アマゾン)だけじゃない全てのショッピング検索に連動};

	my $hr = &html_hr($self,1);	
	&html_header($self);
	my $ad_amazon = &html_amazon_url($self);
	
if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML
	
}else{# xhmlt chtml

print << "END_OF_HTML";
<center>
<h2><font size=1>amazon(アマゾン)通販</font><font size=1color="#FF0000">プラス</font></h2>
</center>
<center>
<form action="/amazon.html" method="POST" ><input type="text" name="q" value="" size="20"><input type="hidden" name="guid" value="ON">
<br />
<input type="submit" value="商品検索プラス"><br />
</form>
</center>
<center>
<font size=1>amazon(アマゾン)<font color="#FF0000">マルチ検索</font></font>
</center>
$hr
<a href="/" accesskey=9>トップ</a>&gt;<strong>amazon(アマゾン)通販ショッピングプラス</strong><br>
<font size=1 color="#AAAAAA">みんなのamazon(アマゾン)通販ショッピングプラスは,amazon(アマゾン)だけじゃなく全ての情報からお得な通販ショッピング情報と価格比較ができる通販ショッピング検索サイトです。<br>
<a href="$ad_amazon">amazon</a><br>
</font>
END_OF_HTML

}

	&html_footer($self);

	return;
}

sub _search(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('q');

	$self->{html_title} = qq{「$keyword」の売れ筋通販商品専門店 -amazon(アマゾン)通販プラス-};
	$self->{html_keywords} = qq{$keyword,amazon,アマゾン,ショッピング,通販,送料無料,売れ筋};
	$self->{html_description} = qq{$keywordの売れ筋通販ランキング情報：amazon(アマゾン)のショッピング通販検索に連動};
	
	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);

	&html_header($self);

	&html_table($self, qq{<h1>$keyword</h1><h2><font size=1 color="#FF0000">amazon(アマゾン)通販検索</font></h2>}, 1, 0);
print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
END_OF_HTML


	&_search_amazon($self);

	my $ad_amazon = &html_amazon_url($self);

print << "END_OF_HTML";
$hr
<a href="/" accesskey=9>トップ</a>&gt;<a href="/amazon/">amazon(アマゾン)通販検索プラス</a>&gt;<strong>$keyword</strong>の商品一覧<br>
<font size=1 color="#AAAAAA">$keywordのamazon(アマゾン)売れ筋通販ショッピングプラスの㌻は、$keywordのamazon(アマゾン)売れ筋通販商品の情報を
amazon(アマゾン)の情報から通販取得ができるマルチショッピング通販検索サイトです。<br>
<a href="$ad_amazon">amazon</a><br>
END_OF_HTML


	&html_footer($self);
	
	return;
}


sub _search_amazon(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('q');
	my $keyword_encode = &str_encode($keyword);
	my $keyword_utf8 = $keyword;
	Encode::from_to($keyword_utf8,'cp932','utf8');
#	$keyword_utf8 = escape ( $keyword_utf8 );
	my $page = 1;
	$page = $self->{cgi}->param('p1') if($self->{cgi}->param('p1'));
	my $next_page = $page+ 1;
	my $pre_page_max = ($page -1) * 10; 
	my $cache = Cache::File->new( 
	    cache_root        => '/tmp/',
	    default_expires   => '30 min',
	);

	my $ua = Net::Amazon->new(
		token      => 'AKIAIRGWPLJPBTAAZKBQ',
		secret_key => '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',
		cache       => $cache,
		max_pages => $page,
		locale => 'jp',
		AssociateTag => 'gooto-22',
	);

	my $response = $ua->search(
		keyword => $keyword_utf8,
		AssociateTag => 'gooto-22',
#		mode => 'books',
	);

	my $hr = &html_hr($self,1);	
	&html_table($self, qq{寀amazon}, 0, 0);

	if (not $response->is_success()) {
print << "END_OF_HTML";
<storong>$keyword</strong>に該当する商品は見つかりませんでした。<br>
END_OF_HTML
	    return;
	}
	my $forcnt;
	foreach my $result ($response->properties){
		$forcnt++;
		next if( $forcnt <= $pre_page_max);
		
		my $name = Jcode->new($result->{Title}, 'utf8')->sjis;
		my $link_url = qq{/$keyword_encode/amazon/amazon/$result->{ASIN}/};
		if($self->{real_mobile}){
			$link_url = qq{$result->{DetailPageURL}};
		}
		
		# 画像処理
		my $img_url;
		if($result->{SmallImageUrl}){
			$img_url = $result->{SmallImageUrl};
		}else{
			$img_url = qq{};
		}
		my $price = &price_dsp($result->{RawListPrice});
		my $pricedown;
		my $sendfree;
#		my $headline = Jcode->new($result->{ProductDescription}, 'utf8')->sjis;

print << "END_OF_HTML";
<font size=1 color="#FF0000">●</font><font size=1><a href="$link_url">$name</a></font><br>
<a href="$link_url"><img src="$img_url" width="$result->{SmallImageWidth}" height="$result->{SmallImageHeight}" alt="$name" style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left"></a>
$price$pricedown<br>
$sendfree
<font size=1><a href="$link_url">詳しく見る</a></font><br>
<br clear="all" />
$hr
END_OF_HTML
	}


print << "END_OF_HTML";
<div align=right><a href="/$keyword_encode/amazon/$next_page/">次の㌻</a></div>
END_OF_HTML

	return;
}

sub _detail(){
	my $self = shift;
	
	&_detail_amazon($self);

	return;
}


sub _detail_amazon(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('q');
	my $asin = $self->{cgi}->param('p2');
	my $keyword_encode = &str_encode($keyword);

	my $keyword_utf8 = $keyword;
	Encode::from_to($keyword_utf8,'cp932','utf8');
	$keyword_utf8 = escape ( $keyword_utf8 );
	my $hr = &html_hr($self,1);	

#binmode(STDOUT, ":utf8");
	my $cache = Cache::File->new( 
	    cache_root        => '/tmp/',
	    default_expires   => '30 min',
	);

	my $ua = Net::Amazon->new(
		token      => 'AKIAIRGWPLJPBTAAZKBQ',
		secret_key => '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',
		cache       => $cache,
		max_pages => 1,
		locale => 'jp',
	);
	my $response = $ua->search(
		AssociateTag => 'gooto-22',
		asin => $asin,
	);
	
	my $dsp_str;
	my ($name,$price,$sendfree);
	# 該当がない場合
	if (not $response->is_success()) {
		$dsp_str = qq{<font size=1><storong>$keyword</strong>に該当する商品は見つかりませんでした。</font><br>};
	}else{
		foreach my $result ($response->properties){
eval{
			# real_mobileは、直リンク
			# /keyword/shopping/yahoo|amazon|rakuten/<ID>
			my $link_url = qq{/$keyword_encode/amazon/amazon/$result->{ASIN}/};
			if($self->{real_mobile}){
				$link_url = qq{$result->{DetailPageURL}};
			}
			$name = Jcode->new($result->{Title}, 'utf8')->sjis if($result->{Title});
#			my $headline = Jcode->new($result->{Headline}, 'utf8')->sjis if($result->{Headline});
#			my $description = Jcode->new($result->{Description}, 'utf8')->sjis if($result->{Description});
			# プライスダウン：
			$price = &price_dsp($result->{RawListPrice});
			# 画像処理
			my $img_url;
			if($result->{MediumImageUrl}){
				$img_url = $result->{MediumImageUrl};
			}else{
				$img_url = qq{};
			}
			$dsp_str .=qq{$price<br>};
			$dsp_str .=qq{<center><a href="$link_url"><img src="$img_url" width=146 height=146 alt="$name"></a></center>};
			$dsp_str .=qq{<a href="$link_url">詳しく見る</a><br>};
#			$dsp_str .=qq{$headline<br>};
#			$dsp_str .=qq{$description<br>};
			foreach my $simmilar ($response->SimilarProducts->{SimilarProducts}){
				$dsp_str .=qq{$simmilar->{Title}};
			}
			$dsp_str .=qq{$hr};
}; # eval

		} # foreach
	} # else


	$self->{html_title} = qq{$name $price-$keyword amazon(アマゾン)通販検索-};
	$self->{html_keywords} = qq{amazon,アマゾン,$keyword,通販};
	$self->{html_description} = qq{$keyword  amazon(アマゾン)通販ショッピングプラスは、amazon(アマゾン)で通販できるお得な$keyword通販情報です。 };

	&html_header($self);

	if($name){
		&html_table($self, qq{<h1>$name</h1>}, 0, 0);
		&html_table($self, qq{<h2><font size=1 color="#FF0000">$keyword amazon(アマゾン)通販検索</font></h2>}, 1, 0);
	}else{
		&html_table($self, qq{<h1>$keyword</h1><h2><font size=1 color="#FF0000">$keyword amazon(アマゾン)通販検索</font></h2>}, 1, 0);
	}

print << "END_OF_HTML";
$dsp_str
END_OF_HTML

	&html_shopping_search_plus($self);
	my $ad_amazon = &html_amazon_url($self,$keyword);

print << "END_OF_HTML";
$hr
<a href="/" accesskey=9>トップ</a>&gt;<a href="/amazon/">amazon(アマゾン)通販検索プラス</a>&gt;<a href="/$keyword_encode/amazon/">$keywordの商品一覧</a>&gt;<strong>$name</strong><br>
<font size=1 color="#AAAAAA">$keywordの売れ筋通販ショッピングプラスの㌻は、$keywordの売れ筋通販商品の情報として、
$nameを検索しました。<br>
amazon(アマゾン)の全ての情報から通販取得ができるマルチショッピング通販検索サイトです。<br>
<a href="$ad_amazon">amazon</a><br>
</font>
END_OF_HTML

	&html_footer($self);
	
	return;
}

1;