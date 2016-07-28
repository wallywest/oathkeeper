module OathKeeper
  module Adapter
    class FileSystem
      def self.write(p)
        OathKeeper.logger.info(p)
      end

      def self.error(p)
        OathKeeper.logger.error(p)
      end
    end
  end
end
