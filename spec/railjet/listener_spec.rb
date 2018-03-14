require "spec_helper"
require "railjet/bus"

describe Railjet::Listener do
  class DummyListener < Railjet::Listener
    listen_to :dummy_event do
      "Dummy event run"
    end

    listen_to :dummy_event_with_arg do |x: 1|
      "Dummy event run with arg: #{x}"
    end
  end

  subject(:listener) { DummyListener }

  it "registers subscriptions" do
    expect(listener.subscriptions).to eq %i[dummy_event dummy_event_with_arg]
  end

  describe "calling through class method" do
    it "calls listener" do
      expect(listener.on_dummy_event).to eq "Dummy event run"
    end

    it "calls listener with default args" do
      expect(listener.on_dummy_event_with_arg).to eq "Dummy event run with arg: 1"
    end

    it "calls listener overriding default args" do
      expect(listener.on_dummy_event_with_arg(x: 2)).to eq "Dummy event run with arg: 2"
    end
  end

  describe "#around_listener callback" do
    class DummyListenerWithCallback < Railjet::Listener
      attr_accessor :event, :tenant_id

      def around_listener(event, **kwargs)
        self.tenant_id = kwargs.fetch(:tenant_id)
        self.event     = event
        yield(**kwargs.except(:tenant_id))
      ensure
        self.tenant_id = nil
      end

      listen_to :dummy_event do
        "Dummy event run with tenant set: #{tenant_id}"
      end

      listen_to :dummy_event_with_arg do |x: 1|
        "Dummy event run with arg: #{x} and tenant set: #{tenant_id}"
      end

      listen_to :who_am_i? do
        "I am #{event}"
      end
    end

    subject(:listener) { DummyListenerWithCallback }

    it "calls listener" do
      expect(listener.on_dummy_event(tenant_id: 111)).to eq "Dummy event run with tenant set: 111"
    end

    it "calls listener with default args" do
      expect(listener.on_dummy_event_with_arg(tenant_id: 222)).to eq "Dummy event run with arg: 1 and tenant set: 222"
    end

    it "calls listener overriding default args" do
      expect(listener.on_dummy_event_with_arg(tenant_id: 333, x: 2)).to eq "Dummy event run with arg: 2 and tenant set: 333"
    end

    describe "#around_filter" do
      it "knows which event was called" do
        expect(listener.on_who_am_i?(tenant_id: 444)).to eq "I am who_am_i?"
      end
    end
  end
end