module OathKeeper
  module Adapter
    MONGO_ADAPTER = :MongoAdapter
    FILE_ADAPTER = :FileSystem

    def self.write(payload)
      versions = OathKeeper::version_definitions.map(&:versions).flatten
      OathKeeper::Adapter::Mongo::write(payload,versions)
      #OathKeeper::Adapter::FileSystem::write(payload.to_json)
    end
  end
end
