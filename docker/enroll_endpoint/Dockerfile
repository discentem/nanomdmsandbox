# syntax=docker/dockerfile:1

FROM --platform=linux/amd64 golang:1.17-alpine AS build

ARG BASE_URL
ENV BASE_URL $BASE_URL

ARG COMPANY
ENV COMPANY $COMPANY

ARG SCEP_CHALLENGE
ENV SCEP_CHALLENGE $SCEP_CHALLENGE

##
## Build
##

WORKDIR /github.com/discentem/nanomdmsandbox

COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o enroll_endpoint ./cmd/enroll/main.go

##
## Deploy
##
FROM --platform=linux/amd64 ubuntu:20.04

ENV BASE_URL $BASE_URL

ENV COMPANY $COMPANY

ENV SCEP_CHALLENGE $SCEP_CHALLENGE

WORKDIR /service/enroll_endpoint

COPY --from=build /github.com/discentem/nanomdmsandbox/enroll_endpoint /service/enroll_endpoint/enroll_endpoint

RUN chmod a+x ./enroll_endpoint

COPY ./docker/config/certs/mdm_push_cert.pem ./mdm_push_cert.pem

EXPOSE 9300

CMD ./enroll_endpoint --base_url=${BASE_URL} --company=${COMPANY} --push_pem_path mdm_push_cert.pem --scep_challenge=${SCEP_CHALLENGE}
