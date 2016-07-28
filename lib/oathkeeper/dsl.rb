module OathKeeper
  class DSL
    attr_reader :audited_model, :definition, :meta_hash
    def initialize(&block)
      @definition = block if block_given?
      @meta_hash = {}
    end

    def parse!(context)
      @audited_model = context
      self.instance_eval(&@definition)
      @meta_hash
    end

    def associate(associated_model, value)
      begin
        associate = @audited_model.send associated_model
        meta = {}
        if associate
          value[:fields].each do |field|
            attribute = associate.send(field)
            raise InvalidField if associate.class.reflections.keys.include?(field) && !value[:method]
            meta[field] = attribute
          end
          @meta_hash[associated_model] = meta
        end
      rescue InvalidField
        raise "cannot save a ActiveRecord Association in meta hash"
      rescue
        raise "#{associated_model} was not found for #{@audited_model.class}"
      end

      @meta_hash
    end
  end
end
