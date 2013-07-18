#!/usr/bin/perl
use lib qw(/var/www/vhosts/goo.to/etc/lib /var/www/vhosts/goo.to/lib/Waao);

use strict;
use Utility;
use DBI;
use Jcode;
use Seolinks;
use LWP::UserAgent;
use Date::Simple;
use LWP::Simple;
# dir
# smartphone なし
# PC -pc
# mobile -m 
# test loto

my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-smf/loto/};
mkdir($dirname, 0755);
my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-smf/loto/loto6/};
mkdir($dirname, 0755);
my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-smf/loto/miniloto/};
mkdir($dirname, 0755);
my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-smf/loto/jumbo/};
mkdir($dirname, 0755);
my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-smf/loto/toto/};
mkdir($dirname, 0755);
my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-smf/loto/totobig/};
mkdir($dirname, 0755);
my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-smf/loto/totobig1000/};
mkdir($dirname, 0755);
my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-smf/loto/totominibig/};
mkdir($dirname, 0755);
my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-smf/loto/loto7/};
mkdir($dirname, 0755);

# top
&_top();
# ジャンボ
&_jumbo();
# toto
&_toto();
# loto6
&_loto6();
# miniloto
&_miniloto();
# loto7
&_loto7();

exit;

sub _top(){

binmode(STDOUT, ":utf8");# PerlIOレイヤ
use open ":utf8";
	my $dbh = &_db_connect();

	my $html = &_load_tmpl("top.html","tmpl_smf");
	$html = &_parts_set($html);

	# 六曜
	my $rokuyo = &_rokuyo();
	$rokuyo = Encode::encode('utf-8',$rokuyo);
	$html =~s/<!--ROKURO-->/$rokuyo/g;

	# キャリーオーバー情報(loto6/toto/競輪くじ/競艇くじ/オートレース/競馬くじWIN5)
	#競馬：農林水産省
	# http://jra.jp/w5jd/win5/
	#競艇：国土交通省
	# http://www.chariloto.com/pc/top
	#競輪：経済産業省
	# 
	#オートレース：経済産業省
	#http://www.oddspark.com/loto/
	#スポーツ振興くじ：文部科学省
	# http://www.toto-dream.com/
	#宝くじ：総務省
	#おまけでFX
	my $coy;
	my $sth = $dbh->prepare(qq{select id, coy from loto6 order by id desc limit 1 } );
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		if($row[1]){
			$coy .= qq{loto6 キャリーオーバー中！  }.&price_dsp($row[1]).qq{<br>};
		}else{
			$coy .= qq{loto6 現在、キャリーオーバーの情報はありません}.qq{<br>};
		}
	}

	my $sth = $dbh->prepare(qq{select id, coy from loto7 order by id desc limit 1 } );
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		if($row[1]){
			$coy .= qq{loto7 キャリーオーバー中！  }.&price_dsp($row[1]);
		}else{
			$coy .= qq{loto7 現在、キャリーオーバーの情報はありません};
		}
	}
	$html =~s/<!--COVER-->/$coy/g;

	&_file_output("/var/www/vhosts/goo.to/httpdocs-smf/loto/index.htm",$html);

	$dbh->disconnect;

	return;
}

sub _toto(){

	my $html = &_load_tmpl("toto.html","tmpl_smf");
	$html = &_parts_set($html);

	&_file_output("/var/www/vhosts/goo.to/httpdocs-smf/loto/toto/index.htm",$html);

	# totoBIG
	&_toto_list(1);
	# totoBIG1000
	&_toto_list(2);
	# totominiBIG
	&_toto_list(3);
	
	return;
}

sub _toto_list(){
	my $type = shift;

	my $dbh = &_db_connect();
	my $cnt;
	my $page;
	my $pagelist;
	my $sth = $dbh->prepare(qq{select * from toto where type = ? order by id desc} );
	$sth->execute($type);
	while(my @row = $sth->fetchrow_array) {
		$cnt++;
		my $dirname;
		if($type eq 1){
			$dirname=qq{totobig};
		}elsif($type eq 2){
			$dirname=qq{totobig1000};
		}elsif($type eq 3){
			$dirname=qq{totominibig};
		}
		my $html;
		$html = &_load_tmpl("$dirname".".html","tmpl_smf");
		$html = &_parts_set($html);

		$html =~s/<!--ID-->/$row[0]/g;
		$html =~s/<!--SDATE-->/$row[2]/g;
		$html =~s/<!--EDATE-->/$row[3]/g;
		$html =~s/<!--ODATE-->/$row[4]/g;

		my $prize_list;
		my $sth2 = $dbh->prepare(qq{select prize,price,cnt,cov from toto_prize where toto_id = ? and type = ? order by prize} );
		$sth2->execute($row[0], $type);
		while(my @row2 = $sth2->fetchrow_array) {
			$prize_list .= qq{<div class="ui-block-a">$row2[0]</div>};
			$prize_list .= qq{<div class="ui-block-b">$row2[2]</div>};
			$prize_list .= qq{<div class="ui-block-c">$row2[1]</div>};
#			$prize_list .= qq{<div class="ui-block-d">$row2[3]</div>};
		}
		$html =~s/<!--PRIZELIST-->/$prize_list/g;

		my $game_list;
		my $sth2 = $dbh->prepare(qq{select `no`,team1,vs_result,team2,no_result from toto_game where toto_id = ? and type = ? order by `no`} );
		$sth2->execute($row[0], $type);
		while(my @row2 = $sth2->fetchrow_array) {
			$game_list .= qq{<div class="ui-block-a">$row2[1]</div>};
			$game_list .= qq{<div class="ui-block-b">$row2[2]</div>};
			$game_list .= qq{<div class="ui-block-c">$row2[3]</div>};
#			$game_list .= qq{<div class="ui-block-d">$row2[4]</div>};
		}
		$html =~s/<!--GAMELIST-->/$game_list/g;

		# page index.htm

		my $pagelist_tmp =qq{<ul data-role="listview" data-theme="a" data-inset="true">};
		$pagelist_tmp.=qq{<li data-role="list-divider" data-theme="a">第$row[0]回</li>};
		$pagelist_tmp.=qq{<li><a href="/<!--DIR-->/$dirname/$row[0].htm">$row[2] $row[3]</a></li>};
		$pagelist_tmp.=qq{</ul>};

		$pagelist .= $pagelist_tmp;

		my $pre_id = $row[0] - 1;
		my $next_id = $row[0] + 1;
		$html =~s/<!--PREID-->/$pre_id/g;
		$html =~s/<!--NEXTID-->/$next_id/g;

		my $list = qq{$row[2] $row[3] $row[4] $row[5] $row[6] $row[7] <font color="#00FF40">($row[8])</font>};
		$html =~s/<!--LIST-->/$list/g;

		&_file_output("/var/www/vhosts/goo.to/httpdocs-smf/loto/$dirname/$row[0].htm",$html);

		if($cnt % 10){
		}else{
			# page 
			my $html;
			$html = &_load_tmpl("$dirname"."list.html","tmpl_smf");

			my $pagenext = $page + 1;
			$html =~s/<!--PAGE-->/$page/g;
			$html =~s/<!--PAGELIST-->/$pagelist/g;
			$html =~s/<!--PAGENEXT-->/$pagenext/g;
			$html = &_parts_set($html);

			&_file_output("/var/www/vhosts/goo.to/httpdocs-smf/loto/$dirname/index$page.htm",$html);

			$page++;
			$pagelist = undef;
		}
	}
	
	

	$dbh->disconnect;

	return;
}

sub _jumbo(){

	my $html = &_load_tmpl("janbo.html","tmpl_smf");
	$html = &_parts_set($html);

	&_file_output("/var/www/vhosts/goo.to/httpdocs-smf/loto/jumbo/index.htm",$html);

	my $dbh = &_db_connect();

	my $arealist;
	my $pagestr;
	my $pre_area=1;
	my $sth = $dbh->prepare(qq{select * from loto_jumbo order by area, date_loto desc} );
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		
		
		# 一覧ページ作成
		if($pre_area ne $row[2]){
			my $html = &_load_tmpl("kujilist$pre_area.html","tmpl_smf");
			$html =~s/<!--LIST-->/$arealist/g;
			$html = &_parts_set($html);
			&_file_output("/var/www/vhosts/goo.to/httpdocs-smf/loto/jumbo/$pre_area.htm",$html);

			$arealist = undef;
			$pre_area = $row[2];
		}

		my $name_tmp = $row[3];
		$name_tmp=~s/全国自治宝くじ（//;
		$name_tmp=~s/）//;

		$arealist .= qq{<li><a href="/<!--DIR-->/jumbo/$row[2]-$row[0].htm">第$row[0]回 $row[4] $name_tmp</a></li>};


		my $list;
		my $list2;
		my $sth2 = $dbh->prepare(qq{select * from loto_kuji where loto_id = ?} );
		$sth2->execute($row[0]);
		while(my @row2 = $sth2->fetchrow_array) {
			$list .= qq{<div class="ui-block-a">$row2[1]</div>};
			$list .= qq{<div class="ui-block-b">$row2[3] $row2[4]</div>};
			$list2 .= qq{<div class="ui-block-a">$row2[1]</div>};
			$list2 .= qq{<div class="ui-block-b">$row2[2]</div>};
		}

		my $html;
		if($row[2] eq 1){
			$html = &_load_tmpl("janbo_detail.html","tmpl_smf");
		}else{
			$html = &_load_tmpl("kuji.html","tmpl_smf");
		}
		$html = &_parts_set($html);
	
		$html =~s/<!--NO-->/$row[0]/g;
		$html =~s/<!--NAME-->/$name_tmp/g;
		$html =~s/<!--LOTODATE-->/$row[4]/g;

		$html =~s/<!--LIST-->/$list/g;
		$html =~s/<!--LIST2-->/$list2/g;
			
		&_file_output("/var/www/vhosts/goo.to/httpdocs-smf/loto/jumbo/$row[2]-$row[0].htm",$html);


	}
	
	
	$dbh->disconnect;
	return;
}

sub _loto6(){
	my $dbh = &_db_connect();
	# allpage
	my $cnt;
	my $page;
	my $pagelist;
	my $sth = $dbh->prepare(qq{select id,date,n1,n2,n3,n4,n5,n6,nb,pc1,pc2,pc3,pc4,pc5,py1,py2,py3,py4,py5,coy,am from loto6 order by id desc} );
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$cnt++;
		my $html = &_load_tmpl("loto6.html","tmpl_smf");
		$html = &_parts_set($html);
		$html =~s/<!--ID-->/$row[0]/g;
		$html =~s/<!--LOTODATE-->/$row[1]/g;
		$html =~s/<!--NO1-->/$row[2]/g;
		$html =~s/<!--NO2-->/$row[3]/g;
		$html =~s/<!--NO3-->/$row[4]/g;
		$html =~s/<!--NO4-->/$row[5]/g;
		$html =~s/<!--NO5-->/$row[6]/g;
		$html =~s/<!--NO6-->/$row[7]/g;
		$html =~s/<!--NO7-->/$row[8]/g;

		$html =~s/<!--CNT1-->/$row[9]/g;
		$html =~s/<!--CNT2-->/$row[10]/g;
		$html =~s/<!--CNT3-->/$row[11]/g;
		$html =~s/<!--CNT4-->/$row[12]/g;
		$html =~s/<!--CNT5-->/$row[13]/g;

		my $p1 = &price_dsp($row[14]);
		my $p2 = &price_dsp($row[15]);
		my $p3 = &price_dsp($row[16]);
		my $p4 = &price_dsp($row[17]);
		my $p5 = &price_dsp($row[18]);
		$html =~s/<!--PRICE1-->/$p1/g;
		$html =~s/<!--PRICE2-->/$p2/g;
		$html =~s/<!--PRICE3-->/$p3/g;
		$html =~s/<!--PRICE4-->/$p4/g;
		$html =~s/<!--PRICE5-->/$p5/g;

		my $cov = &price_dsp($row[19]);
		if($cov){
		}else{
			$cov.=qq{$cov};
		}
		$html =~s/<!--OVER-->/$cov/g;
		# page index.htm

		my $pagelist_tmp =qq{<ul data-role="listview" data-theme="a" data-inset="true">};
		$pagelist_tmp.=qq{<li data-role="list-divider" data-theme="a">第$row[0]回　($row[1])</li>};
		$pagelist_tmp.=qq{<li><a href="/<!--DIR-->/loto6/$row[0].htm">$row[2] $row[3] $row[4] $row[5] $row[6] $row[7] <font color="#00FF40">($row[8])</font><br>};
		if($cov > 0){
			$pagelist_tmp.=qq{キャリーオーバー:<br><font color="red">$cov円</font></a></li> };
		}else{
			$pagelist_tmp.=qq{</a></li> };
#			$pagelist.=qq{キャリーオーバー:0円</a></li> };
		}
		$pagelist_tmp.=qq{</ul>};

		$pagelist .= $pagelist_tmp;

		my $pre_id = $row[0] - 1;
		my $next_id = $row[0] + 1;
		$html =~s/<!--PREID-->/$pre_id/g;
		$html =~s/<!--NEXTID-->/$next_id/g;

		my $list = qq{$row[2] $row[3] $row[4] $row[5] $row[6] $row[7] <font color="#00FF40">($row[8])</font>};
		$html =~s/<!--LIST-->/$list/g;

		&_file_output("/var/www/vhosts/goo.to/httpdocs-smf/loto/loto6/$row[0].htm",$html);

		if($cnt % 10){
		}else{
			# page 
			my $html = &_load_tmpl("loto6list.html","tmpl_smf");

			my $pagenext = $page + 1;
			$html =~s/<!--PAGE-->/$page/g;
			$html =~s/<!--PAGELIST-->/$pagelist/g;
			$html =~s/<!--PAGENEXT-->/$pagenext/g;
			$html = &_parts_set($html);
			&_file_output("/var/www/vhosts/goo.to/httpdocs-smf/loto/loto6/index$page.htm",$html);
			$page++;
			$pagelist = undef;
		}
	}
	
	

	$dbh->disconnect;

	return;
}

sub _miniloto(){
	my $dbh = &_db_connect();
	# allpage
	my $cnt;
	my $page;
	my $pagelist;
	my $sth = $dbh->prepare(qq{select * from miniloto order by id desc} );
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$cnt++;
		my $html = &_load_tmpl("miniloto.html","tmpl_smf");
		$html = &_parts_set($html);
		$html =~s/<!--ID-->/$row[0]/g;
		$html =~s/<!--LOTODATE-->/$row[1]/g;
		$html =~s/<!--NO1-->/$row[2]/g;
		$html =~s/<!--NO2-->/$row[3]/g;
		$html =~s/<!--NO3-->/$row[4]/g;
		$html =~s/<!--NO4-->/$row[5]/g;
		$html =~s/<!--NO5-->/$row[6]/g;
		$html =~s/<!--NO6-->/$row[7]/g;

		$html =~s/<!--CNT1-->/$row[8]/g;
		$html =~s/<!--CNT2-->/$row[9]/g;
		$html =~s/<!--CNT3-->/$row[10]/g;
		$html =~s/<!--CNT4-->/$row[11]/g;

		my $p1 = &price_dsp($row[12]);
		my $p2 = &price_dsp($row[13]);
		my $p3 = &price_dsp($row[14]);
		my $p4 = &price_dsp($row[15]);
		$html =~s/<!--PRICE1-->/$p1/g;
		$html =~s/<!--PRICE2-->/$p2/g;
		$html =~s/<!--PRICE3-->/$p3/g;
		$html =~s/<!--PRICE4-->/$p4/g;

		# page index.htm

		my $pagelist_tmp =qq{<ul data-role="listview" data-theme="a" data-inset="true">};
		$pagelist_tmp.=qq{<li data-role="list-divider" data-theme="a">第$row[0]回　($row[1])</li>};
		$pagelist_tmp.=qq{<li><a href="/<!--DIR-->/miniloto/$row[0].htm">$row[2] $row[3] $row[4] $row[5] $row[6] <font color="#00FF40">($row[7])</font></a>};
		$pagelist_tmp.=qq{</ul>};

		$pagelist .= $pagelist_tmp;

		my $pre_id = $row[0] - 1;
		my $next_id = $row[0] + 1;
		$html =~s/<!--PREID-->/$pre_id/g;
		$html =~s/<!--NEXTID-->/$next_id/g;

		my $list = qq{$row[2] $row[3] $row[4] $row[5] $row[6] <font color="#00FF40">($row[7])</font>};
		$html =~s/<!--LIST-->/$list/g;
		&_file_output("/var/www/vhosts/goo.to/httpdocs-smf/loto/miniloto/$row[0].htm",$html);

		if($cnt % 10){
		}else{
			# page 
			my $html = &_load_tmpl("minilotolist.html","tmpl_smf");

			my $pagenext = $page + 1;
			$html =~s/<!--PAGE-->/$page/g;
			$html =~s/<!--PAGELIST-->/$pagelist/g;
			$html =~s/<!--PAGENEXT-->/$pagenext/g;
			$html = &_parts_set($html);
			&_file_output("/var/www/vhosts/goo.to/httpdocs-smf/loto/miniloto/index$page.htm",$html);
			$page++;
			$pagelist = undef;
		}
	}
	
	

	$dbh->disconnect;

	return;
}

sub _loto7(){
	my $dbh = &_db_connect();
	# allpage
	my $cnt;
	my $page;
	my $pagelist;
	my $sth = $dbh->prepare(qq{select * from loto7 order by id desc} );
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$cnt++;
		my $html = &_load_tmpl("loto7.html","tmpl_smf");
		$html = &_parts_set($html);
		$html =~s/<!--ID-->/$row[0]/g;
		$html =~s/<!--LOTODATE-->/$row[1]/g;
		$html =~s/<!--NO1-->/$row[2]/g;
		$html =~s/<!--NO2-->/$row[3]/g;
		$html =~s/<!--NO3-->/$row[4]/g;
		$html =~s/<!--NO4-->/$row[5]/g;
		$html =~s/<!--NO5-->/$row[6]/g;
		$html =~s/<!--NO6-->/$row[7]/g;
		$html =~s/<!--NO7-->/$row[8]/g;

		$html =~s/<!--CNT1-->/$row[11]/g;
		$html =~s/<!--CNT2-->/$row[12]/g;
		$html =~s/<!--CNT3-->/$row[13]/g;
		$html =~s/<!--CNT4-->/$row[14]/g;
		$html =~s/<!--CNT5-->/$row[15]/g;
		$html =~s/<!--CNT6-->/$row[16]/g;

		my $p1 = &price_dsp($row[17]);
		my $p2 = &price_dsp($row[18]);
		my $p3 = &price_dsp($row[19]);
		my $p4 = &price_dsp($row[20]);
		my $p5 = &price_dsp($row[21]);
		my $p6 = &price_dsp($row[22]);
		$html =~s/<!--PRICE1-->/$p1/g;
		$html =~s/<!--PRICE2-->/$p2/g;
		$html =~s/<!--PRICE3-->/$p3/g;
		$html =~s/<!--PRICE4-->/$p4/g;
		$html =~s/<!--PRICE5-->/$p5/g;
		$html =~s/<!--PRICE6-->/$p6/g;

		my $cov = &price_dsp($row[23]);
		if($cov){
		}else{
			$cov.=qq{$cov};
		}
		$html =~s/<!--OVER-->/$cov/g;
		# page index.htm

		my $pagelist_tmp =qq{<ul data-role="listview" data-theme="a" data-inset="true">};
		$pagelist_tmp.=qq{<li data-role="list-divider" data-theme="a">第$row[0]回　($row[1])</li>};
		$pagelist_tmp.=qq{<li><a href="/<!--DIR-->/loto7/$row[0].htm">$row[2] $row[3] $row[4] $row[5] $row[6] $row[7] $row[8]<font color="#00FF40">($row[9],$row[10])</font><br>};
		if($cov > 0){
			$pagelist_tmp.=qq{キャリーオーバー:<br><font color="red">$cov円</font></a></li> };
		}else{
			$pagelist_tmp.=qq{</a></li> };
#			$pagelist.=qq{キャリーオーバー:0円</a></li> };
		}
		$pagelist_tmp.=qq{</ul>};

		$pagelist .= $pagelist_tmp;

		my $pre_id = $row[0] - 1;
		my $next_id = $row[0] + 1;
		$html =~s/<!--PREID-->/$pre_id/g;
		$html =~s/<!--NEXTID-->/$next_id/g;

		my $list = qq{$row[2] $row[3] $row[4] $row[5] $row[6] $row[7] $row[8]<font color="#00FF40">($row[9],$row[10])</font>};
		$html =~s/<!--LIST-->/$list/g;

		&_file_output("/var/www/vhosts/goo.to/httpdocs-smf/loto/loto7/$row[0].htm",$html);

		if($cnt <= 10){
			# page 
			my $html = &_load_tmpl("loto7list.html","tmpl_smf");

			my $pagenext = $page + 1;
			$html =~s/<!--PAGE-->/$page/g;
			$html =~s/<!--PAGELIST-->/$pagelist/g;
			$html =~s/<!--PAGENEXT-->/$pagenext/g;
			$html = &_parts_set($html);
			&_file_output("/var/www/vhosts/goo.to/httpdocs-smf/loto/loto7/index$page.htm",$html);
			$page++;
			$pagelist = undef;
		}elsif($cnt % 10){
		}else{
			# page 
			my $html = &_load_tmpl("loto7list.html","tmpl_smf");

			my $pagenext = $page + 1;
			$html =~s/<!--PAGE-->/$page/g;
			$html =~s/<!--PAGELIST-->/$pagelist/g;
			$html =~s/<!--PAGENEXT-->/$pagenext/g;
			$html = &_parts_set($html);
			&_file_output("/var/www/vhosts/goo.to/httpdocs-smf/loto/loto7/index$page.htm",$html);
			$page++;
			$pagelist = undef;
		}
	}


	$dbh->disconnect;

	return;
}



sub _parts_set(){
	my $html = shift;

	# meta
	my $header = &_load_tmpl("header.html","tmpl_smf");
	$html =~s/<!--HEADER-->/$header/g;
	my $footer = &_load_tmpl("footer.html","tmpl_smf");
	$html =~s/<!--FOOTER-->/$footer/g;

	my $adsence = &_load_tmpl("adsence.html","tmpl_smf");
	$html =~s/<!--ADSENCE-->/$adsence/g;


	my $dir = qq{loto};
	$html =~s/<!--DIR-->/$dir/g;

	return $html;
}

sub _load_tmpl(){
	my $tmpl = shift;
	my $base_dir = shift;

	$base_dir = qq{tmpl} unless($base_dir);
	
my $file = qq{/var/www/vhosts/goo.to/etc/makehtml/loto/$base_dir/$tmpl};
my $fh;
my $filedata;
open( $fh, "<", $file );
while( my $line = readline $fh ){ 
	$filedata .= $line;
}
close ( $fh );
	$filedata = &_date_set($filedata);

	return $filedata;
}

sub _date_set(){
	my $html = shift;
	my $date = Date::Simple->new();
	my $ymd = $date->format('%Y/%m/%d');
	$html =~s/<!--DATE-->/$ymd/gi;
	return $html;
}

sub _file_output(){
	my $filename = shift;
	my $html = shift;
	
	open(OUT,"> $filename") || die('error');
	print OUT "$html";
	close(OUT);

	return;
}

sub _db_connect(){
	my $dsn = 'DBI:mysql:waao';
	my $user = 'mysqlweb';
	my $password = 'WaAoqzxe7h6yyHz';

	my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 1, AutoCommit => 0});

	return $dbh;
}

sub _rokuyo(){

	my $today = Date::Simple->new();

	my $yesterday = $today->prev;
	my $tomorrow = $today->next;

	my ($rokuyou_today, $rokuyou_today_str) = &_get_rokuyo($today->year,$today->month,$today->day);
	my ($rokuyou_tomorrow, $rokuyou_tomorrow_str) = &_get_rokuyo($tomorrow->year,$tomorrow->month,$tomorrow->day);

	my $str = qq{<img src="/img/E110_20.gif" height="15">}.$today->month.qq{/}.$today->day.qq{ };
	$str .= qq{$rokuyou_today<br />};
	$str .= qq{$rokuyou_today_str<br />};
	$str .= qq{<img src="/img/E110_20.gif" height="15">}.$tomorrow->month.qq{/}.$tomorrow->day.qq{ };
	$str .= qq{$rokuyou_tomorrow<br />};
	$str .= qq{$rokuyou_tomorrow_str};

	return $str;
}

sub _get_rokuyo(){
	my $year = shift;
	my $mon = shift;
	my $mday = shift;

	my $rokuyou;
	my $geturl = qq{http://jqreki.appspot.com/qreki/$year/$mon/$mday};
	my $data_from_web = get( $geturl );

	my @lines = split(/\n/,$data_from_web);
	foreach my $line (@lines){
		if( $line=~/(.*)rokuyo\":\"(.*)\",\"month(.*)/){
			$rokuyou = $2;
		}
	}
	my $rokuyou_str;
#		$rokuyou_str = qq{午前11時ごろから午後1時ごろまでのみ吉で、それ以外は凶};
	if($rokuyou eq '大安'){
		$rokuyou_str = qq{最も吉の日};
	}elsif($rokuyou =~/赤口/){
		$rokuyou_str = qq{午前11時ごろから午後1時ごろまでのみ吉で、それ以外は凶};
	}elsif($rokuyou eq '先勝'){
		$rokuyou_str = qq{午前中は吉、午後二時より六時までは凶};
	}elsif($rokuyou eq '友引'){
		$rokuyou_str = qq{朝は吉、昼は凶、夕は大吉。};
	}elsif($rokuyou eq '先負'){
		$rokuyou_str = qq{午前中は凶、午後は吉};
	}elsif($rokuyou eq '仏滅'){
		$rokuyou_str = qq{仏も滅するような大凶日};
	}

	return($rokuyou,$rokuyou_str);
}

sub price_dsp(){
	my $price = shift;

	1 while $price =~ s/(.*\d)(\d\d\d)/$1,$2/;	

	return $price;
}

