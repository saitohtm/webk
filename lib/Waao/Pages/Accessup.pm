package Waao::Pages::Accessup;
use strict;
use base qw(Waao::Pages::Base);
use Waao::Html;
use Waao::Utility;

#/waao.jp/accessup/
#/waao.jp/list-parent/accessup/<親ID>/
sub dispatch(){
	my $self = shift;
	
	if($self->{cgi}->param('url')){
		&_regist($self);
	}elsif($self->{cgi}->param('q') =~/list-/){
		&_exchange($self);
	}else{
		&_top($self);
	}
	
	return;
	
}

sub _top(){
	my $self = shift;
	
	my $parent_id = $self->{cgi}->param('p1');
   $self->{html_title} = qq{携帯アクセスアップツール みんなのトラフィックエクスチェンジ};
   $self->{html_keywords} = qq{アクセスアップ,トラフィックエクスチェンジ,携帯,アクセスアップツール,SEO,比較,ランキング};
   $self->{html_description} = qq{携帯サイトのアクセス数が劇的にアップするみんなのトラフィックエクスチェンジ};

	my $hr = &html_hr($self,1);	
	&html_header($self);

if($self->{xhtml}){
	# xhtml用ドキュメント
print << "END_OF_HTML";
END_OF_HTML
	
}else{
# xhmlt chtml

print << "END_OF_HTML";
<center>
<img src="http://img.waao.jp/traficexchengelogo.gif" width=120 height=28 alt="トラフィックエクスチェンジ"><font size=1 color="#FF0000">プラス</font>
</center>
END_OF_HTML

	&html_table($self, qq{<h2><font size=1 color="#FF0000">携帯アクセスアップツール</font></h2>}, 1, 0);

print << "END_OF_HTML";
$hr
みんなの<strong>トラフィックエクスチェンジ</strong>は、
今スグ<font color="#FF0000">アクセスアップ</font>ができる
携帯サイト専用の<strong>アクセスアップツール</strong>です<br>
参加は<font color="red">完全無料</font>炻<br>
<center>
<font color="red">
業界No1の高確率
</font>
</center>
1ポイントで1回自分のサイトが紹介されます<br>
<form action=/accessup.html method=POST>
<input type=hidden name=parent_id value="$parent_id">
URL入力で今すぐ<font color=#ff0000>アクセスアップ</font><br>
<input type=text name=url value="" istyle="3"><br>
<input type=submit value="入力">
</form>
$hr
<strong>携帯アクセスアップ</strong>の方法<br>
たくさんのHPを見るとポイントが貯まり、<br>
そのポイント分だけ自分のHPを見てもらうことが出来ます。<br>
まずはアナタのサイトのURLを入力<br>
<form action=/accessup.html method=POST>
<input type=hidden name=parent_id value="$parent_id">
URL入力で今すぐ<font color=#ff0000>アクセスアップ</font><br>
<input type=text name=url value=""  istyle="3"><br>
<input type=submit value="入力">
</form>
$hr
<a href="/release/">リリース情報</a><br>
<a href="/kiyaku/">免責事項・利用規約</a><br>
喆<a href="/privacy/">餅弉舗式累惻/a><br>
$hr
偂<a href="http://waao.jp/list-in/ranking/12/">みんなのランキング</a><br>
坙<a href="http://accessup.goo.to/info.html" title="携帯アクセスアップ">アクセスアップ<a><br>
<a href="/" accesskey=0>トップ</a>&gt;みんなの<strong>トラフィックエクスチェンジ</strong><br>
<font size=1>
みんなのトラフィックエクスチェンジは、携帯専用のアクセスアップツールです。無料で使えてアクセス数アップすることができます。<br>
他のアクセスアップツールと比較しても、圧倒的にランキング1位です</font>
END_OF_HTML
}
	
	&html_footer($self);
	
	return;
}

sub _regist(){
	my $self = shift;

	my $url = $self->{cgi}->param('url');
	my $parent_id = $self->{cgi}->param('parent_id');
	
	if( $url eq 'http://'){
		&_input_err($self);
		return;
	}
	my ($id, $point, $usedpoint, $outcnt);
	my $regist_first;
eval{
	# url 登録チェック
 	my $sth = $self->{dbi}->prepare(qq{select id, point, usedpoint, outcnt from accessexc where url = ? limit 1} );
    $sth->execute( $url );
	while(my @row = $sth->fetchrow_array) {
        ($id, $point, $usedpoint, $outcnt) = @row;
	}
	# 無ければ登録
	unless($id){
		$regist_first = 1;
        $sth = $self->{dbi}->prepare(qq{INSERT INTO accessexc ( `url`,
                                                                `point`,
                                                                `usedpoint`,
                                                                `outcnt`,
                                                                `parent_id`)  
                                         VALUES (?,0,0,0,?)});
		$sth->execute( $url, $parent_id );
		$id = $self->{dbi}->{q{mysql_insertid}};
		$point = 0;
		$usedpoint = 0;
		$outcnt = 0;
	}
};

    $self->{html_title} = qq{携帯アクセスアップツール みんなのトラフィックエクスチェンジ};
    $self->{html_keywords} = qq{アクセスアップ,トラフィックエクスチェンジ,携帯,アクセスアップツール,SEO,比較,ランキング};
    $self->{html_description} = qq{携帯サイトのアクセス数が劇的にアップするみんなのトラフィックエクスチェンジ};
	my $hr = &html_hr($self,1);	
	my $ad = &html_google_ad($self);
	&html_header($self);

	&html_table($self, qq{<font size=1 color="#FF0000">[無料]登録完了</font>}, 1, 0);

print << "END_OF_HTML";
<img src="http://img.waao.jp/gr_domo.gif" width=26 height=47 style="float:left;margin-top:3px;margin-right:3px;margin-bottom:8px;" align="left">
<font size=1>無料登録、ありがとうございました。早速<strong>アクセスアップ</strong>してください。</font><br>
<br clear="all" />
今スグ<font color="#FF0000">アクセスアップ</font>ができる<br>
携帯サイト専用の<strong>アクセスアップツール</strong>です<br>
現在の還元率<br>
<font color="red">業界No.1</font><br>
1ポイント=1アクセス棈
$hr
<font color="blue">$url</font><br>
のアクセスアップ管理ページ<br>
<font size=1 color="red">※悪質なURLは削除されます</font><br>
$hr
現在のポイント:<font color="red">$point</font><br>
<font size=1>└サイトアクセス時に溜まるポイントです</font><br>
アクセス数:<font color="red">$outcnt</font><br>
<font size=1>└サイトが誰かに見られた回数です</font><br>
使用済みポイント:<font color="red">$usedpoint</font><br>
<font size=1>└使用済みのポイントです</font><br>
<br>
<font color=#ff8000>▼</font>ポイント取得URL<br>
<font size=1>└サイトの見える場所にリンクを張ってください</font><br>
<form action="" method="post" wrap="VIRTUAL" name="dummy">
<textarea name="text" rows="3" cols="50">
&lt;a href="http://waao.jp/list-$id/accessup/"&gt;オススメケータイサイトを見る&lt;/a&gt;&lt;br&gt;&lt;a href="http://waao.jp/accessup/"&gt;携帯専用アクセスアップツール!&lt;/a&gt;
</textarea>
</form><br>
<font color=#ff8000>▼</font>お友達紹介リンク<BR>
<font size=1>└紹介した友達のポイントと同じポイントがあなたに入ります</font><br>
<textarea name="text" rows="3" cols="50">
&lt;a href="http://waao.jp/list-$id/accessup/"&gt;オススメケータイサイトを見る&lt;/a&gt;&lt;br&gt;
URLを入力すると誰かに閲覧されます&lt;br&gt;
&lt;form action="http://waao.jp/accessup.html" method="POST"&gt;
&lt;input type="text" name="url" value="http://" istyle="3" size="16"&gt;&lt;br&gt;
&lt;input type="hidden" name="parent_id" value="$id"&gt;
&lt;input type="submit" value="送信"&gt;&lt;br&gt;
&lt;/form&gt;
&lt;a href="http://waao.jp/accessup/"&gt;携帯専用アクセスアップツール!&lt;/a&gt;
</textarea>

$hr
<a href="/" accesskey=0>トップ</a>&gt;みんなの<strong>トラフィックエクスチェンジ</strong><br>
<font size=1>
みんなのトラフィックエクスチェンジは、携帯専用のアクセスアップツールです。無料で使えてアクセス数アップすることができます。
</font>
END_OF_HTML

	&html_footer($self);
	
	return;
}

sub _input_err(){
	my $self = shift;

   $self->{html_title} = qq{携帯アクセスアップツール みんなのトラフィックエクスチェンジ};
   $self->{html_keywords} = qq{アクセスアップ,トラフィックエクスチェンジ,携帯,アクセスアップツール,SEO,比較,ランキング};
   $self->{html_description} = qq{携帯サイトのアクセス数が劇的にアップするみんなのトラフィックエクスチェンジ};

	my $ad = &html_google_ad($self);
	my $hr = &html_hr($self,1);	
	&html_header($self);
	&html_table($self, qq{<font size=1 color="#FF0000">入力エラー</font>}, 1, 0);

print << "END_OF_HTML";
$hr
<center>
$ad
</center>
$hr
URLを正しく入力してください。
$hr
<a href="/" accesskey=0>トップ</a>&gt;<a href="/accessup/">みんなのトラフィックエクスチェンジ</a>&gt;<strong>入力エラー</strong><br>
<font size=1>
みんなのトラフィックエクスチェンジは、携帯専用のアクセスアップツールです。無料で使えてアクセス数アップすることができます。
</font>
END_OF_HTML

	&html_footer($self);

	return;
}

sub _exchange(){
	my $self = shift;
	my $accessupid = $self->{cgi}->param('q');
	$accessupid =~s/list-//g;

#	&_pc_dsp($self) unless($self->{real_mobile});

	my $access_point = 1;
	my $out_point = 1;
	my $redirect_url;
	my $exsist_flag;
eval{
	my $sth = $self->{dbi}->prepare(qq{select id from accessexc  where id = ? and delflag = 0 limit 1} );
    $sth->execute( $accessupid );
	while(my @row = $sth->fetchrow_array) {
		$exsist_flag = 1;
	}
	if($exsist_flag){
	
		# ランダムチョイス
		$sth = $self->{dbi}->prepare(qq{select id, url, parent_id from accessexc where point >= ? and id <> ? order by rand() limit 1} );
	    $sth->execute( $out_point, $accessupid );
		my ($id, $parent_id);
		while(my @row = $sth->fetchrow_array) {
			$id = $row[0];
			$redirect_url = $row[1];
			$parent_id = $row[2];
		}
		# 更新
		if( $id ){
			$sth = $self->{dbi}->prepare(qq{update accessexc set point = point - $out_point, usedpoint = usedpoint + $out_point, outcnt = outcnt + 1 where id = ? } );
   			$sth->execute( $id );
		}
		# point up
		my $sth = $self->{dbi}->prepare(qq{update accessexc set point = point + $access_point where id = ? } );
    	$sth->execute( $accessupid );

		# 親に還元
		if( $parent_id ){
			$sth = $self->{dbi}->prepare(qq{update accessexc set point = point + $out_point where id = ? } );
   			$sth->execute( $parent_id );
		}
	}
};

	unless( $redirect_url ){
		$redirect_url = qq{http://waao.jp/news/};
	}

	print qq{Location:$redirect_url \n\n};

	return;
}

sub _pc_dsp(){
	my $self = shift;
	return;
}

1;