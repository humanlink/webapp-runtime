FROM python:3.5

# We stick everything in one Dockerfile for now
# because AWS ElasticBeanstalk multi-containers requires
# images to be pre-built.
# We do not have that luxury right now.

# -Nginx: https://hub.docker.com/_/nginx/
RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62
RUN echo "deb http://nginx.org/packages/mainline/debian/ jessie nginx" >> /etc/apt/sources.list

ENV NGINX_VERSION 1.9.7-1~jessie

RUN apt-get update && \
    apt-get install -y ca-certificates nginx=${NGINX_VERSION} && \
    rm -rf /var/lib/apt/lists/*

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

VOLUME ["/var/cache/nginx"]
# -End nginx.

# Custom.
RUN pip3 install virtualenv

# Supervisor doesn't work with python 3 :(
# This way, python2 is also instealled.
RUN apt-get update && \
    apt-get install -y supervisor

RUN curl -fsSL --retry 5 https://bootstrap.pypa.io/get-pip.py \
          | python2
RUN python2 -m pip install supervisor-stdout

# We manage these via supervisor.
RUN service supervisor stop
RUN service nginx stop
