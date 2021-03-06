###############################################################################
# <p>
# Wiki API
# </p>
###############################################################################
package Wiki;
use strict;
use CGI2;
use File::Copy;
use File::Path;
use Wiki::DefaultStorage;
use Wiki::HTMLParser;
#use Wiki::CacheParser;
use vars qw($VERSION $DEBUG);
$VERSION = '3.6.3';
$DEBUG   = 0;
#==============================================================================
# <p>
#   コンストラクタ
# </p>
#==============================================================================
sub new {
	my $class = shift;
	my $self  = {};
	
	# 設定を読み込み
	my $setupfile = shift || 'setup.dat';
	$self->{"config"} = &Util::load_config_hash(undef,$setupfile);
	die "setup file ${setupfile} not found" if (keys %{$self->{"config"}} == 0);
	$self->{"config"}->{"plugin_dir"} = "."         unless exists($self->{"config"}->{"plugin_dir"});
	$self->{"config"}->{"frontpage"}  = "FrontPage" unless exists($self->{"config"}->{"frontpage"});
	unshift(@INC, $self->{"config"}->{"plugin_dir"});
	$ENV{'TZ'} = $self->{"config"}->{"time_zone"};
	$CGI::POST_MAX = $self->{"config"}->{"post_max"} if $self->{"config"}->{"post_max"} ne '';
	
	# インスタンス変数を初��E�
	$self->{"handler"}            = {};
	$self->{"handler_permission"} = {};
	$self->{"plugin"}             = {};
	$self->{"title"}              = "";
	$self->{"menu"}               = [];
	$self->{"CGI"}                = CGI2->new();
	$self->{"hook"}               = {};
	$self->{"user"}               = ();
	$self->{"admin_menu"}         = ();
	$self->{"editform"}           = ();
	$self->{"edit"}               = 0;
	$self->{"parse_times"}        = 0;
	$self->{"format"}             = {};
	$self->{"installed_plugin"}   = ();
	$self->{"head_info"}          = ();
	
	# スト��E璽犬離ぅ鵐好織鵐垢鮴言�
	if($self->{config}->{"storage"} eq ""){
		$self->{"storage"} = Wiki::DefaultStorage->new($self);
	} else {
		eval ("use ".$self->{config}->{"storage"}.";");
		$self->{"storage"} = $self->{config}->{"storage"}->new($self);
	}
	
	return bless $self,$class;
}

###############################################################################
#
# ユーザ関係のメソッド群
#
###############################################################################
#==============================================================================
# <p>
#   ユーザを追加します
# </p>
# <pre>
# $wiki-&gt;add_user(ID,パス��E璽�,ユーザタイプ);
# </pre>
# <p>
# ユーザタイプには管理者ユーザの��E�E、��E魅罅璽兇両�E�Eを指定します。
# なお、このメソッドは実行時にWiki.pmにユーザを追加す��E燭瓩里發里如�
# このメソッドに対してユーザを追加しても永続化は行��E�E泙擦鵝�
# </p>
#==============================================================================
sub add_user {
	my $self = shift;
	my $id   = shift;
	my $pass = shift;
	my $type = shift;

	push(@{$self->{"user"}},{id=>$id,pass=>$pass,type=>$type});
}

#==============================================================================
# <p>
#   ユーザが存在す��E�どうかを確認します
# </p>
#==============================================================================
sub user_exists {
	my $self = shift;
	my $id   = shift;
	foreach my $user (@{$self->{"user"}}){
		if($user->{id} eq $id){
			return 1;
		}
	}
	return 0;
}

#==============================================================================
# <p>
#   ��前イン情報を取得します。
#   ��前インしてい��E�E腓魯�前イン情報を含んだハッシュ��E侫．�E鵐垢髻�
#   ��前インしていない��E腓�undefを返します。
# </p>
# <pre>
# my $info = $wiki-&gt;get_login_info();
# if(defined($info)){          # ��前インしていない��E腓�undef
#   my $id   = $info-&gt;{id};    # ��前インユーザのID
#   my $type = $info-&gt;{type};  # ��前インユーザの��E�(0:管理者 1:��E�)
# }
# </pre>
#==============================================================================
sub get_login_info {
	my $self = shift;
	if (exists($self->{'login_info'})){
		return $self->{'login_info'};
	}

	my $cgi = $self->get_CGI();
	return undef unless(defined($cgi));
	
	my $session = $cgi->get_session($self);
	unless(defined($session)){
		$self->{'login_info'} = undef;
		return undef;
	}
	my $id   = $session->param("wiki_id");
	my $type = $session->param("wiki_type");
	my $path = $session->param("wiki_path");

	# PATH_INFOを調べ�
	my $path_info = $cgi->path_info();
	if(!defined($path_info)){ $path_info  = ""; }
	if(!defined($path     )){ $path       = ""; }
	if(!defined($id       )){ $id         = ""; }
	if(!defined($type     )){ $type       = ""; }
	
	if($path_info eq "" && $path ne ""){
		$self->{'login_info'} = undef;
		return undef;
	} elsif($path ne "" && !($path_info =~ /^$path($|\/)/)){
		$self->{'login_info'} = undef;
		return undef;
	}
	
	# クッキーがセットさ��E討い覆�
	if($id eq "" ||  $type eq ""){
		$self->{'login_info'} = undef;
		return undef;
	}
	
	# ユーザ情報を返却
	$self->{'login_info'} = {id=>$id,type=>$type,path=>$path};
	return $self->{'login_info'};
}

#==============================================================================
# <p>
#   ��前インチェックを行います。
# </p>
#==============================================================================
sub login_check {
	my $self = shift;
	my $id   = shift;
	my $pass = shift;
	my $path = $self->get_CGI()->path_info();
	foreach(@{$self->{"user"}}){
		if($_->{id} eq $id && $_->{pass} eq $pass){
			return {id=>$id,pass=>$pass,type=>$_->{type},path=>$path};
		}
	}
	return undef;
}

###############################################################################
#
# プラグイン関係のメソッド群
#
###############################################################################
#==============================================================================
# <p>
#   エディットフォームプラグインを追加します
# </p>
# <pre>
# $wiki-&gt;add_editform_plugin(エディットフォームプラグインのクラス名,優先度);
# </pre>
# <p>
# 優先度が大きいほど上位に表示さ��E泙后�
# </p>
#==============================================================================
sub add_editform_plugin {
	my $self   = shift;
	my $plugin = shift;
	my $weight = shift;
	push(@{$self->{"editform"}},{class=>$plugin,weight=>$weight});
}

#==============================================================================
# <p>
#   編集フォーム用のプラグインの出力を取得します
# </p>
#==============================================================================
sub get_editform_plugin {
	my $self = shift;
	my $buf = "";
	foreach my $plugin (sort { $b->{weight}<=>$a->{weight} } @{$self->{"editform"}}){
		my $obj = $self->get_plugin_instance($plugin->{class});
		$buf .= $obj->editform($self)."\n";
	}
	return $buf;
}

#==============================================================================
# <p>
# 管理者用のメニューを追加します。管理者ユーザが��前インした��E腓防充┐気�E泙后�
# 優先度が高いほど上のほうに表示さ��E泙后�
# </p>
# <pre>
# $wiki-&gt;add_admin_menu(メニュー項目名,遷移す��ERL,優先度,詳細説明);
# </pre>
#==============================================================================
sub add_admin_menu {
	my $self   = shift;
	my $label  = shift;
	my $url    = shift;
	my $weight = shift;
	my $desc   = shift;
	
	push(@{$self->{"admin_menu"}},{label=>$label,url=>$url,weight=>$weight,desc=>$desc,type=>0});
}

#==============================================================================
# <p>
# ��前インユーザ用のメニューを追加します。
# ユーザが��前インした��E腓防充┐気�E泙后４浜�者ユーザの��E腓睇充┐気�E泙后�
# 優先度が高いほど上のほうに表示さ��E泙后�
# </p>
# <pre>
# $wiki-&gt;add_admin_menu(メニュー項目名,遷移す��ERL,優先度,詳細説明);
# </pre>
#==============================================================================
sub add_user_menu {
	my $self   = shift;
	my $label  = shift;
	my $url    = shift;
	my $weight = shift;
	my $desc   = shift;
	
	push(@{$self->{"admin_menu"}},{label=>$label,url=>$url,weight=>$weight,desc=>$desc,type=>1});
}

#==============================================================================
# <p>
# 管理者用のメニューを取得します。
# </p>
#==============================================================================
sub get_admin_menu {
	my $self = shift;
	return sort { $b->{weight}<=>$a->{weight} } @{$self->{"admin_menu"}};
}

#==============================================================================
# <p>
# プラグインをインストー��E靴泙后�このメソッドはwiki.cgiによってcallさ��E泙后�
# プラグイン開発において通��E△海離瓮愁奪匹鮖藩僂垢�E海箸呂△蠅泙擦鵝�
# </p>
#==============================================================================
sub install_plugin {
	my $self   = shift;
	my $plugin = shift;
	
	if ($plugin =~ /\W/) {
		return Util::escapeHTML("${plugin}プラグインは不正なプラグインです。");
#		return "<div class=\"error\">".Util::escapeHTML("${plugin}プラグインは不正なプラグインです。")."</div>";
	}
		
	my $module = "plugin::${plugin}::Install";
	eval 'require &Util::get_module_file($module);'.$module.'::install($self);';
	
	if($@){
		return Util::escapeHTML("${plugin}プラグインがインストー��E任�ません。$@");
#		return "<div class=\"error\">".Util::escapeHTML("${plugin}プラグインがインストー��E任�ません。$@")."</div>";
	} else {
		push(@{$self->{"installed_plugin"}},$plugin);
		return "";
	}
}

#==============================================================================
# <p>
# プラグインがインストー��E気�E討い�E�どうかを調べます。
# </p>
#==============================================================================
sub is_installed {
	my $self   = shift;
	my $plugin = shift;
	
	foreach (@{$self->{"installed_plugin"}}){
		if($_ eq $plugin){
			return 1;
		}
	}
	return 0;
}

#==============================================================================
# <p>
# メニュー項目を追加します。既に同じ名前の項目が登録さ��E討い�E�E腓肋綵颪�します。
# 優先度が高いほど左側に表示さ��E泙后�
# </p>
# <pre>
# $wiki-&gt;add_menu(項目名,URL,優先度,ク��充��E魑馮櫃垢�E�どうか);
# </pre>
# <p>
# 検索エンジンにク��充��E気擦燭�ない��E腓和�E引数に1、許可す��E�E腓�0を指定します。
# 省略した��E腓魯���充��E魑�可します。
# </p>
#==============================================================================
sub add_menu {
	my $self     = shift;
	my $name     = shift;
	my $href     = shift;
	my $weight   = shift;
	my $nofollow = shift;
	
	my $flag = 0;
	foreach(@{$self->{"menu"}}){
		if($_->{name} eq $name){
			$_->{href} = $href;
			$flag = 1;
			last;
		}
	}
	if($flag==0){
		push(@{$self->{"menu"}},{name=>$name,href=>$href,weight=>$weight,nofollow=>$nofollow});
	}
}

#===============================================================================
# <p>
# フックプラグインを登録します。登録したプラグインはdo_hookメソッドで呼び出します。
# </p>
# <pre>
# $wiki-&gt;add_hook(フック名,フックプラグインのクラス名);
# </pre>
#===============================================================================
sub add_hook {
	my $self = shift;
	my $name = shift;
	my $obj  = shift;
	
	push(@{$self->{"hook"}->{$name}},$obj);
}

#===============================================================================
# <p>
# add_hookメソッドで登録さ��E織侫奪�プラグインを実行します。
# 引数にはフックの名前に加えて任意のパラメータを渡すことができます。
# こ��E蕕離僖薀瓠璽燭聾討喀个気�E�E�ラスのhookメソッドの引数として渡さ��E泙后�
# </p>
# <pre>
# $wiki-&gt;do_hook(フック名[,引��E[,引��E...]]);
# </pre>
#===============================================================================
sub do_hook {
	my $self = shift;
	my $name = shift;
	
	foreach my $class (@{$self->{"hook"}->{$name}}){
		my $obj = $self->get_plugin_instance($class);
		$obj->hook($self,$name,@_);
	}
}

#==============================================================================
# <p>
# アクションハンドラプラグインを追加します。
# ��E�エスト時にactionというパラメータが��E廚垢�E▲�ションが呼び出さ��E泙后�
# </p>
# <pre>
# $wiki-&gt;add_handler(actionパラメータ,アクションハンドラのクラス名);
# </pre>
#==============================================================================
sub add_handler {
	my $self   = shift;
	my $action = shift;
	my $class  = shift;
	
	$self->{"handler"}->{$action}=$class;
	$self->{"handler_permission"}->{$action} = 1;
}

#==============================================================================
# <p>
# ��前インユーザ用のアクションハンドラを追加します。
# このメソッドによって追加さ��E織▲�ションハンドラは��前インしてい��E�E腓里濕孫垈椎修任后�
# そ��E奮阿両�E腓魯┘蕁璽瓮奪察璽犬鯢充┐靴泙后�
# </p>
# <pre>
# $wiki-&gt;add_user_handler(actionパラメータ,アクションハンドラのクラス名);
# </pre>
#==============================================================================
sub add_user_handler {
	my $self   = shift;
	my $action = shift;
	my $class  = shift;
	
	$self->{"handler"}->{$action}=$class;
	$self->{"handler_permission"}->{$action} = 2;
}

#==============================================================================
# <p>
# 管理者用のアクションハンドラを追加します。
# このメソッドによって追加さ��E織▲�ションハンドラは管理者として��前インしてい��E�E腓里濕孫垈椎修任后�
# そ��E奮阿両�E腓魯┘蕁璽瓮奪察璽犬鯢充┐靴泙后�
# </p>
# <pre>
# $wiki-&gt;add_admin_handler(actionパラメータ,アクションハンドラのクラス名);
# </pre>
#==============================================================================
sub add_admin_handler {
	my $self   = shift;
	my $action = shift;
	my $class  = shift;
	
	$self->{"handler"}->{$action}=$class;
	$self->{"handler_permission"}->{$action} = 0;
}
#==============================================================================
# <p>
# インラインプラグインを追加します。
# </p>
# <p>
# このメソッドは3.4系との互換性を維持す��E燭瓩忙弔靴泙靴拭�3.6で廃止す��E發里箸靴泙后�
# </p>
#==============================================================================
sub add_plugin {
	my $self   = shift;
	my $name   = shift;
	my $class  = shift;
	
	$self->add_inline_plugin($name,$class,"HTML");
}
#==============================================================================
# <p>
# インラインプラグインを登録します。プラグインの出力タイプには"WIKI"または"HTML"を指定します。
# 省略した��E腓�"HTML"を指定したものとみなさ��E泙后�
# </p>
# <pre>
# $wiki-&gt;add_inline_plugin(プラグイン名,プラグインのクラス名,プラグインの出力タイプ);
# </pre>
#==============================================================================
sub add_inline_plugin {
	my ($self, $name, $class, $format) = @_;
	
	if($format eq ""){
		$format = "HTML";
	} else {
		$format = uc($format);
	}
	
	$self->{"plugin"}->{$name} = {CLASS=>$class,TYPE=>'inline',FORMAT=>$format};
}

#==============================================================================
# <p>
# パラグラフプラグインを登録します。プラグインの出力タイプには"WIKI"または"HTML"を指定します。
# 省略した��E腓�"HTML"を指定したものとみなさ��E泙后�
# </p>
# <pre>
# $wiki-&gt;add_inline_plugin(プラグイン名,プラグインのクラス名,プラグインの出力タイプ);
# </pre>
#==============================================================================
sub add_paragraph_plugin {
	my ($self, $name, $class, $format) = @_;
	
	if($format eq ""){
		$format = "HTML";
	} else {
		$format = uc($format);
	}
	
	$self->{"plugin"}->{$name} = {CLASS=>$class,TYPE=>'paragraph',FORMAT=>$format};
}

#==============================================================================
# <p>
# ブ��礎クプラグインを登録します。プラグインの出力タイプには"WIKI"または"HTML"を指定します。
# 省略した��E腓�"HTML"を指定したものとみなさ��E泙后�
# </p>
# <pre>
# $wiki-&gt;add_block_plugin(プラグイン名,プラグインのクラス名,プラグインの出力タイプ);
# </pre>
#==============================================================================
sub add_block_plugin {
	my ($self, $name, $class, $format) = @_;
	
	if($format eq ""){
		$format = "HTML";
	} else {
		$format = uc($format);
	}
	
	$self->{"plugin"}->{$name} = {CLASS=>$class,TYPE=>'block',FORMAT=>$format};
}

#==============================================================================
# <p>
# プラグインの情報を取得します
# </p>
# <pre>
# my $info = $wiki-&gt;get_plugin_info(&quot;include&quot;);
# my $class  = $info-&gt;{CLASS};  # プラグインのクラス名
# my $type   = $info-&gt;{TYPE};   # inline、paragraph、blockのいず��E�
# my $format = $info-&gt;{FORMAT}; # HTMLまたはWIKI
# </pre>
#==============================================================================
sub get_plugin_info {
	my $self = shift;
	my $name = shift;
	
	return $self->{plugin}->{$name};
}

#==============================================================================
# <p>
# add_handlerメソッドで登録さ��E織▲�ションハンドラを実行します。
# アクションハンドラのdo_actionメソッドの戻��E佑鯤屬靴泙后�
# </p>
# <pre>
# my $content = $wiki-&gt;call_handler(actionパラメータ);
# </pre>
#==============================================================================
sub call_handler {
	my $self   = shift;
	my $action = shift;
	
	if(!defined($action)){
		$action = "";
	}
	
	my $obj = $self->get_plugin_instance($self->{"handler"}->{$action});
	
	unless(defined($obj)){
		return $self->error("不正なアクションです。");
	}
	
	# 管理者用のアクショ�
	if($self->{"handler_permission"}->{$action}==0){
		my $login = $self->get_login_info();
		if(!defined($login)){
			return $self->error("��前インしていません。");
			
		} elsif($login->{type}!=0){
			return $self->error("管理者権限が必要です。");
		}
		return $obj->do_action($self).
		       "<div class=\"comment\"><a href=\"".$self->create_url({action=>"LOGIN"})."\">メニューに戻��E/a></div>";
	
	# ��前インユーザ用のアクショ�
	} elsif($self->{"handler_permission"}->{$action}==2){
		my $login = $self->get_login_info();
		if(!defined($login)){
			return $self->error("��前インしていません。");
		}
		return $obj->do_action($self).
		       "<div class=\"comment\"><a href=\"".$self->create_url({action=>"LOGIN"})."\">メニューに戻��E/a></div>";
		
	# 普通のアクショ�
	} else {
		return $obj->do_action($self);
	}
}

#===============================================================================
# <p>
# 引数で渡したWikiフォーマットの文字列をHTMLに変換して返します。
# </p>
# <pre>
# my $html = $wiki-&gt;process_wiki(文字��E;
# </pre>
#===============================================================================
sub process_wiki {
	my $self    = shift;
	my $source  = shift;
	my $mainflg = shift;
	
	if($self->{parse_times} >= 50){
		return $self->error("Wiki::process_wikiの呼び出し回数が上限を越えました。");
	}
	
	$self->{parse_times}++;
	my $parser = Wiki::HTMLParser->new($self,$mainflg);
	$parser->parse($source);
	$self->{parse_times}--;
	
	return $parser->{html};
}

#===============================================================================
# <p>
# インラインプラグイン、パラグラフプラグインの呼び出し（内部処理用の関数）。
# 初��E離瓮愁奪匹里燭疚震承�則（privateメソッドのメソッド名は_から始め��E�
# に従っていません。
# </p>
#===============================================================================
sub process_plugin {
	my $self   = shift;
	my $plugin = shift;
	my $parser = shift;
	
	if(defined($plugin->{error}) && $plugin->{error} ne ""){
		return "<font class=\"error\">".$plugin->{error}."</font>";
	}

	my $name = $plugin->{command};
	my @args = @{$plugin->{args}};
	my $info = $self->get_plugin_info($name);
	my $obj  = $self->get_plugin_instance($info->{CLASS});

	if(!defined($obj)){
		return "<font class=\"error\">".&Util::escapeHTML($name)."プラグインは存在しません。</font>";
		
	} else {
		if($info->{FORMAT} eq "WIKI"){
			# 裏技用(プラグイン内部からパーサを使う��E�E
			push(@{$self->{'current_parser'}}, $parser);
			if($info->{TYPE} eq "inline"){
				my @result = $parser->parse_line($obj->inline($self,@args));
				pop(@{$self->{'current_parser'}});
				return @result;
			} elsif($info->{TYPE} eq "paragraph"){
				$parser->parse($obj->paragraph($self,@args));
			} else {
				$parser->parse($obj->block($self,@args));
			}
			# パーサの参照を解�
			pop(@{$self->{'current_parser'}});
			return undef;
		} else {
			if($info->{TYPE} eq "inline"){
				return $obj->inline($self,@args);
			} elsif($info->{TYPE} eq "paragraph"){
				return $obj->paragraph($self,@args);
			} else {
				return $obj->block($self,@args);
			}
		}
	}
}

#==============================================================================
# <p>
# パース中の��E隋�現在有効なWiki::Parserのインスタンスを返却します。
# パース中の内容をプラグインから変更したい��E腓忙藩僂靴泙后�
# </p>
#==============================================================================
sub get_current_parser {
	my $self = shift;
	my @parsers = @{$self->{'current_parser'}};
	return $parsers[$#parsers];
}

#==============================================================================
# <p>
# エラーの��E隋�呼び出します。
# アクションハンドラからエラーを報告す��E櫃忙藩僂靴討�ださい。
# </p>
# <pre>
# sub do_action {
#   my $self = shift;
#   my $wiki = shift;
#   ...
#   return $wiki-&gt;error(エラーメッセージ);
# }
# </pre>
#==============================================================================
sub error {
	my $self    = shift;
	my $message = shift;
	
	$self->set_title("エラー");
	$self->get_CGI->param("action","ERROR");
	
	return Util::escapeHTML($message);
#	return "<div class=\"error\">".Util::escapeHTML($message)."</div>";
}

#===============================================================================
# <p>
# プラグインのインスタンスを取得します。Wiki.pmで内部的に使用さ��E�E瓮愁奪匹任后�
# プラグイン開発において通��E△海離瓮愁奪匹鮖藩僂垢�E�要はありません。
# </p>
#===============================================================================
sub get_plugin_instance {
	my $self  = shift;
	my $class = shift;
	
	if($class eq ""){
		return undef;
	}
	
	if(!defined($self->{instance}->{$class})){
		eval {
			require &Util::get_module_file($class);
		};
		return undef if $@;
		my $obj = $class->new();
		$self->{instance}->{$class} = $obj;
		
		return $obj;
	} else {
		return $self->{instance}->{$class};
	}
}

#===============================================================================
# <p>
# インラインプラグインをパースしてコマンドと引数に分割します。
# </p>
#===============================================================================
sub parse_inline_plugin {
	my $self = shift;
	my $text = shift;
	my ($cmd, @args_tmp) = split(/ /,$text);
	my $args_txt = &Util::trim(join(" ",@args_tmp));
	if($cmd =~ s/}}(.*?)$//){
		return { command=>$cmd, args=>[], post=>"$1 $args_txt"};
	}
	
	my @ret_args;
	my $tmp    = "";
	my $escape = 0;
	my $quote  = 0;
	my $i      = 0;
	
	for($i = 0; $i<length($args_txt); $i++){
		my $c = substr($args_txt,$i,1);
		if($quote!=1 && $c eq ","){
			if($quote==3){
				$tmp .= '}';
			}
			push(@ret_args,$tmp);
			$tmp = "";
			$quote = 0;
		} elsif($quote==1 && $c eq "\\"){
			if($escape==0){
				$escape = 1;
			} else {
				$tmp .= $c;
				$escape = 0;
			}
		} elsif($quote==0 && $c eq '"'){
			if($tmp eq ""){
				$quote = 1;
			} else {
				$tmp .= $c;
			}
		} elsif($quote==1 && $c eq '"'){
			if($escape==1){
				$tmp .= $c;
				$escape = 0;
			} else {
				$quote = 2;
			}
		} elsif(($quote==0 || $quote==2) && $c eq '}'){
			$quote = 3;
		} elsif($quote==3){
			if($c eq '}'){
				last;
			} else {
				$tmp .= '}'.$c;
				$quote = 0;
			}
		} elsif($quote==2){
			return {error=>"インラインプラグインの構文が不正です。"};
		} else {
			$tmp .= $c;
			$escape = 0;
		}
	}
	
	if($quote!=3){
		my $info = $self->get_plugin_info($cmd);
		return undef if (defined($info->{TYPE}) && $info->{TYPE} ne 'block');
	}
	
	if($tmp ne ""){
		push(@ret_args,$tmp);
	}
	
	return { command=>$cmd, args=>\@ret_args, 
		post=>substr($args_txt, $i + 1, length($args_txt) - $i)};
}

#==============================================================================
# <p>
# フォーマットプラグインを追加します。
# フォーマットプラグインはconvert_to_fswikiメソッドとconvert_from_fswikiメソッド�
# 実装したクラスでなくてはなりません。
# </p>
# <pre>
# $wiki-&gt;add_format_plugin(文法名,クラス名);
# </pre>
#==============================================================================
sub add_format_plugin {
	my $self  = shift;
	my $name  = shift;
	my $class = shift;
	
	$self->{'format'}->{$name} = $class;
}

#==============================================================================
# <p>
# インストー��E気�E討い�E侫�ーマットプラグインの��E�を取得します。
# </p>
# <pre>
# my @formats = $wiki-&gt;get_format_names();
# </pre>
#==============================================================================
sub get_format_names {
	my $self = shift;
	my @list = keys(%{$self->{'format'}});
	if(!scalar(@list)){
		push(@list, "FSWiki");
	}
	return sort(@list);
}

#==============================================================================
# <p>
# 各Wiki書式で記述したソースをFSWikiの書式に変換します。
# </p>
# <pre>
# $source = $wiki-&gt;convert_to_fswiki($source,&quot;YukiWiki&quot;);
# </pre>
# <p>
# インライン書式のみ変換を行う��E腓和荵旭�数に1を渡します。
# </p>
# <pre>
# $source = $wiki-&gt;convert_to_fswiki($source,&quot;YukiWiki&quot;,1);
# </pre>
#==============================================================================
sub convert_to_fswiki {
	my $self   = shift;
	my $source = shift;
	my $type   = shift;
	my $inline = shift;
	
	my $obj = $self->get_plugin_instance($self->{'format'}->{$type});
	unless(defined($obj)){
		return $source;
	} else {
		$source =~ s/\r\n/\n/g;
		$source =~ s/\r/\n/g;
		if($inline){
			return $obj->convert_to_fswiki_line($source);
		} else {
			return $obj->convert_to_fswiki($source);
		}
	}
}

#==============================================================================
# <p>
# FSWikiの書式で記述したソースを各Wikiの書式に変換します。
# </p>
# <pre>
# $source = $wiki-&gt;convert_from_fswiki($source,&quot;YukiWiki&quot;);
# </pre>
# <p>
# インライン書式のみ変換を行う��E腓和荵旭�数に1を渡します。
# </p>
# <pre>
# $source = $wiki-&gt;convert_from_fswiki($source,&quot;YukiWiki&quot;,1);
# </pre>
#==============================================================================
sub convert_from_fswiki {
	my $self   = shift;
	my $source = shift;
	my $type   = shift;
	my $inline = shift;
	
	my $obj = $self->get_plugin_instance($self->{'format'}->{$type});
	unless(defined($obj)){
		return $source;
	} else {
		$source =~ s/\r\n/\n/g;
		$source =~ s/\r/\n/g;
		if($inline){
			return $obj->convert_from_fswiki_line($source);
		} else {
			return $obj->convert_from_fswiki($source);
		}
	}
}

#==============================================================================
# <p>
# 現在のユーザが編集に使用す��E侫�ーマットを取得します。
# formatプラグインがアクティベートさ��E討い覆ぞ�E腓肋�E�"FSWiki"を返します。
# </p>
# <pre>
# my $format = $wiki-&gt;get_edit_format();
# </pre>
#==============================================================================
sub get_edit_format {
	my $self = shift;
	my $from = shift;
	
	# formatプラグインがアクティベートさ��E討い覆韻�E�FSWikiフォーマットを返す
	unless($self->is_installed("format")){
		return "FSWiki";
	}

	#通��E牢超�設��E萍未農瀋蠅靴�Wikiフォーマットを使用
	my $config = &Util::load_config_hash($self, $self->config('config_file'));
	my $format = $config->{site_wiki_format};

	# Cookieにフォーマットが指定さ��E討い�E�E腓呂修舛蕕鮖藩�
	#(但し、config.datファイ��E�らの取得指��E�はCookieを無��E
	if($from ne "config"){
		my $cgi = $self->get_CGI();
		if($cgi->cookie(-name=>'edit_format') ne ""){
			$format = $cgi->cookie(-name=>'edit_format');
		}
	}

	if($format eq ""){
		return "FSWiki";
	} else {
		return $format;
	}
}

#==============================================================================
# <p>
# headタグ内に出力す��E霾鵑鯆媛辰靴泙后�
# ただしサイトテンプ��E璽箸�対応してい��E�要があります。
# </p>
# <pre>
# $wiki-&gt;add_head_info(&quot;<link rel=\&quot;alternate\&quot; type=\&quot;application/rss+xml\&quot; title=\&quot;RSS\&quot; href=\&quot;?action=RSS\&quot;>&quot;);
# </pre>
#==============================================================================
sub add_head_info {
	my $self = shift;
	my $info = shift;
	
	push(@{$self->{'head_info'}},$info);
}

###############################################################################
#
# 凍��E亡悗垢�E瓮愁奪彪�
#
###############################################################################
#==============================================================================
# <p>
# ページを凍��E靴泙�
# </p>
# <pre>
# $wiki-&gt;freeze_page(ページ名);
# </pre>
#==============================================================================
sub freeze_page {
	my $self = shift;
	$self->{"storage"}->freeze_page(@_);
}

#==============================================================================
# <p>
# ページの凍��E魏鮟�E靴泙�
# </p>
# <pre>
# $wiki-&gt;un_freeze_page(ページ名);
# </pre>
#==============================================================================
sub un_freeze_page {
	my $self = shift;
	$self->{"storage"}->un_freeze_page(@_);
}

#==============================================================================
# <p>
# 凍��E気�E討い�E據璽犬離�E好箸鮗萋世靴泙后�
# </p>
#==============================================================================
sub get_freeze_list {
	my $self = shift;
	return $self->{"storage"}->get_freeze_list();
}

#==============================================================================
# <p>
# 引数で渡したページが凍��E罎�どうかしらべます
# </p>
# <pre>
# if($wiki-&gt;is_freeze(ページ名)){
#   ...
# }
# </pre>
#==============================================================================
sub is_freeze {
	my $self = shift;
	my $page = shift;
	my $path = undef;
	
	if($page =~ /(^.*?[^:]):([^:].*?$)/){
		$path = $1;
		$page = $2;
	}
	
	return $self->{storage}->is_freeze($page,$path);
}

#==============================================================================
# <p>
# 引数で渡したページが編集可能かどうかを調べます。
# 編集不可モード（setup.plで$accept_editが0に設定さ��E討い�E�E隋砲魯�前インしてい��E佇埆顕椎宗�
# ページが凍��E気�E討い�E�E腓牢浜�者ユーザで��前インしてい��E�E腓吠埆顕椎修箸覆蠅泙后�
# </p>
# <pre>
# if($wiki-&gt;can_modify_page(ページ名)){
#   ...
# }
# </pre>
#==============================================================================
sub can_modify_page {
	my $self = shift;
	my $page = shift;
	my $login = $self->get_login_info();
	if($self->config('accept_edit')==0 && !defined($login)){
		return 0;
	}
	if($self->config('accept_edit')==2 && (!defined($login) || $login->{type}!=0)){
		return 0;
	}
	if($self->is_freeze($page) && (!defined($login) || $login->{type}!=0)){
		return 0;
	}
	unless($self->can_show($page)){
		return 0;
	}
	return 1;
}

###############################################################################
#
# 参照権限に関す��E瓮愁奪彪�
#
###############################################################################
#==============================================================================
# <p>
# ページの参照��E戰�E鮴瀋蠅靴泙后�
# <p>
# <ul>
#   <li>0 - 全員に公開</li>
#   <li>1 - ユーザに公開</li>
#   <li>2 - 管理者に公開</li>
# </ul>
# <pre>
# $wiki-&gt;set_page_level(ページ名,公開��E戰�E;
# </pre>
#==============================================================================
sub set_page_level {
	my $self  = shift;
	my $page  = shift;
	my $level = shift;
	
	$self->{"storage"}->set_page_level($page,$level);
}

#==============================================================================
# <p>
# ページの参照��E戰�E鮗萋世靴泙后�
# ページ名が指定さ��E討い覆ぞ�E隋∩瓦討離據璽犬了仮肇�E戰�E
# ハッシュ��E侫．�E鵐垢琶屬靴泙后�
# </p>
# <ul>
#   <li>0 - 全員に公開</li>
#   <li>1 - ユーザに公開</li>
#   <li>2 - 管理者に公開</li>
# </ul>
# <pre>
# my $level = $get_page_level(ページ名);
# </pre>
#==============================================================================
sub get_page_level {
	my $self  = shift;
	my $page  = shift;
	my $path  = undef;
	
	if($page =~ /(^.*?[^:]):([^:].*?$)/){
		$path = $1;
		$page = $2;
	}
	
	$self->{"storage"}->get_page_level($page,$path);
}

#==============================================================================
# <p>
# ページが参照可能かどうかを取得します。
# </p>
# <pre>
# if($wiki-&gt;can_show(ページ名)){
#   # 参照可能
# } else {
#   # 参照不可能
# }
# </pre>
#==============================================================================
sub can_show {
	my $self = shift;
	my $page = shift;
	my $login = $self->get_login_info();
	my $level = $self->get_page_level($page);
	
	if($self->config('accept_show')==1 && !defined($login)){
		return 0;
	}
	if($self->config('accept_show')==2 && (!defined($login) || $login->{type}!=0)){
		return 0;
	}
	if($level==1 && !defined($login)){
		return 0;
	} elsif($level==2 && (!defined($login) || $login->{type}!=0)){
		return 0;
	}
	return 1;
}

###############################################################################
#
# その他のメソッド群
#
###############################################################################
#==============================================================================
# <p>
# ページにジャンプす��E燭瓩�URLを生成す��E罅璽謄���E謄�メソッドです。
# 引数としてページ名を渡します。
# </p>
# <pre>
# $wiki-&gt;create_page_url(&quot;FrontPage&quot;);
# </pre>
# <p>
# 上記のコードは通��E�以下のURLを生成します。
# </p>
# <pre>
# wiki.cgi?page=FrontPage
# </pre>
#==============================================================================
sub create_page_url {
	my $self = shift;
	my $page = shift;
	return $self->create_url({page=>$page});
}

#==============================================================================
# <p>
# 任意のURLを生成す��E燭瓩離罅璽謄���E謄�メソッドです。
# 引数としてパラメータのハッシュ��E侫．�E鵐垢鯏呂靴泙后�
# </p>
# <pre>
# $wiki-&gt;create_url({action=>HOGE,type=>1});
# </pre>
# <p>
# 上記のコードは通��E�以下のURLを生成します。
# </p>
# <pre>
# wiki.cgi?action=HOGE&amp;type=1
# </pre>
#==============================================================================
sub create_url {
	my $self   = shift;
	my $params = shift;
	my $url    = $self->config('script_name');
	my $query  = '';
	foreach my $key (keys(%$params)){
		if($query ne ''){
			$query .= '&amp;';
		}
		$query .= Util::url_encode($key)."=".Util::url_encode($params->{$key});
	}
	if($query ne ''){
		$url .= '?'.$query; 
	}
	return $url;
}

#==============================================================================
# <p>
# アクションハンドラ中でタイト��E鮴瀋蠅垢�E�E腓忙藩僂靴泙后�
# </p>
# <pre>
# $wiki-&gt;set_title(タイト��E,編集系のページがどうか]);
# </pre>
# <p>
# 編集系の画面の��E隋�第二引数に1を指定してください。
# ��捜ット対策用に以下のMETAタグが出力さ��E泙后�
# </p>
# <pre>
# &lt;meta name=&quot;ROBOTS&quot; content=&quot;NOINDEX, NOFOLLOW&quot;&gt;
# </pre>
#==============================================================================
sub set_title {
	my $self  = shift;
	my $title = shift;
	my $edit  = shift;
	$self->{"title"} = $title;
	$self->{"edit"}  = 1 if $edit;
}

#==============================================================================
# <p>
# タイト��E鮗萋世靴泙后�
# </p>
#==============================================================================
sub get_title {
	my $self = shift;
	return $self->{"title"};
}

#==============================================================================
# <p>
# ページの��E�を取得します。
# 引数としてハッシュ��E侫．�E鵐垢鯏呂垢海箸納萋斉睛討鮖慊蠅垢�E海箸�可能。
# デフォ��E箸任倭瓦討離據璽犬鯡樵阿妊宗璽箸靴織�E好箸鯤峙僂垢�E�
# </p>
# <p>
# 以下の例は参照権のあ��E據璽犬里濕萋世掘�更新��E�でソートす��E�
# </p>
# <pre>
# my @list = $wiki-&gt;get_page_list({-sort   => 'last_modified',
#                                  -permit => 'show'});
# </pre>
# <p>
# 以下の例は全てのページを取得し、名前でソートす��E�
# </p>
# <pre>
# my @list = $wiki-&gt;get_page_list({-sort => 'name'});
# </pre>
# <p>
# 以下の例は最新の10��E鮗萋世垢�E�
# </p>
# <pre>
# my @list = $wiki-&gt;get_page_list({-sort=>'last_modified',-max=>10});
# </pre>
#==============================================================================
sub get_page_list {
	my $self = shift;
	my $args = shift;
	
	return $self->{"storage"}->get_page_list($args);

}

#==============================================================================
# <p>
# ページの物理的な（データファイ��E旅洪憩�E�）最終更新時��E鮗萋世靴泙后�
# </p>
# <pre>
# my $modified = $wiki-&gt;get_last_modified(ページ名);
# </pre>
#==============================================================================
sub get_last_modified {
	my $self = shift;
	return $self->{"storage"}->get_last_modified(@_);
}

#==============================================================================
# <p>
# ページ論理的な最終更新時��E鮗萋世靴泙后�
# 「タイムスタンプを更新しない」にチェックを入��E謄據璽犬鯤歛犬靴疹�E腓�
# このメソッドで返さ��E�E�E�は保存前のものになります。
# </p>
# <pre>
# my $modified = $wiki-&gt;get_last_modified2(ページ名);
# </pre>
#==============================================================================
sub get_last_modified2 {
	my $self = shift;
	return $self->{"storage"}->get_last_modified2(@_);
}

#==============================================================================
# <p>
# ページのソースを取得します。
# </p>
# <p>
# 第三引数にフォーマット名を渡した��E腓里漾▲侫�ーマットプラグインによ�
# ソースの変換を行います。そ��E奮阿両�E腓鷲�要に応じてプラグイン側で
# Wiki::convert_from_fswikiメソッドを呼んで変換を行います。
# </p>
#==============================================================================
sub get_page {
	my $self   = shift;
	my $page   = shift;
	my $format = shift;
	my $path   = undef;
	
	if($page =~ /(^.*?[^:]):([^:].*?$)/){
		$path = $1;
		$page = $2;
	}
	
	my $content = $self->{"storage"}->get_page($page,$path);
	
	if($format eq "" || $format eq "FSWiki"){
		return $content;
	} else {
		return $self->convert_from_fswiki($content,$format);
	}
}

#==============================================================================
# <p>
# バックアップさ��E織宗璽垢鮗萋世靴泙后�バックアップが存在しない��E腓篭�文字列を返します。
# 世代バックアップに対応したスト��E璽犬鮖藩僂靴討い�E�E腓和萋鶲�数に取得す��Eぢ紊鮖慊蠅垢�E海箸�できます。
# </p>
# <pre>
# # 世代バックアップを使用していない��E
# my $backup = $wiki-&gt;get_backup(ページ名);
#
# # 世代バックアップを使用してい��E�E
# my $backup = $wiki-&gt;get_backup(ページ名,世��E;
# </pre>
# <p>
# 世代は古いものから順に0〜の数値で指定します。
# </p>
#==============================================================================
sub get_backup {
	my $self = shift;
	return $self->{"storage"}->get_backup(@_);
}

#==============================================================================
# <p>
# ページを保存します。
# キャッシュモードONで利用してい��E�E隋▲據璽犬離�ャッシュも��E�E気�E泙后�
# </p>
# <pre>
# $wiki-&gt;save_page(ページ名,ページ内容);
# </pre>
# <p>
# フォーマットプラグインによ��E侫�ーマットの変換は行��E�E泙擦鵝�
# つまり、フォーマットプラグインを使用してい��E�E隋△海離瓮愁奪匹謀呂�
# Wikiソースは事前にFSWiki形式に変換さ��E織宗璽垢任覆韻�E个覆蠅泙擦鵝�
# </p>
# <p>
# 保存時にタイムスタンプを更新しない��E隋�第三引数に1を渡します。
# </p>
# <pre>
# $wiki-&gt;save_page(ページ名,ページ内容,1);
# </pre>
#
#==============================================================================
sub save_page {
	my $self     = shift;
	my $pagename = shift;
	my $content  = shift;
	my $sage     = shift;
	
	# ページ名をチェック
	if($pagename =~ /([\|\[\]])|^:|([^:]:[^:])/){
		die "ページ名に使用できない文字が含ま��E討い泙后�";
	}
	# いったんパラメータを上書き
	$self->get_CGI->param("page"   ,$pagename);
	$self->get_CGI->param("content",$content);
	$self->do_hook("save_before");
	# パラメータを読み込み直す
	$content = $self->get_CGI()->param("content");
	
	if($self->{"storage"}->save_page($pagename,$content,$sage)){
		if($content ne ""){
			$self->do_hook("save_after");
		} else {
			$self->do_hook("delete");
		}
	}
}

#===============================================================================
# <p>
# ページが存在す��E�どうか調べます。
# </p>
# <pre>
# if($wiki-&gt;page_exists(ページ名)){
#   # ページが存在す��E�E腓僚萢�
# } else {
#   # ページが存在しない��E腓僚萢�
# }
# </pre>
#===============================================================================
sub page_exists {
	my $self = shift;
	my $page = shift;
	my $path = undef;
	
	if($page =~ /(^.*?[^:]):([^:].*?$)/){
		$path = $1;
		$page = $2;
	}
	
	# InterWiki形式の指定でドットを含むことはできない
	if(defined($path) && index($path,".")!=-1){
		return 0;
	}
	
	return $self->{"storage"}->page_exists($page,$path);
}

#===============================================================================
# <p>
# CGIオブジェクトを取得
# </p>
# <pre>
# my $cgi = $wiki-&gt;get_CGI;
# </pre>
#===============================================================================
sub get_CGI {
	my $self = shift;
	return $self->{"CGI"};
}

#==============================================================================
# <p>
# 引数で渡したページに��E瀬ぅ�E�トします。
# ページの保存後にページを再表示す��E�E腓呂海離瓮愁奪匹鮖藩僂靴堂爾気ぁ�
# なお、このメソッドを呼び出すとそこでスク��E廛箸亮孫圓禄�了し、呼び出し元に制御は戻りません。
# </p>
# <pre>
# $wiki-&gt;redirect(&quot;FrontPage&quot;);
# </pre>
#==============================================================================
sub redirect {
	my $self = shift;
	my $page = shift;
	$self->redirectURL($self->create_page_url($page));
}

#==============================================================================
# <p>
# 指定のURLに��E瀬ぅ�E�トします。
# このメソッドを呼び出すとそこでスク��E廛箸亮孫圓禄�了し、呼び出し元に制御は戻りません。
# </p>
# <pre>
# $wiki-&gt;redirectURL(��E瀬ぅ�E�トす��ERL);
# </pre>
#==============================================================================
sub redirectURL {
	my $self = shift;
	my $url  = shift;
	
	# Locationタグで��E瀬ぅ�E�ト
	if($self->config('redirect')==1){
		my ($hoge,$param) = split(/\?/,$url);
		$url = $self->get_CGI->url().$self->get_CGI()->path_info();
		if($param ne ''){
			$url = "$url?$param";
		}
		print "Location: $url\n\n";
		
	# METAタグで��E瀬ぅ�E�ト
	} else {
		my $tmpl = HTML::Template->new(filename=>$self->config('tmpl_dir')."/redirect.tmpl",
		                               die_on_bad_params => 0);
		
		$tmpl->param(URL=>$url);
		
		print "Content-Type: text/html\n\n";
		print $tmpl->output();
	}
	exit();
}

#==============================================================================
# <p>
# グ��充バ��E瀋蠅鮗萋世發靴�は変更します
# </p>
# <pre>
# # データファイ��E魍頁爾垢�E妊���E�ト�
# my $data_dir = $wiki-&gt;config('data_dir');
#
# # 設定��Edata_dirで上書き
# $wiki-&gt;config('data_dir',$data_dir);
# </pre>
#==============================================================================
sub config {
	my $self  = shift;
	my $name  = shift;
	my $value = shift;
	if(defined($value)){
		$self->{config}->{$name} = $value;
	} else {
		return $self->{config}->{$name};
	}
}
###############################################################################
#
# Farm関係のメソッド群
#
###############################################################################
#==============================================================================
# <p>
# Farm機能が有効になってい��E�どうかを取得します
# </p>
# <pre>
# if($wiki-&gt;farm_is_enable()){
#   # Farmが有効になってい��E箸�の処理
# } else {
#   # Farmが無効になってい��E箸�の処理
# }
# </pre>
#==============================================================================
sub farm_is_enable {
	my $self = shift;
	my $farm_config = &Util::load_config_hash($self,$self->config('farmconf_file'));
	if(defined $farm_config->{usefarm} and $farm_config->{usefarm}==1){
		return 1;
	} else {
		return 0;
	}
}

#==============================================================================
# <p>
# 子Wikiを笹椪します。引数にはWikiの名前、笹椪す��Eikiサイトの管理者ID、パス��E璽匹鯏呂靴泙后�
# このメソッド内ではWikiサイト名のバ��E如璽轡腑鵑篏妬�チェックは行��E�E泙擦鵝�
# 事前に行う必要があります。このメソッドはfarmプラグインを使用してい��E�E腓里濟藩儔椎修任后�
# </p>
# <pre>
# $wiki-&gt;create_wiki(Wikiサイト名,管理者ID,パス��E璽�);
# </pre>
#==============================================================================
sub create_wiki{
	my $self  = shift;
	my $child = shift;
	my $id    = shift;
	my $pass  = shift;
	
	# data、backupディ��E�トリを掘��E萢�はStorageに任せたほうがいいかな？
	unless($self->wiki_exists($child)){
		eval {
			# コアでサポートす��E妊���E�トリを掘�
			mkpath($self->config('data_dir'  )."/$child") or die $!;
			mkpath($self->config('backup_dir')."/$child") or die $!;
			mkpath($self->config('config_dir')."/$child") or die $!;
			mkpath($self->config('log_dir'   )."/$child") or die $!;
			
			# 設定のコピー
			copy($self->config('config_dir')."/".$self->config('config_file'),
			     $self->config('config_dir')."/$child/".$self->config('config_file')) or die $!;
			copy($self->config('config_dir')."/".$self->config('usercss_file'),
			     $self->config('config_dir')."/$child/".$self->config('usercss_file')) or die $!;
			copy($self->config('config_dir')."/".$self->config('plugin_file'),
			     $self->config('config_dir')."/$child/".$self->config('plugin_file')) or die $!;
			copy($self->config('config_dir')."/".$self->config('mime_file'),
			     $self->config('config_dir')."/$child/".$self->config('mime_file')) or die $!;
			
			# 管理ユーザの笹椪（ここで笹��E里呂舛腓辰肇▲�E�も・・・）
			open(USERDAT,">".$self->config('config_dir')."/$child/".$self->config('userdat_file')) or die $!;
			print USERDAT "$id=".&Util::md5($pass,$id)."\t0\n";
			close(USERDAT);
			
			# テンプ��E璽箸�らページのコピー
			my $farm_config = &Util::load_config_hash($self,$self->config('farmconf_file'));
			if($farm_config->{'use_template'}==1 && $child ne "template"){
				my $template = $self->config('data_dir')."/template";
				my $depth = $self->_get_wiki_depth();
				my $count = 0;
				while((!(-e $template) || !(-d $template)) && $count < $depth && $farm_config->{'search_parent'}==1){
					$template =~ s/\/template$//;
					$template = $template."/../template";
					$count++;
				}
				if(-e $template && -d $template){
					opendir(DIR,$template) or die $!;
					while(my $entry = readdir(DIR)){
						if($entry =~ /\.wiki$/){
							copy($template."/$entry",$self->config('data_dir')."/$child/$entry");
						}
					}#
					closedir(DIR);
				}
			}
			# create_wikiフックの呼び出し
			$self->do_hook("create_wiki");
		};
		
		# エラーが発生した��E腑�リーンアップ処理
		if($@){
			my $error = $@;
			# ここはエラーが出ても続行
			eval {
				$self->remove_wiki("/$child");
			};
			die "$childの笹椪に失敗しました。発生したエラーは以下のとおりです。\n\n$error";
		}
	}
}

#==============================================================================
# <p>
# 現在のWikiの階層を返却します。��E璽箸両�E腓�0、子Wikiの��E腓�1、
# 孫Wikiの��E腓�2…というようになります。
# </p>
#==============================================================================
sub _get_wiki_depth {
	my $self = shift;
	my $path_info = $self->get_CGI()->path_info();
	$path_info =~ s/^\///;
	my $depth = split(/\//,$path_info);
	return $depth;
}

#==============================================================================
# <p>
# 子Wikiを��E�E靴泙后０�数には��E�E垢�Eikiサイトのパス（PATH_INFO部分）を渡します。
# このメソッドはfarmプラグインを使用してい��E�E腓里濟藩儔椎修任后�
# </p>
# <pre>
# $wiki-&gt;remove_wiki(Wikiサイトのパス);
# </pre>
#==============================================================================
sub remove_wiki {
	my $self = shift;
	my $path = shift;
	
	# コアでサポートす��E妊���E�トリを��E
	rmtree($self->config('data_dir'  ).$path) or die $!;
	rmtree($self->config('backup_dir').$path) or die $!;
	rmtree($self->config('config_dir').$path) or die $!;
	rmtree($self->config('log_dir'   ).$path) or die $!;
	
	# remove_wikiフックの呼び出し
	$self->get_CGI()->param('path',$path);
	$self->do_hook("remove_wiki");
}

#==============================================================================
# <p>
# 引数で渡した名称の子Wikiが存在す��E�どうかを調べます。
# このメソッドはfarmプラグインを使用してい��E�E腓里濟藩儔椎修任后�
# </p>
# <pre>
# $wiki-&gt;wiki_exists(Wikiサイト名);
# </pre>
#==============================================================================
sub wiki_exists{
	my $self  = shift;
	my $child = shift;
	return ($child =~ /[A-Za-z0-9]+(\/[A-Za-z0-9]+)*/
			and -d $self->config('data_dir')."/$child");
}

#==============================================================================
# <p>
# 子Wikiを配列で取得します。孫Wiki、曾孫Wikiは配列の��E侫．�E鵐垢箸靴導頁爾気�E討い泙后�
# </p>
#==============================================================================
sub get_wiki_list{
	my $self = shift;
	if($self->farm_is_enable){
		my @list = $self->search_child($self->config('config_dir'));
		return @list;
	} else {
		return ();
	}
}

#==============================================================================
# <p>
# 子Wikiのツリーを配列で取得します。
# ネストしたWikiは配列��E侫．�E鵐垢燃頁爾靴泙后�
# </p>
#==============================================================================
sub search_child {
	my $self = shift;
	my $dir  = shift;
	my @dirs = ();
	my @list = ();
	
	opendir(DIR,$dir) or die $!;
	while(my $entry = readdir(DIR)){
		if(-d "$dir/$entry" && $entry ne "." && $entry ne ".."){
			push(@dirs,$entry);
		}
	}
	closedir(DIR);
	@dirs = sort @dirs;
	
	foreach my $entry (@dirs){
		push(@list,$entry);
		my @child = $self->search_child("$dir/$entry");
		if($#child>-1){
			push(@list,\@child);
		}
	}
	
	return @list;
}

#==============================================================================
# <p>
# 終了前の処理。
# </p>
#==============================================================================
sub _process_before_exit {
	my $self = shift;
	# プラグイン用のフック
	$self->do_hook('finalize');
	# finalizeメソッドの呼び出し
	$self->get_CGI()->finalize();
	$self->{storage}->finalize();
}

1;
