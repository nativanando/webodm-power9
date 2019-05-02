# webodm-power9

The repo provides a Docker image for running a WebODM environment on power PC and somewhere else architecture. All of the dependencies were compiled to ensure the interoperability between the different systems.


Take a look at Dockerfile to know a little more about the dependencies and make sure the docker is installed.

To run WebODM on power systems, follow the steps below:

`git clone https://github.com/nativanando/webodm-power9.git`

`./start.sh`

To run WebODM on x86 systems, it's possible to change the base image of Dockerfile. To do this, follow the steps below:

`git clone https://github.com/nativanando/webodm-power9.git`

`echo "$(tail -n +2 Dockerfile)" > Dockerfile && sed -i '1 i\FROM ubuntu:16.04' Dockerfile`

`./start.sh`

