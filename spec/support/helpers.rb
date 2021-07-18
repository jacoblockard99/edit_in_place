# frozen_string_literal: true

# rubocop:disable Lint/SuppressedException
module Helpers
  def ignore
    yield
  rescue EditInPlace::Error, Middlegem::Error
  end
end
# rubocop:enable Lint/SuppressedException
