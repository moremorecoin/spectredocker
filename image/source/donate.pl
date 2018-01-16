#!/usr/bin/perl
use strict;
if(@ARGV<2)
{
    print "$0 donate_portion_of_staking donate_to_address [wallet_pass]\n";
    exit(0);
}
my $donate_portion=$ARGV[0];
my $donate_address=$ARGV[1];
my $wallet_pass=$ARGV[2];

if ($donate_portion<=0) #donation portion is less than 0
{
    print "donate_portion <= 0\n";
    exit(0);
}

my $cmd='spectrecoind -conf=/root/configure.conf';
my @staking_incomes = `$cmd listtransactions |egrep "account|category|amount|timereceived"|grep -A3 account`;
my $current_time=time();
for(my $i=0;$i<@staking_incomes;$i+=4)
{
   $staking_incomes[$i+3]=~/"timereceived" : (\d+)/;
   my $income_time=$1;
   if($current_time - $income_time < 86400) #today's staking income
   {
       my $account='';
       my $amount=0;
       #print "Found staking incomes, received time $income_time\n";

       if($staking_incomes[$i]=~/"account" : "(.*)",/)
       {
           $account=$1;
       }
       if($staking_incomes[$i+2]=~/"amount" : (.*),/)
       {
           $amount=$1;
       }
       next if $amount<=0;
       my $coin=$amount*$donate_portion;
       if($wallet_pass)
       {
           `$cmd walletlock`;
       `$cmd walletpassphrase '$wallet_pass' 60`; #unlock for donation
       }
       `$cmd sendtostealthaddress $donate_address $coin Donation Donation`;
       #print "$cmd sendtostealthaddress $donate_address $coin Donation Donation\n";
       if($wallet_pass)
       {
           `$cmd walletlock`;
           `$cmd walletpassphrase '$wallet_pass' 86400 true`; #unlock for staking
       }
   }
}
