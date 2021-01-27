FROM ubuntu:18.04

MAINTAINER runarsf <root@runarsf.dev>

ARG DOCKER_USER=dev
ENV DOCKER_USER ${DOCKER_USER}

ENV DEBIAN_FRONTEND noninteractive

# Setup user
RUN apt-get update \
 && apt-get install -y --no-install-recommends sudo \
 && adduser --disabled-password --gecos '' "${DOCKER_USER}" \
 && adduser "${DOCKER_USER}" sudo \
 && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
 && touch /home/${DOCKER_USER}/.sudo_as_admin_successful \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

USER "${DOCKER_USER}"
WORKDIR "/home/${DOCKER_USER}"

# Install user-packages
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
 && sudo apt-get clean \
 && sudo rm -rf /var/lib/apt/lists/*

# Set up SSH server for X forwarding https://stackoverflow.com/a/37246331
# http://www.inanzzz.com/index.php/post/qdil/creating-a-ssh-server-with-openssh-by-using-docker-compose-and-connecting-to-it-with-php
# ENTRYPOINT service ssh restart && bash
RUN sudo apt-get update \
 && sudo apt-get install -y --no-install-recommends openssh-server \
 && sudo apt-get clean \
 && sudo rm -rf /var/lib/apt/lists/*
 #&& sudo service ssh start \
 #&& sudo service ssh enable

# Configure SSHD.
# https://stackoverflow.com/a/61738823
# SSH login fix. Otherwise user is kicked off after login
RUN sudo sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN sudo mkdir /var/run/sshd
RUN sudo bash -c 'install -m755 <(printf "#!/bin/sh\nexit 0") /usr/sbin/policy-rc.d'
RUN sudo ex +'%s/^#\zeListenAddress/\1/g' -scwq /etc/ssh/sshd_config
RUN sudo ex +'%s/^#\zeHostKey .*ssh_host_.*_key/\1/g' -scwq /etc/ssh/sshd_config
RUN sudo RUNLEVEL=1 dpkg-reconfigure openssh-server
RUN ssh-keygen -A -v
RUN update-rc.d ssh defaults

# Configure sudo.
#RUN ex +"%s/^%sudo.*$/%sudo ALL=(ALL:ALL) NOPASSWD:ALL/g" -scwq! /etc/sudoers

# Generate and configure user keys.
#USER ${DOCKER_USER}
#RUN ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519
#COPY --chown=ubuntu:root "./files/authorized_keys" /home/ubuntu/.ssh/authorized_keys

# To bootstrap user settings, maybe have in CMD
#RUN test -f /docker-bootstrap.sh && /docker-bootstrap.sh

# Set up dotfiles and deploy script
#RUN git config --global http.sslVerify false \
# && git clone https://github.com/runarsf/dotfiles /home/$DOCKER_USER/dotfiles \
# && git clone https://github.com/runarsf/deploy /home/$DOCKER_USER/deploy \
# && /home/$DOCKER_USER/deploy/deploy.sh --dotfiles /home/$DOCKER_USER/dotfiles --packages /home/$DOCKER_USER/dotfiles/deploy-minimal.ini \
# && git config --global http.sslVerify true

# Setup default command and/or parameters.
# ssh -v localhost -p 2222
EXPOSE 22
CMD ["/usr/bin/sudo", "/usr/sbin/sshd", "-D", "-o", "ListenAddress=0.0.0.0"]

#CMD [ "tail", "-f", "/dev/null" ]
