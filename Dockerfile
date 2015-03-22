# See https://github.com/phusion/passenger-docker/blob/master/Changelog.md for
# a list of version numbers.
FROM phusion/passenger-customizable:0.9.15
MAINTAINER Ben Morrall <bemo56@hotmail.com>

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

# Install Ruby 2.2
RUN /pd_build/ruby2.2.sh

# Install Memcached
RUN /pd_build/memcached.sh

WORKDIR /tmp

# Install npm Packages
ADD package.json ./
RUN npm install

# Bundle install (allow gems to be cached)
ADD Gemfile ./
ADD Gemfile.lock ./
RUN bundle install --without development test

# Add Project Files
ADD . /home/app/webapp
WORKDIR /home/app/webapp
RUN mv /tmp/.bundle .; mv /tmp/node_modules .; chown -R app:app /home/app/webapp

# Setup the container
RUN su app -c "bin/setup_docker"

# Start the nginx server
RUN rm /etc/nginx/sites-enabled/default
RUN cp etc/nginx/webapp.conf /etc/nginx/sites-enabled/webapp.conf
RUN cp etc/nginx/*-env.conf /etc/nginx/main.d/
RUN rm -f /etc/service/nginx/down

# Enable the memcached service.
RUN rm -f /etc/service/memcached/down

# Start the Sidekiq service
RUN mkdir /etc/service/sidekiq
ADD etc/sidekiq/sidekiq.sh /etc/service/sidekiq/run

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
