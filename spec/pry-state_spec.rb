require 'spec_helper'
require_relative "../lib/pry-state.rb"

describe "pry-state" do
  Given(:pry_instance) { Pry.new }
  Given(:config) { pry_instance.config.extra_sticky_locals[:pry_state] }
  Given(:hooks) { pry_instance.hooks }

  context "Set up" do
    context "Defaults" do
      Then { config.kind_of? PryState::Config }
      Then { !config.enabled? }
      Then {
        config.groups_visibility == PryState::Config::DEFAULT_GROUPS_VISIBILITY
      }
      Then { config.width == PryState::Config::WIDTH }
      Then { config.max_left_column_width == PryState::Config::MAX_LEFT_COLUMN_WIDTH }
      Then { config.column_ratio == PryState::Config::COLUMN_RATIO }
      Then { config.left_column_width == PryState::Config::LEFT_COLUMN_WIDTH }
      Then { config.right_column_width == PryState::Config::WIDTH - PryState::Config::LEFT_COLUMN_WIDTH }
      Then { !config.truncating? }
      Then { config.prev.empty? }
      Then { hooks.hook_exists? :before_session,  :state_hook }
    end
  end


  context "Given a default set up" do
    before(:each) do
      @o = Object.new
      class << @o
        attr_accessor :first_method, :second_method, :third_method
      end
      def @o.bing() bong end
      def @o.bong() bang end
      def @o.bang() Pry.start(binding) end
    end
    Given(:out) { StringIO.new }
    When {
      redirect_pry_io(
        # The no color line is here because setting it in the config
        # above seems to have no effect, so, that's why.
        InputTester.new("_pry_.config.color = false",
                        "state-show",
                        "exit-all"),
                        out
                      ) do
        @o.bing
      end
    }

    Then { config.prev.kind_of? Hash }
    Then { config.prev.keys == [:instance, :local] }
    Then { out.string.include? "global: false instance: true local: true truncating?: false" }
  end

end