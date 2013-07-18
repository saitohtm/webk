package Waao::Pages::SMFMeikan;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Html5;
use Waao::Data;
use Waao::Utility;

sub dispatch(){
	my $self = shift;
	
	if($self->{cgi}->param('type')){
		&_meikan_top($self);
	}
	
	return;
}

sub _meikan_top(){
	my $self = shift;
	my $meikantype =$self->{cgi}->param('type');

	my $page = 0;
	$page = $self->{cgi}->param('page') if($self->{cgi}->param('page'));
	my $start = 0 + $page * 30;

	my $flag50 = &_flag50($self);
	my ($meikanname, $sql_str) = &_meikan_name($meikantype);

	my $liststr;
	my $sth = $self->{dbi}->prepare(qq{ select id, inital, keyword, birthday, blood, photo from keyword where $sql_str order by cnt desc limit $start,30} );
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
		$liststr.=qq{<li><a href="/person$row[0]/"><img src="$photo" title="$row[2]の画像" width=115><h3>$row[2]</h3><p>$tmp_birth $blood</p></a></li>};
	}
	my $pre_page = $page - 1;
	my $next_page = $page + 1;
	$liststr.=qq{<center>};
	$liststr.=qq{<a href="/meikan$meikantype-$pre_page/" data-role="button" data-inline="true">前へ</a>} if($page ne 0);
	$liststr.=qq{<a href="/meikan$meikantype-$next_page/" data-role="button" data-inline="true">次へ</a>} if($cnt eq 30);
	$liststr.=qq{</center>};
	
	my $page_str;
	$page_str = $page if($self->{cgi}->param('page'));
	
	my $a = "$meikanname名鑑 $page_strページ目 -スマフォナビ-";
	$self->{html_title} = qq{$a};
	my $b = "$meikanname名鑑,$meikanname,画像,プロフィール,wiki";
	$self->{html_keywords} = qq{$b};
	my $c = "$meikanname名鑑 $page_strページ目 $meikanname名鑑は、スマートフォンでできる$meikanname検索です";
	$self->{html_description} = qq{$c};
	&html_header($self);

print << "END_OF_HTML";
<div data-role="header"> 
<h1>$meikanname名鑑</h1> 
</div>
<a href="/">スマフォMAX</a>&gt;<a href="/person.htm">人物名鑑</a>&gt;$meikanname名鑑

<div data-role="content">
<ul data-role="listview">
$liststr
</ul>
</div>

END_OF_HTML


	&html_footer($self);

	return;
}

sub _flag50(){
	my $self = shift;
	
	if($self->{cgi}->param('type') eq 1){
		return 1;
	}elsif($self->{cgi}->param('type') eq 2){
		return 1;
	}elsif($self->{cgi}->param('type') eq 4){
		return 1;
	}elsif($self->{cgi}->param('type') eq 9){
		return 1;
	}elsif($self->{cgi}->param('type') eq 10){
		return 1;
	}elsif($self->{cgi}->param('type') eq 14){
		return 1;
	}

	return;
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

1;