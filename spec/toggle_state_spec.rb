require "spec_helper"
require_relative "../lib/pry-state.rb"

RSpec.describe "toggle-state" do
  context "when the hook is enabled" do
    before do
      @conf_before = Pry.config.state_hook_enabled
      Pry.config.state_hook_enabled = true
    end
    after { Pry.config.state_hook_enabled = @conf_before }
    When(:output) { capture_pry_command("toggle-state", binding) }
    Then { Pry.config.state_hook_enabled == false }
    Then { output.include? "pry-state disabled." }
  end

  context "when the hook is disabled" do
    before do
      @conf_before = Pry.config.state_hook_enabled
      Pry.config.state_hook_enabled = false
    end

    after { Pry.config.state_hook_enabled = @conf_before }
    When(:output) { capture_pry_command("toggle-state", binding) }
    Then { Pry.config.state_hook_enabled == true }
    Then { output.include? "pry-state enabled." }
  end
end
