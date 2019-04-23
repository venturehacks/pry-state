require "pry"
require_relative "pry-state/version"
require_relative "pry-state/config.rb"
require_relative "pry-state/hook_action.rb"
require_relative "pry-state/commands.rb"

# Will the state be displayed automatically?
Pry.config.state_hook_enabled ||= false


Pry.config.extra_sticky_locals[:pry_state] = PryState::Config.new

Pry.hooks.add_hook(:before_session, :state_hook) do |output, binding, pry|
  if pry.config.extra_sticky_locals[:pry_state].enabled?
    action = PryState::HookAction.new binding, pry, config: pry.config.extra_sticky_locals[:pry_state]
    action.process_visible!
    action.print_lines
  end
end
