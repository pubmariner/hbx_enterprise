class DeletionDeltaExtractor
  def initialize(form_params)
    @form_params = form_params
  end

  def extract
    collection_deltas = Hash.new

    @form_params.each do |key, value|
      next unless(key.include? '_attributes')
      nested_attrs = value

      deleted = nested_attrs.select do |key, value|
        is_deletion?(value) && is_persisted_document?(value)
      end

      deleted.each_value do |item|
        delta = Hash.new
        item.each do |key, value|
          next if key == '_destroy'

          if(key == 'id')
            key = '_id'
          end
          delta[key.to_sym] = { :from => value, :to => nil}
        end

        association = key.split('_').first
        association = association.chomp('"').reverse.chomp('"').reverse

        collection_deltas[association.to_sym] ||= []
        collection_deltas[association.to_sym] << delta
      end
    end
    collection_deltas
  end

  private

  def is_deletion?(field)
    field[:_destroy] == '1'
  end

  def is_persisted_document?(field)
    field.has_key?('id')
  end
end
