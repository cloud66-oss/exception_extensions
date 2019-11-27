module ExceptionExtensions
  module CauseEnumerable
    def self.included(klass)
      klass.class_eval do
        include Enumerable
        attr_reader :causes
      end
    end

    def initialize(*causes)
      causes = causes.flatten
      validate(causes)
      @causes = causes
    end

    def each(&block)
      @causes.each(&block)
    end

    private

    def validate(causes)
      # require causes to be provided
      raise "The initializer for #{self.class.name} requires a non-empty collection of causes" if causes.empty?
      # causes should be exceptions
      raise "The initializer for #{self.class.name} requires causes to be ::Exception types" if causes.any? { |cause| !cause.is_a?(::Exception) }
    end
  end
end