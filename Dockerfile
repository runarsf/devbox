FROM ubuntu:18.04

MAINTAINER runarsf <root@runarsf.dev>

ENV DEBIAN_FRONTEND=noninteractive

#ARG UID=1000
#ARG GID=1000
ARG DOCKER_USER
ENV DOCKER_USER $DOCKER_USER

RUN apt-get update \
 && apt-get install -y --no-install-recommends sudo \
 && adduser --disabled-password --gecos '' "$DOCKER_USER" \
 && adduser "$DOCKER_USER" sudo \
 && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
 && touch /home/$DOCKER_USER/.sudo_as_admin_successful \
 && rm -rf /var/lib/apt/lists/*

USER "$DOCKER_USER"
WORKDIR "/home/$DOCKER_USER"

RUN sudo apt-get update \
 && sudo apt-get install -y --no-install-recommends \
    apt-utils \
    git \
    bash-completion \
    curl \
    openssl \
    openssh-client \
    tmux \
    vim \
    docker \
    docker-compose \
 && sudo rm -rf /var/lib/apt/lists/*

# Set up dotfiles and deploy script
#RUN mkdir /home/$DOCKER_USER/git \
RUN git config --global http.sslVerify false \
  && git clone https://github.com/runarsf/dotfiles /home/$DOCKER_USER/dotfiles \
  && git clone https://github.com/runarsf/deploy /home/$DOCKER_USER/deploy \
  && /home/$DOCKER_USER/deploy/deploy.sh --dotfiles /home/$DOCKER_USER/dotfiles --packages /home/$DOCKER_USER/dotfiles/deploy-minimal.ini
