apt-get update
#apt-get upgrade -y
apt-get install -y build-essential libssl-dev libevent-dev libseccomp-dev libcap-dev libboost-all-dev pkg-config git dh-autoreconf
git clone --recursive https://github.com/spectrecoin/spectre.git
cd spectre
./autogen.sh
./configure 
make
cp src/spectrecoind /bin/
cd ..
rm -rf spectre
