package Waao::Mail;
use Net::SMTP;
use Exporter;
@ISA = (Exporter);
@EXPORT = qw(send_mail);


sub send_mail(){
	my $self = shift;
	my $mailto = shift;
	my $subject = shift;
	my $msg = shift;
	
	my $from = 'info@goo.to';
#	$subject = jcode($subject)->mime_encode();

	#メールのヘッダーを構築
my $header = << "MAILHEADER";
From: $from
To: $mailto
Subject: $subject
Mime-Version: 1.0
Content-Type: text/plain; charset = "ISO-2022-JP"
Content-Transfer-Encoding: 7bit
MAILHEADER


#メール本文
my $message = << "__HERE__" ;
$msg
__HERE__

	#文字コードをJISに変換
#	$message = jcode($message,'euc')->jis;

	my $smtp = Net::SMTP->new('localhost');
	$smtp->mail($from);
	$smtp->to($mailto);
	#$smtp->bcc(@mail_bcc);
	$smtp->data();
	$smtp->datasend("$header\n");
	$smtp->datasend("$message\n");
	$smtp->dataend();
	$smtp->quit;
	
	return;
}
