# frozen_string_literal: true

require 'middlegem'

class MiddlewareThree < Middlegem::Middleware
  def call(options, input)
    [options, "#{input}$THREE$"]
  end
end