FROM ubuntu:xenial-20180112.1
MAINTAINER MoreCoin <moremorecoin@gmail.com>
COPY source/install.sh /root
COPY source/configure.conf /root
COPY source/status_report.pl /bin
COPY source/keeper.pl /bin
RUN bash /root/install.sh
ENV WALLETCMD spectrecoind
ENV CONFIGUREFOLDER /root/.spectrecoin
ENV CONFIGUREFILE spectrecoin.conf
ENV CURRENCY XSPEC
ENV REPORT_STATUS_FREQ_IN_SEC 600
ENV BACKUP_WALLET_FREQ_IN_SEC 1209600
ENV DAEMON_ARGUMENT -daemon
ENV Donate_portion_of_staking 0.1
ENV Donate_command sendtostealthaddress
ENV Donate_address smYkGuyCD4z55C4WxtLzkFpNJu8GtFfhLm5minQBvxDMyPLAVLdah2ZjBqTW13QBoCayQW5sVKQMxZNoVYsHV3t7btkDFRq8nMWiyU
ENTRYPOINT ["keeper.pl"]
