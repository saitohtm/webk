package Waao::Wiki;

use lib qw(/var/www/vhosts/goo.to/etc/lib /var/www/vhosts/goo.to/lib/Waao);
use DBI;
use CGI;
use Cache::Memcached;
use Date::Simple;

sub dispatch(){
	my $self = shift;

	if($page = $self->{cgi}->param('page')){
		&_wikilist($self);
	}elsif($page = $self->{cgi}->param('id')){
		&_wiki($self);
	}else{
		&_top($self);
	}

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}

sub _wikilist(){
	my $self = shift;

	my $html = &_load_tmpl("wiki_list.html");
	$html = &_parts_set($html);

	my $list;
	my $sth = $self->{dbi}->prepare(qq{select page_id, page_namespace, page_title, page_restrictions, page_counter, page_is_redirect, page_is_new, page_random, page_touched, page_latest, page_len from page order by page_id asc limit 100});
	$sth->execute();
	while(my @row = $sth->fetchrow_array){
		my ($page_id, $page_namespace, $page_title, $page_restrictions, $page_counter, $page_is_redirect, $page_is_new, $page_random, $page_touched, $page_latest, $page_len) = @row;
		$list.=qq{page_title::$page_title	<br />};
		$list.=qq{page_restrictions::$page_restrictions	<br />};

		my $sth2 = $self->{dbi}->prepare(qq{ select rev_id, rev_page, rev_text_id, rev_comment, rev_user, rev_user_text, rev_timestamp, rev_minor_edit, rev_deleted, rev_len, rev_parent_id from revision  where rev_page = ? limit 1 } );
		$sth2->execute($page_id);
		while(my @row2 = $sth2->fetchrow_array) {
			my ($rev_id, $rev_page, $rev_text_id, $rev_comment, $rev_user, $rev_user_text, $rev_timestamp, $rev_minor_edit, $rev_deleted, $rev_len, $rev_parent_id)=@row2;
			$list.=qq{rev_comment::$rev_comment	<br />};
			$list.=qq{rev_user_text::$rev_user_text	<br />};
			$list.=qq{rev_timestamp::$rev_timestamp	<br />};

			my $sth3 = $self->{dbi}->prepare(qq{ select old_id, old_text, old_flags from text where old_id = ? limit 1 } );
			$sth3->execute($rev_text_id);
			while(my @row3 = $sth3->fetchrow_array) {
				my ($old_id, $old_text, $old_flags) = $row3;
				$list.=qq{old_text::$old_text	<br />};
				$list.=qq{old_flags::$old_flags	<br />};
			}

		}

	}

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$list
END_OF_HTML

	return;
}

sub _top(){
	my $self = shift;

	my $html = &_load_tmpl("wiki_top.html");
	$html = &_parts_set($html);

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	my $sth = $self->{dbi}->prepare(qq{select * from revision order by rev_id desc limit 5});
	$sth->execute();
	while(my @row = $sth->fetchrow_array){
print "AAAAAAAAA";
	}
	

#	my $sth2 = $self->{dbi}->prepare(qq{select type,img1,img2,img3,img4,img5 from app_android_img where app_id = ? limit 1});
#	$sth2->execute($row[6]);
#	while(my @row2 = $sth2->fetchrow_array) {
#		my ($type,$img1,$img2,$img3,$img4,$img5) = @row2;
#		$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img1" alt="$row[0]" /><img src="$img1" alt="$row[0]" class="preview" /></a></li>} if($img1);
#		$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img2" alt="$row[0]" /><img src="$img2" alt="$row[0]" class="preview" /></a></li>} if($img2);
#		$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img3" alt="$row[0]" /><img src="$img3" alt="$row[0]" class="preview" /></a></li>} if($img3);
#		$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img4" alt="$row[0]" /><img src="$img4" alt="$row[0]" class="preview" /></a></li>} if($img4);
#		$shotimgs .= qq{<li><a href="javascript:void(0);"><img src="$img5" alt="$row[0]" /><img src="$img5" alt="$row[0]" class="preview" /></a></li>} if($img5);
#	}

	return;
}

sub new(){
	my $class = shift;
	my $q = new CGI;

	my $self={
			'mem' => &_mem_connect(),
			'dbi' => &_db_connect(),
			'cgi' => $q
			};
	
	return bless $self, $class;
}

# memcached connect
sub _mem_connect(){

	my $memd = new Cache::Memcached {
    'servers' => [ "localhost:11211" ],
    'debug' => 0,
    'compress_threshold' => 1_000,
	};

	return $memd;
}

# db connect
sub _db_connect(){
    my $dsn = 'DBI:mysql:waao';
    my $user = 'mysqlweb';
    my $password = 'WaAoqzxe7h6yyHz';

    my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 0, AutoCommit => 1, PrintError => 0});
	
	return $dbh;
}

sub _load_tmpl(){
	my $tmpl = shift;
	
my $file = qq{/var/www/vhosts/goo.to/etc/makehtml/goo/tmpl/$tmpl};
my $fh;
my $filedata;
open( $fh, "<", $file );
while( my $line = readline $fh ){ 
	$filedata .= $line;
}
close ( $fh );

	return $filedata;
}

sub _parts_set(){
	my $html = shift;

	my $header_top = &_load_tmpl("header_top.html");
	$html =~s/<!--HEADER_TOP-->/$header_top/g;

	my $header = &_load_tmpl("header.html");
	$html =~s/<!--HEADER-->/$header/g;

	my $top_ad = &_load_tmpl("topad.html");
	$html =~s/<!--TOPAD-->/$top_ad/g;

	my $topmenu = &_load_tmpl("topmenu.html");
	$html =~s/<!--TOPMENU-->/$topmenu/g;

	my $topmenu = &_load_tmpl("body.html");
	$html =~s/<!--BODY-->/$topmenu/g;

	my $topslider = &_load_tmpl("topslider.html");
	$html =~s/<!--SLIDER-->/$topslider/g;

	my $footer = &_load_tmpl("footer.html");
	$html =~s/<!--FOOTER-->/$footer/g;

	my $header = &_load_tmpl("release.html");
	$html =~s/<!--RELEASE-->/$header/g;

	return $html;
}


sub DESTROY{
	my $self = shift;

	$self->{db}->disconnect if($self->{db});

	return;
}


1;