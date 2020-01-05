FROM ubuntu:18.04

MAINTAINER runarsf <root@runarsf.dev>

ARG DOCKER_USER=dev
ENV DOCKER_USER $DOCKER_USER
ENV DEBIAN_FRONTEND noninteractive

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

# Set up SSH server for X forwarding https://stackoverflow.com/a/37246331
# http://www.inanzzz.com/index.php/post/qdil/creating-a-ssh-server-with-openssh-by-using-docker-compose-and-connecting-to-it-with-php
# ENTRYPOINT service ssh restart && bash
ARG argssh
EXPOSE 22
RUN test -z "${argssh}" \
 && : \
 ||(sudo apt-get update \
 && sudo apt-get install -y --no-install-recommends \
    ssh \
 && sudo rm -rf /var/lib/apt/lists/* \
 && sudo systemctl ssh start \
 && sudo systemctl ssh enable)

# Set up dotfiles and deploy script
RUN git config --global http.sslVerify false \
 && git clone https://github.com/runarsf/dotfiles /home/$DOCKER_USER/dotfiles \
 && git clone https://github.com/runarsf/deploy /home/$DOCKER_USER/deploy \
 && /home/$DOCKER_USER/deploy/deploy.sh --dotfiles /home/$DOCKER_USER/dotfiles --packages /home/$DOCKER_USER/dotfiles/deploy-minimal.ini \
 && git config --global http.sslVerify true

CMD [ "tail", "-f", "/dev/null" ]
