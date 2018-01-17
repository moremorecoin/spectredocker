#!/usr/bin/perl
use IO::Socket::INET;
 
# auto-flush on socket
$| = 1;
 
# creating a listening socket
# client will send command through this port
my $socket = new IO::Socket::INET (
    LocalHost => '0.0.0.0',
    LocalPort => '9999',
    Proto => 'tcp',
    Listen => 5,
    Reuse => 1
);
die "cannot create socket $!\n" unless $socket;
if( ! -e "/root/.spectrecoin/spectrecoin.conf" ) #if there is no configue file, use the default one
{
    system("cp /root/configure.conf /root/.spectrecoin/spectrecoin.conf");
}
my $walletcmd= "spectrecoind"; 

#start the daemon
system("$walletcmd -daemon");
sleep(10);
system("status_report.pl >> /root/.spectrecoin/status.log &");

while(1)
{
    # waiting for a new client connection
    my $client_socket = $socket->accept();

    # get information about a newly connected client
    my $client_address = $client_socket->peerhost();
    my $client_port = $client_socket->peerport();
    #print "connection from $client_address:$client_port\n";

    # read up to 1024 characters from the connected client
    my $data = "";
    $client_socket->recv($data, 1024);

    #unlock wallet for staking
    system ("$walletcmd walletlock");
    my $ret=system("$walletcmd walletpassphrase '$data' 315360000 true"); # unlock for ten years
    # write response data to the connected client
    $client_socket->send($ret);

    # notify client that response has been sent
    shutdown($client_socket, 1);
}
$socket->close();
