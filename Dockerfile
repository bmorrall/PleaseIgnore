# See https://github.com/phusion/passenger-docker/blob/master/Changelog.md for
# a list of version numbers.
FROM phusion/passenger-ruby22:0.9.15
MAINTAINER Ben Morrall <bemo56@hotmail.com>

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

# Install Bower for asset management
RUN npm install bower@1.3.12 --global

# Bundle install (allow gems to be cached)
WORKDIR /tmp
ADD Gemfile /tmp/
ADD Gemfile.lock /tmp/
RUN bundle install --without development test

# Add Project Files
ADD . /home/app/webapp
WORKDIR /home/app/webapp
RUN mv /tmp/.bundle .
RUN chown -R app:app /home/app/webapp

# Setup the container
RUN su app -c "bin/setup_docker"

# Start the nginx server
RUN rm /etc/nginx/sites-enabled/default
RUN cp etc/nginx/webapp.conf /etc/nginx/sites-enabled/webapp.conf
RUN cp etc/nginx/*-env.conf /etc/nginx/main.d/
RUN rm -f /etc/service/nginx/down

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
