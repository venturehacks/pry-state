require 'spec_helper'
require_relative "../lib/pry-state.rb"

describe "pry-state" do
  context "Set up" do
    Given(:config) { Pry.config.extra_sticky_locals[:pry_state] }
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
  end
end