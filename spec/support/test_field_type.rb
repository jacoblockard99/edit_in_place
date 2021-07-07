class TestFieldType < EditInPlace::FieldType
  attr_reader :arg

  def initialize(arg)
    @arg = arg
  end

  def dup
    TestFieldType.new(arg.dup)
  end

  protected

  def render_viewing(options, *args)
    "Init: #{arg}, After: #{args.first}"
  end

  def render_editing(options, *args)
    "EDITING: Init: #{arg}, After: #{args.first}"
  end
end

