package Waao::Pages::SMFPop;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Html5;
use Waao::Data;
use Waao::Utility;

sub dispatch(){
	my $self = shift;

	&_list($self);
	
	return;
}

sub _list(){
	my $self = shift;
	
	my $page = $self->{cgi}->param('page');
	my $start = 0 + $page * 30;

	my $page_str;
	$page_str = $page + 1 if($self->{cgi}->param('page'));

	my $a = "今話題の人物検索 -スマートフォンナビ(iphone・アンドロイド)- $page_str";
	$self->{html_title} = qq{$a};
	my $b = "人物,スマートフォン,スマフォ,サイト,検索,iphone,アンドロイド";
	$self->{html_keywords} = qq{$b};
	my $c = "今話題の人物検索なら、スマートフォン専用の人物検索サイト。iphone/アンドロイドのスマートフォン専用のサイトだけを検索します $page_strページ目";
	$self->{html_description} = qq{$c};

	&html_header($self);
	
	my $liststr;
	my $sth = $self->{dbi}->prepare(qq{ select id, inital, keyword, birthday, blood, photo from keyword where person = 1 and av is null order by cnt desc limit $start,30} );
	$sth->execute();
	my $cnt;
	while(my @row = $sth->fetchrow_array) {
		$cnt++;
		my $tmp_birth = $row[3];
		if($tmp_birth eq '0000-00-00'){
			$tmp_birth = undef;
		}elsif($tmp_birth){
			my $tmp_birth2 = substr($tmp_birth,0,4)."年".substr($tmp_birth,5,2)."月".substr($tmp_birth,8,2)."日";
			$tmp_birth = $tmp_birth2;
		}
		my $blood;
		if($row[4]){
			$blood = $row[4];
		}
		if($blood eq 1){
			$blood = undef;
		}
		my $photo = $row[5];
		unless($photo){
			my ($photodatacnt, $photodata) = &get_photo($self, $row[0]);
			$photo = $photodata->{url};
		}
#		$liststr.=qq{<li><img src="$photodata->{url}" height="25" width="25" class="ui-li-icon"><a href="/person$row[0]/">$row[2]</a></li>};
		$liststr.=qq{<li><a href="/person$row[0]/"><img src="$photo" title="$row[2]の画像" width=115><h3>$row[2]</h3><p>$tmp_birth $blood</p></a></li>};
	}

	unless($liststr){
		$liststr .= qq{<li>現在、人気の人物がいません。</li>};
	}

	my $pre_page = $page - 1;
	my $next_page = $page + 1;
	$liststr.=qq{<center>};
	$liststr.=qq{<a href="/pop-$pre_page/" data-role="button" data-inline="true">前へ</a>} if($page ne 0);
	$liststr.=qq{<a href="/pop-$next_page/" data-role="button" data-inline="true">次へ</a>} if($cnt eq 30);
	$liststr.=qq{</center>};
	
	my $dsp_page = $page + 1;
print << "END_OF_HTML";
<div data-role="header"> 
<h1>今話題の人物検索</h1>
</div>
<a href="/">トップ</a>&gt;<a href="/pop-0/">人気人物検索</a>&gt;$dsp_pageページ目
<div data-role="content">
<ul data-role="listview">
<li data-role="list-divider">人物検索スマフォサイト</li>
$liststr
</ul>
</div>
END_OF_HTML
	
&html_footer($self);
	
	return;
}

1;