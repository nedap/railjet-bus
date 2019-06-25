require "wisper"
require "wisper/sidekiq"

require "railjet"
require "railjet/bus"


Railjet::Bus.adapter = Wisper
