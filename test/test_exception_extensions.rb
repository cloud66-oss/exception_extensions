require 'minitest/autorun'
require 'exception_extensions'

module ExceptionExtensions
  class ExceptionExtensionsTest < Minitest::Test

    def test_no_exception_path
      assert ExceptionPathTraverser.new(nil).to_a.empty?
    end

    def test_single_exception_path
      exception = capture_exception { raise A }
      exception_traverser = ExceptionPathTraverser.new(exception)

      path_array = exception_traverser.to_a
      assert_equal path_array.size, 1

      path = path_array.first
      assert_equal path.size, 1
      assert_equal path.first, exception
    end

    def test_linear_exception_path
      exception = capture_exception { reraise_with(C) { reraise_with(B) { raise A } } }
      exception_traverser = ExceptionPathTraverser.new(exception)

      path_array = exception_traverser.to_a
      assert_equal path_array.size, 1

      path = path_array.first
      assert_equal path.size, 3 # there are three exceptions - A, which is reraised with B, which is reraised with C
      assert_equal path[0], exception
      assert_equal path[1], exception.cause
      assert_equal path[2], exception.cause.cause
    end

    def test_branched_exception_path
      threads = []
      exceptions = []
      exceptions_mutex = Mutex.new
      threads << Thread.new do
        capture_exception_in_array(exceptions, exceptions_mutex) { reraise_with(C) { reraise_with(B) { raise A } } }
      end
      threads << Thread.new do
        capture_exception_in_array(exceptions, exceptions_mutex) { reraise_with(C) { reraise_with(F) { reraise_with(G) { raise H } } } }
      end
      threads << Thread.new do
        capture_exception_in_array(exceptions, exceptions_mutex) { raise H }
      end
      threads << Thread.new do
        capture_exception_in_array(exceptions, exceptions_mutex) do
          internal_threads = []
          internal_exceptions = []
          internal_exceptions_mutex = Mutex.new
          internal_threads << Thread.new do
            capture_exception_in_array(internal_exceptions, internal_exceptions_mutex) { reraise_with(C) { reraise_with(B) { raise A } } }
          end
          internal_threads << Thread.new do
            capture_exception_in_array(internal_exceptions, internal_exceptions_mutex) { raise H }
          end
          internal_threads.map(&:join)
          raise I.new(internal_exceptions)
        end
      end
      threads.map(&:join)
      exception = capture_exception do
        reraise_with(D) do
          raise E.new(exceptions)
        end
      end
      exception_traverser = ExceptionPathTraverser.new(exception)
      path_array = exception_traverser.to_a
      expected_path_classes = [[D, E, C, B, A], [D, E, C, F, G, H], [D, E, H], [D, E, I, C, B, A], [D, E, I, H]]
      expected_number_of_paths = expected_path_classes.size
      actual_path_classes = path_array.map { |path| path.map(&:class) }
      actual_number_of_paths = actual_path_classes.size
      assert_equal expected_number_of_paths, actual_number_of_paths
      expected_path_classes.each do |path_class_array|
        assert actual_path_classes.include?(path_class_array)
      end
    end

    private

    class A < StandardError;
    end
    class B < StandardError;
    end
    class C < StandardError;
    end
    class D < StandardError;
    end
    class E < StandardErrorCollection;
    end
    class F < StandardError;
    end
    class G < StandardError;
    end
    class H < StandardError;
    end
    class I < StandardErrorCollection;
    end

    def capture_exception_in_array(array, mutex)
      yield
    rescue => exc
      mutex.synchronize { array << exc }
    end

    def capture_exception
      captured_exception = nil
      begin
        yield
      rescue => exc
        captured_exception = exc
      end
      captured_exception
    end

    def reraise_with(exc)
      begin
        yield
      rescue
        raise exc
      end
    end

  end
end