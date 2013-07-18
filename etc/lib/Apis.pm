package Apis;

use Exporter;
@ISA = (Exporter);
@EXPORT = qw(get_qanda get_photo get_news);

use CGI;
use LWP;
use HTTP::Request;
use XML::Simple;
use Unicode::Japanese;
use LWP::UserAgent;
use Jcode;
use URI::Escape;

sub get_photo(){
	my $dbh = shift;
	my $keyword = shift;
	my $keyword_id = shift;

	&_get_photo($dbh,$keyword,"l",$keyword_id);
	&_get_photo($dbh,$keyword,"all",$keyword_id);
##	&_get_photo($dbh,$keyword,"ll");

	return;
}

sub _get_photo(){
	my $dbh = shift;
	my $keyword = shift;
	my $size = shift;
	my $keyword_id = shift;

print "keyword:$keyword\n";
	# naver
	my $dl_url = qq{http://search.naver.jp/image?sm=tab_hty.image&q=$keyword&t_size=2&s=1&order=rel&o_fc=off&o_sf=0&o_sz=$size};
	my $get_url = `GET "$dl_url"`;
	
	$get_url =~s/</\n</g;
	my @lines = split(/\n/,$get_url);
	foreach my $line (@lines){
		if($line=~/<img width(.*)alt=\"(.*)\" title(.*)src=\"(.*)\" orgsrc(.*)/){
			my $name = $2;
			my $url = $4;
			my $original  = uri_unescape($url);
			if($original=~/(.*)\/http(.*)\/r\.270x0/){
				$original = qq{http}.$2;
			}elsif($original=~/(.*)\/http(.*)\/r\.150x0/){
				$original = qq{http}.$2;
			}elsif($original=~/(.*)\/http(.*)\/r\.160x140/){
				$original = qq{http}.$2;
			}elsif($original=~/(.*)\/http(.*)\/r\.80x80/){
				$original = qq{http}.$2;
			}
		next if($original =~/shopping\.c\.yimg\.jp/);
		next if($original =~/blogs\.yahoo\.co\.jp/);
		next if($original =~/jjgirls\.com/);
			
		my $head_url = `HEAD "$original"`;
		my @heads = split(/\n/,$head_url);
		foreach my $head (@heads){
#print "$head <br>";
			if($head =~/Content-Type: image(.*)/){
print "AAAAAAAAAAAA $original <br>";
				if($original=~/fc2/){
				}else{
#					$url = $original;
				}
			}
		}
		
		&_photo_data_ins($dbh,$keyword,$name,$url,$original,$keyword_id);
print "NAME:$name<br/>\n";
print "URL:$url<br/>\n";
print "naver:<img src=$url><br/>\n";
#print "naver:<img src=$original><br/>\n";
		}
	}

	return;
}
sub _photo_data_ins(){
	my $dbh = shift;
	my $keyword = shift;
	my $summary = shift;
	my $url = shift;
	my $backurl = shift;
	my $keyword_id = shift;

	# keyword 情報取得
    unless($keyword_id){
		my $sth = $dbh->prepare(qq{select id from keyword where keyword = ?});
		$sth->execute($keyword);
		while(my @row = $sth->fetchrow_array) {
			$keyword_id = $row[0];
		}
	}

eval{
	unless($keyword_id){
		my $sth = $dbh->prepare(qq{insert into keyword (`keyword`) values(?)});
		$sth->execute($keyword);
		$keyword_id = $sth->{mysql_insertid}
	}
};
	
eval{
	my $sth = $dbh->prepare( qq{ insert into photo (`keywordid`,`url`,`keyword`,`backurl`,`fullurl`,`title`,`good`) values(?,?,?,?,?,?,50)} );
	$sth->execute($keyword_id,$url,$keyword,$backurl,$backurl,$summary);
};	

	return;
}
sub get_qanda(){
	my $dbh = shift;
	my $keyword = shift;
	my $category_id = shift;
	my $keyword_id = shift;

	my $data;
	
	my $url = qq{http://chiebukuro.yahooapis.jp/Chiebukuro/V1/questionSearch?appid=goooooto&query=$keyword&condition=solved&categoryid=$category_id};

    my $ua = new LWP::UserAgent;
    my $req = HTTP::Request->new(GET=>"$url");
    my $res = $ua->request($req);
    $responseXML = $res->content;
    my $xmlSimple = new XML::Simple;
    my $doc = $xmlSimple->XMLin($responseXML);
    foreach my $site (@{$doc->{'Result'}->{'Question'}}) {
    	$data->{id} = $site->{'Id'};
    	$data->{url} = $site->{'Url'};
    	$data->{content} = $site->{'Content'};
    	$data->{bestanswer} = $site->{'BestAnswer'};
    	$data->{categorypath} = $site->{'CategoryPath'};
    	$data->{categoryid} = $site->{'CategoryIdPath'};
    	$data->{solvddate} = $site->{'SolvedDate'};
print "$data->{content} <br>";
print "$data->{bestanswer} <br>";
print "$data->{url} <br>";
print "$data->{id} <br>";
    	&_qanda_data_ins($dbh,$keyword,$data,$keyword_id);
    }
	return;
}

sub _qanda_data_ins(){
	my $dbh = shift;
	my $keyword = shift;
	my $data = shift;
	my $keyword_id = shift;

	# keyword 情報取得
    unless($keyword_id){
		my $sth = $dbh->prepare(qq{select id from keyword where keyword = ?});
		$sth->execute($keyword);
		while(my @row = $sth->fetchrow_array) {
			$keyword_id = $row[0];
		}
	}
	
eval{
	unless($keyword_id){
		my $sth = $dbh->prepare(qq{insert into keyword (`keyword`) values(?)});
		$sth->execute($keyword);
		$keyword_id = $sth->{mysql_insertid}
	}
};

	
eval{
	my $sth = $dbh->prepare( qq{ insert into qanda (`keywordid`,`question`,`bestanswer`,`url`,`question_id`,`keyword`,`condition`) values(?,?,?,?,?,?,1)} );
	$sth->execute($keyword_id,$data->{content},$data->{bestanswer}, $data->{url}, $data->{id}, $keyword);
	print "$keyword_id <br>";
	print $sth->{mysql_insertid}."BBBB<br>";
};	
	return;
}

sub get_news(){
	my $dbh = shift;
	my $keyword = shift;
	my $keyword_id = shift;
	
	my $data;
	my $url = qq{http://news.yahooapis.jp/NewsWebService/V2/topics?appid=goooooto&sort=datetime&query=$keyword};

print $url."<br>";
    my $ua = new LWP::UserAgent;
    my $req = HTTP::Request->new(GET=>"$url");
    my $res = $ua->request($req);
    $responseXML = $res->content;
    my $xmlSimple = new XML::Simple;
    my $doc = $xmlSimple->XMLin($responseXML);

#use Data::Dumper;
#print Dumper($doc);

    foreach my $site (@{$doc->{'Result'}}) {
#    	next unless($site->{'Title'});
    	$data->{id} = $site->{'HeadlineId'} if(ref($site->{'HeadlineId'}) ne "HASH");
    	$data->{datetime} = $site->{'DateTime'} if(ref($site->{'DateTime'}) ne "HASH");
    	$data->{keyword} = $site->{'Keyword'} if(ref($site->{'Keyword'}) ne "HASH");
    	$data->{word} = $site->{'Word'} if(ref($site->{'Word'}) ne "HASH");
    	$data->{title} = $site->{'Title'} if(ref($site->{'Title'}) ne "HASH");
    	$data->{overview} = $site->{'Overview'} if(ref($site->{'Overview'}) ne "HASH");
    	$data->{url} = $site->{'Url'} if(ref($site->{'Url'}) ne "HASH");
    	$data->{smarturl} = $site->{'SmartphoneUrl'} if(ref($site->{'SmartphoneUrl'}) ne "HASH");
    	&_news_data_ins($dbh,$keyword,$data,$keyword_id);
    }

	return;
}

sub _news_data_ins(){
	my $dbh = shift;
	my $keyword = shift;
	my $data = shift;
	my $keyword_id = shift;
print "AAAAAAAAAAAA";
	print "$keyword <br>";

	# keyword 情報取得
	unless($keyword_id){
		my $sth = $dbh->prepare(qq{select id from keyword where keyword = ?});
		$sth->execute($keyword);
		while(my @row = $sth->fetchrow_array) {
			$keyword_id = $row[0];
		}
	}
eval{
	unless($keyword_id){
		my $sth = $dbh->prepare(qq{insert into keyword (`keyword`) values(?)});
		$sth->execute($keyword);
		$keyword_id = $sth->{mysql_insertid}
	}
};

	print "$keyword_id <br>";
	print "$data->{title} <br>";
	print "$data->{overview} <br>";

	
eval{
	my $sth = $dbh->prepare( qq{ insert into keyword_news (`keywordid`,`keyword`,`instime`,`keylist`,`wordlist`,`title`,`overview`,`url`,`smarturl`) values(?,?,?,?,?,?,?,?,?)} );
	$sth->execute($keyword_id,$keyword,$data->{datetime},$data->{keyword}, $data->{word}, $data->{title}, $data->{overview},$data->{url},$data->{smarturl});
	print $sth->{mysql_insertid}."BBBB<br>";
};	
	return;
}

