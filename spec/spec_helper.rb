require "rspec/given"
require 'stringio'
require 'pry'
require 'pathname'

Pathname(__dir__).join("support").glob "**/*.rb" do |rb|
  require rb
end


RSpec.configure do |config|
  Pry.config.extra_sticky_locals = {}
  Pry.config.should_load_rc = false
  Pry.config.pager = false
end
