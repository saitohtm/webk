package Waao::Data;
use Exporter;
use Jcode;

@ISA = (Exporter);
@EXPORT = qw(get_wiki get_keyword get_photo get_uwasa get_bbs get_qanda eva_photo eva_uwasa eva_smf_site cnt_keyword);

sub get_wiki(){
	my $self    = shift;
	my $keyword = shift;
	my $wikiid  = shift;
	
	return if(!$keyword && !$wikiid);

	my $sth;
	my $datacnt;
	my $wikipedia;
	if($wikiid){
		$sth = $self->{dbi}->prepare(qq{ select rev_id, wikipedia, linklist, person, sex, birthday,keyword from wikipedia where rev_id = ? limit 1} );
		$sth->execute($wikiid);
	}else{
		$keyword = Jcode->new($keyword, 'sjis')->utf8;
#		$sth = $self->{dbi}->prepare(qq{ select rev_id, wikipedia, linklist, person, sex, birthday,keyword from wikipedia where keyword = ? order by page_namespace limit 1} );
		$sth = $self->{dbi}->prepare(qq{ select rev_id, wikipedia, linklist, person, sex, birthday,keyword from wikipedia where keyword = ? limit 1} );
		$sth->execute($keyword);
	}	
	while(my @row = $sth->fetchrow_array) {
		$datacnt++;
		($wikipedia->{rev_id}, $wikipedia->{wikipedia}, $wikipedia->{linklist}, $wikipedia->{person}, $wikipedia->{sex}, $wikipedia->{birthday}, $wikipedia->{keyword}) = @row;
	}

	# データがない場合にkeywordを検討する
	if(!$datacnt || !$wikipedia->{wikipedia}){
		
		if($keyword=~/(.*)\_\((.*)\)/){
			$keyword = $1;
			$sth = $self->{dbi}->prepare(qq{ select rev_id, wikipedia, linklist, person, sex, birthday from wikipedia where keyword = ? limit 1} );
			$sth->execute($keyword);
			while(my @row = $sth->fetchrow_array) {
				$datacnt++;
				($wikipedia->{rev_id}, $wikipedia->{wikipedia}, $wikipedia->{linklist}, $wikipedia->{person}, $wikipedia->{sex}, $wikipedia->{birthday}) = @row;
			}
		}
	}
 
	return($datacnt,$wikipedia);
}

sub get_keyword(){
	my $self    = shift;
	my $keyword = shift;
	my $keywordid  = shift;

	return if(!$keyword && !$keywordid);

	my $sth;
	my $datacnt;
	my $keyworddata;

	if($keywordid){
		$sth = $self->{dbi}->prepare(qq{ select id, keyword, wiki_id, sex, birthday, blood, birth_name, cnt, simplewiki, yahookeyword, blogurl, googlekeyword,person, av, artist, model, ana, inital, genre, twitterurl,twitgenre,photo from keyword where id = ? limit 1} );
		$sth->execute( $keywordid );
	}else{
		$sth = $self->{dbi}->prepare(qq{ select id, keyword, wiki_id, sex, birthday, blood, birth_name, cnt, simplewiki, yahookeyword, blogurl, googlekeyword,person, av, artist, model, ana, inital, genre, twitterurl,twitgenre,photo from keyword where keyword = ? limit 1} );
		$sth->execute( $keyword );
	}
	while(my @row = $sth->fetchrow_array) {
		$datacnt++;
		($keyworddata->{id}, $keyworddata->{keyword}, $keyworddata->{wiki_id}, $keyworddata->{sex}, $keyworddata->{birthday}, $keyworddata->{blood}, $keyworddata->{birth_name}, $keyworddata->{cnt}, $keyworddata->{simplewiki}, $keyworddata->{yahookeyword}, $keyworddata->{blogurl}, $keyworddata->{googlekeyword},$keyworddata->{person}, $keyworddata->{av}, $keyworddata->{artist}, $keyworddata->{model}, $keyworddata->{ana}, $keyworddata->{inital}, $keyworddata->{genre}, $keyworddata->{twitterurl}, $keyworddata->{twitgenre}, $keyworddata->{photo}) = @row;
	}
	$keyworddata->{keyword} = $keyword if($keyword);

	# プロフィールフラグ（person）
	if($keyworddata->{wiki_id}){
		if($keyworddata->{birthday}){
			$keyworddata->{person} = 1 unless($keyworddata->{person});
		}
	}

	return($datacnt,$keyworddata);
}

sub get_photo(){
	my $self = shift;
	my $keywordid = shift;
	my $photoid = shift;

	return unless($keywordid);

	my $sth;
	my $datacnt;
	my $photodata;

	if($photoid){
		$sth = $self->{dbi}->prepare(qq{ select id, url, key1, key2, key3, key4, key5, good, bad, backurl, yahoo, fullurl from photo where id = ?  limit 1} );
		$sth->execute( $photoid );
	}else{
		$sth = $self->{dbi}->prepare(qq{ select id, url, key1, key2, key3, key4, key5, good, bad, backurl, yahoo, fullurl from photo where keywordid = ? order by good desc limit 1} );
		$sth->execute( $keywordid );
	}
	my $datacnt;
	while(my @row = $sth->fetchrow_array) {
		$datacnt++;
		($photodata->{id}, $photodata->{url}, $photodata->{key1}, $photodata->{key2}, $photodata->{key3}, $photodata->{key4}, $photodata->{key5}, $photodata->{good}, $photodata->{bad}, $photodata->{backurl}, $photodata->{yahoo}, $photodata->{fullurl}) = @row;
	}
	
	return($datacnt,$photodata);
}

sub get_uwasa(){
	my $self    = shift;
	my $uwasaid = shift;

	return if(!$uwasaid );

	my $sth;
	my $datacnt;
	my $uwasadata;

	$sth = $self->{dbi}->prepare(qq{select id, keyperson, type,	point from keyword_recomend where id = ? limit 1} );
	$sth->execute( $uwasaid );
	while(my @row = $sth->fetchrow_array) {
		$datacnt++;
		($uwasadata->{id}, $uwasadata->{keyperson}, $uwasadata->{type}, $uwasadata->{point}) = @row;
	}

	return($datacnt,$uwasadata);
}

sub get_bbs(){
	my $self    = shift;
	my $bbsid = shift;

	return if(!$bbsid );

	my $sth;
	my $datacnt;
	my $bbsdata;

	$sth = $self->{dbi}->prepare(qq{select id, bbs, point, sex, age, nickname from bbs where id = ? limit 1} );
	$sth->execute( $bbsid );
	while(my @row = $sth->fetchrow_array) {
		$datacnt++;
		($bbsdata->{id}, $bbsdata->{bbs}, $bbsdata->{point}, $bbsdata->{sex}, $bbsdata->{age}, $bbsdata->{nickname}) = @row;
	}

	return($datacnt,$bbsdata);
}

sub get_qanda(){
	my $self    = shift;
	my $qandaid = shift;

	return if(!$qandaid );

	my $sth;
	my $datacnt;
	my $qandadata;

	$sth = $self->{dbi}->prepare(qq{select id, question, bestanswer, url from qanda where id = ? limit 1} );
	$sth->execute( $qandaid );
	while(my @row = $sth->fetchrow_array) {
		$datacnt++;
		($qandadata->{id}, $qandadata->{question}, $qandadata->{bestanswer}, $qandadata->{url}) = @row;
	}

	return($datacnt,$qandadata);
}

sub eva_photo(){
	my $self = shift;
	my $photoid = shift;
	my $good = shift;
	my $bad = shift;

	return if(!$self->{real_mobile} && !$self->{my_device});
eval{
	if($good){
		$sth = $self->{dbi}->prepare(qq{ update photo set good = good + 1 where id = ? limit 1} );
		$sth->execute( $photoid );
		if( $self->{my_device} ){
			$sth = $self->{dbi}->prepare(qq{ update photo set good = good + 10 where id = ? limit 1} );
			$sth->execute( $photoid );
		}
	}elsif($bad){
		$sth = $self->{dbi}->prepare(qq{ update photo set good = good - 1 where id = ? limit 1} );
		$sth->execute( $photoid );
		$sth = $self->{dbi}->prepare(qq{ update photo set bad = bad + 1 where id = ? limit 1} );
		$sth->execute( $photoid );
		if( $self->{my_device} ){
			$sth = $self->{dbi}->prepare(qq{ update photo set good = good - 10 where id = ? limit 1} );
			$sth->execute( $photoid );
		}
	}
};	
	return;
}

sub eva_uwasa(){
	my $self = shift;
	my $uwasaid = shift;
	my $good = shift;
	my $bad = shift;

	return unless($self->{real_mobile});

eval{
	if($good){
		$sth = $self->{dbi}->prepare(qq{ update keyword_recomend set point = point + 1 where id = ? limit 1} );
		$sth->execute( $uwasaid );
	}elsif($bad){
		$sth = $self->{dbi}->prepare(qq{ update keyword_recomend set point = point - 1 where id = ? limit 1} );
		$sth->execute( $uwasaid );
		if( $self->{my_device} ){
			$sth = $self->{dbi}->prepare(qq{ update keyword_recomend set point = -10 where id = ? limit 1} );
			$sth->execute( $uwasaid );
		}
	}
};	
	return;
}

sub eva_smf_site(){
	my $self = shift;
	my $siteid = shift;
	my $good = shift;
	my $bad = shift;

#	return unless($self->{real_mobile});

eval{
	if($good){
		$sth = $self->{dbi}->prepare(qq{ update smf_site set good = good + 1 where id = ? limit 1} );
		$sth->execute( $siteid );
	}elsif($bad){
		$sth = $self->{dbi}->prepare(qq{ update smf_site set good = good - 1 where id = ? limit 1} );
		$sth->execute( $siteid );
	}
};	
	return;
}

sub cnt_keyword(){
	my $self = shift;
	my $id = shift;
	
eval{
	my 	$sth = $self->{dbi}->prepare(qq{ update `keyword` set cnt = cnt + 1 where id = ? limit 1} );
	$sth->execute($id);
};
	return;
}
1;
