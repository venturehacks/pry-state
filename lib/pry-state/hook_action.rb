require 'set'

module PryState

  class Hook
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


      def run_hook output, binding, pry
        output.puts pry.config.state_config.status
        action = PryState::Hook::Action.new binding, pry
        action.process_visible!
        action.each_line do |line|
          output.puts line
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


    def initialize
      Pry.config.state_config = PryState::Config.new( 
        Pry.config.state_hook_enabled,
        truncate: Pry.config.state_truncate_enabled
      )
    end



    def call( output, binding, pry )
      if pry.config.state_config.enabled?
        PryState::Hook.run_hook output, binding, pry
      end
    end


    class Action

      def initialize _binding, pry
        @binding  = _binding
        @pry      = pry
        @config   = pry.config.state_config
        @format = "%-#{@config.left_column_width}s %-s"
      end


      def check_state type
        vars = Set.new @binding.eval("#{type}_variables")
        if PryState::Hook.const_defined? "IGNORABLE_#{type.upcase}_VARS"
          vars -= PryState::Hook.const_get("IGNORABLE_#{type.upcase}_VARS")
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
        @config.prev.replace @data
      end


      def each
        return enum_for(:each) unless block_given?
        @data.each do |type,data|
          yield type, data
        end
      end


      def each_line
        each do |type,data|
          colk, colv = *TYPES_AND_COLOURS[type]
          data.each do |var, value|
            val_format = "%-s"
            if value.nil?
              value = "nil"
              colk = "red"
            else
              value = stringify(value)
              if @config.truncating? and value.size > @config.right_column_width
                new_length = @config.right_column_width - 4
                val_format = "%-#{new_length}.#{new_length}s..."
              end
            end
            left = Pry::Helpers::Text.send(colk, var)
            left_diff = left.length - var.length
            line = sprintf "%-#{@config.left_column_width + left_diff}s #{val_format}", left, value
            yield line
          end
        end
      end


      private


      def stringify value
        if value.respond_to? :chars
          %Q!"#{value}"!
        elsif value.respond_to? :push
          "len:#{value.count} #{value.inspect}"
        elsif value.respond_to? :to_s
          value.to_s
        else
          value.inspect
        end
      end



      attr_reader :binding, :pry


      def value_changed? var, value
        return nil if @config[:pry_state_prev].empty?
        @config.prev[var] != value
      end
    end

  end

end