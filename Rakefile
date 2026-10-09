# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

task default: [:spec, :rubocop]

namespace :code_lists do
  desc "Regenerate data/*.json from an OpenPEPPOL/peppol-bis-invoice-3 tag, e.g. rake code_lists:update[v3.0.20]"
  task :update, [:tag] do |_task, args|
    abort "Usage: rake code_lists:update[TAG]" unless args[:tag]

    require_relative "tools/generator"
    PeppolCodeLists::Generator.new(tag: args[:tag]).run.each { |path| puts "wrote #{path}" }
  end
end
