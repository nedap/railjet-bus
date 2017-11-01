require "railjet"
require "railjet/bus"

require "wisper"
require "wisper/sidekiq"

Railjet::Bus.adapter = Wisper
