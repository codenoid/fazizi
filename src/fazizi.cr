require "./fazizi/*"
require "kemal"
require "yaml"

if !File.exists?("./config.yml")
  raise "Config file not found"
end

config = File.read("./config.yml")
config = YAML.parse config
config = config.as_h

if !config.has_key?("text_source")
  raise "text_source not found"
end

text_source = config["text_source"].to_s

text = [] of String
size = 0

if text_source.includes?("://")
  get = HTTP::Client.get text_source
  if get.success?
    body = get.body.to_s
    text = body.split("\n")
    size = text.size-1
  else
    raise "Failed to load stream : #{text_source}"
  end
else
  text = File.read_lines(config["text_source"].to_s)
  size = text.size-1
end

get "/" do |env|
  query = env.params.query
  if !query.has_key?("category") && !query.has_key?("lang")
    rand = text[Random.rand(0..size)]
    rand
  end
end

Kemal.run
