FROM ruby:2.7.2
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

WORKDIR /apptegy
COPY Gemfile /apptegy/Gemfile
COPY Gemfile.lock /apptegy/Gemfile.lock
RUN bundle install
COPY . /apptegy

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]