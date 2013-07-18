package Waao::Pages::Tmpl;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Html;
use Waao::Utility;

sub dispatch(){
	my $self = shift;
	my $tmpl = shift;
	
print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

END_OF_HTML

my $file = qq{/var/www/vhosts/waao.jp/tmpl/$tmpl}.qq{.html};
my $fh;
my $filedata;
open( $fh, "<", $file );
while( my $line = readline $fh ){ 
	$filedata .= $line;
}
close ( $fh );

print << "END_OF_HTML";
$filedata
END_OF_HTML

	return;
}

1;