require 'set'

module PryState

  class Hook
    class << self


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
    IGNORABLE_GLOBAL_VARS = [:$@, :$-I, :"$\"", :$LOAD_PATH, :$KCODE, :$=, :$LOADED_FEATURES, :$:]


    def call( output, binding, pry )
      Pry.config.state_config = PryState::Config.new( 
        Pry.config.state_hook,
        truncate: Pry.config.state_truncate
      )
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


      # group visible | var visible |
      #     t         |     f       |   f   delete
      #     f         |     t       |   t   replace
      def check_state type
        vs = @binding.eval("#{type}_variables")
        const = "IGNORABLE_#{type.upcase}_VARS"
        if PryState::Hook.const_defined? const
          vs -= PryState::Hook.const_get const
        end
        if !@config.vars_visibility[type].empty?
          if @config.group_visible? type
            finders = @config.vars_visibility[type].select{|_,v| v == false }.keys
            finders.each do |fdr|
              vs.delete(fdr) if vs.include? fdr
            end
          else
            vs.replace @config.vars_visibility[type].select{|_,v| v }.keys
          end
        end
        Hash[
          vs.map { |var|
            [ var, @binding.eval(var.to_s) ]
          }
        ]
      end


      # group visible | var maybe (!empty?)
      #     t         |     t       |     t
      #     t         |     f       |     t
      #     f         |     t       |     t
      #     f         |	    f       |     f
      def process_visible!
        @data = {}
        Config::TYPES_AND_COLOURS.keys.each_with_object(@data) do |type, data|
          next unless @config.group_visible? type or
                      !@config.vars_visibility[type].empty?
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
          colk, colv = *Config::TYPES_AND_COLOURS[type]
          data.each do |var, value|
            val_format = "%-s"
            if value.nil?
              value = "nil"
              colk = "red"
            else
              value = stringify(value)
              if it_should_be_truncated? var, value
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


      def it_should_be_truncated? var, value
        # first because it's better than checking every length
        if @config.truncate_exceptions.has_key?(var.to_sym)
          if @config.truncate_exceptions[var.to_sym] == :truncate
            if value.size > @config.right_column_width
              return true
            end
          end
          return false
        end

        if @config.truncating? and value.size > @config.right_column_width
          return true
        else
          false
        end
      end


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

    end

  end

end