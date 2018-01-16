apt-get update
#apt-get upgrade -y
apt install -y build-essential libssl1.0-dev libevent-dev libseccomp-dev libcap-dev libboost-all-dev pkg-config git dh-autoreconf
git clone --recursive https://github.com/spectrecoin/spectre.git
cd spectre
./autogen.sh
./configure 
make
cp src/spectrecoind /bin/
cd ..
rm -rf spectre
