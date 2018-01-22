#!/usr/bin/perl
use strict;
use IO::Socket::INET;

# auto-flush on socket
$| = 1;

# create a connecting socket
my $socket = new IO::Socket::INET (
    PeerHost => '127.0.0.1',
        PeerPort => '9999',
            Proto => 'tcp',
            );
die "Cannot connect to the server, $!\n" unless $socket;
print "Please input the wallet password for staking\n";
system ( "stty -echo");
my $password=<STDIN>;
chomp $password;
system ( "stty echo");

# data to send to a server
my $size = $socket->send($password);

# notify server that request has been sent
shutdown($socket, 1);

# receive a response of up to 1024 characters from server
my $response = "";
$socket->recv($response, 1024);
if($response==0)
{
    print "Wallet unlocked successfully, please check status.log for wallet status\n";
}
elsif($response==8)
{
    print "Your wallet is unencrypted, you don't have to input password.\n";
}
else
{
    print "Failed to unlock wallet, please try it again. ";
    print "Error code: $response\n";
}
$socket->close();
