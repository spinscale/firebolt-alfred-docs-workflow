require "json"
require "http"
require "fuzzy_match"

# make sure the path exists
path = Path.home / ".config" / "firebolt-alfred-docs-workflow.cr" / "data"
if !File.exists?(path)
  Dir.mkdir_p path
end

# simple locking mechanism, if another process in the background is already 
# fetching the json data
lock_path = path / "search-data.json.lock"
if File.exists?(lock_path)
  exit
end

# check for download in last 8h
# and write to local file
json_path = path / "search-data.json"
if !File.exists?(json_path) || (Time.utc - File.info(json_path).modification_time > 8.hours)
  File.touch lock_path
  begin
    response = HTTP::Client.get "https://docs.firebolt.io/assets/js/search-data.json"
    File.write json_path, response.body
  ensure
    File.delete?(lock_path)
  end
end

# delete lock file again

json = File.open(json_path) do |file|
  JSON.parse(file)
end

data = json.as_h.values
titles = Array(String).new(data.size)
urls = Array(String).new(data.size)
contents = Array(String).new(data.size)
json.as_h.values.each do |e|
  titles << e["title"].as_s
  urls << e["url"].as_s
  contents << e["content"].as_s
end

# before going fancy with fuzzy matching, maybe there is a single direct match
idx = titles.index { |t| t.downcase == ARGV[0].downcase }
if !idx.nil?
  response = JSON.build do |json|
    json.object do
      json.field "items" do
        json.array do
          json.object do
            json.field "title", titles[idx]
            json.field "subtitle", titles[idx]
            json.field "arg", urls[idx]
            json.field "icon" do
              json.object do
                json.field "path", "#{Dir.current}/icon.png"
              end
            end
          end
        end
      end
    end
  end
  puts response
  exit
end

# search titles first
results = FuzzyMatch.search(ARGV[0], titles)
found_in_titles = results.size > 0

if results.size == 0
  results = FuzzyMatch.search(ARGV[0], contents)
end

if results.size == 0
  response = JSON.build do |json|
    json.object do
      json.field "items" do
        json.array do
          json.object do
            json.field "title", "No results found"
            json.field "icon" do
              json.object do
                json.field "path", "#{Dir.current}/icon.png"
              end
            end
          end
        end
      end
    end
  end
else
  response = JSON.build do |json|
    json.object do
      json.field "items" do
        json.array do
          results.each do |hit|
            json.object do
              input = hit.str
              if found_in_titles
                idx = titles.index hit.str
                if !idx.nil?
                  json.field "title", titles[idx]
                  json.field "subtitle", titles[idx]
                  json.field "arg", urls[idx]
                end
              else
                idx = contents.index hit.str
                if !idx.nil?
                  json.field "title", contents[idx]
                  json.field "subtitle", contents[idx]
                  json.field "arg", urls[idx]
                end
              end
              json.field "icon" do
                json.object do
                  json.field "path", "#{Dir.current}/icon.png"
                end
              end
            end
          end
        end
      end
    end
  end
end


puts response

