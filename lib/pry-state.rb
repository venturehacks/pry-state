require "pry"
require_relative "pry-state/version"
require_relative "pry-state/config.rb"
require_relative "pry-state/hook_action.rb"
require_relative "pry-state/commands.rb"


Pry.config.extra_sticky_locals[:pry_state] = PryState::Config.new Pry.config

Pry.hooks.add_hook(:before_session, :state_hook) do |output, binding, pry|
  if pry.config.extra_sticky_locals[:pry_state].enabled?
    PryState::HookAction.run_hook output, binding, pry
  end
end
