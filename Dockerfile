FROM ubuntu:latest

RUN \
      apt-get update -qq -y &&\
      apt-get install -y wget lib32gcc1

RUN \
      mkdir /steamcmd &&\
      cd /steamcmd &&\
      wget http://media.steampowered.com/installer/steamcmd_linux.tar.gz && \
      tar xzvf steamcmd_linux.tar.gz && \
      rm steamcmd_linux.tar.gz

COPY install.steam /steam/install.steam

RUN \
      mkdir /7-days-to-die &&\
      cd /steamcmd &&\
      ./steamcmd.sh +runscript /steam/install.steam

ENTRYPOINT ["/bin/bash"]
