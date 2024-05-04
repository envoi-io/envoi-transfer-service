#!/usr/bin/env bash

TARGET_BASE_DIR=/opt/envoi

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y ruby-dev
sudo apt-get install -y build-essential
sudo gem install bundler
sudo gem install aspera-cli
sudo mkdir -p "${TARGET_BASE_DIR}"
sudo chown -R ubuntu:ubuntu "${TARGET_BASE_DIR}"
cd "${TARGET_BASE_DIR}" || exit 1
git clone https://github.com/envoi-io/envoi-transfer-service.git
cd "${TARGET_BASE_DIR}/envoi-transfer-service/src/envoi-transfer-worker" || exit 1
sudo bundle install
sudo ruby install-worker-service.rb