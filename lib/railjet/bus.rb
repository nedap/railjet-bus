module Railjet
  module Publisher
    def self.included(klass)
      raise "Railjet::Bus adapter must be specified" unless Railjet::Bus.adapter

      klass.__send__(:include, Railjet::Bus.publisher)
      klass.__send__(:include, CustomSubscription)
    end

    module CustomSubscription
      def subscribe(event, subscriber)
        super(subscriber, on: event, prefix: true)
      end
    end
  end

  class Bus
    class << self
      attr_accessor :adapter
      delegate :publisher, to: :adapter
    end

    def initialize(adapter: self.class.adapter)
      @bus = adapter or raise ArgumentError, "Railjet::Bus adapter must be specified"
    end

    def subscribe(event, subscriber)
      bus.subscribe(subscriber, on: event, prefix: true, async: true)
    end

    private

    attr_reader :bus
  end
end
