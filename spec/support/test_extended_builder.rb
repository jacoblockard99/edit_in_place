class TestExtendedBuilder < EditInPlace::ExtendedBuilder
  def an_extension
    field TestFieldType.new('An Extended Field!')
  end
end