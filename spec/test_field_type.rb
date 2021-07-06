class TestFieldType < EditInPlace::FieldType
  attr_reader :arg

  def initialize(arg)
    @arg = arg
  end

  def render
    'Rendered!'
  end

  def dup
    TestFieldType.new(arg.dup)
  end
end

