module PryState
  class ShowState < Pry::ClassCommand
    match "state-show"
    group "State"
    description "Show the current binding state."

    def options(opt)
      opt.banner unindent <<-USAGE
        Usage: state-show

        show-state will show the current binding state.

        Use `state-toggle` to turn on automatic state display.
      USAGE
    end

    def process
      action = PryState::HookAction.new target, _pry_, config: _pry_.config.extra_sticky_locals[:pry_state]
      action.process_visible!
      action.print_lines
    end
  end
end

PryState::Commands.add_command PryState::ShowState
