################################################################################
# <p>
#   FSWiki全体で使用さ��E�E罅璽謄���E謄４愎�群を提供す��E皀献紂璽�E任后�
# </p>
################################################################################
package Util;
use strict;

#===============================================================================
# <p>
#   dieとexitのオーバライド操笹栓行います。
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
#   引数で渡さ��E進源�列をURLエンコードして返します。
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
#   引数で渡さ��E進源�列をURLデコードして返します。
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
#   Cookieのpathに指定す��E源�列を取得します。
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
#   ディ��E�トリ、ファイ��E勝�拡張子を��E腓靴謄侫．ぅ�E召鮴言�します。
# </p>
# <pre>
# my $filename = Util::make_filename(ディ��E�ト��E�,ファイ��E�,拡張子);
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
#   引数で渡さ��E進源�列のHTMLタグをエスケープして返します。
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
#   ��E佞�Equot;yyyy年mm憲�d��Ehh時mi分ss秒&quot;形式にフォーマットします。
# </p>
# <pre>
# my $date = Util::format_date(time());
# </pre>
#===============================================================================
sub format_date {
	my $t = shift;
	my ($sec, $min, $hour, $mday, $mon, $year) = localtime($t);
	return sprintf("%04d年%02d��E02d��E%02d時%02d分%02d秒",
	               $year+1900,$mon+1,$mday,$hour,$min,$sec);
}

#===============================================================================
# <p>
#   文字列の両端の空白を切��E�脆します。
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
#   タグを��E�E靴栃源�列のみを取得します。
# <p>
# <pre>
# my $html = "<B>文字��E/B>";
# # &lt;B&gt;と&lt;/B&gt;を��E�E掘�&quot;文字��Equot;のみ取得
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
#   数値かどうかチェックします。数値の��E腓録拭△修Δ任覆ぞ�E腓狼兇鯤屬靴泙后�
# </p>
# <pre>
# if(Util::check_numeric($param)){
#   # 整数の��E腓僚萢�
# } else {
#   # 整数でない��E腓僚萢�
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
#   管理者にメー��E鯀�信します。
#   setup.datの設��E睛討鳳�じてsendmailコマンドもしくはSMTP通信によってメー��E�送信さ��E泙后�
#   どちらも設定さ��E討い覆ぞ�E腓倭�信を行��E此▲┘蕁爾砲發覆蠅泙擦鵝�
#   SMTPで送信す��E�E隋△海離瓮愁奪匹鮓討喀个靴浸�点でNet::SMTPがuseさ��E泙后�
# </p>
# <pre>
# Util::send_mail($wiki,��E�,本文);
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
		
		# sendmailコマンドで送信
		if($wiki->config('send_mail') ne ""){
			open(MAIL,"| ".$wiki->config('send_mail')." ".$to);
			print MAIL $mail;
			close(MAIL);
			
		# Net::SMTPで送信
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
#   クライアントが携帯電話かどうかチェックします。
#   携帯電話の��E腓録拭△修Δ任覆ぞ�E腓狼兇鯤屬靴泙后�
# </p>
# <pre>
# if(Util::handyphone()){
#   # 携帯電話の��E腓僚萢�
# } else {
#   # 携帯電話でない��E腓僚萢�
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
# load_config_hash関数で使用す��E▲鵐┘好院璽徑儡愎
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
#   設��E侫．ぅ�E魍頁爾垢�E妊���E�トリ（デフォ��E箸任�./config）から指定したファイ��E鯑匹濆�み、
#   ハッシュ��E侫．�E鵐垢箸靴銅萋世靴泙后Ｂ莪�E�数には$wikiを渡し、第二引数でファイ��E召鮖慊蠅靴泙后�
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
#   設��E侫．ぅ�E魍頁爾垢�E妊���E�トリ（デフォ��E箸任�./config）から指定したファイ��E鯑匹濆�み、
#   ファイ��E睛討鯤源�列として取得します。第��E�数には$wikiを渡し、第二引数でファイ��E召鮖慊蠅靴泙后�
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
#   引数で渡したハッシュ��E侫．�E鵐垢鮴瀋�E侫．ぅ�E魍頁爾垢�E妊���E�トリ（デフォ��E箸任�./config）に
#  指定したファイ��E召琶歛犬靴泙后Ｂ莪�E�数には$wikiを渡し、第二引数でファイ��E召鮖慊蠅靴泙后�
# </p>
# <pre>
# Util::save_config_hash($wiki, ファイ��E�, ハッシュ��E侫．�E鵐�);
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
#   引数で渡したテキストを設��E侫．ぅ�E魍頁爾垢�E妊���E�トリ（デフォ��E箸任�./config）に
#  指定したファイ��E召琶歛犬靴泙后Ｂ莪�E�数には$wikiを渡し、第二引数でファイ��E召鮖慊蠅靴泙后�
# </p>
# <pre>
# Util::save_config_hash($wiki, ファイ��E�, テキスト);
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
#   設��E侫．ぅ�E瞭匹濆�みと書き込みを同��E離�礎ク内で行うための関数。
#   読み込んだ内容を変換して書き込みを行うような��E腓忙藩僂靴泙后�
# </p>
# <pre>
# sub convert {
#   my $hash = shift;
#   ...
#   return $hash;
# }
# 
# Util::sync_update_config($wiki, ファイ��E�, \&convert);
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
# ハッシュをテキストに変換す��E燭瓩離罅璽謄���E謄�。
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
#   引数で渡したファイ��E鬟�礎クします。
#   ファイ��E犧�扞了後は必ず同じファイ��E召�Util::file_unlockを呼び出して下さい。
#   ��礎クに失敗した��E腓�dieします。
# </p>
# <pre>
# Util::file_lock(ファイ��E�, ��E肇薀げ鷽堯腹皀織ぅ爛▲Ε隼�間、省略可）);
# </pre>
#===============================================================================
# ��礎クしてい��E侫．ぅ�E魑�録し、終了時に未解��E離�礎クを解��E垢�E欷韻鬚弔韻進�が良いかも知��E覆ぁ�
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
#   引数で渡したファイ��E離�礎クを解��E靴泙后�
# </p>
# <pre>
# Util::file_unlock(ファイ��E�);
# </pre>
#===============================================================================
sub file_unlock {
	my $lock  = shift() . ".lock";
	rmdir($lock);
#	debug("file_unlock($$): $lock");
}

#===============================================================================
# <p>
#   インラインプラグインからエラーメッセージを返す��E腓忙藩僂靴討�ださい。
# </p>
# <pre>
#  return Util::inline_error('プ��糎ェクト名が指定さ��E討い泙擦鵝�');
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
#   パラグラフプラグインからエラーメッセージを返す��E腓忙藩僂靴討�ださい。
# </p>
# <pre>
# return Util::paragraph_error('プ��糎ェクト名が指定さ��E討い泙擦鵝�');
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
#   指定のURLにGET��E�エストを発行し、��E好櫂鵐垢離椒妊Ｉ瑤鯤峙僂靴泙后�
#   この関数を呼び出した時点でLWP::UserAgentがuseさ��E泙后�
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
	
	# プ��銑シの設�
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
	
	# ��E�エストを発行
	my $res = $ua->request($req);
	return $res->content();
}

#===============================================================================
# <p>
#   モジュー��E召�らファイ��E召鮗萋世靴泙后�
#   例えばplugin::core::Installを渡すとplugin/core/Install.pmが返却さ��E泙后�
# </p>
# <pre>
# $file = Util::get_module_file(モジュー��E�);
# </pre>
#===============================================================================
sub get_module_file {
	return join('/',split(/::/,shift)).'.pm';
}

#===============================================================================
# <p>
#   デバッグ��前（debug.log）をカ��E鵐肇妊���E�トリに出力します。
#   Wiki::DEBUG=1の��E腓里濬侘呂鮃圓い泙后�
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
#   Digest::Perl::MD5を用いたパス��E璽匹琉店羃修鮃圓い泙后�
#   第��E�数にパス��E璽鼻�第二引数にアカウントを渡します。
#   このメソッドを呼び出した時点でDigest::Perl::MD5がuseさ��E泙后�
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
#   HTTPヘッダのContent-Disposition行を生成します。
#   添付ファイ��E�PDFなどに使用します。
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
#   CGI::Carpモジュー��E梁紊�E蠅�die関数をオーバーライドします。
#    エラーメッセージを生成した後に本物のdie関数を呼び出します。
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
#   exit関数をオーバーライドします。
# </p>
#===============================================================================
sub _exit {
	CORE::die('safe_die');
}

#===============================================================================
# <p>
#   dieとexitのオーバライド操笹栓解��E靴泙后�
# </p>
#===============================================================================
sub restore_die{
	our @original_exit_handler;
	*CORE::GLOBAL::die = $original_exit_handler[0];
	*CORE::GLOBAL::exit = $original_exit_handler[1];
}

1;
