FROM ghcr.io/tianocore/containers/fedora-35-dev:latest

ARG username
ARG workdir
RUN useradd -ms /bin/bash $username
RUN mkdir -p $workdir
USER $username
