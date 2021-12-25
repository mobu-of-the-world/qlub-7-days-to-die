FROM ubuntu:latest

RUN \
      apt-get update -qq -y &&\
      apt-get install -y wget lib32gcc1

RUN \
      mkdir -p /steamcmd &&\
      cd /steamcmd &&\
      wget http://media.steampowered.com/installer/steamcmd_linux.tar.gz && \
      tar xzvf steamcmd_linux.tar.gz && \
      rm steamcmd_linux.tar.gz

COPY install.steam /steam/install.steam

RUN \
      mkdir -p /7-days-to-die &&\
      cd /steamcmd &&\
      ./steamcmd.sh +runscript /steam/install.steam

COPY serverconfig.xml /7-days-to-die/serverconfig.xml

EXPOSE 26900
EXPOSE 8080
EXPOSE 8081

CMD ["bash", "-c", "echo \"password: $QLUB_SERVER_PASSWORD\" && sed -i -e \"s/QLUB_SERVER_PASSWORD/$QLUB_SERVER_PASSWORD/g\" /7-days-to-die/serverconfig.xml && /7-days-to-die/startserver.sh -configfile=serverconfig.xml"]
