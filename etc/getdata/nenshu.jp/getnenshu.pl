#!/usr/bin/perl
# ���w�Z�@�擾�v���O����

#use strict;
use DBI;
use CGI qw( escape );
use Unicode::Japanese;
use LWP::UserAgent;
use Jcode;
use URI::Escape;

my $dsn = 'DBI:mysql:waao';
my $user = 'mysqlweb';
my $password = 'WaAoqzxe7h6yyHz';

my $dbh = DBI->connect($dsn,$user,$password,{RaiseError => 1, AutoCommit => 0});

my $file = qq{/var/www/vhosts/waao.jp/etc/getdata/nenshu.jp/20100728.txt};

open(IN, $file);
my $line_cnt;
while (my $line = <IN>){
	$line_cnt++;
	next if($line_cnt == 1);
	my @vals = split(/\t/,$line);
	my $kind = $vals[1];

eval{
	my $sth = $dbh->prepare( qq{insert into job_category ( `name` ) values (?)});
	$sth->execute($kind);
};

}
close(IN);

open(IN, $file);
my $line_cnt;
while (my $line = <IN>){
	$line_cnt++;
	next if($line_cnt == 1);
	# �،��R�[�h	�Ǝ�	��Ж�	���ϔN��	�]�ƈ���	���ϔN��	���ϋΑ��N��	�����J��
	my @vals = split(/\t/,$line);
	my $code = $vals[0];
	my $kind = $vals[1];
	my $copo = $vals[2];
	my $money = &_str_chk($vals[3]);
	my $member = &_str_chk($vals[4]);
	my $aveage = &_str_chk($vals[5]);
	my $avejob = &_str_chk($vals[6]);
	my $opdate = $vals[7];
	
	my $sth = $dbh->prepare( qq{select id from job_category where name = ? } );
	$sth->execute( $kind );
	my $job_category;
	while(my @row = $sth->fetchrow_array) {
		$job_category = $row[0];
	}
	
eval{
	my $sth = $dbh->prepare( qq{insert into job_company  ( `id`,`job_category_id`,`job_category`,`name`,`money`,`member`,`aveage`,`avejob`,`opdate` ) values (?,?,?,?,?,?,?,?,?)});
	$sth->execute($code,$job_category,$kind,$copo,$money,$member,$aveage,$avejob,$opdate);
};
	
}

close(IN);

$dbh->disconnect;

exit;

sub _str_chk(){
	my $str = shift;
	
	$str =~s/\"//g;
	$str =~s/\,//g;
	$str =~s/\s//g;

	return $str;
}

