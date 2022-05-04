FROM alpine:3.14 AS build

RUN apk update \
  && apk add bash curl gzip --no-cache aws-cli

ARG NANOMDM_VERSION
ENV NANOMDM_VERSION $NANOMDM_VERSION
ARG CA_FILE_NAME
ENV CA_FILE_NAME $CA_FILE_NAME
ARG API_KEY
ENV API_KEY $API_KEY

ARG MYSQL_USERNAME
ENV MYSQL_USERNAME $MYSQL_USERNAME
ARG MYSQL_HOSTNAME
ENV MYSQL_HOSTNAME $MYSQL_HOSTNAME
# ARG MYSQL_PORT
# ENV MYSQL_PORT $MYSQL_PORT

WORKDIR /service/nanomdm

RUN curl -RLO https://github.com/micromdm/nanomdm/releases/download/v$NANOMDM_VERSION/nanomdm-linux-amd64-v$NANOMDM_VERSION.zip

RUN unzip nanomdm-linux-amd64-v$NANOMDM_VERSION.zip

RUN chmod a+x ./nanomdm-linux-amd64

ENV MYSQL_DSN $MYSQL_DSN
RUN export MYSQL_DSN=$(aws rds generate-db-auth-token \
   --hostname ${MYSQL_HOSTNAME} \
   --port 3306 \
   --region us-east-1 \
   --username ${MYSQL_USERNAME} --output text)

EXPOSE 9000
CMD ./nanomdm-linux-amd64 -ca $CA_FILE_NAME -api $API_KEY -storage mysql -dsn $MYSQL_DSN
