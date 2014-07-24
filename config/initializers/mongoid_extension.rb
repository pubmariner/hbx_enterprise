module Mongoid
  module Document

    # List of all embedded model names defined for this instance
    def all_embedded_model_names
      names = []
      self.relations.each do |name, relation|
        names << name if [:embeds_one, :embeds_many].include? relation.macro.to_sym
      end
      names
    end

    # List of embedded model names populated with data for this instance
    def embedded_populated_model_names
      names = []
      self.all_embedded_model_names.each { |em| names << em unless self.send(em.to_sym).empty? }
      names
    end

    def all_embedded_documents
      docs = []
      self.all_embedded_model_names.each { |em| docs << self.send(em.to_sym) unless self.send(em.to_sym).empty? }
      docs
    end

    def all_embedded_documents_valid?
      self.all_embedded_documents.each do |doc|
        doc.all? { |rec| rec.valid? }
      end
    end

    #
    def all_embedded_document_changes
      data = {}
      self.embedded_populated_model_names.each do |name|
        model_data = self.send(name.to_sym).map { |ed| ed.changes_for_document }
        model_data = model_data.select { |md| md.keys.many? }
        next unless model_data.any?
        data[name.to_sym] = model_data
      end

      data
    end

    def changes_with_embedded
      embedded_data = self.all_embedded_document_changes
      self_changes = self.changes_for_document
      field_data = self_changes.keys.many? ? {self.model_name.underscore.to_sym => Array[self_changes]} : {}

      field_data.merge!(embedded_data) unless embedded_data.empty?
      field_data
    end

    def changes_for_document
      data = {_id: self._id}
      self.changes.each do |key, change|
        unless only_blanked_a_nil?(change)
          data[key.to_sym] = {from: change[0], to: change[1]}
        end
      end
      data
    end

    def only_blanked_a_nil?(change)
      change[0].blank? && change[1].blank?
    end

    def embedded_error_messages
      msgs = []
      self.all_embedded_documents.flatten.each do |doc|
        doc.errors.messages.each do |field_name, messages|
          messages.each do |msg|
            msgs << msg
          end
        end
      end
      msgs
    end
  end
end
