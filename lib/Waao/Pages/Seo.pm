package Waao::Pages::Seo;
use strict;
use base qw(Waao::Pages::Base);


sub dispatch(){
	my $self = shift;

	#ドメイン設定
	my $domain = $ENV{'SERVER_NAME'};
	if($domain eq 'photo.waao.jp'){
		use Waao::Pages::Site::Photo;
		&image_index($self);
	}

	return;
}

1;