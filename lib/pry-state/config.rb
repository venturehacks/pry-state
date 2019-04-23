module PryState


  class Config
    DEFAULT_GROUPS_VISIBILITY = {
      :global   => false,
      :instance => true,
      :local    => true
    }.freeze

    def initialize config=nil
      @groups_visibility = DEFAULT_GROUPS_VISIBILITY.dup
      @vars_visibility   = {}
      @prev = {}
      @enabled = false
    end

    attr_reader :groups
    attr_accessor :prev, :enabled


    def enabled?
      @enabled
    end


    def toggle_group_visibility name
      name = name.to_sym
      if @groups_visibility.has_key?(name)
        @groups_visibility[name] = !name
      else
        @groups_visibility[name] = true
      end
    end


    def toggle_var_visibility name
      name = name.to_sym
      if @vars_visibility.has_key?(name)
        @vars_visibility[name] = !name
      else
        @vars_visibility[name] = true
      end
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
  end

  
  class << self
    def Config config=nil
      PryState::Config.new config
    end
  end

end