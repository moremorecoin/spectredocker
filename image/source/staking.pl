#!/usr/bin/perl
$docmd="/bin/spectrecoind -conf=/root/configure.conf";
print "Enter The Password\n";
system ( "stty -echo");
my $password=<STDIN>;
chomp $password;
system ( "stty echo");
print "Trying to unlock the wallet for staking\n";
system ("$docmd walletlock");
system ("$docmd walletpassphrase '$password' 315360000 true"); # ten years
sleep(10);
system ("$docmd getstakinginfo");
