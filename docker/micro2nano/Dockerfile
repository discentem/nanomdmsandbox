FROM --platform=linux/amd64 ubuntu:20.04

RUN apt-get update && apt-get -y upgrade
RUN apt install -y curl gzip unzip

ARG VERSION
ENV VERSION $VERSION

ARG MICROMDM_API_KEY
ENV MICROMDM_API_KEY $MICROMDM_API_KEY

ARG NANO_API_KEY
ENV NANO_API_KEY $NANO_API_KEY

ARG NANO_URL
ENV NANO_URL $NANO_URL

WORKDIR /service/micro2nano

RUN curl -RLO https://github.com/micromdm/micro2nano/releases/download/v$VERSION/cmdapi-linux-amd64-v$VERSION.zip

RUN unzip cmdapi-linux-amd64-v$VERSION.zip

RUN chmod a+x ./cmdapi-linux-amd64

EXPOSE 9001

CMD ./cmdapi-linux-amd64 -api-key $MICROMDM_API_KEY -nano-api-key $NANO_API_KEY -nano-url $NANO_URL
