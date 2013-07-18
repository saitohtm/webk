package Waao::Youtube;
use strict;
#use Data::Dumper;
use Jcode;
use CGI qw( escape );

# /youtube/		topページ

sub dispatch(){
	my $self = shift;
	
	if($self->{cgi}->param('q') eq 'list-area'){
	}else{
		&_top($self);
	}

	return;
}

sub _top(){
	my $self = shift;

print << "END_OF_HTML";
Content-type: application/xhtml+xml; charset=UTF-8

<!DOCTYPE HTML PUBLIC "-//W3C//DTD Compact HTML 1.0 Draft //EN"> 
<html>
<head>
<meta http-equiv="content-type" CONTENT="text/html;charset=UTF-8">
<meta name="robots" content="index,follow">
<meta http-equiv="Expires" content="0">
<meta http-equiv="Pragma" CONTENT="no-cache">
<meta http-equiv="Cache-Control" CONTENT="no-cache">
</head>
<title>MotoGP</title>
<body>

aaaa


</body>
</html>

END_OF_HTML

	return;
}
1;
