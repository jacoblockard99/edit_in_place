# frozen_string_literal: true

require 'middlegem'

class MiddlewareOne < Middlegem::Middleware
  def call(options, input)
    [options, "#{input}*ONE*"]
  end
end
