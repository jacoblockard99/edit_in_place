# frozen_string_literal: true

require 'middlegem'

class MiddlewareThree < Middlegem::Middleware
  def call(options, input, *args)
    [options, "#{input}$THREE$", *args]
  end
end
