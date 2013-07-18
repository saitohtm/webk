package Waao::Pages::Sp;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Html;
use Waao::Utility;

sub dispatch(){
	my $self = shift;
	my $tmpl = $self->{cgi}->param('tmpl');
	$tmpl =~s/-/\//g;
	
	my $ad = &html_google_ad($self);

	my $adstr = qq{<center>$ad</center>};

print << "END_OF_HTML";
Content-type: text/html; charset=shift_jis

END_OF_HTML

my $file = qq{/var/www/vhosts/waao.jp/tmpl/$tmpl}.qq{.html};
my $fh;
my $filedata;
my $replace_ad = qq{<!--AD-->};
open( $fh, "<", $file );
while( my $line = readline $fh ){ 
	$line =~s/$replace_ad/$adstr/;
	$filedata .= $line;
}
close ( $fh );

print << "END_OF_HTML";
$filedata
END_OF_HTML

	return;
}

1;