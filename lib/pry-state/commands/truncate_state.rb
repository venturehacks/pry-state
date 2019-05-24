module PryState
  class TruncateState < Pry::ClassCommand
    match /^state-truncate\s*(o(?:(?:n)|(?:ff))){0,1}$/
    options listing: "state-truncate"
    group "State"
    description "Truncate pry-State display."

    def options(opt)
      opt.banner unindent <<-USAGE
        Usage: state-truncate

        `state-truncate` will toggle the truncation of state display.
        `state-truncate on` will set it to on.
        `state-truncate off` will set it to off.
        Default is "on".
        
        Set `Pry.config.state_truncate_enabled = false` in your .pryrc file to
        disable it from start up.

        Use `state-show` to show the current state.
      USAGE
    end


    def process
      config = _pry_.config.state_config

      case captures.first
        when "on"
          config.truncate_enabled = true
        when "off"
          config.truncate_enabled = false
        else
          config.truncate_enabled ^= true
      end
      if config.truncating?
        output.puts "Truncation of state display enabled."
      else
        output.puts "Truncation of state display disabled."
      end
      run "state-show"
    end
  end

end

PryState::Commands.add_command PryState::TruncateState
