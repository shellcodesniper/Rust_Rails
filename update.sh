#!/bin/zsh

cd /WorkSpace/Rust_Rails

git pull

bundle install

bundle exec rake assets:precompile RAILS_ENV=production
bundle exec rake db:migrate RAILS_ENV=production

sudo service apache2 restart