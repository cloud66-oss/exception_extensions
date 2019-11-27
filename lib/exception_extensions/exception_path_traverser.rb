module ExceptionExtensions
  class ExceptionPathTraverser < ExceptionTraverser
    def each(&block)
      return if @exception.nil?
      each_internal(@exception, [], &block)
    end

    private

    def each_internal(exception, path, &block)
      # NOTE: path.clone is required because otherwise to_a will return empty array (since path will be an empty array after everything has executed)
      # NOTE: path.clone will clone the array, but not the exceptions, so duplicate exceptions will be the same object ID!
      return block.call(path.clone) if exception.nil?
      path.push(exception)
      if exception.respond_to?(:causes)
        exception.causes.each do |cause|
          each_internal(cause, path, &block)
        end
      else
        each_internal(exception.cause, path, &block)
      end
      path.pop
    end
  end
end