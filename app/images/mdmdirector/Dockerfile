FROM --platform=linux/amd64 ubuntu:20.04

RUN apt-get update && apt-get -y upgrade
RUN apt install -y curl gzip unzip

ARG VERSION
ENV VERSION $VERSION

ARG API_KEY
ENV API_KEY $API_KEY

ARG DB_USERNAME
ENV DB_USERNAME $DB_USERNAME

ARG DB_PASSWORD
ENV DB_PASSWORD $DB_PASSWORD

ARG DB_NAME
ENV DB_NAME $DB_NAME

ARG DB_PORT
ENV DB_PORT $DB_PORT

ARG DB_HOSTNAME
ENV DB_HOSTNAME $DB_HOSTNAME

ARG MICROMDM_API_KEY
ENV MICROMDM_API_KEY $MICROMDM_API_KEY

ARG MICROMDM_URL
ENV MICROMDM_URL $MICROMDM_URL

ARG MDMDIRECTOR_API_KEY
ENV MDMDIRECTOR_API_KEY $MDMDIRECTOR_API_KEY

WORKDIR /service/mdmdirector

RUN curl -RLO https://github.com/mdmdirector/mdmdirector/releases/download/v$VERSION/mdmdirector-linux

RUN chmod a+x ./mdmdirector-linux

EXPOSE 8000

CMD ./mdmdirector-linux -db-username ${DB_USERNAME} -db-password ${DB_PASSWORD} -db-host ${DB_HOSTNAME} -db-port ${DB_PORT} -db-sslmode require -db-name ${DB_NAME} -micromdmapikey ${MICROMDM_API_KEY} -micromdmurl ${MICROMDM_URL} -password ${MDMDIRECTOR_API_KEY} -loglevel debug
