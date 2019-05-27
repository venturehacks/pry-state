require 'spec_helper'
require_relative "../lib/pry-state.rb"

describe "pry-state" do
  Given(:pry_instance) { Pry.new }
  Given(:config) { pry_instance.config.state_config }

  context "Set up" do

    context "Defaults" do
      before do
        Pry.hooks.add_hook(:before_session, :state_hook, PryState::Hook.new)
      end
      after do
        Pry.hooks.delete_hook(:before_session, :state_hook)
      end
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
      Then { config.prev == {} }
      Then { Pry.hooks.hook_exists? :before_session,  :state_hook }
    end

    context "Enabled" do
      before do
        Pry.config.state_hook_enabled = true
        Pry.hooks.add_hook(:before_session, :state_hook, PryState::Hook.new)
      end
      after do
        Pry.hooks.delete_hook(:before_session, :state_hook)
        Pry.config.state_hook_enabled = false
      end
      Then  { Pry.config.state_hook_enabled }
      And  { Pry.config.state_hook_enabled.kind_of? TrueClass }
      And  { pry_instance.config.state_hook_enabled }
      And  { pry_instance.config.state_hook_enabled.kind_of? TrueClass }
      And  { config.kind_of? PryState::Config }
      And  { config.respond_to? :enabled? }
      And  { pry_instance.config.state_config.kind_of? PryState::Config }
      And  { config.enabled? }
      And  { pry_instance.config.state_config == config }
      And  { pry_instance.config.state_config.enabled? }
    end
  end

  context "Output" do
    Given(:obj) {
      obj = Object.new
      class << obj
        attr_accessor :first_method, :second_method, :third_method
      end
      def obj.bing() @x=12; bong end
      def obj.bong() bang end
      def obj.bang() Pry.start(binding) end
      obj
    }
    long_var = '[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80]'
    Given(:out) { StringIO.new }

    context "Truncation" do
      context "Given a default set up, truncation is off" do
        When {
          redirect_pry_io(
            # The no color line is here because setting it in the config
            # above seems to have no effect, so, that's why.
            InputTester.new("_pry_.config.color = false",
                            "z = 14",
                            "ys = #{long_var}",
                            "state-show",
                            "exit-all"),
                            out
                          ) do
            obj.bing
          end
        }

        Then { config.prev.kind_of? Hash }
        And  { config.prev.keys == [:instance, :local] }
        And  { out.string.include? "global: false instance: true local: true truncating?: false" }
        And  { out.string.include? "@x                   12" }
        And  { out.string.include? "z                    14" }
        And  { out.string.include? "ys                   len:80 #{long_var}" }
      end
      context "With the truncate on" do
        When {
          redirect_pry_io(
            # The no color line is here because setting it in the config
            # above seems to have no effect, so, that's why.
            InputTester.new("_pry_.config.color = false",
                            "state-truncate on",
                            "z = 14",
                            "ys = #{long_var}",
                            "state-show",
                            "exit-all"),
                            out
                          ) do
            obj.bing
          end
        }

        Then { config.prev.kind_of? Hash }
        And  { config.prev.keys == [:instance, :local] }
        And  { out.string.include? "global: false instance: true local: true truncating?: true" }
        And  { out.string.include?  "@x                   12" }
        And  { out.string.include?  "z                    14" }
        And  { !out.string.include? "ys                   len:80 #{long_var}" }
        And  { out.string.include?  "ys                   len:80 [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 1..." }
      end
      context "truncate on then truncate off" do
        When {
          redirect_pry_io(
            # The no color line is here because setting it in the config
            # above seems to have no effect, so, that's why.
            InputTester.new("_pry_.config.color = false",
                            "state-truncate on",
                            "z = 14",
                            "ys = #{long_var}",
                            "state-show",
                            "state-truncate off",
                            "state-show",
                            "exit-all"),
                            out
                          ) do
            obj.bing
          end
        }
        Then { out.string.include?  "ys                   len:80 #{long_var}" }
        And  { out.string.include?  "ys                   len:80 [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 1..." }
      
      end
    end


    context "Toggling globals" do
      context "Globals are off by default" do
        When {
          redirect_pry_io(
            # The no color line is here because setting it in the config
            # above seems to have no effect, so, that's why.
            InputTester.new("_pry_.config.color = false",
                            "state-show",
                            "exit-all"),
                            out
                          ) do
            obj.bing
          end
        }
        Then { !out.string.include? "$PROCESS_ID"}
      end
      context "state-show g" do
        When {
          redirect_pry_io(
            # The no color line is here because setting it in the config
            # above seems to have no effect, so, that's why.
            InputTester.new("_pry_.config.color = false",
                            "state-show g",
                            # turn it back off because too many warnings
                            # pop up in the rest of the spec run otherwise
                            "state-show g",
                            "exit-all"),
                            out
                          ) do
            obj.bing
          end
        }
        Then { out.string.include? "$PROCESS_ID"}
      end
    end

    context "Toggling instance vars" do
      context "Instance vars are on by default" do
        When {
          redirect_pry_io(
            # The no color line is here because setting it in the config
            # above seems to have no effect, so, that's why.
            InputTester.new("_pry_.config.color = false",
                            "state-show",
                            "exit-all"),
                            out
                          ) do
            obj.bing
          end
        }
        Then { out.string.include? "@x                   12"}
      end
      context "state-show i off" do
        When {
          redirect_pry_io(
            # The no color line is here because setting it in the config
            # above seems to have no effect, so, that's why.
            InputTester.new("_pry_.config.color = false",
                            "state-show i",
                            "exit-all"),
                            out
                          ) do
            obj.bing
          end
        }
        Then { !out.string.include? "@x                   12"}
      end
      context "state-show i off then on" do
        When {
          redirect_pry_io(
            # The no color line is here because setting it in the config
            # above seems to have no effect, so, that's why.
            InputTester.new("_pry_.config.color = false",
                            "state-show i",
                            "state-show i",
                            "exit-all"),
                            out
                          ) do
            obj.bing
          end
        }
        Then { out.string.include? "@x                   12"}
        And  { out.string.include? "instance: false" }
        And  { out.string.include? "instance: true" }
      end
    end

    context "Toggling local vars" do
      context "Local vars are on by default" do
        When {
          redirect_pry_io(
            # The no color line is here because setting it in the config
            # above seems to have no effect, so, that's why.
            InputTester.new("_pry_.config.color = false",
                            "z = 14",
                            "state-show",
                            "exit-all"),
                            out
                          ) do
            obj.bing
          end
        }
        Then { out.string.include? "z                    14"}
        And  { out.string.include? "local: true" }
      end
      context "state-show l" do
        context "Locals off then on" do
          When {
            redirect_pry_io(
              # The no color line is here because setting it in the config
              # above seems to have no effect, so, that's why.
              InputTester.new("_pry_.config.color = false",
                              "z = 14",
                              "state-show l",
                              "state-show l",
                              "exit-all"),
                              out
                            ) do
              obj.bing
            end
          }
          Then { out.string.include? "z                    14"}
          And  { out.string.include? "local: false" }
          And  { out.string.include? "local: true" }
        end
        context "Locals off" do
          When {
            redirect_pry_io(
              # The no color line is here because setting it in the config
              # above seems to have no effect, so, that's why.
              InputTester.new("_pry_.config.color = false",
                              "z = 14",
                              "state-show l",
                              "exit-all"),
                              out
                            ) do
              obj.bing
            end
          }
          Then { !out.string.include? "z                    14"}
          And  { out.string.include? "local: false"}
          And  { !out.string.include? "local: true" }
        end
      end
    end


    context "Toggling all" do
      context "state-show a" do
        When {
          redirect_pry_io(
            # The no color line is here because setting it in the config
            # above seems to have no effect, so, that's why.
            InputTester.new("_pry_.config.color = false",
                            "z = 14",
                            "state-show a",
                            "exit-all"),
                            out
                          ) do
            obj.bing
          end
        }
        Then { out.string.include? "$PROCESS_ID"}
        And  { out.string.include? "@x                   12" }
        And  { out.string.include? "z                    14"}
        And  { out.string.include? "global: true instance: true local: true truncating?: false"}
      end
      context "state-show n" do
        When {
          redirect_pry_io(
            # The no color line is here because setting it in the config
            # above seems to have no effect, so, that's why.
            InputTester.new("_pry_.config.color = false",
                            "z = 14",
                            "state-show n",
                            "state-show",
                            "exit-all"),
                            out
                          ) do
            obj.bing
          end
        }
        Then { !out.string.include? "$PROCESS_ID"}
        And  { !out.string.include? "@x                   12" }
        And  { !out.string.include? "z                    14"}
        And  { out.string.include? "global: false instance: false local: false truncating?: false" }
        after do
          Pry.config.state_config = PryState::Config.new( 
            Pry.config.state_hook_enabled,
            truncate: Pry.config.state_truncate_enabled
          )
        end
      end
    end


    context "on/off" do
      context "state-show off" do
        When {
          redirect_pry_io(
            # The no color line is here because setting it in the config
            # above seems to have no effect, so, that's why.
            InputTester.new("_pry_.config.color = false",
                            "state-show off",
                            "z = 14",
                            '%Q!enabled? #{_pry_.config.state_config.enabled?}!',
                            "exit-all"),
                            out
                          ) do
            obj.bing
          end
        }
        Then { !out.string.include? "$PROCESS_ID"}
        Then { !out.string.include? "z                    14"}
        Then { !out.string.include? "global:"}
        Then { !out.string.include? "instance:"}
        Then { !out.string.include? "local:"}
        Then { !out.string.include? "truncating?:"}
        Then {  out.string.include? "enabled? false" }
      end
      context "state-show on" do
        When {
          redirect_pry_io(
            # The no color line is here because setting it in the config
            # above seems to have no effect, so, that's why.
            InputTester.new("_pry_.config.color = false",
                            "state-show on",
                            '%Q!enabled? #{_pry_.config.state_config.enabled?}!',
                            "z = 14",
                            "%q!hello!",
                            "exit-all"),
                            out
                          ) do
            obj.bing
          end
        }
        Then { out.string.include? "global: false instance: true local: true truncating?: false"}
        #And  { out.string.include? "z                    14"}
        Then {  out.string.include? "enabled? true" }
      end

    end
  end

end