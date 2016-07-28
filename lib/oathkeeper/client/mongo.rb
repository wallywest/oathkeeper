require 'origin'

module OathKeeper
  class Client
    include Origin::Queryable
    attr_reader :connection

    def initialize
      super
    end

    def execute
      selector = self.selector.dup
      options = self.options.dup
      result = connection.find(selector,options)
      result
    end

    private

    def connection
      @connection = OathKeeper.mongo("archive")
    end
  end
end
