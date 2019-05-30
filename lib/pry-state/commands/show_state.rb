require_relative "../patterns.rb"

module PryState
  class ShowState < Pry::ClassCommand
    match /^
            state\-show
            \s*
            (
              (?: g (?: lobals )? )
                |
              (?: i (?: nstances )? )
                |
              (?: l (?: ocals )? )
                |
              (?: a (?: ll )? )
                |
              (?: n (?: one )? )
                |
              (?: on )
                |
              (?: off )
                |
              (?: hidden )
                |
              (?: #{Patterns::VARIABLE_PATTERN} )
            ){0,1}
          $/x

    options listing: 'state-show'
    group "State"
    description "Display the current binding state, see `help state-show` for full power!"

    def options(opt)
      opt.banner unindent <<-USAGE
        Usage: state-show

        show-state will show the current binding state. For example:

          state-show

        will show you the current state of the app (depending on which
        variable groups you've decided to show). The default is to show
        only instance and local variables.

        If you want to hide or show particular groups, add them.
        Choose from:
          - global
          - instance
          - local
          - all (of the groups above)
          - none (of the groups above)

        e.g. state-show globals

        will toggle the status to now include global variables whenever
        you show-state. If they're already showing then they'll no longer
        show.
        As I'm really lazy, and as I assume everyone is like me, you 
        will be happy to know you can simply use the first letter
        e.g.
          state-show g # toggle on/off globals
          state-show a # show all available groups
          state-show n # hide these foul things that make life hard!

        To keep showing the state automatically then use `state-show on`.
        To turn it off use `state-show off`.
      USAGE
    end

    def process
      config = _pry_.config.state_config
      run_it = true
      case captures.first
        when "g"
          config.toggle_group_visibility "global"
        when "i"
          config.toggle_group_visibility "instance"
        when "l"
          config.toggle_group_visibility "local"
        when "a" # all
          config.groups_visibility[:global]    = true
          config.groups_visibility[:instance]  = true
          config.groups_visibility[:local]     = true
        when "n" # none
          config.groups_visibility[:global]    = false
          config.groups_visibility[:instance]  = false
          config.groups_visibility[:local]     = false
        when "on"
          config.enabled = true
        when "off"
          config.enabled = false
          run_it = false
        when "hidden"
          # show all hidden
        when nil
          # don't remove this or the else is hit when it
          # shouldn't be
        else
          config.toggle_var_visibility captures.first
      end
      if run_it
        PryState::Hook.run_hook output, target, _pry_
      end
    end


  end
end

PryState::Commands.add_command PryState::ShowState
