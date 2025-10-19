require 'sinatra'
require 'socket'

# In-memory visitor counter
$counter = 0

# Route
get '/' do
  $counter += 1
  hostname = Socket.gethostname
  ruby_version = RUBY_VERSION
  environment = ENV['RACK_ENV'] || "development"

  <<~HTML
    <h1>Hello from Ruby Sinatra 🚀</h1>
    <p>Server Hostname: #{hostname}</p>
    <p>Ruby Version: #{ruby_version}</p>
    <p>Environment: #{environment}</p>
    <p>You are visitor number: #{$counter}</p>
  HTML
end
