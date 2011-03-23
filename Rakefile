require "rubygems"
require "rake"
require "echoe"

Echoe.new("devise_koala_connectable", "0.1.4") do |p|
  p.description = "Rails gem for adding Facebook authentification capabillity to devise using koala"
  p.url         = "http://github.com/webmatze/devise_koala_connectable"
  p.author      = "Mathias Karstädt"
  p.email       = "mathias.karstaedt@gmail.com"
  p.ignore_pattern  = ["tmp/*", "script/*"]
  p.runtime_dependencies = ["devise <=1.0.9", "koala"]
  p.development_dependencies = ["devise <=1.0.9", "koala"]
end

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }