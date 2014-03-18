# conjure/passenger-ruby21:1.0.0

FROM phusion/passenger-ruby21:0.9.6
MAINTAINER Brian Auton brianauton@gmail.com
ENV HOME /root

RUN apt-get update
RUN apt-get -y install libsqlite3-dev
RUN /build/nodejs.sh

RUN rm -f /etc/service/nginx/down
RUN rm -f /etc/nginx/sites-enabled/default
ADD nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /home/app/application/shared/bundle/ruby/2.1.0/bin
RUN chown -R app /home/app/application && chmod -R 755 /home/app/application
RUN ln -s /usr/bin/node /home/app/application/shared/bundle/ruby/2.1.0/bin/node

RUN passwd -u app
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
