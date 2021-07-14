# frozen_string_literal: true

module Helpers
  def ignore
    yield
  rescue EditInPlace::Error
  end
end
