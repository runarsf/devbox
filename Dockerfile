FROM ubuntu:latest

MAINTAINER runarsf <root@runarsf.dev>

ENV DOCKER_USER dev
#ENV HOME /home/dev

RUN apt-get update && \
    apt-get install -y sudo && \
    adduser --disabled-password --gecos '' "$DOCKER_USER" && \
    adduser "$DOCKER_USER" sudo && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    touch /home/$DOCKER_USER/.sudo_as_admin_successful && \
    rm -rf /var/lib/apt/lists/*

USER "$DOCKER_USER"
WORKDIR "/home/$DOCKER_USER"

RUN yes | sudo unminimize && \
    sudo apt-get install -y bash-completion curl openssh-client tmux apt-utils git && \
    sudo rm -rf /var/lib/apt/lists/*

# Set up dotfiles and deploy script
RUN mkdir /home/$DOCKER_USER/git && \
    git clone https://github.com/runarsf/dotfiles /home/$DOCKER_USER/git/dotfiles && \
    git clone https://github.com/runarsf/deploy /home/$DOCKER_USER/git/dotfiles/deploy && \
    cd /home/$DOCKER_USER/git/dotfiles/deploy && \
    yes N | ./deploy.sh