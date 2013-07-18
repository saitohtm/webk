package AppDevDataController;

use Exporter;
@ISA = (Exporter);
@EXPORT = qw(app_dev_company_data);

use Date::Simple;

sub app_dev_company_data(){
	my $dbh = shift;
	my $data = shift;
	return unless($data->{email});
	return unless($data->{pass});

	# データ有無
	my $flag;

	my $sth = $dbh->prepare(qq{select id,
	                                  name,
	                                  tanto,
	                                  address,
	                                  memo,
	                                  image
	 from app_dev_company where email = ? and pass = ? });
	$sth->execute($data->{email},$data->{pass});
	while(my @row = $sth->fetchrow_array) {
		$flag = 1;
		$data->{id} = $row[0];
		$data->{name} = $row[1] unless($data->{name});
		$data->{tanto} = $row[2] unless($data->{tanto});
		$data->{address} = $row[3] unless($data->{address});
		$data->{memo} = $row[4] unless($data->{memo});
		$data->{image} = $row[5] unless($data->{image});
	}

	if($flag){
		# 更新
eval{
		my $sth = $dbh->prepare(qq{update app_dev_company set 
				    company_type=?,
				    name=?,
				    tanto=?,
				    pref_id=?,
				    address=?,
				    email=?,
				    pass=?,
				    memo=?,
				    image=?		
                    where id = ? });
		$sth->execute(
					$data->{id},
					$data->{company_type},
					$data->{name},
					$data->{tanto},
					$data->{pref_id},
					$data->{address},
					$data->{memo},
					$data->{image}
						);
};

	}else{
		# 追加
eval{
		my $sth = $dbh->prepare(qq{insert into app_dev_company (
				    `company_type`,
				    `name`,
				    `tanto`,
				    `pref_id`,
				    `address`,
				    `email`,
				    `pass`,
				    `memo`,
				    `image`) 
				values (?,?,?,?,?,?,?,?,?)} );
		$sth->execute(
					$data->{company_type},
					$data->{name},
					$data->{tanto},
					$data->{pref_id},
					$data->{address},
					$data->{email},
					$data->{pass},
					$data->{memo},
					$data->{image}
						);
};
	}

	return;
}

1;