<img src="http://cdn2-cloud66-com.s3.amazonaws.com/images/oss-sponsorship.png" width=150/>

# ExceptionExtensions

ExceptionExtensions provides some custom Exception types to handle Exception collections. It also provides some helpers that enable traversal of the exceptions and the their causes.

Whenever you perform a fanout operation that then joins again, there could potentially be more than one exception raised. This library provides some simple and easy to use classes to handle these scenarios.

To illustrate this, assume we want to perform an operation that itself does three things internally. Each of the three things it does occur in parallel. At the end of the operation we can gather all the exceptions that might have occurred. We can then raise a `StandardErrorCollection` (or custom collection that has the `CauseEnumerable` mixin) to encapsulate all of these exceptions. In the future, to log these for example, we can determine the exception path for each distinct exception via the `ExceptionPathTraverser`.

## Install

Installing the gem directly:
```
gem install exception_extensions
```

If using `bundler`, add to your `Gemfile`:

```
gem 'exception_extensions'
```

## Usage Examples

### Assume the following operation
```ruby
def the_operation
  # collection of exceptions
  exceptions = []
  (1..2).each do |i|
    begin
      if i == 1
        # cause "divided by 0" error
        1/0
      else
        # cause "ArgumentError"
        raise ArgumentError.new('expected a 1')
      end
    rescue => exc
      exceptions << exc
    end
  end
  # raise a collection exception
  raise ::ExceptionExtensions::StandardErrorCollection.new(exceptions, 'multiple exceptions occurred during the_operation') unless exceptions.empty?
end
```

### Example1: Calling the_operation directly
```ruby
begin
  the_operation  
rescue => exc
  # output exception
  puts "exception0 class: #{exc.class.name}"
  puts "exception0 message: #{exc.message}"
  # we can look at the collection of exception causes directly
  # for Exceptions that implement ::ExceptionExtensions::CauseEnumerable
  exc.causes.each_with_index do |cause, idx| 
    puts "exception#{idx+1} class: #{cause.class.name}"
    puts "exception#{idx+1} message: #{cause.message}"
  end
end
```
**OUTPUT** 
```
exception0 class: ExceptionExtensions::StandardErrorCollection
exception0 message: multiple exceptions occurred during the_operation
exception1 class: ZeroDivisionError
exception1 message: divided by 0
exception2 class: ArgumentError
exception2 message: expected a 1
```

### Example2: Calling the_operation indirectly resulting in an exception chain
```ruby
# here, we illustrate traversing the exception chain
def handle_operations
  the_operation  
rescue => exc
  raise "Unable to handle operations"  
end

begin
  handle_operations
rescue => exc
  # now, we create a path traverser for each unique exception path
  # (there may be causes within cause for an exception chain)
  exception_traverser = ::ExceptionExtensions::ExceptionPathTraverser.new(exc)
  # traverse each unique exception path 
  exception_traverser.each do |exception_path| 
    # output exception information
    exception_path.each_with_index do |exception, idx| 
      puts "exception#{idx} class: #{exception.class.name}"
      puts "exception#{idx} message: #{exception.message}"
    end
    # output exception information as a chain of messages    
    puts "JOINED: \"#{exception_path.join(' => ')}\""
    puts
  end
end
```
**OUTPUT** 
```
exception0 class: RuntimeError
exception0 message: Unable to handle operations
exception1 class: ExceptionExtensions::StandardErrorCollection
exception1 message: multiple exceptions occurred during the_operation
exception2 class: ZeroDivisionError
exception2 message: divided by 0
JOINED: "Unable to handle operations => multiple exceptions occurred during the_operation => divided by 0"

exception0 class: RuntimeError
exception0 message: Unable to handle operations
exception1 class: ExceptionExtensions::StandardErrorCollection
exception1 message: multiple exceptions occurred during the_operation
exception2 class: ArgumentError
exception2 message: expected a 1
JOINED: "Unable to handle operations => multiple exceptions occurred during the_operation => expected a 1"

```  
