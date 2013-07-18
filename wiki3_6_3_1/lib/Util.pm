################################################################################
# <p>
#   FSWikiÁ´ÂÎ¤Ç»ÈÍÑ¤µ¤EEæ¡¼¥Æ¥£¥EÆ¥£´Ø¿ô·²¤òÄó¶¡¤¹¤Eâ¥¸¥å¡¼¥EÇ¤¹¡£
# </p>
################################################################################
package Util;
use strict;

#===============================================================================
# <p>
#   die¤Èexit¤Î¥ª¡¼¥Ğ¥é¥¤¥ÉÁàºûÀò¹Ô¤¤¤Ş¤¹¡£
# </p>
#===============================================================================
sub override_die{
	our @original_exit_handler;
	@original_exit_handler or @original_exit_handler = (\&CORE::GLOBAL::die,\&CORE::GLOBAL::exit);
	*CORE::GLOBAL::die = \&Util::_die;
	*CORE::GLOBAL::exit = \&Util::_exit;
}

BEGIN {
	require Util;
#	*CORE::GLOBAL::die = \&Util::_die;
#	*CORE::GLOBAL::exit = \&Util::_exit;
	exists($ENV{MOD_PERL}) or override_die();
}

#===============================================================================
# <p>
#   °ú¿ô¤ÇÅÏ¤µ¤E¿Ê¸»úÎó¤òURL¥¨¥ó¥³¡¼¥É¤·¤ÆÊÖ¤·¤Ş¤¹¡£
# </p>
# <pre>
# $str = Util::url_encode($str)
# </pre>
#===============================================================================
sub url_encode {
	my $retstr = shift;
	$retstr =~ s/([^ 0-9A-Za-z])/sprintf("%%%.2X", ord($1))/eg;
	$retstr =~ tr/ /+/;
	return $retstr;
}

#===============================================================================
# <p>
#   °ú¿ô¤ÇÅÏ¤µ¤E¿Ê¸»úÎó¤òURL¥Ç¥³¡¼¥É¤·¤ÆÊÖ¤·¤Ş¤¹¡£
# </p>
# <pre>
# $str = Util::url_decode($str);
# </pre>
#===============================================================================
sub url_decode{
	my $retstr = shift;
	$retstr =~ tr/+/ /;
	$retstr =~ s/%([A-Fa-f0-9]{2})/pack("c",hex($1))/ge;
	return $retstr;
}

#===============================================================================
# <p>
#   Cookie¤Îpath¤Ë»ØÄê¤¹¤E¸»úÎó¤ò¼èÆÀ¤·¤Ş¤¹¡£
# </p>
# <pre>
# $path = Util::cookie_path($wiki);
# </pre>
#===============================================================================
sub cookie_path {
	my $wiki = shift;
	my $script_name = quotemeta($wiki->config('script_name'));
	my $path = $ENV{'REQUEST_URI'};
	$path =~ s/\?.*//;
	$path =~ s/$script_name$//;
	return $path;
}

#===============================================================================
# <p>
#   ¥Ç¥£¥E¯¥È¥ê¡¢¥Õ¥¡¥¤¥E¾¡¢³ÈÄ¥»Ò¤ò·Eç¤·¤Æ¥Õ¥¡¥¤¥E¾¤òÀ¸À®¤·¤Ş¤¹¡£
# </p>
# <pre>
# my $filename = Util::make_filename(¥Ç¥£¥E¯¥È¥E¾,¥Õ¥¡¥¤¥E¾,³ÈÄ¥»Ò);
# </pre>
#===============================================================================
sub make_filename {
	my $dir  = shift;
	my $file = shift;
	my $ext  = shift;
	
	return $dir."/".$file.".".$ext;
}

#===============================================================================
# <p>
#   °ú¿ô¤ÇÅÏ¤µ¤E¿Ê¸»úÎó¤ÎHTML¥¿¥°¤ò¥¨¥¹¥±¡¼¥×¤·¤ÆÊÖ¤·¤Ş¤¹¡£
# </p>
# <pre>
# $str = Util::escapeHTML($str);
# </pre>
#===============================================================================
sub escapeHTML {
	my($retstr) = shift;
	my %table = (
		'&' => '&amp;',
		'"' => '&quot;',
		'<' => '&lt;',
		'>' => '&gt;',
	);
	$retstr =~ s/([&\"<>])/$table{$1}/go;
	$retstr =~ s/&amp;#([0-9]{1,5});/&#$1;/go;
	$retstr =~ s/&#(0*(0|9|10|13|38|60|62));/&amp;#$1;/g;
#	$retstr =~ s/&amp;([a-zA-Z0-9]{2,8});/&$1;/go;
	return $retstr;
}


#===============================================================================
# <p>
#   ÆEÕ¤Equot;yyyyÇ¯mm·ûdÆEhh»şmiÊ¬ssÉÃ&quot;·Á¼°¤Ë¥Õ¥©¡¼¥Ş¥Ã¥È¤·¤Ş¤¹¡£
# </p>
# <pre>
# my $date = Util::format_date(time());
# </pre>
#===============================================================================
sub format_date {
	my $t = shift;
	my ($sec, $min, $hour, $mday, $mon, $year) = localtime($t);
	return sprintf("%04dÇ¯%02d·E02dÆE%02d»ş%02dÊ¬%02dÉÃ",
	               $year+1900,$mon+1,$mday,$hour,$min,$sec);
}

#===============================================================================
# <p>
#   Ê¸»úÎó¤ÎÎ¾Ã¼¤Î¶õÇò¤òÀÚ¤EûÀÈ¤·¤Ş¤¹¡£
# </p>
# <pre>
# $text = Util::trim($text);
# </pre>
#===============================================================================
sub trim {
	my $text = shift;
	if(!defined($text)){
		return "";
	}
	$text =~ s/^(?:\s)+//o;
	$text =~ s/(?:\s)+$//o;
	return $text;
}


#===============================================================================
# <p>
#   ¥¿¥°¤òºEE·¤ÆÊ¸»úÎó¤Î¤ß¤ò¼èÆÀ¤·¤Ş¤¹¡£
# <p>
# <pre>
# my $html = "<B>Ê¸»úÎE/B>";
# # &lt;B&gt;¤È&lt;/B&gt;¤òºEE·¡¢&quot;Ê¸»úÎEquot;¤Î¤ß¼èÆÀ
# my $text = Util::delete_tag($html);
# </pre>
#===============================================================================
sub delete_tag {
	my $text = shift;
	$text =~ s/<(.|\s)+?>//g;
	return $text;
}

#===============================================================================
# <p>
#   ¿ôÃÍ¤«¤É¤¦¤«¥Á¥§¥Ã¥¯¤·¤Ş¤¹¡£¿ôÃÍ¤Î¾Eç¤Ï¿¿¡¢¤½¤¦¤Ç¤Ê¤¤¾Eç¤Ïµ¶¤òÊÖ¤·¤Ş¤¹¡£
# </p>
# <pre>
# if(Util::check_numeric($param)){
#   # À°¿ô¤Î¾Eç¤Î½èÍı
# } else {
#   # À°¿ô¤Ç¤Ê¤¤¾Eç¤Î½èÍı
# }
# </pre>
#===============================================================================
sub check_numeric {
	my $text = shift;
	if($text =~ /^[0-9]+$/){
		return 1;
	} else {
		return 0;
	}
}


#===============================================================================
# <p>
#   ´ÉÍı¼Ô¤Ë¥á¡¼¥EòÁ÷¿®¤·¤Ş¤¹¡£
#   setup.dat¤ÎÀßÄEâÍÆ¤Ë±ş¤¸¤Æsendmail¥³¥Ş¥ó¥É¤â¤·¤¯¤ÏSMTPÄÌ¿®¤Ë¤è¤Ã¤Æ¥á¡¼¥E¬Á÷¿®¤µ¤EŞ¤¹¡£
#   ¤É¤Á¤é¤âÀßÄê¤µ¤EÆ¤¤¤Ê¤¤¾Eç¤ÏÁ÷¿®¤ò¹Ô¤Eº¡¢¥¨¥é¡¼¤Ë¤â¤Ê¤ê¤Ş¤»¤ó¡£
#   SMTP¤ÇÁ÷¿®¤¹¤EEç¡¢¤³¤Î¥á¥½¥Ã¥É¤ò¸Æ¤Ó½Ğ¤·¤¿»şÅÀ¤ÇNet::SMTP¤¬use¤µ¤EŞ¤¹¡£
# </p>
# <pre>
# Util::send_mail($wiki,·E¾,ËÜÊ¸);
# </pre>
#===============================================================================
sub send_mail {
	my $wiki    = shift;
	my $subject = Jcode->new(shift)->mime_encode();
	my $content = &Jcode::convert(shift,'jis');
	
	if(($wiki->config('send_mail') eq "" && $wiki->config('smtp_server') eq "") ||
	   $wiki->config('admin_mail') eq ""){
		return;
	}

	my ($sec, $min, $hour, $day, $mon, $year, $wday) = localtime(time);
	my $wday_str  = ('Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat')[$wday];
	my $mon_str   = ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec')[$mon];
	my $date = sprintf("%s, %02d %s %4d %02d:%02d:%02d +0900", $wday_str, $day, $mon_str, $year+1900, $hour, $min, $sec);
	
	my $admin_mail = $wiki->config('admin_mail');
	foreach my $to (split(/,/,$admin_mail)){
		$to = trim($to);
		next if($to eq '');
		my $mail = "Subject: $subject\n".
		           "From: $to\n".
		           "To: $to\n".
		           "Date: $date\n".
		           "Content-Transfer-Encoding: 7bit\n".
		           "Content-Type: text/plain; charset=\"ISO-2022-JP\"\n".
		           "\n".
		           $content;
		
		# sendmail¥³¥Ş¥ó¥É¤ÇÁ÷¿®
		if($wiki->config('send_mail') ne ""){
			open(MAIL,"| ".$wiki->config('send_mail')." ".$to);
			print MAIL $mail;
			close(MAIL);
			
		# Net::SMTP¤ÇÁ÷¿®
		} else {
			eval("use Net::SMTP;");
			my $smtp = Net::SMTP->new($wiki->config('smtp_server'));
			$smtp->mail($to);
			$smtp->to($to);
			$smtp->data();
			$smtp->datasend($mail);
			$smtp->quit();
		}
	}
}

#===============================================================================
# <p>
#   ¥¯¥é¥¤¥¢¥ó¥È¤¬·ÈÂÓÅÅÏÃ¤«¤É¤¦¤«¥Á¥§¥Ã¥¯¤·¤Ş¤¹¡£
#   ·ÈÂÓÅÅÏÃ¤Î¾Eç¤Ï¿¿¡¢¤½¤¦¤Ç¤Ê¤¤¾Eç¤Ïµ¶¤òÊÖ¤·¤Ş¤¹¡£
# </p>
# <pre>
# if(Util::handyphone()){
#   # ·ÈÂÓÅÅÏÃ¤Î¾Eç¤Î½èÍı
# } else {
#   # ·ÈÂÓÅÅÏÃ¤Ç¤Ê¤¤¾Eç¤Î½èÍı
# }
# </pre>
#===============================================================================
sub handyphone {
	my $ua = $ENV{'HTTP_USER_AGENT'};
	if(!defined($ua)){
		return 0;
	}
	if($ua=~/^DoCoMo\// || $ua=~ /^J-PHONE\// || $ua=~ /UP\.Browser/ || $ua=~ /\(DDIPOCKET\;/ || $ua=~ /\(WILLCOM\;/ || $ua=~ /^Vodafone\// || $ua=~ /^SoftBank\//){
		return 1;
	} else {
		return 0;
	}
}

#===============================================================================
# load_config_hash´Ø¿ô¤Ç»ÈÍÑ¤¹¤E¢¥ó¥¨¥¹¥±¡¼¥×ÍÑ´Ø¿
#===============================================================================
{
	my %table = ("\\\\" => "\\", "\\n" => "\n", "\\r" => "\r");

	sub _unescape {
		my $value = shift;
		$value =~ s/(\\[\\nr])/$table{$1}/go;
		return $value;
	} 
}

#===============================================================================
# <p>
#   ÀßÄEÕ¥¡¥¤¥Eò³ÊÇ¼¤¹¤EÇ¥£¥E¯¥È¥ê¡Ê¥Ç¥Õ¥©¥EÈ¤Ç¤Ï./config¡Ë¤«¤é»ØÄê¤·¤¿¥Õ¥¡¥¤¥EòÆÉ¤ß¹ş¤ß¡¢
#   ¥Ï¥Ã¥·¥å¥EÕ¥¡¥Eó¥¹¤È¤·¤Æ¼èÆÀ¤·¤Ş¤¹¡£Âè°Eú¿ô¤Ë¤Ï$wiki¤òÅÏ¤·¡¢ÂèÆó°ú¿ô¤Ç¥Õ¥¡¥¤¥E¾¤ò»ØÄê¤·¤Ş¤¹¡£
# </p>
# <pre>
# my $hashref = Util::load_config_hash($wiki, &quot;hoge.dat&quot;);
# </pre>
#===============================================================================
sub load_config_hash {
	my $wiki     = shift;
	my $filename = shift;
	my $text = &load_config_text($wiki,$filename);
	my @lines = split(/\n/,$text);
	my $hash = {};
	foreach my $line (@lines){
		$line = &trim($line);
		if(index($line,"#")==0 || $line eq "\n" || $line eq "\r" || $line eq "\r\n"){
			next;
		}
		my ($name, @spl) = map {/^"(.*)"$/ ? scalar($_ = $1, s/\"\"/\"/g, $_) : $_}
		                     ("=$line" =~ /=\s*(\"[^\"]*(?:\"\"[^\"]*)*\"|[^=]*)/g);
		
		$name  = &trim(_unescape($name));
		my $value = &trim(_unescape(join('=', @spl)));
		
		if($name ne ''){
			$hash->{$name} = $value;
		}
	}
	return $hash;
}

#===============================================================================
# <p>
#   ÀßÄEÕ¥¡¥¤¥Eò³ÊÇ¼¤¹¤EÇ¥£¥E¯¥È¥ê¡Ê¥Ç¥Õ¥©¥EÈ¤Ç¤Ï./config¡Ë¤«¤é»ØÄê¤·¤¿¥Õ¥¡¥¤¥EòÆÉ¤ß¹ş¤ß¡¢
#   ¥Õ¥¡¥¤¥EâÍÆ¤òÊ¸»úÎó¤È¤·¤Æ¼èÆÀ¤·¤Ş¤¹¡£Âè°Eú¿ô¤Ë¤Ï$wiki¤òÅÏ¤·¡¢ÂèÆó°ú¿ô¤Ç¥Õ¥¡¥¤¥E¾¤ò»ØÄê¤·¤Ş¤¹¡£
# </p>
# <pre>
# my $content = Util::load_config_text($wiki, &quot;hoge.dat&quot;);
# </pre>
#===============================================================================
sub load_config_text {
	my $wiki     = shift;
	my $filename = shift;
	my $fullpath = $filename;
	if(defined($wiki)){
		$fullpath = $wiki->config('config_dir')."/$filename";
	}
	
	if(defined($wiki->{config_cache}->{$fullpath})){
		return $wiki->{config_cache}->{$fullpath};
	}
	
	open(CONFIG,$fullpath) or return "";
	binmode(CONFIG);
	my $buf = "";
	while(my $line = <CONFIG>){
		$buf .= $line;
	}
	close(CONFIG);
	
	$buf =~ s/\r\n/\n/g;
	$buf =~ s/\r/\n/g;
	
	$wiki->{config_cache}->{$fullpath} = $buf;
	
	return $buf;
}

#===============================================================================
# <p>
#   °ú¿ô¤ÇÅÏ¤·¤¿¥Ï¥Ã¥·¥å¥EÕ¥¡¥Eó¥¹¤òÀßÄEÕ¥¡¥¤¥Eò³ÊÇ¼¤¹¤EÇ¥£¥E¯¥È¥ê¡Ê¥Ç¥Õ¥©¥EÈ¤Ç¤Ï./config¡Ë¤Ë
#  »ØÄê¤·¤¿¥Õ¥¡¥¤¥E¾¤ÇÊİÂ¸¤·¤Ş¤¹¡£Âè°Eú¿ô¤Ë¤Ï$wiki¤òÅÏ¤·¡¢ÂèÆó°ú¿ô¤Ç¥Õ¥¡¥¤¥E¾¤ò»ØÄê¤·¤Ş¤¹¡£
# </p>
# <pre>
# Util::save_config_hash($wiki, ¥Õ¥¡¥¤¥E¾, ¥Ï¥Ã¥·¥å¥EÕ¥¡¥Eó¥¹);
# </pre>
#===============================================================================
sub save_config_hash {
	my $wiki     = shift;
	my $filename = shift;
	my $hash     = shift;
	my $text     = _make_quoted_text($hash);
	&save_config_text($wiki,$filename,$text);
}

#===============================================================================
# <p>
#   °ú¿ô¤ÇÅÏ¤·¤¿¥Æ¥­¥¹¥È¤òÀßÄEÕ¥¡¥¤¥Eò³ÊÇ¼¤¹¤EÇ¥£¥E¯¥È¥ê¡Ê¥Ç¥Õ¥©¥EÈ¤Ç¤Ï./config¡Ë¤Ë
#  »ØÄê¤·¤¿¥Õ¥¡¥¤¥E¾¤ÇÊİÂ¸¤·¤Ş¤¹¡£Âè°Eú¿ô¤Ë¤Ï$wiki¤òÅÏ¤·¡¢ÂèÆó°ú¿ô¤Ç¥Õ¥¡¥¤¥E¾¤ò»ØÄê¤·¤Ş¤¹¡£
# </p>
# <pre>
# Util::save_config_hash($wiki, ¥Õ¥¡¥¤¥E¾, ¥Æ¥­¥¹¥È);
# </pre>
#===============================================================================
sub save_config_text {
	my $wiki     = shift;
	my $filename = shift;
	my $text     = shift;
	
	$text =~ s/\r\n/\n/g;
	$text =~ s/\r/\n/g;
	
	my $fullpath = $filename;
	if(defined($wiki)){
		$fullpath = $wiki->config('config_dir')."/$filename";
	}
	
	my $tmpfile = "$fullpath.tmp";
	
	file_lock($fullpath);
	
	open(CONFIG,">$tmpfile") or die $!;
	binmode(CONFIG);
	print CONFIG $text;
	close(CONFIG);
	
	rename($tmpfile, $fullpath);
	file_unlock($fullpath);
	
	$wiki->{config_cache}->{$fullpath} = $text;
}

#===============================================================================
# <p>
#   ÀßÄEÕ¥¡¥¤¥EÎÆÉ¤ß¹ş¤ß¤È½ñ¤­¹ş¤ß¤òÆ±°EÎ¥úÁÃ¥¯Æâ¤Ç¹Ô¤¦¤¿¤á¤Î´Ø¿ô¡£
#   ÆÉ¤ß¹ş¤ó¤ÀÆâÍÆ¤òÊÑ´¹¤·¤Æ½ñ¤­¹ş¤ß¤ò¹Ô¤¦¤è¤¦¤Ê¾Eç¤Ë»ÈÍÑ¤·¤Ş¤¹¡£
# </p>
# <pre>
# sub convert {
#   my $hash = shift;
#   ...
#   return $hash;
# }
# 
# Util::sync_update_config($wiki, ¥Õ¥¡¥¤¥E¾, \&convert);
# </pre>
#===============================================================================
sub sync_update_config {
	my $wiki     = shift;
	my $filename = shift;
	my $function = shift;
	
	my $fullpath = $filename;
	if(defined($wiki)){
		$fullpath = $wiki->config('config_dir')."/$filename";
	}
	
	my $tmpfile = "$fullpath.tmp";
	
	file_lock($fullpath);
	
	my $hash = load_config_hash($wiki, $filename);
	my $text = _make_quoted_text(&$function($hash));
	
	open(CONFIG,">$tmpfile") or die $!;
	binmode(CONFIG);
	print CONFIG $text;
	close(CONFIG);
	
	rename($tmpfile, $fullpath);
	file_unlock($fullpath);
	
	$wiki->{config_cache}->{$fullpath} = $text;
}

#===============================================================================
# ¥Ï¥Ã¥·¥å¤ò¥Æ¥­¥¹¥È¤ËÊÑ´¹¤¹¤E¿¤á¤Î¥æ¡¼¥Æ¥£¥EÆ¥£¡£
#===============================================================================
sub _make_quoted_text {
	my $hash = shift;
	my $text = "";
	foreach my $key (sort(keys(%$hash))){
		my $value = $hash->{$key};
		
		$key =~ s/"/""/g;
		$key =~ s/\\/\\\\/g;
		$key =~ s/\n/\\n/g;
		$key =~ s/\r/\\r/g;
		
		$value =~ s/"/""/g;
		$value =~ s/\\/\\\\/g;
		$value =~ s/\n/\\n/g;
		$value =~ s/\r/\\r/g;
		
		$text .= qq{"$key"="$value"\n};
	}
	return $text;
}

#===============================================================================
# <p>
#   °ú¿ô¤ÇÅÏ¤·¤¿¥Õ¥¡¥¤¥Eò¥úÁÃ¥¯¤·¤Ş¤¹¡£
#   ¥Õ¥¡¥¤¥EàºûÙªÎ»¸å¤ÏÉ¬¤ºÆ±¤¸¥Õ¥¡¥¤¥E¾¤ÇUtil::file_unlock¤ò¸Æ¤Ó½Ğ¤·¤Æ²¼¤µ¤¤¡£
#   ¥úÁÃ¥¯¤Ë¼ºÇÔ¤·¤¿¾Eç¤Ïdie¤·¤Ş¤¹¡£
# </p>
# <pre>
# Util::file_lock(¥Õ¥¡¥¤¥E¾, ¥EÈ¥é¥¤²ó¿ô¡Ê¢â¥¿¥¤¥à¥¢¥¦¥È»ş´Ö¡¢¾ÊÎ¬²Ä¡Ë);
# </pre>
#===============================================================================
# ¥úÁÃ¥¯¤·¤Æ¤¤¤EÕ¥¡¥¤¥Eòµ­Ï¿¤·¡¢½ªÎ»»ş¤ËÌ¤²ò½EÎ¥úÁÃ¥¯¤ò²ò½E¹¤Eİ¸±¤ò¤Ä¤±¤¿Êı¤¬ÎÉ¤¤¤«¤âÃÎ¤EÊ¤¤¡£
sub file_lock {
	my $lock  = shift() . ".lock";
	my $retry = shift || 5;
#	debug("file_lock($$): $lock");

	if(-e $lock){
		my $mtime = (stat($lock))[9];
		rmdir($lock) if($mtime < time() - 60);
	}
	
	while(!mkdir($lock,0777)){
		die "Lock is busy." if(--$retry <= 0);
		sleep(1);
	}
}

#===============================================================================
# <p>
#   °ú¿ô¤ÇÅÏ¤·¤¿¥Õ¥¡¥¤¥EÎ¥úÁÃ¥¯¤ò²ò½E·¤Ş¤¹¡£
# </p>
# <pre>
# Util::file_unlock(¥Õ¥¡¥¤¥E¾);
# </pre>
#===============================================================================
sub file_unlock {
	my $lock  = shift() . ".lock";
	rmdir($lock);
#	debug("file_unlock($$): $lock");
}

#===============================================================================
# <p>
#   ¥¤¥ó¥é¥¤¥ó¥×¥é¥°¥¤¥ó¤«¤é¥¨¥é¡¼¥á¥Ã¥»¡¼¥¸¤òÊÖ¤¹¾Eç¤Ë»ÈÍÑ¤·¤Æ¤¯¤À¤µ¤¤¡£
# </p>
# <pre>
#  return Util::inline_error('¥×¥úÁ¸¥§¥¯¥ÈÌ¾¤¬»ØÄê¤µ¤EÆ¤¤¤Ş¤»¤ó¡£');
# </pre>
#===============================================================================
sub inline_error {
	my $message = shift;
	my $type    = shift;
	
	if(uc($type) eq "WIKI"){
		return "<<$message>>";
	} else {
		return &Util::escapeHTML($message);
#		return "<span class=\"error\">".&Util::escapeHTML($message)."</span>";
	}
}

#===============================================================================
# <p>
#   ¥Ñ¥é¥°¥é¥Õ¥×¥é¥°¥¤¥ó¤«¤é¥¨¥é¡¼¥á¥Ã¥»¡¼¥¸¤òÊÖ¤¹¾Eç¤Ë»ÈÍÑ¤·¤Æ¤¯¤À¤µ¤¤¡£
# </p>
# <pre>
# return Util::paragraph_error('¥×¥úÁ¸¥§¥¯¥ÈÌ¾¤¬»ØÄê¤µ¤EÆ¤¤¤Ş¤»¤ó¡£');
# </pre>
#===============================================================================
sub paragraph_error {
	my $message = shift;
	my $type    = shift;
	
	if(uc($type) eq "WIKI"){
		return "<<$message>>";
	} else {
		return &Util::escapeHTML($message);
#		return "<p><span class=\"error\">".&Util::escapeHTML($message)."</span></p>";
	}
}


#===============================================================================
# <p>
#   »ØÄê¤ÎURL¤ËGET¥E¯¥¨¥¹¥È¤òÈ¯¹Ô¤·¡¢¥E¹¥İ¥ó¥¹¤Î¥Ü¥Ç¥£Éô¤òÊÖµÑ¤·¤Ş¤¹¡£
#   ¤³¤Î´Ø¿ô¤ò¸Æ¤Ó½Ğ¤·¤¿»şÅÀ¤ÇLWP::UserAgent¤¬use¤µ¤EŞ¤¹¡£
# </p>
# <pre>
# my $response = Util::get_response($wiki,URL);
# </pre>
#===============================================================================
sub get_response {
	my $wiki = shift;
	my $url  = shift;

	eval("use LWP::UserAgent;");
	eval("use MIME::Base64;");

	my $ua  = LWP::UserAgent->new();
	my $req = HTTP::Request->new('GET',$url);
	
	# ¥×¥úÁ­¥·¤ÎÀßÄ
	my $proxy_host = $wiki->config('proxy_host');
	my $proxy_port = $wiki->config('proxy_port');
	my $proxy_user = $wiki->config('proxy_user');
	my $proxy_pass = $wiki->config('proxy_pass');
	
	if($proxy_host ne "" && $proxy_port ne ""){
		$ua->proxy("http","http://$proxy_host:$proxy_port");
		if($proxy_user ne "" && $proxy_pass ne ""){
			$req->header('Proxy-Authorization'=>"Basic ".&MIME::Base64::encode("$proxy_user:$proxy_pass"));
		}
	}
	
	# ¥E¯¥¨¥¹¥È¤òÈ¯¹Ô
	my $res = $ua->request($req);
	return $res->content();
}

#===============================================================================
# <p>
#   ¥â¥¸¥å¡¼¥E¾¤«¤é¥Õ¥¡¥¤¥E¾¤ò¼èÆÀ¤·¤Ş¤¹¡£
#   Îã¤¨¤Ğplugin::core::Install¤òÅÏ¤¹¤Èplugin/core/Install.pm¤¬ÊÖµÑ¤µ¤EŞ¤¹¡£
# </p>
# <pre>
# $file = Util::get_module_file(¥â¥¸¥å¡¼¥E¾);
# </pre>
#===============================================================================
sub get_module_file {
	return join('/',split(/::/,shift)).'.pm';
}

#===============================================================================
# <p>
#   ¥Ç¥Ğ¥Ã¥°¥úÁ°¡Êdebug.log¡Ë¤ò¥«¥Eó¥È¥Ç¥£¥E¯¥È¥ê¤Ë½ĞÎÏ¤·¤Ş¤¹¡£
#   Wiki::DEBUG=1¤Î¾Eç¤Î¤ß½ĞÎÏ¤ò¹Ô¤¤¤Ş¤¹¡£
# </p>
#===============================================================================
sub debug {
	my $message = shift;
	if($Wiki::DEBUG==1){
		my $date = &Util::format_date(time());
		my $lock = "debug.log.lock";
		my $retry = 5;
		if(-e $lock){
			my $mtime = (stat($lock))[9];
			rmdir($lock) if($mtime < time() - 60);
		}
		
		while(!mkdir($lock,0777)){
			die "Lock is busy." if(--$retry <= 0);
			sleep(1);
		}
		open(LOG,">>debug.log");
		print LOG "$date $message\n";
		close(LOG);
		rmdir($lock);
	}
}

#===============================================================================
# <p>
#   Digest::Perl::MD5¤òÍÑ¤¤¤¿¥Ñ¥¹¥E¼¥É¤Î°Å¹æ²½¤ò¹Ô¤¤¤Ş¤¹¡£
#   Âè°Eú¿ô¤Ë¥Ñ¥¹¥E¼¥É¡¢ÂèÆó°ú¿ô¤Ë¥¢¥«¥¦¥ó¥È¤òÅÏ¤·¤Ş¤¹¡£
#   ¤³¤Î¥á¥½¥Ã¥É¤ò¸Æ¤Ó½Ğ¤·¤¿»şÅÀ¤ÇDigest::Perl::MD5¤¬use¤µ¤EŞ¤¹¡£
# </p>
# <pre>
# my $md5pass = Util::md5($pass,$account);
# </pre>
#===============================================================================
sub md5 {
	my $pass = shift;
	my $salt = shift;
	
	eval("use Digest::Perl::MD5;");
	
	my $md5 = Digest::Perl::MD5->new();
	$md5->add($pass);
	$md5->add($salt);
	
	return $md5->hexdigest;
}

#===============================================================================
# <p>
#   HTTP¥Ø¥Ã¥À¤ÎContent-Disposition¹Ô¤òÀ¸À®¤·¤Ş¤¹¡£
#   ÅºÉÕ¥Õ¥¡¥¤¥EäPDF¤Ê¤É¤Ë»ÈÍÑ¤·¤Ş¤¹¡£
# </p>
#===============================================================================
sub make_content_disposition {
	my ($filename, $disposition) = @_;
	my $ua = $ENV{"HTTP_USER_AGENT"};
	my $encoded = ($ua =~ /MSIE/ ? &Jcode::convert($filename, 'sjis') : Jcode->new($filename)->mime_encode(''));
	return "Content-Disposition: $disposition;filename=\"".$encoded."\"\n\n";
}

#===============================================================================
# <p>
#   CGI::Carp¥â¥¸¥å¡¼¥EÎÂå¤Eê¤Ëdie´Ø¿ô¤ò¥ª¡¼¥Ğ¡¼¥é¥¤¥É¤·¤Ş¤¹¡£
#    ¥¨¥é¡¼¥á¥Ã¥»¡¼¥¸¤òÀ¸À®¤·¤¿¸å¤ËËÜÊª¤Îdie´Ø¿ô¤ò¸Æ¤Ó½Ğ¤·¤Ş¤¹¡£
# </p>
#===============================================================================
sub _die {
	my ($arg,@rest) = @_;
	$arg = join("", ($arg,@rest));
	my($pack,$file,$line,$sub) = caller(1);
	$arg .= " at $file line $line." unless $arg=~/\n$/;
	CORE::die($arg);
}

#===============================================================================
# <p>
#   exit´Ø¿ô¤ò¥ª¡¼¥Ğ¡¼¥é¥¤¥É¤·¤Ş¤¹¡£
# </p>
#===============================================================================
sub _exit {
	CORE::die('safe_die');
}

#===============================================================================
# <p>
#   die¤Èexit¤Î¥ª¡¼¥Ğ¥é¥¤¥ÉÁàºûÀò²ò½E·¤Ş¤¹¡£
# </p>
#===============================================================================
sub restore_die{
	our @original_exit_handler;
	*CORE::GLOBAL::die = $original_exit_handler[0];
	*CORE::GLOBAL::exit = $original_exit_handler[1];
}

1;
