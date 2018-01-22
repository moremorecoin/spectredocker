#!/usr/bin/perl
use IO::Socket::INET;
 
# auto-flush on socket
$| = 1;

my $walletcmd=$ENV{WALLETCMD};
my $configure_folder=$ENV{CONFIGUREFOLDER};
my $configure_file=$ENV{CONFIGUREFILE};

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
if( ! -e "$configure_folder/$configure_file" ) #if there is no configue file, use the default one
{
    system("cp /root/configure.conf $configure_folder/$configure_file");
}

#start the daemon
system("$walletcmd $ENV{DAEMON_ARGUMENT}");

my $ret=1;
while($ret != 0)
{
    system("echo 'Wallet starting up ...' >> $configure_folder/status.log ");
    sleep (5);
    $ret=system("$walletcmd help");
}

my $encrypted=0;
if ( `$walletcmd help |grep encryptwallet` ) #unlocked wallet
{
    $encrypted=0;
    system("status_report.pl >> $configure_folder/status.log 2>&1 &");
}
else
{
    system("echo 'Please use unlock_wallet_for_staking.pl to unlock wallet' >> $configure_folder/status.log");
    $encrypted=1;
}

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

    my $ret='';

    if($data !~/^[\x21-\x7E]+$/) #invalid password
    {
        system("echo 'Password contains invalid characters' >> $configure_folder/status.log");
        $ret=9; #invalid password characters
        next;
    }

    if($encrypted==1)
    {
        system("echo 'Password received, trying to unlock wallet for staking' >> $configure_folder/status.log");
        #unlock wallet for staking
        system ("$walletcmd walletlock");
        $ret=system("$walletcmd walletpassphrase '$data' 315360000 true"); # unlock for ten years
        if($ret==0) #successfully unlocked wallet
        {
            system("echo 'Wallet unlocked successfully' >> $configure_folder/status.log");
            system("pkill status_report");#kill the existing process, if there is any
            system("PHRASE='$data' nohup status_report.pl  >> $configure_folder/status.log 2>&1 &");
        }
        else
        {
            system("echo 'Incorrect password received, wallet remain locked' >> $configure_folder/status.log");
        }
    }
    else
    {
        $ret=8; #error code 8: unencrypted wallet
    }
    # write response data to the connected client
    $client_socket->send($ret);

    # notify client that response has been sent
    shutdown($client_socket, 1);
}
$socket->close();
