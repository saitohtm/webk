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
#   е│еєе╣е╚ещепе┐
# </p>
#==============================================================================
sub new {
	my $class = shift;
	my $self  = {};
	
	# └▀─ъдЄ╞╔д▀╣■д▀
	my $setupfile = shift || 'setup.dat';
	$self->{"config"} = &Util::load_config_hash(undef,$setupfile);
	die "setup file ${setupfile} not found" if (keys %{$self->{"config"}} == 0);
	$self->{"config"}->{"plugin_dir"} = "."         unless exists($self->{"config"}->{"plugin_dir"});
	$self->{"config"}->{"frontpage"}  = "FrontPage" unless exists($self->{"config"}->{"frontpage"});
	unshift(@INC, $self->{"config"}->{"plugin_dir"});
	$ENV{'TZ'} = $self->{"config"}->{"time_zone"};
	$CGI::POST_MAX = $self->{"config"}->{"post_max"} if $self->{"config"}->{"post_max"} ne '';
	
	# едеєе╣е┐еєе╣╩╤┐ЇдЄ╜щ┤БE╜
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
	
	# е╣е╚еБE╝е╕д╬едеєе╣е┐еєе╣дЄ└╕└о
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
# ецб╝е╢┤╪╖╕д╬есе╜е├е╔╖▓
#
###############################################################################
#==============================================================================
# <p>
#   ецб╝е╢дЄ─╔▓├д╖д▐д╣
# </p>
# <pre>
# $wiki-&gt;add_user(ID,е╤е╣еБE╝е╔,ецб╝е╢е┐еде╫);
# </pre>
# <p>
# ецб╝е╢е┐еде╫д╦д╧┤╔═¤╝╘ецб╝е╢д╬╛БEБEбв░БE╠ецб╝е╢д╬╛БEБEдЄ╗╪─ъд╖д▐д╣бг
# д╩дкбвд│д╬есе╜е├е╔д╧╝┬╣╘╗■д╦Wiki.pmд╦ецб╝е╢дЄ─╔▓├д╣дБE┐дсд╬дтд╬д╟бв
# д│д╬есе╜е├е╔д╦┬╨д╖д╞ецб╝е╢дЄ─╔▓├д╖д╞дт▒╩┬│▓╜д╧╣╘дБEБE▐д╗дєбг
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
#   ецб╝е╢дм┬╕║▀д╣дБEлд╔дждлдЄ│╬╟зд╖д▐д╣
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
#   е·┴░едеє╛Ё╩єдЄ╝ш╞└д╖д▐д╣бг
#   е·┴░едеєд╖д╞дддБEБEчд╧е·┴░едеє╛Ё╩єдЄ┤▐дєд└е╧е├е╖ехеБE╒ебеБEєе╣дЄбв
#   е·┴░едеєд╖д╞ддд╩дд╛БEчд╧undefдЄ╩╓д╖д▐д╣бг
# </p>
# <pre>
# my $info = $wiki-&gt;get_login_info();
# if(defined($info)){          # е·┴░едеєд╖д╞ддд╩дд╛БEчд╧undef
#   my $id   = $info-&gt;{id};    # е·┴░едеєецб╝е╢д╬ID
#   my $type = $info-&gt;{type};  # е·┴░едеєецб╝е╢д╬╝БE╠(0:┤╔═¤╝╘ 1:░БE╠)
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

	# PATH_INFOдЄ─┤д┘д
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
	
	# епе├енб╝дме╗е├е╚д╡дБE╞ддд╩дд
	if($id eq "" ||  $type eq ""){
		$self->{'login_info'} = undef;
		return undef;
	}
	
	# ецб╝е╢╛Ё╩єдЄ╩╓╡╤
	$self->{'login_info'} = {id=>$id,type=>$type,path=>$path};
	return $self->{'login_info'};
}

#==============================================================================
# <p>
#   е·┴░едеєе┴езе├епдЄ╣╘ддд▐д╣бг
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
# е╫еще░едеє┤╪╖╕д╬есе╜е├е╔╖▓
#
###############################################################################
#==============================================================================
# <p>
#   еие╟еге├е╚е╒ейб╝ере╫еще░едеєдЄ─╔▓├д╖д▐д╣
# </p>
# <pre>
# $wiki-&gt;add_editform_plugin(еие╟еге├е╚е╒ейб╝ере╫еще░едеєд╬епеще╣╠╛,═е└ш┼┘);
# </pre>
# <p>
# ═е└ш┼┘дм┬чднддд█д╔╛х░╠д╦╔╜╝ид╡дБE▐д╣бг
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
#   ╩╘╜╕е╒ейб╝ер═╤д╬е╫еще░едеєд╬╜╨╬╧дЄ╝ш╞└д╖д▐д╣
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
# ┤╔═¤╝╘═╤д╬есе╦ехб╝дЄ─╔▓├д╖д▐д╣бг┤╔═¤╝╘ецб╝е╢дме·┴░едеєд╖д┐╛БEчд╦╔╜╝ид╡дБE▐д╣бг
# ═е└ш┼┘дм╣тддд█д╔╛хд╬д█джд╦╔╜╝ид╡дБE▐д╣бг
# </p>
# <pre>
# $wiki-&gt;add_admin_menu(есе╦ехб╝╣р╠▄╠╛,┴л░▄д╣дБERL,═е└ш┼┘,╛▄║┘└т╠└);
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
# е·┴░едеєецб╝е╢═╤д╬есе╦ехб╝дЄ─╔▓├д╖д▐д╣бг
# ецб╝е╢дме·┴░едеєд╖д┐╛БEчд╦╔╜╝ид╡дБE▐д╣бг┤╔═¤╝╘ецб╝е╢д╬╛БEчдт╔╜╝ид╡дБE▐д╣бг
# ═е└ш┼┘дм╣тддд█д╔╛хд╬д█джд╦╔╜╝ид╡дБE▐д╣бг
# </p>
# <pre>
# $wiki-&gt;add_admin_menu(есе╦ехб╝╣р╠▄╠╛,┴л░▄д╣дБERL,═е└ш┼┘,╛▄║┘└т╠└);
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
# ┤╔═¤╝╘═╤д╬есе╦ехб╝дЄ╝ш╞└д╖д▐д╣бг
# </p>
#==============================================================================
sub get_admin_menu {
	my $self = shift;
	return sort { $b->{weight}<=>$a->{weight} } @{$self->{"admin_menu"}};
}

#==============================================================================
# <p>
# е╫еще░едеєдЄедеєе╣е╚б╝еБE╖д▐д╣бгд│д╬есе╜е├е╔д╧wiki.cgiд╦дшд├д╞callд╡дБE▐д╣бг
# е╫еще░едеє│л╚пд╦дкддд╞─╠╛БEвд│д╬есе╜е├е╔дЄ╗╚═╤д╣дБE│д╚д╧двдъд▐д╗дєбг
# </p>
#==============================================================================
sub install_plugin {
	my $self   = shift;
	my $plugin = shift;
	
	if ($plugin =~ /\W/) {
		return Util::escapeHTML("${plugin}е╫еще░едеєд╧╔╘└╡д╩е╫еще░едеєд╟д╣бг");
#		return "<div class=\"error\">".Util::escapeHTML("${plugin}е╫еще░едеєд╧╔╘└╡д╩е╫еще░едеєд╟д╣бг")."</div>";
	}
		
	my $module = "plugin::${plugin}::Install";
	eval 'require &Util::get_module_file($module);'.$module.'::install($self);';
	
	if($@){
		return Util::escapeHTML("${plugin}е╫еще░едеєдмедеєе╣е╚б╝еБE╟днд▐д╗дєбг$@");
#		return "<div class=\"error\">".Util::escapeHTML("${plugin}е╫еще░едеєдмедеєе╣е╚б╝еБE╟днд▐д╗дєбг$@")."</div>";
	} else {
		push(@{$self->{"installed_plugin"}},$plugin);
		return "";
	}
}

#==============================================================================
# <p>
# е╫еще░едеєдмедеєе╣е╚б╝еБE╡дБE╞дддБEлд╔дждлдЄ─┤д┘д▐д╣бг
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
# есе╦ехб╝╣р╠▄дЄ─╔▓├д╖д▐д╣бг┤√д╦╞▒д╕╠╛┴░д╬╣р╠▄дм┼╨╧┐д╡дБE╞дддБEБEчд╧╛х╜ёднд╖д▐д╣бг
# ═е└ш┼┘дм╣тддд█д╔║╕┬жд╦╔╜╝ид╡дБE▐д╣бг
# </p>
# <pre>
# $wiki-&gt;add_menu(╣р╠▄╠╛,URL,═е└ш┼┘,епе·╜╝еБEЄ╡ё╚▌д╣дБEлд╔дждл);
# </pre>
# <p>
# ╕б║ўеиеєе╕еєд╦епе·╜╝еБE╡д╗д┐дпд╩дд╛БEчд╧┬БE░·┐Їд╦1бв╡Ў▓─д╣дБEБEчд╧0дЄ╗╪─ъд╖д▐д╣бг
# ╛╩╬мд╖д┐╛БEчд╧епе·╜╝еБEЄ╡Ў▓─д╖д▐д╣бг
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
# е╒е├епе╫еще░едеєдЄ┼╨╧┐д╖д▐д╣бг┼╨╧┐д╖д┐е╫еще░едеєд╧do_hookесе╜е├е╔д╟╕╞д╙╜╨д╖д▐д╣бг
# </p>
# <pre>
# $wiki-&gt;add_hook(е╒е├еп╠╛,е╒е├епе╫еще░едеєд╬епеще╣╠╛);
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
# add_hookесе╜е├е╔д╟┼╨╧┐д╡дБE┐е╒е├епе╫еще░едеєдЄ╝┬╣╘д╖д▐д╣бг
# ░·┐Їд╦д╧е╒е├епд╬╠╛┴░д╦▓├дид╞╟д░╒д╬е╤ещесб╝е┐дЄ┼╧д╣д│д╚дмд╟днд▐д╣бг
# д│дБEщд╬е╤ещесб╝е┐д╧╕╞д╙╜╨д╡дБEБEпеще╣д╬hookесе╜е├е╔д╬░·┐Їд╚д╖д╞┼╧д╡дБE▐д╣бг
# </p>
# <pre>
# $wiki-&gt;do_hook(е╒е├еп╠╛[,░·┐БE[,░·┐БE...]]);
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
# евепе╖ечеєе╧еєе╔еще╫еще░едеєдЄ─╔▓├д╖д▐д╣бг
# еБEпеие╣е╚╗■д╦actionд╚дддже╤ещесб╝е┐дм░БE╫д╣дБEвепе╖ечеєдм╕╞д╙╜╨д╡дБE▐д╣бг
# </p>
# <pre>
# $wiki-&gt;add_handler(actionе╤ещесб╝е┐,евепе╖ечеєе╧еєе╔ещд╬епеще╣╠╛);
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
# е·┴░едеєецб╝е╢═╤д╬евепе╖ечеєе╧еєе╔ещдЄ─╔▓├д╖д▐д╣бг
# д│д╬есе╜е├е╔д╦дшд├д╞─╔▓├д╡дБE┐евепе╖ечеєе╧еєе╔ещд╧е·┴░едеєд╖д╞дддБEБEчд╬д▀╝┬╣╘▓─╟╜д╟д╣бг
# д╜дБE╩│░д╬╛БEчд╧еиещб╝есе├е╗б╝е╕дЄ╔╜╝ид╖д▐д╣бг
# </p>
# <pre>
# $wiki-&gt;add_user_handler(actionе╤ещесб╝е┐,евепе╖ечеєе╧еєе╔ещд╬епеще╣╠╛);
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
# ┤╔═¤╝╘═╤д╬евепе╖ечеєе╧еєе╔ещдЄ─╔▓├д╖д▐д╣бг
# д│д╬есе╜е├е╔д╦дшд├д╞─╔▓├д╡дБE┐евепе╖ечеєе╧еєе╔ещд╧┤╔═¤╝╘д╚д╖д╞е·┴░едеєд╖д╞дддБEБEчд╬д▀╝┬╣╘▓─╟╜д╟д╣бг
# д╜дБE╩│░д╬╛БEчд╧еиещб╝есе├е╗б╝е╕дЄ╔╜╝ид╖д▐д╣бг
# </p>
# <pre>
# $wiki-&gt;add_admin_handler(actionе╤ещесб╝е┐,евепе╖ечеєе╧еєе╔ещд╬епеще╣╠╛);
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
# едеєещедеєе╫еще░едеєдЄ─╔▓├д╖д▐д╣бг
# </p>
# <p>
# д│д╬есе╜е├е╔д╧3.4╖╧д╚д╬╕▀┤╣└ндЄ░▌╗¤д╣дБE┐дсд╦╗─д╖д▐д╖д┐бг3.6д╟╟╤╗▀д╣дБEтд╬д╚д╖д▐д╣бг
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
# едеєещедеєе╫еще░едеєдЄ┼╨╧┐д╖д▐д╣бге╫еще░едеєд╬╜╨╬╧е┐еде╫д╦д╧"WIKI"д▐д┐д╧"HTML"дЄ╗╪─ъд╖д▐д╣бг
# ╛╩╬мд╖д┐╛БEчд╧"HTML"дЄ╗╪─ъд╖д┐дтд╬д╚д▀д╩д╡дБE▐д╣бг
# </p>
# <pre>
# $wiki-&gt;add_inline_plugin(е╫еще░едеє╠╛,е╫еще░едеєд╬епеще╣╠╛,е╫еще░едеєд╬╜╨╬╧е┐еде╫);
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
# е╤еще░еще╒е╫еще░едеєдЄ┼╨╧┐д╖д▐д╣бге╫еще░едеєд╬╜╨╬╧е┐еде╫д╦д╧"WIKI"д▐д┐д╧"HTML"дЄ╗╪─ъд╖д▐д╣бг
# ╛╩╬мд╖д┐╛БEчд╧"HTML"дЄ╗╪─ъд╖д┐дтд╬д╚д▀д╩д╡дБE▐д╣бг
# </p>
# <pre>
# $wiki-&gt;add_inline_plugin(е╫еще░едеє╠╛,е╫еще░едеєд╬епеще╣╠╛,е╫еще░едеєд╬╜╨╬╧е┐еде╫);
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
# е╓е·┴├епе╫еще░едеєдЄ┼╨╧┐д╖д▐д╣бге╫еще░едеєд╬╜╨╬╧е┐еде╫д╦д╧"WIKI"д▐д┐д╧"HTML"дЄ╗╪─ъд╖д▐д╣бг
# ╛╩╬мд╖д┐╛БEчд╧"HTML"дЄ╗╪─ъд╖д┐дтд╬д╚д▀д╩д╡дБE▐д╣бг
# </p>
# <pre>
# $wiki-&gt;add_block_plugin(е╫еще░едеє╠╛,е╫еще░едеєд╬епеще╣╠╛,е╫еще░едеєд╬╜╨╬╧е┐еде╫);
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
# е╫еще░едеєд╬╛Ё╩єдЄ╝ш╞└д╖д▐д╣
# </p>
# <pre>
# my $info = $wiki-&gt;get_plugin_info(&quot;include&quot;);
# my $class  = $info-&gt;{CLASS};  # е╫еще░едеєд╬епеще╣╠╛
# my $type   = $info-&gt;{TYPE};   # inlineбвparagraphбвblockд╬ддд║дБEл
# my $format = $info-&gt;{FORMAT}; # HTMLд▐д┐д╧WIKI
# </pre>
#==============================================================================
sub get_plugin_info {
	my $self = shift;
	my $name = shift;
	
	return $self->{plugin}->{$name};
}

#==============================================================================
# <p>
# add_handlerесе╜е├е╔д╟┼╨╧┐д╡дБE┐евепе╖ечеєе╧еєе╔ещдЄ╝┬╣╘д╖д▐д╣бг
# евепе╖ечеєе╧еєе╔ещд╬do_actionесе╜е├е╔д╬╠сдБE═дЄ╩╓д╖д▐д╣бг
# </p>
# <pre>
# my $content = $wiki-&gt;call_handler(actionе╤ещесб╝е┐);
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
		return $self->error("╔╘└╡д╩евепе╖ечеєд╟д╣бг");
	}
	
	# ┤╔═¤╝╘═╤д╬евепе╖ече
	if($self->{"handler_permission"}->{$action}==0){
		my $login = $self->get_login_info();
		if(!defined($login)){
			return $self->error("е·┴░едеєд╖д╞ддд▐д╗дєбг");
			
		} elsif($login->{type}!=0){
			return $self->error("┤╔═¤╝╘╕в╕┬дм╔м═╫д╟д╣бг");
		}
		return $obj->do_action($self).
		       "<div class=\"comment\"><a href=\"".$self->create_url({action=>"LOGIN"})."\">есе╦ехб╝д╦╠сдБE/a></div>";
	
	# е·┴░едеєецб╝е╢═╤д╬евепе╖ече
	} elsif($self->{"handler_permission"}->{$action}==2){
		my $login = $self->get_login_info();
		if(!defined($login)){
			return $self->error("е·┴░едеєд╖д╞ддд▐д╗дєбг");
		}
		return $obj->do_action($self).
		       "<div class=\"comment\"><a href=\"".$self->create_url({action=>"LOGIN"})."\">есе╦ехб╝д╦╠сдБE/a></div>";
		
	# ╔с─╠д╬евепе╖ече
	} else {
		return $obj->do_action($self);
	}
}

#===============================================================================
# <p>
# ░·┐Їд╟┼╧д╖д┐Wikiе╒ейб╝е▐е├е╚д╬╩╕╗·╬єдЄHTMLд╦╩╤┤╣д╖д╞╩╓д╖д▐д╣бг
# </p>
# <pre>
# my $html = $wiki-&gt;process_wiki(╩╕╗·╬БE;
# </pre>
#===============================================================================
sub process_wiki {
	my $self    = shift;
	my $source  = shift;
	my $mainflg = shift;
	
	if($self->{parse_times} >= 50){
		return $self->error("Wiki::process_wikiд╬╕╞д╙╜╨д╖▓є┐Їдм╛х╕┬дЄ▒█дид▐д╖д┐бг");
	}
	
	$self->{parse_times}++;
	my $parser = Wiki::HTMLParser->new($self,$mainflg);
	$parser->parse($source);
	$self->{parse_times}--;
	
	return $parser->{html};
}

#===============================================================================
# <p>
# едеєещедеєе╫еще░едеєбве╤еще░еще╒е╫еще░едеєд╬╕╞д╙╜╨д╖б╩╞т╔Ї╜ш═¤═╤д╬┤╪┐Їб╦бг
# ╜щ┤БE╬есе╜е├е╔д╬д┐дс╠┐╠╛╡м┬зб╩privateесе╜е├е╔д╬есе╜е├е╔╠╛д╧_длдщ╗╧дсдБE╦
# д╦╜╛д├д╞ддд▐д╗дєбг
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
		return "<font class=\"error\">".&Util::escapeHTML($name)."е╫еще░едеєд╧┬╕║▀д╖д▐д╗дєбг</font>";
		
	} else {
		if($info->{FORMAT} eq "WIKI"){
			# ╬в╡╗═╤(е╫еще░едеє╞т╔Їдлдще╤б╝е╡дЄ╗╚дж╛БEБE
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
			# е╤б╝е╡д╬╗▓╛╚дЄ▓Є╩
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
# е╤б╝е╣├цд╬╛БEчбв╕╜║▀═н╕·д╩Wiki::Parserд╬едеєе╣е┐еєе╣дЄ╩╓╡╤д╖д▐д╣бг
# е╤б╝е╣├цд╬╞т═╞дЄе╫еще░едеєдлдщ╩╤╣╣д╖д┐дд╛БEчд╦╗╚═╤д╖д▐д╣бг
# </p>
#==============================================================================
sub get_current_parser {
	my $self = shift;
	my @parsers = @{$self->{'current_parser'}};
	return $parsers[$#parsers];
}

#==============================================================================
# <p>
# еиещб╝д╬╛БEчбв╕╞д╙╜╨д╖д▐д╣бг
# евепе╖ечеєе╧еєе╔ещдлдщеиещб╝дЄ╩є╣Ёд╣дБE▌д╦╗╚═╤д╖д╞дпд└д╡ддбг
# </p>
# <pre>
# sub do_action {
#   my $self = shift;
#   my $wiki = shift;
#   ...
#   return $wiki-&gt;error(еиещб╝есе├е╗б╝е╕);
# }
# </pre>
#==============================================================================
sub error {
	my $self    = shift;
	my $message = shift;
	
	$self->set_title("еиещб╝");
	$self->get_CGI->param("action","ERROR");
	
	return Util::escapeHTML($message);
#	return "<div class=\"error\">".Util::escapeHTML($message)."</div>";
}

#===============================================================================
# <p>
# е╫еще░едеєд╬едеєе╣е┐еєе╣дЄ╝ш╞└д╖д▐д╣бгWiki.pmд╟╞т╔Ї┼кд╦╗╚═╤д╡дБEБEсе╜е├е╔д╟д╣бг
# е╫еще░едеє│л╚пд╦дкддд╞─╠╛БEвд│д╬есе╜е├е╔дЄ╗╚═╤д╣дБEм═╫д╧двдъд▐д╗дєбг
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
# едеєещедеєе╫еще░едеєдЄе╤б╝е╣д╖д╞е│е▐еєе╔д╚░·┐Їд╦╩м│фд╖д▐д╣бг
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
			return {error=>"едеєещедеєе╫еще░едеєд╬╣╜╩╕дм╔╘└╡д╟д╣бг"};
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
# е╒ейб╝е▐е├е╚е╫еще░едеєдЄ─╔▓├д╖д▐д╣бг
# е╒ейб╝е▐е├е╚е╫еще░едеєд╧convert_to_fswikiесе╜е├е╔д╚convert_from_fswikiесе╜е├е╔д
# ╝┬┴їд╖д┐епеще╣д╟д╩дпд╞д╧д╩дъд▐д╗дєбг
# </p>
# <pre>
# $wiki-&gt;add_format_plugin(╩╕╦б╠╛,епеще╣╠╛);
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
# едеєе╣е╚б╝еБE╡дБE╞дддБE╒ейб╝е▐е├е╚е╫еще░едеєд╬░БEўдЄ╝ш╞└д╖д▐д╣бг
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
# │╞Wiki╜ё╝░д╟╡н╜╥д╖д┐е╜б╝е╣дЄFSWikiд╬╜ё╝░д╦╩╤┤╣д╖д▐д╣бг
# </p>
# <pre>
# $source = $wiki-&gt;convert_to_fswiki($source,&quot;YukiWiki&quot;);
# </pre>
# <p>
# едеєещедеє╜ё╝░д╬д▀╩╤┤╣дЄ╣╘дж╛БEчд╧┬ш╗░░·┐Їд╦1дЄ┼╧д╖д▐д╣бг
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
# FSWikiд╬╜ё╝░д╟╡н╜╥д╖д┐е╜б╝е╣дЄ│╞Wikiд╬╜ё╝░д╦╩╤┤╣д╖д▐д╣бг
# </p>
# <pre>
# $source = $wiki-&gt;convert_from_fswiki($source,&quot;YukiWiki&quot;);
# </pre>
# <p>
# едеєещедеє╜ё╝░д╬д▀╩╤┤╣дЄ╣╘дж╛БEчд╧┬ш╗░░·┐Їд╦1дЄ┼╧д╖д▐д╣бг
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
# ╕╜║▀д╬ецб╝е╢дм╩╘╜╕д╦╗╚═╤д╣дБE╒ейб╝е▐е├е╚дЄ╝ш╞└д╖д▐д╣бг
# formatе╫еще░едеєдмевепе╞еге┘б╝е╚д╡дБE╞ддд╩дд╛БEчд╧╛БE╦"FSWiki"дЄ╩╓д╖д▐д╣бг
# </p>
# <pre>
# my $format = $wiki-&gt;get_edit_format();
# </pre>
#==============================================================================
sub get_edit_format {
	my $self = shift;
	my $from = shift;
	
	# formatе╫еще░едеєдмевепе╞еге┘б╝е╚д╡дБE╞ддд╩д▒дБE╨FSWikiе╒ейб╝е▐е├е╚дЄ╩╓д╣
	unless($self->is_installed("format")){
		return "FSWiki";
	}

	#─╠╛БE╧┤─╢н└▀─БEш╠╠д╟└▀─ъд╖д┐Wikiе╒ейб╝е▐е├е╚дЄ╗╚═╤
	my $config = &Util::load_config_hash($self, $self->config('config_file'));
	my $format = $config->{site_wiki_format};

	# Cookieд╦е╒ейб╝е▐е├е╚дм╗╪─ъд╡дБE╞дддБEБEчд╧д╜д┴дщдЄ╗╚═╤
	#(├вд╖бвconfig.datе╒ебедеБEлдщд╬╝ш╞└╗╪─БE■д╧CookieдЄ╠╡╗БE
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
# headе┐е░╞тд╦╜╨╬╧д╣дБEЁ╩єдЄ─╔▓├д╖д▐д╣бг
# д┐д└д╖е╡еде╚е╞еєе╫еБE╝е╚дм┬╨▒■д╖д╞дддБEм═╫дмдвдъд▐д╣бг
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
# ┼р╖БE╦┤╪д╣дБEсе╜е├е╔╖▓
#
###############################################################################
#==============================================================================
# <p>
# е┌б╝е╕дЄ┼р╖БE╖д▐д╣
# </p>
# <pre>
# $wiki-&gt;freeze_page(е┌б╝е╕╠╛);
# </pre>
#==============================================================================
sub freeze_page {
	my $self = shift;
	$self->{"storage"}->freeze_page(@_);
}

#==============================================================================
# <p>
# е┌б╝е╕д╬┼р╖БEЄ▓Є╜БE╖д▐д╣
# </p>
# <pre>
# $wiki-&gt;un_freeze_page(е┌б╝е╕╠╛);
# </pre>
#==============================================================================
sub un_freeze_page {
	my $self = shift;
	$self->{"storage"}->un_freeze_page(@_);
}

#==============================================================================
# <p>
# ┼р╖БE╡дБE╞дддБE┌б╝е╕д╬еБE╣е╚дЄ╝ш╞└д╖д▐д╣бг
# </p>
#==============================================================================
sub get_freeze_list {
	my $self = shift;
	return $self->{"storage"}->get_freeze_list();
}

#==============================================================================
# <p>
# ░·┐Їд╟┼╧д╖д┐е┌б╝е╕дм┼р╖БEцдлд╔дждлд╖дщд┘д▐д╣
# </p>
# <pre>
# if($wiki-&gt;is_freeze(е┌б╝е╕╠╛)){
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
# ░·┐Їд╟┼╧д╖д┐е┌б╝е╕дм╩╘╜╕▓─╟╜длд╔дждлдЄ─┤д┘д▐д╣бг
# ╩╘╜╕╔╘▓─етб╝е╔б╩setup.plд╟$accept_editдм0д╦└▀─ъд╡дБE╞дддБEБEчб╦д╧е·┴░едеєд╖д╞дддБE╨╩╘╜╕▓─╟╜бв
# е┌б╝е╕дм┼р╖БE╡дБE╞дддБEБEчд╧┤╔═¤╝╘ецб╝е╢д╟е·┴░едеєд╖д╞дддБEБEчд╦╩╘╜╕▓─╟╜д╚д╩дъд▐д╣бг
# </p>
# <pre>
# if($wiki-&gt;can_modify_page(е┌б╝е╕╠╛)){
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
# ╗▓╛╚╕в╕┬д╦┤╪д╣дБEсе╜е├е╔╖▓
#
###############################################################################
#==============================================================================
# <p>
# е┌б╝е╕д╬╗▓╛╚еБE┘еБEЄ└▀─ъд╖д▐д╣бг
# <p>
# <ul>
#   <li>0 - ┴┤░ўд╦╕°│л</li>
#   <li>1 - ецб╝е╢д╦╕°│л</li>
#   <li>2 - ┤╔═¤╝╘д╦╕°│л</li>
# </ul>
# <pre>
# $wiki-&gt;set_page_level(е┌б╝е╕╠╛,╕°│леБE┘еБE;
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
# е┌б╝е╕д╬╗▓╛╚еБE┘еБEЄ╝ш╞└д╖д▐д╣бг
# е┌б╝е╕╠╛дм╗╪─ъд╡дБE╞ддд╩дд╛БEчбв┴┤д╞д╬е┌б╝е╕д╬╗▓╛╚еБE┘еБE
# е╧е├е╖ехеБE╒ебеБEєе╣д╟╩╓д╖д▐д╣бг
# </p>
# <ul>
#   <li>0 - ┴┤░ўд╦╕°│л</li>
#   <li>1 - ецб╝е╢д╦╕°│л</li>
#   <li>2 - ┤╔═¤╝╘д╦╕°│л</li>
# </ul>
# <pre>
# my $level = $get_page_level(е┌б╝е╕╠╛);
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
# е┌б╝е╕дм╗▓╛╚▓─╟╜длд╔дждлдЄ╝ш╞└д╖д▐д╣бг
# </p>
# <pre>
# if($wiki-&gt;can_show(е┌б╝е╕╠╛)){
#   # ╗▓╛╚▓─╟╜
# } else {
#   # ╗▓╛╚╔╘▓─╟╜
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
# д╜д╬┬╛д╬есе╜е├е╔╖▓
#
###############################################################################
#==============================================================================
# <p>
# е┌б╝е╕д╦е╕еуеєе╫д╣дБE┐дсд╬URLдЄ└╕└од╣дБEцб╝е╞егеБE╞егесе╜е├е╔д╟д╣бг
# ░·┐Їд╚д╖д╞е┌б╝е╕╠╛дЄ┼╧д╖д▐д╣бг
# </p>
# <pre>
# $wiki-&gt;create_page_url(&quot;FrontPage&quot;);
# </pre>
# <p>
# ╛х╡нд╬е│б╝е╔д╧─╠╛БEв░╩▓╝д╬URLдЄ└╕└од╖д▐д╣бг
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
# ╟д░╒д╬URLдЄ└╕└од╣дБE┐дсд╬ецб╝е╞егеБE╞егесе╜е├е╔д╟д╣бг
# ░·┐Їд╚д╖д╞е╤ещесб╝е┐д╬е╧е├е╖ехеБE╒ебеБEєе╣дЄ┼╧д╖д▐д╣бг
# </p>
# <pre>
# $wiki-&gt;create_url({action=>HOGE,type=>1});
# </pre>
# <p>
# ╛х╡нд╬е│б╝е╔д╧─╠╛БEв░╩▓╝д╬URLдЄ└╕└од╖д▐д╣бг
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
# евепе╖ечеєе╧еєе╔ещ├цд╟е┐еде╚еБEЄ└▀─ъд╣дБEБEчд╦╗╚═╤д╖д▐д╣бг
# </p>
# <pre>
# $wiki-&gt;set_title(е┐еде╚еБE,╩╘╜╕╖╧д╬е┌б╝е╕дмд╔дждл]);
# </pre>
# <p>
# ╩╘╜╕╖╧д╬▓ш╠╠д╬╛БEчбв┬ш╞є░·┐Їд╦1дЄ╗╪─ъд╖д╞дпд└д╡ддбг
# е·┴▄е├е╚┬╨║Ў═╤д╦░╩▓╝д╬METAе┐е░дм╜╨╬╧д╡дБE▐д╣бг
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
# е┐еде╚еБEЄ╝ш╞└д╖д▐д╣бг
# </p>
#==============================================================================
sub get_title {
	my $self = shift;
	return $self->{"title"};
}

#==============================================================================
# <p>
# е┌б╝е╕д╬░БEўдЄ╝ш╞└д╖д▐д╣бг
# ░·┐Їд╚д╖д╞е╧е├е╖ехеБE╒ебеБEєе╣дЄ┼╧д╣д│д╚д╟╝ш╞└╞т═╞дЄ╗╪─ъд╣дБE│д╚дм▓─╟╜бг
# е╟е╒ейеБE╚д╟д╧┴┤д╞д╬е┌б╝е╕дЄ╠╛┴░д╟е╜б╝е╚д╖д┐еБE╣е╚дЄ╩╓╡╤д╣дБEг
# </p>
# <p>
# ░╩▓╝д╬╬уд╧╗▓╛╚╕вд╬двдБE┌б╝е╕д╬д▀╝ш╞└д╖бв╣╣┐╖╞БE■д╟е╜б╝е╚д╣дБEг
# </p>
# <pre>
# my @list = $wiki-&gt;get_page_list({-sort   => 'last_modified',
#                                  -permit => 'show'});
# </pre>
# <p>
# ░╩▓╝д╬╬уд╧┴┤д╞д╬е┌б╝е╕дЄ╝ш╞└д╖бв╠╛┴░д╟е╜б╝е╚д╣дБEг
# </p>
# <pre>
# my @list = $wiki-&gt;get_page_list({-sort => 'name'});
# </pre>
# <p>
# ░╩▓╝д╬╬уд╧║╟┐╖д╬10╖БEЄ╝ш╞└д╣дБEг
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
# е┌б╝е╕д╬╩к═¤┼кд╩б╩е╟б╝е┐е╒ебедеБE╬╣╣┐╖╞БE■б╦║╟╜к╣╣┐╖╗■╣БEЄ╝ш╞└д╖д▐д╣бг
# </p>
# <pre>
# my $modified = $wiki-&gt;get_last_modified(е┌б╝е╕╠╛);
# </pre>
#==============================================================================
sub get_last_modified {
	my $self = shift;
	return $self->{"storage"}->get_last_modified(@_);
}

#==============================================================================
# <p>
# е┌б╝е╕╧└═¤┼кд╩║╟╜к╣╣┐╖╗■╣БEЄ╝ш╞└д╖д▐д╣бг
# б╓е┐едере╣е┐еєе╫дЄ╣╣┐╖д╖д╩ддб╫д╦е┴езе├епдЄ╞■дБE╞е┌б╝е╕дЄ╩▌┬╕д╖д┐╛БEчд╧
# д│д╬есе╜е├е╔д╟╩╓д╡дБEБEБE■д╧╩▌┬╕┴░д╬дтд╬д╦д╩дъд▐д╣бг
# </p>
# <pre>
# my $modified = $wiki-&gt;get_last_modified2(е┌б╝е╕╠╛);
# </pre>
#==============================================================================
sub get_last_modified2 {
	my $self = shift;
	return $self->{"storage"}->get_last_modified2(@_);
}

#==============================================================================
# <p>
# е┌б╝е╕д╬е╜б╝е╣дЄ╝ш╞└д╖д▐д╣бг
# </p>
# <p>
# ┬ш╗░░·┐Їд╦е╒ейб╝е▐е├е╚╠╛дЄ┼╧д╖д┐╛БEчд╬д▀бве╒ейб╝е▐е├е╚е╫еще░едеєд╦дшд
# е╜б╝е╣д╬╩╤┤╣дЄ╣╘ддд▐д╣бгд╜дБE╩│░д╬╛БEчд╧╔м═╫д╦▒■д╕д╞е╫еще░едеє┬жд╟
# Wiki::convert_from_fswikiесе╜е├е╔дЄ╕╞дєд╟╩╤┤╣дЄ╣╘ддд▐д╣бг
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
# е╨е├епеве├е╫д╡дБE┐е╜б╝е╣дЄ╝ш╞└д╖д▐д╣бге╨е├епеве├е╫дм┬╕║▀д╖д╩дд╛БEчд╧╢ї╩╕╗·╬єдЄ╩╓д╖д▐д╣бг
# └д┬хе╨е├епеве├е╫д╦┬╨▒■д╖д┐е╣е╚еБE╝е╕дЄ╗╚═╤д╖д╞дддБEБEчд╧┬ш╞є░·┐Їд╦╝ш╞└д╣дБEд┬хдЄ╗╪─ъд╣дБE│д╚дмд╟днд▐д╣бг
# </p>
# <pre>
# # └д┬хе╨е├епеве├е╫дЄ╗╚═╤д╖д╞ддд╩дд╛БE
# my $backup = $wiki-&gt;get_backup(е┌б╝е╕╠╛);
#
# # └д┬хе╨е├епеве├е╫дЄ╗╚═╤д╖д╞дддБEБE
# my $backup = $wiki-&gt;get_backup(е┌б╝е╕╠╛,└д┬БE;
# </pre>
# <p>
# └д┬хд╧╕┼дддтд╬длдщ╜чд╦0б┴д╬┐Ї├═д╟╗╪─ъд╖д▐д╣бг
# </p>
#==============================================================================
sub get_backup {
	my $self = shift;
	return $self->{"storage"}->get_backup(@_);
}

#==============================================================================
# <p>
# е┌б╝е╕дЄ╩▌┬╕д╖д▐д╣бг
# енеуе├е╖ехетб╝е╔ONд╟═°═╤д╖д╞дддБEБEчбве┌б╝е╕д╬енеуе├е╖ехдт║БEБE╡дБE▐д╣бг
# </p>
# <pre>
# $wiki-&gt;save_page(е┌б╝е╕╠╛,е┌б╝е╕╞т═╞);
# </pre>
# <p>
# е╒ейб╝е▐е├е╚е╫еще░едеєд╦дшдБE╒ейб╝е▐е├е╚д╬╩╤┤╣д╧╣╘дБEБE▐д╗дєбг
# д─д▐дъбве╒ейб╝е▐е├е╚е╫еще░едеєдЄ╗╚═╤д╖д╞дддБEБEчбвд│д╬есе╜е├е╔д╦┼╧д╣
# Wikiе╜б╝е╣д╧╗Ў┴░д╦FSWiki╖┴╝░д╦╩╤┤╣д╡дБE┐е╜б╝е╣д╟д╩д▒дБE╨д╩дъд▐д╗дєбг
# </p>
# <p>
# ╩▌┬╕╗■д╦е┐едере╣е┐еєе╫дЄ╣╣┐╖д╖д╩дд╛БEчбв┬ш╗░░·┐Їд╦1дЄ┼╧д╖д▐д╣бг
# </p>
# <pre>
# $wiki-&gt;save_page(е┌б╝е╕╠╛,е┌б╝е╕╞т═╞,1);
# </pre>
#
#==============================================================================
sub save_page {
	my $self     = shift;
	my $pagename = shift;
	my $content  = shift;
	my $sage     = shift;
	
	# е┌б╝е╕╠╛дЄе┴езе├еп
	if($pagename =~ /([\|\[\]])|^:|([^:]:[^:])/){
		die "е┌б╝е╕╠╛д╦╗╚═╤д╟днд╩дд╩╕╗·дм┤▐д▐дБE╞ддд▐д╣бг";
	}
	# ддд├д┐дєе╤ещесб╝е┐дЄ╛х╜ёдн
	$self->get_CGI->param("page"   ,$pagename);
	$self->get_CGI->param("content",$content);
	$self->do_hook("save_before");
	# е╤ещесб╝е┐дЄ╞╔д▀╣■д▀─╛д╣
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
# е┌б╝е╕дм┬╕║▀д╣дБEлд╔дждл─┤д┘д▐д╣бг
# </p>
# <pre>
# if($wiki-&gt;page_exists(е┌б╝е╕╠╛)){
#   # е┌б╝е╕дм┬╕║▀д╣дБEБEчд╬╜ш═¤
# } else {
#   # е┌б╝е╕дм┬╕║▀д╖д╩дд╛БEчд╬╜ш═¤
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
	
	# InterWiki╖┴╝░д╬╗╪─ъд╟е╔е├е╚дЄ┤▐дрд│д╚д╧д╟днд╩дд
	if(defined($path) && index($path,".")!=-1){
		return 0;
	}
	
	return $self->{"storage"}->page_exists($page,$path);
}

#===============================================================================
# <p>
# CGIеке╓е╕езепе╚дЄ╝ш╞└
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
# ░·┐Їд╟┼╧д╖д┐е┌б╝е╕д╦еБE└едеБEпе╚д╖д▐д╣бг
# е┌б╝е╕д╬╩▌┬╕╕хд╦е┌б╝е╕дЄ║╞╔╜╝ид╣дБEБEчд╧д│д╬есе╜е├е╔дЄ╗╚═╤д╖д╞▓╝д╡ддбг
# д╩дкбвд│д╬есе╜е├е╔дЄ╕╞д╙╜╨д╣д╚д╜д│д╟е╣епеБE╫е╚д╬╝┬╣╘д╧╜к╬╗д╖бв╕╞д╙╜╨д╖╕╡д╦└й╕цд╧╠сдъд▐д╗дєбг
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
# ╗╪─ъд╬URLд╦еБE└едеБEпе╚д╖д▐д╣бг
# д│д╬есе╜е├е╔дЄ╕╞д╙╜╨д╣д╚д╜д│д╟е╣епеБE╫е╚д╬╝┬╣╘д╧╜к╬╗д╖бв╕╞д╙╜╨д╖╕╡д╦└й╕цд╧╠сдъд▐д╗дєбг
# </p>
# <pre>
# $wiki-&gt;redirectURL(еБE└едеБEпе╚д╣дБERL);
# </pre>
#==============================================================================
sub redirectURL {
	my $self = shift;
	my $url  = shift;
	
	# Locationе┐е░д╟еБE└едеБEпе╚
	if($self->config('redirect')==1){
		my ($hoge,$param) = split(/\?/,$url);
		$url = $self->get_CGI->url().$self->get_CGI()->path_info();
		if($param ne ''){
			$url = "$url?$param";
		}
		print "Location: $url\n\n";
		
	# METAе┐е░д╟еБE└едеБEпе╚
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
# е░е·╜╝е╨еБE▀─ъдЄ╝ш╞└дтд╖дпд╧╩╤╣╣д╖д▐д╣
# </p>
# <pre>
# # е╟б╝е┐е╒ебедеБEЄ│╩╟╝д╣дБE╟егеБEпе╚е
# my $data_dir = $wiki-&gt;config('data_dir');
#
# # └▀─ъдБEdata_dirд╟╛х╜ёдн
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
# Farm┤╪╖╕д╬есе╜е├е╔╖▓
#
###############################################################################
#==============================================================================
# <p>
# Farm╡б╟╜дм═н╕·д╦д╩д├д╞дддБEлд╔дждлдЄ╝ш╞└д╖д▐д╣
# </p>
# <pre>
# if($wiki-&gt;farm_is_enable()){
#   # Farmдм═н╕·д╦д╩д├д╞дддБE╚днд╬╜ш═¤
# } else {
#   # Farmдм╠╡╕·д╦д╩д├д╞дддБE╚днд╬╜ш═¤
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
# ╗╥WikiдЄ║√▄од╖д▐д╣бг░·┐Їд╦д╧Wikiд╬╠╛┴░бв║√▄од╣дБEikiе╡еде╚д╬┤╔═¤╝╘IDбве╤е╣еБE╝е╔дЄ┼╧д╖д▐д╣бг
# д│д╬есе╜е├е╔╞тд╟д╧Wikiе╡еде╚╠╛д╬е╨еБE╟б╝е╖ечеєдф╜┼╩ге┴езе├епд╧╣╘дБEБE▐д╗дєбг
# ╗Ў┴░д╦╣╘дж╔м═╫дмдвдъд▐д╣бгд│д╬есе╜е├е╔д╧farmе╫еще░едеєдЄ╗╚═╤д╖д╞дддБEБEчд╬д▀╗╚═╤▓─╟╜д╟д╣бг
# </p>
# <pre>
# $wiki-&gt;create_wiki(Wikiе╡еде╚╠╛,┤╔═¤╝╘ID,е╤е╣еБE╝е╔);
# </pre>
#==============================================================================
sub create_wiki{
	my $self  = shift;
	my $child = shift;
	my $id    = shift;
	my $pass  = shift;
	
	# dataбвbackupе╟егеБEпе╚еъдЄ╖бдБEш═¤д╧Storageд╦╟дд╗д┐д█дждмдддддлд╩бй
	unless($self->wiki_exists($child)){
		eval {
			# е│евд╟е╡е▌б╝е╚д╣дБE╟егеБEпе╚еъдЄ╖бд
			mkpath($self->config('data_dir'  )."/$child") or die $!;
			mkpath($self->config('backup_dir')."/$child") or die $!;
			mkpath($self->config('config_dir')."/$child") or die $!;
			mkpath($self->config('log_dir'   )."/$child") or die $!;
			
			# └▀─ъд╬е│е╘б╝
			copy($self->config('config_dir')."/".$self->config('config_file'),
			     $self->config('config_dir')."/$child/".$self->config('config_file')) or die $!;
			copy($self->config('config_dir')."/".$self->config('usercss_file'),
			     $self->config('config_dir')."/$child/".$self->config('usercss_file')) or die $!;
			copy($self->config('config_dir')."/".$self->config('plugin_file'),
			     $self->config('config_dir')."/$child/".$self->config('plugin_file')) or die $!;
			copy($self->config('config_dir')."/".$self->config('mime_file'),
			     $self->config('config_dir')."/$child/".$self->config('mime_file')) or die $!;
			
			# ┤╔═¤ецб╝е╢д╬║√▄об╩д│д│д╟║√└БE╬д╧д┴дчд├д╚евеБEлдтбжбжбжб╦
			open(USERDAT,">".$self->config('config_dir')."/$child/".$self->config('userdat_file')) or die $!;
			print USERDAT "$id=".&Util::md5($pass,$id)."\t0\n";
			close(USERDAT);
			
			# е╞еєе╫еБE╝е╚длдще┌б╝е╕д╬е│е╘б╝
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
			# create_wikiе╒е├епд╬╕╞д╙╜╨д╖
			$self->do_hook("create_wiki");
		};
		
		# еиещб╝дм╚п└╕д╖д┐╛БEчепеъб╝еєеве├е╫╜ш═¤
		if($@){
			my $error = $@;
			# д│д│д╧еиещб╝дм╜╨д╞дт┬│╣╘
			eval {
				$self->remove_wiki("/$child");
			};
			die "$childд╬║√▄од╦╝║╟╘д╖д▐д╖д┐бг╚п└╕д╖д┐еиещб╝д╧░╩▓╝д╬д╚дкдъд╟д╣бг\n\n$error";
		}
	}
}

#==============================================================================
# <p>
# ╕╜║▀д╬Wikiд╬│м┴╪дЄ╩╓╡╤д╖д▐д╣бгеБE╝е╚д╬╛БEчд╧0бв╗╥Wikiд╬╛БEчд╧1бв
# ┬╣Wikiд╬╛БEчд╧2б─д╚дддждшджд╦д╩дъд▐д╣бг
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
# ╗╥WikiдЄ║БEБE╖д▐д╣бг░·┐Їд╦д╧║БEБE╣дБEikiе╡еде╚д╬е╤е╣б╩PATH_INFO╔Ї╩мб╦дЄ┼╧д╖д▐д╣бг
# д│д╬есе╜е├е╔д╧farmе╫еще░едеєдЄ╗╚═╤д╖д╞дддБEБEчд╬д▀╗╚═╤▓─╟╜д╟д╣бг
# </p>
# <pre>
# $wiki-&gt;remove_wiki(Wikiе╡еде╚д╬е╤е╣);
# </pre>
#==============================================================================
sub remove_wiki {
	my $self = shift;
	my $path = shift;
	
	# е│евд╟е╡е▌б╝е╚д╣дБE╟егеБEпе╚еъдЄ║БE
	rmtree($self->config('data_dir'  ).$path) or die $!;
	rmtree($self->config('backup_dir').$path) or die $!;
	rmtree($self->config('config_dir').$path) or die $!;
	rmtree($self->config('log_dir'   ).$path) or die $!;
	
	# remove_wikiе╒е├епд╬╕╞д╙╜╨д╖
	$self->get_CGI()->param('path',$path);
	$self->do_hook("remove_wiki");
}

#==============================================================================
# <p>
# ░·┐Їд╟┼╧д╖д┐╠╛╛╬д╬╗╥Wikiдм┬╕║▀д╣дБEлд╔дждлдЄ─┤д┘д▐д╣бг
# д│д╬есе╜е├е╔д╧farmе╫еще░едеєдЄ╗╚═╤д╖д╞дддБEБEчд╬д▀╗╚═╤▓─╟╜д╟д╣бг
# </p>
# <pre>
# $wiki-&gt;wiki_exists(Wikiе╡еде╚╠╛);
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
# ╗╥WikiдЄ╟█╬єд╟╝ш╞└д╖д▐д╣бг┬╣Wikiбв┴╜┬╣Wikiд╧╟█╬єд╬еБE╒ебеБEєе╣д╚д╖д╞│╩╟╝д╡дБE╞ддд▐д╣бг
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
# ╗╥Wikiд╬е─еъб╝дЄ╟█╬єд╟╝ш╞└д╖д▐д╣бг
# е═е╣е╚д╖д┐Wikiд╧╟█╬єеБE╒ебеБEєе╣д╟│╩╟╝д╖д▐д╣бг
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
# ╜к╬╗┴░д╬╜ш═¤бг
# </p>
#==============================================================================
sub _process_before_exit {
	my $self = shift;
	# е╫еще░едеє═╤д╬е╒е├еп
	$self->do_hook('finalize');
	# finalizeесе╜е├е╔д╬╕╞д╙╜╨д╖
	$self->get_CGI()->finalize();
	$self->{storage}->finalize();
}

1;
