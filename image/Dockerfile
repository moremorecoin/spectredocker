FROM ubuntu:xenial-20180112.1
MAINTAINER MoreCoin <moremorecoin@gmail.com>
COPY source/install.sh /root
COPY source/configure.conf /root
COPY source/status_report.pl /bin
COPY source/keeper.pl /bin
RUN bash /root/install.sh
ENTRYPOINT ["keeper.pl"]
