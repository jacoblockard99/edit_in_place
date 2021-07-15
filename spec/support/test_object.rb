# frozen_string_literal: true

class TestObject
  attr_accessor :name, :attributes

  def initialize(name, attributes = {})
    @name = name
    @attributes = attributes
  end

  def dup
    TestObject.new(name.dup, attributes.deep_dup)
  end
end
