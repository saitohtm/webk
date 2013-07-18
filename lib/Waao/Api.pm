package Waao::Api;
use Exporter;
@ISA = (Exporter);
@EXPORT = qw(rakuten_api yahoo_api amazon_api kakakucom_api flickr_img_url);

sub rakuten_api(){
	my $api;
	$api->{developer_id} = "5e39057439ff0a07c0f92c9aa10dbdb9";
	$api->{affiliate_id} = "0af1be70.3c43452f.0af1be71.7199b32d";
	return $api;
}

sub yahoo_api(){
	my $api;
	$api->{appid} = "goooooto";
	$api->{affiliate_id} = "ETEGckfa4duxNnHCXO6Y3ycq4QQ-";
	return $api;
}

sub amazon_api(){
	my $api;
	$api->{token} = "AKIAIRGWPLJPBTAAZKBQ";
	$api->{secret_key} = "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";
	$api->{associatetag} = "gooto-22";
	return $api;
}

sub kakakucom_api(){
	my $api;
	$api->{apiaccesskey} = "8183616f9754fd016014fbac968b6770";

	return $api;
}
sub flickr_img_url(){
	my $id = shift;
	my $val = shift;
	my $size = shift;

#	my $farm-id = $val->{farm};
#	my $server-id = $val->{server};
#	my $secret = $val->{secret};
#	my $user-id = $val->{owner};
	
#	my $url;
#	$url->{photo} = qq{http://farm}.$farm-id.qq{static.flickr.com/}.$server-id.qq{/}.$id.qq{_}.$secret.qq{_}.$size.qq{.jpg};
#	$url->{link} = qq{http://www.flickr.com/people/}.$user-id.qq{/}.$id$; 

	return $url;
}
1;