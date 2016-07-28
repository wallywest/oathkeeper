module OathKeeper
  module Adapter
    module Mongo
      include OathKeeper::Helpers
      extend OathKeeper::Helpers

      def self.write(payload,versions)
        #schema
        #{:a => app_id, :u => user, :ts => time, :c => controller, :a => action, :e => events[], :assoc => message[]}
        #insert = MultiJson.load(payload)
        insert = payload.to_hash
        t = payload[:ts]

        begin
          id = BSON::ObjectId.new
          insert.merge!({"_id" => id})
          archive_col.insert(insert)
          write_version(versions,t,id)
        rescue ::Mongo::ConnectionFailure => ex
          Rails.logger.info("Mongo::ConnectionFailure: #{ex}")
          OathKeeper::Adapter::FileSystem::error(ex)
        rescue ::Mongo::OperationFailure => ex
          Rails.logger.info("Mongo::OperationFailure: #{ex}")
          OathKeeper::Adapter::FileSystem::error(ex)
        ensure
          OathKeeper::Adapter::FileSystem::write(insert)
        end
      end

      def self.write_version(versions,time,oid)
        versions.each do |version|
          dump = version.dump(time,oid)

          id = version.mongo_id
          update = {
            "$push" => {
              "v" => {
                "$each" => [dump],
                "$slice" => -25
              }
            }
          }

          upsert = {:upsert => true}

          versions_col.update({"_id" => id},update,upsert);
        end
      end
    end
  end
end
