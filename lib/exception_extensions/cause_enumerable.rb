module ExceptionExtensions
  module CauseEnumerable
    def self.included(klass)
      raise "The ::ExceptionExtensions::CauseEnumerable module is only applicable to ::Exception types" unless klass.is_a?(::Exception)
      klass.class_eval do
        include Enumerable
        attr_reader :causes
      end
    end

    def initialize(causes, message = nil)
      validate(causes)
      @causes = causes
      if message.nil?
        # generate a message from the collection of causes
        cause_messages = @causes.map { |cause| "Exception: #{cause.message}" }
        message = "Multiple exceptions occurred! #{cause_messages.join('. ')}"
      end
      # add the message to this exception
      super(message)
    end

    def each(&block)
      @causes.each(&block)
    end

    private

    def validate(causes)
      # require causes to be provided
      raise "The initializer for #{self.class.name} requires an enumerable collection of causes" unless causes.is_a?(::Enumerable)
      # require causes to be provided
      raise "The initializer for #{self.class.name} requires a non-empty collection of causes" if causes.empty?
      # causes should be exceptions
      raise "The initializer for #{self.class.name} requires causes to be ::Exception types" if causes.any? { |cause| !cause.is_a?(::Exception) }
    end
  end
end