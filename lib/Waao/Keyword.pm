package Waao::Keyword;
use lib qw(/var/www/vhosts/goo.to/etc/lib /var/www/vhosts/goo.to/lib/Waao);

use DBI;
use CGI;
use Jcode;
use Date::Simple;
use Apis;

sub dispatch_check(){
	my $self = shift;
	
	if($self->{cgi}->param('id')){
		&_del_photo($self);
	}else{
		&_del_list($self);
	}
	return;
}
sub _del_photo(){
	my $self = shift;
	
if($self->{cgi}->param('del')){
eval{
	my $sth = $self->{dbi}->prepare(qq{update photo set good = 0 where id = ? limit 1});
	$sth->execute($self->{cgi}->param('id'));
};
}	

if($self->{cgi}->param('good')){
eval{
	my $sth = $self->{dbi}->prepare(qq{update photo set good = good + 100 where id = ? limit 1});
	$sth->execute($self->{cgi}->param('id'));
};
}	

if($self->{cgi}->param('bad')){
eval{
	my $sth = $self->{dbi}->prepare(qq{update photo set good = 30 where id = ? limit 1});
	$sth->execute($self->{cgi}->param('id'));
};
}	

	
print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

OK
END_OF_HTML

	return;
}

sub _del_list(){
	my $self = shift;

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

END_OF_HTML

my $page = $self->{cgi}->param('page');

my $start = $page * 300;

my $sth = $self->{dbi}->prepare(qq{select id, url, keyword from photo order by good desc limit $start,300});
$sth->execute();
while(my @row = $sth->fetchrow_array) {
	print qq{<img src="$row[1]" width=100>$row[2] <a href="/imgcheck.htm?id=$row[0]&del=1" target="_blank">削除</a>　<a href="/imgcheck.htm?id=$row[0]&good=1" target="_blank">評価</a>　　<a href="/imgcheck.htm?id=$row[0]&bad=1" target="_blank">マイナス評価</a><br>};

}
my $page = $page + 1;
print qq{<br><a href="imgcheck.htm?page=$page">次へ</a><br>};
	return;
}

sub dispatch(){
	my $self = shift;
	
	if($self->{cgi}->param('keyword_ins')){
		&_keyword_ins($self);
	}else{
		&_input($self);
	}
	return;
}

sub _keyword_ins(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('keyword');

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

END_OF_HTML

	&get_photo($self->{dbi},$keyword);
	&get_qanda($self->{dbi},$keyword);
	&get_news($self->{dbi},$keyword);

 	my $html;
	$html = &_load_tmpl("keyword_ins.html",$self);
	$html = &_parts_set($html,$self);

	&_output($html);

	
	return;
}

sub _input(){
	my $self = shift;

 	my $html;
	$html = &_load_tmpl("keyword_inp.html",$self);
	$html = &_parts_set($html,$self);

	&_output($html);

	return;
}
sub _parts_set(){
	my $html = shift;
	my $self = shift;

	# meta
	my $meta = &_load_tmpl("meta.html", $self);
	my $metatop = &_load_tmpl("metatop.html", $self);
	# header
	my $header = &_load_tmpl("header.html", $self);
	# footer
	my $footer = &_load_tmpl("footer.html", $self);
	# slider
	my $side_free = &_load_tmpl("side_free.html", $self);
	$html =~s/<!--SIDE_FREE-->/$side_free/g;

	$html =~s/<!--META-->/$meta/g;
	$html =~s/<!--METATOP-->/$metatop/g;
	$html =~s/<!--HEADER-->/$header/g;
	$html =~s/<!--FOOTER-->/$footer/g;

	# slider
	my $social_tag = &_load_tmpl("social_tag.html", $self);
	$html =~s/<!--SOCIAL_TAG-->/$social_tag/g;

	# ad
	my $ad_header = &_load_tmpl("ad_header.html", $self);
	$html =~s/<!--AD_HEADER-->/$ad_header/g;

	return $html;
}

sub new(){
	my $class = shift;
	my $q = new CGI;

	my $self={
			'dbi' => &_db_connect(),
			'cgi' => $q
			};
	
	return bless $self, $class;
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
	my $self = shift;
my $file;
$file = qq{/var/www/vhosts/goo.to/etc/makehtml/goo/tmpl/$tmpl};

my $fh;
my $filedata;
open( $fh, "<", $file );
while( my $line = readline $fh ){ 
	$filedata .= $line;
}
close ( $fh );

	return $filedata;
}
sub DESTROY{
	my $self = shift;

	$self->{db}->disconnect if($self->{db});

	return;
}

sub _output(){
	my $html = shift;
	
print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}

1;