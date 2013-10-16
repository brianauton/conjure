require "minitest/autorun"
require_relative "../lib/conjure"

class Test < Minitest::Unit::TestCase
  def self.test(name, &block)
    symbol = "test_#{name.gsub(/\s+/,'_')}".to_sym
    raise "Duplicate test '#{name}'" if instance_methods.include? symbol
    define_method symbol, &block
  end
end
