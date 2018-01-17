#!/usr/bin/perl
use strict;
$| = 1;
my $walletcmd='spectrecoind';
while(1)
{
    print get_recent_info(600);
    sleep(600); #print status report every 10 minutes
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

    my $staking_status = `$walletcmd getstakinginfo | grep staking`;
    $staking_status=~/"staking" : (\S+),/;
    $ret .= "Staking=$1";

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


