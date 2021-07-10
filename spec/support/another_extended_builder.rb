# frozen_string_literal: true
class AnotherExtendedBuilder < EditInPlace::ExtendedBuilder
  def another_extension(name)
    "Hello, #{name}!"
  end
end
