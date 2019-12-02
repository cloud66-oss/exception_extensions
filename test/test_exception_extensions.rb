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