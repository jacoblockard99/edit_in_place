require 'middlegem'

class MiddlewareTwo < Middlegem::Middleware
  def call(options, input)
    [options, input + '!TWO!']
  end
end
