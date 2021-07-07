class ComplexTestFieldType < EditInPlace::FieldType
  protected

  def render_viewing(options, data, str)
    "#{str} #{data} #{str}"
  end

  def render_editing(options, data, str)
    "||#{str} |#{data}| #{str}||"
  end
end
