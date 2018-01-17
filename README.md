# Spectre(XSPEC) Docker
## Staking Spectre in the Could, or anywhere you want!

Have you ever thought of staking your Spectre(XSPEC coin) in Amazon Cloud? Or any of your VPS servers? Or even any of your old computers but get pushed back because of the difficult installation process?

Recently I spend quite some time to compile the source code to built a docker instance. It takes me quite a lot time, but now I'd like to share it out so you don't have to spend the time again. If you know what docker is, you probably know you will love this solution. Because it is simple, straight forward, and takes only seconds to run your wallet anywhere to start staking.

### Get started
First, please install **Docker** and **Docker Compose** to your AWS/VPS/Any Computer, by following this guide: https://docs.docker.com/compose/install/

Then, download source code from my GitHub repository:

```
git clone https://github.com/moremorecoin/spectredocker.git
```

Last, run it by:

```
cd spectredocker
sudo docker-compose up -d
```

After a few seconds, you should see there are wallet.dat file as well as other log files in SpectreConf folder, you can then copy your own wallet.dat file into SpectreConf folder to replace the auto-generated wallet.dat file. After Spectre wallet syncronized all the blocks, your staking will begin automatically.

### Encrypted wallet

If your wallet is encrypted, after you start the docker, you can run unlock_wallet_for_staking.pl to unlock your wallet for staking only:

```
perl unlock_wallet_for_staking.pl
```

You will be asked for password to unlock the wallet. After you type it in, the password will be passed to the docker instance to unlock the wallet. You don't have to write down your password into docker-compose.yml file anymore.

### Monitoring

To check the wallet status, you can take a look at the log file SpectreConf/status.log. To get the progressive output, run:

```
tail -f SpectreConf/statue.log
```

This file is updated every 10 minutes. 

If you want to use command line on your own -- to see your wallet address, send coin, check balance etc, you can attach to the docker instance this way:

```
sudo docker exec -it spectredocker_xspec_1 bash
```

To show some commands for use:

```
spectrecoind help
```

After you are done, type 'exit' to leave the console. 

### Shutdown

If you want to turn off the wallet, simply run this command in the same folder of docker-compose.yml file:

```
sudo docker-compose down
```

### Donation

My Spectre stealth address
is **smYkGuyCD4z55C4WxtLzkFpNJu8GtFfhLm5minQBvxDMyPLAVLdah2ZjBqTW13QBoCayQW5sVKQMxZNoVYsHV3t7btkDFRq8nMWiyU**, please donate to help on this work. 
