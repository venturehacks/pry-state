require "rspec/given"
require 'stringio'
require 'pry'


RSpec.configure do |config|
  Pry.config.extra_sticky_locals = {}
end

def capture_stdout
  old_out = $stdout
  $stdout = Pry.output = fake = StringIO.new
  yield if block_given?
  fake.string
ensure
  $stdout = Pry.output = old_out
end


def capture_stderr
  old = $stderr
  $stderr = fake = StringIO.new
  yield if block_given?
  fake.string
ensure
  $stderr = old
end


def capture_pry_command(command, cmd_binding=binding)
  old_in = Pry.input
  Pry.input = StringIO.new("#{command}\nexit-all")
  capture_stdout do
    Pry.start_without_pry_nav(cmd_binding, hooks: Pry::Hooks.new)
  end
ensure
  Pry.input = old_in
end
