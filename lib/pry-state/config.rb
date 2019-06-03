module PryState


  class Config

    WIDTH = ENV['COLUMNS'] ? ENV['COLUMNS'].to_i : 80
    MAX_LEFT_COLUMN_WIDTH = 25
    # Ratios are 1:3 left:right, or 1/4 left
    COLUMN_RATIO = 3 # right column to left ratio
    LEFT_COLUMN_WIDTH = [(WIDTH / (COLUMN_RATIO + 1)).floor, MAX_LEFT_COLUMN_WIDTH].min


    DEFAULT_GROUPS_VISIBILITY = {
      :global   => false,
      :instance => true,
      :local    => true
    }.freeze


    TYPES_AND_COLOURS = {
      :global   =>  %w{white yellow},
      :instance =>  %w{green white},
      :local    =>  %w{cyan white},
    }.freeze


    def initialize enabled=nil, truncate:
      @groups_visibility = DEFAULT_GROUPS_VISIBILITY.dup
      @vars_visibility   = {
        :global   => {},
        :instance => {},
        :local    => {}
      }
      @enabled = enabled.nil? ?
        !!Pry.config.state_hook :
        !!enabled
      @width = WIDTH
      @max_left_column_width = MAX_LEFT_COLUMN_WIDTH
      @column_ratio = COLUMN_RATIO
      @left_column_width =
        [ ( @width / (@column_ratio + 1) ).floor, @max_left_column_width ].min
      @right_column_width = @width - @left_column_width
      @truncate_enabled = truncate.nil? ?
        !!Pry.config.state_truncate :
        !!truncate
      @truncate_exceptions = {}
      @prev = {}
    end

    attr_reader :width, :max_left_column_width, :column_ratio, :left_column_width, :right_column_width, :prev

    attr_reader :groups_visibility, :truncate_exceptions, :vars_visibility
    attr_accessor :enabled
    attr_writer :truncate_enabled


    def enabled?
      !!@enabled
    end


    def truncating?
      @truncate_enabled
    end


    def toggle_group_visibility name
      @groups_visibility[name.to_sym] = !@groups_visibility[name.to_sym]
    end


    def toggle_var_visibility name
      name = name.to_sym
      type = 
        case name.to_s
        when /^\$/
          :global
        when /^@/
          :instance
        else
          :local
        end
      if @vars_visibility[type].has_key? name
        @vars_visibility[type][name] = !@vars_visibility[type][name]
      else
        @vars_visibility[type][name] = !group_visible?(type)
      end
    end


    def group_visible? name
      name = name.to_sym
      @groups_visibility.has_key?(name) && @groups_visibility[name]
    end


    def status
      statuses = %w{global instance local}.map { |type|
        val = @groups_visibility[type.to_sym]
        colour = @groups_visibility[type.to_sym] ? "cyan" : "magenta"
        str = %Q!#{Pry::Helpers::Text.yellow(type)}: #{Pry::Helpers::Text.send colour, val}!
      }
      colour = truncating? ? "cyan" : "magenta"
      statuses << "#{Pry::Helpers::Text.yellow("truncating?")}: #{Pry::Helpers::Text.send colour, truncating?}"
      "State__  " << statuses.join(" ")
    end
  end


end