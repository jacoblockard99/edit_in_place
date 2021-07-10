# frozen_string_literal: true
class TestFieldType < EditInPlace::FieldType
  attr_reader :arg

  def initialize(arg)
    @arg = arg
  end

  def dup
    TestFieldType.new(arg.dup)
  end

  protected

  def render_viewing(_options, *args)
    "Init: #{arg}, After: #{args.first}"
  end

  def render_editing(_options, *args)
    "EDITING: Init: #{arg}, After: #{args.first}"
  end
end
