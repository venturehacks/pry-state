require 'spec_helper'
require 'ostruct'
require_relative "../lib/pry-state.rb"

RSpec.describe PryState::HookAction do
  context "When a binding.pry called" do
    # create a sticky locals hash with different @b value to get it in green color
    Given(:pry_mock){
      OpenStruct.new(
        :config =>  OpenStruct.new(
                      :extra_sticky_locals  =>  {
                        :pry_state_prev =>  {
                          :@b =>  'wd' }
                        }
                    )
                  )
    }

    context "when hook is enabled" do
      # begin/end codes for bright_yellow
      Given(:val_chg_begin_code) {"\e[0m\e[1;33m"}
      Given(:val_chg_end_code) { "\e[0m\n\e[0;32m@c" }
      Given(:a) { 1 }
      Given(:b) { "world" }
      Given(:cs) { [1, 2, 4, 5] }
      Given(:beed) { %Q!#{val_chg_begin_code}"#{b}"#{val_chg_end_code}! }
      Given(:ceed) { "len:#{cs.count} #{cs}" }


      before do
        Pry.config.state_hook_enabled = true
        @b = b
        @c = cs
      end

      When(:output) {
        capture_stdout do
          PryState::HookAction.new(binding, pry_mock).act
        end
      }

      Then { output.include? 'a' }
      Then { output.include? a.to_s }
      Then { output.include? '@b' }
      Then { output.include? beed }
      Then { output.include? '@c' }
      Then { output.include? ceed }
    end

    context "when hook is disabled" do
      before { Pry.config.state_hook_enabled = false }

      it "doesn't print anything" do
        output = capture_stdout do
          PryState::HookAction.new(anything, anything).act
        end
        expect(output).to be_empty
      end

      context "when force is true" do
        it "prints the current state" do
          user = "Superman"
          output = capture_stdout do
            PryState::HookAction.new(binding, pry_mock).act(true)
          end
          line = output.lines.find { |l| l.include? "user" }
          expect(line).not_to be_nil
          expect(line).to include "Superman"
        end
      end
    end

  end
end
