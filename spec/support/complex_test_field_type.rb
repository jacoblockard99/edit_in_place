# frozen_string_literal: true

class ComplexTestFieldType < EditInPlace::FieldType
  protected

  def render_viewing(_options, data, str)
    "#{str} #{data} #{str}"
  end

  def render_editing(_options, data, str)
    "||#{str} |#{data}| #{str}||"
  end
end
