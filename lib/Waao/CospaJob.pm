package Waao::CospaJob;

use lib qw(/var/www/vhosts/waao.jp/etc/lib /var/www/vhosts/waao.jp/lib/Waao);

use Utility;
use DBI;
use CGI;
use Cache::Memcached;
use Waao::Api;
use XML::Simple;
use LWP::Simple;
use Jcode;
use CGI qw( escape );
use Date::Simple;


sub dispatch_regist(){
	my $self = shift;

	if($self->{cgi}->param('joburl')){
		&_regist($self);
	}else{
		&_regist_top($self);
	}

	return;
}

sub _regist(){
	my $self = shift;

	my $html;
	$html = &load_tmpl("cospajob","regist_end.html");
	$html = &_parts_set($html);

	if($self->{cgi}->param('jobtitle') && 
	   $self->{cgi}->param('jobplace') && 
	   $self->{cgi}->param('jobcontact') && 
	   $self->{cgi}->param('jobbody') && 
	   $self->{cgi}->param('company') && 
	   $self->{cgi}->param('companyurl') && 
	   $self->{cgi}->param('companyemail')
	   ){
		# エラー処理
		$html = &load_tmpl("cospajob","regist_err.html");
		$html = &_parts_set($html);

print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

		return;


	}else{

eval{
	my $sth = $self->{dbi}->prepare(qq{insert into cospa_job 
	                                  (`title`,
	                                   `genre`,
	                                   `place`,
	                                   `contact`,
	                                   `body`,
	                                   `url`,
	                                   `price`,
	                                   `type1`,
	                                   `type2`,
	                                   `type3`,
	                                   `type4`,
	                                   `station`,
	                                   `company`,
	                                   `companyurl`,
	                                   `companyfacebook`,
	                                   `companylogo`,
	                                   `companyemail`
	                                  ) 
								   values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)});
	$sth->execute(
	              $self->{cgi}->param('jobtitle'),
	              $self->{cgi}->param('jobgenre'),
	              $self->{cgi}->param('jobplace'),
	              $self->{cgi}->param('jobcontact'),
	              $self->{cgi}->param('jobbody'),
	              $self->{cgi}->param('joburl'),
	              $self->{cgi}->param('jobprice'),
	              $self->{cgi}->param('jobtype1'),
	              $self->{cgi}->param('jobtype2'),
	              $self->{cgi}->param('jobtype3'),
	              $self->{cgi}->param('jobtype4'),
	              $self->{cgi}->param('jobstation'),
	              $self->{cgi}->param('company'),
	              $self->{cgi}->param('companyurl'),
	              $self->{cgi}->param('companyfacebook'),
	              $self->{cgi}->param('companylogo'),
	              $self->{cgi}->param('companyemail')
	              );
};

	}
	
	
print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}


sub _regist_top(){
	my $self = shift;

	my $html;
	$html = &load_tmpl("cospajob","regist.html");
	$html = &_parts_set($html);

	# カテゴリ取得
	my $catelist;
	my $sth = $self->{dbi}->prepare(qq{select id,name from cospa_job_genre order by id } );
	$sth->execute();
	while(my @row = $sth->fetchrow_array) {
		$catelist .= qq{<option value=$row[0]>$row[1]</option>};
	}
	$html =~s/<!--JOB_GENRE-->/$catelist/g;
	
print << "END_OF_HTML";
Content-type: text/html; charset=UTF-8

$html
END_OF_HTML

	return;
}

sub _parts_set(){
	my $html = shift;

	# meta
	my $meta = &load_tmpl("cospajob","meta.html");
	# header
	my $header = &load_tmpl("cospajob","header.html");
	# footer
	my $footer = &load_tmpl("cospajob","footer.html");
	# slider
	my $side_free = &load_tmpl("cospajob","side_free.html");
	$html =~s/<!--SIDE_FREE-->/$side_free/g;
	my $catelist = &load_tmpl("cospajob","cate_list.html");
	$html =~s/<!--CATELIST-->/$catelist/g;

	$html =~s/<!--META-->/$meta/g;
	$html =~s/<!--HEADER-->/$header/g;
	$html =~s/<!--FOOTER-->/$footer/g;

	return $html;
}

sub new(){
	my $class = shift;
	my $q = new CGI;

	my $self={
			'mem' => &memcache(),
			'dbi' => &db_connect(),
			'cgi' => $q
			};
	
	return bless $self, $class;
}

sub DESTROY{
	my $self = shift;

	$self->{db}->disconnect if($self->{db});

	return;
}


1;