PryState::Commands = Pry::CommandSet.new

require_relative "commands/truncate_state.rb"
require_relative "commands/show_state.rb"

Pry.commands.import PryState::Commands
