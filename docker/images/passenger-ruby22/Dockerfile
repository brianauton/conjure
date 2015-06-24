# conjure/passenger-ruby22:1.0.1

FROM phusion/passenger-ruby22:0.9.15
MAINTAINER Brian Auton brianauton@gmail.com
ENV HOME /root

RUN apt-get update
RUN apt-get -y install libsqlite3-dev libpq-dev libruby2.2 ruby2.2

RUN rm -f /etc/service/nginx/down
RUN rm -f /etc/nginx/sites-enabled/default
ADD nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /home/app/application/shared/bundle/ruby/2.2.0/bin
RUN chown -R app /home/app/application && chmod -R 755 /home/app/application
RUN ln -s /usr/bin/node /home/app/application/shared/bundle/ruby/2.2.0/bin/node

RUN passwd -u app
RUN rm -f /etc/service/sshd/down
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
