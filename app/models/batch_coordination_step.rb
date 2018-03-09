class BatchCoordinationStep
  include Mongoid::Document
  include Mongoid::Timestamps

  field :batch_name, type: String
  field :coordination_kind, type: String
  field :index_key, type: String
  field :batch_size, type: Integer
  field :key_list, type: Array
  field :data, type: String
  field :large_metadata, type: Hash
  field :large_data_id, type: BSON::ObjectId
  field :is_large_data, type: Boolean, default: false

  index({:batch_name => 1})

  def self.store_entry(
    coord_kind,
    batch_name,
    index,
    batch_size,
    key_list,
    plain_data,
    large_meta_data,
    large_raw_data)
    if large_raw_data.nil?
      self.create!({
        :coordination_kind => coord_kind,
        :batch_name => batch_name,
        :index_key => index,
        :key_list => key_list,
        :plain_data => plain_data
      })
    else
      fs = self.collection.database.fs
      file_entry = Mongo::Grid::File.new(large_raw_data, :filename => "#{batch_name}_#{index}.data")
      l_data_id = fs.insert_one(file_entry)
      self.create!({
        :coordination_kind => coord_kind,
        :batch_name => batch_name,
        :index_key => index,
        :key_list => key_list,
        :large_metadata => large_meta_data,
        :large_data_id => l_data_id,
        :is_large_data => true
      })
    end
  end

  def self.get_batch_members(batch_name)
    self.where(:batch_name => batch_name.to_s)
  end

  def self.generate_batch_name
    BSON::ObjectId.new
  end

  def self.clear_batch(batch_name)
    batch_members = get_batch_members(batch_name)
    fs_bucket = self.collection.database.fs
    batch_members.select(&:is_large_data?).each do |bm|
      fs_bucket.delete(bm.large_data_id)
    end
    get_batch_members(batch_name).delete_all
  end

  def is_large_data?
    is_large_data
  end

  def large_data
    return nil unless is_large_data?
    # We'll fix this once the next version of the mongo driver returns a proper IO
    StringIO.new(large_data_file.data)
  end

  def index
    index_key
  end

  private
  def large_data_file
    fs_client = self.collection.database.fs
    # We'll fix this once the next version of the mongo driver returns a proper IO
    fs_client.find_one({:_id => large_data_id})
  end
end
