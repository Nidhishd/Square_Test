FROM ubuntu:18.04
MAINTAINER Nidhish K Dinesh
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -yq --no-install-recommends \
    software-properties-common \
    apt-utils \
    curl \
    git \
    && curl -sL https://aka.ms/InstallAzureCLIDeb | bash \
    && az aks install-cli
