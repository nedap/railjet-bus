begin
  require "wisper/testing"
  require "wisper/testing-ordering-fix"
rescue LoadError
  puts "Railjet::Bus::Testing will only work in test environment"
end

module Railjet
  class Bus
    module Testing
      class << self
        delegate :adapter, to: Bus
        delegate :clear,   to: :adapter
        delegate :inline,  to: :testing

        def testing
          adapter::Testing
        end
      end
    end
  end
end