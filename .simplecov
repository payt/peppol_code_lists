# frozen_string_literal: true

SimpleCov.configure do
  enable_coverage :branch
  primary_coverage :branch

  skip "/spec/"

  minimum_coverage line: 100, branch: 100
  refuse_coverage_drop :line, :branch
end
