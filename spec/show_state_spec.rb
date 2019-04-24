require "spec_helper"
require_relative "../lib/pry-state.rb"

RSpec.describe "show-state" do
  context "prints local variables" do
    Given(:test_string) { "secret message"}

    When(:output) { capture_pry_command("show-state", binding) }
    Given(:expected) {
      <<~'STR'
        \e[0;36mtest_string          \e[0m\e[0;37m"secret message"\e[0m\n
      STR
    }
    Then { output == expected }
  end

  context "prints instance variables" do
    before do
      @instance_test = "#winning"
    end
    When(:output) { capture_pry_command("show-state", binding) }
    Given(:expected) {
      <<~'STR'
        \e[0;32m@instance_test       \e[0m\e[0;37m"#winning"\e[0m\n
      STR
    }
    Then { output == expected }
  end

  context "prints objects" do
    When(:output) {
      test_object = Object.new
      capture_pry_command("show-state", binding)
    }
    Given(:expected) {
      <<~STR
        \e[0;36mtest_object          \e[0m\e[0;37m#{test_object}\e[0m\n
      STR
    }
    Then { output == expected }
  end

  context "doesn't print constants" do
    before do
      TestMe = Struct.new(:one, :two)
    end

    When(:output) { capture_pry_command("show-state", binding) }
    Given(:unexpected) { "TestMe" }
    Then { ! output == unexpected }
  end

  context "when hook_enabled=false" do
    before do
      @conf_before = Pry.config.state_hook_enabled
      Pry.config.state_hook_enabled = false
    end

    context "prints state" do
      Given(:test_object) { Object.new }
      Given(:expected) {
        <<~STR
        \e[0;36mtest_object          \e[0m\e[0;37m#{test_object}\e[0m\n
        STR
      }
      When(:output) {
        capture_pry_command("show-state", binding)
      }
      Then { output == expected }
    end
  end
end
