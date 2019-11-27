module ExceptionExtensions
  class StandardErrorCollection < StandardError
    include CauseEnumerable
  end
end