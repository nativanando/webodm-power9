FROM docker.io/ppc64le/ubuntu:16.04
MAINTAINER Régis Belson <me@regisbelson.fr>

# Install the dependecies to compile the applications 

RUN apt-get update && apt-get install -y \
  	build-essential \
  	git \
  	vim \
  	wget \
  	libreadline-dev \
  	zlib1g-dev \
  	autoconf \
  	automake \
  	libtool \
  	cmake

# Download of postgres 9.6.8 

RUN cd /opt \
 	&& wget https://ftp.postgresql.org/pub/source/v9.6.8/postgresql-9.6.8.tar.gz

RUN mkdir /opt/postgresql-9.6.8
  
RUN tar \
        --extract \
        --file /opt/postgresql-9.6.8.tar.gz \
        --directory /opt/postgresql-9.6.8 \
        --strip-components 1

RUN cd /opt/postgresql-9.6.8 \
 	&& ./configure \
  	&& make -j8 \
  	&& make install


RUN adduser --disabled-password --shell /bin/bash --gecos "postgres" postgres
RUN mkdir /usr/local/pgsql/data
RUN chown postgres /usr/local/pgsql/data

# Create database Workdir

RUN su - postgres -c "/usr/local/pgsql/bin/initdb -D /usr/local/pgsql/data" && \
 	su - postgres -c "/usr/local/pgsql/bin/postgres -D /usr/local/pgsql/data >logfile 2>&1 &"

RUN ln -s /usr/local/pgsql/bin/psql /usr/bin/psql


# Compile python 2 and 3
RUN apt-get update && apt-get install -y python
RUN cd /usr/src/ && \
 	wget https://www.python.org/ftp/python/3.5.6/Python-3.5.6.tgz && \
  	tar -xvf Python-3.5.6.tgz && \
  	cd Python-3.5.6 && \
	./configure --enable-optimizations && \
  	make -j4 && \
  	make install
#RUN mv /usr/bin/python /usr/bin/python2
#RUN ln -s /usr/local/bin/python3 /usr/bin/python
#RUN ln -s /usr/local/bin/python3 /usr/local/bin/python

# Install postgis dependencies
RUN apt-get update && apt-get install -y \
 	libgeos++-dev \
  	libgeos-3.5.0 \
  	libgeos-c1v5 \
  	libgeos-dev \
 	libgeos-doc \
  	libgeos-dbg \
 	proj-bin \
  	binutils \
  	libproj-dev \
  	gdal-bin \
  	libxml2 \
  	libxml2-dev \
  	libgdal-dev 

# Compile gdal lib > 2
RUN cd /opt \
 	&& wget http://download.osgeo.org/gdal/2.1.0/gdal-2.1.0.tar.gz

RUN mkdir /opt/gdal-2.1.0/

RUN tar \
        --extract \
        --file /opt/gdal-2.1.0.tar.gz \
        --directory /opt/gdal-2.1.0/ \
        --strip-components 1

RUN cd /opt/gdal-2.1.0/ && \
 	./configure --prefix=/usr/ && \
  	make -j4 && \
  	make install && \
  	cd swig/python/ && \
  	python3 setup.py install # Make sure to have python3 as default 

# Download and install  postgis 2.3.9
RUN cd /opt && \
 	wget https://download.osgeo.org/postgis/source/postgis-2.3.9.tar.gz

RUN mkdir /opt/postgis-2.3.9

RUN tar \
        --extract \
        --file /opt/postgis-2.3.9.tar.gz \
        --directory /opt/postgis-2.3.9 \
        --strip-components 1

RUN cd /opt/postgis-2.3.9 && \
	./configure --with-pgconfig=/usr/local/pgsql/bin/pg_config && \
        make && \
	make install

# NodeJS Compile
RUN cd /opt \
        && wget https://nodejs.org/dist/v10.15.3/node-v10.15.3.tar.gz

RUN mkdir /opt/node-v10.15.3/

RUN tar \
        --extract \
        --file /opt/node-v10.15.3.tar.gz \
        --directory /opt/node-v10.15.3/ \
        --strip-components 1

RUN cd /opt/node-v10.15.3 \
        && ./configure \
        && make -j8 \
        && make install

# Install nginx

RUN apt-get update && apt-get install -y nginx

# Redis Compile

RUN cd /opt \
        && wget http://download.redis.io/redis-stable.tar.gz

RUN mkdir /opt/redis-stable/

RUN tar \
        --extract \
        --file /opt/redis-stable.tar.gz \
        --directory /opt/redis-stable/ \
        --strip-components 1

RUN cd /opt/redis-stable/ && \
	make && \
	make install

# expose web server port
EXPOSE 8000


# Install WebODM
RUN apt-get install -y python3-pip
RUN cd /opt \
	&& git clone --depth 1 https://github.com/OpenDroneMap/WebODM

# Copy the databse local seetings config
COPY ./local_settings.py /opt/WebODM/webodm/

RUN cd /opt/WebODM/ && \
	pip3 install virtualenv && \
        virtualenv python3env && \
	sh python3env/bin/activate && \
	pip3 install -r requirements.txt && \
	npm install -g webpack && \
	npm install -g webpack-cli && \
	npm install && \
	webpack --mode production && \
	python manage.py collectstatic --noinput && \
	chmod +x start.sh
