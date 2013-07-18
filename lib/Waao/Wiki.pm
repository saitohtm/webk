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
	return;
}

sub _wiki(){
	my $self = shift;

	my $html = &_load_tmpl("wiki.html");
	$html = &_parts_set($html);
	my $id = $self->{cgi}->param('id');
	my $list;
	my $sth = $self->{dbi}->prepare(qq{ select rev_id, wikipedia, linklist, person, sex, birthday,keyword from wikipedia where rev_id = ?} );
	$sth->execute($id);
	while(my @row = $sth->fetchrow_array){
		$html =~s/<!--KEYWORD-->/$row[6]/g;
		$html =~s/<!--WIKI-->/$row[1]/g;
	}

	$html =~s/<!--LIST-->/$list/g;

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
	my $page  = $self->{cgi}->param('page');
	my $start = $page * 50;
	my $list;
	my $sth = $self->{dbi}->prepare(qq{ select rev_id, wikipedia, linklist, person, sex, birthday,keyword from wikipedia limit $start,50} );
	$sth->execute();
	while(my @row = $sth->fetchrow_array){
		$list .=qq{<a href="/dictionary-id-$row[0]/">$row[6]</a><br>};
	}

	my $pager = &_pager($page,"dictionary");
	$html =~s/<!--LIST-->/$list/g;
	$html =~s/<!--PAGER-->/$pager/g;

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}

sub _top(){
	my $self = shift;

	my $html = &_load_tmpl("wiki_top.html");
	$html = &_parts_set($html);

	my $list;
	my $sth = $self->{dbi}->prepare(qq{ select rev_id, wikipedia, linklist, person, sex, birthday,keyword from wikipedia limit 50} );
	$sth->execute();
	while(my @row = $sth->fetchrow_array){
		$list .=qq{<a href="/dictionary-id-$row[0]/">$row[6]</a><br>};
	}

	my $pager = &_pager(1,"dictionary");
	$html =~s/<!--PAGER-->/$pager/g;
	$html =~s/<!--LIST-->/$list/g;

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML


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

sub _pager(){
	my $page = shift;
	my $type = shift;
	my $pagelist;

	$pagelist .= qq{<div class="pagination">\n};
	$pagelist .= qq{<ul>\n};
	if($page == 1){
	   	$pagelist .= qq{<li class="prev disabled"><a href="/$type-1/">&larr; Previous</a></li>\n};
	}else{
		my $preno = $page - 1;
	   	$pagelist .= qq{<li class="prev"><a href="/$type-$preno/">&larr; Previous</a></li>\n};
	}
	my $pageno;
	for(my $i=0; $i<10; $i++){
		$pageno = $page + $i;
		if($page eq $pageno){
		    $pagelist .= qq{<li class="active"><a href="/$type-$pageno/">$pageno</a></li>\n};
		}else{
		    $pagelist .= qq{<li><a href="/$type-$pageno/">$pageno</a></li>\n};
		}
	}
	$pageno++;
	my $page_next = $page + 1;
    $pagelist .= qq{<li class="next"><a href="/$type-$page_next/">Next &rarr;</a></li>\n};
    $pagelist .= qq{</ul>\n};
    $pagelist .= qq{</div>\n};

	return $pagelist;
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