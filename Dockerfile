FROM circleci/python:latest

ENV SUMO_VERSION 0_31_0
ENV SUMO_HOME /opt/sumo
# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ENV PYTHON_PIP_VERSION 9.0.1
ENV PYTHON_VERSION 3.6.3

# ensure local python is preferred over distribution python
ENV PATH /usr/local/bin:$PATH

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG C.UTF-8
ENV GPG_KEY 0D96DF4D4110E5C43FBFB17F2D347EA6AA65421D

WORKDIR /tmp
RUN wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz"
RUN wget -O python.tar.xz.asc "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc"
RUN export GNUPGHOME="$(mktemp -d)"
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEY"
RUN gpg --batch --verify python.tar.xz.asc python.tar.xz
RUN rm -rf "$GNUPGHOME" python.tar.xz.asc
RUN mkdir -p /tmp/src/python
RUN tar -xJC /tmp/src/python --strip-components=1 -f python.tar.xz
RUN rm python.tar.xz
WORKDIR /tmp/src/python
RUN ./configure \
        --enable-loadable-sqlite-extensions \
        --enable-shared \
        --with-system-expat \
        --with-system-ffi \
        --enable-optimizations
RUN make -j "$(nproc)"
RUN sudo make altinstall

# test for python
RUN python -V
RUN python3 -V
RUN python2 -V

# test for pip
RUN pip3 -V

# build essential
RUN sudo apt-get update && sudo apt-get install -y build-essential

# Install SUMO dependencies
RUN sudo apt-get update && sudo apt-get install -qq \
    wget \
    g++ \
    make \
    libxerces-c3.1 \
    libxerces-c3-dev \
    libproj-dev \
    proj-bin \
    proj-data \
    libtool \
    libgdal-dev \
    libxerces-c3-dev \
    libfox-1.6-0 \
    libfox-1.6-dev \
    autoconf

# Download and extract source code
RUN wget https://github.com/DLR-TS/sumo/archive/v$SUMO_VERSION.tar.gz -O /tmp/$SUMO_VERSION.tar.gz
RUN tar xzf /tmp/$SUMO_VERSION.tar.gz -C /tmp
RUN sudo mv /tmp/sumo-$SUMO_VERSION/sumo $SUMO_HOME
RUN rm -rf /tmp/sumo-$SUMO_VERSION
RUN rm /tmp/$SUMO_VERSION.tar.gz

# Configure and build from source.
WORKDIR $SUMO_HOME
RUN make -f Makefile.cvs
RUN ./configure
RUN make -j "$(nproc)"
RUN sudo make install

# Ensure the installation works. If this call fails, the whole build will fail.
RUN sumo

# Download and compile traci4j library
RUN sudo apt-get install -qq -y ssh-client git maven openjdk-7-jdk
RUN mkdir -p /tmp/traci4j 
WORKDIR /tmp/traci4j
RUN git clone https://github.com/egueli/TraCI4J.git /tmp/traci4j && mvn package -Dmaven.test.skip=true

# Add volume to allow for host data to be used
RUN mkdir ~/data
VOLUME ~/data

# Expose a port so that SUMO can be started with --remote-port 1234 to be controlled from outside Docker
EXPOSE 1234

ENTRYPOINT ["sumo"]

CMD ["--help"]

