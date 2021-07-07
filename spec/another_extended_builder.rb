class AnotherExtendedBuilder < EditInPlace::ExtendedBuilder
  def another_extension(name)
    "Hello, #{name}!"
  end
end
