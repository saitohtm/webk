package Waao::Pages::SMFRegist;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Html5;
use Waao::Data;
use Waao::Utility;
use Waao::Mail;

sub dispatch(){
	my $self = shift;

	if($self->{cgi}->param('site')){
		&_regist($self);
		&send_mail($self, 'waaooooo@gmail.com','site regist ','http://s.waao.jp/sitecheck.html');
	}else{
		&_top($self);
	}
	
	return;
}

sub _regist(){
	my $self = shift;
	
	unless( $self->{cgi}->param('category') ){
		&_err_page($self,"001");
		return;
	}
	return &_err_page($self,"002") if( &urlcheck($self->{cgi}->param('siteurl')) );
	return &_err_page($self,"003") if( &lengthcheck($self->{cgi}->param('site'),1,255) );
	return &_err_page($self,"004") if( &lengthcheck($self->{cgi}->param('description'),1,600) );


eval{
	my $siteid;
	my $sth = $self->{dbi}->prepare(qq{select id FROM smf_site where  url = ? limit 1});
	$sth->execute( $self->{cgi}->param('siteurl') );
	while(my @row = $sth->fetchrow_array) {
		$siteid = $row[0];
	}
	if($siteid){
	    $sth = $self->{dbi}->prepare(qq{update smf_site set good = good + 1 where id = ? limit 1});
		$sth->execute($siteid);
		
	}else{
	    $sth = $self->{dbi}->prepare(qq{insert into smf_site ( `name`, `url`, `title`,`category_id`,`description`)  
                                         VALUES (?,?,?,?,?)});
		$sth->execute(&input_str( $self->{cgi}->param('site') ),
			&input_str( $self->{cgi}->param('siteurl') ),
			&input_str( $self->{cgi}->param('site') ),
			$self->{cgi}->param('category'),
			&input_str( $self->{cgi}->param('description') )
		);
	}
};
if($@){
	&_err_page($self,"005");
	return;
}	
	

	my $pcdsp;
	$pcdsp .= qq{不正防止のため、登録者情報を記録させていただきます<br>};
	$pcdsp .= $ENV{'REMOTE_ADDR'}."<br>";
	$pcdsp .= $ENV{'REMOTE_HOST'}."<br>";

	my $a = 'スマートフォンサイト登録完了 -スマートフォンナビ-';
	$self->{html_title} = qq{$a};
	my $b = 'スマフォサイト,サイト登録,スマートフォン,アプリ,ドコモ,au,iphone,アンドロイド';
	$self->{html_keywords} = qq{$b};
	my $c = 'スマフォナビにスマートフォンサイトを登録完了しました。';
	$self->{html_description} = qq{$c};
	&html_header($self);

print << "END_OF_HTML";
<div id="header">
<h1><a href="/" style="display: block;"><img src="/img/smftop.jpg" width=100% alt="スマフォナビ"></a></h1>
</div>
<div data-role="header">
<h2>登録完了</h2>
</div>
<a href="/">トップ</a>&gt;<a href="/regist.html">サイト登録</a>&gt;サイト登録完了
<div data-role="content">
<table border="0" width=100%><tr><td BGCOLOR="#FFFFFF">
<center>
<img src="/img/gr_domo.gif">
</center>
ご登録ありがとうございます<br><br>
みんなの力で育てるスマートフォン専用の検索エンジン<br>
リンクフリーです。<br>
<br>
http://s.waao.jp/<br>
<br>
$pcdsp
</td></tr></table>
</div>
END_OF_HTML

	&html_footer($self);

	return;
}

sub _err_page(){
	my $self = shift;
	my $errno = shift;
	
	my $a = 'サイト登録入力エラー';
	$self->{html_title} = qq{$a};
	my $b = 'スマフォサイト,サイト登録,スマートフォン,アプリ,ドコモ,au,iphone,アンドロイド';
	$self->{html_keywords} = qq{$b};
	my $c = 'スマフォのサイト登録時にエラーとなりました';
	$self->{html_description} = qq{$c};

	&html_header($self);

print << "END_OF_HTML";
<div id="header">
<h1><a href="/" style="display: block;"><img src="/img/smftop.jpg" width=100% alt="スマフォナビ"></a></h1>
</div>
<div data-role="header">
<h2>登録完了</h2>
</div>
<a href="/">トップ</a>&gt;<a href="/regist.html">サイト登録</a>&gt;サイト登録エラー
<div data-role="content">
<center>
<img src="/img/gr_domo.gif">
</center>
サイト登録時にエラーとなりました。<br>
入力項目を確認して、再度ご登録をお願いします。<br>$errno
</div>
END_OF_HTML


	&html_footer($self);

	return 1;
}

sub _top(){
	my $self = shift;
	
	my $a = 'スマートフォンサイト登録 -スマートフォンナビ-';
	$self->{html_title} = qq{$a};
	my $b = 'サイト登録,スマートフォン,アプリ,ドコモ,au,iphone,アンドロイド';
	$self->{html_keywords} = qq{$b};
	my $c = 'スマフォナビにスマートフォンサイトを登録したい方は、こちらのサイト登録ページよりお願いします';
	$self->{html_description} = qq{$c};
	&html_header($self);
	

	my $categorystr;
	my 	$sth = $self->{dbi}->prepare(qq{ select id, name from smf_category} );
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$categorystr.=qq{<option value="$row[0]">$row[1]</option>};
	}
	
print << "END_OF_HTML";
<div id="header">
<h1><a href="/" style="display: block;"><img src="/img/smftop.jpg" width=100% alt="スマフォナビ"></a></h1>
</div>
<div data-role="header">
<h2>サイト登録</h2>
</div>
<div data-role="fieldcontain">
<form action="/regist.html"; method="post">

<label for="site">サイト名:</label>
<input type="text" name="site" id="site" value=""  />

<label for="siteurl">URL:</label>
<input type="text" name="siteurl" id="site" value=""  />

<label for="select-choice-1" class="select">カテゴリ:</label>
<select name="category" id="select-choice-1">
$categorystr
</select>

<label for="textarea">説明文:</label>
<textarea cols="40" rows="8" name="description" id="textarea"></textarea>
<fieldset data-role="controlgroup">
<input type="checkbox" name="adult" id="checkbox-1"/>
<label for="checkbox-1">アダルト含む</label>
</fieldset>
     
<button type="submit" data-transition="fade">登録</button>
</form>

</div>
注）スマートフォンに最適化されたサイトのみ登録をしてください。<br>
自薦・他薦は、問いません。<br>
PCサイトやモバイルサイトを登録された場合、スマートフォンで正常に表示されないサイトは、削除されますのでご注意ください。
END_OF_HTML
	
&html_footer($self);

	return;
}

1;