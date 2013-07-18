package Waao::Pages::SMFEditPhoto;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Html5;
use Waao::Data;
use Waao::Utility;

sub dispatch(){
	my $self = shift;

	if($self->{cgi}->param('photoid')){
		&_bestphoto($self);
	}elsif($self->{cgi}->param('id')){
		&_avupd($self);
	}else{
		&_list($self);
	}
	return;
}

sub _bestphoto(){
	my $self = shift;
	
eval{
	my $sth = $self->{dbi}->prepare(qq{ update photo set good = good + 100 where id = ? limit 1} );
	$sth->execute( $self->{cgi}->param('photoid') );
};
	return;
}

sub _avupd(){
	my $self = shift;
	
eval{
	my $sth = $self->{dbi}->prepare(qq{ update keyword set av = 1 where id = ? limit 1} );
	$sth->execute( $self->{cgi}->param('id') );
};
	return;
}

sub _list(){
	my $self = shift;
	my $page = $self->{cgi}->param('page');
	$page=0 unless($page);
	
	&html_header($self);
	
	my $liststr;
	my $cnt;
	my $startpage = $page * 10;
	my $pagenext = $page + 1;
	my 	$sth = $self->{dbi}->prepare(qq{ select id, keyword, birthday, blood, photo, cnt, av from keyword order by cnt desc limit ?, 10} );
	$sth->execute($startpage);
	while(my @row = $sth->fetchrow_array) {
		$liststr.=qq{<li data-role="list-divider">$row[1] ($row[5])</li>};
		unless($row[6]){
			$liststr.=qq{<li><a href="/edit_photo.html?id=$row[0]&page=$page" target="_blank">アダルト登録</a></li>};
		}

		my 	$sth2 = $self->{dbi}->prepare(qq{ select id, url, good from photo where keywordid = ? order by good desc limit 30} );
		$sth2->execute($row[0]);
		while(my @row2 = $sth2->fetchrow_array) {
			$liststr.=qq{<a href="/edit_photo.html?photoid=$row2[0]&page=$page" target="_blank"><img src="$row2[1]" width=115></a>};
		}
		$cnt++;
	}

	$liststr .= qq{<li><img src="/img/E23C_20.gif" class="ui-li-icon"><a href="/edit_photo.html?page=$pagenext">次へ</a></li>} if($cnt eq 10);
	
print << "END_OF_HTML";
<div data-role="content">
<ul data-role="listview">
$liststr
</ul>
</div>
END_OF_HTML
	
&html_footer($self);
	
	return;
}


1;