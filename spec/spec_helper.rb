require "rspec/given"
require 'stringio'
require 'pry'
require 'pathname'
require 'pry/testable'

Pathname(__dir__).join("support").glob "**/*.rb" do |rb|
  require rb
end

Pad = Class.new do
  include Pry::Config::Behavior
end.new(nil)

RSpec.configure do |config|
  Pry.config.extra_sticky_locals = {}
  Pry.config.should_load_rc = false
  Pry.config.pager = false
  config.include Pry::Testable::Mockable
  config.include Pry::Testable::Utility
  include Pry::Testable::Evalable
  include Pry::Testable::Variables
end
