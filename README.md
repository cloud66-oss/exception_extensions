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
gem 'rails'
```

## Use

TBD
