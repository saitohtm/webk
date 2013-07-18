package Waao::Session;
use strict;

sub new(){
	my $class = shift;
	my $session_id = shift;
	
	my $self={
			'_session_id' => &_create_session_id($session_id),
			'_data' => undef
			};
	
	return bless $self, $class;
}

sub _create_session_id(){
	my $session_id = shift;

	my $session_atag;
	my $session_formtag;
	if( $ENV{'HTTP_X_DCMGUID'} ){
		# docomo 端末
		$session_id = $ENV{'HTTP_X_DCMGUID'};
	}elsif( $ENV{'HTTP_X_UP_SUBNO'} ){
		# au 端末
		$session_id = $ENV{'HTTP_X_UP_SUBNO'};
	}elsif($ENV{'HTTP_X_JPHONE_UID'}){
		# softbank
		$session_id = $ENV{'HTTP_X_JPHONE_UID'};
	}elsif($ENV{'HTTP_USER_AGENT'} =~/^J-PHONE|^Vodafone|^SoftBank/){
		if($ENV{'HTTP_USER_AGENT'} =~ /\/SN([A-Za-z0-9]+)\ /){
			# softbank
			$session_id = $1;
		}
	}else{
		# PCの場合
		$session_id = $ENV{'REMOTE_ADDR'};
	}

	$session_id = $ENV{'REMOTE_ADDR'} unless($session_id);
	
	return $session_id;
}

sub DESTROY{
}
1;
