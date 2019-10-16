# frozen_string_literal: true

require 'bundler/setup'
Bundler.setup
require 'simplecov'
SimpleCov.start do
  add_filter '/spec'
  add_filter '/lib/ext'
end
SimpleCov.minimum_coverage(100)

require 'slack_notification'

RSpec.configure do |config|
  #
end
