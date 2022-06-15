# @example Rails application example.
#   class ApplicationController < ActionController::Base
#     if ::Rails.env.test?
#       rescue_from ::Exception do |exception|
#         ::UnhandledExceptionRspecFormatter.unhandled_exception = exception
#         raise exception
#       end
#
#       before_action do
#         ::UnhandledExceptionRspecFormatter.unhandled_exception = nil
#       end
#     end
#   end
#
# @example Run this formatter like this.
#   bundle exec rspec --format doc --format UnhandledExceptionRspecFormatter
#
class UnhandledExceptionRspecFormatter
  ::RSpec::Core::Formatters.register self, :example_failed

  class << self
    attr_accessor :unhandled_exception
  end

  def initialize(output)
    @output = output
  end

  def example_failed(notification)
    exception = self.class.unhandled_exception
    return if exception.nil?

    @output.puts <<~TEXT
      Unhandled exception:
        class:
          #{exception.class}
        message:
          #{exception}
        short backtrace:
      #{exception.backtrace.take(10).join("\n").indent(4)}
    TEXT
  end
end
