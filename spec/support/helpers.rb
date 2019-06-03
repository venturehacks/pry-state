require 'stringio'

class << Pry
  alias_method :orig_reset_defaults, :reset_defaults
  def reset_defaults
    orig_reset_defaults

    Pry.color = false
    Pry.pager = false
    Pry.config.should_load_rc       = false
    Pry.config.should_load_local_rc = false
    Pry.config.should_load_plugins  = false
    Pry.config.history.should_load  = false
    Pry.config.history.should_save  = false
    Pry.config.auto_indent          = false
    #Pry.config.hooks                = Pry::Hooks.new
    Pry.config.collision_warning    = false
    Pry.config.extra_sticky_locals = {}
  end
end


class InputTester
  def initialize(*actions)
    if actions.last.is_a?(Hash) && actions.last.keys == [:history]
      @hist = actions.pop[:history]
    end
    @orig_actions = actions.dup
    @actions = actions
  end

  def readline(*)
    @actions.shift.tap{ |line| @hist << line if @hist }
  end

  def rewind
    @actions = @orig_actions.dup
  end
end


# Set I/O streams.
#
# Out defaults to an anonymous StringIO.
#
def redirect_pry_io(new_in, new_out = StringIO.new)
  old_in = Pry.input
  old_out = Pry.output

  Pry.input = new_in
  Pry.output = new_out
  begin
    yield if block_given?
  ensure
    Pry.input = old_in
    Pry.output = old_out
  end
end

