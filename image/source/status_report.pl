#!/usr/bin/perl
use MIME::Base64;
use JSON;
use POSIX 'strftime';
use strict;
$| = 1;
my $walletcmd=$ENV{WALLETCMD};
my $configure_folder=$ENV{CONFIGUREFOLDER};
my $configure_file=$ENV{CONFIGUREFILE};
my $currency=$ENV{CURRENCY};
my $backup_folder="$configure_folder/backup";
my $backup_time_file="$configure_folder/backup/time";
my $report_status_freq_in_sec=$ENV{REPORT_STATUS_FREQ_IN_SEC};
my $backup_wallet_freq_in_sec=$ENV{BACKUP_WALLET_FREQ_IN_SEC};

while(1)
{
    my $current_info = get_recent_info($report_status_freq_in_sec);
    print $current_info;
    $current_info=~/^(\d+)/;
    my $current_time=$1;

    my $last_backup_time=0;
    if(open(TF,"$backup_time_file"))
    {
        $last_backup_time=<TF>;
        chomp $last_backup_time;
        close TF;
    }

    if( $current_time-$last_backup_time >= $backup_wallet_freq_in_sec ) #time to backup wallet file
    {
        my $review=get_recent_info( $backup_wallet_freq_in_sec );
        if ( $ENV{Donate_portion_of_staking} > 0 && $ENV{Donate_portion_of_staking} <=1 )
        {
            my $total_staking=0;
            my @col = split(", ",$review);
            for(my $i=0;$i<@col-1;++$i)
            {
                if($col[$i] eq 'generate')
                {
                    $col[$i+1]=~/(\d+)\]/;
                    $total_staking += $1;
                }
            }
            print "Staking generated $total_staking $currency in the past $backup_wallet_freq_in_sec seconds\n";
            send_donation($total_staking*$ENV{Donate_portion_of_staking});
        }
        backup_wallet($review);
        open(TF,">$backup_time_file") || die "ERROR: Can't write to $backup_time_file\n";
        print TF "$current_time";
        close TF;
    }

    sleep($report_status_freq_in_sec); #print status report every 10 minutes
}

sub sendmail
{
    my ($text,$fn)=@_;
    my $filename=$fn;
    my $template=$fn.".email";
    $filename=~s/^.*\///;

    if (!$ENV{mailjet_api_key} || !$ENV{mailjet_secret_key})
    {
        print "Cann't backup wallet to email because you haven't set mailjet_api_key or mailjet_secret_key\n";
        return;
    }

    my $apikey=$ENV{mailjet_api_key};
    my $secretkey=$ENV{mailjet_secret_key};
    #my $text='';
    my $buf='';
    my $content='';
    open(FILE,"$fn") || return "Can not open file!";
    while (read(FILE, $buf, 60*57))
    {
        $content .= encode_base64($buf);
    }
    close FILE;

    my %json;
    $json{FromEmail}=$ENV{mail_to};
    $json{FromName}=$ENV{mail_sender_name};
    $json{Subject}=$ENV{mail_subject};
    $json{"Text-part"}=$text;
    $json{"Html-part"}='';
    my @emails=split(",",$ENV{mail_to});
    my $index=0;
    foreach(@emails)
    {
        $json{Recipients}[$index++]{Email}=$_;
    }

    $json{Attachments}[0]{"Content-type"}="application/octet-stream";
    $json{Attachments}[0]{"Filename"}=$filename;
    $json{Attachments}[0]{"content"}=$content;
    my $json_text = encode_json(\%json);
    open(OUT,">$template") || return "Can't write to file $template";
    print OUT $json_text;
    close OUT;

    my $cmd= "curl -s -X POST --user '$apikey:$secretkey' https://api.mailjet.com/v3/send -H 'Content-Type: application/json' -d \@$template";
    system("$cmd");
    unlink "$template";
}

sub backup_wallet
{
    my ($text)=@_;
    if( ! -e "$backup_folder")
    {
        `mkdir -p $backup_folder`;
    }
    my $fn="wallet.dat"; #strftime '%Y%m%d-%H%M%S-w.dat', localtime;
    if($ENV{wallet_backup_filename})
    {
        $fn=$ENV{wallet_backup_filename};
    }
    `$walletcmd backupwallet $backup_folder/$fn`;
    sendmail($text,"$backup_folder/$fn");
}
sub send_donation
{
    my ($value)=@_;
    
    return if($value<=0);
    if($ENV{PHRASE}) #entrypted wallet
    {
        `$walletcmd walletlock`;
        `$walletcmd walletpassphrase '$ENV{PHRASE}' 10`; #unlock for donation
    }
    `$walletcmd $ENV{Donate_command} $ENV{Donate_address} $value Donation Donation`;
    if($ENV{PHRASE})
    {
        `$walletcmd walletlock`;
        `$walletcmd walletpassphrase '$ENV{PHRASE}' 315360000 true`; #set back to staking state
    }
}

#return [timestamp, total balance, staking status, [timestamp1, account1, type1, amount1], [timestamp2, account2, type2, amount2] ...]
sub get_recent_info 
{
    my ($period)=@_; #one hour? one day? in second
    my $ret;

    my $current_time=time();
    $ret .= "$current_time, ";

    my $balance = `$walletcmd getbalance`;
    chomp $balance;
    $ret .= "Balance=$balance, ";

    my @staking_status = `$walletcmd getstakinginfo | egrep "staking|expectedtime"`;
    $staking_status[0]=~/"staking" : (\S+),/;
    $ret .= "Staking=$1";
    $staking_status[1]=~/"expectedtime" : (\d+)/;
    $ret .= ", Expetedtime=$1";

    my @recent_transaction = `$walletcmd listtransactions |egrep "account|category|amount|timereceived"|grep -A3 account`;
    for(my $i=0;$i<@recent_transaction;$i+=4)
    {
        $recent_transaction[$i+3]=~/"timereceived" : (\d+)/;
        my $transaction_time=$1;
        if($current_time - $transaction_time < $period) #within the time frame
        {
            my $account='';
            if($recent_transaction[$i]=~/"account" : "(.*)",/)
            {    
                $account=$1;
            }

            my $category=0;
            if($recent_transaction[$i+1]=~/"category" : "(.*)",/)
            {
                $category=$1;
            }

            my $amount=0;
            if($recent_transaction[$i+2]=~/"amount" : (.*),/)
            {
                $amount=$1;
            }
            
            $ret .= ", [$transaction_time, $account, $category, $amount]";
        }
    }
    return $ret."\n";
}


