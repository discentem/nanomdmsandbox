# syntax=docker/dockerfile:1

##
## Build
##
FROM --platform=linux/amd64 golang:1.18-buster AS build


# need to do this so go mod download works
WORKDIR github.com/discentem/nanomdmsandbox/cli

COPY nanomdmsandbox/cli .

#RUN rm go.mod go.sum
#RUN go mod init github.com/discentem/nanomdmsandbox/cli
RUN go mod download
RUN go build -o /enroll-endpoint

##
## Deploy
##
FROM --platform=linux/amd64 gcr.io/distroless/base-debian10

ARG BASE_URL
ENV BASE_URL $BASE_URL

ARG COMPANY
ENV COMPANY $COMPANY

ARG SCEP_CHALLENGE
ENV SCEP_CHALLENGE $SCEP_CHALLENGE

WORKDIR /service/enroll_endpoint

COPY --from=build /enroll-endpoint /service/enroll_endpoint/enroll-endpoint
# COPY --from=build /mdm_push_cert.pem /mdm_push_cert.pem

COPY ../../config/certs/mdm_push_cert.pem /service/enrollment_endpoint/mdm_push_cert.pem

EXPOSE 9203

CMD ["enroll-endpoint", "--push_pem_path", "mdm_push_cert.pem", "enrollment_endpoint", "--port", "9203", "--base_url", $BASE_URL, "--company", $COMPANY, "--scep_challenge", $SCEP_CHALLENGE]