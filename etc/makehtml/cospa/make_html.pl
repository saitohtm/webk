#!/usr/bin/perl
# スマフォページ作成処理
use lib qw(/var/www/vhosts/goo.to/etc/lib /var/www/vhosts/goo.to/lib/Waao);

use strict;
use Utility;
use DBI;
use Jcode;
use CGI qw( escape );
use Date::Simple;


# そのた
&_else_pages();

# top
&_top();

# job
&_job();

exit;

sub _job(){
	
	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-cospa/job/};
	mkdir($dirname, 0755);

	#top
	&_job_top();

	return;
}

sub _job_top(){

	my $html = &_load_tmpl("job_top.html");
	$html = &_parts_set_job($html);

	my $dbh = &_db_connect();

	&_file_output("job/index.html",$html);

	$dbh->disconnect;


	return;
}

sub _parts_set_job(){
	my $html = shift;

	my $header_top = &_load_tmpl("header_top.html");
	$html =~s/<!--HEADER_TOP-->/$header_top/g;

	my $header = &_load_tmpl("header.html");
	$html =~s/<!--HEADER-->/$header/g;

	my $jobmenu = &_load_tmpl("jobmenu.html");
	$html =~s/<!--TOPMENU-->/$jobmenu/g;

	my $topmenu = &_load_tmpl("body.html");
	$html =~s/<!--BODY-->/$topmenu/g;

	my $jobslider = &_load_tmpl("jobslider.html");
	$html =~s/<!--SLIDER-->/$jobslider/g;

	my $footer = &_load_tmpl("footer.html");
	$html =~s/<!--FOOTER-->/$footer/g;


	return $html;
}

sub _else_pages(){

	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-cospa/privacy/};
	mkdir($dirname, 0755);
	my $html = &_load_tmpl("privacy.html");
	$html = &_parts_set($html);
	&_file_output("privacy/index.html",$html);

	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-cospa/about/};
	mkdir($dirname, 0755);
	my $html = &_load_tmpl("about.html");
	$html = &_parts_set($html);
	&_file_output("about/index.html",$html);

	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-cospa/faq/};
	mkdir($dirname, 0755);
	my $html = &_load_tmpl("faq.html");
	$html = &_parts_set($html);
	&_file_output("faq/index.html",$html);

	my $dirname = qq{/var/www/vhosts/goo.to/httpdocs-cospa/contact/};
	mkdir($dirname, 0755);
	my $html = &_load_tmpl("contact.html");
	$html = &_parts_set($html);
	&_file_output("contact/index.html",$html);

	return;
}

sub _top(){

	my $html = &_load_tmpl("top.html");
	$html = &_parts_set($html);

	my $dbh = &_db_connect();

	&_file_output("index.html",$html);

	$dbh->disconnect;

	return;
}


sub _parts_set(){
	my $html = shift;

	my $header_top = &_load_tmpl("header_top.html");
	$html =~s/<!--HEADER_TOP-->/$header_top/g;

	my $header = &_load_tmpl("header.html");
	$html =~s/<!--HEADER-->/$header/g;

	my $topmenu = &_load_tmpl("topmenu.html");
	$html =~s/<!--TOPMENU-->/$topmenu/g;

	my $topmenu = &_load_tmpl("body.html");
	$html =~s/<!--BODY-->/$topmenu/g;

	my $topslider = &_load_tmpl("topslider.html");
	$html =~s/<!--SLIDER-->/$topslider/g;

	my $footer = &_load_tmpl("footer.html");
	$html =~s/<!--FOOTER-->/$footer/g;

	return $html;
}

sub _file_output(){
	my $filename = shift;
	my $html = shift;
	
	my $file = qq{/var/www/vhosts/goo.to/httpdocs-cospa/}.$filename;
print $file."\n";	
	open(OUT,"> $file") || die('error');
	print OUT "$html";
	close(OUT);

	return;
}


sub _load_tmpl(){
	my $tmpl = shift;
	
my $file = qq{/var/www/vhosts/goo.to/etc/makehtml/cospa/tmpl/$tmpl};

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
	$html =~s/<!--DATE-->/$ymd/ig;
	return $html;
}

sub _db_connect(){

	my $dsn = 'DBI:mysql:waao';
	my $user = 'mysqlweb';
	my $password = 'WaAoqzxe7h6yyHz';
	my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 1, AutoCommit => 0});

	return $dbh;
}

sub price_dsp(){
	my $price = shift;

	1 while $price =~ s/(.*\d)(\d\d\d)/$1,$2/;	

	return $price;
}

