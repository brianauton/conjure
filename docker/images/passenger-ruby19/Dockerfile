# conjure/passenger-ruby19:1.0.1

FROM phusion/passenger-ruby19:0.9.15
MAINTAINER Brian Auton brianauton@gmail.com
ENV HOME /root

RUN apt-get update
RUN apt-get -y install libsqlite3-dev libpq-dev libruby1.9 ruby1.9

RUN rm -f /etc/service/nginx/down
RUN rm -f /etc/nginx/sites-enabled/default
ADD nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /home/app/application/shared/bundle/ruby/1.9.0/bin
RUN chown -R app /home/app/application && chmod -R 755 /home/app/application
RUN ln -s /usr/bin/node /home/app/application/shared/bundle/ruby/1.9.0/bin/node

RUN passwd -u app
RUN rm -f /etc/service/sshd/down
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
