require_relative "printer.rb"

module PryState

  class HookAction
    class << self
    
      def find_changed h1, h2
        s1 = Set.new h1.keys
        s2 = Set.new h2.keys
        intersection = s1 & s2 
        intersection.each_with_object({}) do |k,combined|
          combined[k] = h1[k] if h1[k] == h2[k]
          combined
        end
      end
    end


    IGNORABLE_LOCAL_VARS = [:__, :_, :_ex_, :_pry_, :_out_, :_in_, :_dir_, :_file_, :pry_state]

    CONTROLLER_INSTANCE_VARIABLES = [:@_request, :@_response, :@_routes]
    RSPEC_INSTANCE_VARIABLES = [:@__inspect_output, :@__memoized]
    IGNORABLE_INSTANCE_VARS = CONTROLLER_INSTANCE_VARIABLES + RSPEC_INSTANCE_VARIABLES
    IGNORABLE_GLOBAL_VARS = [:$@]

    TYPES_AND_COLOURS = {
      :global   =>  %w{white yellow},
      :instance =>  %w{green white},
      :local    =>  %w{cyan white},
    }


    def initialize binding, pry, config:
      @binding, @pry = binding, pry
      @config = config
    end


    def check_state type
      vars = Set.new @binding.eval("#{type}_variables")
      if PryState::HookAction.const_defined? "IGNORABLE_#{type.upcase}_VARS"
        vars -= PryState::HookAction.const_get("IGNORABLE_#{type.upcase}_VARS")
      end
      
      Hash[ 
        vars.map { |var|
          [var,@binding.eval(var.to_s)]
        }
      ]
    end


    def process_visible!
      @data = {}
      TYPES_AND_COLOURS.keys.each_with_object(@data) do |type, data|
        next unless @config.group_visible? type
        data[type] = check_state type
      end
      @data.freeze
      @config.prev = @data
    end


    def print_lines
      @data.each do |type,data|
        colk, colv = *TYPES_AND_COLOURS[type]
        data.each do |key, value|
          eval_and_print key, value, var_color: colk, value_color: colv
        end
      end
    end


    private


    attr_reader :binding, :pry


    def eval_and_print var, value, var_color: 'green', value_color: 'white'
      # if value_changed? var, value
      #   var_color = "bright_#{var_color}"; value_color = 'bright_yellow'
      # end
      PryState::Printer.trunc_and_print var, value, var_color, value_color
    end


    def value_changed? var, value
      prev_state[var] and prev_state[var] != value
    end


    def stick_value! var, value
      prev_state[var] = value
    end


  end

end