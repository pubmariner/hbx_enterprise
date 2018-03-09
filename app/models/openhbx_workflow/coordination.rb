module OpenhbxWorkflow
  class Coordination
    include Singleton

    cattr_accessor :implementer

    def initialize
      @implementation = self.class.implementer
    end

    def self.generate_batch_name
      self.instance.generate_batch_name
    end

    def self.store_batch_entry(coord_kind, batch_name, index, batch_size, key_list, data)
      self.instance.store_batch_entry(coord_kind, batch_name, index, batch_size, key_list, data)
    end

    def self.batch_records(batch_name)
      self.instance.batch_records(batch_name)
    end

    def self.batch_complete?(batch_name)
      self.instance.batch_complete?(batch_name)
    end

    def self.clear_batch(batch_name)
      self.instance.clear_batch(batch_name)
    end

    def store_batch_entry(coord_kind, batch_name, index, batch_size, key_list, data)
      plain_data = nil
      large_meta_data = nil
      large_raw_data = nil
      if data.kind_of?(::OpenhbxWorkflow::LargeData)
        large_meta_data = data.metadata
        large_raw_data = data.data
      else
        plain_data = data
      end
      @implementation.store_entry(
        coord_kind,
        batch_name,
        index,
        batch_size,
        key_list,
        plain_data,
        large_meta_data,
        large_raw_data
      )
    end

    def batch_records(batch_name)
      @implementation.get_batch_members(batch_name)
    end

    def batch_complete?(batch_name)
      records = batch_records(batch_name)
      return false unless records.any?
      case records.first.coordination_kind
      when ::OpenhbxWorkflow::CoordinationKind::FULL_COLLECTION
        records.count == records.first.batch_size.to_i
      else
        records.first.key_list.sort == records.map(&:index).sort
      end
    end

    def clear_batch(batch_name)
      @implementation.clear_batch(batch_name)
    end

    def generate_batch_name
      @implementation.generate_batch_name
    end
  end
end
