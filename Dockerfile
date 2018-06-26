# Use Ubuntu 16.04 as parent image
FROM ubuntu:16.04

# Set the working directory to /app
WORKDIR /app

# Install Ubuntu dependencies
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y wget apt-transport-https

# Download albacore installer 
RUN wget https://mirror.oxfordnanoportal.com/software/analysis/python3-ont-albacore_2.2.2-1~xenial_amd64.deb

# Add ONT deb repository (used for installing dependencies)
RUN wget -O- https://mirror.oxfordnanoportal.com/apt/ont-repo.pub | apt-key add -
RUN echo "deb http://mirror.oxfordnanoportal.com/apt trusty-stable non-free" | tee /etc/apt/sources.list.d/nanoporetech.sources.list
RUN apt-get update

# Install albacore (will produce errors because of missing dependencies, so force exit code of 0 so build process completes)
RUN dpkg -i python3-ont-albacore_2.2.2-1~xenial_amd64.deb; exit 0

# Install the missing dependencies
RUN apt-get -fy install

