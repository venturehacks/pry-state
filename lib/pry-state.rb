require "pry"
require_relative "pry-state/version"
require_relative "pry-state/config.rb"
require_relative "pry-state/hook_action.rb"
require_relative "pry-state/commands.rb"

Pry.hooks.add_hook(:before_session, :state_hook, PryState::Hook.new)