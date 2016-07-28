module OathKeeper
  module Helpers
    def mongo(collection)
      OathKeeper.mongo(collection)
    end

    def versions_col
      mongo("versions")
    end

    def archive_col
      mongo("archive")
    end

  end
end
