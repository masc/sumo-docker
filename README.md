# SUMO Docker Base Image

[![Docker Pulls](https://img.shields.io/docker/pulls/socialcars/sumo-docker.svg)](https://hub.docker.com/r/socialcars/sumo-docker/)
[![Docker Automated build](https://img.shields.io/docker/automated/socialcars/sumo-docker.svg)](https://hub.docker.com/r/socialcars/sumo-docker/~/settings/automated-builds/)
[![Docker Build Status](https://img.shields.io/docker/build/socialcars/sumo-docker.svg)](https://hub.docker.com/r/socialcars/sumo-docker/builds/)

A Docker base image for the [SUMO](http://sumo.dlr.de/wiki/Main_Page) traffic simulation package. SUMO (Simulation of Urban MObility) is an open source, highly portable, microscopic and continuous road traffic simulation package designed to handle large road networks.

## Run with Docker

This uses an automated build on Dockerhub: https://hub.docker.com/r/socialcars/sumo-docker/ so you don't have to build the image for yourself.

This Dockerfile uses Docker's concept of [volumes](https://docs.docker.com/v1.10/engine/userguide/containers/dockervolumes/) where you make one or more folders on your host computer available inside the docker container. The paths of these volumes are specificed in the [Dockerfile](Dockerfile). In this case, you can make a folder on your host computer available as ```/data``` in the Docker container. 

For example, if you have your SUMO files stored in the folder ```/some/local/path/to/your/data``` on your host computer, you can "mount" this folder as follows: ``` -v /some/local/path/to/your/data:/data```. When passing command line arguments to SUMO, use ```/data``` instead of the real folder's name on your computer.

This command illustrates this:
```
docker run --rm -t -i -p 1234:1234 -v /some/local/path/to/your/data:/data socialcars/sumo-docker
```

## Run with CircleCI and Automate Simulation Runs

It is also possible to automate simulation runs by using [CircleCI](https://circleci.com) as an execution engine.
The results of the simulation can then be published as a GitHub release.

### Example

See [masc/sumo-stressgrid](https://github.com/masc/sumo-stressgrid). To automate a simulation one could use the following workflow:

0. Setup CircleCI to build your project.
1. Develop simulation code in the [master branch](https://github.com/masc/sumo-stressgrid/tree/master) until it is mature enough to be used for a simulation.
2. Fork a new branch, e.g. [sim-4x4](https://github.com/masc/sumo-stressgrid/tree/sim-4x4) to simulate a 4x4 grid or [sim-4x6](https://github.com/masc/sumo-stressgrid/tree/sim-4x4).
3. Adapt [circle.yaml](https://github.com/masc/sumo-stressgrid/blob/sim-4x4/circle.yml) in that branch to your needs, i.e. add parameters, etc.
4. Push to repository and let CircleCI run your simulation and publish the [results](https://github.com/masc/sumo-stressgrid/releases).

## Control SUMO via TraCi

Use the following command if you want to control SUMO using the [Traffic Control Interface ](TraCI). This exposes SUMO's features on port 1234 via TCP/IP:
```
docker run -t -i --rm -p 1234:1234 \
	-v /some/local/path/to/your/data:/data \
	socialcars/sumo-docker \
	-c /data/cologne.sumocfg \
	--remote-port 1234 \
	-v
```
(remove all \ in the previous example if you use a single line instead of multiple lines)


## Java API for TraCI

A Java API for TraCI is available [here](https://github.com/egueli/TraCI4J). 

An example application that uses TraCI4J is available [here](https://github.com/pfisterer/sumo-traci-demo).

## Credits

Initially based on work done by [pfisterer](https://github.com/pfisterer) and [farberg](https://hub.docker.com/u/farberg/).
