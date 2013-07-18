package Waao::SHOP;

use DBI;
use CGI;
use Cache::Memcached;
use Waao::Api;
use XML::Simple;
use LWP::Simple;
use Jcode;
use CGI qw( escape );


sub dispatch_smf(){
	my $self = shift;
	
	if($self->{cgi}->param('area')){
		&_area_list($self);
	}elsif($self->{cgi}->param('id')){
		&_shop_detail($self);
	}elsif($self->{cgi}->param('ticket')){
		&_ticket($self);
	}else{
		&_top($self);
	}
	return;
}
sub _ticket(){
	my $self = shift;

	my $html = &_load_tmpl("shop_ticket.htm");
	my $ticketlist;
	my $sth = $self->{dbi}->prepare(qq{select name,url,photo,`to` from eruca_ticket limit 50});
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		next if($row[3]=~/^HASH/);
		$ticketlist .= qq{<li><a href="$row[1]"><img src="$row[2]" alt="$row[0]" width=115><h3>$row[0]</h3></a></li>\n}
	}
	$html =~s/<!--TIKET-->/$ticketlist/g;

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}

sub _shop_detail(){
	my $self = shift;

	my $id = $self->{cgi}->param('id');
	my $page = $self->{cgi}->param('page');

	my $html = &_load_tmpl("shop_detail.htm");
	my $brand_id;
	my $sth = $self->{dbi}->prepare(qq{select id, name,name_kana, photo, photo_in, url, address, billding_name, tel, closeday, opentime, access, brand_id, brand_name, area_id, area_name from eruca_shop where id = ? });
	$sth->execute($id);
	while(my @row = $sth->fetchrow_array) {
		$brand_id = $row[12];
		$html =~s/<!--SHOPNAME-->/$row[1]/g;
		$html =~s/<!--AREAID-->/$row[14]/g;
		$html =~s/<!--AREA-->/$row[15]/g;
		my $body;
		$body.=qq{<img src="$row[3]">} if($row[3]);
		$body.=qq{<img src="$row[4]">} if($row[4]);
		$body.=qq{<br><a href="$row[5]">店舗サイト</a><br>} if($row[5]);
		$body.=qq{住所：$row[6]<br>} if($row[6]);
		$body.=qq{TEL：$row[8]<br>} if($row[8]);
		$html =~s/<!--BODY-->/$body/g;
		
	}
	my $ticketlist;
	my $sth = $self->{dbi}->prepare(qq{select name,url,photo,`from` from eruca_ticket where brand_id = ? limit 5});
	$sth->execute($brand_id);
	while(my @row = $sth->fetchrow_array) {
		next if($row[3]=~/^HASH/);
		$ticketlist .= qq{<li><a href="$row[1]"><img src="$row[2]" alt="$row[0]" width=115><h3>$row[0]</h3></a></li>\n}
	}
	$html =~s/<!--TIKET-->/$ticketlist/g;

	my $coodlist;
	my $sth = $self->{dbi}->prepare(qq{select name,url,photo from eruca_coordinate where brand_id = ? limit 20});
	$sth->execute($brand_id);
	while(my @row = $sth->fetchrow_array) {
		$coodlist .= qq{<li><a href="$row[1]"><img src="$row[2]" alt="$row[0]" width=115><h3>$row[0]</h3></a></li>\n}
	}
	$html =~s/<!--COOD-->/$coodlist/g;

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}

sub _area_list(){
	my $self = shift;

	my $area = $self->{cgi}->param('area');
	my $page = $self->{cgi}->param('page');

	my $html = &_load_tmpl("shop_list.htm");

	my $shop_list;
	my $area_name;
	my $sth = $self->{dbi}->prepare(qq{select id, name, photo, address, area_name from eruca_shop where area_id = ? });
	$sth->execute($area);
	while(my @row = $sth->fetchrow_array) {
		$area_name = $row[4];
		my $img = $row[2];
		$img = "/img/noimage75.gif" unless($img);
		$shop_list.=qq{<li><a href="/shopid$row[0]"><img src="$img" alt="$row[1]" width=115><h3>$row[1]</h3><p>$row[3]</p></a></li>\n};
	}
	$html =~s/<!--SHOP-->/$shop_list/g;
	$html =~s/<!--AREA-->/$area_name/g;
	$html =~s/<!--AREAID-->/$area/g;
print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}
sub _top(){
	my $self = shift;
	
	my $html = &_load_tmpl("shop_top.htm");
	my $area_list;
	my $sth = $self->{dbi}->prepare(qq{select id, name from eruca_area order by id });
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$area_list.=qq{<li><img src="/img/E231_20.gif" height="20" class="ui-li-icon"><a href="/area$row[0]">$row[1]</a></li>\n};
	}
	$html =~s/<!--AREA-->/$area_list/g;

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

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
	
my $file = qq{/var/www/vhosts/waao.jp/etc/makeshophtm/tmpl_smf/$tmpl};
my $fh;
my $filedata;
open( $fh, "<", $file );
while( my $line = readline $fh ){ 
	$filedata .= $line;
}
close ( $fh );

	return $filedata;
}

sub price_dsp(){
	my $price = shift;

	1 while $price =~ s/(.*\d)(\d\d\d)/$1,$2/;	

	return $price;
}


1;