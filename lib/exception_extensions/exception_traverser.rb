module ExceptionExtensions
  class ExceptionTraverser
    include Enumerable
    attr_reader :exception

    def initialize(exception)
      @exception = exception
    end
  end
end