# frozen_string_literal: true

require 'middlegem'

class MiddlewareOne < Middlegem::Middleware
  def call(options, input, *args)
    [options, "#{input}*ONE*", *args]
  end
end
