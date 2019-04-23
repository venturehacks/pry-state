PryState::Commands = Pry::CommandSet.new

require_relative "commands/show_state.rb"
require_relative "commands/toggle_state.rb"


Pry.commands.import PryState::Commands
