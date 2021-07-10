module Helpers
  def ignore
    yield
  rescue EditInPlace::Error
  end
end
