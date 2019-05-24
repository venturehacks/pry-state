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


    def initialize enabled=false, truncate: false
      @groups_visibility = DEFAULT_GROUPS_VISIBILITY.dup
      @vars_visibility   = {}
      @enabled = !!enabled
      @width = WIDTH
      @max_left_column_width = MAX_LEFT_COLUMN_WIDTH
      @column_ratio = COLUMN_RATIO
      @left_column_width =
        [ ( @width / (@column_ratio + 1) ).floor, @max_left_column_width ].min
      @right_column_width = @width - @left_column_width
      @format = "%-#{@left_column_width}s %-s"
      @truncate_enabled = !!truncate
      @prev = {}
    end

    attr_reader :width, :max_left_column_width, :column_ratio, :left_column_width, :right_column_width, :format, :prev

    attr_reader :groups_visibility
    attr_accessor :enabled, :truncate_enabled


    def enabled?
      !!@enabled
    end


    def truncating?
      @truncate_enabled
    end


    def toggle_group_visibility name
      @groups_visibility[name.to_sym] ^= true
    end


    def toggle_var_visibility name
      @vars_visibility[name.to_sym] ^= true
    end


    def groups
      @groups_visibility.keys
    end


    def vars
      @vars_visibility.keys
    end


    def group_visible? name
      name = name.to_sym
      @groups_visibility.has_key?(name) && @groups_visibility[name]
    end


    def var_visible? name
      name = name.to_sym
      @vars_visibility.has_key?(name) && @vars_visibility[name]
    end


    def status
      statuses = %w{global instance local}.map { |type|
        val = @groups_visibility[type.to_sym]
        colour = @groups_visibility[type.to_sym] ? "cyan" : "magenta"
        str = %Q!#{Pry::Helpers::Text.yellow(type)}: #{Pry::Helpers::Text.send colour, val}!
      }
      colour = truncating? ? "cyan" : "magenta"
      statuses << "#{Pry::Helpers::Text.yellow("truncating?")}: #{Pry::Helpers::Text.send colour, truncating?}"
      "  " << statuses.join(" ")
    end
  end

  
  class << self
    def Config config=nil
      PryState::Config.new config
    end
  end

end