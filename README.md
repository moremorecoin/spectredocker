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

If your wallet is encrypted, before you run the docker by docker-compose command, you should modify the docker-compose.yml file by adding your wallet password to PASS variable.

For example, if your password is 12345678, it should look like:

```
version: '3'
services:
  XP:
    restart: always
    environment:
     - PASS=12345678
     - Donate_portion_of_staking=0.1
    volumes:
     - ./SpectreConf:/root/.spectrecoin
    image: morecoin/spectre
```

Note: if your password contains '$', please type '$$' instead. This is because '$' is a special character in docker compose file, you have to type '$$' to tell docker compose that this is a single '$'.

The process to unlock wallet for staking will run every hour, in the worst case, your wallet will start staking 59 minutes after the docker instance started to run.

### Monitoring

To check the wallet status, you can take a look at the log file SpectreConf/debug.log. To get the progressive output, run:

```
tail -f SpectreConf/debug.log
```

To check the staking status, see SpectreConf/staking.log. This file should update every one hour. If you see the staking status is false, try to check it one hour later.

### Shutdown

If you want to turn off the wallet, simply run this command in the same folder of docker-compose.yml file:

```
sudo docker-compose down
```

### Donation

As you can see there is a parameter for you to donate a portion of you staking incomes to the developer. By default, it is set to 0.1, which means you agree to donate 10% of you staking incomes to the developer. This feature could be turned off by setting Donate_portion_of_staking to 0. I appreciate for your generous donation. My Spectre stealth address
is **smYkGuyCD4z55C4WxtLzkFpNJu8GtFfhLm5minQBvxDMyPLAVLdah2ZjBqTW13QBoCayQW5sVKQMxZNoVYsHV3t7btkDFRq8nMWiyU**, you can also donate to this wallet manually.
