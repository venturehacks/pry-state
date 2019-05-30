require_relative "../patterns.rb"

module PryState
  class TruncateState < Pry::ClassCommand
    match /^ state-truncate (?:\s* ( #{Patterns::VARIABLE_PATTERN} ))? $/x
    options listing: "state-truncate"
    group "State"
    description "Truncate pry-State display."

    def options(opt)
      opt.banner unindent <<-USAGE
        Usage: state-truncate

        `state-truncate` will toggle the truncation of state display.
        `state-truncate NAME-OF-VARIABLE` will toggle the truncation of a variable.
        
        Set `Pry.config.state_truncate = true` in your .pryrc file to
        enable it from start up.

        Use `state-show` to show the current state.
      USAGE
    end


    def process
      config = _pry_.config.state_config
      if captures.first.nil? or captures.first.empty?
        config.truncate_enabled = !config.truncating?
      else
        sym = captures.first.to_sym
        if config.truncate_exceptions.has_key? sym
          config.truncate_exceptions[sym] = 
            config.truncate_exceptions[sym] == :truncate ?
              :normal :
              :truncate
        else
          config.truncate_exceptions[sym] = config.truncating? ?
            :normal :
            :truncate
        end
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
