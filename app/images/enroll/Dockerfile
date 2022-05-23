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

WORKDIR /

COPY --from=build /enroll-endpoint /enroll-endpoint
# COPY --from=build /mdm_push_cert.pem /mdm_push_cert.pem

COPY micromdm/mdm_push_cert.pem /mdm_push_cert.pem

EXPOSE 9203

ENTRYPOINT ["/enroll-endpoint", "--push_pem_path", "/mdm_push_cert.pem", "enrollment_endpoint", "--port", "9203", "--base_url", "mdm.bkurtz.cloud", "--company", "bkurtz.cloud", "--scep_challenge", "ThisIsAChallenge"]