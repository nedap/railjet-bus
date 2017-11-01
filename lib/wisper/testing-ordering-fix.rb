require "wisper/testing"

module Wisper
  class Testing
    # Sets all broadcasters to FakeBroadcaster which does not broadcast any
    # events to the subscriber.
    #
    # @return self
    #
    def self.fake!
      store_original_broadcasters
      Wisper.configuration.broadcasters.keys.each do |key, broadcaster|
        Wisper.configuration.broadcasters[key] = FakeBroadcaster.new
      end

      # Monkeypatch start
      store_global_broadcasters
      Wisper::GlobalListeners.registrations.each do |registration|
        registration.instance_variable_set("@broadcaster", FakeBroadcaster.new)
      end
      # Monkeypatch end

      is_enabled
      self
    end

    # Sets all broadcasters to InlineBroadcaster which broadcasts event
    #  to the subscriber synchronously.
    #
    #  @return self
    #
    def self.inline!
      store_original_broadcasters
      Wisper.configuration.broadcasters.keys.each do |key, broadcaster|
        Wisper.configuration.broadcasters[key] = InlineBroadcaster.new
      end

      # Monkeypatch start
      store_global_broadcasters
      Wisper::GlobalListeners.registrations.each do |registration|
        registration.instance_variable_set("@broadcaster", InlineBroadcaster.new)
      end
      # Monkeypatch end

      is_enabled
      self
    end

    # Sets all broadcasters to InlineBroadcaster which broadcasts event
    #  to the subscriber synchronously.
    #
    #  @return self
    #
    def self.inline
      inline!
      yield
      restore!
      self
    end

    # Restores the original broadcasters configuration
    #
    # @return self
    #
    def self.restore!
      if enabled?
        Wisper.configuration.broadcasters.clear
        original_broadcasters.each do |key, broadcaster|
          Wisper.configuration.broadcasters[key] = broadcaster
        end

        # Monkeypatch start
        Wisper::GlobalListeners.registrations.each do |registration|
          registration.instance_variable_set("@broadcaster", global_broadcaster_for(registration))
        end
        # Monkeypatch end

        is_not_enabled
      end
      self
    end

    def self.global_broadcasters
      @global_broadcasters
    end

    def self.global_broadcaster_for(registration)
      global_broadcasters[[registration.listener, registration.on]]
    end

    def self.store_global_broadcasters
      @global_broadcasters = Wisper::GlobalListeners.registrations.map do |registration|
        key = [registration.listener, registration.on]
        val = registration.broadcaster

        [key, val]
      end.to_h
    end
  end
end
