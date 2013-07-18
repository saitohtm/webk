package Waao::Pages::Uc;
use strict;
use CGI;

sub dispatch(){

	my $q = new CGI;
	my $ucid = $q->param('ucid');
    if( $ENV{'REMOTE_HOST'} =~/docomo/i ){
		print qq{Location:http://click.oni.ktaf.jp/?a=FlC5lLCyOc&s=X7F2G8rQ8z&guid=on \n\n} if($ucid eq 1);
    }elsif( $ENV{'REMOTE_HOST'} =~/ezweb/i ){
		print qq{Location:http://goo.to/ \n\n} if($ucid eq 1);
    }elsif( $ENV{'REMOTE_HOST'} =~/^J-PHONE|^Vodafone|^SoftBank/i ){
    }elsif( $ENV{'REMOTE_HOST'} =~/panda-world\.ne\.jp/i ){
	}
	
	return;
	
}

1;