FROM circleci/python:3.6.3-stretch

ENV SUMO_VERSION 0_31_0
ENV SUMO_HOME /opt/sumo

ENV PATH /usr/local/bin:~/go/bin:$PATH
ENV GOPATH $HOME/go

# test for python
RUN python -V
RUN python2 -V
RUN python3 -V

# test for pip
RUN pip -V

# Install dependencies
RUN sudo apt-get update && sudo apt-get install -qq \
    build-essential \
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
    autoconf \
    ssh-client \
    git \
    maven \
    openjdk-8-jdk \
    golang-go

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
RUN sudo apt-get install -qq -y 
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

