package Waao::Pages::SMFWiki;
use strict;
use base qw(Waao::Pages::Base);
#use Data::Dumper;
use Waao::Html5;
use Waao::Data;
use Waao::Utility;

sub dispatch(){
	my $self = shift;
	
	if($self->{cgi}->param('id')){
		&_wiki($self);
	}
	
	return;
}

sub _wiki(){
	my $self = shift;
	my $links_no = $self->{cgi}->param('no');
	my ($datacnt, $wikipedia) = &get_wiki($self, "", $self->{cgi}->param('id'));
	my ($datacnt, $keyworddata) = &get_keyword($self, $wikipedia->{keyword},"");
	
	my $wikiid = $self->{cgi}->param('id');
	my $keyword = $keyworddata->{keyword};
	my $a = "$keyword wikipedia スマフォナビ $wikiid";
	$a = $keyworddata->{simplewiki} if($keyworddata->{simplewiki});
	$self->{html_title} = qq{$a};
	my $b = "$keyword,プロフィール,wikipedia,生年月日,身長";
	$self->{html_keywords} = qq{$b};
	my $c = "スマートフォン専用！ 「$keyword」スマフォサイト。$wikiid ";
	$c = $keyworddata->{simplewiki} if($keyworddata->{simplewiki});
	$self->{html_description} = qq{$c};
	&html_header($self);

	if($wikipedia->{linklist}){
		my $links = $wikipedia->{linklist};
		my $str_encode = &str_encode( $keyword );
		$links =~s/\#links\_/\/$str_encode\/wiki\/$wikipedia->{rev_id}\//g;
		$links =~s/\"\>/\/\"\>/g;
		$wikipedia->{linklist} = qq{<font size=1>$links</font>};
	}
	my $wikistr;
	my @lines = split(/\n/,$wikipedia->{wikipedia});

	# 見出しごとに分割
	if($links_no){
		my $flag;
		foreach my $line (@lines){
			if( ($line=~/links_$links_no\"/) || ($line=~/links_$links_no\>/) ){
				$flag = 1;
			}elsif( $line=~/links_/ ){
				if($flag eq 1){
					last;
				}
			}
			if($flag){
				$line =~s/\|/<br>/g;
				$wikistr .= $line."\n";
			}
		}
	}else{
		foreach my $line (@lines){
			if( ($line=~/links_1\"/) || ($line=~/links_1\>/) ){
				$wikistr .= $wikipedia->{linklist};
				last unless($links_no);
				$wikistr .= $line."\n";
			}else{
				$line =~s/\|/<br>/g;
				$wikistr .= $line."\n";
			}
		}
	}

	
print << "END_OF_HTML";
<div data-role="header"> 
<h1>$keyword</h1> 
</div>
<a href="/">トップ</a>&gt;<a href="/person$keyworddata->{id}/">$keyword</a>&gt;<strong>$keyword wikipedia</strong>

<div data-role="content">
<ul data-role="listview">
<li data-role="list-divider">$keywordとは -wikipedia-</li>
<iframe src="http://ja.wikipedia.org/wiki/$keyword" height=300 width=300></iframe>
$wikistr
</ul>
</div>
END_OF_HTML

	
&html_footer($self);

	return;
}

1;