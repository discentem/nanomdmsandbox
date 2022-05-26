FROM --platform=linux/amd64 ubuntu:20.04
# FROM --platform=linux/amd64 alpine:3.14
# RUN apk update \
#   && apk add bash curl gzip --no-cache aws-cli

RUN apt-get update && apt-get -y upgrade
RUN apt install -y curl gzip unzip

# RUN apk update \
#   && apk add bash curl gzip --no-cache aws-cli

ARG NANOMDM_VERSION
ENV NANOMDM_VERSION $NANOMDM_VERSION
# ARG CA_FILE_NAME
# ENV CA_FILE_NAME $CA_FILE_NAME
ARG API_KEY
ENV API_KEY $API_KEY

ARG MYSQL_USERNAME
ENV MYSQL_USERNAME $MYSQL_USERNAME
ENV MYSQL_PASSWORD $MYSQL_PASSWORD
ARG MYSQL_HOSTNAME
ENV MYSQL_HOSTNAME $MYSQL_HOSTNAME
ARG APP_NAME
ENV APP_NAME $APP_NAME
# ARG MYSQL_PORT
# ENV MYSQL_PORT $MYSQL_PORT

WORKDIR /service/nanomdm

COPY ./docker/config/certs/depot/ca.pem /service/nanomdm/ca.pem

RUN curl -RLO https://github.com/micromdm/nanomdm/releases/download/v$NANOMDM_VERSION/nanomdm-linux-amd64-v$NANOMDM_VERSION.zip

RUN unzip nanomdm-linux-amd64-v$NANOMDM_VERSION.zip

RUN chmod a+x ./nanomdm-linux-amd64

ENV MYSQL_DSN $MYSQL_DSN

EXPOSE 9000

CMD ./nanomdm-linux-amd64 -debug -ca ca.pem -api $API_KEY -storage mysql -dsn "${MYSQL_DSN}"
