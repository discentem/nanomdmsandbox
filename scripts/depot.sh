#!/bin/sh

curl -RL https://github.com/micromdm/scep/releases/download/v2.1.0/scepserver-darwin-amd64-v2.1.0.zip -o scepserver-darwin-amd64.zip
unzip scepserver-darwin-amd64.zip -d .
chmod +x scepserver-darwin-amd64; ./scepserver-darwin-amd64 ca -init
mkdir -p docker/config/certs/depot
cp -r depot/* docker/config/certs/depot
rm scepserver-darwin-amd64.zip
rm scepserver-darwin-amd64
rm -rf depot