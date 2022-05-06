FROM --platform=linux/amd64 ubuntu:20.04

RUN apt-get update && apt-get -y upgrade
RUN apt install -y curl gzip unzip

ARG SCEP_VERSION
ENV SCEP_VERSION $SCEP_VERSION

ARG CHALLENGE
ENV CHALLENGE $CHALLENGE

WORKDIR /service/scep

COPY ../../config/certs/depot /service/scep/depot

RUN curl -RLO https://github.com/micromdm/scep/releases/download/v$SCEP_VERSION/scepserver-linux-amd64-v$SCEP_VERSION.zip

RUN unzip scepserver-linux-amd64-v$SCEP_VERSION.zip

EXPOSE 8080
CMD ./scepserver-linux-amd64 -depot depot -port 8080 -challenge=$CHALLENGE
