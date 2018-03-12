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

  class Listener
    include Railjet::Util::UseCaseHelper

    class << self
      def subscriptions
        @subscriptions ||= []
      end

      def listen_to(event, &block)
        subscriptions << event
        define_listeners(event, &block)
      end

      private

      def define_listeners(event, &block)
        name = listener_name(event)
        define_listener(name, &block)
        define_listener_caller(name)
      end

      def define_listener(name, &block)
        define_method name do |**kwargs|
          around_listener(kwargs) { |args| instance_exec(args, &block) }
        end
      end

      def define_listener_caller(name)
        define_singleton_method name do |**kwargs|
          new.public_send(name, **kwargs)
        end
      end

      def listener_name(event)
        "on_#{event}"
      end
    end

    # This around block does nothing
    # but it's there as point of extensions so it could be easily overridden in
    # sub-class if some additional setup is needed
    def around_listener(**kwargs)
      yield(**kwargs)
    end
  end
end
