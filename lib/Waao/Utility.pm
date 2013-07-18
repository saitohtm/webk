package Waao::Utility;
use Exporter;
@ISA = (Exporter);
@EXPORT = qw(str_encode str_decode simple_wiki_upd price_dsp debug_dumper lengthcheck urlcheck mailcheck encodestr decodestr input_str access_check);
use URI::Escape;
use Digest::MD5;

sub access_check(){
	my $accesstype = 1;
	
    if( $ENV{'REMOTE_HOST'} =~/docomo/i ){
		$accesstype = 2;
    }elsif( $ENV{'REMOTE_HOST'} =~/ezweb/i ){
		$accesstype = 2;
    }elsif( $ENV{'REMOTE_HOST'} =~/^J-PHONE|^Vodafone|^SoftBank/i ){
		$accesstype = 2;
    }elsif( $ENV{'REMOTE_HOST'} =~/panda-world\.ne\.jp/i ){
		$accesstype = 3;
	}elsif( $ENV{'HTTP_USER_AGENT'} =~/iPhone|iPod|Android|dream|CUPCAKE|blackberry|webOS|incognito|webmate/i ){
		$accesstype = 3;
	}elsif( $ENV{'HTTP_USER_AGENT'} =~/Google-Site/i ){
    }elsif( $ENV{'REMOTE_HOST'} =~/hinocatv/i ){
    }
	return $accesstype;
}

sub str_encode(){
	my $str = shift;
	return uri_escape($str);
}

sub str_decode() {
  my $str = shift;
  return uri_unescape($str);
}

sub simple_wiki_upd(){
	my $wiki = shift;
	my $len = shift;
	
	$wiki =~s/\&lt\;br\&gt\;//gi;
	$wiki =~s/\&lt\;br\/\&gt\;//gi;
	$wiki =~s/\&lt\;br \/\&gt\;//gi;
	$wiki =~s/\<br\>//gi;
	$wiki =~s/\<br\/\>//gi;
	$wiki =~s/\<br \/\>//gi;
	$wiki =~s/ //gi;
	$wiki = substr($wiki, 0, $len) if($len);
	$wiki .= qq{...}  if($len);

	return $wiki;
}

sub price_dsp(){
	my $price = shift;

	1 while $price =~ s/(.*\d)(\d\d\d)/$1,$2/;	

	return $price;
}

sub debug_dumper(){
	my $val = shift;
	
#	use Data::Dumper;
#	warn "START ##############################################";
#	warn Dumper $val;
#	warn "END   ##############################################";
	return;
}

sub lengthcheck(){
	use strict;
	my $str = shift;
	my $low = shift;
	my $high = shift;

	if(length($str) < $low){
		return 1;	
	}elsif(length($str) > $high){
		return 1;	
	}else{
		return;	
	}
}
sub mailcheck(){
	use strict;
	my $str = shift;
	return unless($str);
    if($str=~/^[^@]+@[^.]+\..+/){
        return;
    }else{
        return 1;
    }
}

sub urlcheck(){
	use strict;
	my $str = shift;
	return unless($str);

    if ( $str =~ /^http:\/\// ) {
		return;
	}else{
		return 1;
	}
}

sub encodestr(){
	my $plaintext = shift;
	my $key = shift;
	$plaintext .= 'goo';

    my $md5 = new Digest::MD5();
    $md5->add($plaintext);
	return $md5->hexdigest();

}

sub decodestr(){
	my $ciphertext = shift;
	my $key = shift;
	$key .= 'goo';

}

sub input_str(){
	my $str = shift;
	
	$str =~ s/</&lt;/g;
	$str =~ s/>/&gt;/g;
	$str =~ s/\"/&quot;/g;
	
	return $str;
}


1;