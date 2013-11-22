#!/bin/bash
# ~/keinkopf/provision.sh
# should be executed using: ./keinkopf/provision.sh
sudo apt-get update
sudo apt-get install curl
\curl -L https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm
rvm
rvm requirements
rvm install ruby-1.9.3-p448
rvm use 1.9.3
rvm use 1.9.3 --default
echo "gem: --no-document" >> ~/.gemrc
rvm rubygems current
gem install rails
sudo apt-get install python-software-properties
sudo add-apt-repository ppa:ubuntu-mozilla-security/ppa
sudo apt-get update
sudo apt-get install firefox
sudo apt-get install xvfb
gem install headless
sudo apt-get install nodejs
cd keinkopf
bundle install
rails s
