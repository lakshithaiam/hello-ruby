FROM ruby:3.3-alpine

WORKDIR /app

# Install build dependencies for native gems
RUN apk add --no-cache build-base

# Copy Gemfile and install gems
COPY Gemfile Gemfile.lock* ./
RUN bundle install

# Copy app
COPY app.rb .

EXPOSE 4567
CMD ["bundle", "exec", "ruby", "app.rb", "-o", "0.0.0.0"]
