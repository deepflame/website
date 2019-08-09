FROM ruby:2.6.2

RUN apt-get update -qq && apt-get install -y build-essential nodejs
RUN mkdir /site
WORKDIR /site
ADD Gemfile /site/Gemfile
ADD Gemfile.lock /site/Gemfile.lock
RUN bundle install

ADD . /site
