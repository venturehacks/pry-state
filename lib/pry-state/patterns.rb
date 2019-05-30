module PryState
  # A place to share regex
  module Patterns
    # Matching ruby global, instance, class and local variables.
    VARIABLE_PATTERN = /(?:\$|@@?)? \w\w*/x
  end
end