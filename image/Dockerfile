FROM ubuntu:zesty-20171122
MAINTAINER MoreCoin <moremorecoin@gmail.com>
COPY source/install.sh /root
COPY source/configure.conf /root
COPY source/staking.pl /bin
COPY source/donate.pl /bin
COPY source/stakingunlock /etc/cron.hourly/stakingunlock
COPY source/dailycheck /etc/cron.daily/dailycheck
ENV Donate_to smYkGuyCD4z55C4WxtLzkFpNJu8GtFfhLm5minQBvxDMyPLAVLdah2ZjBqTW13QBoCayQW5sVKQMxZNoVYsHV3t7btkDFRq8nMWiyU
ENV Donate_portion_of_staking 0.1
RUN bash /root/install.sh
ENTRYPOINT ["spectrecoind","-conf=/root/configure.conf"]
