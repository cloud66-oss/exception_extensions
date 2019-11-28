Gem::Specification.new do |gem|
  gem.name = 'exception_extensions'
  gem.version = '1.0.0'
  gem.date = '2019-11-27'
  gem.summary = 'Useful extensions for Ruby Exceptions'
  gem.description = 'Useful extensions for Ruby Exceptions; Adds support for Exceptions with multiple causes (useful when executing fan-out operations) and Exception cause traversal.'
  gem.author = 'Cloud 66'
  gem.email = 'hello@cloud66.com'
  gem.homepage = 'https://github.com/cloud66-oss/exception_extensions'
  gem.files = `git ls-files`.split("\n")
  gem.license = 'Apache-2.0'
end