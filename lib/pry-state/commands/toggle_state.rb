module PryState
  class ToggleState < Pry::ClassCommand
    match "state-toggle"
    group "State"
    description "Toggle automatic pry-State display."

    def options(opt)
      opt.banner unindent <<-USAGE
        Usage: state-toggle

        state-toggle will toggle automatic state display. Off by default.
        Set `Pry.config.state_hook_enabled = true` in your .pryrc file to
        permanently enable it.

        Use `state-show` to show the current state.
      USAGE
    end


    def process
      _pry_.config.extra_sticky_locals[:pry_state].enabled ^= true

      if _pry_.config.extra_sticky_locals[:pry_state].enabled?
        output.puts "pry-state enabled."
        run "state-show"
      else
        output.puts "pry-state disabled."
      end
    end
  end

end

PryState::Commands.add_command PryState::ToggleState
