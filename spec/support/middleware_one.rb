require 'middlegem'

class MiddlewareOne < Middlegem::Middleware
  def call(options, input)
    [options, input + '*ONE*']
  end
end
