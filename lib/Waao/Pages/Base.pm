package Waao::Pages::Base;

#use strict;
use DBI;
use CGI;
#use HTTP::MobileAgent;
use Cache::Memcached;
use Waao::Session;

sub new(){
	my $class = shift;
	my $q = new CGI;

	my $self={
			'session' => Waao::Session->new($q->param('session')),
			'mem' => &_mem_connect(),
			'dbi' => &_db_connect(),
			'cgi' => $q
#			'agent' => HTTP::MobileAgent->new("$ENV{'HTTP_USER_AGENT'}")
			};

	my $errsite;
	$errsite = 1 if($ENV{'SCRIPT_URI'} eq 'http://now.goo.to/13/13733/');
	$errsite = 1 if($ENV{'SCRIPT_URI'} eq 'http://now.goo.to/13/13733/395432qa.html');
	$errsite = 1 if($ENV{'SCRIPT_URI'} eq 'http://waao.jp/%94%FC%94g/qanda/');
	$errsite = 1 if($ENV{'SCRIPT_URI'} eq 'http://waao.jp/%94%FC%94g/qanda/395432/');
	$errsite = 1 if($ENV{'SCRIPT_URI'} eq 'http://waao.jp/qandalist13733/');
	$errsite = 1 if($ENV{'SCRIPT_URI'} eq 'http://waao.jp/qanda395432/');
	if($errsite){
		print "Status: 404 Not Found\n\n";
		exit;
		return bless $self, $class;
	}



	# mobielアクセス
	$self =&_mobile_access_check($self);

	if($self->{access_type} eq 4){
		if($ENV{'SERVER_NAME'} ne 'smax.tv'){
			print qq{Location: http://smax.tv/\n\n};
		}
	}

	# robot対策
	$self = &_robot_setup($self);
	# date情報ゲット
	$self = &_set_date($self);

	# NG word check
	&_ng_word_check($self);

	# PC ページ表示
	unless( $self->{mobile_access} ){
		unless($self->{crawler}){
			&_pc_page($self);
		}
	}
	
	# 特権
	$self = &_set_my_device($self);

	# セッション情報取得
	my $session_data = $self->{mem}->get( $self->{session}->{_session_id} );
	$self->{session}->{_data} = $session_data if($session_data);

	
	return bless $self, $class;
}

# memcached connect
sub _mem_connect(){

	my $memd = new Cache::Memcached {
    'servers' => [ "localhost:11211" ],
    'debug' => 0,
    'compress_threshold' => 1_000,
	};

	return $memd;
}

# db connect
sub _db_connect(){
    my $dsn = 'DBI:mysql:waao';
    my $user = 'mysqlweb';
    my $password = 'WaAoqzxe7h6yyHz';

    my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 0, AutoCommit => 1, PrintError => 0});
	
	return $dbh;
}

# access_check
# sid 取得
sub _mobile_access_check(){
	my $self = shift;

    if( $ENV{'REMOTE_HOST'} =~/docomo/i ){
    	$self->{mobile_access} =1;
    	$self->{access_type} =1;
    	$self->{real_mobile} =1;
    }elsif( $ENV{'REMOTE_HOST'} =~/ezweb/i ){
    	$self->{mobile_access} =1;
    	$self->{access_type} =2;
    	$self->{real_mobile} =1;
    }elsif( $ENV{'REMOTE_HOST'} =~/^J-PHONE|^Vodafone|^SoftBank/i ){
    	$self->{mobile_access} =1;
    	$self->{access_type} =3;
    	$self->{real_mobile} =1;
    }elsif( $ENV{'REMOTE_HOST'} =~/panda-world\.ne\.jp/i ){
    	$self->{mobile_access} =1;
    	$self->{access_type} =4;
    	$self->{real_mobile} =1;
	}elsif( $ENV{'HTTP_USER_AGENT'} =~/iPhone|iPod|Android|dream|CUPCAKE|blackberry|webOS|incognito|webmate/i ){
    	$self->{mobile_access} =1;
    	$self->{access_type} =4;
    	$self->{real_mobile} =1;
	}elsif( $ENV{'HTTP_USER_AGENT'} =~/Google-Site/i ){
    	$self->{mobile_access} =1;
	}elsif( $ENV{'HTTP_USER_AGENT'} =~/www\.valuecommerce\.ne\.jp/i ){
    	$self->{mobile_access} =1;
    }elsif( $ENV{'REMOTE_HOST'} =~/hinocatv/i ){
#    	$self->{mobile_access} =1;
#    	$self->{access_type} =9;
    }
	return $self;
}

sub _robot_setup(){
	my $self = shift;

	# google
	if( $ENV{'HTTP_USER_AGENT'} =~/Googlebot-Mobile|Google-Sitemaps/i ){
		$self->{crawler} = "google";
#	}elsif($ENV{'REMOTE_ADDR'} =~/74\.125\.16|74\.125\.75|72\.14\.199|209\.85\.238/i){
#		$self->{crawler} = "google";
	# yahoo
#	}elsif($ENV{'REMOTE_ADDR'} =~/124\.83\.159/i){
#		$self->{crawler} = "yahoo";
	}elsif( $ENV{'HTTP_USER_AGENT'} =~/Y!J-SRD|Y!J-MBS/i ){
		$self->{crawler} = "yahoo";
	# goo
#	}elsif($ENV{'REMOTE_ADDR'} =~/210\.150\.10|203\.131\.250/i){
#		$self->{crawler} = "goo";
	}elsif( $ENV{'HTTP_USER_AGENT'} =~/mobile goo/i ){
		$self->{crawler} = "goo";
	# livedoor
#	}elsif($ENV{'REMOTE_ADDR'} =~/203\.104\.254/i){
#		$self->{crawler} = "livedoor";
	}elsif( $ENV{'HTTP_USER_AGENT'} =~/LD_mobile_bot/i ){
		$self->{crawler} = "livedoor";
	# dena
#	}elsif($ENV{'REMOTE_ADDR'} =~/202\.238\.103\.126|202\.213\.221\.97/i){
#		$self->{crawler} = "dena";
	}elsif( $ENV{'HTTP_USER_AGENT'} =~/moba-crawler/i ){
		$self->{crawler} = "dena";
	# froute
#	}elsif($ENV{'REMOTE_ADDR'} =~/60\.43\.36\.253/i){
#		$self->{crawler} = "froute";
	}elsif( $ENV{'HTTP_USER_AGENT'} =~/froute\.jp/i ){
		$self->{crawler} = "froute";
	# yicha
	}elsif($ENV{'REMOTE_ADDR'} =~/220\.194\.55|219\.142\.177\.97/i){
		$self->{crawler} = "yicha";
	# baidu
#	}elsif($ENV{'REMOTE_ADDR'} =~/119\.63\.195/i){
#		$self->{crawler} = "google";
	}elsif( $ENV{'HTTP_USER_AGENT'} =~/BaiduMobaider/i ){
		$self->{crawler} = "baidu";
	}
	# bing

	if($self->{crawler}){
		$self->{session}->{_session_id} = 'robot';
		$self->{mobile_access} = 1;
	}

	return $self;
}

sub _set_date(){
	my $self = shift;

	my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
	$year = $year + 1900;
	$mon = $mon + 1;
	$self->{date_yyyy_mm_dd} = sprintf("%d-%02d-%02d",$year,$mon,$mday);
	$self->{date_yyyymmdd} = sprintf("%d%02d%02d",$year,$mon,$mday);
	$self->{date_y} = sprintf("%d",$year);
	$self->{date_m} = sprintf("%d",$mon);
	$self->{date_d} = sprintf("%d",$mday);
	$self->{date_hour} = sprintf("%d",$hour);
	$self->{date_min} = sprintf("%d",$min);
	$self->{date_sec} = sprintf("%d",$sec);

	return $self;
}

sub _ng_word_check(){
	my $self = shift;

	return unless($self->{cgi}->param('q'));
	my $ng_word_check;
	my $sth = $self->{dbi}->prepare(qq{select * from ng_word where keyword like "}.$self->{cgi}->param('q').qq{%"});
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$ng_word_check = 1;
	}
	if($ng_word_check){
		use Waao::Ngword;
		&ng_word_dsp($self);
		exit; # 強制終了
	}
	return;
}

sub _pc_page(){
	my $self = shift;

# PC でも閲覧可能なもの
	return if( $ENV{'SCRIPT_NAME'} eq '/pv.html' );
	return if( $ENV{'SCRIPT_NAME'} eq '/blog.html' );
	return if( $ENV{'SCRIPT_NAME'} eq '/sp.html' );
	return if( $ENV{'REQUEST_URI'} eq '/pc.html' );
	return if( $ENV{'SCRIPT_NAME'} eq '/pctest.html' );
	return if( $ENV{'SCRIPT_NAME'} eq '/pc.html' );
	return if( $ENV{'HTTP_HOST'} eq 'wiki.waao.jp' );
	return if( $ENV{'HTTP_HOST'} eq 'smax.tv' );
	return if( $ENV{'HTTP_HOST'} eq 'smax.webk-vps.com' );
	return if( $ENV{'SCRIPT_URI'} =~/\/id(.*)/ );
	return if( $ENV{'SCRIPT_URI'} =~/\/photoid(.*)/ );
	return if( $ENV{'SCRIPT_URI'} =~/\/wiki(.*)/ );
	return if( $ENV{'SCRIPT_URI'} =~/\/uwasa(.*)/ );
	return if( $ENV{'SCRIPT_URI'} =~/\/bbslist(.*)/ );
	return if( $ENV{'SCRIPT_URI'} =~/\/bbsid(.*)/ );
	return if( $ENV{'SCRIPT_URI'} =~/\/qanda(.*)/ );
	return if( $ENV{'SCRIPT_URI'} =~/\/person(.*)/ );
	

	return if( ($ENV{'SCRIPT_NAME'} eq '/f1.html') && ($self->{cgi}->param('q') eq 'list-newsdetail') );
	return if( ($ENV{'SCRIPT_NAME'} eq '/motogp.html') && ($self->{cgi}->param('q') eq 'list-newsdetail') );
    if( $ENV{'REMOTE_HOST'} =~/ftth\.ucom\.ne\.jp/i ){
    	return if( $ENV{'HTTP_USER_AGENT'} =~/DoCoMo/i);
	}

	use Waao::Pc;
	&pc_page($self);
	&_access_check($self);
	exit; # 強制終了
}

sub _set_my_device(){
	my $self = shift;
	
    if( $ENV{'REMOTE_HOST'} =~/hinocatv/i ){
    	$self->{my_device} = 1;
    }elsif( $ENV{'HTTP_X_UP_SUBNO'} eq '05001014065133_af.ezweb.ne.jp' ){
    	$self->{my_device} = 1;
    }

	return $self;
}

####################################################################################
####################################################################################
####################################################################################

sub DESTROY{
	my $self = shift;

	# keywordデータが存在したい場合の処理
	&_no_keyword($self) if($self->{no_keyword});
	
	# 3キャリア＋hinocatvのみ
	if($self->{access_type}){
		# keyword分析
		&_ins_keyword($self);
	}
	# アクセス解析
	&_access_check($self);
	
	# セッション情報登録
	$self->{mem}->delete( $self->{session}->{_session_id} );
	$self->{mem}->set( $self->{session}->{_session_id}, $self->{session}->{_data}, 3600 ) if( $self->{session}->{_data} );
	
	$self->{db}->disconnect if($self->{db});

	return;
}

sub _no_keyword(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('q');

	use Waao::Html;

	$self->{html_title} = qq{$keywordの検索結果 -みんなの検索プラス-};
	$self->{html_keywords} = qq{$keyword,検索,データ,情報};
	$self->{html_description} = qq{$keywordのことが楽〜に探せるみんなの検索プラス！};

	my $hr = &html_hr($self,1);	

	&html_header($self);
	use Waao::Ad;
	my $yicha_url = &get_yicha_url($self,$keyword);
if($self->{xhtml}){

print << "END_OF_HTML";
END_OF_HTML

}else{

print << "END_OF_HTML";
<center>
<h1>$keyword</h1><br>
</center>
$hr
<br>
<center>
<a href="$yicha_url">$keywordの検索結果</a>
</center>
<br>
$hr
<a href="/" accesskey=0>トップ</a>&gt;<strong>$keyword</strong><br>
<font size=1 color="#E9E9E9">
この㌻は、「$keywordの」の検索結果㌻です。<br>
$keywordの情報収集にご協力をお願いします。
</font>
END_OF_HTML

}
	&html_footer($self);

	return;
}

sub _ins_keyword(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('q');
	return unless($keyword);
	return if($keyword =~/^list-/);
	
	# 複合キーワードはカウントしない
	if($keyword =~/\s/){
		&_keyword_many($self);
	}
	if($keyword =~/ /){
		&_keyword_many($self);
	}
	return if($keyword =~/\s/);
	return if($keyword =~/ /);
	
	# メインテーブルへの移行カウント
	my $tmp_max_cnt = 5;

	my $keyword_id;
	# keyword メインテーブル
	my $sth = $self->{dbi}->prepare(qq{ select id from keyword where keyword = ? } );
	$sth->execute($keyword);
	while(my @row = $sth->fetchrow_array) {
		$keyword_id = $row[0];
	}
	if($keyword_id){
		my $sth = $self->{dbi}->prepare(qq{ update keyword set cnt = cnt + 1 where id = ? limit 1} );
		$sth->execute($keyword_id);
		# アクセス解析用の処理を実施
		my $key_rank_table;
		my $mon = $self->{date_m};
		if($mon % 2){
			$key_rank_table = qq{keyword_rank1};
		}else{
			$key_rank_table = qq{keyword_rank2};
		}
		my $key_rank_id;
		my $sth = $self->{dbi}->prepare(qq{ select keyword_id from $key_rank_table where keyword_id = ? } );
		$sth->execute($keyword_id);
		while(my @row = $sth->fetchrow_array) {
			$key_rank_id = $row[0];
		}
		if($key_rank_id){
			my $sth = $self->{dbi}->prepare(qq{ update $key_rank_table set cnt = cnt + 1 where keyword_id = ? limit 1} );
			$sth->execute($keyword_id);
		}else{
			my $sth = $self->{dbi}->prepare(qq{ insert into $key_rank_table (`keyword_id`,`cnt`) values (?,?)} );
			$sth->execute($keyword_id,1);
		}
		
	}else{
		# keyword_tmp
		my $keyword_tmp_cnt;
		my $sth = $self->{dbi}->prepare(qq{ select cnt from keyword_tmp where keyword = ? } );
		$sth->execute($keyword);
		while(my @row = $sth->fetchrow_array) {
			$keyword_tmp_cnt = $row[0];
		}
		if($keyword_tmp_cnt >= $tmp_max_cnt){
			use Waao::Data;
			my ($datacnt, $wikipedia) = &get_wiki($self, $keyword);
			my $rev_id;
			$rev_id = $wikipedia->{rev_id} if($wikipedia);
			my $sth = $self->{dbi}->prepare(qq{ insert into keyword (`keyword`,`cnt`,`wiki_id`) values (?,?,?)} );
			$sth->execute($keyword,1,$rev_id);
			$sth = $self->{dbi}->prepare(qq{ delete from keyword_tmp where keyword = ? limit 1} );
			$sth->execute($keyword);
		}elsif($keyword_tmp_cnt){
			my $sth = $self->{dbi}->prepare(qq{ update keyword_tmp set cnt = cnt + 1 where keyword = ? limit 1} );
			$sth->execute($keyword);
		}elsif(!$keyword_tmp_cnt){
			my $sth = $self->{dbi}->prepare(qq{ insert into keyword_tmp (`keyword`,`cnt`) values (?,?)} );
			$sth->execute($keyword,1);
		}
	}
	
	return;
}

sub _access_check(){
	my $self = shift;

	# PVチェック
	&_pv($self);

	# ユニークPV
	if($self->{real_mobile}){
		&_uniq_pv($self);
		&_robots_search($self);
		&_pv_detail($self);
	}
	# アクセスカウント
	$self->{session}->{_data}->{acnt} = $self->{session}->{_data}->{acnt} + 1;
	# ページカウント設定
	&_get_pagecnt($self);

	return;
}

sub _pv(){
	my $self = shift;

	my $sqlstr;

	# 総合PV
	$sqlstr .= qq{ pv = pv + 1 };

	if($self->{real_mobile}){
		# 3キャリア
		$sqlstr .= qq{, pv_mo = pv_mo + 1 };
		if($self->{access_type} eq 1){
			$sqlstr .= qq{, pv_i = pv_i + 1 };
		}elsif($self->{access_type} eq 2){
			$sqlstr .= qq{, pv_ez = pv_ez + 1 };
		}elsif($self->{access_type} eq 3){
			$sqlstr .= qq{, pv_sb = pv_sb + 1 };
		}
	}elsif($self->{crawler}){
		# クローラ
		$sqlstr .= qq{, pv_robot = pv_robot + 1 };
	}else{
		# PC
		$sqlstr .= qq{, pv_pc = pv_pc + 1 };
	}
	my $pv_date = $self->{mem}->get( 'pv_date' );

	if($pv_date ne $self->{date_yyyy_mm_dd}){

eval{
		my $sth = $self->{dbi}->prepare( qq{insert into pv ( `id` ) values (?)}	);
		$sth->execute($self->{date_yyyy_mm_dd});
};
		$self->{mem}->set( 'pv_date', $self->{date_yyyy_mm_dd} );
	}


eval{
	my $sth = $self->{dbi}->prepare( qq{update pv set $sqlstr where id = ? limit 1 } );
	my $ret = $sth->execute($self->{date_yyyy_mm_dd});
};
if($@){
}

	return;
}

sub _uniq_pv(){
	my $self = shift;

	# dailyユニーク
	# マンスリーユニーク
	my $mon = $self->{date_m};
eval{
	if($mon % 2){
	    $sth = $self->{dbi}->prepare(qq{insert into muu1 ( `uid`,`carrier`,`date` ) VALUES (?,?,?)});
		$sth->execute($self->{session}->{_session_id}, $self->{access_type},$self->{date_yyyy_mm_dd});
	}else{
	    $sth = $self->{dbi}->prepare(qq{insert into muu2 ( `uid`,`carrier`,`date` ) VALUES (?,?,?)});
		$sth->execute($self->{session}->{_session_id}, $self->{access_type},$self->{date_yyyy_mm_dd});
	}
};
if($@){
}
	return;
}

sub _get_pagecnt(){
	my $self = shift;
	
	my $accesscnt = $self->{session}->{_data}->{acnt};
	return if($accesscnt < 1 );
	return if($accesscnt >= 20 );

	my $pagecnt_str = "apagecnt".$accesscnt;
	my $pagecnt = $self->{mem}->get($pagecnt_str);
	$pagecnt++;

	$self->{mem}->set( $pagecnt_str, $pagecnt );
	
	return;
}

# 検索エンジンからのキーワードを取得する
sub _robots_search(){
	my $self = shift;
	
	my ($q,$startindex,$adpage,$mode,$yahoo,$url);

	# EZweb
	if( $ENV{'HTTP_REFERER'} =~/ezGoogleMain/i ){
		if($ENV{'HTTP_REFERER'} =~/(.*)query=(.*)&start-index=(.*)&adpage=(.*)&mode=(.*)/){
			$q = $2;
			$startindex = $3;
			$adpage = $4;
			$mode = $5;
			$q =~s/%([0-9A-Fa-f][0-9A-Fa-f])/pack('H2',$1)/eg;
		}
	}elsif( $ENV{'HTTP_REFERER'} =~/ezsch\.ezweb\.ne\.jp/i ){
		if($ENV{'HTTP_REFERER'} =~/(.*)query=(.*)&(.*)/){
			$q = $2;
			$q =~s/%([0-9A-Fa-f][0-9A-Fa-f])/pack('H2',$1)/eg;
		}
	}
	# yahoo フラグを利用する
	# 1 yahoo
	if( $ENV{'HTTP_REFERER'} =~/mobile\.yahoo\.co\.jp/i ){
		if($ENV{'HTTP_REFERER'} =~/(.*)p=(.*)/){
			$yahoo = 1;
			$q = $2;
			$q =~s/%([0-9A-Fa-f][0-9A-Fa-f])/pack('H2',$1)/eg;
		}
	}
	# 2 google
	if( $ENV{'HTTP_REFERER'} =~/google\.co\.jp/i ){
		if($ENV{'HTTP_REFERER'} =~/(.*)q=(.*)&(.*)/){
			$yahoo = 2;
			$q = $2;
			$q =~s/%([0-9A-Fa-f][0-9A-Fa-f])/pack('H2',$1)/eg;
		}
	}
	# 3 goo
	if( $ENV{'HTTP_REFERER'} =~/search\.mobile\.goo\.ne\.jp/i ){
		if($ENV{'HTTP_REFERER'} =~/(.*)MT=(.*)&(.*)/){
			$yahoo = 3;
			$q = $2;
			$q =~s/%([0-9A-Fa-f][0-9A-Fa-f])/pack('H2',$1)/eg;
		}
	}
	# 4 moba
	if( $ENV{'HTTP_REFERER'} =~/mbkn\.jp/i ){
		if($ENV{'HTTP_REFERER'} =~/(.*)q=(.*)&(.*)/){
			$yahoo = 4;
			$q = $2;
			$q =~s/%([0-9A-Fa-f][0-9A-Fa-f])/pack('H2',$1)/eg;
		}
	}
	
	return unless($q);
	$url = 'http://'.$ENV{'HTTP_HOST'}.$ENV{'REQUEST_URI'};
eval{
	my $sth = $self->{dbi}->prepare(qq{INSERT INTO robot_search ( `keyword`,`startindex`,`adpage`,`mode`,`yahoo`,`url`) VALUES (?,?,?,?,?,?)});
	$sth->execute($q,$startindex,$adpage,$mode,$yahoo,$url);
};
if($@){
}

	return;
}

sub _pv_detail(){
	my $self = shift;
	
eval{
		my $sth = $self->{dbi}->prepare( qq{insert into pv_detail ( `date_id`,`ctype`,`cginame`,`cnt` ) values (?,?,?,1)}	);
		$sth->execute($self->{date_yyyy_mm_dd},$self->{access_type},$ENV{'SCRIPT_NAME'});
};
eval{
	my $sth = $self->{dbi}->prepare( qq{update pv_detail set cnt = cnt + 1 where date_id = ? and ctype=? and cginame=? limit 1 } );
	$sth->execute($self->{date_yyyy_mm_dd},$self->{access_type},$ENV{'SCRIPT_NAME'});
};
	
	return;
}

sub _keyword_many(){
	my $self = shift;
	my $keyword = $self->{cgi}->param('q');

	$keyword =~s/\s/,/;
	$keyword =~s/ /,/;
eval{	
	my @vals = split(/,/,$keyword);

	my $sth = $self->{dbi}->prepare(qq{ select id from keyword where keyword = ? } );
	$sth->execute($vals[0]);
	my $keyword_id;
	while(my @row = $sth->fetchrow_array) {
		$keyword_id = $row[0];
	}

	my $sth = $self->{dbi}->prepare(qq{ insert into keyword_many (`keywords`,`keyword_id`) values (?,?)} );
	$sth->execute($keyword,$keyword_id);
};
	return;
}

1;