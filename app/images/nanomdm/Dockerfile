FROM alpine:3.14 AS build

RUN apk update \
  && apk add bash curl gzip

ARG NANOMDM_VERSION
ENV NANOMDM_VERSION $NANOMDM_VERSION
ARG CA_FILE_NAME
ENV CA_FILE_NAME $CA_FILE_NAME
ARG API_KEY
ENV API_KEY $API_KEY

WORKDIR /service/nanomdm

RUN curl -RLO https://github.com/micromdm/nanomdm/releases/download/v$NANOMDM_VERSION/nanomdm-linux-amd64-v$NANOMDM_VERSION.zip

RUN unzip nanomdm-linux-amd64-v$NANOMDM_VERSION.zip

RUN chmod a+x ./nanomdm-linux-amd64

EXPOSE 9000
CMD ./nanomdm-linux-amd64 -ca $CA_FILE_NAME -api $API_KEY -storage $dsnString
